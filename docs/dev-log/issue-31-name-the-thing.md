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
