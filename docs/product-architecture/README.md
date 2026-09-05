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
| **Campaign** | An arc — many issues, days to weeks | What work exists, in what order, what runs in parallel, where the human stops | At kickoff, and at each checkpoint | Scope drift · unsequenced work · an arc whose shape nobody can see | Skills — judgment about sequencing and risk |
| **Knowledge** | One finding, routed to one place | Which tier it belongs in, and when it moves up | Session start to read · decision points and PR time to write | A 20-minute cold start · analysis nobody finds again · reasoning that dies with the machine | Skills for routing, plus a hook that invokes the mining agent |
| **Delegation** | One task, handed to a worker | Which agent takes it, on which model, and what comes back | On dispatch, whoever calls | Orchestrator filling with raw output · top-model rates for mechanical work · every agent re-deriving what the last one learned | Agent definitions, the brief/packet protocol, and the agents themselves |
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

Thirty-five mechanisms across the six pieces.

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

| ID | Mechanism | Src | Payoff | Spec | Status |
|---|---|---|---|---|---|
| | **WORKSPACE GUARD** | | | | |
| m10 | Branch / worktree guard | 🔥 | **Right workspace, every time.** *Verifies branch, worktree, and base freshness before any edit* | [spec](mechanisms/m10-branch-guard.md) | ⚪ |
| m12 | Issue linking | 🔥 | **Everything links, nothing strays.** *Branch↔issue and PR↔issue links form; the PR targets the arc branch* | [spec](mechanisms/m12-issue-linking.md) | ⚪ |
| m42 | Default branch flip | 🔥 | **Closing keywords bind inside an arc.** *Offers to point the default branch at the arc for its lifetime, on preconditions it checks itself; restores at close* | [spec](mechanisms/m42-default-branch-flip.md) | ⚪ |
| m14 | Commit rhythm | 🔥 | **Commits at reviewable points.** *Judges when to propose one; checks files saved, identity, nothing dropped* | [spec](mechanisms/m14-commit-rhythm.md) | ⚪ |
| m22 | Configuration management | 🔥 | **What is in this revision, exactly.** *Versioning is verified as work lands. Software is solved by branches and releases; hardware component and BOM state is not* | [spec](mechanisms/m22-configuration-management.md) | ⚪ |
| m40 | Autonomy switch | 🔥 | **The mode is state the user can see, not an instruction to remember.** *Three states — manual, autonomous, and autonomous suspended for a conversation. Entering is always explicit; returning to manual never has to be. The permission sits beside every prohibition it overrides, because the prohibition is read every turn and a cross-reference is read once* | [spec](mechanisms/m40-autonomy-switch.md) | 🔵 |
| m41 | Relief valve | 🔥 | **Depth has a way out.** *Notices when questioning has gone deeper than the decision needs — especially before a repo or branch exists, where the work is untracked — and offers to back out to the critical point* | [spec](mechanisms/m41-relief-valve.md) | ⚪ |
| | **AUTHORING** | | | | |
| m11 | `issue-writing` | ⚙️ | **Issues someone can act on.** *Issue and PR body practice, title sizing, and the link mechanics that fail silently* | [skill](../../skills/issue-write/SKILL.md) | 🔵 |
| m13 | Issue write-back | 🔥 | **Edits land, agreed actions get filed.** *Reads back what it wrote; captures follow-ups agreed mid-conversation* | [spec](mechanisms/m13-issue-write-back.md) | ⚪ |
| m18 | `engineering-report` | ⚙️ | **Reports that get read.** *Layering, length budgets, and confidence marking* | [skill](../../skills/engineering-report/SKILL.md) | 🔵 |
| m38 | `chat-response` | ⚙️ | **Answers, not essays.** *Length, structure, when to decide rather than ask, and the labelled block that makes a multi-topic reply answerable by number* | [skill](../../skills/chat-response/SKILL.md) | 🔵 |
| m45 | `spec-interview` | 🔥 | **A spec that matches what was agreed.** *Every question named up front so the scope has a visible end, labelled sets to reach the decisions, then the full re-read that catches a document contradicting itself* | [skill](../../skills/spec-interview/SKILL.md) | 🔵 |
| m46 | Work navigation | 🔥 | **A discovery does not derail the work or get lost.** *Records it in the parent's `Spawned` section, asks the user to ascend or descend, and branches where the dependency actually is — the patch series model* | [spec](mechanisms/m46-work-navigation.md) | ⚪ |
| | | | ↳ *The dev-log and arc-log are authored by m17, in Knowledge* | | |
| | **CAMPAIGN** | | | | |
| m47 | Onboarding | 🔥 | **Arc's behaviours survive the repository boundary.** *Configures a fresh repository once — the rules that must load without a skill firing, Camp's documents, the hooks, the default-branch decision. Zero re-teaching* | [spec](mechanisms/m47-onboarding.md) | ⚪ |
| m09 | Kickoff + scope gate | ⚙️ | **Scope is agreed before a branch exists.** *A hard stop at the start of an arc* | [spec](mechanisms/m09-kickoff-scope-gate.md) | ⚪ |
| m20 | Arc decomposition, checkpoints | 📐 | **Work arrives in reviewable chunks.** *Sequences issues and places checkpoints after the riskiest work — risk-weighted, not calendar-weighted* | [spec](mechanisms/m20-arc-decomposition.md) | ⚪ |
| m43 | Camp — the delivery assistant | 🔥 | **A colleague, not a command.** *Holds the arc's intent and asks whether proposed work still serves it, answers where the arc stands, and makes Arc's operation visible — governed by an operating agreement you approve* | [spec](mechanisms/m43-camp-assistant.md) | ⚪ |
| m21 | Arc-tree — spawn diagram | 🔥 | **Arc shape is visible.** *Family tree of which issue spawned which, so scope growth shows early* | [spec](mechanisms/m21-arc-tree.md) | ⚪ |
| m24 | Verification planning | 📐 | **Requirements get proven.** *Turns unproven requirements into a validation milestone, and reports results back* | [spec](mechanisms/m24-verification-planning.md) | ⚪ |
| m27 | Worktree waves | ⚙️ | **Parallel work without collisions.** *Partitions issues into disjoint-file tracks and sequences their merges. Disjointness is the go/no-go* | [spec](mechanisms/m27-worktree-waves.md) | ⚪ |
| m28 | Human gate | ⚙️ | **The step only a person can do, happens.** *One gate per feature-complete state, with the environment staged* | [spec](mechanisms/m28-human-gate.md) | ⚪ |
| | **KNOWLEDGE** | | | | |
| m15 | Context ladder / handoff | 🔥 | **Cold starts stop costing 20 minutes.** *Which documents a fresh session opens, in what order, and when to stop* | [spec](mechanisms/m15-handoff-spine.md) | ⚪ |
| m16 | Record routing | 🔥 | **Analysis stays findable.** *Decides which file a finding goes in, and promotes it when it outlives the arc* | [tiers](mechanisms/knowledge-tiers.md) · [structure](mechanisms/m16-hardware-record-structure.md) | ⚪ |
| m17 | K1 upkeep | ⚙️ | **The dev-log and arc-log get written, not remembered.** *A dev-log per merged unit authored at decision points, the arc-log status table updated as work lands, both gated at PR time* | [spec](mechanisms/m17-k1-upkeep.md) | ⚪ |
| m19 | Knowledge mining trigger | 🔥 | **Reasoning in transcripts reaches the record.** *Fires at PR time and runs the mining agent with the knowledge filter* | [spec](mechanisms/m30-transcript-mining.md) | ⚪ |
| m23 | Test obligation capture | 🔥 | **Designs get tested when the part arrives.** *Proposes the test item at design time, months before it can be run* | [spec](mechanisms/m23-test-obligation-capture.md) | ⚪ |
| | **DELEGATION** | | | | |
| m25 | Autonomous execution | ⚙️ | **Work runs unattended between checkpoints.** *The agent roster — scout, architect, planner, builder, reviewer, verifier, scribe — each pinned to a model, plus how much to hand over: T0-Inline · T1-Squad · T2-Wave* | [spec](mechanisms/m25-agent-roster.md) | ⚪ |
| m26 | Briefs down / packets up | ⚙️ | **The orchestrator stays lean.** *A subagent gets a small brief and returns a bounded packet, never its raw context* | [spec](mechanisms/m26-briefs-and-packets.md) | ⚪ |
| m29 | Agent wiki | ⚙️ | **Exploration cost compounds downward.** *Distilled repo knowledge every agent reads before exploring. A fork of the published wiki agent* | [spec](mechanisms/m29-agent-wiki.md) | ⚪ |
| m30 | Transcript mining | 🔥 | **One pipeline, two filters.** *Knowledge filter promotes findings into the record; friction filter clusters corrections into mechanism candidates* | [spec](mechanisms/m30-transcript-mining.md) | ⚪ |
| | **SELF-IMPROVEMENT** | | | | |
| m31 | Self-improvement loop | 🔥 | **Tooling fixes land without leaving the work.** *Files the issue, makes the fix locally uncommitted, opens the diff* | [spec](mechanisms/m31-self-improvement-loop.md) | ⚪ |
| m32 | Session preservation | 🔥 | **Past sessions stay findable.** *Indexes transcript directories at creation, before a worktree is deleted* | [spec](mechanisms/m32-session-preservation.md) | ⚪ |
| m33 | Plugin retrospective | 🔥 | **Future work becomes mechanisms.** *The process that produced this product definition* | [skill](../../skills/plugin-retrospective/SKILL.md) | 🔵 |
| m39 | Mechanism numbering | 📐 | **A new mechanism gets a number that is actually free.** *The number space spans all three plugins; a registry issues the next one and records the claim* | — | ⚪ |
| m44 | Event log | 🔥 | **Turning the volume down does not erase the evidence.** *Every artifact firing is appended to a plugin-level log, independent of verbosity — the record a retrospective and a human read to tell whether Arc is working* | [spec](mechanisms/m44-event-log.md) | ⚪ |

Numbering is inherited from the retrospective's product plan and kept stable so existing
specs and evidence still resolve. That plan ran to 37 across all three plugins, so new
mechanisms take numbers from 38 up. m38 is the first — `chat-response` was already
written and in use, and a mechanism that works produces no friction to mine, so the
retrospective never surfaced it.

**The number space is shared with Lodestar and Bench**, so "highest here, plus one" is
wrong once another plugin claims one. m39 issues the next free number; the registry it
reads is in
[suite-architecture](../suite-architecture/README.md#mechanism-numbering).

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

The files Arc ships. **One artifact carries one or more mechanisms** — they do not map
one-to-one, and pretending they do produces a plugin with twenty-seven files each doing a
tenth of a job.

**Merge when two mechanisms fire at the same moment on the same data. Keep them separate
when their triggers differ**, even when the subject matter is close.

**Reading it for a build increment:** pick the artifact, read back its mechanisms to get the
function list, then read its Needs column to find what else must exist before it is useful.

| Artifact | Form | Carries | Invoked by | Needs |
|---|---|---|---|---|
| | **WORKSPACE GUARD** | | | |
| `hooks/branch-guard` | hook | m10 | Automatic, before any edit | Campaign's branch convention |
| `hooks/tracker-verify` | hook | m12 · m43 | Automatic, on issue create, PR open, PR merge | `skills/issue-write` for repair |
| `hooks/camp-session-start` | hook | m43 | Automatic, at a session's first edit | `skills/camp` for the voice |
| `hooks/camp-branch-check` | hook | m43 | Automatic, on branch creation | `skills/camp` for the voice |
| `skills/work-watch` | skill | m14 · m23 · m41 · m13 · m15 · m17 | Always, as work proceeds | `skills/relief-valve` when the depth precondition trips · `skills/issue-write` to file what it catches · `skills/record-route` for the friction entry |
| `skills/relief-valve` | skill | m41 | Run by `work-watch` when the precondition trips | — |
| `skills/config-check` | skill | m22 | Invoked, when a revision is cut | — |
| `skills/autonomy-set` | skill | m40 | Invoked, at kickoff, on a mode word, at a wave boundary, and when an exchange turns into a conversation | `HANDOFF.md`'s *Execution mode* row for the state · `skills/work-watch` for the capture points auto commits at |
| | **AUTHORING** | | | |
| `skills/issue-write` | skill | m11 · m13 | Invoked, when writing or editing an issue or PR | — |
| `skills/engineering-report` | skill | m18 | Invoked, when writing a report | `skills/record-route` for where it lands |
| `skills/chat-response` | skill | m38 | Always, every reply | — |
| `skills/spec-interview` | skill | m45 · m41 | Invoked, when a capability needs specifying before it can be built | `skills/issue-write` for the inventory checklist and the decomposition that follows |
| | **CAMPAIGN** | | | |
| `skills/kickoff` | skill | m09 · m20 | Invoked, at the start of an arc | `skills/issue-write` to file the decomposition · `skills/autonomy-set` |
| `skills/camp` | skill | m21 · m43 | Addressed by name, or `/camp` | `.claude/arc/camp/` for its agreement and voice · `skills/decompose` |
| `skills/decompose` | skill | m43 | Invoked, when a spec or idea must become a set of issues | `skills/arc-intent` to classify the set · `skills/issue-write` to file it |
| `skills/arc-intent` | skill | m43 | On issue spawn, at PR open, when asked, and when the relief valve fires | `docs/arc-log/` for the stated intent |
| `commands/camp.md` | command | m43 | Typed as `/camp` | `skills/camp` |
| `.claude/arc/camp/` | record | m43 | Read by `skills/camp` on every invocation | — |
| `camp-reports.md` | reference | m43 | Read by anything that declares what it checks | — |
| `close-sequence.md` | reference | m43 | Read by `skills/camp` when an issue is closing or starting | `skills/record-route` · `skills/issue-write` · `hooks/tracker-verify` |
| `templates/SKILL.md` | template | m43 | Copied when a new skill is written | `camp-reports.md` |
| `skills/wave-plan` | skill | m27 | Invoked, when work may run in parallel | `skills/camp` for the partition · `skills/delegate` |
| `skills/gate-run` | skill | m28 | Invoked, at a feature-complete state | — |
| `skills/verification-plan` | skill | m24 | Invoked, when requirements need proving | Lodestar, for what must be proven |
| | **KNOWLEDGE** | | | |
| `skills/handoff` | skill | m15 | Read at cold start, written at session end | `skills/record-route` for where it lives |
| `commands/arc-next.md` | command | m15 | Typed as `/arc-next`, at the start of a session | `skills/handoff` for the read path |
| `skills/record-route` | skill | m16 · m17 | Invoked, at session start and decision points | `reference/knowledge-tiers` |
| `reference/knowledge-tiers` | reference | — | Read by anything that reads or writes the record | — |
| `hooks/mining-trigger` | hook | m19 | Automatic, at PR open | `agents/transcript-miner` |
| | **DELEGATION** | | | |
| `agents/*.md` | agents | m25 | Dispatched by the orchestrator | `wiki/` |
| `skills/delegate` | skill | m25 · m26 | Invoked, when deciding how much to hand over | `agents/*.md` |
| `wiki/` | agent | m29 | Invoked, and read by every agent before exploring | — |
| `agents/transcript-miner` | agent | m30 | Invoked by `skills/plugin-retrospective` step 1; later by `hooks/mining-trigger` and `agents/improver` | `hooks/session-index` |
| | **SELF-IMPROVEMENT** | | | |
| `agents/improver` | agent | m31 | Called at PR time, and on request | `agents/transcript-miner` · `skills/issue-write` |
| `hooks/session-index` | hook | m32 | Automatic, at worktree creation | — |
| `skills/plugin-retrospective` | skill | m33 | Invoked, after a stretch of real work | `agents/transcript-miner` |
| `scripts/next-mechanism` | script | m39 | Called when a mechanism is captured | The suite registry |
| `.claude/arc/log.md` | record | m44 | Appended whenever any artifact fires | Every artifact that declares `camp-reports:` |

**Mostly one artifact per mechanism.** Four merges, each because the
mechanisms fire together:

| Artifact | Merges | Why |
|---|---|---|
| `skills/work-watch` | m14 · m23 · m41 · m13 · m15 · m17 | One always-on sweep, six things it watches for. See below |
| `skills/issue-write` | m11 · m13 | Write the issue and verify the write landed — one moment |
| `skills/kickoff` | m09 · m20 | Scope agreement and decomposition happen in one sitting |
| `skills/delegate` | m25 · m26 | Choosing the tier and shaping the brief are the same decision |

### `skills/work-watch` — the design-time evaluator

Six mechanisms watch work as it proceeds. Splitting them into six always-on
checks means four separate sweeps competing for the same attention — and
[test-obligation-capture](mechanisms/m23-test-obligation-capture.md) rejects the split
outright: *"one of the things the design-time evaluator watches for, alongside commit
timing. Not a separate always-on process — a check in the same sweep."*

| Watches for | Proposes | Mechanism |
|---|---|---|
| The work reached a reviewable point | A commit | m14 |
| A design decision implies later physical verification | A test item | m23 |
| Questioning has gone deeper than the decision needs | Backing out to the critical point | m41 — runs `skills/relief-valve` |
| An edit was reported done while the file still contradicts it | The grep that settles it | m13 |
| A decision is settled and the next topic is opening | Writing it down before moving | m15 · m13 — a gate on your own moving on. Nudges only when the surface itself has stopped holding the state |
| Arc itself cost the work something | A line in the arc's friction log | m17 — **the only one with an off switch**, and off is the default |

The first three **propose and never act**, and share one open question: how often they may
fire before the nudging becomes the annoyance.

**The fourth blocks instead of proposing.** Edit completeness gates the agent's own report
that an edit is done — a `grep` for the replaced string, zero hits or it is not finished. It
is m13's shape B in files, which m13 had recorded as already handled; arc 03 disproved that
four times in one session.

**Names are provisional.** Paths firm up when the plugin skeleton exists.

**`reference/knowledge-tiers` carries no mechanism.** The K1–K4 ladder is a definition that
every record-reading and record-writing artifact depends on, not a capability of its own.
It is in the list because the dependency is real and something must ship it.

**Camp is a skill, not an agent.** An arc needs something that holds its shape — the spawn
tree, what is next, what must not be re-litigated. [m43](mechanisms/m43-camp-assistant.md)
settled the form: documents, skills and hooks. An agent would have to read the conversation
continuously, which is the one cost Arc cannot carry; only the relief valve needed it, and
that half degrades to a skill. The name pairs with Lodestar's Star.

**`skills/handoff` is separate from `skills/record-route` on purpose.** Record routing answers
*where does this go*; the handoff is a durable artifact that survives window death —
[its spec](mechanisms/m15-handoff-spine.md) names the gap as "2 to 12 days of end-on-end
development, surviving repeated window death, cheap to rehydrate from." Different trigger,
different lifetime.
