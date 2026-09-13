# PR #344 — docs: Tracker's second boundary report

> Dev-log, not a spec.

**Issue:** none  ·  **PR:** [#344](https://github.com/Calyx-Engineering/arc/pull/344)

## Problem

Tracker ([#147](https://github.com/Calyx-Engineering/arc/issues/147)) closed a second time on 2026-09-13 when #336 merged. The loop's report dispatch is broken until [#310](https://github.com/Calyx-Engineering/arc/issues/310) is fixed, so the orchestrator ran it by hand: the loop's prompt, `claude -p` on Sonnet, from a worktree on `arc/04-dogfood`.

## Intent and north star

The report is a comment on #147 and arc-log §6.8. This PR carries the section; it covers only what §6.6 left open — #226, #234, #286, #287, #336.

## Decisions & trade-offs

| | |
|---|---|
| Run on Sonnet, 29 turns, $0.86 | A 200-word summary of closed issues |
| Mode row left Autonomous | The run asked whether to drop it at this boundary and correctly did not: the grant is *until the playlist completes*, and S14 was live under it |

## Retrospective

Two *Not done* items are recorded here and not filed: #286's numbered-merge case still misreports `merge-close`; `issue-write` carries two stale *closure defers to the arc PR* sentences. Both are arc 05's — the second under #277.
