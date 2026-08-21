# Arc: Camp, and the tracker fixes

> **Arc log** — the spine above the per-issue [dev-logs](../dev-log/). It holds what spans
> issues: why this arc exists, what was decided once and applies throughout, and where the
> work stands.

**Milestone:** [Arc 03 — Camp and the linking fix](https://github.com/Calyx-Engineering/arc/milestone/4) · **Branch:** `arc/03-camp` · **Started:** 2026-08-18

---

## 1 In one minute

**Camp is the spine window made portable** — the role that holds an arc's plan and tracks
which issue is active, backed by committed documents instead of a VS Code window that has to
stay open.

| | |
|---|---|
| **New issues** | [#39](https://github.com/Calyx-Engineering/arc/issues/39)–[#47](https://github.com/Calyx-Engineering/arc/issues/47), nine of them, plus [#48](https://github.com/Calyx-Engineering/arc/issues/48) last. Four more spawned during execution — see the tree |
| **Already filed** | [#37](https://github.com/Calyx-Engineering/arc/issues/37) the event log · [#31](https://github.com/Calyx-Engineering/arc/issues/31)–[#35](https://github.com/Calyx-Engineering/arc/issues/35) tracker mechanics · [#55](https://github.com/Calyx-Engineering/arc/issues/55) · [#56](https://github.com/Calyx-Engineering/arc/issues/56) spawned mid-arc |
| **Build order** | See §10 *Status — execution order*. Numbered 1–23; **22 is vacant** — [#73](https://github.com/Calyx-Engineering/arc/issues/73) left the arc and took step 6.2 with it |
| **Autonomous** | Every wave. The modes are defined in §6 and assigned in §10.1. **Breaks at wave boundaries are context, not approval** |
| **Not in this arc** | The monitoring agent · onboarding · mined thresholds |

**The one thing to check:** the spec-to-issue table below. Every section of m43 appears
exactly once, so a gap there is a feature nobody is building.

---

## 2 Why this arc exists

Arc's workflow depends on one VS Code window holding the plan and tracking which issue is
active. That window is fragile — close it, switch branches, or move to another repo and the
orchestration is gone.

**Camp is that role, made portable.** The same job, held by an addressable persona backed by
committed documents instead of by a window that has to stay open.

Two failures follow from having no such role:

| | |
|---|---|
| **Work drifts from the arc's intent** | Every step looks reasonable; nothing holds the destination and tests proposed work against it |
| **Arc's operation is invisible** | A tool that cannot be observed cannot be evaluated — and produces no improvement signal |

**The bar:** Camp is what turns using Arc on real hardware work into an evaluation rather than
just use.

---

## 3 What the decomposition produced

Nine new issues, plus one already filed and five carried in from the tracker work spawned
during scoping.

```mermaid
flowchart TB
    subgraph F[" Foundation — nothing works without these "]
        direction LR
        I39["<b>#39</b><br/>The three documents<br/>agreement · voice · notes"] --> I40["<b>#40</b><br/>Reach Camp<br/>by name or /camp"]
    end
    subgraph O[" The obligations — what Camp is relied on to do "]
        direction LR
        I41["<b>#41</b> · ob 1<br/>Where the arc stands,<br/>and what comes next"]
        I42["<b>#42</b> · ob 0<br/>Test work against<br/>the arc's intent"]
        I47["<b>#47</b> · ob 2<br/>Decompose an idea<br/>into issues"]
    end
    subgraph S[" Speaking — unasked, and about what it did "]
        direction LR
        I43["<b>#43</b> · ob 3<br/>Four hooks on<br/>detectable moments"]
        I44["<b>#44</b><br/>Relief valve —<br/>a way out of depth"]
        I45["<b>#45</b> · ob 4<br/>Announce completed<br/>actions"]
    end
    subgraph R[" The record and its volume "]
        direction LR
        I37["<b>#37</b><br/>Event log —<br/>survives quiet"] --> I46["<b>#46</b><br/>Verbosity —<br/>3 levels, 2 settings"]
    end
    F --> O
    F --> S
    R --> S
    classDef n fill:#1e3a5f,stroke:#4a9eff,color:#fff
    class I39,I40,I41,I42,I43,I44,I45,I46,I47,I37 n
    style F fill:#0d1b2a,stroke:#2c4a6b,color:#8fb8e0
    style O fill:#0d1b2a,stroke:#2c4a6b,color:#8fb8e0
    style S fill:#0d1b2a,stroke:#2c4a6b,color:#8fb8e0
    style R fill:#0d1b2a,stroke:#2c4a6b,color:#8fb8e0
```

---

## 4 Every spec section, and the issue that delivers it

**Read this table to check nothing was dropped.** Every numbered section of
[m43](../product-architecture/mechanisms/m43-camp-assistant.md) appears exactly once.

| m43 § | What it defines | Issue |
|---|---|---|
| §2 · §6 | The persona, its voice, how it is reached | [#40](https://github.com/Calyx-Engineering/arc/issues/40) |
| §3.1 | **The intent check** — hold the arc's intent, the authority ladder | [#42](https://github.com/Calyx-Engineering/arc/issues/42) |
| §3.2 | **Status and flow** — status, and the close/start sequence run the same way every time | [#41](https://github.com/Calyx-Engineering/arc/issues/41) |
| §3.3 | **Decomposition** — decomposition | [#47](https://github.com/Calyx-Engineering/arc/issues/47) |
| §3.4 | **The nudge** — the event half, four hooks | [#43](https://github.com/Calyx-Engineering/arc/issues/43) |
| §3.5 | **The report** — announcing completed actions, and the templates that make future artifacts do the same | [#45](https://github.com/Calyx-Engineering/arc/issues/45) |
| §3.6 | The relief valve — the conversational half | [#44](https://github.com/Calyx-Engineering/arc/issues/44) |
| §5 | The three documents and their ownership | [#39](https://github.com/Calyx-Engineering/arc/issues/39) |
| §7 | Verbosity — three levels, two settings | [#46](https://github.com/Calyx-Engineering/arc/issues/46) |
| §8 · [m44](../product-architecture/mechanisms/m44-event-log.md) | The event log, independent of verbosity | [#37](https://github.com/Calyx-Engineering/arc/issues/37) |
| §11 | Onboarding | **Backlogged** — not this arc |
| §12 | Named gaps | **Open by design** — see below |
| — | Repo hygiene: shipping skills match their local copies | [#48](https://github.com/Calyx-Engineering/arc/issues/48) |

### 4.1 Carried in from scoping

Five issues spawned by friction observed while writing the spec. Tracker mechanics, not Camp —
classified *escalate* under the intent check's own ladder, and correct to do. **Scheduled as wave
5**, issues 11 through 15.

Two more were spawned later, by the work itself — see below.

| Issue | |
|---|---|
| [#31](https://github.com/Calyx-Engineering/arc/issues/31) | Say what a branch or setting **is** when naming it |
| [#32](https://github.com/Calyx-Engineering/arc/issues/32) | Size an issue title to what merging delivers |
| [#33](https://github.com/Calyx-Engineering/arc/issues/33) | A repeatable loop for scoping an involved piece of work |
| [#34](https://github.com/Calyx-Engineering/arc/issues/34) | Numbered questions in a multi-topic reply |
| [#35](https://github.com/Calyx-Engineering/arc/issues/35) | Keep the issue checklist current as working state |

**What each of these traces to is §9**, beside the execution order.

### 4.2 Spawned during execution

**Found by building the arc, not by planning it.** Each names the issue whose work exposed it.
[#55](https://github.com/Calyx-Engineering/arc/issues/55) and [#56](https://github.com/Calyx-Engineering/arc/issues/56)
are tracker and document mechanics, so they join wave 5. The three below block work in progress
and are scheduled where they are needed.

```mermaid
flowchart LR
    I45["<b>#45</b><br/>announce completed actions"] -->|"its own PR bound a link<br/>its keyword did not ask for"| I55["<b>#55</b><br/>reject a stray<br/>closing keyword"]
    I39["<b>#39</b><br/>Camp's three documents"] -->|"review found the agreement<br/>restating the spec"| I56["<b>#56</b><br/>strip the agreement<br/>to actionable clauses"]
    I60["<b>#60</b><br/>the arc's approval mode"] -->|"writing the handoff<br/>exposed the gap"| I61["<b>#61</b><br/>handoff omits ordered<br/>actions + transcript save"]
    I60 -->|"four partial edits<br/>reported as complete"| I62["<b>#62</b><br/>edit reported done<br/>unchecked elsewhere"]
    classDef p fill:#1e3a5f,stroke:#4a9eff,color:#fff
    classDef c fill:#4a3520,stroke:#d98f2b,color:#fff
    class I45,I39,I60 p
    class I55,I56,I61,I62 c
```

| Issue | | Spawned by | Why it exists |
|---|---|---|---|
| [#55](https://github.com/Calyx-Engineering/arc/issues/55) | Reject a closing keyword written anywhere but a body's last line | [#45](https://github.com/Calyx-Engineering/arc/issues/45) | Its PR heading bound a link the body's `Refs` did not ask for. The trap is documented in `skills/issue-write`; no check derives from it |
| [#56](https://github.com/Calyx-Engineering/arc/issues/56) | Strip the operating agreement to clauses a user can act on | [#39](https://github.com/Calyx-Engineering/arc/issues/39) | Sections 1, 2 and 6 restated m43 — rationale a user cannot act on, in a document that exists to record deviation |
| [#60](https://github.com/Calyx-Engineering/arc/issues/60) | State the arc's approval mode and where a window breaks | The stop review | The plan named no mode the arc actually ran in, and said nothing about surviving one context window. **Wave 2.3** |
| [#61](https://github.com/Calyx-Engineering/arc/issues/61) | The handoff omits the next session's ordered actions and the transcript save | [#60](https://github.com/Calyx-Engineering/arc/issues/60) | `skills/handoff` says nothing about the prompt that starts the next chat, so the prompt duplicated the handoff. **Wave 3.1** |
| [#62](https://github.com/Calyx-Engineering/arc/issues/62) | An edit is reported done without checking everywhere the claim appears | [#60](https://github.com/Calyx-Engineering/arc/issues/60) | One claim lives in a table, a diagram label and a summary row. Editing one and reporting done left the others contradicting it, four times consecutively. **Wave 2.4** |

---

## 5 Build order

Dependency, not value. **The most valuable issue is frequently the one that cannot start.**

```mermaid
flowchart TB
    subgraph A[" Autonomous — waves 1 and 2 "]
        direction LR
        W1["<b>Wave 1</b><br/>1 · #39 documents<br/>2 · #37 event log"] --> W2["<b>Wave 2</b><br/>3 · #40 reach Camp<br/>4 · #45 announce + templates<br/>5 · #60 plan modes<br/>6 · #62 edit verification"]
    end
    A ==> STOP{{"<b>STOP</b><br/>human review<br/>before wave 3<br/><i>cleared 2026-08-19</i>"}}
    subgraph B[" Autonomous — waves 3 to 6 "]
        direction LR
        W3["<b>Wave 3</b><br/>7 · #61 · 8 · #41<br/>9 · #44 · 10 · #47<br/>11 · #43 · 12 · #46"] --> BR3{{"<b>BREAK</b><br/>new window<br/>handoff written"}}
        BR3 --> W4["<b>Wave 4</b><br/>13 · #42<br/>the intent check"]
        W4 --> BR4{{"<b>BREAK</b><br/>new window<br/>handoff written"}}
        BR4 --> W5["<b>Wave 5</b><br/>14–20 · #31–#35<br/>#55 · #56"]
        W5 --> BR5{{"<b>BREAK</b><br/>new window<br/>handoff written"}}
        BR5 --> W6["<b>Wave 6</b><br/>21 · #48 · 23 · #78<br/>parity, work nav"]
    end
    STOP ==> B
    classDef n fill:#1e3a5f,stroke:#4a9eff,color:#fff
    classDef s fill:#4a3520,stroke:#d98f2b,color:#fff
    class W1,W2,W3,W4,W5,W6 n
    class STOP,BR3,BR4,BR5 s
    style A fill:#0d1b2a,stroke:#2c4a6b,color:#8fb8e0
    style B fill:#0d1b2a,stroke:#2c4a6b,color:#8fb8e0
```

**Why the intent check is late despite being the priority.** It cannot evaluate direction without
knowing where work stands ([#41](https://github.com/Calyx-Engineering/arc/issues/41)), and its
fourth firing moment is the relief valve
([#44](https://github.com/Calyx-Engineering/arc/issues/44)). Building it first would mean
building it twice.

---

## 6 How this arc is executed

**Not only what gets built — how.** An arc run autonomously and an arc run beside a human are
different plans, and the difference belongs here rather than in a chat message.

**Three modes, and the difference is who reviews the wave's work.**

| Mode | Who reviews, and when |
|---|---|
| **Per step** | The user approves after each issue. They start it, Claude runs one issue, they review it |
| **Per wave** | The user approves at the end of the wave. They start it, Claude runs the wave, they review it in detail |
| **Autonomous** | Claude does not wait for approval. It runs the wave, and performs the review at the end of it |

**Which mode each wave runs in is recorded once, in §10.1** — beside the description of what
that wave is. It is not repeated here, because two tables of wave modes drift.

**Why this arc runs autonomously throughout.** The spec exists and the foundation was proven
at the stop, so execution does not need step-by-step approval.

**The stop is the point.** Sixteen issues run unattended ends in either a good arc or sixteen
PRs on a wrong foundation, and the second is not visible until it is expensive. The numbered
table under §10 *Status — execution order* marks where it is.

### 6.1 Autonomous mode — what it actually means

> **Manual is the default.** Autonomous is entered only by an explicit instruction from the
> user, or by the handoff naming it. Absent either, Claude proposes and waits for the user.

**In autonomous mode, Claude reads this arc-log whole** — not the section that looks relevant. The
§10 *Status — execution order* table is the work queue, and it is followed top to bottom.

**And the spec of the mechanism the issue traces to.** Every piece of work in this repo traces
back to a mechanism, and a fair number of those have a written spec. An issue's intent is not
recoverable from its own body when the body assumes that spec.

| | |
|---|---|
| **Where the mapping is** | §9 *What each issue traces to* — every issue in the arc, ordered by number |
| **Where the spec is** | [`docs/product-architecture/README.md`](../product-architecture/README.md)'s registry — the mechanism's row carries its spec link, or a dash where none exists |
| **When** | Once, when the issue is picked up. Not once per window, and not m43 by default |
| **A dash is not a gap to fill** | Read the artifacts the issue names instead |

**m43 is read whole only when the issue traces to it.** Wave 5 is what proves the point: eight
of its nine issues trace to m11, m12, m13, m38 or m45, and reading m43 for them costs a
thousand lines and returns nothing.

```mermaid
flowchart TB
    START["<b>/arc-next</b><br/>a new window, or<br/>called inside one"] --> MODE{{"<b>Which mode?</b><br/>the handoff's<br/><i>Execution mode</i> row"}}
    MODE ==>|"manual — the default"| MAN{{"<b>MANUAL</b><br/>Claude proposes,<br/>the user approves"}}
    MODE ==>|"autonomous"| READ["<b>Read the arc-log whole</b><br/>the execution order<br/>and this definition"]
    subgraph L[" One issue — read to merge "]
        direction TB
        ISSUE["<b>Take the next row</b><br/>read the issue from gh<br/>create the branch"] --> INTENT["<b>Intent and north star</b><br/>what the issue is really for,<br/>written into the dev-log<br/><i>before any plan exists</i>"]
        INTENT --> PLAN["<b>Plan</b><br/>the execution plan,<br/>in the dev-log,<br/>tested against the north star"]
        PLAN --> IMPL["<b>Initial pass</b><br/>fix the intent,<br/>not the symptom"]
        IMPL --> REF["<b>Refine · 4 passes</b><br/>every axis, every pass"]
        REF --> REV["<b>Review · 3 passes</b><br/>fixing what<br/>each pass finds"]
        REV --> PR["<b>Open the PR</b><br/>milestone + Closes"]
        PR --> FIN{{"<b>Final review</b><br/>all reasonable angles"}}
        FIN -->|"not clean"| REV
        FIN -->|"clean"| MERGE["<b>Claude merges the PR</b><br/>not the user"]
    end
    READ --> ISSUE
    MERGE --> NEXT{{"<b>Break point on<br/>the next row?</b>"}}
    NEXT -->|"no — take the next issue"| ISSUE
    NEXT ==>|"yes — stop the run"| BRK{{"<b>BREAK</b><br/>handoff written, mode cued<br/>50-word status, problems first"}}
    classDef n fill:#1e3a5f,stroke:#4a9eff,color:#fff
    classDef s fill:#4a3520,stroke:#d98f2b,color:#fff
    class START,READ,ISSUE,INTENT,PLAN,IMPL,REF,REV,PR,MERGE n
    class MODE,MAN,FIN,NEXT,BRK s
    style L fill:#0d1b2a,stroke:#2c4a6b,color:#8fb8e0
```

#### 6.1.1 One issue, start to merge

| | |
|---|---|
| 1 | **Read the issue from `gh`** — the one the execution order names, not the one that seems next |
| 2 | **Create the branch** |
| 3 | **Establish the issue's intent and its north star, in the dev-log — before any plan exists.** Two passes, below. A plan written first steers by the issue's wording instead |
| 4 | **Write the execution plan in the dev-log**, tested against the north star above |
| 5 | **Implement the initial pass** — fix the intent, not the symptom it happens to describe |
| 6 | **Refine four times** — the axes are below |
| 7 | **Final review, iterated three times**, fixing what each pass finds |
| 8 | **Open the PR** — the north star from step 3 goes in the body **verbatim**, so step 9 tests the diff against it rather than re-deriving it |
| 9 | **One more review, from every reasonable angle** — and against the north star in the body. If the diff does not reach it, the issue is not done |
| 10 | **Claude merges the PR** — not the user. Only when satisfied, everything resolved, everything clean |
| 11 | **Continue to the next row, or stop** — whichever the execution order says |

#### 6.1.2 Establishing the intent — two passes

**One pass produces a paraphrase of the title.** The second is where the intent appears.

| Pass | Reads | Writes into the dev-log |
|---|---|---|
| **1** | The issue body alone, and any verbatim quote it carries | The problem in one sentence, and a first north star |
| **2** | Every issue it links to, the spec of the mechanism it traces to, and every artifact it names | **What changed from pass 1** — and if nothing changed, that it did not |

**Not every mechanism has a spec.** The registry's *Spec* column carries a dash where none is written — m40 is the example. Pass 2 then reads the artifacts the issue names instead. An absent spec is not a gap to hunt for.

**The verbatim quote is the intent.** Where an issue carries one — most of this arc's do — the
north star is tested against the quote, never against the title.

**Fire `skills/arc-intent` here.** It classifies proposed work Agreed, Derived or Escalate
against the arc's stated intent, and this is its call site in the loop. An *escalate* is not a
stop; it is a thing to say plainly in the dev-log and in the PR body.

| The north star must | |
|---|---|
| **Say something the title does not** | A restatement means the issue was read, not understood |
| **Name what makes the fix durable** | What it has to survive — a reworded heading, a fresh session, a different repository |
| **Name what is out of scope** | Four refining passes will otherwise grow the work into whatever looks adjacent |

#### 6.1.3 The refining axes

**Read the dev-log before each pass** — the north star and the plan, as written, never as remembered. An axis answered from memory drifts with the work it is meant to check.

| |
|---|
| Does this reach the north star recorded in the dev-log? |
| Does this make skills or other artifacts larger than they should be? |
| Can it be trimmed without sacrificing performance? |
| Is there anything new that needs inventing to make this work better? |
| Have references to every modified file been checked? |
| Is it consistent with every file in the repo? |
| Are there other files that should be touched to make this work better? |
| Am I on topic? |
| Are there tests that need writing to evaluate this? |
| Have all evaluating tests been run? |

#### 6.1.4 Commit cadence

**Over-committing bloats the log and the tree.** Commit at least once for the plan, once for
the initial implementation, and once per refinement and review loop.

#### 6.1.5 At a break point

A break marked in the execution order **stops autonomous execution.** In order:

| | |
|---|---|
| 1 | Write the updated handoff |
| 2 | **Re-evaluate it** — it must cue the next `/arc-next` into **the mode §10.1 assigns the next wave**, not whatever mode this window happened to run in, and initialise enough state for the next window to continue from §10 |
| 3 | A status update of **50 words or less** on issues and merges, **leading with any problem** |

### 6.2 What is least certain, and why

| | |
|---|---|
| **Skills cannot be executed here** | Nothing in this repo runs a skill. A session writes one, checks it against the spec diagram, and marks it done — with no evidence it *behaves* right. True of every skill Arc has shipped |
| **The intent check is judgement** | *"Does this serve the arc's intent"* has no mechanical test. It will build; whether it fires usefully is unknown until used. §6.1.2 makes the autonomous loop fire it on every issue, which is the first real exercise it gets |
| **The relief valve's thresholds are estimates** | 8 turns, 3 questions, 45 minutes. Placed so the mechanism is buildable, corrected by [#36](https://github.com/Calyx-Engineering/arc/issues/36) |
| **The close sequence is unproven** | [#41](https://github.com/Calyx-Engineering/arc/issues/41)'s nine steps were written from informal practice. Executing it will find gaps the spec side could not see |
| **Degradation is observed, not forecast** | A session at this point lost the ability to follow direction: it went autonomous against instruction and reported an issue number that was never created. Recovery was the user escaping out. **Hand off at a wave boundary before the middle of a wave, not after** |

**Autonomy is per-arc, not per-repo** — m40. The mode above is this arc's, decided from how
specified the work is. **m40 has no spec file**; writing it is
[#73](https://github.com/Calyx-Engineering/arc/issues/73), which left this arc for the
*Onboarding — m47* milestone because its hard requirement is that the behaviour survive a
repository boundary.

**§6.1 is the interim stand-in, and it is arc-scoped.** It defines autonomous mode well enough
to run this arc and no further — it dies with the arc-log it lives in. Anything tracing to m40
reads §6.1 first and [#73](https://github.com/Calyx-Engineering/arc/issues/73) second.

---

## 7 Load-bearing decisions

Settled during scoping. **These apply across every issue in the arc.**

| | |
|---|---|
| **Camp is documents, skills and hooks — not an agent** | Continuous conversation reading is the one form Arc cannot afford. Only the nudge's conversational half needs it, and that half ships as a skill |
| **Camp owns no arc state** | m15 owns the handoff, m17 the logs, m21 the tree. Camp reads them and fires them; it authors none of them |
| **Obligations and memory never merge** | The agreement is what Camp must do (user-owned). Notes are what Camp learned (Camp's own). Merging them lets learning silently rewrite obligations |
| **The goal is user-owned** | Camp evaluates work against the arc's intent and cannot revise that intent |
| **Camp proposes; it never executes** | It names what is required. The main thread acts, after the user approves |
| **A fired precondition always nudges** | Direction sets the nudge's strength, never whether it speaks |
| **Verbosity governs display, never retention** | Everything reaches the event log regardless of setting |
| **Two mechanisms ship knowingly partial** | Decomposition, and the nudge's conversational half. Both state their limits where they are specified |
| **The obligations are named, not numbered** | *The intent check · status and flow · decomposition · the nudge · the report.* The numbers were m43 §3's insertion order — which is why the one that ranks first was called *obligation 0* — and a sixth numeric token competing with issue, mechanism and wave numbers helped nobody. The names are not new: `operating-agreement.md` already shipped three of them. Sections are still cited by number |

---

## 8 What is deliberately not in this arc

| | Why |
|---|---|
| **The monitoring agent** | Continuous conversation reading — the one unaffordable form. The relief valve degrades to a skill instead |
| **Onboarding** | Camp configuring itself at install. The intent check ships without it |
| **Mined relief-valve thresholds** | [#36](https://github.com/Calyx-Engineering/arc/issues/36), pass 2 — needs the transcript miner |
| **How fine an issue should be** | An operating-agreement clause once first use produces examples |

---

## 9 What each issue traces to

**Every issue in this repo traces back to a mechanism.** This table is what a session reads
before starting one — the spec to read is that mechanism's, and it is **m43's only when the
*Traces to* column says m43.** Wave 5 is what makes that worth stating: eight of its nine
issues trace elsewhere, and reading m43 for them costs a thousand lines and returns nothing.

**Ordered by issue number**, not by build order — the table below it is the build order. The
registry in [`docs/product-architecture/README.md`](../product-architecture/README.md) is the
authority for every mechanism's spec link.

| Issue | Delivers | Traces to | Where the spec is |
|---|---|---|---|
| [#27](https://github.com/Calyx-Engineering/arc/issues/27) | This spec and the decomposition | **m43** · **m44** | [m43](../product-architecture/mechanisms/m43-camp-assistant.md) whole — this issue produced it |
| [#31](https://github.com/Calyx-Engineering/arc/issues/31) | Say what a branch, file or setting is when naming it | **m38** `chat-response` · **m42** | [`skills/chat-response`](../../skills/chat-response/SKILL.md) · [m42](../product-architecture/mechanisms/m42-default-branch-flip.md) |
| [#32](https://github.com/Calyx-Engineering/arc/issues/32) | Size an issue title to what merging delivers | **m11** `issue-writing` | [`issue-writing`](../reference-roadz/issue-writing/SKILL.md) — the skill is its own spec |
| [#33](https://github.com/Calyx-Engineering/arc/issues/33) | A repeatable loop for scoping involved work | **m45** `spec-interview` | [`skills/spec-interview`](../../skills/spec-interview/SKILL.md) — the skill is its own spec |
| [#34](https://github.com/Calyx-Engineering/arc/issues/34) | Numbered questions in a multi-topic reply | **m38** `chat-response` | [`skills/chat-response`](../../skills/chat-response/SKILL.md) — the skill is its own spec |
| [#35](https://github.com/Calyx-Engineering/arc/issues/35) | Keep the issue checklist current as working state | **m13** issue write-back | [m13](../product-architecture/mechanisms/m13-issue-write-back.md) |
| [#37](https://github.com/Calyx-Engineering/arc/issues/37) | The event log | **m44** event log | [m44](../product-architecture/mechanisms/m44-event-log.md) · m43 §8 |
| [#39](https://github.com/Calyx-Engineering/arc/issues/39) | Camp's three documents | **m43** | m43 §5 |
| [#40](https://github.com/Calyx-Engineering/arc/issues/40) | Reaching Camp by name or `/camp` | **m43** | m43 §2 · §6 |
| [#41](https://github.com/Calyx-Engineering/arc/issues/41) | Status and flow — status and the close sequence | **m43** | m43 §3.2 |
| [#42](https://github.com/Calyx-Engineering/arc/issues/42) | The intent check — holding the arc's intent | **m43** | m43 §3.1 |
| [#43](https://github.com/Calyx-Engineering/arc/issues/43) | The nudge — four hooks | **m43** | m43 §3.4 |
| [#44](https://github.com/Calyx-Engineering/arc/issues/44) | The relief valve skill | **m41** relief valve · **m43** | [m41](../product-architecture/mechanisms/m41-relief-valve.md) · m43 §3.6 |
| [#45](https://github.com/Calyx-Engineering/arc/issues/45) | The report — announcing actions, and the templates | **m43** | m43 §3.5 |
| [#46](https://github.com/Calyx-Engineering/arc/issues/46) | Verbosity — three levels, two settings | **m43** | m43 §7 |
| [#47](https://github.com/Calyx-Engineering/arc/issues/47) | Decomposition | **m43** · **m20** | m43 §3.3 · [m20](../product-architecture/mechanisms/m20-arc-decomposition.md) |
| [#48](https://github.com/Calyx-Engineering/arc/issues/48) | Shipping skills match their local copies | **None** | Pre-release repo hygiene. The local-copy arrangement is deleted at first release |
| [#55](https://github.com/Calyx-Engineering/arc/issues/55) | Reject a closing keyword written anywhere but a body's last line | **m12** issue linking | [m12](../product-architecture/mechanisms/m12-issue-linking.md) |
| [#56](https://github.com/Calyx-Engineering/arc/issues/56) | Strip the operating agreement to actionable clauses | **m43** | m43 §5.1 — the only wave 5 issue that reads m43 |
| [#60](https://github.com/Calyx-Engineering/arc/issues/60) | The arc's approval mode, and where a window breaks | **m40** autonomy switch · **m15** | **m40 has no spec.** Read §6.1 *Autonomous mode* — this arc's interim definition, and the closest thing that exists — then [#73](https://github.com/Calyx-Engineering/arc/issues/73), which owns the durable one · [m15](../product-architecture/mechanisms/m15-handoff-spine.md) |
| [#61](https://github.com/Calyx-Engineering/arc/issues/61) | The handoff's ordered actions and transcript save | **m15** context ladder / handoff | [m15](../product-architecture/mechanisms/m15-handoff-spine.md) |
| [#62](https://github.com/Calyx-Engineering/arc/issues/62) | Edits reported done without checking everywhere the claim appears | **m13** issue write-back | [m13](../product-architecture/mechanisms/m13-issue-write-back.md), via [`skills/work-watch`](../../skills/work-watch/SKILL.md) |
| [#73](https://github.com/Calyx-Engineering/arc/issues/73) | Specify the autonomy switch | **m40** autonomy switch | **No spec.** This issue is the one that would write it, and it left this arc for *Onboarding — m47*. Read §6.1 *Autonomous mode* first — it is the interim definition and the input this issue starts from |
| [#76](https://github.com/Calyx-Engineering/arc/issues/76) | Specify work navigation | **m46** work navigation | [m46](../product-architecture/mechanisms/m46-work-navigation.md) — this issue produced it |
| [#78](https://github.com/Calyx-Engineering/arc/issues/78) | Build the six artifacts that carry work navigation | **m46** work navigation | [m46](../product-architecture/mechanisms/m46-work-navigation.md) |

| | |
|---|---|
| **A skill can be its own spec** | m11, m38 and m45 have no `mechanisms/` file. `CLAUDE.md` states the exception: a capability that is already a single skill is specified by that skill |
| **m40 has no spec at all** | [#60](https://github.com/Calyx-Engineering/arc/issues/60) and [#73](https://github.com/Calyx-Engineering/arc/issues/73) both trace to it. §6.1 *Autonomous mode* is this arc's interim stand-in; [#73](https://github.com/Calyx-Engineering/arc/issues/73) owns the durable version and left this arc |
| **One issue traces to nothing** | [#48](https://github.com/Calyx-Engineering/arc/issues/48) is pre-release repo hygiene, not a mechanism |

---

## 10 Status — execution order

**Work top to bottom, in this order.**

**Name a step by its wave** — *wave 2.2* is the second issue of wave 2. Never "issue 4": a bare
number collides with `#4`. The `#` column is the global order and is for sequencing, not naming.

| # | Step | Issue | Delivers | State |
| :--- | :--- | :--- | :--- | :--- |
| 1 | 1.1 | [#39](https://github.com/Calyx-Engineering/arc/issues/39) | Camp's three documents | **Merged** — [PR #51](https://github.com/Calyx-Engineering/arc/pull/51) |
| 2 | 1.2 | [#37](https://github.com/Calyx-Engineering/arc/issues/37) | The event log | **Merged** — [PR #52](https://github.com/Calyx-Engineering/arc/pull/52) |
| 3 | 2.1 | [#40](https://github.com/Calyx-Engineering/arc/issues/40) | Reaching Camp by name or `/camp` | **Merged** — [PR #53](https://github.com/Calyx-Engineering/arc/pull/53) |
| 4 | 2.2 | [#45](https://github.com/Calyx-Engineering/arc/issues/45) | The report — announcing actions, and the templates | **Merged** — [PR #54](https://github.com/Calyx-Engineering/arc/pull/54) |
| | | | **■ STOP — cleared 2026-08-19 ■** | |
| 5 | 2.3 | [#60](https://github.com/Calyx-Engineering/arc/issues/60) | The arc's approval mode, and where a window breaks | **Merged** — [PR #63](https://github.com/Calyx-Engineering/arc/pull/63) |
| 6 | 2.4 | [#62](https://github.com/Calyx-Engineering/arc/issues/62) | Edits reported done without checking everywhere the claim appears | **Merged** — [PR #64](https://github.com/Calyx-Engineering/arc/pull/64) |
| 7 | 3.1 | [#61](https://github.com/Calyx-Engineering/arc/issues/61) | The handoff's missing ordered actions and transcript save | **Merged** — [PR #65](https://github.com/Calyx-Engineering/arc/pull/65) |
| 8 | 3.2 | [#41](https://github.com/Calyx-Engineering/arc/issues/41) | Status and flow — status and the close sequence | **Merged** — [PR #66](https://github.com/Calyx-Engineering/arc/pull/66) |
| 9 | 3.3 | [#44](https://github.com/Calyx-Engineering/arc/issues/44) | The relief valve skill | **Merged** — [PR #67](https://github.com/Calyx-Engineering/arc/pull/67) |
| 10 | 3.4 | [#47](https://github.com/Calyx-Engineering/arc/issues/47) | Decomposition — decomposition | **Merged** — [PR #69](https://github.com/Calyx-Engineering/arc/pull/69) |
| 11 | 3.5 | [#43](https://github.com/Calyx-Engineering/arc/issues/43) | The nudge — four hooks | **Merged** — [PR #70](https://github.com/Calyx-Engineering/arc/pull/70) |
| 12 | 3.6 | [#46](https://github.com/Calyx-Engineering/arc/issues/46) | Verbosity | **Merged** — [PR #71](https://github.com/Calyx-Engineering/arc/pull/71) |
| | | | **▬ BREAK — new window. Handoff written and confirmed before it closes ▬** | |
| 13 | 4.1 | [#42](https://github.com/Calyx-Engineering/arc/issues/42) | The intent check — holding the intent | **Merged** — [PR #95](https://github.com/Calyx-Engineering/arc/pull/95). Ships `skills/arc-intent`, fired from four call sites, and renamed the five obligations across the artifacts [#41](https://github.com/Calyx-Engineering/arc/issues/41) [#43](https://github.com/Calyx-Engineering/arc/issues/43) [#44](https://github.com/Calyx-Engineering/arc/issues/44) [#45](https://github.com/Calyx-Engineering/arc/issues/45) [#47](https://github.com/Calyx-Engineering/arc/issues/47) delivered |
| | | | **▬ BREAK — new window. Handoff written and confirmed before it closes ▬** | |
| 14 | 5.1 | [#31](https://github.com/Calyx-Engineering/arc/issues/31) | Say what a branch or setting is when naming it | **PR open** — [PR #96](https://github.com/Calyx-Engineering/arc/pull/96), awaiting merge. The rule landed in `skills/chat-response`, in [m42](../product-architecture/mechanisms/m42-default-branch-flip.md), and in the strings `tools/arc-default-branch.sh` prints. **Also carries this arc-log's autonomous-mode definition** |
| 15 | 5.2 | [#32](https://github.com/Calyx-Engineering/arc/issues/32) | Size an issue title to what merging delivers | Ready |
| 16 | 5.3 | [#33](https://github.com/Calyx-Engineering/arc/issues/33) | A repeatable loop for scoping involved work | Ready |
| 17 | 5.4 | [#34](https://github.com/Calyx-Engineering/arc/issues/34) | Numbered questions in a multi-topic reply | Ready |
| 18 | 5.5 | [#35](https://github.com/Calyx-Engineering/arc/issues/35) | Keep the issue checklist current as working state | Ready |
| 19 | 5.6 | [#55](https://github.com/Calyx-Engineering/arc/issues/55) | Reject a closing keyword written anywhere but a body's last line | **Merged** — [PR #88](https://github.com/Calyx-Engineering/arc/pull/88). Pulled forward out of order |
| 20 | 5.7 | [#56](https://github.com/Calyx-Engineering/arc/issues/56) | Strip the operating agreement to clauses a user can act on | **Merged** — [PR #57](https://github.com/Calyx-Engineering/arc/pull/57) |
| | | | **▬ BREAK — new window. Handoff written and confirmed before it closes ▬** | |
| 21 | 6.1 | [#48](https://github.com/Calyx-Engineering/arc/issues/48) | Shipping skills match their local copies | Ready |
| — | — | [#73](https://github.com/Calyx-Engineering/arc/issues/73) | Specify the autonomy switch — what auto changes, and how it ends | **Left this arc** — moved to the *Onboarding — m47* milestone. Its portability requirement is onboarding's to carry, and nothing was written |
| 23 | 6.3 | [#78](https://github.com/Calyx-Engineering/arc/issues/78) | Build the six artifacts that carry work navigation | Spawned by [#76](https://github.com/Calyx-Engineering/arc/issues/76). Last — it touches skills every earlier wave edits |
| — | — | [#76](https://github.com/Calyx-Engineering/arc/issues/76) | Specify work navigation | **Spec written** — produced [m46](../product-architecture/mechanisms/m46-work-navigation.md), spawned by [PR #75](https://github.com/Calyx-Engineering/arc/pull/75) |
| — | — | [#27](https://github.com/Calyx-Engineering/arc/issues/27) | This spec and decomposition | **Closed** — produced m43, m44 and this plan |

### 10.1 What each wave is

**The modes are defined in §6.** This table is the assignment — the only place a wave's mode
is stated.

| Wave | | Mode |
|---|---|---|
| **1** | The two artifacts nothing else can be built without | **Autonomous** |
| **2** | The entry point, and artifacts declaring what they report | **Autonomous** |
| **3** | The obligations that need only the entry point | **Autonomous** |
| **4** | The intent check, which needs status and the relief valve | **Autonomous** |
| **5** | Tracker and chat mechanics — touches `skills/`, not Camp | **Autonomous** |
| **6** | The parity check, which needs every skill to exist | **Autonomous** |

**Wave 5 is last of the substantive work, not optional.** It was spawned during scoping and is
scheduled here because it depends on nothing in Camp — but it ships in this arc.

### 10.2 Where a window breaks

**A break is context, not approval.** Ten issues do not fit one window. The mode says who
reviews the work; the break says where the window ends — and the two are independent, so
**breaks happen in every mode.**

Break at a wave boundary — a boundary is a dependency edge, and it is where a fresh session
needs least explanation. **Never mid-wave.**

| Break after | Carries | Why there |
|---|---|---|
| **Wave 3** | [#61](https://github.com/Calyx-Engineering/arc/issues/61) · [#41](https://github.com/Calyx-Engineering/arc/issues/41) · [#44](https://github.com/Calyx-Engineering/arc/issues/44) · [#47](https://github.com/Calyx-Engineering/arc/issues/47) · [#43](https://github.com/Calyx-Engineering/arc/issues/43) · [#46](https://github.com/Calyx-Engineering/arc/issues/46) | Six issues, all obligations, all specified. The expected limit of one window |
| **Wave 4** | [#42](https://github.com/Calyx-Engineering/arc/issues/42) alone | Only if wave 3 ran light. The intent check is the judgement-heaviest issue in the arc |
| **Wave 5** | [#31](https://github.com/Calyx-Engineering/arc/issues/31)–[#35](https://github.com/Calyx-Engineering/arc/issues/35) · [#55](https://github.com/Calyx-Engineering/arc/issues/55) | Six issues, no spec. Judgement plus no spec is the most expensive combination here — its own window regardless |

**A break is not optional and not a checkpoint to pass through.** The window ends there.

| At a break | |
|---|---|
| 1 | Write the handoff |
| 2 | Say it was written |
| 3 | Give the prompt for the next chat |

A new chat starts from that prompt and picks up where the last one stopped.

**Stopping to hand off is not stopping for approval** — it is what makes a long arc survive
its own context. Write a fresh handoff and stop whenever the context degrades, boundary or not.

### 10.3 The stop — cleared 2026-08-19

Waves 1 and 2 merged and were reviewed together. **Wave 3 may start.**

| | |
|---|---|
| **Why here** | Waves 1 and 2 are the foundation. Everything after depends on the documents, the entry point and the log being right |
| **If the foundation had been wrong** | Four PRs to redo. Discovered at wave 6, it is eighteen |

Waves 1 and 2 ran in one session. A session cannot clear its own context, so the wave boundary
was dependency rather than a fresh start.

#### 10.3.1 What the review found

Three defects, all in artifacts whose verification had passed. **The pattern is that structural
checks passed while the artifact itself was wrong** — worth carrying into how later positions
are checked.

| Defect | Shipped in | Caught by |
|---|---|---|
| A closing keyword in a PR heading bound a link the body's `Refs` did not ask for | [#45](https://github.com/Calyx-Engineering/arc/issues/45)'s PR | Reading the rendered PR. Filed as [#55](https://github.com/Calyx-Engineering/arc/issues/55) |
| An unquoted colon made `skills/camp`'s frontmatter fail to parse | [#40](https://github.com/Calyx-Engineering/arc/issues/40) | Adding a field that forced the frontmatter to be parsed rather than read |
| Ten template links one directory too shallow, and one truncated line | [#39](https://github.com/Calyx-Engineering/arc/issues/39) | Checking link resolution on the template, which #39 never did |

**Since fixed:** `tools/sync-local-skills.sh --check` false-positived on Windows — line endings
made every copy compare unequal on a clean tree. The sync writes LF and `.gitattributes` had no
`.md` rule, so a synced copy came back CRLF-dirty with no content change. `*.md text eol=lf` plus
a renormalize took a repeat sync from `4 copied` to `0 copied, 9 checked`. Fixed while doing
[#55](https://github.com/Calyx-Engineering/arc/issues/55); noted on
[#68](https://github.com/Calyx-Engineering/arc/issues/68) and
[#48](https://github.com/Calyx-Engineering/arc/issues/48).

**Still unexercised.** Nothing in this repository runs a skill or fires a hook, so no
acceptance criterion written as runtime behaviour has been tested. The event log has three
hand-written entries and no producer.

## 11 Wave 3 review — 2026-08-19

**Six issues, eight PRs open, none merged.** The review at a wave's end is the reviewer's, per
the autonomous mode. Findings below are mine, on my own work.

| | |
|---|---|
| **Every PR binds its issue** | Checked with `gh pr view --json closingIssuesReferences`, not by reading the keyword — the check [#41](https://github.com/Calyx-Engineering/arc/issues/41) specifies, run against the eight PRs. All eight bound |
| **Three merge conflicts are unavoidable** | [#62](https://github.com/Calyx-Engineering/arc/issues/62)+[#44](https://github.com/Calyx-Engineering/arc/issues/44) both edit `work-watch`'s mechanism list, the README and ROADMAP · [#47](https://github.com/Calyx-Engineering/arc/issues/47)+[#41](https://github.com/Calyx-Engineering/arc/issues/41) both edit `skills/camp` · [#43](https://github.com/Calyx-Engineering/arc/issues/43) edits the README rows again. **No merge order avoids them** — tested both directions |
| **Two defects found by tests, not review** | A truncated payload made `camp-session-start` speak on input that was not a hook call; the `field` helper's comma split erased the very signal the issue-title check reads. Both in [#43](https://github.com/Calyx-Engineering/arc/issues/43) |
| **A hardcoded list hid a new skill** | `tools/sync-local-skills.sh` reported success while copying nothing. Filed as [#68](https://github.com/Calyx-Engineering/arc/issues/68) |
| **[#43](https://github.com/Calyx-Engineering/arc/issues/43) built three artifacts, not four hooks** | Two of the four moments are already `tracker-verify`'s. Flagged in the PR rather than reconciled silently |

**The conflicts are the finding worth carrying.** Six issues in one wave touching four shared
surfaces — README, ROADMAP, `skills/camp`, `work-watch` — means parallel branches collide by
construction. Either the wave's issues are partitioned by file, which is
[m27](../product-architecture/mechanisms/m27-worktree-waves.md)'s disjointness test, or they
are merged in sequence and each rebased on the last. **Nothing in the plan made that choice.**

**Still unexercised.** Nothing here has run. The hooks are the exception — they were executed
against real fixtures by `tools/verify-hook.sh`, which is the first acceptance criterion in
this arc tested rather than asserted.

## 12 Soak

**Per `CLAUDE.md`: a plugin change runs against real work before it leaves the machine.**
Committed is not exercised. Unsoaked means a commit here with no soak line from any repo.

| Change | Soaked on | Result |
|---|---|---|
| `skills/arc-intent` — the ladder, the test, the override rule ([#42](https://github.com/Calyx-Engineering/arc/issues/42)) | The rest of [#42](https://github.com/Calyx-Engineering/arc/issues/42), by hand — the obligation rename was classified through the ladder before it was done | **Fired correctly.** *Derived* for the one artifact, *escalate* for all five, put as a question rather than a refusal; the user chose all five and it was not raised again. Found a case the skill does not name: the two readings differed only by scope, so the honest output was two options, not one flag |

> **This is the first soak line in this repository, across three arcs.**
> `arc-02` and everything in `arc-03` before it shipped plugin changes with the box unticked
> and nothing written. The rule was stated and never once executed — a gap in the practice,
> not in this issue.

**What a soak cannot cover here.** Nothing Arc ships actually *runs* in this repo, so a soak
line records the mechanism being followed by hand against real work. That is weaker than
execution and is worth exactly what it says.

## 13 At arc close

- [ ] Status table reflects reality
- [ ] Default branch restored — `tools/arc-default-branch.sh restore`
- [ ] Arc PR into `main` carries a `Closes` line for every issue
- [ ] Soak line appended for every plugin change made during this arc — **started**, see *Soak* above. Every earlier plugin change in this arc is still unsoaked
- [ ] K2 swept — durable product facts graduated

**Why nothing has run, and what closes it.** `hooks/hooks.json` registers all four hooks
correctly, through `${CLAUDE_PLUGIN_ROOT}` — a path that resolves only for an installed plugin.
The skills half of this has a stopgap in `tools/sync-local-skills.sh`; the hooks half has none
and gets none, because a hook copied into `.claude/settings.json` would be tested against a
version of itself.

**Installing the released plugin is what closes it** — a release milestone, not arc work, per
CLAUDE.md and the ROADMAP's release bar. Until then every hook-carried check is written and
not running: `hooks/tracker-verify` already holds the milestone check that
[PR #91](https://github.com/Calyx-Engineering/arc/pull/91) in this arc still missed.

---

## 14 Related

- [m43](../product-architecture/mechanisms/m43-camp-assistant.md) — the Camp spec
- [m44](../product-architecture/mechanisms/m44-event-log.md) — the event log
- [m41](../product-architecture/mechanisms/m41-relief-valve.md) — the relief valve's precondition and thresholds
- [m42](../product-architecture/mechanisms/m42-default-branch-flip.md) — why the default branch is pointed at this arc
- [m46](../product-architecture/mechanisms/m46-work-navigation.md) — where a discovery goes and how the work gets back out, spawned mid-arc by [#75](https://github.com/Calyx-Engineering/arc/pull/75)
