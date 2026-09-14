# Issue #148 — workstream: Upkeep — make drift fail loudly

> Dev-log, not a spec.

**Issue:** [#148](https://github.com/Calyx-Engineering/arc/issues/148)  ·  **PR:** the review PR on `arc/04-dogfood-issue-148-upkeep-review`

## Problem

Upkeep had no boundary report. Its twenty-two closed children landed over eight days, the loop's report dispatch has been broken since 2026-09-09 ([#310](https://github.com/Calyx-Engineering/arc/issues/310)), and the last two children's PRs merged after the user had said the workstream reports were to be finished by hand. The status table still read *In progress* with three PR numbers from 2026-09-08.

## Intent and north star

| | |
|---|---|
| **What this is for** | The user closes Upkeep in one read of §6.10 |
| **North star** | One report, in the reviewed shape, written from the twenty-two dev-logs and the issue bodies — not from memory of the runs |
| **Out of scope** | [#175](https://github.com/Calyx-Engineering/arc/issues/175) and [#320](https://github.com/Calyx-Engineering/arc/issues/320), which are the user's and still open; whether they roll is asked, not decided |

## Decisions & trade-offs

| | |
|---|---|
| Numbered §6.10, after Skills | §6.5 is Handoff's second closing on the tip until [#146](https://github.com/Calyx-Engineering/arc/issues/146)'s PR removes it; a second §6.5 on this branch would collide at the merge |
| Written by hand, from the record | Every Delivered line is a dev-log's Retrospective or an issue's ticked boxes. Nothing here was inferred from a transcript |
| The before/after rows | Gates 11 to 73 by `verify-all.sh`; `mode-guard` cases 0 to 36 by `git ls-tree v0.1.0`; the 35 stripped PRs are #204's own count |
| #285 and #310 detached | Rolled to arc 05, the user's call of 2026-09-13 |
| The budget commit cherry-picked from the Handoff branch | The gate has to be green on this PR alone |

## Retrospective

Twenty-two dev-logs, and every Retrospective section in them was readable in under a minute — the dev-log-per-unit rule paid for itself here, because the report could be written without opening a transcript.
