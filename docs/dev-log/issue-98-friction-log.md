# Issue #98 — A friction log for the arc

> Dev-log, not a spec. Started at plan time, finalised as a retrospective at PR time.

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
| **The retrospective friction log is a different artifact, not a template** | [`friction-transcript-log.md`](../retrospectives/2026-08-plugin-line/friction-transcript-log.md) is 560 lines, mined from 28 transcripts, **ranked by recurrence**. Ranking needs the whole corpus. A live log cannot rank as it goes, so it is chronological and the ranking is the retrospective's job |
| **This log is the retrospective's input, not a small copy of it** | Which settles the format: each entry carries what a miner would otherwise have to reconstruct — the trigger, the cost, and what would have prevented it |

**Intent classification — [`arc-intent`](../../skills/arc-intent/SKILL.md).** Read §2 *Why this
arc exists* and §7 *Load-bearing decisions*. §2 names *"Arc's operation is invisible — a tool
that cannot be observed cannot be evaluated, and produces no improvement signal"* as one of
the two failures the arc exists to fix. A friction log is that signal.
***Derived*** — not in the stated plan, and admitting it changes nothing in §2.

## The plan

| | | Status |
|---|---|---|
| 1 | `docs/arc-work/03-camp/friction-log.md`, with the merge-step entry | Done, `b81da02` |
| 2 | `skills/record-route` — a row that routes friction to it | Done, `b81da02` |
| 3 | The arc-log names it in a section a cold session reads | Done, `b81da02` — §1, §4.2, §9, §10, §14 |
| 4 | **The switch, off by default** — added mid-issue at the user's request | Done, `b81da02` |
| 5 | **m47 §3 carries it as an onboarding question** — same request | Done, `b81da02` · `a4b6a1a` |
| 6 | Four refining passes, three review passes | Done |
| + | **`work-watch` check 5** — not in the plan. Refining pass 1 found the log had a destination and no trigger | Done, `0099ea6` |
| + | **Rename the mined log to `friction-transcript-log.md`** — the user's clarification. 33 paths and 27 labels across 16 files | Done, `9467be7` |
| + | **Entry 1 rewritten** — the review pass falsified its diagnosis | Done, `9467be7` |

## Decisions & trade-offs

| | |
|---|---|
| **`work-watch` gets a fifth check rather than a sixth watcher** | The sweep already exists and already has a threshold. A separate always-on friction watcher is the split [m23](../product-architecture/mechanisms/m23-test-obligation-capture.md) rejects outright for test obligations, and the reasoning transfers unchanged |
| **It is the only one of the five with an off switch** | The other four are about the work and hold in every repository. This one is about Arc, and a repository consuming Arc has no reason to record its rough edges |
| **The switch lives in the operating agreement, not a new settings file** | §1 already carries register and two verbosity levels, is user-owned, and is what onboarding walks through. A second settings surface would need its own onboarding question anyway |
| **Renaming the mined log, not the live one** | *Transcript* names what makes it different — it is mined and ranked by recurrence, which needs the whole corpus. The live log keeps the plain name because it is the one written during work |
| **The archive links the rename touched were repaired; the rest were not** | They were one directory too shallow and already broken. Leaving a link just edited still broken is worse than not having touched it. The other archive rot is pre-existing and belongs to whoever owns the archive |

## Retrospective

**The issue as filed was three rows. It finished at nine**, and only one of the additions came
from the user — the switch and its onboarding question. The rest came from the axes.

| Found by | |
|---|---|
| *Does this reach the north star?* | The north star's durable clause is *something has to route to it*. `record-route` routes once you have decided to write; nothing decides. Without `work-watch` check 5 this log gets exactly one entry and goes quiet — the failure this repo already names for hooks, *a README line is a rule with no trigger* |
| *Is it consistent with every file?* | The check count appears in five places outside `work-watch`. Four said four |
| *Have all evaluating tests been run?* | The review pass checked entry 1's claim against [#31](https://github.com/Calyx-Engineering/arc/issues/31)'s transcript and **falsified it.** `--delete-branch` was not the cause; [#31](https://github.com/Calyx-Engineering/arc/issues/31) was denied on the flagless form |

**The last one is the finding worth keeping.** A diagnosis from three same-session data points
reached this log, the arc-log and the handoff before one `grep` of an already-saved transcript
disproved it. Entry 1 now says what is established and what is not, and the log's entry format
carries a section for exactly that separation.

**What is still untested.** `work-watch` check 5 has never fired — nothing in this repository
runs a skill. Entry 1 was written by hand, which is the mechanism being followed rather than
executed, and it is worth what it says.
