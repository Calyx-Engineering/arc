# Issue #141 — the miner scans repositories it was not given

**Issue:** [#141](https://github.com/Calyx-Engineering/arc/issues/141)  ·  **PR:** pending

## Problem

`agents/transcript-miner` said *"glob across every matching raw directory, never one"*, because worktrees get their own slug and a deleted worktree leaves an orphaned directory a scoped search misses silently — 45 MB of the richest material, once. Matching on a shared prefix then pulled in a sibling repository: briefed on `roadz-sound-system`, the first real run also read `R--work-lantern-roadz-pb-firmware`, a different product.

## The fix is a script, not a rule

The scope rule is exact, so it should not be a judgement the agent re-derives each run.

```sh
tools/miner-scope.sh <briefed-slug> [<briefed-slug>...]
```

A directory is **IN** when, case-insensitively, its slug equals a briefed slug or begins with a briefed slug followed by `--` — the worktree form. **A shared stem is not enough:** `roadz-sound-system` is not a prefix of `roadz-pb-firmware` under that rule, because the separator has to be there.

| Decisions | |
|---|---|
| **Three outcomes, not two** | `NEAR` is separate from `SKIP`. A directory sharing ten or more leading characters with a briefed slug is the case a reader has to actually consider; `r--lodestar` is not. Reporting both as "skipped" would bury the one that matters |
| **Ten characters** | The slug is `<drive>--<path>`, so a few characters are the drive and mean nothing. The #141 pair shared 22 |
| **A briefed slug matching nothing exits 1** | That is a wrong brief, not an empty result, and it must never read as an absence of friction |
| **Every present directory is on exactly one line** | Silence about a directory is indistinguishable from the directory not existing |
| **Cross-repository mining stays available** | Brief more than one slug. It stops being an accident of globbing, which is m30's open question rather than this issue's |

## What the packet must now say

*Not covered* names **every** NEAR directory, whether or not the run thought it mattered. Without that, a reader cannot tell a correct scope from a lucky one.

## Verification

`tools/miner-scope.sh selftest` — 9 cases against a throwaway fixture tree, the same precedent as `verify-tracker-body.sh selftest`. It covers the worktree-with-different-case case, the #141 sibling, an unrelated repository, two briefed slugs, and all three exit codes. Wired into `tests/verify-all.sh`.

## Retrospective

**The narrowing did not reintroduce the failure it was written to prevent.** The worktree case is asserted directly — a fixture directory whose slug differs in case from the brief is still IN.

**Written before the fix.** The script and its cases came first; the agent was edited to call it afterwards. The cases are the spec.
