# PR #180 — the Loop workstream's boundary report

**Issue:** none  ·  **PR:** [#180](https://github.com/Calyx-Engineering/arc/pull/180)

## Problem

Loop reached its boundary with three of four issues closed. The arc-log's status table still described the arc as it stood before any of it — *not started*, 23 issues unfiled, no workstream parents.

## Decisions

| | |
|---|---|
| **The blocker is reported at the boundary, not on its issue alone** | [#149](https://github.com/Calyx-Engineering/arc/issues/149) blocks 18 of the arc's issues. A comment on one issue is not where that gets read |
| **The merge result is stated as one observation** | It is the first unasked merge here, and a single success does not separate statement count from session context |

## Retrospective

**The branch number was predicted wrong and caught before the PR opened.** `gh api repos/…/issues` defaults to open only, so two merged PRs were not counted and the prediction came out two low. Renaming was safe because no PR existed yet — the rule that a rename closes an open PR did not apply. The correct query takes `?state=all`.

**`tools/new-direct-pr.sh` may carry the same defect** — it predicts the same way. Not checked in this unit.
