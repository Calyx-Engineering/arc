# Mechanism — Session Preservation

**Status:** specified. Prerequisite for [transcript-mining](transcript-mining.md); pairs with [handoff-spine](handoff-spine.md).
**Home:** Arc — Self-improvement.
**Spawned from:** [friction-log.md](../../retrospectives/2026-08-plugin-line/friction-log.md) §2.4.

---

## The correction that produced this

Earlier in this work it was assumed — and stated to David — that worktree conversations
are lost when the worktree is removed. **That is wrong, and checking it changed the
design.**

### What was actually measured, 2026-08-16

| | |
|---|---|
| Live worktrees in ROADZ | **2** |
| Transcript directories for ROADZ | **4** |
| Directories whose worktree no longer exists | **2** |

The two orphans are `issue-44-poe-pse-onboard` and
`issue-1-flasher-dim-report`. Issue 44 is the exact conversation David reported as lost:

> *"it looks like we lost the conversation from when we completed issue 44. Gosh this is
> a real limitation of claude and worktrees."* — 2026-08-04

It is on disk. 80 lines, spanning 19:45–19:52 UTC on 2026-08-04 — the same day.

### The real failure

**Transcripts survive worktree deletion. What dies is the ability to find them.**

Claude Code stores transcripts under `~/.claude/projects/<path-slug>/`, where the slug
is derived from the *working directory*. A worktree gets its own slug. Delete the
worktree and the directory remains — orphaned, named after a path that no longer
exists, with nothing linking it to the issue, branch, or arc it belonged to.

| Assumed problem | Actual problem |
|---|---|
| Data is deleted | Data persists |
| Unrecoverable | Recoverable, but unfindable |
| Needs backup | Needs **an index and a link to work artifacts** |

**Lesson recorded on purpose:** the claim "worktree conversations are lost" was
plausible, matched the user's experience, and was false. The user's experience was of
*not being able to get at them*, which is a different defect with a different fix.

---

## Why this matters beyond recovery

Hardware development happens *in* these conversations. The transcripts hold:

- Measurements taken at the bench and reasoned about once
- Options considered and rejected before anything was written down
- Corrections that never made it into a report or a wiki page
- The reasoning behind a decision the dev-log states only as a conclusion

Two other mechanisms depend on this material being findable:

| Mechanism | Depends on |
|---|---|
| [transcript-mining](transcript-mining.md) | Complete coverage — orphaned directories are invisible to a per-project scan |
| [handoff-spine](handoff-spine.md) | Being able to answer "what happened in that worktree?" during rehydration |

The first hand-run of transcript mining found the orphans **only because the search was
a wildcard glob across all project directories**. A scan scoped to the current repo's
slug would have silently missed 55 MB of the richest material.

---

## Proposed shape

### 1. Index, do not copy

Copying transcripts duplicates gigabytes and creates drift. Maintain a small index
instead:

| Field | Example |
|---|---|
| Transcript directory slug | `R--...-worktrees-issue-44-poe-pse-onboard` |
| Worktree path (may no longer exist) | `.claude/worktrees/issue-44-poe-pse-onboard` |
| Branch | `interface-pcba/rev_b-issue-44-...` |
| Issue | `#44` |
| Arc | `interface-pcba/rev_b` |
| Date span | `2026-08-04` |
| Status | worktree removed |

Committed to the repo, so the mapping outlives both the worktree and the machine.

### 2. Capture the mapping when the worktree is created, not when it is deleted

At deletion the branch and issue context may already be gone. At creation everything is
known. **The index entry is written at worktree creation** and marked orphaned later.

### 3. Distil before deletion — knowledge mining

**A distinct mechanism from friction mining, sharing its pipeline.** Same extraction,
different filter, different destination.

| | Friction mining | **Knowledge mining** |
|---|---|---|
| Looks for | Corrections — where the tooling failed | **Findings** — measurements, rejected options, reasoning |
| Output | Ranked mechanism candidates | **Content for `scratch/`, `arc-work/`, the wiki** |
| Improves | The plugins | **The project record** |
| Runs | End of a work stretch | **Before a worktree closes; at arc close** |
| Home | Arc — Self-improve | **Arc — Record** |

**Why it is worth building.** Transcripts hold reasoning that never reaches any document:
a bench observation made in passing, an option dismissed in one line, the number that
settled an argument. That material sits in **K4** — too incidental for a scratch
file at the time, too valuable to lose — and it evaporates when a worktree is removed.

**What it produces:**

| Found in transcript | Goes to |
|---|---|
| A measurement and what it meant | `scratch/issue-NN-.../` |
| A finding that spans issues | `arc-work/<arc>/` |
| A durable product fact | The wiki, via the graduation path |
| An option considered and dropped | The dev-log's *Rejected approaches* |

### When it runs — PR time, not worktree removal

**Worktree removal is the wrong trigger.** Measured in ROADZ, 2026-08-16:

| Where work happens | Transcript directory | Does a removal ever fire? |
|---|---|---|
| A worktree (`issue-1-dimmer-flasher`) | Its own slug | Yes |
| **The main repo, branch checked out in place** (`issue-39`) | **Shared with every other branch** | **Never** |

ROADZ's #39 work is on a branch in the main repo, not a worktree. A removal-based trigger
would **never fire for it**, and its 18 transcripts pile into one directory spanning every
branch ever checked out there — no per-issue boundary at all.

**Use PR creation instead.** It is issue-scoped, already happens, and fires whether or not
a worktree is involved. It also coincides with the dev-log's retrospective checkpoint, so
distillation and the retrospective are one moment.

| Trigger | Fires for worktrees | Fires for in-place branches | Issue-scoped |
|---|---|---|---|
| Worktree removal | Yes | **No** | Yes |
| **PR creation** | **Yes** | **Yes** | **Yes** |

**Keep worktree removal as a backstop** — a last-chance sweep for anything that never
reached a PR. It is a safety net, not the primary trigger.

**Run while the context is live.** At PR time the branch, issue, and reasoning are all
present; weeks later the transcript is an orphan with no anchor.

**Scoping the read.** For in-place branches the transcript directory is shared, so the
distillation pass must filter by time window or by branch rather than reading the whole
directory.

**Never write silently.** Same rule as friction mining — propose the distillation, let
the human confirm before it lands in a committed document.

### 4. Retention is a real risk

Transcripts are not guaranteed forever — they can be rotated, cleaned, or lost with the
machine. Anything that matters must be distilled into a committed artifact. **The
index makes transcripts findable; it does not make them durable.**

---

## Open questions

| Question | Notes |
|---|---|
| Who writes the index entry? | A worktree-creation hook is the natural point. Arc territory |
| Distil automatically on removal, or prompt? | Automatic risks a slow, expensive pass at an inconvenient moment |
| How much survives distillation? | A page per worktree is probably right; a paragraph is too little |
| Cross-machine? | Desktop and laptop have separate transcript stores. The index is committed; the transcripts are not |
| Does this generalise beyond worktrees? | Any directory rename orphans a transcript directory the same way |

---

## Related

- [friction-log.md](../../retrospectives/2026-08-plugin-line/friction-log.md) §2.4 — session context loss
- [transcript-mining.md](transcript-mining.md) — consumer of this data
- [handoff-spine.md](handoff-spine.md) — the live-state counterpart
