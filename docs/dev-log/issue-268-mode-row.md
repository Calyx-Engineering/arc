# Issue #268 — a staleness check on the handoff's mode row

**Issue:** [#268](https://github.com/Calyx-Engineering/arc/issues/268)  ·  **PR:** [#304](https://github.com/Calyx-Engineering/arc/pull/304)

## Problem

Two artifacts already said the read path catches a mode disagreement, and nothing did.
`skills/autonomy-set` — *the arc-log disagrees with it … the staleness checks in `handoff`'s read
path catch it* — and [m40 §3](../product-architecture/mechanisms/m40-autonomy-switch.md) — *when
they disagree the handoff is stale, and the staleness checks are what catch it*. The read path
had seven checks and none of them read the mode row, so the rule `autonomy-set` states — re-read
the row before a commit, a push — rested on nothing mechanical.

## Intent and north star

| | |
|---|---|
| **What this issue is really for** | Making a claim two documents already make come true. The gap is not that the mode is unchecked at the moment of a commit — `hooks/mode-guard` does that — but that a cold start acts on a handoff whose mode row nobody compared against the plan |
| **North star** | A cold start that finds a row saying autonomous where the arc-log grants no such thing stops and says so, before it executes an ordered action |
| **What makes it durable** | The check is in the skill's read-path slice, where `tools/verify-handoff-checks.sh` asserts each check's mechanical probe is present, and in `checks:` so a report can say it ran |
| **Out of scope** | Enforcement. `hooks/mode-guard` is the behaviour half and reads the same row; this is the staleness half. Also the asymmetry — a run may lower the mode and never raise it — which is m40 §4's and unchanged here |

## Decisions & trade-offs

**The check reads the row with `hooks/mode-guard`'s own command.** `grep -m1 -iE '^\|[^|]*\bmode\b[^|]*\|' HANDOFF.md`
— the first table row whose first cell names the mode. A check that located the row any other way
could pass while the hook denies on the same file, which is the disagreement this arc keeps
finding between a stated rule and the artifact that runs it.

**A disagreement is reported, not reconciled.** The arc-log grants a mode to a wave or a
workstream; the row says what this session is in, and it is what the hook reads. Neither is
authority over the other's subject, so the check quotes both and stops — the rule the whole
staleness block already states.

**Absent is a disagreement, not a missing check.** `hooks/mode-guard` denies on an absent row
because absent means manual. The read-path check says the same thing one step earlier, where it
costs a sentence rather than a denied commit. **Unreadable is the third state and it is carried** —
the hook denies on a cell that is not exactly `manual` or `autonomous` after stripping emphasis,
which the template's own unedited *Manual · Autonomous* row is. Pass 1 found that half missing.

**m15 §3's constraint is met on one half, and the spec now says so.** A check must cost one
command with one mechanical answer; absence does, and a disagreement is a comparison against a
document the reading order has already opened. Recorded in m15 rather than left as a check that
quietly does not meet the rule its own spec states.

**The eighth check is declared the way #267's thirteen are** — `mode-row-agrees` in `checks:`,
skipped on the write path, because no handoff is being acted on there.

## Rejected approaches

**Comparing the two strings.** The arc-log's mode is a sentence — *Manual until the merge route
is fixed. Autonomous per workstream after* — so an equality test would report a disagreement on
every cold start of this arc. The check asks whether the arc-log grants the mode the row claims,
which is a reading, and it is the same reading the surrounding checks make.

**Putting it in `hooks/mode-guard` instead.** The hook fires at the moment of a commit and reads
one file. It has no occasion to open the arc-log, and a hook that reads a document to make a
judgement is a hook that denies on a judgement.

## Spawned

- **Issues:** none.

## Retrospective

**The gate was written first and failed on the missing eighth check**, which is what put the row
in the read-path slice rather than anywhere else in the skill: `tools/verify-handoff-checks.sh`
bounds its probes to that slice on purpose.

**The gate asserts the row and the command separately, and pass 1 is why.** The first draft
probed only `grep -m1 -iE`, which lives in the prose — so deleting the table row left the gate
green with the check gone. The row is now the check's own probe and the command sits with the
rules that travel with the checks, anchored on the table cell rather than the phrase. Deleting
either exits 1, and both are selftest cases rather than ad-hoc runs — the gate's own rule is that
a gate nobody can make fail is one nobody should read a pass from.

**The probe is split because a table cell cannot hold the command.** A markdown table cell splits on
an unescaped `|`, and the command is a regex made of them — so the command lives in the prose
below the table and the row carries the condition. That is also where the rule about reading it
the hook's way belongs.
