# Issue #146 — workstream: Handoff — intent survives a cold start

> Dev-log, not a spec.

**Issue:** [#146](https://github.com/Calyx-Engineering/arc/issues/146)  ·  **PR:** the review PR on `arc/04-dogfood-issue-146-handoff-review`

## Problem

Handoff closed three times — six children on 2026-09-09, four more by 2026-09-12, and [#349](https://github.com/Calyx-Engineering/arc/issues/349), [#351](https://github.com/Calyx-Engineering/arc/issues/351) and [#353](https://github.com/Calyx-Engineering/arc/issues/353) on 2026-09-13 — and its record was two report sections and a Spawned table with three *Unfiled* rows. The user reviewed §6.4 on 2026-09-13, about ninety minutes and eight corrections, and set the shape every report now takes. The friction-log entry on this branch records the review.

## Intent and north star

| | |
|---|---|
| **What this is for** | The user closes Handoff in one read of §6.4, and the rules his review produced outlive this branch |
| **North star** | One §6.4, reviewed by him; §6.5 gone; the ten rules in `run-instructions.md` §6.2; a report budget the reviewed shape fits |
| **Out of scope** | The other four workstreams' reports — each on its own linked branch, shaped to this one |

## Decisions & trade-offs

| | |
|---|---|
| **The report budget is 500 words, from 200** | The reviewed §6.4 is 480 words and failed the 200-word gate at the tip. The shape he set — goal line, before/after table with its instrument, seven sections — does not fit 200, and the gate cannot fail the pattern it is meant to enforce. 500 is the shape's ceiling. `tests/verify-report-budget.sh` says why in its header; the three documents that state the budget say 500; the selftest fixtures moved to the new boundary. Cherry-picked onto the other four review branches so each is green alone |
| The `-newer` staleness check excludes the writer's own live transcript | Found at this branch's own cold start: the writing session's file is always newer than its handoff. `skills/handoff`, one line |
| §6.4.2's two *running* rows | [#351](https://github.com/Calyx-Engineering/arc/issues/351) and [#353](https://github.com/Calyx-Engineering/arc/issues/353) ran in one Sonnet dispatch on 2026-09-13; the rows name their PR |
| [#352](https://github.com/Calyx-Engineering/arc/issues/352), [#354](https://github.com/Calyx-Engineering/arc/issues/354) rolled to arc 05 and detached | The user's call: out of time |

## Retrospective

The review cost more than the workstream's last three issues together, and every correction was a rule that already existed in a skill. What did not exist was a place a report is checked against them before a human reads it — that is now `run-instructions.md` §6.2's table, and the orchestrator's row-4 pass over the other four reports was the first use of it.
