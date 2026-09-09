# Issue #190 — the verifiers and their cases move into tests/

**Issue:** [#190](https://github.com/Calyx-Engineering/arc/issues/190)  ·  **PR:** predicted at branch time, confirmed on open

## Problem

`tools/` held two kinds of thing and only one of them was a tool. Twenty-four `verify-*.sh` scripts and two fixture directories sat beside `arc-loop.sh`, `plugin-reload.sh` and the scoring instruments, so a person looking for this repository's tests looked in the one directory named for something else.

## Intent and north star

| | |
|---|---|
| **What this issue is really for** | `tests/` is where the gates are, and `tools/` is where the things that act are |
| **North star** | `bash tests/verify-all.sh` runs the same gates, on the same cases, to the same result |
| **What makes it durable** | The disk guard sweeps both directories, so a verifier in either one is impossible to leave unwired |
| **Out of scope** | Any change to what a gate checks. A rename that also changes a check is two changes |

## What moved

| | |
|---|---|
| **To `tests/`** | 24 verifiers and `tracker-cases/` |
| **Stayed in `tools/`** | `verify-hook.sh` and `hook-cases/` — see *Not done* |
| **Stayed in `tools/`, correctly** | `arc-loop.sh`, `arc-claim.sh`, `plugin-reload.sh`, `new-direct-pr.sh`, `arc-default-branch.sh`, `arc-link-sweep.sh`, `miner-scope.sh`, `skill-firing.sh` and the scoring instruments. The issue's own table puts `skill-firing.sh` and `miner-scope.sh` under *Does work*, which draws the boundary at the `verify-` prefix rather than at "has a selftest" |

## Decisions

| | |
|---|---|
| **The boundary is the `verify-` prefix, not "has a selftest"** | Eight scripts in `tools/` carry a `selftest` subcommand and are wired into `verify-all.sh`. All eight also do work — `plugin-reload.sh` reloads, `arc-claim.sh` claims. The issue's table names two of them as tools, so the prefix is the line the issue drew and the line taken here |
| **`$(dirname "$0")/..` needed no edit** | Every verifier resolves the repository root one level up, and `tests/` sits at the same depth as `tools/`. `verify-tracker-body.sh` resolves `tracker-cases` as its sibling, so the pair moved together and the derivation is unchanged |
| **Two wrappers did need an edit** | `verify-case-reader.sh` and `verify-set-mode.sh` run `$HERE/<name>.py`, and those two `.py` files act rather than prove, so they stayed. Both now reach `$HERE/../tools/` |
| **The disk guard sweeps both directories** | `verify-all.sh` globs `tests/verify-*.sh` **and** `tools/verify-*.sh`. Globbing only the new one would make a verifier left behind invisible, which is [#68](https://github.com/Calyx-Engineering/arc/issues/68)'s lesson restated by the move that caused it |
| **`.gitattributes` follows the directory** | Its `tracker-cases` rule was rekeyed from the old directory to `tests/tracker-cases/** text eol=lf`. Without it the fixtures check out CRLF-bound and every fixture title gains a stray carriage return — the exact failure the rule was written for |
| **`plugin-reload.sh`'s fixture gains `tests/`** | `INERT_PATHS` is an exclusion list, so a new top-level directory is treated as loaded without being named, which is the direction that fails safe. The fixture repository still needed the directory to exist |
| **Dev-logs were swept too** | The issue's *Done when* is "no reference to the old `verify-` path remains outside issue bodies". A path citation is a pointer to a file, not a claim about history, and 300 pointers into a directory that no longer holds the file is the problem this issue exists to fix |
| **Except where the file never lived in `tests/`** | A blanket substitution over the record rewrote three claims about a **deleted** script, `tools/verify-sync-parity.sh` ([#142](https://github.com/Calyx-Engineering/arc/issues/142)), and two hypothetical paths — `tools/verify-plugin-reload.sh`, a rejected alternative, and `tools/verify-ghost.sh`, an evidence row's provoked failure. All five reverted. A pointer follows its file; a sentence about a file that was never there is a claim, and rewriting it makes the record wrong |

## Not done

**`tools/verify-hook.sh` and `tools/hook-cases/` stayed where they were.** #190's constraint reads *its move comes to the user as a proposal*, and a loop run cannot ask. The two are inseparable: `verify-hook.sh` resolves `$(dirname "$0")/hook-cases/<hook>`, so moving the cases without the script means editing the script, which is the thing the never-edited-autonomously list forbids. Moving both together is one `git mv` pair and no content edit at all — that is the proposal.

The two boxes this leaves open are named on the issue with this reason rather than ticked. **The issue's box 1 and its own second constraint cannot both be satisfied** — "both case directories" against "`verify-hook.sh`'s move comes to the user as a proposal" — and the tree follows the constraint.

**`tests/` has no README.** The old arrangement had the same gap, so it is not a regression, but the move was the moment to close it. Recorded on the issue as spawned rather than done here: a rename that also adds a document is two changes.

## Unexpected

| | |
|---|---|
| **[#305](https://github.com/Calyx-Engineering/arc/issues/305) reproduced here before its fix was merged** | The branch point predated PR [#307](https://github.com/Calyx-Engineering/arc/pull/307). Two commits titled `ran gh issue close 42` landed on this branch, carrying this run's staged work under a message from a hook comment. They are the defect #305 names, not a new one. `git reset` is denied to this session, so they stay in history with the merge that brought the fix in |
| **The branch point was nineteen merges stale by the time the work was ready** | Two of those merges added verifiers — `verify-hook-source.sh` and `verify-log-rotation.sh` — which had to move under the same rule. The gate count is 58 after two merges where it was 53 at the branch point, and the arc branch had to be merged in twice because it moved again while the review passes ran |
| **The issue's *nothing else in flight* constraint did not hold** | Four sibling worktrees were dispatched against the same arc branch during this run, and `origin/arc/04-dogfood` advanced seventeen commits. A rename touching 150 files will conflict with every branch open against it |
| **A string sweep cannot see a path built from a variable** | `tools/probe-handoff-checks.sh:120` reached its sibling as `bash "$HERE/verify-handoff-checks.sh"` — the old directory name appears nowhere in it, so the sweep passed over it and the first full sweep failed on that gate. It is the only such reach in the repository; `hooks/`, `tools/` and `tests/` were searched for `$HERE/verify-`, `$(dirname "$0")/verify-`, `$ROOT/verify-` and bare `../verify-` |
| **Excluding the hook fixtures from the sweep hid two citations** | `mode-guard/pass/manual-script-undeclared.json` named the runner at its old path. `hooks/mode-guard` does `[ -n "$SPATH" ] || continue` **before** it reads the `# mode-guard: writes-outward` declaration, so an unresolvable path made the case pass without ever reaching the read it was written for — green, and testing nothing. Repointed at `tests/verify-all.sh`, which restores exactly the pre-move behaviour rather than changing the check |
| **One gate is flaky inside a live session** | `activation log` failed the first sweep on *branch-guard wrote to the real `.claude/arc/log.md` with no session set*, 111178 bytes before and 112059 after. That is this session's own hooks appending while the gate measured the file, not anything this change did |
| **A blanket sweep crosses the line it was told to hold** | Four kinds of line matched `tools/verify-` and should not have moved: a verbatim hook entry in the append-only event log (`arc-03-camp.log.md:60011`), a measurement of what a reload left alone (`issue-158:121`), and two prose claims that group scripts *by their directory* rather than cite a path (`arc-03-camp.md:711`, `issue-48:95`). All four found by review, not by the sweep. A path is a pointer and follows its file; a measurement, a machine record and a claim about a directory are none of those |

## Evidence

| | |
|---|---|
| `verify-hook.sh hooks/tracker-verify` | 118 passed, 0 failed, exit 0 |
| `verify-hook.sh hooks/mode-guard` | 34 passed, 0 failed, exit 0 |
| `verify-hook.sh hooks/session-index` | 11 passed, 0 failed, exit 0 |
| `verify-hook.sh hooks/handoff-archive` | 11 passed, 0 failed, exit 0 |
| `bash tests/verify-all.sh --list` | 58 gates, no unknown-verifier finding. The gate NAMES diff identically against `origin/arc/04-dogfood:tools/verify-all.sh` — same 51 static gates, same 7 hooks |
| `bash tests/verify-all.sh`, first sweep | 57 gates then, 2 failed — both diagnosed above, both fixed |
| `bash tools/probe-handoff-checks.sh selftest` | 16 cases, 16 passed, 0 failed, after the sibling-path fix |
| `bash tests/verify-all.sh`, final sweep | **58 gates, all clean, exit 0**, on a clean tree with nothing else running |
| Citation sweep | a repository-wide grep for the old `verify-` path returns only `tools/verify-hook.sh`, the two `tools/verify-*.sh` glob lines the disk guard needs, and the five never-lived-in-`tests/` citations named under *Decisions* |
| Orphan-citation sweep | every `tests/verify-*.sh` string cited anywhere resolves to a file that exists — 24 names, 24 files |

## Soak

Committed unsoaked. The next run's gate suite soaks it; soak row in the arc-log §10 when one has.
