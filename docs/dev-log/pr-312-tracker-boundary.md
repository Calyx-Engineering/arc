# PR #312 — Tracker's boundary report

**Issue:** none  ·  **PR:** [#312](https://github.com/Calyx-Engineering/arc/pull/312)  ·  **Workstream:** [#147](https://github.com/Calyx-Engineering/arc/issues/147) — Tracker

## Problem

Tracker's twelve children closed between 2026-09-07 and 2026-09-09 across eight merged PRs and
twelve dev-logs, with no report over them. The status table's Tracker row still said *7 issues,
in progress* and named [#274](https://github.com/Calyx-Engineering/arc/issues/274) as the last
open child.

## Intent and north star

| | |
|---|---|
| **What this unit is for** | Run-instructions §6: a report run over #147, reading the twelve bodies, eight merged PRs and twelve dev-logs and nothing else |
| **North star** | A reader of the arc-log can tell what Tracker delivered, spawned and left undone, by section number |
| **Out of scope** | Any change to the code the twelve issues touched — a report run does no work, §6 |

## Decisions & trade-offs

**The record was read by a sub-agent.** Thirty thousand words across thirty-two files, collapsed
to a digest of eight headings — §3's permitted use. Its sharpest claims were checked against the
files by hand before they went into the report: #84's unticked box, #135's two boxes ticked on a
reading, PR #302's *not a green claim*, the 47-of-102 sweep, and every `Spawned` row's routing
read live from the tracker.

**Routing is *Dogfood, unattached* for five of the spawned issues.** #226, #234, #242, #286 and
#287 are open in the milestone with no parent and no workstream. That is the half a reader needs,
and the tracker is the source.

**#305 is not in Spawned.** Its body says spawned by #273, which is Fire's. #274's run hit it and
took the fix by merging the base twice; that is §6.6.4's row, not a Spawned one.

**The status row lists the five open spawned issues** so the table says where the loose ends are
without opening the report.

**The mode row was left alone.** §6.1 step 5 says confirm rather than write when dispatched by
`arc-loop.sh`. The row in this tree says autonomous *until the playlist completes*, and this
boundary is not that one — the same reading PR #311's run made.

## Retrospective

**First draft 282 words, shipped at 200.** The script's count. The hand count in the header was
corrected to match it after the first run said 199.

**`verify-all.sh` ran past the tool's ten-minute limit twice.** The first run was piped through
`tail`, so nothing was visible and it was killed unread. The second wrote to a file and finished:
58 gates, exit 0, in about twenty minutes. Most of that was one gate — `activation log`, which
runs every hook against every case with a fresh log — and it was working, not blocked. PR #311's
run recorded the same symptom and blamed stdin; `</dev/null` was passed here and made no
difference. A ten-minute ceiling on a twenty-minute gate is a finding about the tool's timeout,
not the gate.
