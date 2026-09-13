# PR #334 — fix: run-instructions — nothing in the background, nobody answers, the gate's real duration

> Dev-log, not a spec.

**Issue:** none  ·  **PR:** [#334](https://github.com/Calyx-Engineering/arc/pull/334)

## Problem

Three of four S12 runs on 2026-09-12 ended with their work uncommitted. Each had sent `tests/verify-all.sh` to the background after it outran the tool's ten-minute ceiling, then ended its turn to wait for a notification a `claude -p` session never receives. A fourth stopped to ask which of two options to take and got no answer. §3 already forbade background *sub-agents*; the runs read that literally and backgrounded a Bash task instead.

The suite itself passes — every run's log ends `67–68 gates, all clean` — but it takes ten to twenty-five minutes with four runs sharing one machine, and three of four runs also omitted `LANG=en_US.UTF-8`.

## Intent and north star

A run ends only when its PR is merged or it has a reason it cannot be. §3 now says: nothing in the background, of any kind; nobody answers a question, so decide and record the assumption; and the gate's real duration, so a run waits rather than backgrounds.

## Decisions & trade-offs

| | |
|---|---|
| Wording only | The suite's speed is the real fix — arc 05 Upkeep. Tonight's runs need the rule at the arc tip, which is why this is a direct PR rather than waiting for Fire's review branch to merge |
| The same hunk is on `arc/04-dogfood-issue-145-fire-review` at `2be458b` | Union at that PR's merge; identical text |

## Retrospective

Soak: S13 onward. The measure is whether a run ends with an unmerged PR and a backgrounded gate.
