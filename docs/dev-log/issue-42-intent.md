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

## What the review passes changed

Two rounds. Each round is four passes per artifact, then two consistency passes against every
mechanism that touches them — m11 · m13 · m21 · m41 · m42 · m43 · m44 · m46, plus
`record-route`'s K1–K4 routing and `camp-reports.md`'s declaration format.

**The second round earned its place.** It caught three defects the first round introduced or
missed, including one the first round created while fixing something else.

| | |
|---|---|
| **The ladder had labels and no test** | Added the discriminator: *would "why this arc exists", as written, have covered this if its author had thought of it?* Three names and no way to choose between them is not a classification mechanism |
| **A genuinely unclear call is an *escalate*** | The tie-break was agreed in conversation and never reached the artifact. An unclear case resolved downward is silent drift, which is the one thing this cannot do |
| **An override did not survive the session** | Acceptance requires an override to proceed *without further challenge*; nothing recorded it, so the next session re-read the same `arc-log` and re-raised the same *escalate*. The override is now written against the work it admitted |
| **…but not into the load-bearing decisions** | First draft routed it there. [`record-route`](../../skills/record-route/SKILL.md) sends a decision there only when it constrains **every** issue in the arc, and an override constrains nothing. Caught by the consistency pass, not the review pass |
| **Three blocks existed in two places** | The nudge-strength table in `arc-intent` and `relief-valve`; the user-owned pair in `arc-intent` and `camp`. The skill's own rule is that a second copy is what drifts. Owner keeps it, callers point |
| **A trigger collision** | `camp`'s description still claimed *"whether work belongs in this arc"*, which is now `arc-intent`'s. Two skills competing for one phrase is [#89](https://github.com/Calyx-Engineering/arc/issues/89)'s failure shape |
| **The fourth firing moment was thinner than claimed** | Issue close had no separate call site. It did not need one — `issue-write` runs inside close-sequence step 5. Named there rather than added as a tenth step, because the invariant nine is the point of that document |
| **A [#62](https://github.com/Calyx-Engineering/arc/issues/62) failure, in this issue's own work** | A wording fix was applied in `issue-write` and the identical claim left standing in `arc-intent`'s firing table. Found by the second round, not the first — which is the argument for there being a second round |
| **Work outside any arc was unhandled** | The skill covered *no arc-log* but not *no arc*. Both now skip the check and defer to [m46](../product-architecture/mechanisms/m46-work-navigation.md), which owns discovery outside an arc |
| **A check and an event shared a name** | `override-recorded` appeared in both `camp-reports:` and `checks:`. No sibling artifact overlaps the two lists; the check is now `override-row-written` |

## Length — answering [#90](https://github.com/Calyx-Engineering/arc/issues/90) rather than ignoring it

The first draft added 63 lines to skills already over the 180-line working limit. After the
de-duplication pass:

| | Before this issue | First draft | Now |
|---|---|---|---|
| `issue-write` | 344 | 361 | **355** |
| `camp` | 326 | 342 | **338** |
| `relief-valve` | 159 | 162 | 162 |
| `decompose` | 114 | 120 | 120 |
| `arc-intent` | — | 173 | **192** |

`arc-intent` grew because the review added rules to it. **It sits 12 lines over the limit,
and #90's own escape clause is that a skill which cannot reach 180 without losing a rule says
so — this is that statement.** The two remaining cuts are the m43 §3.1 ladder diagram, which
the issue calls the compact statement of the feature, and the worked case, which is an
acceptance criterion. Neither is a line worth buying back.

**Every skill this issue touched came down from its first draft**, which is the outcome that
matters: the feature no longer makes #90 worse than it found it.

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
