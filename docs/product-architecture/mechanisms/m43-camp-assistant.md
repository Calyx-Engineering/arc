# Mechanism — Camp, the delivery assistant

**Status:** specified — the role, the five obligations, the form, the voice, the agreement and
the verbosity are settled. What remains open is named in *What is not designed*.
**Home:** Arc — Campaign.
**Src:** 🔥 observed.
**Covers:** m43.

---

## 1 Rationale

Camp addresses three distinct failures. **The first is its origin, the second is why it needs
authority, and the third is what makes it assessable.**

### 1.1 Orchestration is bound to a window

The workflow this mechanism replaces dedicates **one VS Code window** to running an arc: it
holds the plan, tracks which issue is active, and is where the user goes to ask what happens
next. Everything else — the editing, the building — happens elsewhere.

**The role is real; binding it to a window is what fails.**

| Failure | |
|---|---|
| The window is closed | The orchestration context is gone |
| The window moves to another branch | It no longer reflects the work |
| Work continues in a different repo or worktree | The window is left behind |
| A session ends | Nothing carries forward but what was committed |

**Orchestration must be portable.** It has to be reachable from wherever the work is
happening, and to survive a session ending — which a window cannot do and a role backed by
committed documents can.

> *"I don't like the main-thread role. It's very process specific — if I don't have a main
> repo VS Code open and keep it that way then I lose it. If the main repo opens a different
> branch then I lose it."* — 2026-08-18

This is the origin of the mechanism: **the same orchestration, held by an addressable role
instead of a window.**

### 1.2 Work drifts from its stated intent

An arc holds a stated intent, and the work executed under it diverges from that intent while
each individual step remains locally reasonable. Nothing in Arc holds the destination and
tests proposed work against it.

The existing mechanisms address adjacent problems and not this one:

| Mechanism | Answers |
|---|---|
| [m15](m15-handoff-spine.md) · [m17](m17-k1-upkeep.md) | What was decided, and where the work stands |
| [m20](m20-arc-decomposition.md) | How the work was sequenced at the outset |
| [m41](m41-relief-valve.md) | Whether the *conversation* has gone too deep |
| **None** | **Whether the work still serves the arc's intent** |

Detection is the smaller half. **The intent must be held by something with the authority to
say no** — an advisory reminder is routed around, and a party that can revise the goal when
challenged is not holding it.

### 1.3 Arc's operation is not observable

Arc's hooks, skills and templates operate without announcing themselves. Two consequences
follow.

**A tool that cannot be observed cannot be evaluated.** The user cannot tell whether Arc
helped, was absent, or was wrong — so no judgement about the tooling is possible.

**Invisible tooling produces no improvement signal.** [m30](m30-transcript-mining.md) mines
transcripts for corrections, but a user only corrects machinery they knew was running. The
self-improvement loop starves on tooling nobody noticed.

> *"the obfuscation means i dont know what it is actually doing and thus i don't know when i
> need it and when not."* — 2026-08-18

### 1.4 A role carries expectations; a command does not

The three problems above share a solution shape. Observability requires something that speaks
for Arc's operation; intent-holding requires something with standing authority over
direction. Both are properties of a **role**, not of a tool invoked on request.

Lodestar's Star establishes the pattern for product ownership. **Camp is its delivery
counterpart:** Star owns what the product must be, Camp owns getting the work done, in
order, with a record.

---

## 2 Definition

**Camp is a colleague, not a command — a role the user places expectations on.**

That distinction is the mechanism. A command is invoked and does one thing; a role is relied
upon to do a known set of things without being asked each time, and can be held to them. The
five obligations below are that set, and the operating agreement is where the user states what
they are for this repository.

| | |
|---|---|
| **Is** | A delivery lead. Holds the arc's intent, answers where work stands and what is next, reports what Arc did, speaks up unasked |
| **Replaces** | The dedicated spine window — the same orchestration, reachable from anywhere and surviving a session |
| **Is not** | A narrator of the main thread's work. Camp speaks about the arc, not about what Claude is currently typing |
| **Governed by** | A committed operating agreement the user amends by reviewed diff |
| **Answers from** | The committed record — so its answers survive session turnover |

**The primary obligation is project management**, in the sense Lodestar's Star performs
product ownership: Camp holds the arc's destination and tests proposed work against it before
that work is done. Making Arc's operation visible is the second function, and it is what
makes the tooling assessable at all.

The intent Camp holds is user-owned. Camp evaluates work against the goal and cannot revise
the goal itself.

### 2.1 What placing an expectation on Camp looks like

Each line below is an obligation the user does not have to request:

```text
[asked]        "Camp, where are we?"
               Arc 03 has six issues. #27 is scoping Camp — you are in it now.
               #31–#35 are tracker work. Nothing is blocked.

[asked]        "Help me close this and get to the next issue."
               #27 has two unchecked items: decompose, and the arc-log entry.
               After it, #37 is next — it has no dependencies.

[issue spawn]  **Camp here —** that is tracker work in an arc scoped to Camp.
               Off the stated intent — worth doing, or worth deferring?

[PR open]      **Camp here —** PR #33 opened. Milestone and keywords set.

[too deep]     **Camp here —** we are eight turns into naming with nothing written.
               Does this still serve the arc, or should we back out to the decision?

[correction]   **Camp here —** you asked me not to do that in this repo. It is a
               standing clause in the agreement.
```

**This is the whole product.** Everything below specifies how each of those lines is produced,
what governs it, and what it costs.

```mermaid
flowchart TD
    U(["The user"]) -->|amends by reviewed diff| AG["operating-agreement.md<br/>what Camp will do"]
    AG -->|governs| C{{"Camp"}}
    V["voice.md<br/>register, prefix, length"] -->|styles| C
    N["notes.md<br/>what Camp learned here"] -->|informs| C
    C -->|proposes amendment| AG
    C -->|writes freely| N
    REC[("The record<br/>arc-log · issues · handoff")] -->|answers come from| C
    C -->|speaks| U
    classDef n fill:#1e3a5f,stroke:#4a9eff,color:#fff
    classDef u fill:#3d2b4f,stroke:#b07fd6,color:#fff
    class AG,V,N,C,REC n
    class U u
```

**Camp holds no state of its own.** It reads the record, is governed by the agreement, and
writes only to its notes.

---

## 3 The five obligations

Ordered by initiator. The distinction is load-bearing: obligations that fire without a
request are what the operating agreement exists to govern.

| | Obligation | Initiator |
|---|---|---|
| **0** | Hold the arc's intent; test proposed work against it | Asked, at checkpoints, and **unsolicited** on issue spawn |
| 1 | Report where the arc stands, and what comes next | Asked |
| 2 | Decompose an idea or a base issue into issues | Asked |
| 3 | Catch problems at the moment they happen | **Unsolicited** |
| 4 | Report completed work per the agreement | **Unsolicited** |

### 3.1 Obligation 0 — holding the arc's intent

Obligation 0 tests proposed work against the arc's stated intent, before the work is done:

```mermaid
flowchart TD
    W["Work is proposed"] --> Q{"Does it serve<br/>the arc's stated intent?"}
    Q -->|yes| A["<b>Agreed</b><br/>proceed without comment"]
    Q -->|"not stated, but follows from it"| D["<b>Derived</b><br/>say so, then proceed"]
    Q -->|no| E["<b>Escalate</b><br/>stop and ask —<br/>Camp cannot decide this"]
    E --> U(["User decides"])
    U --> A
    classDef n fill:#1e3a5f,stroke:#4a9eff,color:#fff
    classDef u fill:#3d2b4f,stroke:#b07fd6,color:#fff
    class W,Q,A,D,E n
    class U u
```

Obligation 0 is a project-management function. It fixes the arc's stated intent and tests
proposed work against it **before** the work is done.

| | |
|---|---|
| **Is** | Holding the destination; evaluating proposed work against it |
| **Is not** | Reading history to locate past errors — that is the retrospective's function |

**The goal is user-owned.** Camp cannot revise the arc's intent; only the user can. That
constraint is what distinguishes a delegate from an observer — work proposed outside the
stated intent is flagged, and the flag cannot be argued away by the proposer.

The failure addressed is **development drift**: work that diverges from an arc's intent while
each individual step appears reasonable. This is one level above the conversational drift
[m41](m41-relief-valve.md) addresses.

#### 3.1.1 The intent lives in the `arc-log`

No new artifact. The `arc-log` already carries *why this arc exists* and its *load-bearing
decisions* — obligation 0 is the skill that reads them and answers against them.

#### 3.1.2 The authority ladder

A binary block would be routed around. Three levels, matching Star's ladder — shown in the
diagram above.



**Worked example.** Five issues about how issues and chat responses are written — [#31](https://github.com/Calyx-Engineering/arc/issues/31) · [#32](https://github.com/Calyx-Engineering/arc/issues/32) · [#33](https://github.com/Calyx-Engineering/arc/issues/33) · [#34](https://github.com/Calyx-Engineering/arc/issues/34) · [#35](https://github.com/Calyx-Engineering/arc/issues/35) — were
filed during an arc scoped to Camp. Outside its stated intent, and correct to do.
Classification: *escalate*; user decision: proceed. A blocking mechanism would have produced
the wrong outcome.

**Obligation 0 never blocks — it asks.** A drift flag raised against a deliberate change of
direction is worse than silence, and the mechanism cannot distinguish the two on its own.

#### 3.1.3 When it fires

```mermaid
flowchart TB
    subgraph R1[" Work is proposed or reaches a boundary "]
        direction LR
        M1["An issue<br/>is spawned"] --- M2["An issue closes,<br/>a PR opens"]
    end
    subgraph R2[" Someone or something raises it "]
        direction LR
        M3["The user<br/>asks"] --- M4["The relief valve<br/>fires on depth"]
    end
    R1 --> Q{"Does this work serve<br/>the arc's stated intent?"}
    R2 --> Q
    Q --> V["Agreed · Derived · Escalate<br/>— see the ladder above"]
    classDef n fill:#1e3a5f,stroke:#4a9eff,color:#fff
    class M1,M2,M3,M4,Q,V n
    style R1 fill:#0d1b2a,stroke:#2c4a6b,color:#8fb8e0
    style R2 fill:#0d1b2a,stroke:#2c4a6b,color:#8fb8e0
```

| Moment | |
|---|---|
| **Issue spawn** | Does this belong in the arc, or outside it |
| **Issue close · PR open** | Checkpoints that already exist |
| **Asked** | Always available |
| **When the relief valve fires** ([3.6](#36-the-relief-valve--a-skill-now-an-agent-later)) | Depth and drift, asked together |

**The relief-valve pairing shares one trigger** ([3.6](#36-the-relief-valve--a-skill-now-an-agent-later))**.** Excessive depth is commonly a symptom of
drift — questioning escalates because the direction has stopped being clear. One precondition
serves both, requiring no second trigger and no second over-firing budget.

##### 3.1.3.1 How the nudge is tuned

Direction is evaluated first, and it tunes the nudge rather than gating it. The signals that
fire the check, and this decision in full, are diagrammed at [3.6](#36-the-relief-valve--a-skill-now-an-agent-later).

| Serves the arc | Nudge | Sounds like |
|---|---|---|
| **Yes** | Light. An observation with an option attached | *"Deep on this — worth a checkpoint, or keep going?"* |
| **No** | Strong. Names the drift and proposes the exit | *"We are four questions into naming and it has left the arc's scope. Back out to the decision?"* |

**A fired precondition always produces a nudge.** Direction sets its strength and what it
proposes, never whether it speaks — the precondition already established that something is
worth remarking on, and discarding that signal wastes the only measurement available.

**Depth on a subject that serves the arc is not a defect**, so the nudge for it is an
observation the user can wave off in one word, not an intervention.

##### 3.1.3.2 Rejected — firing from the event log

Obligation 0 evaluates direction, not history. [m44](m44-event-log.md)'s event log serves the
retrospective and the human reader; obligation 0 does not read it.

#### 3.1.4 Not a capability catalogue

*"What can Arc do"* is a real question with two audiences, and neither is served by a
standalone listing inside obligation 0 — a help command is read once and never again.

| Question | Served by |
|---|---|
| What Arc can do, in general — for the user | Onboarding (backlogged; see below) |
| What Arc can do, in general — for the agent | The plugin's own file layout |
| What Arc just did here | The report — obligation 4 |
| What it should have done, and whether it did | The same report, one line further |

**Obligation 0's per-action half collapses into obligation 4.** The artifact that ran the
checks already holds what it checked and what it skipped, so no additional mechanism is
required. The arc-level question is obligation 1.

Obligation 0 is what remains after that routing: **holding the intent**, not describing the
tooling.

#### 3.1.5 The report always says what was checked

```text
**Camp here —** PR #33 opened.
  Checked: milestone, arc prefix, closing keywords — all set
  Declared but skipped: placeholder scan (no body edit)
```

**The skipped line is emitted unconditionally**, with a configuration switch to suppress it.
Unconditional emission makes it a check; conditional emission makes it easy to stop trusting.
A non-empty skipped line is an actionable gap at the moment it occurs rather than at the next
retrospective.

**Reporting rule: an artifact states what it checked for, not only what it found.** *"Checked
milestone — not set"* rather than *"milestone missing."* One additional word keeps the
machinery visible when checks pass.

##### 3.1.5.1 Rejected — naming the governing clause in each report

With no single Camp agent, no subject exists for *"why is this being done"* — each artifact holds only its own reason. A
`governed-by:` header plus a cross-artifact sweep was scaffolding for a question the
reporting rule above already answers.

### 3.2 Obligation 1 — where the arc stands, and what comes next

The full crossing — from an issue that looks finished to a session working on the next one:

```mermaid
flowchart TB
    subgraph R1[" Closing "]
        direction LR
        A["Current issue<br/>looks complete"] --> B["<b>Camp</b><br/>names what<br/>closing requires"] --> C(["<b>User</b> approves —<br/>Claude opens the PR,<br/>user merges"])
    end
    subgraph R2[" Carrying the record "]
        direction LR
        D{"Session<br/>ending?"} -->|yes| E["<b>Camp</b> triggers the handoff<br/>and confirms it landed"]
        D -->|no| F["<b>Camp</b> names the next<br/>issue, branch<br/>and dependencies"]
        E --> F
    end
    subgraph R3[" Starting "]
        direction LR
        G(["<b>User</b> approves —<br/>Claude creates<br/>the branch"]) --> H["<b>Camp</b> loads the record —<br/>and the handoff,<br/>if one was written"] --> I["Working in context<br/>on the next issue"]
    end
    C --> D
    F --> G
    classDef n fill:#1e3a5f,stroke:#4a9eff,color:#fff
    classDef u fill:#3d2b4f,stroke:#b07fd6,color:#fff
    classDef d fill:#1f3d2b,stroke:#4caf70,color:#fff
    class A,B,D,E,F,H n
    class C,G u
    class I d
    style R1 fill:#0d1b2a,stroke:#2c4a6b,color:#8fb8e0
    style R2 fill:#0d1b2a,stroke:#2c4a6b,color:#8fb8e0
    style R3 fill:#0d1b2a,stroke:#2c4a6b,color:#8fb8e0
```

Two halves, both answered from the record rather than from the conversation.

| | Sounds like |
|---|---|
| **Status** | *"Camp, where are we?"* — which issues are open, what merged, what the `arc-log`'s status table says |
| **Flow** | *"Help me close this and get to the next issue"* — what remains here, what closing requires, and what the arc says comes next |

#### 3.2.1 Flow — carrying the user across the transition

The second half is what moves work, and it is what the spine window did. Status alone is a
report; facilitating the flow means answering at each point of transition:

| At this point | Camp answers |
|---|---|
| Mid-issue | What remains unchecked, and what is blocking |
| The work looks done | What closing requires — the `dev-log`, the PR, the checklist items still open |
| An issue just closed | What the arc says is next, and whether its dependencies have merged |
| Starting the next one | Which branch it comes off, and what it depends on |



**Purple is where the user decides.** Camp names what is required and the main thread executes
it; what the user owns is the go-ahead, not the keystrokes. The crossing completes only at the
last node — an issue being open is not the same as a session being ready to work on it.

**The transition is where the spine window was most needed and most fragile.** Everything
required to answer it lives in the record; nothing requires a window to have stayed open.

**Camp proposes; it does not execute.** Camp names what remains, what is next and what that
requires. Creating the branch, opening the PR and writing the `dev-log` are performed by the
main thread and the artifacts that own them — **after the user approves**, which is the
decision Camp is surfacing.

#### 3.2.2 The handoff at a transition

A transition is exactly the moment the record must survive: a session ending, an issue
closing, work moving to a new branch. [m15](m15-handoff-spine.md) owns what a handoff
contains and how it is written. **Camp owns noticing that one is due, and confirming it
landed.**

| Step | Owner |
|---|---|
| Recognising a transition is happening | **Camp** |
| Writing the handoff | [m15](m15-handoff-spine.md) |
| Confirming it was written, and is current | **Camp** |
| Reading it back at the next session's start | [m15](m15-handoff-spine.md), invoked by Camp |

**Camp never authors the handoff.** It fires the mechanism that does and verifies the result —
the same posture as obligation 4, where the artifact does the work and Camp reports on it.

**A handoff is not the whole context load, and only sometimes exists.** Two distinct reads
happen when work resumes:

| | Holds | When it exists |
|---|---|---|
| **The handoff** | Where the last session left off | Only when a session ended mid-arc. Session-scoped and gitignored |
| **The record** | The arc's intent, the `dev-log`, the issue | Always |

A new session mid-arc reads both. Moving to the next issue without a session break reads only
the record, because no handoff was written. **Camp loads the record either way, and the
handoff when one exists** — which is why the two are named separately rather than treated as
one step.

**This is the spine window's job.** Noticing that a boundary is being crossed, and that the
record has to cross it too, is precisely what a dedicated window was being used for.

#### 3.2.3 Boundaries

**Camp orchestrates; it never authors.** [m15](m15-handoff-spine.md) owns the handoff,
[m17](m17-k1-upkeep.md) the logs, [m21](m21-arc-tree.md) the tree. Camp invokes them, verifies
they landed, and holds no state of its own.

**Answering from the committed record is what makes the answer survive session turnover** — a
fresh session asks Camp and receives the same answer the previous one would have.

**The cheapest obligation with immediate payoff**, which is why it ships in the first pass
alongside the intent-holding it supports: obligation 0 cannot evaluate direction without knowing where
the work currently stands.

### 3.3 Obligation 2 — decomposition

```mermaid
flowchart TB
    subgraph R1[" From a spec or a rough idea "]
        direction LR
        A["Read the spec<br/>and the arc's<br/>stated intent"] --> B["List every part<br/>that must exist"]
    end
    subgraph R2[" Group into issues "]
        direction LR
        C["One artifact,<br/>or one decision,<br/>per issue"] --> D["Order by<br/>dependency,<br/>not by value"]
    end
    subgraph R3[" Before filing "]
        direction LR
        E["Name what each<br/>issue delivers<br/>when it merges"] --> F(["<b>User</b><br/>approves<br/>the set"])
    end
    R1 --> R2 --> R3
    classDef n fill:#1e3a5f,stroke:#4a9eff,color:#fff
    classDef u fill:#3d2b4f,stroke:#b07fd6,color:#fff
    class A,B,C,D,E n
    class F u
    style R1 fill:#0d1b2a,stroke:#2c4a6b,color:#8fb8e0
    style R2 fill:#0d1b2a,stroke:#2c4a6b,color:#8fb8e0
    style R3 fill:#0d1b2a,stroke:#2c4a6b,color:#8fb8e0
```

Turning a specification or a rough idea into a set of issues that can be worked
independently.

**Status: partial.** The loop is specified; the judgement inside it is not. Shipping an
imperfect decomposition beats shipping none — a proposed set the user corrects costs one
review, while no mechanism costs the whole decomposition every time.

#### 3.3.1 What makes one issue

| Rule | |
|---|---|
| **One artifact, or one decision** | A skill, a hook, a document — or a choice that must be settled before work starts |
| **Merging it delivers something** | If merging leaves nothing usable, it is half an issue |
| **Independently workable** | Once its dependencies merge, it needs nothing else in flight |
| **A title stating what merging delivers** | Governed by [m11](m11-issue-writing.md); the same rule that rejects naming a concept from the conversation |

**Order by dependency, not by value.** The most valuable issue is frequently the one that
cannot start. Sequencing is what the arc-log records as load-bearing.

#### 3.3.2 What Camp does not decide

| | Owner |
|---|---|
| Whether the set is right | **The user.** Camp proposes; approval is a separate act |
| What lands in this arc versus later | **The user.** Scope is obligation 0's territory, and the goal is user-owned |
| Whether an issue is worth doing at all | **The user** |

**Camp files nothing unapproved.** The output is a proposed set, presented as a list with what
each delivers — not issues already in the tracker.

#### 3.3.3 What is not designed

**How fine is too fine.** *"Many small issues, not a couple with 14-point checklists"* is a
stated preference, and the boundary is not defined. It belongs in the operating agreement as a
work-size clause once first use produces examples.

**The boundary against [m20](m20-arc-decomposition.md).** m20 sequences an arc's issues at
kickoff; obligation 2 decomposes a single idea or spec at any point. They overlap when the
idea being decomposed *is* the arc, and which owns that case is unsettled.

**Whether decomposition proposes its own arc.** A large enough idea is an arc rather than a
set of issues. Camp does not currently make that call.

### 3.4 Obligation 3 — catching problems at the moment they happen

```mermaid
flowchart TB
    subgraph R1[" Moments a hook can see "]
        direction LR
        E1["A session's<br/>first edit"] --- E2["A branch<br/>is created"] --- E3["A PR<br/>is opened"] --- E4["An issue<br/>is created"]
    end
    subgraph R2[" Only visible in the conversation "]
        direction LR
        E5["Discussion has<br/>gone too deep"] --- E6["A standing correction<br/>is being repeated"]
    end
    subgraph R3[" What Camp does "]
        direction LR
        C{"Something wrong<br/>the user has<br/>not flagged?"} -->|no| S["Stay silent"]
        C -->|yes| N["<b>Camp here —</b><br/>names it,<br/>offers the fix"] --> U(["<b>User</b><br/>decides"])
    end
    R1 --> R3
    R2 --> R3
    classDef n fill:#1e3a5f,stroke:#4a9eff,color:#fff
    classDef u fill:#3d2b4f,stroke:#b07fd6,color:#fff
    classDef q fill:#2b2b3d,stroke:#6b6b8a,color:#c9c9d4
    class E1,E2,E3,E4,E5,E6,C,N n
    class U u
    class S q
    style R1 fill:#0d1b2a,stroke:#2c4a6b,color:#8fb8e0
    style R2 fill:#0d1b2a,stroke:#2c4a6b,color:#8fb8e0
    style R3 fill:#0d1b2a,stroke:#2c4a6b,color:#8fb8e0
```

The originating expectation:

> *"[unsolicited, Camp writes to me] Hey, Camp here, I see you're about to start an issue
> (without an arc), do you want me to check for other related issues?"* — 2026-08-18

**Camp notices a situation the user has not flagged, and says so before it becomes a problem.**
The example is the shape: a condition is observable at a specific moment, the user has not
noticed it, and mentioning it then costs far less than discovering it later.

Most such moments are identifiable and therefore hookable. Continuous observation is required
by a minority of cases.

| Moment | Catches | Continuous? |
|---|---|---|
| First edit of a session | No arc, no issue, no branch | No — one check |
| Branch creation | Branch does not match the arc convention | No — event |
| PR open | Milestone missing, prefix missing, base wrong | No — event |
| Issue creation | A title promising more than it delivers | No — event |
| After a tool call | Work reached a capture point | No — hookable |
| **Questioning gone too deep** | The relief valve ([3.6](#36-the-relief-valve--a-skill-now-an-agent-later)) | **Yes** |
| **A standing correction being repeated** | The agreement's clauses | **Yes** |



**Five of seven are events**, costing nothing until they fire and carrying most of the value.
The remaining two concern the **shape of the dialogue** rather than repository state: a hook
observes tool calls and cannot observe that three clarifying questions have been answered
without a decision landing.

#### 3.4.1 The conversational half — a skill with a mechanical precondition

**Stated limitation:** the relief valve ([3.6](#36-the-relief-valve--a-skill-now-an-agent-later)) fires when the agent has gone too deep, so a skill the
agent must invoke is self-detection. Failure to notice is the condition being addressed.

**Built regardless.** A skill is a named check with criteria run at a defined moment, rather
than a standing obligation to be self-aware — converting *"should this have been noticed"*
into *"was the check run"*, the same conversion `work-watch` performs. It degrades safely:
firing produces value, missing leaves current behaviour unchanged.

**The precondition is [m41](m41-relief-valve.md)'s**, not a second one. It counts turns since
the last write, questions with no artifact changed, time in an issue with no checklist
movement, and emphasis markers in the user's messages — with provisional thresholds specified
there and replaced with mined evidence by
[#36](https://github.com/Calyx-Engineering/arc/issues/36).

**One precondition serves both mechanisms.** m41 asks whether the depth is excessive;
obligation 0 asks whether the work still serves the arc. No second trigger, no second
over-firing budget.

Mechanical trigger, judged response. **The skill catches the cases the agent is capable of
noticing; the agent — later — catches the ones it is not.**

---

### 3.5 Obligation 4 — an audit trail in conversation

```mermaid
flowchart TB
    subgraph R1[" An artifact finishes its work "]
        direction LR
        A["A hook runs,<br/>a skill completes,<br/>a PR is opened"] --> B["It declares what<br/>it checked and<br/>what it skipped"]
    end
    subgraph R2[" Two destinations, one unconditional "]
        direction LR
        C{"Verbosity<br/>setting"} -->|"loud or normal"| D["<b>Camp here —</b><br/>said in the<br/>conversation"]
        C -->|quiet| E["Nothing said"]
        B ==> F[("Written to the<br/>event log either way")]
    end
    B --> C
    classDef n fill:#1e3a5f,stroke:#4a9eff,color:#fff
    classDef q fill:#2b2b3d,stroke:#6b6b8a,color:#c9c9d4
    classDef l fill:#1f3d2b,stroke:#4caf70,color:#fff
    class A,B,C,D n
    class E q
    class F l
    style R1 fill:#0d1b2a,stroke:#2c4a6b,color:#8fb8e0
    style R2 fill:#0d1b2a,stroke:#2c4a6b,color:#8fb8e0
```

Each completed action is announced in Camp's voice, producing a running record of Arc's
operation in the conversation itself.

**The artifact speaks; Camp does not narrate it.** The one that ran the checks already holds
what it checked and what it skipped, so it reports in Camp's voice rather than handing the
result to something else to announce.

**Reports default to `normal`, nudges to `loud`** (see *Verbosity*). Defaults start visible
because a user new to Arc needs to observe it operating; reducing verbosity is a later
adjustment.

---

### 3.6 The relief valve — a skill now, an agent later

```mermaid
flowchart TB
    subgraph R1[" Countable signals, checked as work runs "]
        direction LR
        S1["8 turns with<br/>nothing written"] --- S2["3 questions, no<br/>artifact changed"] --- S3["45 min, no<br/>checklist movement"]
    end
    subgraph R2[" Or, on its own "]
        direction LR
        S4["Caps, bolded corrections,<br/>profanity, sharply<br/>shorter replies"]
    end
    R1 -->|"any two"| C{"Does the work still<br/>serve the arc?"}
    R2 -->|"any one"| C
    C -->|yes| L["<b>Light</b> — name the depth,<br/>offer a checkpoint"]
    C -->|no| H["<b>Strong</b> — name the drift,<br/>offer the way back"]
    classDef n fill:#1e3a5f,stroke:#4a9eff,color:#fff
    class S1,S2,S3,S4,C,L,H n
    style R1 fill:#0d1b2a,stroke:#2c4a6b,color:#8fb8e0
    style R2 fill:#0d1b2a,stroke:#2c4a6b,color:#8fb8e0
```

**What ships:** a skill the main thread runs when [m41](m41-relief-valve.md)'s precondition
trips. The precondition counts four signals:

| Signal | Threshold |
|---|---|
| Turns since the last commit or file write | 8 |
| Questions asked with no artifact changed | 3 |
| Minutes in one issue with no checklist movement | 45 |
| Emphasis markers in the user's messages — caps, bolded corrections, profanity, sharply shorter replies | any |

**Two of the first three fire the check; an emphasis marker fires it alone.** The skill then
asks whether the work still serves the arc, and nudges light or strong on the answer.

Thresholds are provisional and specified in [m41](m41-relief-valve.md); mined evidence
replaces them via [#36](https://github.com/Calyx-Engineering/arc/issues/36).

**What it cannot do:** notice when the agent is too deep to notice. A skill the agent must
invoke is self-detection, and failing to notice is the condition being detected. The
mechanical precondition limits how much this matters — the check fires on countable signals
rather than on self-awareness — but it does not remove it.

| | Detects depth | Cost |
|---|---|---|
| **Ships now** — a skill on a mechanical precondition | What the main thread is capable of noticing | Per fire |
| **Deferred** — an observer independent of the main thread | Also what it is not | Continuous conversation reading |

**The deferred form is better because it is outside the stuck conversation:**

> *"**Camp here —** I see what you and Claude are doing. We might want to step back."*

That removes the conflict of interest rather than asking the agent to overcome it — and
independence is exactly the expensive property, requiring continuous reading of both sides of
every turn.

**Neither form blocks.** Direction sets the nudge's strength, not whether it fires — specified
under [obligation 0](#when-it-fires).

---

## 4 Form — documents, skills, and hooks

**Revised 2026-08-18.** An earlier draft chose "an agent" because a personality felt like an
agent thing. Evaluating each obligation against whether it actually requires one relocated
most of Camp:

| Obligation | What it needs | Agent? |
|---|---|---|
| 0 — hold the arc's intent | Read the `arc-log`'s intent, evaluate proposed work | **No.** A skill reading files |
| 1 — where the arc stands and what is next | Read `arc-log`, handoff, issues | **No.** A skill |
| 2 — decompose an idea | Judgement against the record | **No.** An invoked skill |
| 3 — catch problems as they happen | **Continuous observation** | **The only one that does** |
| 4 — report what happened | Speak when an artifact completes | **No.** The artifact speaks |

**The personality is a document. The capabilities are skills. Only the watching is an agent.**

### 4.1 Cost model

Invocation cost is input tokens plus output tokens. Input dominates for any process reading
every turn: an observer of the main conversation consumes both sides of every message
continuously while producing output only occasionally.

Continuous observation is therefore the only form that cannot be afforded by default, and it
is required by obligation 3 alone.

### 4.2 What Camp is, concretely

| | Form | Cost |
|---|---|---|
| Identity | `voice.md` + the operating agreement | Free |
| Obligations 0 and 1 | Skills, invoked | Per use |
| Obligation 2 | A skill, invoked | Per use |
| Obligation 4 | The artifact speaks in Camp's voice | Free |
| Obligation 3, event half | Hooks | Free until they fire |
| Obligation 3, conversational half | A skill now, an agent later | Bounded |

### 4.3 The relocation preserves the role

**The implementation changes; the interface does not.** All three properties that constitute
an assistant persist, each in its own artifact:

| Property | Artifact | Authority |
|---|---|---|
| **Personality** | `voice.md` — register, prefix rule, length | Settings |
| **Obligations** | `operating-agreement.md` — what Camp will do | **The user's** |
| **Memory** | `notes.md` — what Camp learned about this repo | Camp's own |

**Obligations and memory are distinct and must not be conflated.** What Camp is required to do
is user-owned; what Camp has learned is Camp's own. Merging them would let learning silently
alter obligations, which is the failure the agreement exists to prevent.

Camp is the main thread operating under a defined persona. **A persona backed by committed
documents is more consistent than a resident agent would be**: an agent's memory terminates
with its session, whereas `notes.md` persists and is readable, diffable and correctable.

**The one property genuinely lost is independent observation** — a process watching the
conversation that is not the agent itself. It is required only by the relief valve ([3.6](#36-the-relief-valve--a-skill-now-an-agent-later)), and is
deferred on cost rather than rejected.

### 4.4 Forms considered

| Form | Verdict |
|---|---|
| **Documents + skills + hooks** | **Chosen.** The identity is committed files; the capabilities are invoked skills; the watching is event hooks |
| A resident agent | **Deferred, not rejected.** Only the conversational watching needs one, and continuous reading is the expensive case |
| The spine window | **Superseded.** The right responsibility, bound to the wrong thing — see *Orchestration is bound to a window*. Camp keeps the role and drops the window |

**Camp owns no arc state.** [m15](m15-handoff-spine.md) owns the handoff,
[m17](m17-k1-upkeep.md) owns the logs, [m21](m21-arc-tree.md) owns the tree. Camp reads them,
and invokes them at the moments they are due — but authors none of them. **The moment Camp holds state it is the spine window again under a new name** — and
inherits the fragility it was built to remove.

---

## 5 Camp owns three artifacts, and only two are governed

The defining structural decision. `voice.md` holds settings; the two below define the
relationship between Camp and the user. [m44](m44-event-log.md)'s event log is plugin-level
and not Camp's.

| | **Operating agreement** | **Camp's notes** |
|---|---|---|
| Holds | What Camp will do, and how | What Camp has learned about this repo |
| Authority | **The user's.** Camp proposes; the user approves | Camp's own |
| Changed by | A reviewed diff | Camp, freely |
| Committed | Yes | Yes |
| If they conflict | **The agreement wins** | — |

**Camp never silently revises its own obligations.** User feedback is ingested as a *proposed
amendment*: Camp drafts the change, presents the diff, and the user approves it.

Example: *"stop poking me so much"* produces a proposed amendment to the unsolicited-behaviour
clause, not an immediate behaviour change.

**Camp's authority derives from reading the record, not from private memory.** This is the
property that makes the persona trustworthy rather than confidently wrong.

### 5.1 The operating agreement

#### 5.1.1 The agreement is where Arc deviates from stock

Arc's mechanisms encode what is **common across projects**. The agreement encodes what is
**specific to one repository** — the documented deviation from the shipped default.

> *"here is what the default matured version of Arc does, but it doesnt match my exact
> needs, so i'm tuning its operation."*

**Camp is the user-facing surface of that tuning**, and the agreement is where a deviation is
recorded rather than re-explained each session.

#### 5.1.2 Sections

| Section | Holds |
|---|---|
| **Register and verbosity** | Colleague · terse · character, and how loud |
| **What Camp does unasked** | The triggers for obligations 3 and 4 |
| **Work size and shape** | Issue granularity, *and* the form work takes — checklist versus prose, table versus paragraph |
| **Response shape** | Where long is wanted, where short |
| **Standing corrections** | Things not to repeat — see below |

**Shape is not a subset of size.** A preference for many small issues and a preference for
checklists over narrative are both deviations from the default and both belong in this
section.

#### 5.1.3 Standing corrections — Camp watches for the uncommon ones

This clause type is what makes Camp more than an interface.

> *"i've found i'm constantly applying corrective nudges and guidance to claude … but if
> [memories] work so well, then why do i keep running into the same issue?"*

**Memory is retrieval, and retrieval is probabilistic** — a remembered correction surfaces only
when something cues it. An agreement clause is read deliberately before acting.

| | Handles |
|---|---|
| **Arc's mechanisms** | What is common across every project |
| **The agreement's standing corrections** | What is specific to this repo, this person, this work |

A correction given in conversation is captured as a clause, and **Camp watches for its
recurrence** — the correction outliving the session in which it was given. Equivalent in
content to the handoff's *do not* section, but permanent rather than arc-scoped.

#### 5.1.4 What tuning sounds like

Real examples, verbatim in shape:

- *"i'd like long responses here, short there"*
- *"stop poking me so much"*
- *"our issues should cover very small things — many small issues, not a couple with
  14-point checklists"*

Each is a durable preference about how work runs in **this** repo. None is a fact about the
product.

#### 5.1.5 The default agreement governs

Arc ships a **populated** agreement, not a template — a blank one leaves Camp without
obligations until the user writes them, making the first session useless. The default governs
from install and is amended as needed.

**Known risk, noted rather than solved:** an unread default silently governing. Mitigated by a
rule Camp applies to itself.

> **Camp must be able to answer *"why are you doing this?"* with the clause it is acting
> under.** If it cannot name one, it should not be acting.

Camp applies this test irrespective of whether the user asks. An action with no clause behind
it is improvisation, which is the failure the agreement exists to prevent.

### 5.2 Camp's notes — what belongs in `notes.md`

Observations about **this repository** that make Camp's future answers better, and that are
not obligations.

| Belongs | Does not |
|---|---|
| Where this repo keeps things that Arc's defaults do not predict | A preference about how Camp should behave — that is an amendment |
| Which checks have been noisy here | A fact about the product — that graduates to the wiki |
| Recurring shapes in how work runs in this repo | Anything the `arc-log` or a `dev-log` already records |

**The distinguishing test: does acting on it change what Camp is obliged to do?** If yes, it
is a proposed amendment to the agreement and requires approval. If it only makes an existing
obligation better-informed, it is a note and Camp writes it freely.

Notes are committed and diffable, so an incorrect note is visible and correctable rather than
silently shaping behaviour.

### 5.3 Where it lives

```text
.claude/arc/
└── camp/
    ├── operating-agreement.md  ← what Camp will do.        User-owned; amended by approved diff
    ├── voice.md                ← register, prefix, length. Settings
    └── notes.md                ← what Camp learned here.   Camp-owned
```

[m44](m44-event-log.md)'s event log sits beside `camp/` at `.claude/arc/log.md`, not within
it — it records what every Arc artifact did, not what Camp did.

**Agent space, not `docs/`.** These are configuration files a human reviews, not documentation
a human navigates — the same rationale that places the concern index in agent space. Committed
and diffable.

**Namespaced under `arc/`** so Lodestar's Star and Bench get their own without collision.

### 5.4 Cross-pollination

An agreement clause proven in one repository graduates to the plugin default as a reviewed
change, never as accumulated behaviour. This is the same promotion path as every other durable
fact in Arc.

---

## 6 Voice

The voice has one function: **make Arc's operation visible without becoming noise.** That
constraint governs the decisions below more than personality does.

### 6.1 The prefix marks unsolicited speech

**`**Camp here —**` when speaking unprompted. No prefix when answering.**

A response to a direct question needs no attribution. Unprompted speech does: the prefix marks
it as distinct from the main thread's own output, and bold weight makes it visible inside a
long working passage.

```text
[unsolicited]  **Camp here —** PR #33 opened. Milestone set, arc-03 prefix, Closes #27 bound.

[you asked]    Arc 03 has three issues. #27 is scoping Camp — you are in it now.
```

### 6.2 Length

| | |
|---|---|
| A report | **One line** |
| An answer | **Three or four** |
| Anything not asked for | **Nothing** |

**Failure mode: Camp becoming a second narrator** competing for the same attention. Camp
reports what occurred; it does not explain, expand, or instruct unless asked.

### 6.3 Register — colleague

Three were considered:

| Register | Sounds like |
|---|---|
| Terse operator | *"PR #33 opened. Milestone set, keywords bound."* |
| **Colleague** ← | *"PR #33 is up — milestone's set and the keywords bound this time."* |
| Character | *"Camp here. Got #33 out the door, and the links actually took."* |

**Colleague is selected.** Terse reads as a log line rather than a party, forfeiting the
delegation the persona exists to support. Character costs reader attention on every utterance.

**The register is a value in the operating agreement, not code.** Changing it is an amendment,
making it inexpensive to trial all three during first use and select on evidence.

---

## 7 Verbosity — three levels, two settings

**All events are recorded regardless of setting**, in [m44](m44-event-log.md)'s event log.
Verbosity governs what surfaces in conversation, never what is retained; reducing it loses no
information.

| Level | Shows |
|---|---|
| **loud** | The machinery. What was checked, what passed, what was declared but skipped |
| **normal** | The outcome only |
| **quiet** | Silence unless something is wrong |

```text
loud     **Camp here —** PR #33 opened.
           Checked: milestone, arc prefix, closing keywords — all set
           Declared but skipped: placeholder scan (no body edit)

normal   **Camp here —** PR #33 opened. Milestone and keywords set.

quiet    (nothing)
```

### 7.1 Two settings, not one

Reports and unsolicited nudges are different kinds of noise.

| | Default |
|---|---|
| **Reports** — obligation 4 | `normal` |
| **Nudges** — obligation 3 | `loud` |

A nudge fires because a condition appears wrong and should be hard to miss. A report fires on
every completion and should be brief.

**Finer control is an amendment, not a fourth level.** Per-artifact suppression — *"no reports
for PR generation"* — is an agreement clause rather than an extension of the level scheme.

---

## 8 Suppressed output is still recorded — [m44](m44-event-log.md)

Verbosity governs what is displayed. It must not govern what is retained: at `quiet`, nothing
would survive a session.

**That record is [m44](m44-event-log.md), the event log** — a plugin-level artifact recording
every Arc artifact's firing, written regardless of verbosity. Camp's reporting is what
surfaced the need for it, and Camp declares its own events into it like any other artifact.

```mermaid
flowchart LR
    ART["Any Arc artifact<br/>does something"] --> EV["The event"]
    EV --> VB{"Verbosity"}
    VB -->|loud| CH1["Chat — the machinery"]
    VB -->|normal| CH2["Chat — the outcome"]
    VB -->|quiet| CH3["Chat — nothing"]
    EV ==>|"always, unconditionally"| LOG[("The event log —<br/>every firing, kept<br/>whatever the setting")]
    classDef n fill:#1e3a5f,stroke:#4a9eff,color:#fff
    classDef l fill:#1f3d2b,stroke:#4caf70,color:#fff
    class ART,EV,VB,CH1,CH2,CH3 n
    class LOG l
```

**Verbosity gates the left branch only.** The right branch is unconditional, which is what
makes turning the volume down safe.

**Camp does not own it and does not read it.** It records what *every* artifact did, and its
consumers are the retrospective, transcript mining, and the user reading manually. Obligation
0 evaluates direction against the `arc-log`'s stated intent, not history against the event log.

---

## 9 Invocation — how Camp is reached

### 9.1 Both: addressed in prose, and `/camp`

Prose for conversational use — *"Camp, where are we?"* — and a slash command where the entry
point must be unambiguous.

### 9.2 Claude delegates when the answer comes from the record

**Target state:** Camp handles questions *about* the work; the main thread performs the work.
State, shape, sequence and prioritisation route to Camp; code, files and execution route to
the main thread. Because Camp answers from the record, its answers survive session turnover.

**Initial implementation is a single rule:**

> **Claude delegates when the answer comes from the record rather than from the
> conversation.**

| Camp | Claude |
|---|---|
| Where are we · what did we decide · what is next | What does this function do |
| Does this belong in this arc · is this issue too big | Fix this · write this |

**Fails safe.** Under uncertainty the main thread answers and notes that Camp could have. A
misrouted question is immediately visible.

**Deferred:** Camp determining unprompted *conversational* intervention. Obligation 3's event
triggers are specified and ship in the first pass; the continuous half does not.

---

## 10 Completeness of each part

What is fully specified, what ships knowingly partial, and what is deferred. **Delivery
sequencing is roadmap and lives in the tracker, not here.**

| Part | State |
|---|---|
| `voice.md` · operating agreement · `notes.md` | **Specified.** The identity; nothing operates without it |
| Obligation 0 — hold the arc's intent | **Specified** |
| Obligation 1 — where the arc stands, and what is next | **Specified** |
| Obligation 2 — decompose an idea | **Partial.** The loop is specified; its judgement calls are not |
| Obligation 3, event half | **Specified.** Hooks on identifiable moments |
| Obligation 3, conversational half | **Partial by design.** A skill on countable signals, limited as stated in [3.6](#36-the-relief-valve--a-skill-now-an-agent-later) |
| Obligation 4 — report per the agreement | **Specified** |
| The monitoring agent | **Deferred.** Continuous conversation reading is the one unaffordable form |

**Two parts ship knowingly incomplete**, and both say so where they are specified rather than
only here. An incomplete mechanism that fires is worth more than a complete one that does not
exist — but only if its limits are stated, because a partial mechanism trusted as complete is
worse than none.

---

## 11 Backlog — Camp runs onboarding

> **Onboarding is [m47](m47-onboarding.md).** Camp is its voice, not its owner — it writes
> repository instructions, registers hooks and points at the mechanism registry, which are
> other mechanisms' concerns. What follows is Camp's part.

**Not in scope; recorded so it is not lost.** When Arc is first installed in a repository,
Camp could walk the user through configuring it — the operating agreement, the register, the
verbosity level, whether the default-branch flip is available.

**Camp's first useful act being to configure itself is the clearest possible demonstration of
obligation 0.** It also puts the m42 warning in front of the user at the moment it matters.

**Deferred past the first pass**, not abandoned — obligation 0 ships without it.

**What it would carry:**

| | |
|---|---|
| Pick the register | Colleague, terse, or character — trying all three is how the choice gets made on evidence |
| **Import an agreement from another repo** | Where tuning has already happened, rather than starting from stock again. This is cross-pollination at install time instead of at graduation |

---

## 12 What is not designed

**Obligation 3's over-firing budget.** The event half and `work-watch`'s three proposing
checks share one threshold, and nothing sets it. First use produces the number. Its fourth
check — edit completeness — is exempt: it fires on an act, not a pause.

**The relief valve's real triggers.** The shipped signals are plausible guesses, not
evidence. [#36](https://github.com/Calyx-Engineering/arc/issues/36) mines three repositories
for what was countable *before* the frustration surfaced.

**Whether Camp speaks for `work-watch`.** `work-watch` does the noticing; Camp may be the
voice. One voice, several sources — attractive, unproven.

**Obligation 2's judgement calls.** The loop is specified; how fine an issue should be, and
the boundary against [m20](m20-arc-decomposition.md), are named as undesigned in
[3.3.3](#333-what-is-not-designed).

---

## 13 Related

- [m21](m21-arc-tree.md) — the tree Camp renders
- [m41](m41-relief-valve.md) — Camp as the third party
- [m15](m15-handoff-spine.md) · [m17](m17-k1-upkeep.md) — the record Camp reads and never owns
- [m25](m25-agent-roster.md) — the roster Camp's deferred monitoring agent would join
- [m44](m44-event-log.md) — the event log Camp's verbosity makes necessary
- [m46](m46-work-navigation.md) — where a discovery goes; obligation 0 decides whether it belongs in this arc at all
