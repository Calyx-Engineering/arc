# Issue #34 — Question blocks answerable by reference

> Decision log, not a spec. Started at plan time, finalised as a retrospective at PR time.

**Issue:** [#34](https://github.com/Calyx-Engineering/arc/issues/34)  ·  **PR:** _pending_

## Problem

`chat-response` covers length and structure. It does not cover the shape that makes a
multi-topic exchange answerable: labelled questions the user can reply to by number, each
carrying alternatives and a recommendation. Used throughout
[#27](https://github.com/Calyx-Engineering/arc/issues/27)'s scoping and load-bearing there,
recorded nowhere.

## Intent and north star

**Pass 1 — the issue body alone.**

| | |
|---|---|
| **What this issue is really for** | Not "add a format". The issue names the failure precisely: *"A question with no recommendation hands the design back to the user… the depth is not in the questioning but in the answering."* The block exists so the user **judges** rather than **invents** |
| **North star** | A reply covering several topics can be answered in a few words, by number, without the user restating anything |
| **What makes it durable** | The labels are the same labels the scoping inventory uses. Two schemes for the same job is worse than none |
| **Out of scope** | The single-decision case, which `chat-response` already covers under *A decision leads the message* |

**Pass 2 — what it links to, the spec of the mechanism it traces to, and the artifacts it names.**

The north star did not move. Three things changed underneath it.

| | |
|---|---|
| **Two shipping skills currently contradict each other** | `chat-response` says *"One decision per question. Bundled questions get partial answers."* [`spec-interview`](../../skills/spec-interview/SKILL.md) says *"Two or three questions per set, one set per exchange."* Both are right about different units, and neither says which unit it means. **Resolving that is the load-bearing half of this issue**, not the format |
| **The label scheme already exists in `CLAUDE.md`, unowned** | *"Number discussion topics — a reply covering several topics labels each D1, D2… so he can answer by number instead of restating."* A repo instruction with no skill carrying it is the shape [#89](https://github.com/Calyx-Engineering/arc/issues/89) is about |
| **[#33](https://github.com/Calyx-Engineering/arc/issues/33) shipped the letters an hour ago** | `spec-interview`'s inventory assigns a letter per subject and numbers the questions inside it. #34's `V1`/`A1`/`I1` **is that scheme**. `D` is what it degrades to when there is no inventory — a discussion rather than an interview |

**The dead-link check.** The issue's Related points at
`docs/product-architecture/mechanisms/m38-chat-response.md`, which does not exist — m38 is one
of the three mechanisms whose skill *is* its spec. Same dead link
[#31](https://github.com/Calyx-Engineering/arc/issues/31) found and fixed in its own body.

**Intent classification — [`arc-intent`](../../skills/arc-intent/SKILL.md).** Read §2 and §7.
Tracker and chat mechanics in a Camp-scoped arc: ***escalate***, decided already —
[#31](https://github.com/Calyx-Engineering/arc/issues/31)–[#35](https://github.com/Calyx-Engineering/arc/issues/35) are `arc-intent`'s worked case. Not re-raised.

## The plan

| | | Status |
|---|---|---|
| 1 | **Reconcile the unit** — one block, two or three numbered questions, one decision each | — |
| 2 | `chat-response` — the block convention, with alternatives and a recommendation | — |
| 3 | The label scheme, and that it is `spec-interview`'s letters where an inventory exists | — |
| 4 | One block per message; never a second before the first is answered | — |
| 5 | Fix the dead m38 link in the issue body | — |
| 6 | Four refining passes, three review passes | — |

## Decisions & trade-offs

_Filled as they are made._

## Retrospective

_At PR time._
