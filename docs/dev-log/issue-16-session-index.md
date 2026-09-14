# Issue #16 — index transcript locations at worktree creation

**Issue:** [#16](https://github.com/Calyx-Engineering/arc/issues/16)  ·  **PR:** [#250](https://github.com/Calyx-Engineering/arc/pull/250)

## Problem

Transcripts survive worktree deletion. What dies is the ability to find them. Claude Code stores a
session under `~/.claude/projects/<path-slug>/`, and the slug comes from the working directory —
so a worktree gets its own directory, and deleting the worktree leaves that directory named after a
path that no longer exists, tied to no issue, branch or arc.

**Measured here, 2026-09-08, before anything was built:**

| | |
|---|---|
| Live worktrees under `R:/arc-wt` | **5** |
| Transcript directories for them | **22** |
| Orphaned | **17** |

m32 recorded 2 orphans in ROADZ. This repository has seventeen. `tools/arc-loop.sh` names its
worktrees after the issue, so the number happens to be recoverable here from the directory name
alone — ROADZ's are not named that way, and there an orphan is a bare path.

## Intent and north star

| | |
|---|---|
| **What this issue is really for** | The producer half of a two-part mechanism. `agents/transcript-miner` already globbed and already knew it was globbing blind; requirement 5 was moved here from #17 because a consumer cannot meet a requirement its producer has not shipped |
| **North star** | A transcript directory whose worktree is gone can still be named, with its branch, its issue and its arc, by reading a committed file |
| **What makes it durable** | The mapping is committed and the transcripts are not; the entry is written while the context is live, because at deletion the branch and issue are already gone |
| **Out of scope** | **Backfilling the seventeen** — the issue names it as a constraint, and a backfilled row can only carry a path, since the branch and issue died with the worktree. It would add rows that look indexed and are not. **Knowledge mining** (m32 §3) — a distinct mechanism, m19's trigger over m30's pipeline, and it is why m32's status says *built* about §1 and §2 only. **A `SessionStart` hook** — CLAUDE.md bars writing one autonomously |

## Decisions & trade-offs

**The unit is a working directory and a branch, not a session.** One transcript directory holds
every session ever run there, so a row per session would be a row per firing. The branch is in the
key because of m32's measured ROADZ case: #39 was worked on a branch *in the main repo*, and its
eighteen transcripts piled into one shared directory spanning every branch ever checked out there.
The branch column is the only per-issue boundary such a directory can be given.

**The slug comes from the payload, not from a rule.** `transcript_path` names the `.jsonl` Claude
Code is writing, so its parent directory *is* the answer. The derivation — every character that is
not `[A-Za-z0-9]` becomes a hyphen — is the fallback, measured off the real store. Even then the
store's own spelling wins: this machine holds `r--arc` and `R--arc-wt-16` side by side, because an
older Claude Code lowercased. The store is *listed* rather than probed with `[ -d ]`, because
Windows `/tmp` is case-insensitive and a probe reports the computed spelling confirmed when no
directory of that name exists.

**The orphan sweep is scoped to this machine, and that is a correctness fix rather than a nicety.**
The index is committed and the transcripts are not, so a second machine pulling this file sees
worktree paths that never existed on it. A row is marked `orphaned` only when its worktree is absent
**and** its transcript directory is present here — the transcript directory is what proves this
machine ran that session. Without that second half, one machine declares the other's live worktrees
dead. m32 listed cross-machine as an open question; this is the smallest answer that does not
corrupt the record.

**A PreToolUse proxy for a cold start**, the shape `handoff-archive` and `camp-session-start`
already use, because CLAUDE.md bars a `SessionStart` hook from being written autonomously. It costs
the one session that starts, reads and exits without a single tool call — whose transcript is a
directory listing with nothing in it.

**Registered on `Bash` as well as the edit tools.** Every `claude -p` run in this arc reaches for
Bash long before it edits anything, and a session interrupted before its first edit would otherwise
leave no row at all. The tax is real and measured below.

**Cost, re-measured after the review passes added a lock and a second read** — 20 iterations warm,
10 cold, this machine, 2026-09-08:

| | |
|---|---|
| `bash -c 'exit 0'` | 39 ms |
| `hooks/mode-guard` | 97 ms |
| `hooks/handoff-archive` | 175 ms |
| **`hooks/session-index`, warm** | **109 ms** — every call after the first |
| `hooks/session-index`, warm, no `CLAUDE_PROJECT_DIR` | 167 ms — the git fork the fast path avoids |
| **`hooks/session-index`, cold** | **303 ms** — once per session, and it does the whole rewrite |

The first version of that table in the hook's header was stale within the hour, because it was
written before the lock and the pre-scan existed. It is re-measured, not adjusted.

## Rejected approaches

| | |
|---|---|
| **Copying transcripts** | m32's first constraint. Gigabytes, drift, and client material entering a repository |
| **Appending only, like the event log** | m44's log never reads itself before writing, which is what makes it cheap. #16 requires an existing row's status to change when its worktree goes, and that is a rewrite by definition. Affordable because it happens once per session over a table with one row per working directory |
| **A worktree-removal trigger** | m32 already measured this wrong: work done on a branch *in the main repo* never fires one, and that was ROADZ's #39 |
| **`git add` from the hook** | Staging files surprises every `git commit -a` in the repository, and `hooks/mode-guard` governs what a session may commit. `skills/handoff`'s setup step names the file instead, and the gate fails if it exists untracked |
| **A `.gitignore` entry for the index** | The inverse of everything else under `.claude/` and `.arc-work/`, and the reason the gate asserts *both* directions: the index tracked, the markers ignored |

## What the review passes found

Recorded because three of the four found something the run had not, and one of them was a defect
that would have disabled the mechanism silently.

| Pass | Found |
|---|---|
| **1** | The index is created *untracked* and nothing adds it, so requirement 3 was met in form only. The artifact table's `Needs` cell had been filled with a circular dependency. `[ -s "$TMP" ]` did not detect the truncation its own comment claimed to prevent. A header-stripped index stayed headerless |
| **2** | **The row-count guard pass 1 added counted only the rows the rewrite touched**, while the count it compared against covered every row the file held. Any index carrying a row for another live worktree looked like a loss, the write was blocked, and — since the next session read the same unchanged file — the mechanism would have stopped permanently and said nothing. It survived a full green selftest because every fixture had one row. Also: the pre-scan read the same file the guard was protecting against, so an unreadable index defeated it; the header repair duplicated the title; `rmdir` ran whether or not the lock was owned |
| **3** | Three assertions that would pass with the code they named deleted — the once-per-session case, the lock case, and the edit-matcher registration check. Two cells asserted for non-emptiness rather than value, one of them the worktree path the whole sweep keys on |
| **4** | The lock and the temporary file were named off `$INDEX`, which put both in `.claude/arc/` — a **tracked** directory. A crashed session would leave `sessions.md.lock` or `sessions.md.4711` sitting next to the record, where the first `git add .` sweeps them in. Both moved to the gitignored `.arc-work/session-index/`, with a gate assertion on the source, because the obvious spelling is the wrong one |

**Pass 2's finding is the one worth carrying forward.** A guard added to prevent data loss became
the thing that stopped the mechanism, and every existing test stayed green because they all
exercised a one-row file. The regression case for it was itself vacuous on the first attempt —
asserting the row count was unchanged, which a *blocked* write satisfies exactly as well as a
correct one — and was only made real by firing from a new branch so a correct rewrite must add a
row. It was then checked by reverting the fix and confirming the case fails.

## Not covered, named rather than implied

- **Mutual exclusion is not tested.** The hook takes a `mkdir` lock around read-rewrite-move.
  Exclusion is a property of two processes interleaving and nothing here can make that happen on
  demand; a case that fired two hooks and hoped would be flaky, which is worse than an absent one.
  Case 18 asserts the cleanup contract only and says so at the case.
- **The unreadable-index guard has no executed coverage on this machine.** Case 16b drives it with
  `chmod 000`, which does nothing on Windows; the case reports `SKIP` rather than a green it has
  not earned.
- **No hook fires in a live session here.** `tests/verify-all.sh --list` already says so. The
  installed plugin copy is stale until `tools/plugin-reload.sh` runs, and that reload would swap
  the plugin under the other five worktrees running concurrently, so it was not run. The soak below
  is the hook executed as a program against this repository.
- **`verify-hook.sh`'s kill-switch-suppression check does not run for this hook**, because that
  block only fires for a hook shipping `deny/` or `report/` cases and this one speaks on no path.
  The real coverage is `verify-session-index.sh` case 9, which points `HOME` at a fixture holding
  `HOOKS_OFF` and then asserts the index was never written — the switch reaching the *side effect*
  rather than a message.

## Soak

`hooks/session-index` was run as a program against this worktree, with this session's real
`session_id` and `transcript_path`, and wrote the first real row:

```text
| `R--arc-wt-16` | `R:/arc-wt/16` | `arc/04-dogfood-issue-16-session-index` | #16 | `arc/04-dogfood` | 2026-09-08 to 2026-09-08 | live |
```

`.claude/arc/log.md` carries the matching m44 entry — `session-indexed`, `index-entry=R--arc-wt-16`,
`orphan-sweep=none`, `outcome: ok`. Re-firing is idempotent: still one row.

## Spawned

- **Issues:** none filed. Two observations that belong to the arc rather than to this unit:
  - `.claude/arc/log.md` accumulates every firing of every hook in a session — 2,828 lines in this
    one — and no run in this arc has ever committed that growth. m44's record is therefore lost
    with each worktree. Following the established practice here rather than changing it in a PR
    about something else.
  - #16's own title carries a clause after the deliverable, which `hooks/tracker-verify` reports on
    every label edit. Left alone: renaming an issue mid-run is not this unit's job.

## Retrospective

Built the producer half of m32 and wired the consumer to it. `hooks/session-index` writes
`.claude/arc/sessions.md` — one row per working directory and branch, seven fields, written at a
session's first tool call and flipped to `orphaned` by a later firing from elsewhere once the
worktree is gone. `agents/transcript-miner` §1 now opens with the index and carries four routing
rules over its rows, requires quotes from an indexed directory to be located by issue and branch
rather than by slug, and must say in its `Scope` row how many rows resolved or that it fell back to
globbing. `tests/verify-session-index.sh` is the gate — 28 cases against real repositories, plus
twelve live checks including that the index is *tracked* and that the hook's column names match the
template's character for character.

What a future reader needs: the guard on the rewrite is load-bearing and subtle. It must count
**every** row the rewrite emits, not only the ones it changed, and it cannot rely on a pre-scan of
the file it is protecting. Both of those were wrong at some point in this issue, and neither was
caught by a test until the tests were rewritten to fail without the fix.

- [m32](../product-architecture/mechanisms/m32-session-preservation.md) — the spec, now *built* for §1 and §2
- [templates/session-index.md](../../templates/session-index.md) — the format authority
