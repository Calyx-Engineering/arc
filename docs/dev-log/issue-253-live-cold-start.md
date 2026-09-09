# Issue #253 — score a live cold start on a real handoff

**Issue:** [#253](https://github.com/Calyx-Engineering/arc/issues/253)  ·  **Parent:** [#146](https://github.com/Calyx-Engineering/arc/issues/146) — Handoff

## Status: blocked, not done

No box was ticked and the one-shot measurement was **not spent.** Two of the five boxes cannot be
satisfied by an issue run, and the other three depend on the first. The reasons are below so the
next attempt starts from them rather than rediscovering them.

## Why box 1 is not this run's to do

> *The orchestrating session writes the real `HANDOFF.md` with `skills/handoff` at a set boundary*

| | |
|---|---|
| **It names a different actor** | The orchestrating session is the one in the main tree. This is a loop-dispatched issue run in `R:/arc-wt/252`, handed two issue numbers by `tools/arc-loop.sh` |
| **The real handoff is in the main tree** | `R:/arc/HANDOFF.md`, gitignored, headed *2026-09-09 00:50*. Run-instructions §4: *never `cd` to the main tree — another run, or the orchestrator, is working in it.* That tree is demonstrably in use, paused mid-work on `arc/04-dogfood-issue-145-fire-review` with uncommitted changes |
| **This worktree's `HANDOFF.md` is not a handoff** | It is `arc-loop.sh`'s mode stub, and says so in its own second line: *"It is not a session handoff."* Writing a plausible one here would not make it the real one |
| **No boundary is set** | The real handoff's *Live now* row lists five worktrees running S7, this one among them. A boundary is where the orchestrator stops and hands over; S7 is mid-flight and an issue run cannot declare one |

**The constraint is what makes guessing expensive.** *Live, once. One opening is the unit. A
second attempt after a correction is a different measurement.* Spending the single opening on a
handoff this run invented would measure the invention, and #146's *Done when* would still have no
moved score — with the unit gone.

## Why box 4 cannot be read where it says to read it

> *`skills/handoff` fired and ran the staleness checks, read from `.claude/arc/log.md`*

**The activation log records hooks. It does not record skills.**
`hooks/lib/activation-log` states it in its own header — *"NOT A HOOK. It is sourced by one"* —
and `hooks/` holds seven hooks, none of which is a skill.

Counted across the whole of this worktree's `.claude/arc/log.md`, 27,446 lines:

| Row source | Rows |
|---|---|
| `handoff-archive`, `mode-guard`, `camp-branch-check`, `tracker-verify`, `session-index`, `camp-session-start`, `branch-guard` — the seven hooks | 6,935 |
| `issue-write` — the only skill that appears at all, three rows dated 2026-08-19, from arc 03 | 3 |
| **`handoff`** | **0** |
| **Any of the seven staleness-check names** — `handoff-age`, `transcripts-newer`, `branch-matches`, `tree-accounted`, `commits-accounted`, `open-prs-accounted`, `first-action-issue-open` | **0** |

Zero in the main tree's log too. `skills/handoff` declares both `camp-reports:` and `checks:`, and
#208 added the seven to that declaration — but a declaration is read by whatever writes the row,
and for a skill nothing does. The three `issue-write` rows are a session having written them by
hand, not a mechanism.

**So box 4 would read empty after a successful opening exactly as it reads empty now**, and a run
that took the box literally would report `skills/handoff` as not having fired when it had. That is
the same shape as #252's third box, found the same way, and it is worth more here: #253 gets one
opening, and a box that cannot distinguish success from failure would waste it.

## What was not done, and what it would take

Boxes 2, 3 and 5 all need box 1's handoff to open on, so none was attempted.

| Needed before this issue can run | |
|---|---|
| A real boundary, and the orchestrating session at it | Not an issue run's to create |
| An instrument for box 4 | Either a mechanism that writes a skill row to `.claude/arc/log.md`, or box 4 rewritten against something that exists. #252 hit the neighbouring case and answered it by resolving the qualified skill name to the installed file — the same move may serve here |

**Nothing was redesigned and no adjacent issue was done instead** — run-instructions §5.

## Evidence

| | |
|---|---|
| `grep -c "handoff-age" .claude/arc/log.md` | 0. Same for the other six check names, and for a `handoff` row |
| `grep -c "handoff-age" /r/arc/.claude/arc/log.md` | 0 |
| `hooks/lib/activation-log` | *"NOT A HOOK. It is sourced by one"* |
| `ls hooks/` | seven hooks, no skill among them |
| `head -1 /r/arc/HANDOFF.md` | `# Handoff — 2026-09-09 00:50`, listing five live S7 worktrees including this one |
| `head -3 HANDOFF.md` | this worktree's is `arc-loop.sh`'s mode stub, *"It is not a session handoff"* |

**The one-shot opening is unspent.** No `claude` session was opened on any handoff for this issue.
