---
name: handoff
description: Use at a cold start to rehydrate from the previous session in one read, and at session end, issue close, or branch change to write what the next session needs. Covers what the handoff holds, the ordered actions the next session executes, saving the transcript, the three-line prompt that starts the next chat, what belongs in the committed record instead, and why it is a document rather than a chat window.
camp-reports: [handoff-written, handoff-read, transcript-saved]
checks: [handoff-exists, ordered-actions-present, transcript-saved, open-threads-carried, graduated-to-record, stale-rows-removed]
skips:
  - graduated-to-record (nothing in the handoff outlives the arc)
---

# The handoff

> **The read path is the point.** The write is what makes a one-read cold start possible;
> it is not the deliverable.

Cold starts cost 20+ minutes and sometimes send the work down the wrong path. Guided
hardware sessions run at 250k+ context, so **starting fresh is necessary rather than
accidental** — this mechanism does not try to prevent restarts, it makes them cheap.

---

## Reading — at a cold start

**Read `HANDOFF.md` first, before anything else.** Before exploring the tree, before
`git log`, before opening a spec. It names the reading order for everything else, and
reading in the wrong order is what makes a cold start expensive.

Then, and only what it points at:

| Order | Read | Why |
|---|---|---|
| 1 | `HANDOFF.md` | Where we are, and what to read next |
| 2 | The repo's `CLAUDE.md` | How this repo works |
| 3 | The arc-log for the current arc | K1 — the arc's shape and its load-bearing decisions |
| 4 | The dev-log for the current issue | K1 — this issue's *why* |
| 5 | Whatever those name | K2 and below, **only when the work touches it** |

**Do not read the whole record.** Five finished arcs and fifty closed issues are history,
not context. Loading all of K1 reproduces the exact failure the ladder exists to prevent.

### When the current issue has no dev-log yet

A dev-log is created at plan time, so **the first session on an issue arrives before one
exists.** The reading order then has a hole exactly where the issue's *why* should be, and a
cold session fills it by inference — which is the failure this skill exists to prevent.

**The handoff carries the issue's scope in one line until the dev-log exists.** Not a
summary of the issue body; the sentence that says what this issue is for. Once the dev-log
is written, the line is redundant and the reading order takes over.

If you arrive and find neither, **write the dev-log first** — that is step one of the work,
not a detour from it.

If you finished this list and still do not know what to do next, **that is a finding, not a
personal failing** — record it in the handoff's open threads. The mechanism is being tested
every time it is used.

---

## Writing

### When

| Moment | |
|---|---|
| **Session end** | The obvious one, and the one most often missed |
| **A planned break** | A long arc does not fit one context window. The window ends at the break, so the handoff is written and confirmed before it closes |
| **Issue close** | The tree and status changed |
| **Branch change** | Where-we-are is now wrong |
| **Before any handoff** | Including a compaction |

**Not continuously.** Per-turn churn is narration by another name.

At a break the order is fixed: **save the transcript, write the handoff, say it was written,
give the prompt for the next chat.** The transcript is saved first so the handoff can name
it.

### What it holds

Every section below exists because something was missing at a real failed cold start.

| Section | Holds | Prevents |
|---|---|---|
| **Where we are** | Current issue, branch, worktree, what was just finished | Work landing on the wrong branch |
| **Do these in order** | The numbered actions the next session executes, top to bottom | A session that knows the state and still asks what to do |
| **The tree** | Issues and what spawned them, with status | A flat list losing the shape of hardware work |
| **Load-bearing decisions** | What must not be re-litigated | A fresh session re-opening settled questions |
| **Open threads** | Agreed but unfiled follow-ups, and unresolved questions | *"i asked you to update #12 … that didn't happen"* |
| **What was ruled out** | Causes checked and eliminated, with what eliminated them | The next session re-deriving what this one already disproved |
| **Next action** | One line, concrete — the first row of *do these in order* | The "what now?" round trip |
| **Do not** | Live traps — wrong branch, do not commit, do not rewrite that file | Repeating a correction already given |

### The ordered actions are the working half

**Where we are is state. *Do these in order* is instruction.** A handoff carrying only
state produces a session that knows exactly where things stand and still opens by asking
what to do — the round trip the mechanism exists to remove.

| A row is | Not |
|---|---|
| An action, numbered, executable top to bottom | A topic, or an area to look at |
| Concrete enough to start without asking | *"continue the arc"* |
| Carrying its issue number, branch and the one constraint that changes how it is done | A restatement of the issue body |

Order by dependency, not importance. **When a row must be done before another is even
readable, say so in the row** — an approval that has already been given, a file that must be
read first, a branch that does not exist yet.

**Rows come off the top and the rest renumber.** The list is working state, not a plan: the
next session rewrites it when it hands off.

---

### Saving the transcript

**A step in writing the handoff, not a separate chore.** The handoff records conclusions;
the transcript is the only place the reasoning behind them survives, and it is what a
retrospective and any transcript mining read later.

| | |
|---|---|
| **Source** | The live session file — in Claude Code, `~/.claude/projects/<project-slug>/<session-id>.jsonl`, newest by mtime |
| **Destination** | Outside the repo, and never committed. It contains the whole session |
| **Naming** | `YYYY-MM-DD-arc<NN>-<topic>.jsonl` — sortable, and says which arc it belongs to |
| **When** | At the break, **before** writing the handoff — so the handoff can name the file it saved |

The destination is per-machine setup, so name it in the repo's `CLAUDE.md` or the handoff's
own *transcripts* note rather than leaving it to be supplied each time.

#### A saved transcript is stale the moment it is written

It stops at the save. Everything decided afterwards — including the decision to save — exists
only in the live session file.

> **When reading a transcript for a decision, read the live source, not the saved copy.**

This has already misled a session: a decision agreed after the save was absent from the
saved copy, and the copy was read as though it were complete. The saved file is an archive,
not the current state.

---

### The prompt that starts the next chat

**The handoff is the payload. The prompt is a pointer to it.**

A prompt that restates where we are creates a second copy of the state, and the two drift
immediately — the next session then has two sources disagreeing and no way to tell which is
current.

Three lines, and nothing that is already in the handoff:

```text
Read HANDOFF.md first, then do the steps in "Do these in order".
Branch is arc/03-camp-issue-61-handoff-prompt.
Next is #61 — the handoff's ordered actions and transcript save.
```

| The prompt carries | The prompt never carries |
|---|---|
| *Read `HANDOFF.md` first* | The tree, the status table, the open threads |
| The branch | Load-bearing decisions |
| The next step, by issue number | A summary of what was just finished |
| Anything **not** in the handoff — a standing approval, an instruction for how to work | Anything the handoff already says |

**The last row is the only reason a prompt is more than one line.** An approval given in
chat, or an instruction about how the next session should run, has no home in the handoff —
so it goes in the prompt. Everything else has a home, and belongs there.

**Give the prompt as a copyable block**, not as prose describing what to paste.

---

### What does NOT go in it

| Not here | Where |
|---|---|
| Why a decision was made | The dev-log. The handoff says *what was decided*, not the reasoning |
| Measurements, analysis, rejected topologies | K2 — `scratch/` or `arc-work/` |
| Anything true after this arc ends | The wiki. The handoff dies with the arc |
| A narrative of the session | Nowhere. Nobody reads it |

**The test:** if a fact would still be true and useful in six months, it belongs in the
committed record, not here.

---

## It is gitignored, and that is deliberate

`HANDOFF.md` is session-scoped working state. It is **not** part of the record.

| | Handoff | Arc-log |
|---|---|---|
| Lifetime | This arc, then deleted | Committed, permanent |
| Scope | Where we are *right now* | What was decided and built |
| Committed | **No** | Yes |
| Audience | The next session, today | Anyone, later |

Committing it means the record contains a file that is stale the moment it is written, and
a fresh session cannot tell which of two overlapping documents to trust.

**Add `HANDOFF.md` to `.gitignore` when starting an arc in a new repo.** It is the one
setup step this skill needs.

**At arc close, delete it.** Anything in it worth keeping was already promoted to the
arc-log or a dev-log. If deleting it feels lossy, something skipped a tier — find what and
put it where it belongs.

---

## Why a document and not a chat window

TimeScope holds arc state in a coordinating chat window. That window dies under context
pressure, and hardware work kills windows constantly. So the spine is inverted:

> **The spine is a document. Any fresh session becomes the spine by reading it.**

The same reasoning rules out putting arc state anywhere that must stay alive — a running
agent, a held context, an open tab.

---

## The failure mode to watch for

A handoff that grows until reading it is itself expensive is **the spine window's failure,
relocated to a file.** It stays one screen. When it does not fit, the excess is almost
always reasoning that belongs in a dev-log, or detail that belongs in K2.

---

## Template

[templates/handoff.md](../../templates/handoff.md). Copy it rather than writing from memory
— the section list is the mechanism, and a handoff missing *do not*, *open threads* or *do
these in order* fails in exactly the way those sections exist to prevent.

**The title carries a date and a time**, `YYYY-MM-DD HH:MM`. It is the only thing in the
document that says when the state it describes was true, and the next session reads it to
decide whether to trust the rest. A date alone cannot distinguish a handoff written an hour
ago from one written before a full day's work in another window.
