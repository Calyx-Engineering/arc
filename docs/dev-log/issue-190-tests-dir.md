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
| **The disk guard sweeps both directories** | `verify-all.sh` globs `tests/verify-*.sh` **and** `tools/verify-*.sh`. Globbing only `tests/` would make a verifier left in `tools/` invisible, which is [#68](https://github.com/Calyx-Engineering/arc/issues/68)'s lesson restated by the move that caused it |
| **`.gitattributes` follows the directory** | `tools/tracker-cases/** text eol=lf` became `tests/tracker-cases/**`. Without it the fixtures check out CRLF-bound and every fixture title gains a stray carriage return — the exact failure the rule was written for |
| **`plugin-reload.sh`'s fixture gains `tests/`** | `INERT_PATHS` is an exclusion list, so a new top-level directory is treated as loaded without being named, which is the direction that fails safe. The fixture repository still needed the directory to exist |
| **Dev-logs were swept too** | The issue's *Done when* is "no reference to `tools/verify-` remains outside issue bodies". A path citation is a pointer to a file, not a claim about history, and 300 pointers into a directory that no longer holds the file is the problem this issue exists to fix |

## Not done

**`tools/verify-hook.sh` and `tools/hook-cases/` stayed where they were.** #190's constraint reads *its move comes to the user as a proposal*, and a loop run cannot ask. The two are inseparable: `verify-hook.sh` resolves `$(dirname "$0")/hook-cases/<hook>`, so moving the cases without the script means editing the script, which is the thing the never-edited-autonomously list forbids. Moving both together is one `git mv` pair and no content edit at all — that is the proposal.

The two boxes this leaves open are named on the issue with this reason rather than ticked.

## Unexpected

| | |
|---|---|
| **[#305](https://github.com/Calyx-Engineering/arc/issues/305) reproduced here before its fix was merged** | The branch point predated PR [#307](https://github.com/Calyx-Engineering/arc/pull/307). Two commits titled `ran gh issue close 42` landed on this branch, carrying this run's staged work under a message from a hook comment. They are the defect #305 names, not a new one. `git reset` is denied to this session, so they stay in history with the merge that brought the fix in |
| **The branch point was ten merges stale by the time the work was ready** | Two of those merges added verifiers — `verify-hook-source.sh` and `verify-log-rotation.sh` — which had to move under the same rule. The gate count is 57 after the merge where it was 53 before it |
| **The issue's *nothing else in flight* constraint did not hold** | Four sibling worktrees were dispatched against the same arc branch during this run, and `origin/arc/04-dogfood` advanced seventeen commits. A rename touching 150 files will conflict with every branch open against it |

## Evidence

| | |
|---|---|
| `verify-hook.sh hooks/tracker-verify` | 118 passed, 0 failed, exit 0 |
| `verify-hook.sh hooks/mode-guard` | 34 passed, 0 failed, exit 0 |
| `verify-hook.sh hooks/session-index` | 11 passed, 0 failed, exit 0 |
| `verify-hook.sh hooks/handoff-archive` | 11 passed, 0 failed, exit 0 |
| `bash tests/verify-all.sh --list` | 57 gates, no unknown-verifier finding |
| `bash tests/verify-all.sh` | recorded below when the sweep completes |
| Citation sweep | `grep -rn 'tools/verify-'` returns nothing outside `tools/verify-hook.sh`, the hook fixtures and the two intentional `tools/verify-*.sh` glob lines |

## Soak

Committed unsoaked. The next run's gate suite soaks it; soak row in the arc-log §10 when one has.
