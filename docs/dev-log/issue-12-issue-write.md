# Issue #12 — issue writing, and verifying the write landed

> Decision log, not a spec.

**Issue:** [#12](https://github.com/Calyx-Engineering/arc/issues/12)  ·  **PR:** [#22](https://github.com/Calyx-Engineering/arc/pull/22)

## Problem

Issue style re-taught 6+ times. Agreed edits silently not landing. Links failing to form
with nobody noticing until an issue looks orphaned. Writing and verifying are one loop, so
they ship together.

## Decisions & trade-offs

**`tracker-verify` is `PostToolUse`, not `PreToolUse`.** The write has already happened by
the time anything can be checked, so there is nothing to deny. It reads back and reports.
This is a different hook shape from the branch guard and forced a change to the harness.

**The closing-keyword check is conditioned on the base branch.** Empty
`closingIssuesReferences` is a defect on the default branch and *expected* on an arc branch.
Reporting it as a failure on every issue PR in an arc would be correct about the API and
wrong about the work — and a check that cries wolf gets turned off, which loses the case
where it matters.

**The hook accepts a body in its payload.** Otherwise the only way to exercise the scanners
is against a live tracker, and a hook whose test path needs the network is a hook nobody
runs the day it matters. Three of the six evaluation cases are now offline-runnable.

**Cases 1 and 2 are not this hook's.** They are writes that never started — nothing to read
back. They belong to `skills/issue-write` (capture at agreement time) and the handoff (hold
until a checkpoint). Building them into the hook would have meant inventing a signal for
"something was agreed", which does not exist.

## Rejected approaches

**Setting the repository default branch to the arc branch during an arc.** It would make
keywords bind, and it breaks in multi-user repos and changes behaviour for everyone
cloning. Verify-and-report replaces it.

**A `PreToolUse` hook that blocks a `gh` write with placeholders in it.** The body usually
arrives via `--body-file`, so the payload does not contain the text to scan. Blocking on a
filename is not possible, and reading the file at `PreToolUse` time races the write.

## Spawned

- **Arc work:** [closing keywords and the base branch](../arc-work/02-foundation/closing-keywords-and-base-branch.md) — written during #11, and this issue is what it changed

## Retrospective

Shipped `skills/issue-write` with `references/github.md`, and `hooks/tracker-verify`. Both
hooks pass: 13 and 13.

**The harness needed a second verdict vocabulary and that was not foreseen.** `verify-hook.sh`
assumed the PreToolUse deny shape. A hook now ships `deny/` cases or `report/` cases, never
both, so the case directories declare its shape rather than the script guessing. The branch
guard was re-run against the changed harness to confirm the added branch did not alter its
result.

**The base-branch finding from #11 changed this issue's scope before it was built.** That is
the record loop working end to end within one arc: a finding written to K2 during one issue
altered the design of the next. It is the first evidence in this repo that the ladder does
what it claims.
