# PR #311 — Handoff's second boundary report

**Issue:** none  ·  **PR:** [#311](https://github.com/Calyx-Engineering/arc/pull/311)  ·  **Workstream:** [#146](https://github.com/Calyx-Engineering/arc/issues/146) — Handoff

## Problem

Handoff's boundary report, §6.4 of the arc-log, was written on 2026-09-08 over six children. Four
more — [#252](https://github.com/Calyx-Engineering/arc/issues/252),
[#253](https://github.com/Calyx-Engineering/arc/issues/253),
[#267](https://github.com/Calyx-Engineering/arc/issues/267) and
[#268](https://github.com/Calyx-Engineering/arc/issues/268) — were attached afterwards and closed
on 2026-09-09, and the record of that second stretch was in three PRs and four dev-logs with no
report over them. The status table's Handoff row said *10 of 10 closed* and *two open* in the
same cell.

## Intent and north star

| | |
|---|---|
| **What this unit is for** | Run-instructions §6: a report run over the reopened workstream, reading the four bodies, three merged PRs and four dev-logs and nothing else |
| **North star** | A reader of the arc-log can tell what the second stretch delivered and left undone, by section number |
| **Out of scope** | Any change to the code the four issues touched — a report run does no work, §6 |

## Decisions & trade-offs

**A second report as §6.5, not an addendum to §6.4.** Four issues with their own PRs and dev-logs
are a stretch, and a stretch gets the seven sections. Fire's reopening got a paragraph under §6.3
because nothing had closed yet; here everything has.

**The heading is `### 6.5 Handoff, reopened — boundary report`.** `verify-report-budget.sh`
finds a report by a heading ending `— boundary report`, so the qualifier goes before the dash.
Its slug, `#65-handoff-reopened--boundary-report`, is what the status row links.

**The status row now names both reports** and drops the sentence that contradicted itself.

**`#308` is the one Spawned row.** Filed by #268's run, closed as a duplicate of Fire's #305 —
routed to Fire, which is the half the report's Spawned table exists to carry.

**The mode row was left alone.** §6.1 step 5 says confirm rather than write when dispatched by
`arc-loop.sh`. The row in this tree says autonomous *until the playlist completes*, and
`run_report` leaves a row it found autonomous as it found it. Tracker's report run is next on the
playlist, so the grant is not spent at this boundary.

## Retrospective

**First draft 245 words, shipped at 198.** The script's count, not a hand count.

**Two commands hung on stdin.** `verify-all.sh` sat for ten minutes with no output because a
gate read from an open stdin; a stray `cat > /dev/null` did the same. Every later command carried
`</dev/null`. Worth a line in `verify-all.sh`'s header if it recurs.

**`markdownlint` reports MD060 on every compact table in the arc-log** — 74 in the committed file
before this change. Not this unit's, and the delimiter style matches the file's.
