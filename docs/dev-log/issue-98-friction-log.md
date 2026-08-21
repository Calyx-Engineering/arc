# Issue #98 — A friction log for the arc

> Decision log, not a spec. Started at plan time, finalised as a retrospective at PR time.

**Issue:** [#98](https://github.com/Calyx-Engineering/arc/issues/98)  ·  **PR:** _pending_

## Problem

Friction hit during an arc has nowhere to go. The arc-log holds decisions, the dev-log holds
one issue's *why*, and neither holds *this cost twenty minutes and here is what would fix it*.

> *"spin up an issue in this arc to make a friction-log in the arc-work area (for this arc)
> and that they need to add note on this in the arc log. write the first entry (this friction
> we just had) in there."* — 2026-08-21

## Intent and north star

**Pass 1 — the issue body alone.**

| | |
|---|---|
| **What this issue is really for** | Not "add a file". The improvement signal this arc exists to produce is currently only recoverable by mining transcripts after the fact, and the mechanism that would do that ([#17](https://github.com/Calyx-Engineering/arc/issues/17)) is not built. This is the cheap interim that keeps the signal from being lost |
| **North star** | Friction is written down at the moment it is felt, in a place a cold session finds without being told it exists |
| **What makes it durable** | Something has to *route* to it. A log nobody is sent to is a file nobody writes in |
| **Out of scope** | Building [#17](https://github.com/Calyx-Engineering/arc/issues/17)'s extraction. Reconstructing this arc's earlier friction from its transcripts |

**Pass 2 — what it links to, the spec of the mechanism it traces to, and the artifacts it names.**

The north star did not move. Three things changed underneath it.

| | |
|---|---|
| **`skills/record-route` has no row for friction at all** | Its table routes measurements, analysis, rejected approaches and findings. Friction is none of those — it is about the *tooling*, not the work. That absence is why this has never been captured live, and it makes the record-route row the load-bearing half of this issue rather than an extra |
| **The retrospective friction log is a different artifact, not a template** | [`docs/retrospectives/2026-08-plugin-line/friction-log.md`](../retrospectives/2026-08-plugin-line/friction-log.md) is 560 lines, mined from 28 transcripts, **ranked by recurrence**. Ranking needs the whole corpus. A live log cannot rank as it goes, so it is chronological and the ranking is the retrospective's job |
| **This log is the retrospective's input, not a small copy of it** | Which settles the format: each entry carries what a miner would otherwise have to reconstruct — the trigger, the cost, and what would have prevented it |

**Intent classification — [`arc-intent`](../../skills/arc-intent/SKILL.md).** Read §2 *Why this
arc exists* and §7 *Load-bearing decisions*. §2 names *"Arc's operation is invisible — a tool
that cannot be observed cannot be evaluated, and produces no improvement signal"* as one of
the two failures the arc exists to fix. A friction log is that signal.
***Derived*** — not in the stated plan, and admitting it changes nothing in §2.

## The plan

| | | Status |
|---|---|---|
| 1 | `docs/arc-work/03-camp/friction-log.md`, with the merge-step entry | — |
| 2 | `skills/record-route` — a row that routes friction to it | — |
| 3 | The arc-log names it in a section a cold session reads | — |
| 4 | Four refining passes, three review passes | — |

## Decisions & trade-offs

_Filled as they are made._

## Retrospective

_At PR time._
