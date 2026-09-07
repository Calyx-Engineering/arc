# PR #176 — the merge test's result

**Issue:** none  ·  **PR:** [#176](https://github.com/Calyx-Engineering/arc/pull/176)

## Problem

The arc-log's load-bearing decisions recorded *"a merge runs only on an explicit request"* as settled, on four denials. [#138](https://github.com/Calyx-Engineering/arc/issues/138) reduced the mode rule from five statements to one, and the next unasked merge ran.

## Decisions

| | |
|---|---|
| **Superseded, not deleted** | The row held for four denials and the reasoning behind it is what #138's evidence is measured against |
| **One observation, stated as one** | A single success does not separate statement count from session context. The row says so |

## Retrospective

The result arrived as a side effect of merging [PR #172](https://github.com/Calyx-Engineering/arc/pull/172) — the fix's own PR was the test case, because the user had not asked for that merge.
