---
name: handoff
description: Use at a cold start to rehydrate from the previous session in one read, and at session end, issue close, or branch change to write what the next session needs. Covers what the handoff holds, what belongs in the committed record instead, and why it is a document rather than a chat window.
---

> **Copy — do not edit.** The source is [`skills/handoff/SKILL.md`](../../../skills/handoff/SKILL.md),
> which is what the plugin ships. This copy exists only so the skill is live in this repo
> before Arc is installed here. **Edit the source, then re-run `tools/sync-local-skills.sh`.**


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
| **Issue close** | The tree and status changed |
| **Branch change** | Where-we-are is now wrong |
| **Before any handoff** | Including a compaction |

**Not continuously.** Per-turn churn is narration by another name.

### What it holds

Every section below exists because something was missing at a real failed cold start.

| Section | Holds | Prevents |
|---|---|---|
| **Where we are** | Current issue, branch, worktree, what was just finished | Work landing on the wrong branch |
| **The tree** | Issues and what spawned them, with status | A flat list losing the shape of hardware work |
| **Load-bearing decisions** | What must not be re-litigated | A fresh session re-opening settled questions |
| **Open threads** | Agreed but unfiled follow-ups, and unresolved questions | *"i asked you to update #12 … that didn't happen"* |
| **Next action** | One line, concrete | The "what now?" round trip |
| **Do not** | Live traps — wrong branch, do not commit, do not rewrite that file | Repeating a correction already given |

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
— the section list is the mechanism, and a handoff missing *do not* or *open threads* fails
in exactly the way those sections exist to prevent.
