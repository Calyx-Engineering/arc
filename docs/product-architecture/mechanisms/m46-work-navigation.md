# Mechanism — Work Navigation

**Status:** specified. The decisions are settled; the artifacts that carry them are named
below and built separately.
**Home:** Arc — Authoring.
**Src:** 🔥 observed, 2026-08-20.
**Covers:** m46.

---

## 1 The friction

Work is discovered while doing other work. There was no defined way to record it, decide
whether it belonged here or elsewhere, or find the way back out — so a discovery either
derailed the current work or was lost.

> *"i go to review 1 change… and we're in a different branch so there is no change! that
> specific case has happened at least 8 different times over the last 3 days."*

**Eleven PRs open across five branches, each cut from a different base.** A review begun in
one branch lost its subject when the working tree moved to another. The review time spent
before each move was lost with it.

The naming was the visible symptom. **The cause was that a discovery moved the working tree
at all.**

---

## 2 What this is not

**Not scope control.** Whether a discovery belongs in this arc is
[m43](m43-camp-assistant.md)'s obligation 0.

**Not decomposition.** Turning a body of work into issues is
[m43](m43-camp-assistant.md)'s (not [m20](m20-arc-decomposition.md)'s) obligation 2, carried
by [`skills/decompose`](../../../skills/decompose/SKILL.md). This decides *where a discovery
goes and how you get back*; decompose decides *what shape it takes* once it is going
somewhere.

**Not arc-scoped.** Discovery happens outside arcs, which is why this is its own mechanism
rather than part of [m21](m21-arc-tree.md) or the arc-log.

---

## 3 The industry model — a patch series

**This is the patch series tradition**, most visible in Linux kernel practice: a set of
related changes reviewed and landed as one unit, ordered so each builds on the last.

Two mainstream traditions disagree about the unit, and both agree about the constraint:

| Tradition | The unit | Says |
|---|---|---|
| **Trunk-based** (Google, Meta) | One small change | Split discoveries into separate changes |
| **Patch series** (Linux kernel) | An ordered series | Land related discoveries together |
| **Both** | — | **One reviewable unit, one coherent story** |

**Arc follows the patch series model**, because discovery work produces changes that only
make sense together — a rule and the artifact that reads it, a process and the skill that
performs it.

> **The anti-pattern is not size. It is a unit that grows without its title and description
> growing with it.** A PR that expanded four times and still carries its first title is
> unreviewable no matter how few lines it touches.

Naming the tradition is deliberate: a reader can research it rather than treating this as a
local invention.

---

## 4 Three relations, not two

A discovery relates to its parent in one of three ways, and the branch shape follows.

| Relation | Test | Branches from | Merges to |
|---|---|---|---|
| **Tangent** | It would exist anyway | The shared base | The shared base |
| **Descent** | It changes what the parent should be | The parent branch | The parent |
| **Tangent with dependency** | Shared base, but it would not exist without the parent | The shared base | The shared base |

**The third is the most common and has no distinct branch shape.** A worked example, from
the work that produced this mechanism:

| # | | Discovery | Relation | Why | Branched from |
|---|---|---|---|---|---|
| 1 | **Parent** | issue [#45](https://github.com/Calyx-Engineering/arc/issues/45) — announcing completed actions | — | The work in hand | `arc/03-camp` |
| 2 | **Child** | PR [#74](https://github.com/Calyx-Engineering/arc/pull/74) — issue numbers in chat must be links | **Tangent with dependency** | Noticed while reading issue [#45](https://github.com/Calyx-Engineering/arc/issues/45)'s output, but changes nothing about it and needs none of its code | `arc/03-camp` |
| 3 | **Grandchild** | PR [#75](https://github.com/Calyx-Engineering/arc/pull/75) — a PR needs no issue | **Tangent with dependency** | Same shape again, one level down: found by doing PR [#74](https://github.com/Calyx-Engineering/arc/pull/74), independent of it | `arc/03-camp` |
| 4 | **Inside PR [#75](https://github.com/Calyx-Engineering/arc/pull/75)** | The arc tree must see a no-issue PR | **Descent** | The new rule was useless unless something read it, so it changes what PR [#75](https://github.com/Calyx-Engineering/arc/pull/75) is | **PR [#75](https://github.com/Calyx-Engineering/arc/pull/75) itself** — no new branch |
| 5 | **Great-grandchild** | issue [#76](https://github.com/Calyx-Engineering/arc/issues/76) — this mechanism | **Tangent with dependency** | The rule needed a whole navigation model behind it. Too large to fold into PR [#75](https://github.com/Calyx-Engineering/arc/pull/75) without making it unreviewable | `arc/03-camp` |

**Rows 4 and 5 were both found inside PR [#75](https://github.com/Calyx-Engineering/arc/pull/75),
and only one stayed there.** That is the reviewable-unit test, and it is the judgement this
whole mechanism turns on:

| | |
|---|---|
| **The tree change stayed** | A rule and the thing that reads it are one story. Splitting them would ship a rule nothing honours |
| **Issue [#76](https://github.com/Calyx-Engineering/arc/issues/76) split off** | A spec, a diagram and five artifacts is a different story. Folding it in would have grown PR [#75](https://github.com/Calyx-Engineering/arc/pull/75) past what one review can hold |

**Every one of these branched from the same base**, because none of them needed another's
code. The parent/child structure is real and lives in the spawned tree, not in git.

```mermaid
flowchart TB
    subgraph G[" The git graph — dependency only "]
        direction TB
        GB["<b>arc/03-camp</b><br/>the shared base"]
        GB --> G45["issue #45<br/>parent"]
        GB --> G74["PR #74<br/>tangent w/ dependency"]
        GB --> G75["PR #75<br/>tangent w/ dependency"]
        G75 --> GD["descent —<br/>same branch as PR #75"]
        GB --> G76["issue #76<br/>tangent w/ dependency"]
    end
    subgraph W[" The spawned tree — the work story "]
        direction TB
        W45["<b>issue #45</b><br/>announce actions"]
        W45 -->|spawned| W74["<b>PR #74</b><br/>numbers are links"]
        W74 -->|spawned| W75["<b>PR #75</b><br/>a PR needs no issue"]
        W75 -->|descent| WD["the tree must<br/>see it"]
        W75 -->|spawned| W76["<b>issue #76</b><br/>this mechanism"]
    end
    classDef n fill:#1e3a5f,stroke:#4a9eff,color:#fff
    classDef b fill:#2b2b3d,stroke:#6b6b8a,color:#c9c9d4
    classDef d fill:#4a3520,stroke:#d98f2b,color:#fff
    class G45,G74,G75,G76,W45,W74,W75,W76 n
    class GB b
    class GD,WD d
    style G fill:#0d1b2a,stroke:#2c4a6b,color:#8fb8e0
    style W fill:#0d1b2a,stroke:#2c4a6b,color:#8fb8e0
```

**Read the two side by side.** The left is flat because nothing depended on anything — three
siblings off one base. The right is three levels deep because each was found by doing the one
above it. **Both are correct.**

> **The git graph carries dependency. The spawned tree carries the work story.** They are
> different views of the same work and **neither fakes the other** — a tangent with a
> dependency is a child in the tree and a sibling in the graph, and forcing either view to
> match the other loses information.

**Branch where the dependency actually is**, so merge order stays reorderable and a
dependent change cannot land before what it depends on.

---

## 5 The loop

**A unit of work is a breath.** It opens, it may nest, and it ends at a merge.

```mermaid
flowchart TB
    START(["Working on a unit"]) --> WORK["Work on it"]
    WORK -->|something spotted| TABLE["Row into the parent's<br/><b>spawned table</b> — unfiled.<br/><i>Do not act on it</i>"]
    TABLE --> WORK
    WORK --> DONE{"Unit<br/>complete?"}
    DONE -->|not yet| WORK
    DONE -->|yes| SPAWN["Spawn the tabled rows —<br/>issue, PR, or marked abandoned"]
    SPAWN --> ASK{{"<b>Ascend or descend?</b><br/>the user decides"}}
    ASK -->|descend| START
    ASK -->|ascend| REVIEW["Review · merge"]
    REVIEW --> EXHALE(["Breath ends<br/>at the merge"])
    classDef n fill:#1e3a5f,stroke:#4a9eff,color:#fff
    classDef u fill:#3d2b4f,stroke:#b07fd6,color:#fff
    classDef d fill:#1f3d2b,stroke:#4caf70,color:#fff
    class WORK,TABLE,DONE,SPAWN,REVIEW,START n
    class ASK u
    class EXHALE d
```

**Entry condition:** a small, scoped discovery during manual work — the no-issue PR case.
Larger or already-scoped work goes to a worktree instead, and does not move the tree at all.

### 5.1 Breaths nest

A discovery inside a discovery is normal and does not need flattening.

> *"when you're sobbing you'll do a burst breath in, start to exhale just a bit, then burst
> breath in a bit more, lungs filling deeper… and then finally your lungs fill up so large
> you have a large exhale."*

Nested inhales, one long exhale. **Trying to exhale mid-nest is what splits one story across
several PRs** — the failure this mechanism was written after.

---

## 6 The spawned table is a scope buffer

**A spotted tangent goes into the parent's spawned table immediately, unfiled. Nothing is
acted on when it is spotted.**

| | |
|---|---|
| **Not a to-do list** | A growing definition of what this work turned out to be |
| **Long is fine** | Length is evidence of scope, and seeing it early is the point |
| **Unfiled rows get numbers later** | At spawn time, not at spot time |
| **Abandoned rows stay**, marked at the front of the row | A record of what was chosen against is worth more than a tidy table |

**This is [`decompose`](../../../skills/decompose/SKILL.md)'s other input.** It reads a spec
*or* a spawned table, and records which — so the proposed set carries its own origin. A table
that grew for three days is exactly the raw material decomposition needs.

**Both directions are recorded**, and the pair is what makes the tree navigable rather than
only readable:

| | Written on |
|---|---|
| `Spawned` table | The parent |
| `Spawned by #NN` | The child — **the only record when the child has no issue** |

---

## 7 Asking the user to choose

### 7.1 Any navigation decision leads the message

**A decision that changes where the work goes next is never buried.** It opens the reply, it
is set apart, and it is flagged as needing an answer.

> **The reader must not have to finish the message to learn a decision was wanted.** A
> question in the last line of a long reply reads as commentary, and the answer given is the
> answer to whatever they read first.

| Rule | |
|---|---|
| **First, and marked** | A one-line note at the top that a decision is needed, before any reasoning |
| **Bold and set apart** | It is a break in the conversation, not a sentence within it |
| **Just the ask** | **No other content in that message.** Reasoning goes below, or in the next reply |
| **Every option named concretely** | The user answers without reconstructing where they are |

**This governs any navigation decision** — ascend or descend, fold in or split off, file now
or table it. The ascend/descend prompt below is the most frequent instance, not the only one.

### 7.2 The ascend/descend prompt

**Whether a discovery is a tangent or a descent is the user's call and cannot be inferred.**
It is the same judgement as *is this in scope*, and it is cheap for the user to make in the
moment — but only if the question is asked plainly.

| Rule | |
|---|---|
| **Fires only when there is somewhere to descend to** | At depth zero there is no decision, so there is no prompt |
| **The words match the action** | *Ascend* and *descend*, on the work tree |

```text
**Decision needed.**

**Descend into the spawned process update, or ascend to issue #45 (the handoff blockage)?**
```

**Never *"what next?"*** — that puts the reconstruction back on the person the prompt exists
to serve.

---

## 8 Manual mode

Auto and manual are [m40](m40-autonomy-switch.md)'s. What binds here:

| | |
|---|---|
| **Work stops at the edit** | The user reviews, then merges. `git status` and the editor's diff are the review surface |
| **Every merge in a stack is reviewed** | Including intermediate ones — a stacked merge carries changes the previous did not |
| **"This is good, merge up" delegates the rest** | **Explicit only.** Never assumed |

**Nine unreviewed PRs merged at once is the failure state**, and it is what this section
exists to prevent.

---

## 9 Branch naming

**The branch name is often the only reference visible** — an editor's status bar truncates
early, and it is the one place the current work is named while a PR is being reviewed in a
browser.

**Two forms, and the number names whichever identifier exists first.**

```text
arc/<nn>-<slug>-issue-<NN>-<hint>    an issue exists — use its number
arc/<nn>-<slug>-pr<NN>-<hint>        no issue — the PR number is the only identifier

arc/03-camp-issue-76-work-nav
arc/03-camp-pr75-no-issue-pr
```

**Do not write `pr<NN>` for an issue-backed branch.** The issue number and the PR number are
different numbers from the same counter, and naming a branch after the wrong one points the
reader at an unrelated object. If an issue exists, its number is the one that names the work.

| | |
|---|---|
| **The number is mandatory** | It is what makes the branch sayable and matchable against what is under review |
| **The hint is short** | A twenty-word slug truncates to nothing |
| **The PR title carries the real name** | And is **retitled as the unit grows** |

**GitHub's issue and PR numbers share one counter**, so the PR number is already unique
across both. A second index would create two tokens for one thing.

**A number cannot be reserved** — it is allocated on creation, so predicting it is silently
wrong whenever anything lands in between. The branch is therefore named after the PR exists,
and renamed before its first push if a placeholder was used.

---

## 10 What is not designed

**Where the mechanism's rules live so they are portable.** They must arrive with the plugin
and not be re-taught per repo — the same requirement as
issue [#73](https://github.com/Calyx-Engineering/arc/issues/73). The carrier is undecided.

**When a worktree is right instead.** Already-scoped parallel work belongs in a worktree, and
unscoped discovery does not. The boundary between them is judgement.

**Whether the ascend/descend prompt over-fires** at depth two or three. No budget is set.

---

## 11 Artifacts

| Artifact | Carries |
|---|---|
| [`skills/issue-write`](../../../skills/issue-write/SKILL.md) | The spawned table, the abandoned marker, mandatory retitling |
| [`skills/decompose`](../../../skills/decompose/SKILL.md) | Reading the spawned table as an input, and recording its origin |
| [`skills/chat-response`](../../../skills/chat-response/SKILL.md) | The ascend/descend prompt as a standalone message |
| `CLAUDE.md` — branching | Branch naming with the number |
| [m21](m21-arc-tree.md) | Rendering these relations |

---

## 12 Related

- issue [#76](https://github.com/Calyx-Engineering/arc/issues/76) — the issue this specifies
- [m40](m40-autonomy-switch.md) — auto and manual, and who reviews
- [m20](m20-arc-decomposition.md) — sequences an arc at kickoff; this navigates discovery at any point
- [m21](m21-arc-tree.md) — the tree these relations render into
- [m43 §3.1](m43-camp-assistant.md) — obligation 0, which owns whether a discovery belongs in this arc
