---
name: decompose
description: Use when turning a specification, a rough idea, or an accumulated Spawned section into a proposed set of issues — reading the source and the arc's intent, listing every part that must exist, grouping into one artifact or one decision each, ordering by dependency, and naming what each delivers when it merges. Presents the set for approval and files nothing unapproved.
camp-reports: [decomposition-proposed]
checks: [intent-read, origin-recorded, parts-listed, one-artifact-each, dependency-ordered, deliverable-named, intent-classified, approval-held]
---

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
| 1 | **Read the source and the arc's stated intent** | Both. A set that satisfies the source and drifts from the intent is the failure the intent check exists to catch. **Two kinds of source** — below |
| 2 | **List every part that must exist** | Parts, not issues. Grouping comes next, and grouping first hides parts |
| 3 | **Group into issues** | One artifact, or one decision, each |
| 4 | **Order by dependency** | Not by value |
| 5 | **Name what each delivers when it merges** | One line per issue |
| 6 | **Classify each against the arc's intent** | [`arc-intent`](../arc-intent/SKILL.md). Issue spawn is one of its four firing moments |
| 7 | **Present the set for approval, naming its origin** | **File nothing unapproved** |

**Step 2 before step 3.** Listing parts and grouping them are different acts, and doing them
together produces issues shaped by what is convenient to write rather than by what must exist.

**Step 6 does not remove anything from the set.** An issue outside the arc's intent is
presented with its classification attached — *escalate*, and the reason — so the user decides
whether it lands here or later. Dropping it silently is the same failure as filing it silently.

### Two kinds of source, and the set says which it read

**A spec is not the only input. A `Spawned` section is the other, and it has equal standing.**

| Source | Is | Reading it means |
|---|---|---|
| **A specification** | Written forward. Someone decided what should exist, then wrote it down | Every part is named. The work is finding the ones the prose implies without stating |
| **A parent's `Spawned` section** | Written backward. Rows accumulated as work uncovered work, over hours or days | The parts are already observed rather than predicted — and they are unordered, unequal in size, and some are already abandoned |

**A `Spawned` table that grew for three days is not a rough note.** It is the only record of
what the work turned out to be, written at the moments the observations were made rather than
reconstructed afterwards, and it is exactly the raw material this loop wants.

| Reading a `Spawned` section | |
|---|---|
| **Abandoned rows are input, not noise** | A row marked abandoned records a decision already taken. Re-proposing it as an issue reopens something settled — read the marker and leave it out, saying so |
| **A row is not an issue** | Rows are spot-sized: some are a part, some are three, some are half of another row. Step 2 still applies, and skipping it because the rows look issue-shaped is how a `Spawned` table decomposes straight into a bad set |
| **Rows already fixed on the branch stay** | m46 §5.1 keeps the row when the work was done immediately. It is a record, not an open item — do not propose it again |

**Record which source was read, in the proposed set's first line.** A set carries its own
origin or the user cannot tell whether an absent part was never specified or never observed —
and those have opposite fixes.

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

### How fine is too fine — the repository answers, not this skill

**The boundary is a value in the operating agreement**, section 3, **Work size** — a
`Checklist ceiling:` line. A proposed issue whose `Required` checklist is longer than it is
split before it is presented, and the split is named in the set rather than made quietly.

| The agreement says | Then |
|---|---|
| `Checklist ceiling: <n>` | `<n>` boxes in `Required` is the largest issue this repository wants |
| No clause, no file, an unreadable value | **7** |

**Read it at step 3**, where issues first get their shape. Applied at step 7 it is a review of
a set already built, and the grouping that produced the oversized issue has already happened.

**It is a ceiling, not a target.** The value is where a decomposition stops being defensible,
not what an issue should aim at. A typical issue sits well under it; the clause says how the
repository arrived at its number.

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

A list. One line per issue, in dependency order, each naming what merging it delivers —
**headed by what it was decomposed from.**

```text
Proposed — 5 issues, in dependency order.
From m43 §3, the Camp spec.

1  The event log's format            no dependency
   Merging gives every artifact one place to append to.
2  Reaching Camp by name or /camp    no dependency
   Merging makes Camp addressable.
3  Announcing completed actions      needs 1, 2
   Merging makes Arc's operation visible in conversation.
4  Status and the close sequence     needs 2
   Merging makes the ten closing steps identical every issue.
5  Holding the arc's intent          needs 4
   Merging lets Camp test proposed work against the arc's goal.

Nothing filed. Approve, edit, or reject the set.
```

**The last line is not decoration.** It states the boundary the mechanism is built on.

**Neither is the second.** `From m43 §3, the Camp spec` and
`From #45's Spawned section, 11 rows, 2 abandoned` are read differently — the first invites
*what did the spec not say*, the second *what did we not notice*.

---

## Known gaps, stated rather than solved

| | |
|---|---|
| **The boundary against [m20](../../docs/product-architecture/mechanisms/m20-arc-decomposition.md)** | m20 sequences an arc's issues at kickoff; this decomposes a single idea or spec at any point. They overlap when the idea being decomposed **is** the arc, and which owns that case is unsettled |
| **Whether a large idea should be an arc** | A large enough idea is an arc rather than a set of issues. This skill does not make that call — say so and let the user decide |

**These are stated, not hidden.** A gap named in the artifact is one the user can work around;
a gap discovered at use is one that produced a bad decomposition first.

---

## Related

- [m43 §3.3](../../docs/product-architecture/mechanisms/m43-camp-assistant.md) — decomposition, which this implements
- [m46 §6](../../docs/product-architecture/mechanisms/m46-work-navigation.md) — the `Spawned` section this reads as a source, and why its rows accumulate rather than being cleared down
- [`issue-write`](../issue-write/SKILL.md) — what files the set once approved, the title rule, and what writes a `Spawned` row
- [`arc-intent`](../arc-intent/SKILL.md) — the intent check, which decides whether a proposed issue belongs in this arc
- [`camp`](../camp/SKILL.md) — the entry point
