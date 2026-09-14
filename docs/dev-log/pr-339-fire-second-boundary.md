# PR #339 — docs: Fire's second boundary report

> Dev-log, not a spec.

**Issue:** none  ·  **PR:** [#339](https://github.com/Calyx-Engineering/arc/pull/339)

## Problem

Fire ([#145](https://github.com/Calyx-Engineering/arc/issues/145)) closed a second time on 2026-09-12 when #300 merged. Its report run cannot dispatch from the loop until [#310](https://github.com/Calyx-Engineering/arc/issues/310) is fixed, so the orchestrator ran it by hand — the loop's prompt, `claude -p` on Sonnet, from a worktree on `arc/04-dogfood`.

## Intent and north star

The report is a comment on #145 and a section in the arc-log, §6.7. This PR carries the section. Six children roll to arc 05 rather than close here; the report says so.

## Decisions & trade-offs

| | |
|---|---|
| Run on Sonnet, 59 turns, $2.25 | The report is a 200-word summary of closed issues; no judgement a Sonnet cannot make from the record |
| Mode row left Autonomous | The grant is *until the playlist completes*, not this workstream's close |

## Retrospective

Nothing to soak. The report run's dispatch is #310's, arc 05.
