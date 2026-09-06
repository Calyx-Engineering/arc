---
name: plugin-retrospective
description: Use when returning to a Calyx plugin repo after a stretch of real work elsewhere, to mine that work's transcripts for friction and turn it into concrete plugin improvements. Also use when the user says "let's do a plugin retrospective", "what did that arc teach us about the tooling", or wants to defer plugin iteration until after a work push rather than context-switching mid-task. Covers extraction, clustering, the review interview, and writing findings up as mechanism specs. Not a general project or team retrospective — this one improves the tooling.
---

# plugin-retrospective

**Scope note.** Retrospectives in general are a broad practice — team, project, incident,
sprint. **This one is narrow on purpose:** it improves the Calyx plugin line by mining
real engineering work for friction the tooling caused. Nothing here is designed for
reviewing a project's outcomes, a team's process, or an incident.

## The principle everything follows from

> **A user's corrections are labeled data about where the tooling is wrong, and they
> sit unread on disk.**

Every transcript records where the tool failed the work. Nothing reads them, so the
same friction recurs until it gets loud enough that someone writes a skill by hand.

**Why deferred beats live.** Iterating on tooling mid-task is a context switch away from
the engineering. This process makes deferral safe: the evidence survives in transcripts,
so improvements can be batched at the end of a work push without losing what happened.


## When to run it

| Trigger | Why |
|---|---|
| Returning to the tooling repo after a work push | The reason this exists |
| An arc closed | Natural boundary, evidence is fresh |
| The same correction given three times | Do not wait for the twelfth |
| Before writing or revising a skill | The evidence should precede the fix |

Not ambient. It is a deliberate session.


## The loop

```text
1 Extract  → 2 Cluster → 3 Draft → 4 INTERVIEW → 5 Specify → 6 Rank
                                        ↑
                            the step that produces the value
```

**Step 4 is not optional and not a formality.** In the run that produced this skill,
three of the drafted diagnoses were wrong, and only the user's review caught them. A
retrospective that skips the interview produces confident, wrong conclusions.


### 1. Extract

Transcripts live in `~/.claude/projects/<path-slug>/*.jsonl`, one directory per working
directory.

**Glob across all matching directories, never one.** Worktrees get their own slug, and
deleted worktrees leave orphaned directories that a scoped search misses silently — in
one real case, 55 MB of the richest material.

Keep `type: "user"` entries. Drop:

- Anything containing `tool_use_id` (tool results, not speech)
- Messages starting with `<command-`, `<local-command`, `<system-reminder`
- Strip `<ide_opened_file>` / `<ide_selection>` wrappers but **keep the text after them**

### 2. Cluster

Filter for correction signals, then group by what was being corrected.

```text
no,|nope|wrong|incorrect|not right|actually|again|still|stop|don.t|didn.t|
why did|why are|you (missed|forgot|removed|deleted|changed)|i (told|said|asked)|
revert|undo|that.s not|isn.t (right|correct)|mistake|broke|broken|re-?do|
fix that|never mind|hold on|wait
```

| Tuning note | |
| --- | --- |
| Cap message length ~1500 chars | Longer ones are usually new instructions, not corrections |
| `"actually"` is the highest-yield token | It prefixes most gentle corrections |
| Expect ~15% of user messages to survive | 474 → 75 in the reference run |

**Then read the full set for the top clusters, not just the filtered hits.** The filter
finds the argument; the surrounding messages carry the reasoning. The commit-rhythm
finding only appeared after reading every commit-related message, not just the angry
ones.

### 3. Draft

For each cluster: what happened, how often, what it cost, a **verbatim quote**.

**A cluster without a quote is an inference, not a finding.** Rank by recurrence —
recurrence is what a mechanism repays.

### 4. Interview

Walk the user through the draft one cluster at a time. Their corrections are the
deliverable.

**What to ask:**

- "Is this diagnosis right?" — the mechanism matters more than the symptom
- "What did you do instead?" — reveals the workaround already in use
- "What should have happened?" — often names the mechanism directly

**Two failure modes seen in the reference run:**

| Wrong diagnosis | Correct one | Why it mattered |
| --- | --- | --- |
| "Assumptions were unstated" | Analysis was shallow; the data was in the datasheet | Needed a domain persona, not better communication |
| "Worktree transcripts are lost" | They survive; they become unfindable | Needed an index, not a backup |

Both were plausible and matched the user's felt experience. **Plausible-and-matching is
not the same as correct.**

**Verify claims that can be verified.** In the reference run, a documented belief about
GitHub's `Closes #NN` behavior was disproved in two API calls. Test before designing
around an assumption.

### 5. Specify

Two kinds of output, two destinations.

| Output | Goes to |
|---|---|
| **The retrospective** — evidence, clusters, verbatim quotes | `docs/retrospectives/<YYYY-MM>-<slug>/README.md` |
| **Mechanism specs** — one file each | `docs/product-architecture/mechanisms/` |

**The retrospective is dated and never edited afterwards.** It is evidence, and evidence
freezes when the run ends. Every retrospective produces one, so they need a home that does
not clog the product definition — the first run's sat in the architecture root and had
to be moved.

**`README.md`, and never `friction-log.md`.** Two reasons, both learned the hard way:

| | |
|---|---|
| **It is not a log** | A log is appended to as friction happens — that is the running `friction-log.md` a *work* repository keeps. This is written once, at the end of a run. Naming both the same thing makes a reader open the wrong one |
| **`README.md` matches the convention already in use** | `report/<capability-slug>/README.md`, `docs/product-architecture/README.md`. The folder name carries the run; the filename's job is *this is the document*, and GitHub renders it on the folder |

**The `# H1` carries the identity, not the filename** — `# Retrospective — <slug>, <date>`. A file
that escapes its folder still says what it is.

**Specs are living.** They change as mechanisms get built. That is why they live apart from
the evidence that produced them.

One file per mechanism. Do not bury specs inside argument documents.

| Section | Holds |
| --- | --- |
| Status · Home · Spawned from | Where it belongs and why it exists |
| The problem | Verbatim quotes |
| Proposed shape | Hook, agent, skill, or rule — and why that form |
| Open questions | What is genuinely undecided |

**Prefer an agent when the work is token-heavy** (reading transcripts, datasheets, large
diffs). A skill pulls the raw material into the orchestrator's context; an agent returns
a bounded packet.

### 6. Rank and place

| Column | |
| --- | --- |
| Mechanism | The unit of maintenance |
| Fixes | Which cluster |
| Effort | Adaptation of something proven, or invention |
| Payback | What it saves, in the user's terms |
| Home | Which plugin owns it |

**Count mechanisms, not plugins.** Thirty mechanisms cost about the same whether they
sit in one plugin or four, plus a small per-plugin tax. The question is whether each
mechanism repays its own upkeep.

**Placing a mechanism is routine; re-drawing the boundaries is not.** If a mechanism
does not fit any existing plugin, say so and stop — that is a boundary question for the
user, not a call to make inside a retrospective.


## The three-part rule

Everything that works in practice has all three. Everything that fails has at most one.

| | Trigger | Template | Enforcement |
| --- | --- | --- | --- |
| **What it means** | Something says *now* | Not a blank page | A hook, gate, or mandatory step |

**Any mechanism proposed without all three will produce an empty stub.** Check each
proposal against this before writing it up.


## Measuring whether it worked

The only honest test of whether tooling repays its upkeep:

| Signal | Meaning |
| --- | --- |
| New cluster, no mechanism covers it | Candidate |
| Cluster persists after a mechanism ships | The mechanism is wrong or not firing |
| **Cluster disappears after a mechanism ships** | **It repaid** |

Record cluster counts per run so the comparison is possible.


## Rules

| Rule | |
| --- | --- |
| **Never write the fix silently** | Propose; the user decides |
| **Quote, do not paraphrase** | Paraphrase drifts toward the diagnosis you already have |
| **Read your own wrong turns as evidence** | A correction after a skill exists means the skill is wrong |
| **Cross-repo patterns are portable candidates** | A cluster in two repos belongs in a plugin, not a `CLAUDE.md` |
| **Transcripts stay local** | They contain client and employer material. Findings may be shareable when the source is not |
| **Distil before deletion** | Transcripts rotate. Anything that matters goes into a committed artifact |
| **Stay product-agnostic** | This process runs the same way for every plugin. Nothing here should assume which products exist |


## Scope

**This skill improves plugins that already exist.** It finds friction in real work and
turns it into mechanisms.

It does **not** decide how many plugins there should be, or where their boundaries fall.
That is a separate, occasional exercise with different evidence and a different output.
When a retrospective surfaces something that does not fit anywhere, record it as a
finding and hand it to the user.

| Question | Belongs to |
| --- | --- |
| "What friction recurred, and what mechanism fixes it?" | **This skill** |
| "Which plugin owns this mechanism?" | This skill, when the answer is obvious |
| "Should this be its own plugin?" | The user |
| "How do we split the product line?" | A boundary exercise, not a retrospective |
