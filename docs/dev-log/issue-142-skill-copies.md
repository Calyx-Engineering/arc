# Issue #142 — delete the local skill copies

**Issue:** [#142](https://github.com/Calyx-Engineering/arc/issues/142)  ·  **PR:** pending

## Problem

`.claude/skills/` held a copy of all 13 shipping skills. Arc is installed in this repository, so both trees loaded and every skill appeared twice with identical descriptions — selection matching against two identical candidates. It is [#138](https://github.com/Calyx-Engineering/arc/issues/138)'s duplication defect at thirteen times the scale.

## The blocking constraint did not apply

The issue was marked blocked on the reload loop, because deleting the copies would leave the repository's skills served by a released snapshot with no way to exercise an unreleased edit.

**The marketplace is a directory install pointing at `R:\arc` itself** — `known_marketplaces.json`: `{"source": "directory", "path": "R:\arc"}`. `tools/plugin-reload.sh` copies from the working tree, not from a release. Verified before deleting: the cache carried `work-watch`'s old *Never commit unasked* row, a reload replaced it, and the row was gone from the cache.

## Decisions and trade-offs

| | |
|---|---|
| **The registry check outlived the sync** | `sync-local-skills.sh` did two jobs. The second — fail when a shipping skill has no row in the artifact table with a mechanism number — is now `tools/verify-skill-registry.sh` |
| **The new verifier also fails on a reappearing copy** | The deletion is a state to hold, not an event. A copy that comes back reintroduces the defect silently |
| **`verify-sync-parity.sh` went with the sync** | Nine fixture cases for a script that no longer exists |
| **Commands were left** | `.claude/commands/` shadows `commands/` the same way. #142's scope named skills; [#177](https://github.com/Calyx-Engineering/arc/issues/177) does the commands |

## What the gates caught

**A template link.** `templates/camp/operating-agreement.md` pointed at `../../skills/record-route/SKILL.md`, which resolved into `.claude/skills/` from where the template lands. Deleting the copies made it dead, and `verify-template-links.sh` failed on it. Now an absolute URL.

## Retrospective

**Two coverage claims in `verify-all.sh --list` were false and had been for two weeks.** It said hooks cannot fire in a live session and that nothing here invokes a skill. Arc is installed: `camp-branch-check` and `tracker-verify` were both observed firing, and skills load from the plugin. Corrected — and the correction records the real limitation, which is that a live firing uses the *installed* copy and the standalone cases run the working tree.

**Writing the verifier first worked exactly as intended.** `verify-skill-registry.sh` was written before the deletion and failed on the 13 shadowing copies, which is the spec of the change stated as a test rather than a claim.

Gates: 8, all clean — two replaced by one.
