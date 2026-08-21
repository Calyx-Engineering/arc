---
name: decompose
description: Use when turning a specification or a rough idea into a proposed set of issues — reading the spec and the arc's intent, listing every part that must exist, grouping into one artifact or one decision each, ordering by dependency, and naming what each delivers when it merges. Presents the set for approval and files nothing unapproved.
camp-reports: [decomposition-proposed]
checks: [intent-read, parts-listed, one-artifact-each, dependency-ordered, deliverable-named, intent-classified, approval-held]
---

> **Copy — do not edit.** The source is [`skills/decompose/SKILL.md`](../../../skills/decompose/SKILL.md),
> which is what the plugin ships. This copy exists only so the skill is live in this repo
> before Arc is installed here. **Edit the source, then re-run `tools/sync-local-skills.sh`.**


# Decomposition

**Decomposition happens by hand every time, and its quality varies with how much context the
session still holds.** An imperfect proposed set the user corrects costs one review. No
mechanism costs the whole decomposition, every time.

> **Partial by design.** The loop below is specified; the judgement inside it is not. Shipping
> an imperfect decomposition beats shipping none.

---

## The loop

| # | Step | |
|---|---|---|
| 1 | **Read the spec and the arc's stated intent** | Both. A set that satisfies the spec and drifts from the intent is the failure the intent check exists to catch |
| 2 | **List every part that must exist** | Parts, not issues. Grouping comes next, and grouping first hides parts |
| 3 | **Group into issues** | One artifact, or one decision, each |
| 4 | **Order by dependency** | Not by value |
| 5 | **Name what each delivers when it merges** | One line per issue |
| 6 | **Classify each against the arc's intent** | [`arc-intent`](../arc-intent/SKILL.md). Issue spawn is one of its four firing moments |
| 7 | **Present the set for approval** | **File nothing unapproved** |

**Step 2 before step 3.** Listing parts and grouping them are different acts, and doing them
together produces issues shaped by what is convenient to write rather than by what must exist.

**Step 6 does not remove anything from the set.** An issue outside the arc's intent is
presented with its classification attached — *escalate*, and the reason — so the user decides
whether it lands here or later. Dropping it silently is the same failure as filing it silently.

---

## What makes one issue

| Rule | |
|---|---|
| **One artifact, or one decision** | A skill, a hook, a document — or a choice that must be settled before work can start |
| **Merging it delivers something** | If merging leaves nothing usable, it is half an issue |
| **Independently workable** | Once its dependencies merge, it needs nothing else in flight |
| **A title stating what merging delivers** | [`issue-write`](../issue-write/SKILL.md) governs. Never a concept from the conversation |

**A decision can be an issue.** A choice that must be settled before anything can be built is
a unit of work, even though it produces only a document.

### Order by dependency, not by value

**The most valuable issue is frequently the one that cannot start.** Ordering by value puts it
first and it blocks immediately.

Dependencies are stated per issue, and the order respects them. An issue whose dependency has
not merged is blocked, not merely later.

---

## What Camp does not decide

| | Owner |
|---|---|
| Whether the set is right | **The user.** Camp proposes; approval is a separate act |
| What lands in this arc versus later | **The user.** Scope is the intent check's territory |
| Whether an issue is worth doing at all | **The user** |

> **Camp files nothing unapproved.** The output is a proposed set — a list, with what each
> issue delivers. Not issues already in the tracker.

Filing is [`issue-write`](../issue-write/SKILL.md)'s, after approval.

---

## The output

A list. One line per issue, in dependency order, each naming what merging it delivers.

```text
Proposed — 5 issues, in dependency order.

1  The event log's format            no dependency
   Merging gives every artifact one place to append to.
2  Reaching Camp by name or /camp    no dependency
   Merging makes Camp addressable.
3  Announcing completed actions      needs 1, 2
   Merging makes Arc's operation visible in conversation.
4  Status and the close sequence     needs 2
   Merging makes the nine closing steps identical every issue.
5  Holding the arc's intent          needs 4
   Merging lets Camp test proposed work against the arc's goal.

Nothing filed. Approve, edit, or reject the set.
```

**The last line is not decoration.** It states the boundary the mechanism is built on.

---

## Known gaps, stated rather than solved

| | |
|---|---|
| **How fine is too fine** | *"Many small issues, not a couple with 14-point checklists"* is a stated preference; the boundary is undefined. It belongs in the operating agreement as a work-size clause once first use produces examples |
| **The boundary against [m20](../../../docs/product-architecture/mechanisms/m20-arc-decomposition.md)** | m20 sequences an arc's issues at kickoff; this decomposes a single idea or spec at any point. They overlap when the idea being decomposed **is** the arc, and which owns that case is unsettled |
| **Whether a large idea should be an arc** | A large enough idea is an arc rather than a set of issues. This skill does not make that call — say so and let the user decide |

**These are stated, not hidden.** A gap named in the artifact is one the user can work around;
a gap discovered at use is one that produced a bad decomposition first.

---

## Related

- [m43 §3.3](../../../docs/product-architecture/mechanisms/m43-camp-assistant.md) — decomposition, which this implements
- [`issue-write`](../issue-write/SKILL.md) — what files the set once approved, and the title rule
- [`arc-intent`](../arc-intent/SKILL.md) — the intent check, which decides whether a proposed issue belongs in this arc
- [`camp`](../camp/SKILL.md) — the entry point
