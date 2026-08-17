# Arc — product definition

**A Claude Code plugin for AI-driven engineering delivery.** Arc holds the unit of work an
engineer actually runs: the workspace it happens in, the issues and reports it produces,
the knowledge that survives it, and the agents that execute it. It works the same whether
the work is guided by an engineer step by step or run autonomously between checkpoints.

This document is the product definition — what Arc is and what it ships. Build order lives
in [ROADMAP.md](../../ROADMAP.md); the three-plugin suite Arc belongs to is described in
[suite-architecture/](../suite-architecture/).

---

## The six pieces

Arc is six pieces, and the arc itself is one of them.

| Piece | Scale | Decides | Fires | Prevents | Form |
|---|---|---|---|---|---|
| **Workspace guard** | One edit, commit, or PR | Whether *this* action is landing correctly | Continuously, on every tool call | Edit on the wrong branch · PR that never links · commit that drops staged files | Hooks — mechanical, no judgment |
| **Authoring** | One document | What goes in an issue or report, and what gets cut | On invocation, when something is written | Style re-taught every time · a report nobody can read · an edit that left stale content behind | Skills — style and structure |
| **The arc** | A milestone — many issues, days to weeks | What work exists, in what order, where the human stops | At kickoff, and at each checkpoint | Scope drift · unsequenced work · a milestone whose shape nobody can see | Skills — judgment about sequencing and risk |
| **Knowledge** | One finding, routed to one place | Which tier it belongs in, and when it moves up | Session start to read · decision points and PR time to write | A 20-minute cold start · analysis nobody finds again · reasoning that dies with the machine | Skills for routing, plus a hook to trigger promotion |
| **Delegation** | One task, dispatched | Which agent, which model, and when a human must be asked | On dispatch, and at each feature-complete state | Orchestrator filling with raw output · top-model rates for mechanical work · shipping what only a human could verify | Skills and agent definitions, plus the agent wiki |
| **Self-improvement** | The toolset itself, across repos | Which recurring friction is worth codifying, and where the fix belongs | At PR time, and on request | The same correction given twelve times before anyone notices · a shipped mechanism that quietly stopped working | Agents that read transcripts, plus a hook to trigger them |

**Workspace guard polices; the arc plans.** The guard's idea of *correct* — branch names,
the right base, which issue is live — is supplied by the arc, and it enforces that on
every action.

**Knowledge is a ladder**, K1 through K4, where cost scales with relevance. Canonical
definition in [mechanisms/knowledge-tiers.md](mechanisms/knowledge-tiers.md).

**Delegation has three levels** — T0-Inline · T1-Squad · T2-Wave. Briefs go down small,
packets come back bounded.

**Self-improvement is the only piece whose subject is Arc** rather than the engineering
work. A user's corrections are labeled data about where the tool is wrong, and they sit
unread on disk.

---

## Mechanisms

Twenty-five mechanisms across the six pieces.

**Src** — how the mechanism came to be part of the product. Individual specs name their
specific origin; this column says which direction it arrived from.

| | Vector | Means |
|---|---|---|
| 🔥 | **Observed** | Surfaced by self-improvement — recurring friction in real work said this was needed |
| 📐 | **Designed** | Reasoned out deliberately. Nothing was failing; this is a thing worth doing |
| ⚙️ | **Inherited** | Matured elsewhere as working practice, then brought in |

| # | Piece | Mechanism | Src | Spec | Build |
|---|---|---|---|---|---|
| 10 | Workspace guard | Branch / worktree guard | 🔥 | partial | elsewhere |
| 12 | Workspace guard | Issue linking | 🔥 | specified | none |
| 14 | Workspace guard | Commit rhythm | 🔥 | specified | none |
| 11 | Authoring | `issue-writing` | ⚙️ | specified | elsewhere |
| 13 | Authoring | Issue write-back | 🔥 | specified | none |
| 18 | Authoring | `engineering-report` | ⚙️ | specified | elsewhere |
| 9 | The arc | Kickoff + scope gate | ⚙️ | partial | elsewhere |
| 20 | The arc | Arc decomposition, checkpoints | 📐 | specified | none |
| 21 | The arc | Arc-tree — spawn diagram | 🔥 | undefined | none |
| 22 | The arc | Configuration management | 🔥 | undefined | none |
| 24 | The arc | Verification campaign | 📐 | undefined | none |
| 15 | Knowledge | Context ladder / handoff | 🔥 | partial | none |
| 16 | Knowledge | Record routing | 🔥 | specified | none |
| 17 | Knowledge | K1 upkeep | ⚙️ | partial | elsewhere |
| 19 | Knowledge | Knowledge mining trigger | 🔥 | partial | none |
| 23 | Knowledge | Test obligation capture | 🔥 | specified | none |
| 25 | Delegation | Agent roster + dispatch tiers | ⚙️ | specified | elsewhere |
| 26 | Delegation | Briefs down / packets up | ⚙️ | specified | elsewhere |
| 27 | Delegation | Worktree waves | ⚙️ | specified | elsewhere |
| 28 | Delegation | Human gate | ⚙️ | specified | elsewhere |
| 29 | Delegation | Agent wiki | ⚙️ | specified | elsewhere |
| 30 | Self-improvement | Transcript mining | 🔥 | partial | none |
| 31 | Self-improvement | Self-improvement loop | 🔥 | specified | none |
| 32 | Self-improvement | Session preservation | 🔥 | specified | none |
| 33 | Self-improvement | Plugin retrospective | 🔥 | specified | ported |

Numbering is inherited from the retrospective's product plan and kept stable so existing
specs and evidence still resolve.

### Status vocabulary

Two independent axes. A mechanism can be fully specified and not built, or running
elsewhere and only partly specified.

| Spec state | Means |
|---|---|
| `undefined` | Named only. No spec exists |
| `partial` | A spec exists with known holes. **The holes must be named** |
| `specified` | Buildable without further decisions |

| Build state | Means |
|---|---|
| `none` | Nothing exists |
| `elsewhere` | Working practice in another repo, not yet brought in |
| `ported` | In Arc, not yet exercised against real work |
| `soaked` | Has run against real work — see the soak rule in [CLAUDE.md](../../CLAUDE.md) |

**Why `partial` needs its holes named.** Transcript mining has a validated friction filter
and an undesigned knowledge filter. A single "spec written" marker made that row read as
finished. Any `partial` row states what is missing.

---

## Artifacts

*To be written — the list of files Arc ships, with the mechanisms each one carries.*
