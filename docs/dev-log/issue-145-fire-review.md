# Issue #145 — workstream: Fire — skills and hooks fire when they should

> Dev-log, not a spec.

**Issue:** [#145](https://github.com/Calyx-Engineering/arc/issues/145)  ·  **PR:** the review PR on `arc/04-dogfood-issue-145-fire-review`

## Problem

Fire closed twice — thirteen children on 2026-09-08, fifteen more on 2026-09-12 — and each closing wrote its own report, §6.3 and §6.7. The user's review of Handoff's report on 2026-09-13 set the shape a report takes: one per workstream, a goal line, a before/after table naming its instrument, end state only, every Spawned row an issue. Fire's two reports broke every one of those.

The branch also held five commits that never reached the arc tip: the playlist cut to fifteen sets, the arc 05 plan, the m10 decision on hook edits, four load-bearing rows in arc-log §4, and `hooks/TEMPLATE`'s activation-log boilerplate applied on the user's approval of 2026-09-08.

## Intent and north star

| | |
|---|---|
| **What this is for** | The user closes Fire in one read of §6.3 |
| **North star** | One §6.3 in the reviewed shape; §6.7 gone; the branch carries the tip, so its diff is the report and the five commits above |
| **Out of scope** | The children's work — nothing under `hooks/`, `skills/` or `tools/` changes here beyond the merge from the tip. `hooks/TEMPLATE`'s change is the one approved in chat on 2026-09-08, carried, not new |

## Decisions & trade-offs

| | |
|---|---|
| `git merge origin/arc/04-dogfood` first, 291 commits | Three conflicts: `sessions.md` (the hook's index, took the tip's), the status table (took the tip's, then rewrote Fire's row), and §10's soak table (a union — the tip's rows plus this branch's three) |
| Two of #266's findings had no issue | Filed as [#355](https://github.com/Calyx-Engineering/arc/issues/355) and [#356](https://github.com/Calyx-Engineering/arc/issues/356), Self-improvement, `Agent`; #266's rows now point at them. The third finding is in the grader, not work |
| The six rolled children detached from #145 | A rolled child still attached keeps the workstream open. `removeSubIssue`, 2026-09-13 |
| The budget commit cherry-picked from the Handoff branch | The reviewed shape does not fit 200 words; every review PR needs the 500-word gate green on its own |

## Retrospective

Fire's record was in five places — two reports, the playlist, the arc 05 plan, and #266's table — and the review reads one. What the rewrite cost was the before/after numbers: the hook-case counts had to be read from `v0.1.0` by `git ls-tree`, because no report had recorded a baseline for them.
