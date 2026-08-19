# Roadmap

> **The authority on what gets built, and in what order.** The product definition says what
> Arc is made of; this says which parts become real, when, and what blocks what.

Status per mechanism lives in the [product definition](docs/product-architecture/README.md).
This file decides what moves next.

---

## Milestone: the working foundation

**Two passes, one milestone.** Pass 1 is the bar for using Arc on real work; pass 2
continues in the same push and adds the loop that improves it.

### Pass 1 — usable on hardware work

**Goal: Arc is usable on real hardware work.** Not complete, not polished — enough that a
guided arc runs with its record intact and its workspace protected.

The bar: `git clone`, install the plugin, start an arc, work an issue, and have the branch
guard stop a wrong-branch edit, the issue skill write and verify a tracker edit, and the
record survive a cold start.

**This is the gate for real use.** Everything after it is improvement on a working base.

### What ships

| Artifact | Mechanisms | Why in pass 1 | Work |
|---|---|---|---|
| `.claude-plugin/plugin.json` | — | Nothing loads without it | New |
| `tools/verify-hook.sh` | — | Required by CLAUDE.md before any hook is registered | New |
| `hooks/branch-guard` | m10 | Highest-value single mechanism in the plan — the 08-03 incident cost a session | Port, extend |
| `skills/issue-write` | m11 · m13 | Issue style re-taught 6+ times; agreed edits silently not landing | Port, generalise |
| `skills/engineering-report` | m18 | Report style re-taught 12+ times | Port, generalise |
| `skills/chat-response` | m38 | Already here | Soak only |
| `skills/record-route` | m16 · m17 | **The dev-log and arc-log get written.** Without this there is no K1 | Port from TimeScope |
| `skills/handoff` | m15 | Cold starts cost 20+ minutes. Guided hardware work restarts constantly | Build |
| `hooks/tracker-verify` | m12 | Links fail silently; a PR to the wrong base splits a milestone | Build |
| `skills/work-watch` | m14 · m23 · m41 | Commit timing, test obligations, and depth — one sweep | Build |
| `skills/relief-valve` | m41 | The depth check's mechanical precondition, run inside that sweep | Build |
| `skills/camp` | m21 · m43 | Something to ask "where is this arc, what is next" | Build |

**Eleven artifacts. Four are ports of working practice, one is already here, six are new.**

### What waits

| Not in pass 1 | Why |
|---|---|
| Self-improvement — 30 · 31 · 32 · 33 · 39 | **Pass 2**, same milestone. Depends on the rest existing to improve |
| Delegation — 25 · 26 · 29 | Guided hardware work is mostly serial. Delegation pays off in autonomous work |
| Campaign — 9 · 20 · 24 · 27 · 28 | Kickoff and decomposition are judgment an engineer already applies; the arc-log carries the result |
| Configuration management — 22 | Hardware half is undesigned and deferred pending an interview |
| Autonomy switch — 40 | Pass 1 is guided only. The switch matters when both modes exist |
| Knowledge mining trigger — 19 | Its only job is calling `agents/transcript-miner`, which is pass 2's. m32 is the standalone half and ships here |

### Order

Dependencies, not value:

```text
1. plugin.json + verify-hook.sh     ← nothing loads or is testable without these
2. hooks/branch-guard               ← proves the skeleton; one check only, branch
3. skills/record-route              ← everything downstream writes to K1
4. skills/issue-write               ← tracker-verify needs it for repair
5. hooks/tracker-verify
6. skills/handoff                   ← needs record-route for where it lives
7. skills/engineering-report        ← needs record-route for where reports land
8. skills/work-watch                ← needs issue-write to file what it catches
9. skills/camp                      ← needs record-route and handoff
```

**Branch guard ships one check, not three.** Branch only; worktree and base-freshness are
follow-ups. One working check beats three half-finished.

**Soak before the next thing.** Per CLAUDE.md, a change runs against real work before it
leaves the machine. Pass 1 soaks on live hardware work.

---

### Pass 2 — self-improvement

Same milestone, continuing after pass 1 is usable. The loop that keeps Arc improving
without leaving the work.

| Artifact | Mechanisms | Order |
|---|---|---|
| `hooks/session-index` | m32 | 1 — the miner reads what it writes |
| `agents/transcript-miner` | m30 | 2 |
| `hooks/mining-trigger` | m19 | 3 — its only job is calling the miner |
| `agents/improver` | m31 | 4 |
| `skills/plugin-retrospective` | m33 | Already here; needs the miner to be more than manual |
| `scripts/next-mechanism` | m39 | Any time |

**Session preservation first.** Without it K4 has holes and nothing warns you. It also only
indexes transcripts created *after* it ships — anything from pass 1's own work needs
backfilling from `~/.claude/projects/`, which is possible but loses the branch and issue
context that would have been captured live.

**One known gap:** the knowledge filter in
[transcript-mining](docs/product-architecture/mechanisms/m30-transcript-mining.md) is not
designed. The friction filter is validated against a real 28-transcript run.

---

**Before this arc:** [#49](https://github.com/Calyx-Engineering/arc/issues/49) evaluates whether
GitHub Projects replaces this file as the roadmap. A markdown table stops working once waves
run in parallel.

---

## Arc: autonomous execution

**Ports TimeScope's wave-execution tooling.** Arc can decide what runs unattended — the arc-log
records the mode and the stopping point — but has nothing that *runs* it. TimeScope built the
dispatch, the worktree partitioning and the merge sequencing; that is what this arc brings in.

| Artifact | Mechanisms |
|---|---|
| `agents/*.md` · `skills/delegate` | m25 · m26 |
| `skills/wave-plan` | m27 |
| `skills/gate-run` | m28 |
| `skills/kickoff` | m09 · m20 |
| `skills/autonomy-set` | m40 |
| `wiki/` | m29 |

**After the first release.** Foundation pass 2 puts in place what *enables* self-improvement —
session preservation, the miner, the loop — and ships with release one. Porting TimeScope's
execution tooling does not.

**The precondition is the arc below.** Running work unattended without a way to test the
tooling means a defect ships to every repo before anyone notices.

---

## Arc: Arc tests itself

**Nothing in this repository executes a skill.** A skill is written, read against its spec,
and marked done — with no evidence it behaves correctly. Every skill Arc has shipped went out
on that basis.

| Needed | |
|---|---|
| A way to execute a skill against a fixture and assert on the result | The gap |
| Hook tests | `tools/verify-hook.sh` already does this, and is the shape to follow |
| The evaluation sets as runnable cases | m13's six cases exist as prose |
| A regression suite that runs before a release | Nothing today |

**`tools/verify-hook.sh` is the precedent.** It builds real throwaway repositories rather than
mocking, and it caught a real defect the first time it ran. Skills need the equivalent.

**Blocks autonomous execution.** Unattended work multiplies whatever the tooling gets wrong.

---

## Deferred, needing an interview

| Mechanism | Blocked on |
|---|---|
| m22 — Configuration management | Hardware BOM and component-revision practice |
| m24 — Verification planning | How a campaign is planned and results recorded |

Both are named in [friction-log §5](docs/retrospectives/2026-08-plugin-line/friction-log.md#5-what-still-needs-the-interview).

**A related gap surfaced 2026-08-17:** ROADZ's branch-naming vocabulary comes from a BOM
that lives in a Google Sheet, outside version control. Configuration management is not only
"what is in this revision" but "what are the legal names for work."

---

## Spec gaps

Ranked by what they block.

**Every mechanism except 39 and 40 now has a spec.** What remains is what those specs say is
undesigned — a `partial` spec names its own holes.

| Gap | Blocks | What is missing |
|---|---|---|
| m10 — Branch guard | Pass 1, item 2 | Where the guard learns which branch is correct. Two of its three checks have no precedent |
| m17 — K1 upkeep | Pass 1, item 3 | Whether TimeScope's arc-log template survives hardware — it is wave-and-track shaped, and a guided arc has neither |
| m41 — Relief valve | Pass 1, item 8 | The trigger. Four candidates named, all rejected |
| m15 — Handoff | Pass 1, item 6 | Whether issue-level K2 extends the dev-log or sits beside it |
| m30 — Transcript mining | Pass 2 | The knowledge filter. The friction filter is validated against a real run |
| m29 — Agent wiki | Later | Fork, depend, or reimplement — a published plugin already exists |
| m40 — Autonomy switch | Later | **No spec.** Nothing written beyond the row |
| m39 — Mechanism numbering | Pass 2 | **No spec.** Covered by [issue #5](https://github.com/Calyx-Engineering/arc/issues/5) |
| m22 · m24 | Deferred | Both need the interview above |
| Guided flow steps 5–8 | Nothing yet | CAD review, manufacturing package, quoting, PR-as-record have no mechanisms at all. Design review is described in [m28](docs/product-architecture/mechanisms/m28-human-gate.md) but unowned |

---

## Not on the roadmap

The mechanism table's Status column reports where things stand. This file decides what
moves. If a mechanism is not in a pass above, it is not scheduled — which is a statement
about sequence, not about value.
