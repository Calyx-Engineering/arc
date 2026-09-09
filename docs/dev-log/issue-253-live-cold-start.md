# Issue #253 — score a live cold start on a real handoff

**Issue:** [#253](https://github.com/Calyx-Engineering/arc/issues/253)  ·  **Parent:** [#146](https://github.com/Calyx-Engineering/arc/issues/146) — Handoff

## The result

**C1 pass, C2 pass**, against a baseline of 5/8 and 4/8. One opening, 2026-09-08 20:38 EDT,
session `d8fadd56` on the handoff `803108a7` wrote 0.0 h earlier. The row, the evidence and what
it does not establish are in
[`handoff-baseline.md`](../arc-work/04-dogfood/handoff-baseline.md#the-live-opening--2026-09-08-beside-the-corpus),
beside #150's eight — the corpus there is closed at `--until 2026-09-06` and a ninth row in it
would move a denominator that has to stay fixed.

**The opening was not this run's to make, and was not made twice.** The first attempt at #253 was
a loop-dispatched issue run that could not create a boundary or write the real handoff — its
reasoning is kept below, because it is why the orchestrating session made the opening instead.
This run scored the record that opening left. *Live, once* held: one opening, spent once.

| Box | |
|---|---|
| 1 · the handoff written at a boundary | Session `803108a7`, `R:/arc/HANDOFF.md`, mtime `20:37:16` EDT |
| 2 · a fresh session opens with `/arc-next` | Session `d8fadd56`, first prompt `2026-09-09T00:38:32.642Z`, `/arc:arc-next` |
| 3 · scored on #150's two criteria | C1 pass, C2 pass. Evidence below and in the baseline |
| 4 · `skills/handoff` fired and ran the checks | Fired — `Skill` call `arc:handoff` at `00:38:36.633Z`, the first tool call. **Not readable from `.claude/arc/log.md`**, which is the box's named instrument |
| 5 · recorded beside #150's baseline | The section named above, with locators |

### C1 — pass

The handoff's *Do these in order* row 1 told the session to note whether the skill fired and what
its first action was, and record it on #253; row 2 was `bash tools/arc-loop.sh --status`. It fired
`arc:handoff` at `00:38:36.633Z` before opening the file, ran the seven staleness checks to
`00:39:48`, ran `--status` at `00:39:04.803Z`, and posted the record at `00:41:10.318Z`. The
user's next message, `00:42:11.554Z`: *"ok continue your process."* No correction, then or later;
at `03:54:12.112Z`, unprompted: *"Also, this is an example of where handoff worked well."*

### C2 — pass, with the surface named

At `00:40:57.547Z`, 74 seconds before the user's first substantive message, the session gave three
reasons for the current approach — autonomy until the playlist completes, four parallel tracks,
one probe track per set — **all three lifted from the handoff's own `Why` and *Load-bearing
decisions* rows.** That is the mechanism [#151](https://github.com/Calyx-Engineering/arc/issues/151)
changed, and the four C2 failures in the baseline are openings whose handoff held the decision
without the reason.

**It was written into the tracker comment the handoff asked for, not into the chat reply.**
Unprompted and inside the opening exchange, which is what the criterion asks; a different surface
from the eight, which is why the baseline says so rather than scoring it silently.

### What the pass does not carry

| | |
|---|---|
| **n = 1** | It moves #146's *Done when* from *no score* to *a score*. It is not a trend against 5/8 and 4/8 |
| **The opening knew it was the measurement** | Handoff row 1 named it as #253's live cold start and asked for half of C1 directly. None of the eight knew |
| **Two findings came out of the checks, not the score** | The handoff's title said `14:40` with an mtime of `20:37:16` — the stamp was not re-stamped on the last write. And `find -newer HANDOFF.md` lists the writing session's own live transcript, nine seconds later, so the check's *never trips by construction* claim holds for the saved copy only |

## Why box 1 was not the first attempt's to do — kept from that run

**Written by the first attempt, in `R:/arc-wt/252`, before the opening existed.** Kept verbatim:
it is the reason the orchestrating session made the opening and an issue run did not.

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

## Why box 4 cannot be read where it says to read it — confirmed after the opening

> *`skills/handoff` fired and ran the staleness checks, read from `.claude/arc/log.md`*

**The activation log records hooks. It does not record skills.**
`hooks/lib/activation-log` states it in its own header — *"NOT A HOOK. It is sourced by one"* —
and `hooks/` holds seven hooks, none of which is a skill.

**Re-counted after the live opening**, across this worktree's `.claude/arc/log.md` — one `awk`
pass classifying every row by its source field, so the parts sum to the whole. **The totals are
a snapshot**: a hook appends on every tool call, so they move while a session runs, and the
zeros are what is stable. At the count, 8,366 rows:

| Row source | Rows |
|---|---|
| `handoff-archive` 1,790, `mode-guard` 1,553, `camp-branch-check` 1,528, `tracker-verify` 1,522, `session-index` 1,480, `camp-session-start` 245, `branch-guard` 245 — the seven hooks | 8,363 |
| `issue-write` — the only skill that appears at all, three rows dated 2026-08-19, from arc 03 | 3 |
| **`handoff`** | **0** |
| **Any of the seven staleness-check names** — `handoff-age`, `transcripts-newer`, `branch-matches`, `tree-accounted`, `commits-accounted`, `open-prs-accounted`, `first-action-issue-open` | **0** |

Zero in the main tree's log too — re-checked on this branch: `handoff` rows 0, `issue-write` 3. `skills/handoff` declares both `camp-reports:` and `checks:`, and
#208 added the seven to that declaration — but a declaration is read by whatever writes the row,
and for a skill nothing does. The three `issue-write` rows are a session having written them by
hand, not a mechanism, and nothing has written one since 2026-08-19.

**A substring count says 27 and is wrong.** `grep -c issue-write` also hits hook rows that name
the skill in their detail, and `grep -c handoff-archive` counts continuation lines as rows. The
figures above are the `awk` classification, which is why they sum.

**The opening then proved it.** `skills/handoff` fired — `Skill` call `arc:handoff`,
`00:38:36.633Z`, the first tool call of the session — and the log says nothing about it. A run
that took box 4 literally would have reported the skill as not having fired when it had. That is
the same shape as #252's third box, found the same way.

**Box 4 is therefore answered from the transcript**, which is the only place the firing is
observable, and the box is left saying so rather than ticked against an instrument that cannot
distinguish success from failure.

## What is still open

| | |
|---|---|
| **An instrument for box 4** | Either a mechanism that writes a skill row to `.claude/arc/log.md`, or the box rewritten against something that exists. #252 hit the neighbouring case and answered it by resolving the qualified skill name to the installed file — the same move may serve here |
| **The stamp and the `-newer` check** | Two findings the opening's own checks produced, recorded on #253 by the session that made them. The stamp was not re-stamped on the last write; `find -newer HANDOFF.md` trips on the writing session's own live transcript, so it needs a tolerance or the writer's session id excluded |

**Nothing was redesigned and no adjacent issue was done instead** — run-instructions §5.

## Evidence

| | |
|---|---|
| `bash tools/handoff-openings.sh r--arc --since 2026-09-08T12:00 --until 2026-09-09T12:00` | 1 cold start, `d8fadd56`, `handoff-read yes`; pair `d8fadd56` ← `803108a7`, written `2026-09-09 00:37`, age 0.0 h |
| Reader transcript | `~/.claude/projects/r--arc/d8fadd56-35a6-42d7-b419-c7dd7ca60bd0.jsonl` — first prompt `00:38:32.642Z`, `Skill` `arc:handoff` `00:38:36.633Z`, why-row written `00:40:57.547Z`, user's next message `00:42:11.554Z`, verdict `03:54:12.112Z` |
| Writer transcript | `~/.claude/projects/r--arc/803108a7-5a24-4535-9a84-28113b5a2ae1.jsonl` |
| Row classification of `.claude/arc/log.md` (one `awk` pass) | 8,366 rows: 8,363 from the seven hooks, 3 `issue-write` from 2026-08-19. `handoff` rows 0; each of the seven check names 0 |
| `hooks/lib/activation-log` | *"NOT A HOOK. It is sourced by one"* |
| `bash tools/verify-all.sh` | 51 gates, all clean (exit 0) at the write-up commit; 52 after the arc tip was merged in, all clean |

**The one-shot opening is spent, once.** Session `d8fadd56`, 2026-09-08 20:38 EDT. It is not
repeatable; a second opening would be a different measurement.
