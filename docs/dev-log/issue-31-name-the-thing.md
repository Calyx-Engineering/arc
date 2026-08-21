# Issue #31 — Saying what a thing is when naming it

> Decision log, not a spec. Started at plan time, finalised as a retrospective at PR time.

**Issue:** [#31](https://github.com/Calyx-Engineering/arc/issues/31)  ·  **PR:** _pending_

## Problem

A bare identifier makes the reader do classification work before they can answer the
question it appears in.

> *"i know through sentence context i should realize `arc/03-camp` is the **name** of a
> branch, but its a lot of extra cognitive load to search through all of my memory to figure
> out what type of thing `arc/03-camp` could be, identify it as a potential branch name, then
> figure out you're asking me to change the default branch in github. then finally make an
> assesment on your question."* — 2026-08-18

The sentence that produced it was printed by `tools/arc-default-branch.sh`, not written in a
chat reply. **A rule that lives only in a chat skill does not reach a script that prints its
own prompts**, which is why this issue has a tooling half and a guidance half.

## Intent and north star

**Pass 1 — the issue body alone.**

| | |
|---|---|
| **What this issue is really for** | Not "add a rule about naming". The reader is being made to do classification work *before* they can answer a question, and the cost lands hardest where an answer is required |
| **North star** | A prompt Arc emits can be answered without the reader first working out what kind of thing the identifier is |
| **What makes it durable** | The rule reaches the **emitter**. A script prints its own sentences and loads no skill, so guidance alone never arrives |
| **Out of scope** | Sweeping every skill for hypothetical prompts. Diagnostic output that reports rather than asks |

**Pass 2 — what it links to, the spec section, and the artifacts it names.**

The north star did not move. Three things changed underneath it:

| | |
|---|---|
| **§4 maps this issue to no m43 section** | The table shows `—` for wave 5. There is no spec section to satisfy, and looking for one is the wrong instinct |
| **m43 §3.1.2 cites this issue by number** | [#31](https://github.com/Calyx-Engineering/arc/issues/31)–[#35](https://github.com/Calyx-Engineering/arc/issues/35) are the *worked example* of an *escalate* that was correct to do. The spec relies on this cluster existing |
| **The issue's `m38` link is dead** | It points at `docs/product-architecture/mechanisms/m38-chat-response.md`, which does not exist. m38 is one of the three mechanisms whose skill *is* its spec — `CLAUDE.md` names the exception explicitly |

**Intent classification — `skills/arc-intent`.** Read §2 *Why this arc exists* and §7
*Load-bearing decisions*. Tracker and chat mechanics inside a Camp-scoped arc:
***escalate***. Already raised, and the user's decision was proceed — recorded in §4.1 and in
m43 §3.1.2. Not re-raised.

## The plan

| | | Status |
|---|---|---|
| 1 | `tools/arc-default-branch.sh` — every emitted line names the object type | Done, `17d380c` |
| 2 | [m42](../product-architecture/mechanisms/m42-default-branch-flip.md) states the phrasing its prompts must use | Done, `17d380c` |
| 3 | `skills/chat-response` carries the general rule and its limit | Done, `17d380c` |
| 4 | Artifacts that ask the user something — a standing obligation, stated in `chat-response` | Done, `17d380c` |
| 5 | **Fix the dead `m38` link in the issue body** | Pass 2 |
| 6 | Four refining passes, three review passes, against this north star | — |

## Decisions & trade-offs

| | |
|---|---|
| **The script is fixed, not only the guidance** | `tools/arc-default-branch.sh` emits its own sentences and loads no skill. Every line it prints to a human now names the object type |
| **Two words is the budget** | *"the default branch"*, not *"the arc-scoped integration branch named `arc/03-camp`"*. A qualifier that runs long means the sentence is built wrong and should be reworded instead. The limit ships with the rule, or the rule produces worse sentences than it replaces |
| **The identifier stays** | This is a qualifier, not a substitution. `arc/03-camp` still appears wherever someone has to type or verify it — it stops being the *only* thing that appears |
| **Issue numbers are exempt, and only issue numbers** | `#31` is central enough to daily use that a qualifier is noise. Mechanism identifiers, branches and paths get no such exemption — `m42` is not `#42` |
| **The rule goes in `chat-response`, not `issue-write`** | The cost lands on a reader who must classify before answering, which is a conversational cost. A tracker body is read at leisure and carries its own links |
| **The fourth checklist item is a standing obligation, not a sweep** | *Any artifact that asks the user something* is satisfied as those artifacts are built. Sweeping every existing skill for hypothetical prompts would touch most of `skills/` for no observed defect |
| **Diagnostic-only tools are out of scope** | `verify-hook.sh`, `verify-tracker-body.sh` and `sync-local-skills.sh` report; they do not ask. The friction is classification-before-answering, which needs a question |

## Where the rule is stated three times, and why that is not duplication

| Artifact | Carries |
|---|---|
| `skills/chat-response` | The general rule and its limit, for every reply |
| [m42](../product-architecture/mechanisms/m42-default-branch-flip.md) | The phrasing its own prompts must use, so the spec and the script cannot drift |
| `tools/arc-default-branch.sh` | The phrasing itself, in the strings |

The script is the emitter and cannot read either document at runtime. The spec states the
phrasing so a future rewrite of the script does not have to rediscover it from the strings.

## Open

- The rule is unenforced. Nothing checks a new prompt for a bare identifier, and the
  hook-carried checks Arc ships have never run in this repository
