# Issue #33 — The scoping loop's missing half

> Decision log, not a spec. Started at plan time, finalised as a retrospective at PR time.

**Issue:** [#33](https://github.com/Calyx-Engineering/arc/issues/33)  ·  **PR:** _pending_

## Problem

Scoping an involved piece of work has no repeatable loop. [m09](../product-architecture/mechanisms/m09-kickoff-scope-gate.md)
gates scope at arc start and [m20](../product-architecture/mechanisms/m20-arc-decomposition.md)
sequences issues; neither covers the middle. The loop was observed working during
[#27](https://github.com/Calyx-Engineering/arc/issues/27), unnamed and therefore unrepeatable.

## Intent and north star

**Pass 1 — the issue body alone.**

| | |
|---|---|
| **What this issue is really for** | Not "write down a loop". The named failure is [m41](../product-architecture/mechanisms/m41-relief-valve.md)'s — *escalating questions with no visible end*. Every step in the issue's six exists to make the end visible, and the issue says so outright: *"A numbered list with three of five checked is an answer to how much longer is this? that no amount of reassurance provides"* |
| **North star** | At any point in a scoping session, the user can see how many questions remain without reading the transcript |
| **What makes it durable** | The count survives the chat window. If it lives only in the conversation, it dies with it — which is the same failure [m15](../product-architecture/mechanisms/m15-handoff-spine.md) exists for |
| **Out of scope** | Decomposition, which is [m20](../product-architecture/mechanisms/m20-arc-decomposition.md)'s and comes after. How fine an issue should be |

**Pass 2 — what it links to, the spec of the mechanism it traces to, and the artifacts it names.**

**The north star moved.** Pass 1 read the issue as specifying a loop that does not exist.
Three of its six steps already ship.

| | |
|---|---|
| **`skills/spec-interview` already carries half of it** | §9 traces this issue to **m45**, whose skill is its own spec. *One question at a time with a recommendation*, *answer by number*, and *write it into the spec before the next set* are all there — the last one marked **the load-bearing rule** |
| **The three missing steps are the ones that make the end visible** | Every question named up front · the list living in the issue as a checklist · the box checked and read back. **They are exactly the m41 half** |
| **`spec-interview`'s own structure is what causes the friction** | *"Two to three questions per set, one set per exchange"* with no list of remaining sets means the human never sees the shape. Its relief valve is a **conversational offer** — *"want me to pick and move?"* — which asks the human to judge depth without giving them the number they would need to judge it |
| **So this is a repair, and the fix is a counterweight** | Not a second skill. `skills/scope-work` would duplicate `spec-interview`'s Part 1 and the two would drift — the exception `CLAUDE.md` names for m11, m18 and m38 applies here too |

**Revised north star.** *`spec-interview` cannot run without the human being able to see how
many question sets remain, and that count lives in the tracker, not in the conversation.*

**Deviation from the issue, stated plainly.** The Required list names `skills/scope-work`. That
artifact is not being created — the capability is `spec-interview`'s and belongs in it.
`CLAUDE.md`: *document the mechanism, never the artifact — which file carries a capability is
decided when it gets built.*

**Intent classification — [`arc-intent`](../../skills/arc-intent/SKILL.md).** Read §2 *Why this
arc exists* and §7 *Load-bearing decisions*. Tracker and chat mechanics in a Camp-scoped arc:
***escalate***, decided already — [#31](https://github.com/Calyx-Engineering/arc/issues/31)–[#35](https://github.com/Calyx-Engineering/arc/issues/35) are `arc-intent`'s worked case and §4.1
records the user's proceed. Not re-raised.

## The plan

| | | Status |
|---|---|---|
| 1 | `spec-interview` — the question inventory named before the first set | — |
| 2 | The inventory lives in the issue as a checklist, and is the working surface | — |
| 3 | Box checked and read back as each set closes | — |
| 4 | Where it sits against m09, m20 and m41 — the issue's fourth Required row | — |
| 5 | The boundary against [#35](https://github.com/Calyx-Engineering/arc/issues/35), which owns checklist currency generally | — |
| 6 | Four refining passes, three review passes | — |

## Decisions & trade-offs

_Filled as they are made._

## Retrospective

_At PR time._
