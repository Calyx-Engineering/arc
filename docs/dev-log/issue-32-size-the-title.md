# Issue #32 — Sizing a title to what merging delivers

> Decision log, not a spec. Started at plan time, finalised as a retrospective at PR time.

**Issue:** [#32](https://github.com/Calyx-Engineering/arc/issues/32)  ·  **PR:** _pending_

## Problem

A title is a promise about what merging delivers, and it is broken in two opposite
directions.

| Failure | Shape | Observed |
|---|---|---|
| **Over-claiming** | `feat: Camp — the delivery assistant` on an issue that delivered a scoping decision | [#27](https://github.com/Calyx-Engineering/arc/issues/27) |
| **Over-explaining** | `feat: carry work navigation in issue-write, decompose, chat-response, record-route, CLAUDE.md and m21 (m46)` | Nine issues written in one session, 2026-08-20, retitled twice |

The second is an over-correction of a rule this repo already shipped. `skills/issue-write`
says a title must be *comprehensible cold*; the response was to put the explanation in the
title — the mechanism, the consequence, and the affected files, all of which are body
material.

## Intent and north star

**Pass 1 — the issue body alone.**

| | |
|---|---|
| **What this issue is really for** | Not "write a title rule". A rule already exists and produced the second failure. The issue is that the existing guidance pushes one way with no counterweight, so obeying it harder makes titles worse |
| **North star** | A title names its deliverable at the size merging actually delivers, and both ways of missing — claiming more than merges, and describing instead of naming — are caught before the write |
| **What makes it durable** | The counterweight is stated *beside* the rule that overshoots it. A limit written in a different section is read as a different topic |
| **Out of scope** | Retitling issues that already exist. The body's own constraint forbids it |

**Pass 2 — what it links to, the spec of the mechanism it traces to, and the artifacts it names.**

The north star did not move. Four things changed underneath it.

| | |
|---|---|
| **m11's spec is a frozen reference, not an editable spec** | §9 traces this issue to m11, whose registry row links [`docs/reference-roadz/issue-writing/SKILL.md`](../reference-roadz/issue-writing/SKILL.md). That tree is *"copied verbatim from a client project… do not edit these to change Arc's behavior."* **`skills/issue-write` is m11's spec in practice**, and it is the only artifact of the two this issue may touch |
| **The `## Titles` section already exists** | [#31](https://github.com/Calyx-Engineering/arc/issues/31) shipped it. This issue is not adding a section; it is repairing one that demonstrates the failure it now has to prevent |
| **Its own *Instead* examples break the new rule** | *"Number multi-topic questions so they can be answered by reference"* and *"Keep the issue checklist current while the work runs"* both carry the trailing clause the issue names as body material. **The examples are the guidance** — a rule contradicted by the example under it teaches the example |
| **`hooks/tracker-verify` already scans titles, for neither failure** | `scan_title` catches `X and Y and Z` — a title naming more than one deliverable. Over-claiming and over-explaining pass it untouched |

**A third type is already in the wild.** [#73](https://github.com/Calyx-Engineering/arc/issues/73) is titled `spec:` while the skill names `scope:`.
Whatever this issue writes has to resolve which one exists, not add a fourth.

**Intent classification — [`arc-intent`](../../skills/arc-intent/SKILL.md).** Read §2 *Why
this arc exists* and §7 *Load-bearing decisions*. Tracker mechanics in a Camp-scoped arc:
***escalate***, decided already — [#31](https://github.com/Calyx-Engineering/arc/issues/31)–[#35](https://github.com/Calyx-Engineering/arc/issues/35) are `arc-intent`'s own worked case and
the arc-log records the user's proceed in §4.1. Not re-raised.

## The plan

| | | Status |
|---|---|---|
| 1 | `skills/issue-write` — the two failures stated as one rule, with the counterweight beside the cold-comprehension rule | — |
| 2 | **Replace the *Instead* examples that break it.** The table is the guidance | — |
| 3 | The type list — `scope:` versus [#73](https://github.com/Calyx-Engineering/arc/issues/73)'s `spec:`, resolved and written down | — |
| 4 | `hooks/tracker-verify` — a mechanical signal for length, and the verify-hook ceremony run and pasted | — |
| 5 | `tools/sync-local-skills.sh` after any `skills/` edit | — |
| 6 | Four refining passes, three review passes, against this north star | — |

## Decisions & trade-offs

| | |
|---|---|
| **The title rules live in `tools/verify-tracker-body.sh`, not in the hook** | The hook is `PostToolUse` — by the time it speaks the wrong title is in the tracker, and the north star says *caught before the write*. That tool already carries the same argument for keyword placement. The hook calls it as a subprocess rather than sourcing it: the tool sets `-u`, and a guardrail that must fail open cannot inherit that |
| **The mechanical threshold is twelve words; the guidance is eight** | Run against this repo's twenty-five open issues, a threshold of ten flagged three titles that were doing their job. Judgement lives in the skill and takes the borderline; the check takes what nobody would defend |
| **A comma count, not a word count, catches the worst case** | `feat: carry work navigation in issue-write, decompose, …` is eleven words, under any defensible length gate. Six file names cost one word each. Three separators is the signal, and a serial list inside one name needs at most two |
| **[#73](https://github.com/Calyx-Engineering/arc/issues/73) keeps its `spec:` prefix** | The skill decides the type is `scope:`, and the same section says *retitle before children exist, not after*. [#73](https://github.com/Calyx-Engineering/arc/issues/73) is referenced from three sections of the arc-log and from a pointer comment on the issue itself. Leaving it is the rule being followed, not a contradiction of it |

## Rejected approaches

| | |
|---|---|
| **A shared shell library sourced by both** | Would add a third file that has to ship, and sourcing leaks `set -u` into a hook whose whole contract is failing open. A subprocess costs one fork and cannot leak anything |
| **Altering the issue's own worked-correct title to fit the regex** | `scope: Camp — obligations, documents, and the build decomposition` tripped the multi-deliverable check on its Oxford comma. Fixing the check was right; trimming the example to suit it would have been the tail wagging the dog |

## Retrospective

_At PR time._
