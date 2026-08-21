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

**So the deliverable is a new `work-watch` check**, and its subject is *the working surface* —
whether the tracker still says where the work is. It landed as **check 5**, beside check 4
where the gates belong; the friction check renumbered to 6.

**Intent classification — [`arc-intent`](../../skills/arc-intent/SKILL.md).** Read §2 and §7.
Tracker and chat mechanics in a Camp-scoped arc: ***escalate***, decided already —
[#31](https://github.com/Calyx-Engineering/arc/issues/31)–[#35](https://github.com/Calyx-Engineering/arc/issues/35) are `arc-intent`'s worked case. Not re-raised.

## The plan

| | | Status |
|---|---|---|
| 1 | `work-watch` **check 5** — the tracker as working state, read not only written. The friction check became 6 | Done, `371c716` |
| 2 | The settled-decision rule, generalised out of `spec-interview` | Done, `371c716` |
| 3 | The tangent-becomes-an-issue-now rule, and its boundary with m46 | Done, `371c716` |
| 4 | Why it is structural rather than attentional — the argument the issue makes | Done, `371c716` |
| 5 | Propagate the check count, again — five places outside the skill | Done, swept to zero stale |
| 6 | Four refining passes, three review passes | Done |
| + | **m15 and m13 back-reference check 5** — it claims m15's argument and is m13's other half | Done |
| + | **The posture block, restated for six** | Done — it said *"four of the six nudge"* and *"check 4 is not a nudge"*, describing neither |

## Decisions & trade-offs

| | |
|---|---|
| **Check 5, not check 6** | It belongs beside check 4 — both are gates that fire on an act and govern your own behaviour. The friction check renumbered because grouping by kind beats preserving a number one issue old |
| **It notices; it does not create the surface** | A check that files the checklist owns the work's shape. This one only fires when the surface in use has stopped being current, whatever that surface is |
| **The fourth firing case is a nudge, and is named as one** | *Re-anchoring cost the transcript* cannot be repaired by writing one more thing down — the surface itself has failed, and only the human can decide whether to rebuild it. Papering that over as a gate would have been the tidier lie |
| **The boundary with m46 is stated in the skill, not inferred** | m46 owns where a discovery goes and whether to ascend to it. This check fires the moment one appears and nothing is written down. Two mechanisms, one moment |

## Retrospective

**Two of the three Required rows already existed, each scoped to one moment.** *Write the
decision before the next topic* is `spec-interview`'s load-bearing rule — inside an interview.
*File the tangent now* is m46's and `issue-write`'s — inside work navigation. Neither held
outside its own moment, and the general case is what was missing.

**The check count moved twice in one day.** [#98](https://github.com/Calyx-Engineering/arc/issues/98)
took it four → five and taught where the count is duplicated; this took it five → six and the
sweep found zero stale. The lesson transferred; the duplication did not get fixed, and there
are still six places asserting a number the skill owns.

| Found by | |
|---|---|
| *Is it consistent with every file?* | The posture block said *"four of the six nudge"* and *"check 4 is not a nudge"* — accurate for neither the old set nor the new |
| *Have references to every modified file been checked?* | m15 and m13 pointed at nothing. Third time in this wave: m41 in [#33](https://github.com/Calyx-Engineering/arc/issues/33), m46 in wave 3, these two here |
| *Am I on topic?* | The fourth firing row said *"Say so"* under a heading claiming the check never asks the human anything. Named it a nudge rather than dropping it |

**What is still untested.** Nothing here has run. The behaviour held through
[#27](https://github.com/Calyx-Engineering/arc/issues/27)'s scoping by accident; whether
naming it makes it reliable is unknown until a long session uses it.
