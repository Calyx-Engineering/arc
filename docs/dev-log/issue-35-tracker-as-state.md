# Issue #35 — The tracker as in-session working state

> Decision log, not a spec. Started at plan time, finalised as a retrospective at PR time.

**Issue:** [#35](https://github.com/Calyx-Engineering/arc/issues/35)  ·  **PR:** _pending_

## Problem

Long working sessions drift, and the drift is invisible from inside. What kept
[#27](https://github.com/Calyx-Engineering/arc/issues/27)'s scoping on track was structural
rather than attentional — the issue's checklist *was* the state, so any message could
re-anchor by reading nine lines instead of the transcript. Nothing in Arc named it, so it
happened by accident.

## Intent and north star

**Pass 1 — the issue body alone.**

| | |
|---|---|
| **What this issue is really for** | Not "keep a checklist tidy". The issue states the argument outright: *"An agent's focus degrades with context length regardless of intent. Structure external to the context does not."* This is the **in-session** case of what [m15](../product-architecture/mechanisms/m15-handoff-spine.md) does between sessions |
| **North star** | On turn 200, re-anchoring to where the work stands costs the same as it did on turn 10 — because the state is outside the context, not in it |
| **What makes it durable** | It has to fire on a *moment*, not on good intentions. A rule that depends on noticing you have drifted is the thing that degrades |
| **Out of scope** | The scoping inventory itself, which [#33](https://github.com/Calyx-Engineering/arc/issues/33) shipped. Whether a checklist exists at all |

**Pass 2 — what it links to, the spec of the mechanism it traces to, and the artifacts it names.**

The north star did not move. Four things changed underneath it.

| | |
|---|---|
| **§9 traces this to m13, but the issue names `work-watch`** | [m13](../product-architecture/mechanisms/m13-issue-write-back.md) is issue write-back — *reads back what it wrote, captures follow-ups agreed mid-conversation*. That is the **write** half. This issue is about the tracker being **read** as state. Same artifact, adjacent mechanism |
| **`work-watch` check 4 already has the shape** | *"Before reporting any edit done, `grep` the file"* — a gate on your own reporting, fired by an act rather than a pause. **A settled decision written before the next topic opens is the same shape**: an act-fired gate, not a nudge |
| **Two of the three Required rows are already owned elsewhere, and that is the finding** | *Write the decision before the next topic* is `spec-interview`'s **load-bearing rule**, scoped to an interview. *File the tangent now* is [m46](../product-architecture/mechanisms/m46-work-navigation.md)'s and `issue-write`'s `Spawned` section. **Neither holds outside its own moment** — which is why the general case was never written down |
| **[#33](https://github.com/Calyx-Engineering/arc/issues/33) shipped the inventory an hour ago** | *"Progress was countable — three of five"* is now real for scoping. This issue generalises the surface from a scoping inventory to any checklist the work is running against |

**So the deliverable is a sixth `work-watch` check**, and its subject is *the working surface*
— whether the tracker still says where the work is.

**Intent classification — [`arc-intent`](../../skills/arc-intent/SKILL.md).** Read §2 and §7.
Tracker and chat mechanics in a Camp-scoped arc: ***escalate***, decided already —
[#31](https://github.com/Calyx-Engineering/arc/issues/31)–[#35](https://github.com/Calyx-Engineering/arc/issues/35) are `arc-intent`'s worked case. Not re-raised.

## The plan

| | | Status |
|---|---|---|
| 1 | `work-watch` check 6 — the tracker as working state, read not only written | — |
| 2 | The settled-decision rule, generalised out of `spec-interview` | — |
| 3 | The tangent-becomes-an-issue-now rule, and its boundary with m46 | — |
| 4 | Why it is structural rather than attentional — the argument the issue makes | — |
| 5 | Propagate the check count, again — five places outside the skill | — |
| 6 | Four refining passes, three review passes | — |

## Decisions & trade-offs

_Filled as they are made._

## Retrospective

_At PR time._
