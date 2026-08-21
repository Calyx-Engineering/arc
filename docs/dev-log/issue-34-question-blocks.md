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
| 1 | **Reconcile the unit** — one block, two or three numbered questions, one decision each | Done, `f0a...` in the feat commit |
| 2 | `chat-response` — the block convention, with alternatives and a recommendation | Done |
| 3 | The label scheme, and that it is `spec-interview`'s letters where an inventory exists | Done |
| 4 | One block per message; never a second before the first is answered | Done |
| 5 | Fix the dead m38 link in the issue body | Done, read back — zero hits for the old path |
| 6 | Four refining passes, three review passes | Done |
| + | **`spec-interview` names the same unit** — the reconciliation needs both sides | Done |
| + | **`CLAUDE.md`'s D1/D2 row names the artifact that owns it** | Done, `23a620d` |
| + | **The example block carries two questions** | Done, `e6337d9` |

## Decisions & trade-offs

| | |
|---|---|
| **`D` degrades from the inventory letters; it is not a second scheme** | [#33](https://github.com/Calyx-Engineering/arc/issues/33) shipped `spec-interview`'s per-subject letters an hour earlier. Two schemes for the same job is worse than none, so `D` is what the scheme becomes when no inventory exists — a discussion rather than an interview |
| **The unit is stated in `chat-response` and referenced from `spec-interview`** | It is a conversational rule, so it belongs to m38. `spec-interview` defers rather than restating it, which is what stops the two drifting again |
| **The single-decision form stays** | A block for one decision is ceremony. The section now names both shapes and when each applies, rather than replacing one with the other |

## Retrospective

**The format was the easy half.** The load-bearing find was that two shipping skills
contradicted each other: `chat-response` said *"one decision per question"*, `spec-interview`
said *"two or three questions per set"*. Both were right about different units and neither
named its unit, so a reader following both had no consistent rule.

Naming the three levels — message, block, question — dissolves it, and neither original
sentence had to be wrong.

| Found by | |
|---|---|
| *Is it consistent with every file?* | The contradiction above, and `CLAUDE.md` carrying the D1/D2 rule with no artifact behind it — the [#89](https://github.com/Calyx-Engineering/arc/issues/89) shape |
| *Have references to every modified file been checked?* | The issue's own m38 link pointed at a `mechanisms/` file that does not exist. Same dead link [#31](https://github.com/Calyx-Engineering/arc/issues/31) found in its body |
| *Does this reach the north star?* | The example block showed one question under a rule requiring two or three. Fixed the example — [#32](https://github.com/Calyx-Engineering/arc/issues/32)'s finding that a rule contradicted by its example teaches the example |

**What is still untested.** Nothing here has run. The convention worked throughout
[#27](https://github.com/Calyx-Engineering/arc/issues/27)'s scoping; whether writing it down
makes it reproducible is unknown until the next interview.
