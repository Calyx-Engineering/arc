# Issue #42 — Obligation 0, holding the arc's intent

> Decision log, not a spec. Started at plan time, finalised as a retrospective at PR time.

**Issue:** [#42](https://github.com/Calyx-Engineering/arc/issues/42)  ·  **Spec:** [m43 §3.1](../product-architecture/mechanisms/m43-camp-assistant.md)

## Problem

Work diverges from an arc's stated intent while every individual step looks reasonable. The
divergence is only visible against the destination, and nothing in Arc holds the destination
and tests proposed work against it.

**This is one level above the drift [m41](../product-architecture/mechanisms/m41-relief-valve.md)
addresses.** The relief valve catches a conversation that has gone too deep; obligation 0
catches work that is going somewhere the arc did not agree to go.

**The judgement is the deliverable, and it has no mechanical test.** *"Does this serve the
arc's intent"* cannot be computed, which is why the answer is a three-level ladder ending in
a question rather than a pass/fail.

## Decisions & trade-offs

| | |
|---|---|
| **Its own skill, not a section inside `skills/camp`** | `skills/arc-intent/`. Four different artifacts fire it — `decompose` on issue spawn, `issue-write` at PR open, `relief-valve` on depth, `camp` when asked. A section inside Camp would be a capability three artifacts reach into Camp to borrow. Same reasoning that put `decompose` outside Camp in [#47](https://github.com/Calyx-Engineering/arc/issues/47), and `close-sequence.md` outside it in [#41](https://github.com/Calyx-Engineering/arc/issues/41) |
| **A skill, never a hook** | The firing moments are detectable in bash — `gh issue create`, `gh pr create` — but the answer is judgement, and a hook that detects the moment and cannot answer it is a hook that fires an empty report. [#43](https://github.com/Calyx-Engineering/arc/issues/43)'s hooks check mechanical properties of a command; this checks the work against a paragraph of prose |
| **No new artifact holds the intent** | m43 §3.1.1. The `arc-log`'s *Why this arc exists* and *Load-bearing decisions* already are the intent. A second copy drifts from the first, and then nothing knows which is the destination |
| **It shares the relief valve's precondition rather than carrying its own** | m43 §3.1.3. Excessive depth is commonly a symptom of drift, so one trigger serves both — no second over-firing budget to tune, and no second set of provisional thresholds to correct in [#36](https://github.com/Calyx-Engineering/arc/issues/36) |
| **Three levels, because a binary block gets routed around** | *Agreed · Derived · Escalate*, matching Star's ladder. The middle level is what keeps the mechanism usable: most real work is a reasonable consequence of the intent rather than a restatement of it, and a two-level ladder would classify all of it as drift |
| **Escalate is a question, and the user's answer ends it** | The acceptance criterion phrased as a refusal-to-refuse: after the user decides, Camp proceeds without re-raising it. A flag that survives its own answer is a flag the proposer learns to route around, which is the failure the ladder exists to avoid |
| **The intent is user-owned and Camp cannot revise it** | m43 §3.1. This is the property that makes obligation 0 a delegate rather than an observer — the flag cannot be argued away by the thing that proposed the work |
| **The classification is reported, including when it is *agreed*** | The `camp-reports:` rule — state what was checked, not only what was found. An obligation that only speaks on escalate is indistinguishable from one that never ran |

## What this issue does not build

| | Where it lives |
|---|---|
| The intent itself | The `arc-log`, already written for every arc |
| The precondition that fires it on depth | [`relief-valve`](../../skills/relief-valve/SKILL.md), built by [#44](https://github.com/Calyx-Engineering/arc/issues/44) |
| The issue-spawn moment | [`decompose`](../../skills/decompose/SKILL.md), built by [#47](https://github.com/Calyx-Engineering/arc/issues/47) |
| The PR-open moment | [`issue-write`](../../skills/issue-write/SKILL.md) |
| The report's format | [`camp-reports.md`](../product-architecture/camp-reports.md), built by [#45](https://github.com/Calyx-Engineering/arc/issues/45) |

**Reading history to find past errors is the retrospective's job**, and m43 §3.1.3.2 rejects
firing obligation 0 from the event log. Obligation 0 evaluates direction, not the past.

## The diagram walk — m43 §3.1

Required before the PR. m43 §3.1 carries **two** diagrams, and every node in both is
something this issue delivers.

### The ladder — §3.1

| Node | Delivered by |
|---|---|
| Work is proposed | The four call sites — `decompose` step 6, `issue-write`'s pre-write section, `relief-valve`'s direction question, `camp`'s obligation 0 section |
| Does it serve the arc's stated intent? | *The intent lives in the `arc-log`* — the two sections read, and the refusal to classify when there is no arc-log |
| **Agreed** — proceed without comment | The ladder table. Reported, but nothing said in conversation |
| **Derived** — say so, then proceed | The ladder table, with the one-line phrasing |
| **Escalate** — stop and ask | *Escalate never blocks* — it states the observation and asks |
| **User decides** | *The intent is user-owned.* Camp cannot revise the intent; the `arc-log` is amended by the user, in a diff |
| User decides → Agreed | *The user's answer ends it* — no second raising, no re-classifying at the next firing moment |

### When it fires — §3.1.3

| Node | Delivered by |
|---|---|
| An issue is spawned | `decompose` step 6, before the set is presented |
| An issue closes, a PR opens | `issue-write`'s *Before the write*, and the `arc-intent` check in its declaration |
| The user asks | `camp`'s obligation 0 section |
| The relief valve fires on depth | `relief-valve`'s direction question, now answered on the ladder |
| The question, and Agreed · Derived · Escalate | One ladder, reached from all four moments |

**No mismatch found.** Both diagrams are delivered whole.

## Open

- **Nothing here has been executed.** No skill runs in this repo, so every acceptance
  criterion written as runtime behaviour — the escalate phrasing, the override being honoured,
  the refusal to re-flag — is unverified. Same status as every issue in this arc
- **The self-detection limit is real and unsolved.** Three of the four call sites fire from a
  mechanical moment, which is what keeps it from being pure self-awareness. The independent
  observer that would remove it is deferred in m43 §4, at the same cost as the relief valve's
- **`skills/camp` grew rather than shrank.** [#90](https://github.com/Calyx-Engineering/arc/issues/90)
  flags it at 326 lines against a 180 limit; obligation 0 added roughly fifteen. Putting the
  ladder in its own skill kept that number from being much larger, but it did not reverse it
