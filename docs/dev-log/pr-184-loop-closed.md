# PR #184 — Loop closed

**Issue:** none  ·  **PR:** [#184](https://github.com/Calyx-Engineering/arc/pull/184)

## Problem

Loop's boundary report was written at three of four, with [#149](https://github.com/Calyx-Engineering/arc/issues/149) recorded as blocked on an account entitlement and blocking 18 issues. The rescope removed that, and the workstream closed.

## Decisions

| | |
|---|---|
| **The report is edited, not appended** | It is a boundary report, not a log. The block says what the workstream did, once it is done |
| **The blocked framing is replaced, not deleted** | `plugin eval` is still gated and still wanted — it moved to [#181](https://github.com/Calyx-Engineering/arc/issues/181), out of the milestone, and the report says nothing waits on it |

## Retrospective

**The blocker was a symptom of a design error, and three exchanges went into the wrong question.** How to get `plugin eval` enabled was asked and answered before *what is the real issue here*. The real issue was that 18 issues were built on an instrument nobody had run — the arc-log had flagged it as untested in writing.
