# Mechanism — Autonomous Execution

**Status:** partial — the source is written and proven; what Arc changes on the way in is
not decided.
**Home:** Arc — Delegation.
**Src:** ⚙️ inherited.
**Covers:** row 25 — the roster and the dispatch ladder. Rows 26–29 come from the same
source document and are specced separately.

---

## What it is

**Work runs unattended between checkpoints.** A named roster of subagents, each pinned to a
model and effort level, plus a rule for how much of a task to hand over. The orchestrator
stays the main chat thread; agents get small briefs and return bounded packets.

Subagents cannot converse with the user, so decisions and gates stay in the main thread.
Defining an "orchestrator agent" adds a hop to every decision and detaches it from the
gates.

**The source is [`agent-process-foundation.md`](../../reference-timescope/agent-process-foundation.md)**
— written deliberately to be dropped into another repo. Part 1 is the invariant core, Part
2 is a tuning table for swapping domain specifics, Part 3 is a seeding checklist. It is the
largest single port in Arc's plan.

### The roster

| Archetype | Model / effort | Mission |
|---|---|---|
| scout | mid / med | Recon and root-cause, read-only, packet ≤30 lines |
| architect | top / high | Options studies for main-thread decisions. Decides nothing |
| planner | top / high | Slices, tests-first, track partitioning and merge order |
| builder ×N | mid / med | Implementation of a specified slice. One per toolchain track |
| reviewer | top / med | Adversarial diff review against domain invariants. Finds, never fixes |
| verifier | mid / low | Mechanical gate checklist, human-gate packet, environment staging |
| scribe | mid / low | Doc drafts, wiki curation and lint |

### The tiers

| Tier | When |
|---|---|
| **T0-Inline** | Single-file or trivial. An agent would be pure overhead |
| **T1-Squad** | Exploration, review, verification and doc drafting delegated; one builder or inline implementation |
| **T2-Wave** | Several builders in parallel, one per track |

The ladder is one decision — *how much do I hand over* — so it stays whole here. What
happens once T2 is chosen is a different question, and it belongs to Campaign: partitioning
issues into disjoint-file tracks and sequencing their merges is arc-scale work. See row 27.

### What this mechanism does not own

| | Owner |
|---|---|
| The brief and packet formats | Row 26 |
| Track partitioning, worktrees, merge order | Row 27 — Campaign |
| Where a human must act | Row 28 — Campaign |
| What agents read before exploring | Row 29 |

Scribe's mission includes wiki curation, but the wiki's structure, page budgets and lint
rules belong to row 29. The roster says who does the work; row 29 says what the work is.

---

## Why it is inherited rather than designed

It runs today. TimeScope ships eight agent definitions and a `delegate` skill, and the
model has been exercised across real feature work. Nothing here is being invented — the
open questions are all about what changes on the way into Arc.

---

## What is not decided

**The vocabulary drifted.** The source calls T1 *"standard"*. Arc's vocabulary is
**T1-Squad**, per [CLAUDE.md](../../../CLAUDE.md). The port must rename, and the reference
copy must not be edited — it is a fixed reference point.

**Which archetypes survive.** Seven are defined against a VS Code extension's workflow.
Hardware work may not need a ui-builder equivalent, and may need archetypes that do not
exist yet.

**How the tuning table ships.** Part 2 swaps domain specifics per repo. In a plugin that is
either a configuration file, a setup skill that interviews the user, or a documented manual
step. The swaps themselves belong to whichever mechanism owns each — the human gate to row
28, the builder tracks to row 27.

**Whether the roster is one artifact or many.** TimeScope has one file per agent under
`.claude/agents/`. A plugin could ship them the same way, or generate them from a single
definition at install.

**Model pinning across providers.** The source names `sonnet` and `opus` directly. A
shipped plugin needs those to be a tier — mid, top — resolved at install rather than
hardcoded.

---

## Related

- [`agent-process-foundation.md`](../../reference-timescope/agent-process-foundation.md) — the source, do not edit
- [`agent-process.md`](../../reference-timescope/agent-process.md) — TimeScope's tuned instance
- [`skill-delegate/`](../../reference-timescope/skill-delegate/SKILL.md) — the delegation skill itself
