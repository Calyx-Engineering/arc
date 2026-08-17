# Friction Log — ROADZ rev B, 2026-07-21 → 2026-08-14

Evidence for the plugin-scope decision. Extracted from 28 Claude Code transcripts
across the ROADZ branches and worktrees (~91 MB), filtered to 474 David messages, then
to 75 carrying a correction or friction signal.

Method: read the user's own words, not the assistant's summaries of them. Every row
below traces to a real message.

---

## 1. Friction by frequency

Ranked by how often it recurred, because recurrence is what a mechanism can fix.

| Rank | Friction | Times | Costs |
|---|---|---|---|
| 1 | **Wrong branch / worktree / lost work** | 8+ | Whole sessions. One near-disaster |
| 2 | **Report style must be re-taught** | 12+ | Re-reading and re-editing every report |
| 3 | **Issue style must be re-taught** | 6+ | Re-reading and re-editing every issue |
| 4 | **Context lost between sessions** | 5+ | 20+ min per cold start, sometimes more |
| 5 | **Committed too early / too much noise to review** | 4 | Cannot see what changed |
| 6 | **Shallow domain analysis** | 6+ | Long correction cycles on engineering substance |
| 7 | **Follow-up action forgotten** | 3 | Silent — only caught by chance |
| 8 | **Tracker mechanics fail silently** | 4 | Issues not closing, links not forming |

---

## 2. The eight, with evidence

### 2.1 Wrong branch / worktree — the most expensive failure

The single worst moment in four weeks:

> **"CRAP!! we screwed up big time. and we both missed it. we are supposed to be
> working off the parent branch of interface-pcba/rev_b This just completely messed
> everything up."** *(2026-08-03)*

And a cluster of smaller instances of the same class:

- *"is there a reason teh working tree at the bottom says issue 39 instead of 1?"*
- *"dar it looks like it opened on the main branch … can you fix that so its on this branch?"*
- *"do i not have the updates from #44/#45/#46 because this branch was created before then?"*
- *"why don't i see this branch up on github?"*

**Diagnosis.** Hardware work runs long-lived arc branches with several worktrees open at
once. Nothing verifies the workspace before work begins. **Three distinct checks** are
needed, one per failure above:

| Check | Catches |
|---|---|
| Correct **branch** for this task | Work landing on the wrong parent — the 08-03 incident |
| Correct **worktree** for this window | Editing in a worktree opened for a different issue |
| **Base is current** | A branch cut before other work merged, silently stale |

TimeScope solves an adjacent problem with a `PreToolUse` hook blocking source edits on
protected branches. ROADZ has no equivalent, and none of these three checks exist.

**A hook, and the highest-value single mechanism in this document** — the 08-03 case cost
a session to recover; the others cost minutes each but recur.

### 2.2 Report style — taught repeatedly, never retained

Twelve-plus corrections, all pulling in one direction. Representative:

> *"the readme should be short with quick conclusions unless there is critical
> information … i spend forever reading it and it talks to me like i'm a 5 year old"*

> *"Your point of view should always reference 'what was the last released thing' e.g.
> rev A as 'previous' concept."*

> *"is talking like a tech bro again"*

> *"you're not presenting in a way i can read. maybe make a scratchpad md because the
> chat makes your statements illegible."*

**Diagnosis.** `engineering-report` exists and is good — it was *built out of these
corrections during the four weeks*. The skill is the artifact of this friction, not a
pre-existing solution to it. It is portable and largely done.

### 2.3 Issue style — same pattern, thinner skill

> **"ok new rule, we must be much less verbose about these issues. i spend forever
> reading it and it talks to me like i'm a 5 year old by providing basic reasoning
> e.g. 'Nobody has yet reconciled the union of them against the actual pinout.' is a
> useless sentence and wastes time."** *(2026-07-28)*

> *"in file table we don't need to list the same effective file 3 times"*

> *"the related issues is helpful, but please stick to bullet point list and not c[ommas]"*

> *"ummm are you broken right now? you didnt update the issue description to be detailed
> it just says '@-'"*

Confirmed in David's own words two weeks later:

> *"i think its very important to create some system around how to write issues because
> i have had to repeatedly reguide you on that."*

### 2.4 Context lost between sessions

> **"Its monday. I started a clean chat and it seems to be COMPLETELY clueless … your
> handoff was insufficient to start a new chat. i've wasted about 20 minutes trying to
> get it to start up and i'm out of paitence with that approach."** *(2026-08-10)*

> *"it looks like we lost the conversation from when we completed issue 44. Gosh this is
> a real limitation of claude and worktrees. In timescope we created a 'spine' claude to
> cleanly handoff from one issue to another."*

**Diagnosis.** David already knows the fix and named it himself — TimeScope's spine
session. It exists in software and has never been ported to hardware. Handoff files
were tried in ROADZ and proved insufficient.

### 2.5 Committing too early / unreviewable diffs

> **"could you wait before making these commits? i know you got scared when you thought
> you lost it before. but you commit before [I can review]"** *(2026-08-13)*

> **"i never squash merge … because there is so much noise here i can't tell what you
> changed"** *(2026-08-13)*

**Diagnosis.** David reviews by diff in the VS Code source-control graph. Any commit
he did not ask for destroys his review surface. Directly contradicts an agent instinct
to checkpoint work defensively.

### 2.6 Shallow domain analysis

The most technically serious category, and the least mechanical:

> **"on the PTC - you're going to have to trust me that your analysis is wrong. I don't
> have time to explain it to you."** *(2026-08-12)*

> *"i'd like you to add something to your assumption. Saturation isnt a cliff. for power
> inductors like this its more linear."*

> *"update your assumptions, i already have a 2mOhm in the LTC surge stopper."*

> *"ok i actually got the requirement wrong - max output is 4A per channel … here is
> where the requirement came from - january 15th from chad on slack: [link]"*

**Diagnosis — corrected 2026-08-16 by David.** The original reading here was
*"assumptions invisible until wrong."* That is wrong. The information was available —
in datasheets, largely as graphs — and was not retrieved. The defect is **analysis
depth, not missing input**: devices modelled as binary when they are continuous, and
the primary source not consulted. David's characterisation: *"sophomore EE college
student"* level.

A second failure compounded it: the same non-issue was re-raised four or five times
without new evidence, until David said stop. **Re-raising an answered concern is its own
defect.**

Full analysis, including the BOM-reuse case, in
[mechanisms/domain-engineer-persona.md](mechanisms/domain-engineer-persona.md).

**The Slack-thread requirement is a separate finding.** David traces it to a weak PRD —
*"the temp range is"* style, rather than a story with acceptance criteria. Same root
cause as the missing duty-cycle fact in the PTC case: a requirement known to the team,
never written down, so the analysis could not use it. **That is the Lodestar gap
producing measurable engineering cost, twice.**

### 2.7 Follow-up actions forgotten

> **"i asked you to update #12 with the new component selection. i checked and that
> didn't happe. please do that before we forget again"** *(2026-08-11)*

> *"you pointed out #49/#50 (emissions), and then there is #51, #56, #57. why did you
> put those as spawned?"*

**Diagnosis.** Actions agreed mid-conversation have no home until someone files them.
The failure is silent — caught only because David happened to check.

### 2.8 Tracker mechanics failing silently

> *"with a commit that says it closes #11 is there a reason that #11 didn't automatically
> get closed and tagged to the commit?"*

> *"i found how to do it. i dont have authority to do it so i asked chad. please manually
> close issue 3"*

Already documented in ROADZ `CLAUDE.md` (the default-branch workaround) and already
decided as build work.

---

## 3. What the evidence changes

Six conclusions. Sections 3.1–3.4 come from the transcript scan; 3.5–3.6 were produced
by David's review of §2 on 2026-08-16 and changed the reading of the evidence itself.

### 3.1 The friction is overwhelmingly process, not requirements

Of eight friction categories, **one** is a requirements problem. Seven are delivery
process: branches, sessions, commits, issue and report authoring, follow-ups, tracker
mechanics.

**Consequence.** The build order — Crew, then Arc, then Lodestar — is supported more
strongly by this evidence than by the reasoning that first produced it. What actually
hurt during four weeks of hardware work was almost entirely delivery.

### 3.2 The hardware/software divergence is smaller than modelled

| Friction | Hardware-specific? | TimeScope already solves it? |
|---|---|---|
| Wrong branch / worktree | No | Partly — `PreToolUse` branch guard |
| Report style | No | No — ROADZ built the skill |
| Issue style | No | No |
| Session context loss | No | **Partly — see 3.2a** |
| Premature commits | No | No |
| Shallow domain analysis | **Yes** | No |
| Forgotten follow-ups | No | Partly — dev-log at checkpoints |
| Tracker mechanics | No | Partly |

**One of eight is hardware-specific.** Earlier documents claimed hardware and software
delivery differ in *control flow* — autonomy, verification timing, issue granularity,
configuration management. Those differences are real, but **they are not what caused the
pain.** The pain was generic AI-assisted-engineering friction that neither repo had
mechanised.

**Consequence.** This substantially weakens the case for separate hardware and software
delivery plugins. **One delivery plugin with a mode switch**, and the mode carries less
than previously assumed.

### 3.2a The spine does not solve session context loss

**What TimeScope's spine is:** a *chat window* on the integration branch, coordination
only, never editing source. Its durable state is the **arc-log** — a committed file with
architecture, build order, and a status table. So the arc-log is the mechanism; the spine
is a role that reads it. **A window is not a place to store state.**

**The spine itself does not solve session context loss** — a window holding that much
context saturates.

**And TimeScope's arc-log is software-shaped** — waves, tracks, PRs. It carries none of
the working context a hardware session needs. Neither did ROADZ's `handoff.md`.

**A single deeper file does not fix it either** — it grows across a 2–12 day arc until it
saturates a fresh session by itself, which is the spine's failure moved into a file.
Hence a **ladder**, where cost scales with relevance:

| Tier | Holds | Read when |
|---|---|---|
| **K1** — arc-log, dev-log | Where we are, what is next, the *why* | **Every** session start |
| **K2** — arc-work, scratch, wiki | BOM analysis, measurements, rejected paths | When the work touches it |
| **K3** — report | A product **capability**, for people | Rarely |
| **K4** — transcripts | Raw session reasoning | Queried, never loaded |

Canonical definition: [knowledge-tiers](mechanisms/knowledge-tiers.md).

Two findings fell out of designing it:

- **K3 is not per-issue.** A report documents a capability; several issues may feed
  one, most feed none. 300 reports means none get read.
- **Concerns are a second axis, not a tier.** EMI analysis for PWM dimming lives *with*
  PWM dimming; a flat agent index says where to find it, and carries no status — or it
  competes with Lodestar's RD.

Structure: [hardware-record-structure](mechanisms/hardware-record-structure.md) ·
ladder: [handoff-spine](mechanisms/handoff-spine.md).

### 3.2b The switch is autonomy, not domain

> *"the switch is more 'can i automate the execution of the arc or sequence of issues?'
> not 'is it software or hardware'."* — David

Replaces the hardware/software mode. One question — *can this work run unattended between
checkpoints?* — instead of a domain answer for every mechanism, most of which would be
"identical".

**What it flips, and nothing else:**

| Setting | Autonomous | Guided |
|---|---|---|
| Who drives each issue | Agent, with checkpoints | Engineer, agent assists |
| Issue granularity | Many, small, AI-sized | Fewer, checklist-heavy |
| Verification timing | Continuous, gates merge | Deferred; review gates merge |
| Wave parallelism | Disjoint-file tracks | Usually serial |
| K2 analysis | Occasional | Most non-trivial issues |

Report style, issue style, commit rhythm, branch guarding, the context ladder and tracker
linking are **shared**.

**Why it is the better model:** it names what actually differs (hardware is guided because
steps need judgment or physical action, not because it is hardware); it admits mixed cases
(firmware autonomous, board work guided, same repo); it fails safe, since unknown work
defaults to guided; and it stops depending on job title — safety-critical software is
guided too.

**David's caveat:** this holds *"as long as … report styles, documentation requirements,
etc. are quite common."* Both are flagged in §6.

**The exception:** the one hardware-specific friction — shallow domain analysis (§2.6) —
is not delivery process at all. It needs a domain-expert persona, which is why it lands in
Bench. See [domain-engineer-persona](mechanisms/domain-engineer-persona.md).

### 3.3 The skills already written are the record of this friction

`engineering-report` and `issue-writing` were not designed and then applied. They were
**precipitated out of repeated corrections** during these four weeks — manually, after
roughly a dozen repeats each.

That validates the method and sets an expectation: the highest-confidence content for
any new plugin is already written. **Extraction, not invention.**

It also motivates [transcript-mining](mechanisms/transcript-mining.md) — doing
deliberately, at three repeats, what happened accidentally at twelve.

### 3.4 The Lodestar gap appears twice, and not where the design expects it

Two instances of a requirement that existed but was never written down, each costing
real engineering time:

| Instance | Where the requirement lived | Cost |
|---|---|---|
| 4 A per-channel output limit | A **Slack thread** from January | Analysis run against the wrong number |
| ~10 s duty cycle, long gaps | **Weeks of conversation**, never captured | PTC analysis wrong; same non-issue raised 4–5 times |

**Capture was attempted and produced the wrong artifact.**

> *"i went through a requirements capture process at the start of RAS dev. BUT i didn't
> have lodestar and i made it in more sanitized (traditional) requirements format which
> made the prd impossible to maintain."*

A traditional PRD states *"the temp range is X"* and drops the narrative that carries the
*why*. Duty cycle — 10 s bursts, long gaps — is exactly the kind of context a bare number
discards. **The story format is the fix**: acceptance criteria hold the numbers, the
narrative holds the context an analysis needs. Lodestar's core model already says this;
the RAS PRD is the counter-example that proves it.

**But capture alone is not sufficient — the failure is two-stage.** David's second point:

> *"the engineering analysis would have needed to know to go back to the stories to pull
> that important context out if it **were** there."*

| Stage | Failure | Fix |
|---|---|---|
| **1 — Capture** | PRD format discarded the context | Story format (Lodestar core) |
| **2 — Consumption** | Analysis never consulted requirements | **The analyst asks Star** |

**Both must work.** A captured story nothing reads is as useless as an uncaptured one.

**Stage 2 is Star's job, not the analyst's.** The engineering persona should not learn the
structure of the requirements set — it should ask the agent that owns it. Doc 04 already
defines Star as the PO-delegate answering *"what does the user want?"* mid-build, with a
graduated Star authority ladder:

| Star's answer | When |
|---|---|
| **Agreed** | Grounded in an agreed story — answer with authority |
| **Derived** | A reasonable extrapolation, low-stakes and reversible — answer, mark provisional, log it |
| **Escalate** | A genuine gap, or high-stakes — stop and pull David in |

**The worked case.** A PTC fuse protects the light output. Whether the chosen part
survives depends on how long the load is actually applied — the fuse tolerates a 10 s
burst indefinitely but not continuous current. The analysis assumed continuous, flagged
a problem that did not exist, and re-raised it four or five times.

Had it asked *"what duty cycle applies to the light output?"*, Star would return the
~10 s burst pattern cited to its story — or escalate because no story carries it.
**Either outcome prevents the wrong analysis.** Full case in
[domain-engineer-persona](mechanisms/domain-engineer-persona.md).

**This makes Lodestar an active participant in delivery, not a document store.** Star is
queried during engineering work, which is a stronger product boundary than "Arc reads
Lodestar's files."

**The Slack case adds a third source.** Some requirements were never in any capture
process — they live in threads, email, datasheets, a colleague's memory. Pulling from
those is a distinct mechanism from conversational capture, and this evidence says it
matters. But it supplements the story format rather than replacing it.

### 3.5 A transcript scan mis-diagnoses mechanisms

Two of eight diagnoses were wrong in a way the scan could not catch — both plausible,
both matching the felt experience, both wrong about the mechanism. Only review against
the person who lived it corrected them. **The interview step is not optional.**

| § | Plausible reading | Actual mechanism | Effect |
|---|---|---|---|
| **2.6** | Assumptions invisible until wrong → the human should state more | **Analysis depth** — datasheet curves available, not retrieved | Needs a domain-expert persona, not a communication fix |
| **2.4** | Worktree conversations are lost | **They survive; they become unfindable** | Needs an index, not a backup |

The §2.4 correction was empirical. ROADZ has **2 live worktrees and 4 transcript
directories** — two orphans, including the issue-44 conversation David reported lost. It
is on disk. See [session-preservation](mechanisms/session-preservation.md).

### 3.6 The default-branch workaround is unnecessary — tested

CLAUDE.md records the belief that `Closes #NN` only links when the PR base is the repo
default branch. **Measured 2026-08-16 and disproved.**

Two merged PRs, both based on `interface-pcba/rev_b`:

| PR | Base | `closingIssuesReferences` | Created |
|---|---|---|---|
| #55 | `interface-pcba/rev_b` | **Linked to #54** | After the default switch |
| #48 | `interface-pcba/rev_b` | **Empty** | Before the default switch |

Same non-default base, opposite outcomes. GitHub parses the keyword **when the body is
written**, against whatever the default was at that moment — a parse-time quirk, not a
base-branch restriction.

**Consequence.** The repo-global default-branch switch — which is what breaks in
multi-user repos and needs admin rights — can be replaced by per-PR
**verify-and-repair**. Full detail in [tracker-linking](mechanisms/issue-linking.md).

**Confidence caveat.** Both PRs saw manual intervention, so #55's link may have formed
from the default switch or from a body re-save. The recommendation holds either way —
verify-and-repair works in both cases — but this is **inference from two samples, not a
controlled test.** Confirm it on the first arc that runs without the default switch.

### 3.7 The recurring failure mode is silent success

Five of the eight frictions share one shape: **a mechanism reports success and does the
wrong thing.**

| Friction | What silently succeeded |
|---|---|
| Tracker mechanics (2.8) | `Closes #NN` written, no link formed |
| Follow-ups (2.7) | Issue edited, stale content left behind |
| Commits (2.5) | Staged files silently dropped, twice, weeks apart |
| Wrong branch (2.1) | Edits applied cleanly — to the wrong branch |
| Session loss (2.4) | Worktree removed, transcripts orphaned without warning |

`issue-writing` already opens with *"Every mechanism here fails silently"* — and did not
prevent these. **Naming the failure mode in a skill is not the same as checking for it.**

**Consequence.** The single highest-leverage design rule available: **assert, then
verify.** Every mechanism built from here should read back what it wrote. That behaviour
already exists for file edits and is simply not applied elsewhere.

---

## 4. Mechanisms this friction justifies

**Friction-derived only.** These fifteen came out of the evidence above.
They are not the full product scope — mechanisms that already work caused no friction
and left no trace here. The complete picture, including those, is in
[product-plan.md](product-plan.md).

**Form** — `hook` fires automatically and can deny · `skill` is invoked and shapes
behavior · `agent` runs token-heavy work and returns a bounded packet.

| Plugin | Group | Mechanism | Form | Fixes | Effort | Payback | Spec |
|---|---|---|---|---|---|---|---|
| **Lodestar** | Capture | Source decomposition | agent | [3.4](#34-the-lodestar-gap-appears-twice-and-not-where-the-design-expects-it) | High | 🆕 **Requirements stop hiding in Slack.** *Pulls requirements out of threads, email, datasheets, and colleagues rather than waiting for someone to say them in conversation* | — |
| | Capture | Story format over PRD | skill | [3.4](#34-the-lodestar-gap-appears-twice-and-not-where-the-design-expects-it) | — | ✅ **Already Lodestar doc 01 — validated, not discovered.** *Friction confirmed the story format beats a PRD; nothing new to read* | — |
| | Represent | Star as requirements interface | agent | [3.4](#34-the-lodestar-gap-appears-twice-and-not-where-the-design-expects-it) | — | ✅ **Already Lodestar doc 04 — validated, not discovered.** *Friction confirmed Star must be queried during analysis; nothing new to read* | — |
| ‎ | | | | | | | |
| **Arc** | Guardrails | Branch / worktree guard | hook | [2.1](#21-wrong-branch--worktree--the-most-expensive-failure) | Low | 🆕 **Right workspace, every time.** *Verifies branch, worktree, and base freshness before any edit* | — |
| | Guardrails | Commit rhythm | skill + hook | [2.5](#25-committing-too-early--unreviewable-diffs) | Low | 🆕 **Commits at reviewable points.** *Skill judges when to propose; hook checks files saved, identity, nothing dropped* | [spec](mechanisms/commit-rhythm.md) |
| | Tracker | Issue linking | hook + skill | [2.8](#28-tracker-mechanics-failing-silently) | Low | 🆕 **Everything links, nothing strays.** *Branch↔issue and PR↔issue links actually form; the PR targets the arc branch, not `main`. Removes the multi-user blocker* | [spec](mechanisms/issue-linking.md) |
| | Tracker | Issue write-back | hook + skill | [2.7](#27-follow-up-actions-forgotten) | Medium | 🆕 **Edits land, and agreed actions get filed.** *Reads back what it wrote to catch placeholders and stale values; captures follow-ups agreed mid-conversation* | [spec](mechanisms/issue-write-back.md) |
| | Context | Context ladder / handoff | skill + agent | [2.4](#24-context-lost-between-sessions) | Medium | 🆕 **Cold starts stop costing 20 minutes.** *The reading order: which documents a fresh session opens, in what order, and when to stop* | [spec](mechanisms/handoff-spine.md) |
| | Context | Record structure | skill | [2.4](#24-context-lost-between-sessions) | Low | 🆕 **Analysis stays findable.** *Defines `arc-log` · `dev-log` · `arc-work/` · `scratch/` · `report/`, decides which one a given piece of work is written to, and moves findings up to the wiki once they outlive the arc* | [spec](mechanisms/hardware-record-structure.md) |
| | Authoring | `issue-writing` | skill | [2.3](#23-issue-style--same-pattern-thinner-skill) | **Written** | ✅ **Already written — validated, not discovered.** *Friction confirmed issue style must be enforced, not re-taught; the skill already exists* | — |
| | Authoring | `engineering-report` | skill | [2.2](#22-report-style--taught-repeatedly-never-retained) | **Written** | ✅ **Already written — validated, not discovered.** *Friction confirmed report style must be enforced, not re-taught; the skill already exists* | — |
| ‎ | | | | | | | |
| **Arc** | Self-improve | Plugin retrospective | skill | meta | **Written** | 🆕 **Turns future work into mechanisms.** *The process that produced this document* | [skill](../../.claude/skills/plugin-retrospective/SKILL.md) |
| | Memory | Session-transcript mining | agent | [2.4](#24-context-lost-between-sessions) | Medium | 🆕 **Mines past Claude Code chat sessions — one pipeline, two filters.** *Knowledge filter distils findings into the record at PR time; friction filter clusters corrections into mechanism candidates* | [spec](mechanisms/transcript-mining.md) |
| | Memory | Session preservation | hook | [2.4](#24-context-lost-between-sessions) | Low | 🆕 **Past chat sessions stay findable.** *Indexes Claude Code transcript directories at creation, so they survive the worktree being deleted* | [spec](mechanisms/session-preservation.md) |
| ‎ | | | | | | | |
| **Bench** | Reasoning | Domain engineer persona | agent + skill | [2.6](#26-shallow-domain-analysis) | **High** | 🆕 **Analysis at real engineering depth.** *Reads datasheet curves, asks Star for requirements, escalates once then logs* | [spec](mechanisms/domain-engineer-persona.md) |

**🆕 marks what friction actually discovered. ✅ marks a mechanism that already existed** —
designed in the Lodestar docs, or already written as a skill. Friction only supplied
evidence that it matters. Skip the ✅ rows; they repeat nothing new.

**Lodestar rows come from [§3.4](#34-the-lodestar-gap-appears-twice-and-not-where-the-design-expects-it), not from §2.**
Its gap produced *engineering* cost — a wrong PTC analysis, an analysis run against the
wrong current limit — rather than process friction, so it surfaced through the review
rather than the correction scan.

### What this list shows

**Ten of fifteen are already written or low-effort adaptations** of something proven.
The four hard ones are Lodestar three plus the domain-engineer persona — each an
invention with nothing to copy.

**Arc holds over half.** Consistent with
[§3.2b](#32b-the-switch-is-autonomy-not-domain): what varies between hardware and
software is *autonomy*, not the mechanisms themselves.

**Crew's three are all meta** — they improve how the tooling gets built rather than the
engineering work. A different job from Arc's, and the clearest argument that Crew is a
separate product.

**Hooks cluster in Guardrails and Tracker.** Both enforce things that fail silently
([§3.7](#37-the-recurring-failure-mode-is-silent-success)) — the failure mode showing up
in the architecture.

## 5. What still needs the interview

The transcripts show where the AI failed. They do not show David's process where the AI
was absent — which is where the remaining gaps are:

| Topic | Why it matters |
|---|---|
| **Design review** | Gates the hardware merge; no mechanism owns it |
| **Merge → board-in-hand** | Fab, assembly, receiving — entirely unmodelled |
| **Verification once hardware exists** | How a campaign gets planned and results recorded |
| **BOM and component-revision control** | Configuration management in practice, not theory |
| **Multi-user and PLM** | A second engineer; Dedrone with Altium 365 and Atlassian |

**One question is now sharper than the others.** §3.4 shows requirements hiding in Slack
threads and undocumented conversation. Before designing elicitation, it is worth knowing
**where requirements actually live today** — which systems, whose memory, and what makes
them surface.

### The execution phase is unobserved

Everything in this document comes from **discovery-phase work** — architecture,
feasibility, a new capability, issues spawning issues. David has named the next phase as
structurally different:

| Phase | Observed? | Produces |
|---|---|---|
| **Discovery** | ✅ Four weeks of evidence | Reports, scratch, many spawned issues |
| **Execution** | ❌ **Not yet** | Scratch only; issues sequence rather than branch |

**Consequence.** The friction list may be phase-specific. Execution-phase work could
surface entirely different problems — or could find that mechanisms designed here are
mis-sized for it. **Worth re-running this retrospective after the first execution
stretch**, which is exactly what the
[plugin-retrospective](../../.claude/skills/plugin-retrospective/SKILL.md) skill exists
for.

---

## 6. Parked — pull on these later

Both remaining items test §3.2b's claim that only autonomy differs. Everything else
raised during the review was resolved in §3.2a, §3.2b, §3.6, and
[record structure](mechanisms/hardware-record-structure.md).

### 6.1 Does report style transfer unchanged?

**David disagrees with §3.2's "domain-neutral" call.** `engineering-report` was written
entirely from hardware work, so candidate biases worth testing:

| Aspect | Possible hardware bias |
|---|---|
| Evidence type | Scope captures and datasheet curves vs test output and logs |
| "Previous = last released revision" | Rev A is a physical artifact; software's is a tag |
| Confidence splits | Measured / calculated / assumed — a hardware framing? |
| Length budgets | Do software findings need the same 1–2 page discipline? |
| Safety content never trimmed | Hardware-specific, or generally good? |

**Test:** apply the skill to a TimeScope report and see what strains.

### 6.2 Issue style — likely common, worth confirming

David leans agree. Open sub-question: **same format at different granularity, or
different formats?** §3.2b puts granularity on the autonomy switch, which would leave
format fully shared.

### 6.3 Working rule — never cite TimeScope by name alone

David has largely forgotten TimeScope's mechanisms. When one is cited as already-solved,
**state what it is and how it works in the same breath.** The §3.2a correction is the
model: naming what the spine actually was is what exposed the flaw.
