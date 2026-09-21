# Issue #32 — Sizing a title to what merging delivers

> Dev-log, not a spec. Started at plan time, finalised as a retrospective at PR time.

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
| **m11's spec is a frozen reference, not an editable spec** | §9 traces this issue to m11, whose registry row links the client reference copy of `issue-writing` (private corpus, not in this repository). That tree is *"copied verbatim from a client project… do not edit these to change Arc's behavior."* **`skills/issue-write` is m11's spec in practice**, and it is the only artifact of the two this issue may touch |
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
| 1 | `skills/issue-write` — the two failures stated as one rule, with the counterweight beside the cold-comprehension rule | Done, `12c34a1` |
| 2 | **Replace the *Instead* examples that break it.** The table is the guidance | Done, `12c34a1` · `4fb77c9` |
| 3 | The type list — `scope:` versus [#73](https://github.com/Calyx-Engineering/arc/issues/73)'s `spec:`, resolved and written down | Done, `12c34a1` |
| 4 | `hooks/tracker-verify` — a mechanical signal for length, and the verify-hook ceremony run and pasted | Done, `12c34a1` · moved to the tool in `2500659` |
| 5 | `tools/sync-local-skills.sh` after any `skills/` edit | Done, every commit |
| 6 | Four refining passes, three review passes, against this north star | Done |
| + | **`tests/verify-tracker-body.sh title`** — not in the plan. Refining pass 2 found the hook cannot reach *before the write*, which the north star requires | Done, `2500659` |
| + | **`.gitattributes`** — a `.txt` fixture escaped a `**/*.md` rule and committed CRLF-bound | Done, `5cbf96f` |
| + | **m11's registry row** — pointed at the frozen client-repo copy, where the rule does not exist | Done, `319e45e` |

## Decisions & trade-offs

| | |
|---|---|
| **The title rules live in `tests/verify-tracker-body.sh`, not in the hook** | The hook is `PostToolUse` — by the time it speaks the wrong title is in the tracker, and the north star says *caught before the write*. That tool already carries the same argument for keyword placement. The hook calls it as a subprocess rather than sourcing it: the tool sets `-u`, and a guardrail that must fail open cannot inherit that |
| **The mechanical threshold is twelve words; the guidance is eight** | Run against this repo's twenty-five open issues, a threshold of ten flagged three titles that were doing their job. Judgement lives in the skill and takes the borderline; the check takes what nobody would defend |
| **A comma count, not a word count, catches the worst case** | `feat: carry work navigation in issue-write, decompose, …` is eleven words, under any defensible length gate. Six file names cost one word each. Three separators is the signal, and a serial list inside one name needs at most two |
| **[#73](https://github.com/Calyx-Engineering/arc/issues/73) keeps its `spec:` prefix** | The skill decides the type is `scope:`, and the same section says *retitle before children exist, not after*. [#73](https://github.com/Calyx-Engineering/arc/issues/73) is referenced from three sections of the arc-log and from a pointer comment on the issue itself. Leaving it is the rule being followed, not a contradiction of it |

## Rejected approaches

| | |
|---|---|
| **A shared shell library sourced by both** | Would add a third file that has to ship, and sourcing leaks `set -u` into a hook whose whole contract is failing open. A subprocess costs one fork and cannot leak anything |
| **Altering the issue's own worked-correct title to fit the regex** | `scope: Camp — obligations, documents, and the build decomposition` tripped the multi-deliverable check on its Oxford comma. Fixing the check was right; trimming the example to suit it would have been the tail wagging the dog |

## Retrospective

The issue reads as *write a title rule*. There already was one — [#31](https://github.com/Calyx-Engineering/arc/issues/31) shipped `## Titles`
three days earlier — and its *Instead* column carried the exact trailing clauses this issue
names as the failure. **A rule contradicted by the example under it teaches the example**, so
replacing four examples did more of the work than any sentence added.

The plan grew by three rows, each from a refining axis rather than from the issue.

| Found by | |
|---|---|
| *Does this reach the north star?* | The north star says *before the write*, and a `PostToolUse` hook is by definition after. The rules moved into `tests/verify-tracker-body.sh`, whose own header already argued exactly this for keyword placement. The hook now calls it |
| *Consistent with every file in the repo?* | m11's registry row pointed at the do-not-edit client-repo copy, which has none of this. A session following the registry to m11's spec would have concluded the rule does not exist |
| *Have all evaluating tests been run?* | Running the check over all twenty-five open issues is what set the threshold. At ten words it flagged three titles that were doing their job; at twelve it flags nine, every one of them a title this issue names |

**The measurement changed the design.** A word count alone misses the worst real case —
`feat: carry work navigation in issue-write, decompose, …` is eleven words, because six file
names cost one word each. Counting separators catches it and counting words never would.

**What is still untested.** Nothing here has fired inside a real session: `hooks/hooks.json`
resolves `${CLAUDE_PLUGIN_ROOT}`, which needs an installed plugin. The hook was executed
against fixtures by `tools/verify-hook.sh` and the tool against its own selftest — both real
executions, neither of them the deployed path.
