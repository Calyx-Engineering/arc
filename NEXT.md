# Next — building Arc

**Written 2026-08-16.** Read [docs/product-architecture/HANDOFF.md](docs/product-architecture/HANDOFF.md)
first for what was decided and why. This file is what to *do*.

---

## The big picture

Arc is the unit of work an engineer runs: kickoff to merge, with checkpoints, a record
that survives the session, and the agents that execute it. Twenty-six mechanisms across
five groups.

**Eleven of them already run** in TimeScope or ROADZ. That is the whole reason Arc is
first in the build order — most of the early work is porting, not inventing.

| Group | Mechanisms | Already running |
|---|---|---|
| Workflow | 6 | 3 |
| Record | 5 | 3 |
| Planning | 5 | 0 |
| Agents | 5 | 5 |
| Self-improve | 4 | 1 |

Source material is in [docs/reference-timescope/](docs/reference-timescope/) and
[docs/reference-roadz/](docs/reference-roadz/) — real working files, copied verbatim,
not to be edited.

---

## Step 1 — map mechanisms onto artifacts

**Do this before writing anything.** The product plan lists mechanisms; a plugin ships
skills, agents, and hooks. **These do not map one-to-one**, and pretending they do
produces a plugin with 26 files that each do a tenth of a job.

Expect consolidation:

| Likely one artifact | Mechanisms it absorbs |
|---|---|
| A **design-time evaluator** hook | Commit rhythm (14) · test obligation capture (23) · probably more later — both are "notice something and nudge" |
| One **issue skill** | `issue-writing` (11) · issue linking (12) · issue write-back (13) — write it, link it, verify it landed |
| One **record skill** | Record routing (16) · K1 upkeep (17) — both answer "where does this go" |
| One **mining agent** | Transcript mining (30) with two filter modes, invoked by the knowledge trigger (19) and the self-improvement loop (31) |

**Deliverable:** `docs/artifact-map.md` — a table with one row per shipped artifact,
naming which mechanisms it covers and which product-plan rows it closes. Nothing is built
until this exists, because it decides the file layout.

**The judgement to apply:** merge when two mechanisms fire at the same moment on the same
data. Keep separate when they have different triggers, even if the subject matter is
close.

---

## Step 2 — the early win, by Monday noon

**One working session. Pick the smallest thing that proves the plugin is real.**

Recommended: **the branch / worktree guard** (row 10).

| Why this one | |
|---|---|
| **Highest-value single mechanism in the plan** | The 08-03 incident cost a whole session; the friction log ranks it #1 at 8+ occurrences |
| **A working example exists** | `reference-timescope/hooks/block_source_edits.js` — port, do not invent |
| **It is one file** | A `PreToolUse` hook. No agent, no skill, no orchestration |
| **It proves the skeleton** | If this fires, the plugin loads, hooks register, and the whole architecture is real |
| **Instantly testable** | Run it standalone with echoed JSON on stdin — no session restart to see it work |

**Scope it tight.** TimeScope's hook covers one check; Arc needs three (branch, worktree,
base freshness). **Ship the branch check only.** The other two are follow-ups, and
shipping one working check beats three half-finished ones.

### What Monday needs

1. `.claude-plugin/plugin.json` — the skeleton. Nothing exists yet; this is the first
   real artifact in the repo.
2. `hooks/branch-guard.sh` — ported from the TimeScope hook, **branch check only**.
3. `tools/verify-hook.sh` — the test harness. Required by CLAUDE.md before any hook is
   registered, and it is the thing that makes hook editing safe from here on.
4. A README line documenting `~/.claude/HOOKS_OFF`.

**Non-negotiable, from CLAUDE.md:** the kill-switch line at the top, fail-open on
unexpected error, verify output pasted before approval, one hook per commit.

### Then soak it

Install locally, work a real ROADZ or TimeScope issue with it live, and let it prove
itself before the next thing is built. **A hook that has never fired is not evidence.**

---

## After the early win

Rough order, in dependency sequence rather than value order:

| # | What | Why here |
|---|---|---|
| 1 | Finish the branch guard — worktree and base-freshness checks | Same file, now with a proven harness |
| 2 | Port the Agents group (25–29) | Five mechanisms, all already written. Mostly copying `agent-process-foundation.md` and the delegate skill |
| 3 | Port `issue-writing` and `engineering-report` (11, 18) | Copy from ROADZ, lift out the project-specific parts |
| 4 | The design-time evaluator | Commit rhythm and test obligation capture together — the first genuinely new build |
| 5 | Session preservation (32) | Prerequisite for mining: without it, K4 has holes and nothing warns you |
| 6 | Transcript mining (30) | The friction filter is proven by hand; the knowledge filter is **not designed** |
| 7 | The self-improvement loop (31) | Depends on 5 and 6, and on there being plugin repos to write to. All three now exist |

**Deferred on purpose:** hardware configuration management (22) and the verification
campaign (24). Both need the interview described in
[friction-log §5](docs/product-architecture/friction-log.md#5-what-still-needs-the-interview).

---

## Things that will bite

| | |
|---|---|
| **The knowledge filter is a stub** | `transcript-mining.md` specs the friction filter properly and marks the knowledge half not-yet-designed. Row 19's state (🟦) is half-true |
| **Hook registration is the dangerous edit** | A bad one breaks every session in every repo. The kill switch and `verify-hook.sh` exist for exactly this; build them before you need them |
| **Soak is easy to skip** | It is also the thing that keeps untested changes off `main`. The record lives in this repo's `arc-log`, appended by whichever repo exercised the change |
| **Doc 04 is mirrored** | A change here must be made in lodestar in the same session |

---

## The prototype bar

Monday noon means: **`git clone`, install the plugin, edit a file on the wrong branch,
and get stopped.** One mechanism, working, with a test harness proving it and a kill
switch making it safe.

That is a real prototype. Twenty-six mechanisms half-scaffolded is not.
