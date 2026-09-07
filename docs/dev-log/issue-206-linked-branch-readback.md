# Issue #206 — createLinkedBranch reports success but forms no link

> Decision log, not a spec.

**Issue:** [#206](https://github.com/Calyx-Engineering/arc/issues/206)  ·  **PR:** [#223](https://github.com/Calyx-Engineering/arc/pull/223) — written in after it opened. The first draft of this line predicted #220, which turned out to be another issue's merged PR

## Problem

The run for [#155](https://github.com/Calyx-Engineering/arc/issues/155) created its branch with
`createLinkedBranch`, got a success node back, and then read `issue.linkedBranches` as
`totalCount: 0` while the branch was still on the remote. It filed that as a broken mutation.
[m12](../product-architecture/mechanisms/m12-issue-linking.md) records the same read as tested and
working, and `run-instructions.md` §4 mandates the mutation *specifically to form that link* with
nothing checking it formed.

## Intent and north star

| | |
|---|---|
| **What this issue is really for** | The arc mandates a mutation for its side-effect and never looks at the side-effect. That is the defect class this arc exists to fix, reproduced inside the arc's own instructions |
| **North star** | A run can state, from an exit code, that the branch↔issue link exists — at branch creation and again at pass 4 |
| **What makes it durable** | The check has to stay right as the link **moves**. A check pinned to one field at one moment is wrong half the time |
| **Out of scope** | Falling back to `git checkout -b`. The issue forbids it, and it turned out not to be needed |

## What was measured

`createLinkedBranch` is not broken. **The link moves.** Measured live on #206, 2026-09-07:

| Moment | `issue.linkedBranches` | PR `closingIssuesReferences` |
|---|---|---|
| After the mutation | the branch, within one second | no PR yet |
| After a push, and after a **force**-push | the branch | no PR yet |
| **After a PR is opened on the ref** | **empty** | **the issue** |
| After that PR is closed again | empty | the issue |
| After the ref is deleted | empty | the issue |

Opening a PR from a linked branch **promotes** the link — GitHub converts the branch record into
that PR's closing reference and drops it from `linkedBranches`. Three properties, each tested:

1. **One-way.** Closing the PR does not restore the branch record.
2. **No keyword needed.** The probe PR's body was edited down to text containing no issue
   reference at all and `closingIssuesReferences` still read `[206]`. That is the discriminator
   between a promoted link and a parsed one.
3. **No timeline event at creation.** `createLinkedBranch` emits none, and neither does deleting
   the ref. The single `ConnectedEvent` fires at promotion.

**And the promoted link cannot be told from a parsed one once the keyword is there.**
`closedByPullRequestsReferences` is fed by a `Closes #NN` in the body as well as by promotion, and
every arc PR is required to carry that line. Measured on #17, whose branch was made with
`git checkout -b` and which still reads as linked, through PR #139's keyword. Three readings, not
two:

| What the read finds | What it proves |
|---|---|
| The branch in `issue.linkedBranches` | The mutation formed the link. **Decisive** |
| A closing PR on that branch, **no** keyword in its body | Only the branch could have put it there. **Decisive** |
| A closing PR on that branch, **with** a keyword | Only that the PR closes the issue |

**So the read-back after the mutation is the load-bearing one**, and the same check at pass 4
verifies the closure binding instead. The tool prints which of the three it found rather than
collapsing them into one `PASS`.

**The lifecycle then reproduced on this issue's own branch.** Before PR #223 existed the check
read `PASS branch link`. After it opened, the same command reads
`PASS PR link — PR #223 … cannot be told apart`, because this PR body carries `Closes #206` like
every arc PR. The tool predicted its own reading and got it.

**So #155's read was correct and its conclusion was not.** Its pass 4 ran after PR #205 existed
(PR opened 06:55:14Z, the finding committed 06:58:59Z, the branch not deleted until 07:11:49Z), so
the link had already moved. Its second inference — *"the only `connected` event is timestamped
with PR #205's cross-reference, so it is the PR link, not the branch link"* — is backwards: that
`ConnectedEvent` **is** the promoted branch link, and a branch link never has one of its own.
Running the new verifier against #155 today reports `PASS PR link — PR #205 … cannot be told apart` — PR #205's body carries `Closes #155`, so the tracker can no longer say whether that branch was ever linked. The link was not lost; it is no longer provable.

## Decisions & trade-offs

| | |
|---|---|
| **Check both fields, not one** | The whole defect is that either field alone is right at one moment and wrong at the other. `verify-linked-branch.sh` reads `issue.linkedBranches` and, failing that, the closing PRs, and **names which one holds the link** so the caller can tell a fresh link from a promoted one |
| **Three verdicts, not two** | Pass 2 found the first version calling every closing reference a *promoted link*, so a `git checkout -b` branch passed at pass 4 — the check passing for exactly the branch the arc forbids. The keyword column separates them, and where it cannot, the message says so instead of claiming more than the read supports |
| **A pure `classify` over two lists** | The bug class is *which field was consulted*, so that decision is a function of two lists and nothing else. The selftest exercises it with no network and no repository; live mode only supplies the lists |
| **Every read is checked, and a failed read exits 2** | Pass 1 caught the first draft returning empty on a failed `gh` call. At pass 4 `linkedBranches` is legitimately empty, so an unchecked second read that also comes back empty produces `FAIL no link` — **#155's false negative reproduced inside the tool built to prevent it, with an exit code attached.** "Missing" and "could not tell" are now different exits |
| **`x="$(gh_read …)" \|\| exit $?`, not a bare assignment** | The first fix for the row above was **inert**. `exit 2` inside a command substitution kills only the subshell; the caller carries on with an empty string. Measured in a scratch script before trusting it, then end to end: issue `999999` now exits 2 with the GraphQL error, where the bare form printed `FAIL no link` |
| **`closedByPullRequestsReferences` on the issue, not a `gh pr list` sweep** | A sweep needs a `--limit`, and this repo is already past PR #219. Any link promoted to a PR outside that window would read as absent — the same false negative in a new place. Asked of the issue, there is no horizon |
| **The repair note is gated on what heads the ref** | It used to say *delete the ref and re-run* unconditionally. Combined with the unchecked read above, a network blip at pass 4 would have told an unattended run to delete the branch its own PR stood on. **The note is conservative because the outcome is unmeasured** — §7 records the tested neighbour, that *renaming* the branch of an open PR closes it; deletion was not measured here, and the advice is written as though it does |
| **Wired into `verify-all.sh`** | Not optional. That script fails on any `tools/verify-*.sh` it does not know, which is what forced the wiring — and is the check working |
| **Cases inline, not in a fixtures directory** | Each case is two short lists. A file per case would be more scaffolding than case |
| **One PR number spent on a probe** | PR #219, opened from a throwaway branch, closed, its branch deleted. The promotion could not be established any other way, and writing m12 on an untested hypothesis was the alternative |

## Rejected approaches

| | |
|---|---|
| **Retry the mutation on a failed read** | It cannot link a branch that already exists, so the retry is guaranteed to fail. The script says so and offers **one** repair, chosen by whether an open PR heads the ref: delete and re-run when it is free, bind from the PR side when it is not, and the PR side when that read itself failed |
| **A timeline read as the check** | Tested and disproved above — `createLinkedBranch` emits no event, so a timeline read cannot see a branch link at all |
| **Re-counting the ROADZ survey in m12** | Different repo, not re-run here. Its conclusion is left standing and the recount marked unmeasured rather than asserted |

## Spawned

- **Residue, permanent:** closed probe PR [#219](https://github.com/Calyx-Engineering/arc/pull/219)
  still reads `closingIssuesReferences: [206]`. Promotion is one-way and survives closing, and no
  mutation detaches it, so **#206 carries a closing PR that closed nothing, for good.** The
  consequence is that `verify-linked-branch.sh 206` with no branch argument passes forever
  regardless of the real state. The script's header and m12 §4 both now say the one-argument form
  only asks whether an issue is linked to *nothing at all*.
- **The sweep, in full.** `grep -rn createLinkedBranch --include=*.md` finds six files. Four need
  nothing: m12 and this dev-log are the fix, `issue-155-skill-firing-shapes.md` is the report being
  answered, and m42 §44 only notes that no PR-side mutation exists. Two carried the bare mandate:

  | | |
  |---|---|
  | `run-instructions.md` §4 | Fixed — the read-back row |
  | `docs/arc-log/arc-04-dogfood.md` line 134 | Fixed — the same clause, since the arc's own decision record stating the mandate without it is the defect |
  | `docs/arc-work/04-dogfood/issue-plan.md` line 314 | **Left.** Out of what the issue named, and a run does not read the issue plan (§1). Whoever edits that file next
- **Finding, not filed as an issue:** the fourth `Required` box's premise is false —
  `tools/new-direct-pr.sh` does not use `createLinkedBranch`. It uses `git checkout -b`, which is
  correct there: a direct PR has no issue, so there is no `issueId` and no link to form. Recorded
  as a header comment in the script rather than an issue, because the confusion it causes is the
  arc's blanket *"never `git checkout -b`"* rule read out of context.

## Retrospective

**The reported bug did not exist; the gap it pointed at did.** The mutation works, the link forms,
and it lands where it should. What was missing was any read-back at all, so the arc could not tell
a working link from a broken one — and when a run finally looked, it read one field at the one
moment that field is empty and filed a defect against a healthy mechanism. m12 had the same blind
spot: it documented the read as working without saying what stops holding the answer.

**The cheap lesson is that a moving fact needs a check that knows it moves.** The expensive one is
that #155 reached a confident wrong conclusion from a correct observation, and nothing in the four
passes catches that — the observation was real, the reasoning was not, and pass 4 does not read
reasoning.

**Pass 1 then caught this run doing the same thing one layer down.** The first draft of the
verifier read the closing PRs without checking whether the read succeeded, so a `gh` failure at
pass 4 — the one moment `linkedBranches` is legitimately empty — would have printed `FAIL no
link` and told the run to delete a ref with an open PR on it. The tool built to stop #155's false
negative contained it.

**And the first fix for it was inert.** `exit 2` inside `$( )` ends the subshell, not the script,
so the guard printed its error and the caller continued with an empty string into the same wrong
verdict. Caught by testing the failure path rather than reading it — which is the issue's own
lesson applied one more time: a mutation reporting success is not evidence, and neither is a
guard that has never been made to fire.
