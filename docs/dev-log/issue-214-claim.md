# Issue #214 — Two dispatchers cannot take the same issue

> Dev-log, not a spec. Started at plan time, finalised as a retrospective at PR time.

**Issue:** [#214](https://github.com/Calyx-Engineering/arc/issues/214)  ·  **PR:** [#284](https://github.com/Calyx-Engineering/arc/pull/284)

## Problem

`tools/arc-loop.sh` holds its position in GitHub state alone — which sub-issues are still open —
and nothing claims one. Two dispatchers read the same open list on 2026-09-07 and both picked
[#158](https://github.com/Calyx-Engineering/arc/issues/158). One cut the linked branch, built the
tool and measured; the other committed that working tree, wrote the dev-log, opened
[PR #212](https://github.com/Calyx-Engineering/arc/pull/212) and merged it while the first was
still probing. Nothing was lost, but the dev-log shipped single-run numbers the probe was in the
middle of disproving, and needed a follow-up commit.

The `in-progress` label looks like an interlock and is not one: it is set *after* selection, and
neither run reads it.

## Intent and north star

| | |
|---|---|
| **What this issue is really for** | Selection is not an interlock. Two dispatchers reading one list will pick one issue, and the second one has to be told to stop before it starts working |
| **North star** | A dispatcher that dies leaks nothing past one TTL, and a restarted loop resumes correctly — the claim is in GitHub for the same reason the position is |
| **What makes it durable** | The read-back is the interlock, not the post. A claim that trusts its own write is #206's defect in a new place |
| **Out of scope** | Interlocking *runs*. A run is a detached `claude -p` that outlives the shell that launched it, by design. This claims for dispatchers, and the gap is named in the tool's header rather than papered over |

## Decisions & trade-offs

| | |
|---|---|
| **The claim is an issue comment** | It carries an owner token, a timestamp and a TTL in its own body, has a monotonic id that settles a race, and deletes cleanly — so a released claim leaves the issue as it found it |
| **The owner is the dispatcher PROCESS** | `<host>/<pid>/<random>`. Two dispatchers run as the same GitHub account, which is exactly why the account cannot be the identity |
| **The lowest live comment id wins** | Not the earliest epoch. A heartbeat rewrites the epoch, so ordering on it would hand the issue to whoever arrived second |
| **Post, then read back, then withdraw** | Posting is not atomic. Each dispatcher reads after its own post, ids are monotonic, so with `post_A < post_B` the later poster always sees the earlier one and withdraws. The case where both win needs both reads to precede both posts, which that ordering forbids |
| **A pre-check before the post** | The common case — an issue somebody already holds — costs one read and leaves no comment behind. It is an optimisation; the read-back is the correctness |
| **`epoch + ttl > now`, exclusive** | A claim cannot outlive its TTL by a second. `ttl` is *how long after the dispatcher dies before the issue is free*, not how long a run may take — which is what the heartbeat is for |
| **The heartbeat rides the poll loop `wait_run` already runs** | Every tenth poll: five minutes against a 30-minute TTL. No new timer, no new process. The rate-limit wait gets one too — `sleep_heartbeat` slices it, because `ARC_LOOP_RETRY_WAIT` is a knob and nothing else couples it to the TTL |
| **One owner per dispatcher, not per `arc-claim.sh` call** | Every issue the loop holds carries the same name, and the pid in the claim comment is the dispatcher's rather than a helper process that exited seconds later |
| **A killed dispatcher's token is recorded beside its run, and only `--resume` may pick it up** | A fresh process mints a fresh token, so without this a restarted loop reads its own claim as somebody else's for a full TTL — the north star row above. The token is a **bearer credential** and `.arc-work/runs/` is shared by every dispatcher started from this checkout, so what makes it safe is the caller: `--resume` has already established the run is dead. `run_batch` refuses outright when a worktree or a live run is there, so it never adopts — and its two guards were moved **above** its first claim, because a claim taken before them is a claim taken inside another dispatcher's workspace |
| **Three traps, and the signal ones exit** | A handler that returns hands control back to the line after the interrupted one, so a single `trap release_claims EXIT INT TERM` turned Ctrl-C into *drop the claim on the running issue, then dispatch the next one* — worse than the no-trap behaviour it replaced. 130 and 143 are the shell's own codes |
| **A lost race is bounded** | Five losses and the dispatcher stops. Each pass is several `gh` calls, and there was no ceiling |
| **`read_claimed` fails closed** | An unreadable claim list is indistinguishable from an empty one, and treating *I could not tell* as *nobody holds it* is the whole defect. `die`, rather than select blind |
| **A lost race returns 3, not 1** | Losing a race is not a failed run. The loop re-reads the claimed set, skips that issue and picks another; `--issues` says so and stops, because the batch was named by a human |
| **Not declared `mode-guard: writes-outward`** | The guard's contract is commit, push, PR and merge — [#201](https://github.com/Calyx-Engineering/arc/issues/201). A claim comment is bookkeeping that deletes itself, and `check`/`claimed` are reads that must work in manual mode. `arc-loop.sh` is declared, and that is where the gate belongs |

## Rejected approaches

| Rejected | Why |
|---|---|
| An assignee | Two dispatchers share a GitHub account, so an assignee cannot tell *mine* from *theirs* — the one question a claim has to answer |
| A label — `in-progress` or a new one | Same identity problem, plus no room for a timestamp. `in-progress` is out twice over: PR #200 gave it a human-facing contract, and it is set after selection |
| A lockfile | Invisible to a dispatcher on another machine, and #214's constraint is that position lives in GitHub so the loop can be killed and restarted |
| A `claimed_at` field in `.arc-work/runs/` | Same. It is the script holding state, which is what the constraint rules out |

## Cases

`bash tools/arc-claim.sh selftest` — 56 cases, run by `verify-all.sh` as **issue claim cases**.
The decision cases are pure functions over one list; the rest drive `take`, `refresh`, `release`,
`check` and `claimed` end to end through a **mutable fixture backend** (`ARC_CLAIM_FIXTURES`,
`ARC_CLAIM_NOW`), so argument parsing and exit codes are exercised with no network. One case
drives the live path instead, behind a stubbed `gh`.

| #214 asks for | Where |
|---|---|
| Two dispatchers racing | Both posted before either read, at the decision layer. Then through the real command, twice: the **pre-check**, which turns the second dispatcher away with no comment posted; and the **race proper**, where `ARC_CLAIM_AFTER_POST` lands a rival's lower-numbered claim between our post and our read-back — the one interleaving the pre-check cannot see, and so the only case that exercises the read-back and the withdrawal |
| A claim left by a killed run | An expired claim locks nothing, the expiry boundary is exclusive, an unrefreshed claim stops being live after its TTL, and the next reader reaps it |
| A claim released on every exit path | The tool half, executed: `release` removes ours and **only** ours with a second dispatcher's claim standing beside it, leaves an ordinary comment alone, and is not an error twice over. The caller half, as source text: **fifteen** checks on `arc-loop.sh` — the three traps, `release_claims`, the per-issue release when a run ends, `take_claim` in `run_batch` and `reclaim_claim` in `--resume`, that `reclaim_claim` has **exactly one** caller, and that `run_batch`'s worktree and liveness guards precede its first claim |

Structural checks follow `tests/verify-linked-branch.sh`'s precedent: the guarantee is one line of
shell, it cannot be exercised without dispatching a real run, and the first draft of this
integration released on the happy path only.

**Eleven mutations, each killing at least one case.** Dropping the unterminated-line guard (5
cases); a withdrawal that deletes nothing; `claims_on` swallowing a failed read; an inclusive
expiry; ordering the winner by epoch instead of id; `read_comments` failing quietly; moving
`run_batch`'s guards back below its claim; `--resume` calling `take_claim` instead of
`reclaim_claim`; `release` dropping its owner filter; `refresh` dropping its liveness filter; and
`settle` back to the integer test that skipped the window in silence.

## Retrospective

Four review passes. Each found defects the pass before had introduced or missed: pass 2's were in
pass 1's own repairs, and pass 3's were in the cases rather than the code.

**The live read found what 40 green fixture cases could not.** `read_comments` ended with
`printf '%s' "$out"`; command substitution strips the trailing newline, and `while read` at an
unterminated final line runs no body. So the **newest** comment was silently dropped — and the
newest comment is the only one a race turns on. On a live #214 holding exactly one claim, `check`
reported `free`.

It had already produced a visible symptom that was nearly mis-read as eventual consistency: a
second dispatcher posted, withdrew, and left its comment behind. The sequence explains itself
once the bug is known — its pre-check saw an empty list (last line dropped), so it posted; its
read-back saw two comments and dropped its own, so it correctly found itself second; then its
delete filtered for its own token among the claims it could see, and its own was the one it could
not. One bug, three symptoms.

The fixture backend hid it because `sort` terminates its output. The fixture now `cat`s the file
verbatim and `claims_on` carries `|| [ -n "$id" ]`, so **every** case runs through the guard — five
of them fail if it is removed, which is a stronger position than the one dedicated case it started
as.

**Pass 1 found twelve, and the two that mattered were about telling a failure from an answer.**
`claims_on` ran `read_comments` on the left of a pipeline, where its `exit 2` kills only that
subshell — so a rate limit read as *nobody holds this issue*, which is #214's own defect reachable
through one transient error. And `trap release_claims INT` released the claim and then **carried
on**, because a signal handler that returns resumes the script: Ctrl-C would have dropped the
claim on the issue whose run was still executing and dispatched the next one.

**Pass 2 read pass 1's repairs and found four more.** The worst was the token file written to
enable restart-resume: the token is a bearer credential, `.arc-work/runs/` is shared by every
dispatcher started from one checkout, and `run_batch` adopted from it *before* the guards that
say the directory is nobody else's — so a racing dispatcher could adopt a live peer's claim and
then have its own `die` delete that peer's claim comment mid-run. Adoption is now `--resume`'s
alone, after the guard that establishes the run is dead, and `run_batch`'s guards moved above its
first claim. Pass 2 also found `LOOP_HOST="$(hostname … | tr …)"` fatal under `pipefail` on a host
with no `hostname` — the fallback on the next line was unreachable, and it would have killed
`--status` and `--report` too — a non-integer `ARC_LOOP_RETRY_WAIT` turning the sliced rate-limit
wait into **no wait**, and the new failed-read case exiting at `repo_nwo` rather than at the read
it was written for.

**Pass 3 audited the checklist and found the cases, not the code, wanting.** Every box was backed
by code, but two mutations survived the whole suite: `cmd_release` dropping its owner filter, and
`cmd_refresh` dropping its liveness filter. Both slipped through for the same reason — every case
in the release family held **one** claim at a time, so *ours and only ours* was never tested with
anybody else's claim beside it. One dispatcher's release would have destroyed another's live
claim, and a lapsed dispatcher would have resurrected its own expired one and — holding the lower
id — beaten the legitimate holder. Two cases now stand a second dispatcher's claim next to ours.
Pass 3 also found `[ "$SETTLE" -gt 0 ] 2>/dev/null && sleep "$SETTLE"`: an integer test on `20s`
is an **error**, not a false, so any value `sleep` would have accepted skipped the settle window
in silence — the same class pass 2 had just fixed in `sleep_heartbeat`, one knob away.

**Exercised live**, on #214 and #134 in the real repository:

| | |
|---|---|
| `take` then `claimed 148` | `214 <host>/49250/2ab5db7d` — the issue and its holder |
| A second dispatcher | `#214 held by … — comment 5594028858`, exit 1, **no comment posted** |
| `release` | `#214 free`, comment count 0 — the issue left as it was found |
| Selection skips a claimed issue | `#134` claimed, then `arc-loop.sh 148 --dry-run` → `#134 claimed by another dispatcher` / `[1] issue run for #198` |

**Not soaked, and one part is unexercised.** The change is to the dispatcher, and a dispatcher is
not exercised by the run it dispatched — this one. `--dry-run` reaches `read_claimed` and
`next_issue` and nothing further: `run_batch` returns before its claim block, so `take_claim`,
`reclaim_claim`, the heartbeat, the per-issue release and all three traps have not executed once
outside the structural checks. It soaks on the next `tools/arc-loop.sh` invocation from the main
tree.

**Gates:** `bash tests/verify-all.sh` → exit 0, 47 gates clean, including the new **issue claim
cases** gate at 56. `bash tools/arc-claim.sh selftest` → 56 passed, 0 failed.
