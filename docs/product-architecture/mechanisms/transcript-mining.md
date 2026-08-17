# Mechanism — Transcript Mining

**Status:** partial — the friction filter is validated; the knowledge filter is not designed.
**Home:** Arc — Delegation.
**Form:** agent, not skill — see §4.

---

## What it does

Reads Claude Code transcripts, extracts user turns, filters, clusters, and proposes.

**One pipeline, two filters.** The steps are identical; what differs is what is kept and
where the output goes:

| | Knowledge filter | Friction filter |
|---|---|---|
| Looks for | Findings, measurements, decisions, rejected options | Corrections |
| Produces | Durable knowledge promoted **K4 → K2** — `arc-work/`, `scratch/`, the wiki | Mechanism candidates — clusters worth codifying as a skill or hook |
| Invoked at | PR time, by Arc | End of a work stretch, by the retrospective |
| Answers | *What did we learn that is not written down?* | *Where is the tooling wrong?* |

Splitting these into separate mechanisms would duplicate extraction and clustering
across two groups and let the copies drift — see
[suite-architecture](../../suite-architecture/README.md#why-three-not-five).

**Neither filter writes silently.** Both propose; the human decides. What happens after
the proposal — filing, fixing, reviewing — is
[self-improvement-loop](self-improvement-loop.md).

### Why the knowledge filter matters

Transcripts are **K4** in the knowledge ladder: machine-local, never pushed, not backed up
by git. A drive failure loses them, and a second machine never had them.

Promoting K4 material into K2 is therefore not a convenience — it is the only path from
machine-local reasoning to a durable record.

---

## Why it exists

Proven once, by hand, on 2026-08-16. Reading 28 ROADZ transcripts corrected three
architecture errors in a single pass that four rounds of reasoning from design
documents had not — see [friction-log.md](../../retrospectives/2026-08-plugin-line/friction-log.md).

The general claim:

> **A user's corrections are labeled data about where the tool is wrong, and they sit
> unread on disk.**

Two skills in ROADZ (`engineering-report`, `issue-writing`) were precipitated out of
roughly a dozen repeated corrections each — manually, and only once the pain got loud
enough to notice. This mechanism does that at three, deliberately.

---

## How it worked in practice

The hand-run that produced the friction log, as a repeatable pipeline:

| Step | What happened | Numbers |
|---|---|---|
| 1. Locate | `~/.claude/projects/<slug>/*.jsonl`, all branches and worktrees | 28 files, ~91 MB |
| 2. Extract | Keep `type: "user"` entries; drop tool results, hook noise, slash-command echoes | 474 messages, 544 KB |
| 3. Filter | Regex for correction signals | 75 messages, 35 KB |
| 4. Cluster | Group by what was being corrected | 8 categories |
| 5. Rank | By recurrence | Top: branch/worktree, 8+ hits |
| 6. Propose | Name the mechanism that would prevent each | 8 candidates |

Steps 1–3 reduce ~91 MB to ~35 KB — a 2600× reduction, which is what makes this
affordable to run at all.

### The correction-signal filter (friction mode)

Only the filter step differs between modes. This is the friction one; the regex that
produced usable results:

```text
no,|nope|wrong|incorrect|not right|actually|again|still|stop|don.t|didn.t|
why did|why are|you (missed|forgot|removed|deleted|changed)|i (told|said|asked)|
revert|undo|that.s not|isn.t (right|correct)|mistake|broke|broken|re-?do|
fix that|never mind|hold on|wait
```

**Tuning notes from the real run:**

- Cap message length (~1500 chars). Long messages are usually new instructions, not
  corrections.
- `"actually"` is the highest-yield single token — it prefixes most gentle corrections.
- Exclude messages containing `tool_use_id` and anything starting with
  `<command-`, `<local-command`, or `<system-reminder`.
- `<ide_opened_file>` and `<ide_selection>` prefixes are noise but the message after
  them is often real — strip the tag, keep the text.

---

### The knowledge-signal filter

**Not yet designed.** The friction regex was validated on a real 28-transcript run; the
knowledge filter has not been built or tested.

What it must keep is different in kind — not a phrasing pattern but a content one:
measurements and numbers with units, decisions and their rationale, options considered
and rejected, and findings that contradict an earlier assumption. A regex may be the
wrong tool; this may need the model to judge each turn.

**Open:** whether the two filters can share step 3 at all, or whether knowledge mode
needs a different reduction strategy to stay affordable.

---

## What it produces

**Friction mode** — a ranked table, highest recurrence first:

| Friction | Times | Cost | Proposed mechanism | Effort |
|---|---|---|---|---|

**Knowledge mode** — proposed additions to the record, each naming its destination file
in K2 (`arc-work/`, `scratch/`, or the wiki).

Every row in either mode must carry a **verbatim quote** as evidence. A cluster without
a quote is an inference, not a finding.

---

## Why an agent, not a skill

| | |
|---|---|
| **Token volume** | Reads megabytes; must not land in the main thread's context |
| **Output shape** | Returns a bounded ranked table — the packet pattern exactly |
| **Judgment** | Clustering "same underlying problem, different words" is genuine judgment |
| **Cadence** | Runs occasionally, not per-turn |

Fits the brief-down/packet-up model without modification. A skill would pull the raw
transcripts into the orchestrator's context, which is the failure this design exists to
prevent.

**Model tier:** mid for extraction and filtering, top for clustering and proposing.
Possibly two agents.

---

## The second-order value

A correction that arrives **after** a skill exists means the skill is wrong, missing a
case, or not firing.

That makes this a **maintenance signal for the plugins themselves** — and it directly
serves the constraint that plugin upkeep must not exceed what it saves. Without it,
skill drift is invisible until it becomes irritating.

| Signal | Meaning |
|---|---|
| New cluster, no skill covers it | Candidate for a new mechanism |
| Cluster persists after a skill ships | Skill is wrong or not triggering |
| Cluster disappears after a skill ships | Mechanism worked — evidence it repaid |

That last row is the only honest way to measure whether a plugin is paying for itself.

---

## Open questions

| Question | Notes |
|---|---|
| **When does it run?** | Not ambient. Candidates: on request, at arc close, or on a counter (same correction three times) |
| **Cross-repo?** | Patterns recurring in *both* ROADZ and TimeScope are portable-skill candidates by definition. Strong argument for scanning all projects, not one |
| **Privacy** | Transcripts contain everything said, including client and employer material. Must stay local; never send transcript content anywhere. A finding may be shareable when the transcript is not |
| **Does it read assistant turns too?** | The hand-run read only user messages. Assistant turns would show *what* triggered a correction, at much higher token cost |
| **Retention** | Transcripts are not forever. Findings should be durable even when the source rotates away |

---

## Related

- [friction-log.md](../../retrospectives/2026-08-plugin-line/friction-log.md) — output of the first hand-run
- [what-the-tools-do.md](../archive/what-the-tools-do.md) §4.4 — job 13, *Learn*
- ROADZ `.claude/skills/engineering-report`, `issue-writing` — both precipitated from
  corrections this mechanism would have surfaced sooner
