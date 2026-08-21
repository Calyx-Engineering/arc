# Issue #73 — the autonomy switch

> Decision log, not a spec. Started at plan time, finalised as a retrospective at PR time.

**Issue:** [#73](https://github.com/Calyx-Engineering/arc/issues/73)  ·  **PR:** —

## Problem

Auto mode has been declared three to five times and has never once run. Every attempt wrote a
document; none changed behaviour. The most recent, [PR #100](https://github.com/Calyx-Engineering/arc/pull/100), added a permission allow-list
and was credited with five unattended merges — and [PR #114](https://github.com/Calyx-Engineering/arc/pull/114) was then denied twice with
that file unchanged, merging on the first attempt after the user asked.

## Intent and north star

### Pass 1 — from the issue body alone

| | |
|---|---|
| **What this is really for** | Not writing m40. m40 not existing is a symptom — auto mode has been specified in prose repeatedly and prose is what keeps failing |
| **North star (pass 1)** | The mode is a switch with state, not an instruction to be remembered, and it is portable to a fresh repository |

### Pass 2 — after reading the four contradicting artifacts, `close-sequence`, `work-watch` check 1, `templates/handoff.md`, and friction entries 1, 2 and 4

**Five things changed. The fourth is the one that explains the failures.**

| | |
|---|---|
| **The acceptance criteria are the user's three, not the issue's checklist** | Added to the issue this session. The north star is tested against them |
| **Scope changed from spec-only to spec-and-build** | The issue's own constraint said *"scoping, not building"*. Three to five attempts have shipped a document and no behaviour; a spec that merges without its artifacts is the fourth |
| **`work-watch` already names *under-commit* as a failure** | Check 1 has both directions — *"nothing committed because nobody asked"* is listed as a cost. **The skill is not the problem; the mechanical rule table below it is**, and that table has no exception |
| **The prohibition is refreshed constantly; the permission is read once** | `CLAUDE.md` is in context every turn. `work-watch` is registered always-on and declares `checks: [commit-point, …]`. The arc-log's §6.1.1 is read once at session start. **Of course the prohibition wins** — it is restated on every turn and the permission decays with the context that held it |
| **The dead link the issue names is already gone** | `docs/arc-log/arc-03-camp.md` no longer links `m40-autonomy-switch.md`. One required box is already satisfied |

**North star.** Auto mode stops being something the session must remember and becomes state the
session can read. Specifically, the user can do three things:

> - A document like the arc-log defines an execution plan with the autonomous switch set, and **it executes correctly**
> - Saying *"switch to autonomous"* in chat enters auto; *"switch back to manual"* leaves it
> - **It returns to manual on its own when conversation starts** — entering auto is always explicit, returning never has to be

And the reason it will hold this time: **the permission lives in the same artifacts as the
prohibition, read at the same frequency.** Every place that says *never commit unasked* says
what auto mode does instead, in the same row. Nothing defers to a document read once.

| | |
|---|---|
| **What makes it durable** | It survives a fresh repository with no `CLAUDE.md` of ours. It survives the session forgetting, because the mode is written down and re-read. It survives a new prohibition being added, because a script fails when one appears without its auto clause |
| **Out of scope** | Beating the harness classifier. Nothing in the plugin can, and the spec must say so rather than implying otherwise — that conflation is what three previous attempts were built on |

### Intent check

**Agreed.** The user moved [#73](https://github.com/Calyx-Engineering/arc/issues/73) back into
this arc's milestone explicitly and instructed the work. *Why this arc exists* names Arc's
operation being invisible as one of the two failures Camp exists to fix; a mode nobody can see
the state of is that failure exactly.

## The design

**Three states, not two.** Two states cannot express what the user asked for in criterion 3.

| State | Means | Entered by |
|---|---|---|
| **Manual** | The floor. Work stops at the edit; nothing is committed | The default, and any explicit return |
| **Autonomous** | Executes the ordered actions to a named boundary — commits, pushes, opens PRs, merges | **Explicitly, always** |
| **Autonomous, suspended** | Auto is still set, but this exchange is a conversation and is answered, not executed | **Inferred** — a question, a correction, or anything that is not the named next action |

**Suspension is the whole answer to criterion 3.** Cancelling auto on every question would make
a wave un-runnable — one clarification and the plan is off. Suspension keeps the mode set,
answers the human, and resumes when they point back at the work. It is also what actually
happened in the session that filed this: the run stopped merging and started answering, which
was correct, and no artifact told it to.

### Where the mode lives

**In the handoff's *Execution mode* row.** Not a new file.

| | |
|---|---|
| **It already exists** | `templates/handoff.md` carries the row, and says *"Never infer it — if this row does not say autonomous, it is manual"* |
| **The user can see it** | A mode the user cannot observe is a wrong belief that only surfaces after an unwanted push |
| **It survives the window** | Which is the entire argument for the handoff being a document |
| **A mid-session switch rewrites it immediately** | Not at the next break. The row is the state, so it is wrong the moment it lags |

**A second store was rejected.** `.claude/arc/mode.md` would be a second source of truth for one
fact, and the two would disagree — the failure [#105](https://github.com/Calyx-Engineering/arc/issues/105) exists to fix, created deliberately.

### The permission travels with the prohibition

**This is the load-bearing decision.** Each of the four artifacts keeps its rule and gains the
auto clause in the same row — not a cross-reference to m40.

| Artifact | Today | After |
|---|---|---|
| `CLAUDE.md:23` | Never commit unasked | Never commit unasked **in manual, which is the default.** In auto, commit at the cadence the plan names |
| `skills/work-watch` | *Standing. Propose and wait* | Propose and wait **in manual**; in auto, commit at the capture points check 1 already defines |
| `m14-commit-rhythm.md` | *Standing instruction* | The same, scoped to manual, with the switch named |
| `close-sequence.md:27` | Step 8 — **User merges** | **Whoever the mode says** — the user in manual, the agent in auto |

**Why not a single cross-reference.** A rule that says *"see m40"* is read once; the rule beside
it is read every turn. The asymmetry in how often the two are read is the mechanism that has
defeated every previous attempt, and duplicating one clause four times is the cost of fixing it.
`tools/verify-autonomy.sh` is what keeps the four copies honest.

### What the switch cannot do, stated in the spec

Auto mode does not change what the harness permits. On a denial: **record it, hand it over,
retry at most once.** Never treat a denial as a fact about the world — friction entries 1 and 4
are both a wrong diagnosis reached from a single session's denials.

## Plan

| | |
|---|---|
| 1 | `docs/product-architecture/mechanisms/m40-autonomy-switch.md` — the spec. Three states, where the mode lives, entry and exit, the announcement, the self-test, the harness boundary |
| 2 | `skills/autonomy-set/SKILL.md` — the switch. Already reserved in the registry's artifact table |
| 3 | The four artifacts gain their auto clause, in the same row as the rule |
| 4 | `close-sequence` steps 8 and 9 become mode-dependent |
| 5 | `templates/handoff.md` gains the suspended state and the rule for inferring it |
| 6 | `tools/verify-autonomy.sh` — fails when an artifact states a prohibition with no auto clause, when the registry or ROADMAP still call m40 unspecified, or when the mode vocabulary drifts |
| 7 | Registry row, ROADMAP row, arc-log §9 and §10, and the sync |

## Decisions & trade-offs

## Rejected approaches

## Retrospective
