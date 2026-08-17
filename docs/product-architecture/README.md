# Arc — product definition

> **The authority on what Arc is made of.** Its pieces, its mechanisms, the artifacts it
> ships, and the state each one is in. Where another document disagrees about scope or
> composition, this one is correct.

Arc is six pieces — workspace guard, authoring, campaign, knowledge, delegation, and
self-improvement. Every mechanism belongs to one and resolves to an artifact, so a piece of
work traces to the files that carry it and to whatever else must exist before it is useful.

**Not the authority on:** why you would use Arc — [the repo README](../../README.md) ·
what gets built next — [ROADMAP.md](../../ROADMAP.md) · how the Calyx plugins fit together
— [suite-architecture/](../suite-architecture/) · how any single mechanism works —
[mechanisms/](mechanisms/).

---

## The six pieces

One of the six produces an **arc** — a multi-issue push with a beginning, a shape, and an
end. That piece is Campaign; the arc is what it produces.

| Piece | Scale | Decides | Fires | Prevents | Form |
|---|---|---|---|---|---|
| **Workspace guard** | One edit, commit, or PR | Whether *this* action is landing correctly | On every tool call | Edit on the wrong branch · a PR that never links · a revision nobody can reconstruct | Hooks — mechanical, no judgment |
| **Authoring** | One issue, report, or reply | What gets said, and what gets cut | On invocation, whenever something is written | Style re-taught every time · a report nobody can read · an edit that left stale content behind | Skills — style and structure |
| **Campaign** | An arc — many issues, days to weeks | What work exists, in what order, where the human stops | At kickoff, and at each checkpoint | Scope drift · unsequenced work · an arc whose shape nobody can see | Skills — judgment about sequencing and risk |
| **Knowledge** | One finding, routed to one place | Which tier it belongs in, and when it moves up | Session start to read · decision points and PR time to write | A 20-minute cold start · analysis nobody finds again · reasoning that dies with the machine | Skills for routing, plus a hook that invokes the mining agent |
| **Delegation** | One task, dispatched | Which agent, which model, and when a human must be asked | On dispatch, and at each feature-complete state | Orchestrator filling with raw output · top-model rates for mechanical work · shipping what only a human could verify | Skills and agent definitions, plus the agent wiki |
| **Self-improvement** | The toolset itself, across repos | Which friction is worth codifying, and where the fix belongs | At PR time, and on request | The same correction given twelve times · a shipped mechanism that quietly stopped working | Agents that read transcripts, plus a hook |

**Workspace guard polices; campaign plans.** The guard's idea of *correct* — branch names,
the right base, which issue is live — comes from the arc, and it enforces that on every
action.

**Knowledge is a ladder**, K1 through K4, where cost scales with relevance. Canonical
definition in [mechanisms/knowledge-tiers.md](mechanisms/knowledge-tiers.md).

**Delegation has three levels** — T0-Inline · T1-Squad · T2-Wave. Briefs go down small,
packets come back bounded.

**Self-improvement is the only piece whose subject is Arc** rather than the engineering
work. A user's corrections are labeled data about where the tool is wrong, and they sit
unread on disk.

---

## Mechanisms

Twenty-seven mechanisms across the six pieces.

**Src** — how the mechanism came to be part of the product. Individual specs name their
specific origin; this column says which direction it arrived from.

| | Vector | Means |
|---|---|---|
| 🔥 | **Observed** | Surfaced by self-improvement — recurring friction in real work said this was needed |
| 📐 | **Designed** | Reasoned out deliberately. Nothing was failing; this is a thing worth doing |
| ⚙️ | **Inherited** | Matured elsewhere as working practice, then brought in |

**Spec** — a link when a written spec exists, a dash when it does not. A dash is a gap, not
a judgement about whether the mechanism matters.

**Status** — where the mechanism is against being real in Arc. The roadmap decides what
moves next; this column only reports.

| | State | Means |
|---|---|---|
| ⚪ | **Todo** | Not in Arc. A ⚪ ⚙️ row is working practice elsewhere, waiting to be brought in |
| 🔵 | **Implemented** | In Arc, waiting on the soak — it has not yet run against real work |
| ✅ | **Matured** | Soaked. Exercised against real work and holding up |

| # | Mechanism | Src | Payoff | Spec | Status |
|---|---|---|---|---|---|
| | **WORKSPACE GUARD** | | | | |
| 10 | Branch / worktree guard | 🔥 | **Right workspace, every time.** *Verifies branch, worktree, and base freshness before any edit* | — | ⚪ |
| 12 | Issue linking | 🔥 | **Everything links, nothing strays.** *Branch↔issue and PR↔issue links form; the PR targets the arc branch* | [spec](mechanisms/issue-linking.md) | ⚪ |
| 14 | Commit rhythm | 🔥 | **Commits at reviewable points.** *Judges when to propose one; checks files saved, identity, nothing dropped* | [spec](mechanisms/commit-rhythm.md) | ⚪ |
| 22 | Configuration management | 🔥 | **What is in this revision, exactly.** *Versioning is verified as work lands. Software is solved by branches and releases; hardware component and BOM state is not* | — | ⚪ |
| | **AUTHORING** | | | | |
| 11 | `issue-writing` | ⚙️ | **Issues someone can act on.** *Issue and PR body practice, and the link mechanics that fail silently* | [skill](../reference-roadz/issue-writing/SKILL.md) | ⚪ |
| 13 | Issue write-back | 🔥 | **Edits land, agreed actions get filed.** *Reads back what it wrote; captures follow-ups agreed mid-conversation* | [spec](mechanisms/issue-write-back.md) | ⚪ |
| 18 | `engineering-report` | ⚙️ | **Reports that get read.** *Layering, length budgets, and confidence marking* | [skill](../reference-roadz/engineering-report/SKILL.md) | ⚪ |
| 38 | `chat-response` | ⚙️ | **Answers, not essays.** *Length, structure, and when to decide rather than ask* | [skill](../../.claude/skills/chat-response/SKILL.md) | 🔵 |
| | | | ↳ *The dev-log and arc-log are authored by row 17, in Knowledge* | | |
| | **CAMPAIGN** | | | | |
| 9 | Kickoff + scope gate | ⚙️ | **Scope is agreed before a branch exists.** *A hard stop at the start of an arc* | — | ⚪ |
| 20 | Arc decomposition, checkpoints | 📐 | **Work arrives in reviewable chunks.** *Sequences issues and places checkpoints after the riskiest work — risk-weighted, not calendar-weighted* | — | ⚪ |
| 21 | Arc-tree — spawn diagram | 🔥 | **Arc shape is visible.** *Family tree of which issue spawned which, so scope growth shows early* | — | ⚪ |
| 24 | Verification planning | 📐 | **Requirements get proven.** *Turns unproven requirements into a validation milestone, and reports results back* | — | ⚪ |
| | **KNOWLEDGE** | | | | |
| 15 | Context ladder / handoff | 🔥 | **Cold starts stop costing 20 minutes.** *Which documents a fresh session opens, in what order, and when to stop* | [spec](mechanisms/handoff-spine.md) | ⚪ |
| 16 | Record routing | 🔥 | **Analysis stays findable.** *Decides which file a finding goes in, and promotes it when it outlives the arc* | [tiers](mechanisms/knowledge-tiers.md) · [structure](mechanisms/hardware-record-structure.md) | ⚪ |
| 17 | K1 upkeep | ⚙️ | **The dev-log and arc-log get written, not remembered.** *A dev-log per issue authored at decision points, the arc-log status table updated as work lands, both gated at PR time* | — | ⚪ |
| 19 | Knowledge mining trigger | 🔥 | **Reasoning in transcripts reaches the record.** *Fires at PR time and runs the mining agent with the knowledge filter* | [spec](mechanisms/transcript-mining.md) | ⚪ |
| 23 | Test obligation capture | 🔥 | **Designs get tested when the part arrives.** *Proposes the test item at design time, months before it can be run* | [spec](mechanisms/test-obligation-capture.md) | ⚪ |
| | **DELEGATION** | | | | |
| 25 | Agent roster + dispatch tiers | ⚙️ | **The right agent on the right work.** *Named agents, plus how much to delegate — T0-Inline · T1-Squad · T2-Wave* | — | ⚪ |
| 26 | Briefs down / packets up | ⚙️ | **The orchestrator stays lean.** *A subagent gets a small brief and returns a bounded packet, never its raw context* | — | ⚪ |
| 27 | Worktree waves | ⚙️ | **Parallel work without collisions.** *Disjoint-file tracks, one builder per track in its own worktree* | — | ⚪ |
| 28 | Human gate | ⚙️ | **The step only a person can do, happens.** *One gate per feature-complete state, with the environment staged* | — | ⚪ |
| 29 | Agent wiki | ⚙️ | **Exploration cost compounds downward.** *Distilled repo knowledge every agent reads before exploring* | — | ⚪ |
| | **SELF-IMPROVEMENT** | | | | |
| 30 | Transcript mining | 🔥 | **One pipeline, two filters.** *Knowledge filter promotes findings into the record; friction filter clusters corrections into mechanism candidates* | [spec](mechanisms/transcript-mining.md) | ⚪ |
| 31 | Self-improvement loop | 🔥 | **Tooling fixes land without leaving the work.** *Files the issue, makes the fix locally uncommitted, opens the diff* | [spec](mechanisms/self-improvement-loop.md) | ⚪ |
| 32 | Session preservation | 🔥 | **Past sessions stay findable.** *Indexes transcript directories at creation, before a worktree is deleted* | [spec](mechanisms/session-preservation.md) | ⚪ |
| 33 | Plugin retrospective | 🔥 | **Future work becomes mechanisms.** *The process that produced this product definition* | [skill](../../.claude/skills/plugin-retrospective/SKILL.md) | 🔵 |
| 39 | Mechanism numbering | 📐 | **A new mechanism gets a number that is actually free.** *The number space spans all three plugins; a registry issues the next one and records the claim* | — | ⚪ |

Numbering is inherited from the retrospective's product plan and kept stable so existing
specs and evidence still resolve. That plan ran to 37 across all three plugins, so new
mechanisms take numbers from 38 up. Row 38 is the first — `chat-response` was already
written and in use, and a mechanism that works produces no friction to mine, so the
retrospective never surfaced it.

**The number space is shared with Lodestar and Bench**, so "highest here, plus one" is
wrong once another plugin claims one. Row 39 issues the next free number; the registry it
reads lives in [suite-architecture/](../suite-architecture/).

### Spec completeness

A spec that exists is not automatically finished. Each one states its own state at the top:

| | Means |
|---|---|
| `partial` | A spec exists with known holes. **The holes must be named** |
| `specified` | Buildable without further decisions |

**Why `partial` must name its holes.** Transcript mining has a validated friction filter
and an undesigned knowledge filter. A single "spec written" marker made that row read as
finished when half of it was not designed.

**Status reports; the roadmap decides.** The Status column says where each mechanism stands
today. What moves next, and in what order, is [ROADMAP.md](../../ROADMAP.md)'s call — this
document is the authority on composition, not on sequence.

---

## Capturing a gap

When Arc should do something and does not, **the mechanism is what gets documented — never
the artifact.** A gap is a capability that is missing; which file eventually carries it is
a separate decision made by whoever builds it, against the merge rule below.

Deciding at capture time means guessing the shape of a solution before the problem is
understood. That is how a plugin ends up with twenty-six files each doing a tenth of a job.

| What was noticed | What to write |
|---|---|
| Arc should do X, and nothing covers it | A new mechanism spec, next number up. Add the row here with ⚪ |
| Arc does X, but badly | An issue against the artifact that carries it. Not a definition change |
| X should happen at a different moment | Edit the existing mechanism's spec. Same capability, different trigger |
| Two mechanisms keep firing together | A note on the artifact list, not a merged spec. The artifact decides |

**A gap captured mid-work is thin, and that is correct.** The friction, a verbatim quote if
there is one, and what should have happened. Mark the spec `partial` and name what is
undesigned. A thin spec filed at the moment of friction beats a complete one written from
memory a week later.

**When the artifact already exists, it is its own spec.** Some mechanisms are a single
skill — `issue-writing`, `engineering-report`, `chat-response`. Their Spec column links to
the skill itself, not to a `mechanisms/` file, because a separate spec would paraphrase
what the skill already says and the two would drift. Write a `mechanisms/` spec when the
capability is not yet a file, or when it spans several.

**Then file the issue**, so the gap is tracked as work rather than only described.

---

## Artifacts

*To be written — the list of files Arc ships, with the mechanisms each one carries.*
