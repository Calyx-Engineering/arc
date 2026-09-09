# Issue #272 — branch-guard denies a write to a path in no repository

**Issue:** [#272](https://github.com/Calyx-Engineering/arc/issues/272)  ·  **PR:** pending

## Problem

A `Write` to a scratchpad `.py` under the session temp directory was denied from `arc/04-dogfood` with *"Source edit blocked: you are on a coordination branch"*. The file is in no repository at all, so the guard had no claim on it.

`hooks/branch-guard` runs three checks in order, and check 2 owned the answer to *which repository does this path land in*. It resolved the path, found no repository, and set `worktree-identity` to skip. Check 1 had already denied. The exemption existed and was unreachable.

## The fix — resolve before check 1, not inside check 2

The resolution moves to its own section above check 1, and a path that lands in **no worktree of any repository** takes an early exit: three `arc_log_skip` calls, `outcome: ok`, `exit 0`.

```
  checked: branch-kind=coord — all ok
  outcome: ok — the path is in no repository
  skipped: path-is-source (the path lands outside every git worktree) · worktree-identity (…) · base-freshness (…)
```

| Decisions | |
|---|---|
| **Exempt at one place, not check by check** | Each check exempting the path itself is what produced the bug — check 1 denied before check 2's exemption ran. One gate above all three cannot be outrun by ordering |
| **Base freshness is skipped too, deliberately** | It is a property of the session's *branch*, not the path, so it does have something to say. It is skipped anyway: #272's requirement is that the path is **allowed**, and a stale-base denial on a write the guard has no claim over is the same denial. Nothing is lost — the stamp is written only where the reminder is delivered, so the next in-repo edit on that branch still gets it |
| **Check 2 decides, it no longer resolves** | It reads `WT_ELSEWHERE`, `WT_SKIP`, `CWD_TOP`, `TGT_TOP`. Its deny is byte-identical, verified against `git show HEAD:hooks/branch-guard` on a real worktree pair |
| **`CWD_TOP="$TOP"`** | The hoist made the toplevel lookup unconditional. `$TOP` already holds it from the identical command, and a fork here is paid by every relative-path write — the common case, which reached none of this before |

Two skip reasons were wrong and are corrected. `worktree-identity` logged *"the path lands outside any repository"* for the mirrored-file edit into a **different** repository, which is emphatically inside one; it now says so. The `elif` restating the no-repository case in check 2 is removed — the early exit is the same condition, and a second answer to one question is the half that rots.

## Verification

| | |
|---|---|
| `tools/verify-hook.sh hooks/branch-guard` | 19 passed, 0 failed, exit 0 |
| `tools/verify-activation-log.sh hooks/branch-guard` | 69 passed, 0 failed, exit 0 |
| `tools/verify-all.sh` | see the PR body |

`tools/hook-cases/branch-guard/pass/coord-branch-outside-any-repository.json` is a real regression test, not a case that already passed: against `git show HEAD:hooks/branch-guard` it reads **18 passed, 1 failed**. It is the only case in the directory that flips.

It is not redundant with `pass/worktree-outside-any-repository.json`, whose cwd is an *issue* branch — check 1 never fires there, so it could not have caught this.

## Retrospective

**The case was written before the fix, and failed.** That is what proved the diagnosis rather than the patch.

**Review found the comment before it found a defect.** The first justification for skipping base freshness claimed all three checks are "about where work in a repository goes". True of two of them. The exemption is right; the reasoning written under it was not, and a wrong comment above a correct branch is what the next reader inherits.

**Spawned [#294](https://github.com/Calyx-Engineering/arc/issues/294).** An absolute path whose whole ancestor chain is absent resolves differently by root form — `/nonexistent/src/x.ts` walks up to `/`, which exists and is in no repository, so it is now allowed; `z:/nope/src/x.ts` walks up to nothing absolute and still reaches check 1, which denies it. Same class of path, opposite verdicts. Out of scope here: this issue is about a path that *is* resolvable and *is* outside every worktree.
