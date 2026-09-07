# PR #186 — the boundary report, inside its budget

**Issue:** none  ·  **PR:** [#186](https://github.com/Calyx-Engineering/arc/pull/186)

## Problem

Two failures at the Loop boundary, both caught by the user rather than by anything here.

**The workstream parent was closed.** [#144](https://github.com/Calyx-Engineering/arc/issues/144) was closed as soon as its four children closed. That is mechanical completion, not review — and the parent *is* the checkpoint. Closing it removed the surface the report is read on and buried the report in a closed issue. Reopened.

**The report was 302 words against a 200-word budget.** `run-instructions.md` §6 states the budget and nothing checks it. It is now 184.

## Decisions

| | |
|---|---|
| **A workstream parent closes when the user says so** | Not when its children do. The boundary is a review, and a review needs something open to happen on |
| **The budget needs a check** | Two documents state 200 words and neither is enforced. [#185](https://github.com/Calyx-Engineering/arc/issues/185) |

## Retrospective

**Both failures are the same shape as the arc's own subject:** a rule that exists, is written down in two places, was loaded, and did not fire. The budget is in `run-instructions.md` §6 and arc-log §3.3; the report was written without either being consulted.
