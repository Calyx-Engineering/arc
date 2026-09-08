---
name: handoff
description: Use when the user asks for the handoff to be read or written, in any wording — "read HANDOFF.md first", "read HANDOFF.md if it exists", "please read handoff", "ingest handoff", "get up to speed", "get back up to speed", "pick up from where we left off", "where did we leave off", "do these in order", "write the handoff", "give me the prompt for the next chat" — or runs /arc-next. Also fires when the request describes this work without naming it: copying or saving a session transcript to the arc's transcript directory, or being told the handoff was updated elsewhere. Fires when the read is wrapped inside other instructions rather than being the whole message: a read followed by a branch name and three further requests, or a read buried under "run autonomously", is still a handoff turn. Loading this skill does not answer the rest of the turn and does not replace another skill. When the same message also greets Camp or asks where things stand, that is a Camp turn as well — load camp too, on the same turn, rather than choosing between them. Covers the reading order, the staleness checks before acting on a handoff, what it holds, the ordered actions the next session executes, saving the transcript, and what belongs in the committed record instead.
camp-reports: [handoff-written, handoff-read, transcript-saved]
checks: [handoff-exists, ordered-actions-present, transcript-saved, open-threads-carried, graduated-to-record, stale-rows-removed, handoff-age, transcripts-newer, branch-matches, tree-accounted, commits-accounted, open-prs-accounted, first-action-issue-open]
skips:
  - graduated-to-record (nothing in the handoff outlives the arc)
  - handoff-age (the write path — no handoff is being acted on)
  - transcripts-newer (the write path — no handoff is being acted on)
  - branch-matches (the write path — no handoff is being acted on)
  - tree-accounted (the write path — no handoff is being acted on)
  - commits-accounted (the write path — no handoff is being acted on)
  - open-prs-accounted (the write path — no handoff is being acted on)
  - first-action-issue-open (the write path — no handoff is being acted on)
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

### Check the handoff is still true, before acting on it

**A handoff is written at a stop point and describes the state at that moment.** Anything
done afterwards — including in another window, or by the user between sessions — is absent
from it. Acting on a stale handoff is worse than having none, because it is specific and
wrong.

Run these before executing anything. They cost one command each.

| Check | Stale when |
|---|---|
| **The date in the handoff's title** | More than 24 hours before today. Age alone is not proof of staleness, but past a day the odds that something happened outside it are high enough to say so |
| **Transcripts newer than the handoff** | `find <transcript-dir> -name '*.jsonl' -newer HANDOFF.md` prints anything. A session ran after this handoff was written and its decisions are not in here |
| `git branch --show-current` | The branch differs from the one *Where we are* names |
| `git status --short` | The tree is dirty and the handoff does not say work was left uncommitted |
| `git log --oneline -5` | The last commit is not one the handoff accounts for |
| `gh pr list --state open` | An open PR the handoff calls merged, or says nothing about |
| The issue in *Do these in order* row 1 | `gh issue view <NN> --json state` returns `CLOSED` |

**Compare modification times, never the handoff's *Transcripts* table.** That table is
curated — it names the few transcripts worth reading, not every file on disk — so measuring a
complete directory against it reports a lost session on every cold start once the arc has run
more sessions than the table lists. The check wants one fact: *did a session run after this
handoff was written.* An mtime answers it and nothing else does.

The saved transcript never trips this. The order at a break is fixed — save the transcript,
then write the handoff — so the newest file is always older than `HANDOFF.md` by construction.

**What it cannot see: a session that ran and saved no transcript.** Nothing on disk records
it. The other six checks are what catch that one — a commit, a branch, or a PR the handoff
does not account for.

**If any check disagrees, stop and report the specific contradiction** — what the handoff
says, what the repository says. Do not reconcile it silently and do not proceed on a guess.
The handoff is the spine; a spine that disagrees with the tree is the one thing this
mechanism cannot let pass.

Two exceptions, which are not staleness: a handoff that *says* work was left uncommitted and
the tree is dirty in exactly that way, and a branch that does not exist yet because row 1
creates it.

### Then execute

Execute *Do these in order*, top to bottom. The rows are instructions, not topics —
start the first one without asking what to do.

**If `HANDOFF.md` does not exist**, say so and stop. There is nothing to resume from, and
guessing the arc's state is the failure the handoff exists to prevent.

**If the handoff has no *Do these in order* section**, report where the arc stands from what
it does carry, and ask for the next step. A handoff missing its ordered actions is a finding
worth naming, not a gap to fill by inference.

### When you are about to do it a different way

**The unit was accepted. How it was to be done was accepted with it.** This fires on a
substitution — the same issue and the same branch, not new work — in either of its two forms:

| The substitution | |
|---|---|
| **A different approach inside a row the handoff names** | The same ordered action, done another way |
| **A different order across rows it names** | A sequence is itself a decision. Re-ordering accepted rows replaces the approach to all of them at once, and it is the form least likely to be noticed, because every row still gets done |

Twice in the measured corpus a session did one without noticing — one of each form. One inverted
the handoff's step order and supplied a reason it had derived itself. The other read *not built,
only needed if the coupler floor lands above the audio band*, stated the correct rationale for
the rig unprompted, and about twelve minutes after that read had promoted the method to the
primary plan. Neither announced a substitution, because neither saw itself making one.

| | |
|---|---|
| **Say it before the work, not in the report** | One line: what the handoff names, what you are about to do instead, and what makes you think so |
| **Then read the fact the decision rests on** | For an approach, *What would have to change* in *Load-bearing decisions*. For an order, the reason the row gave for its position. **If that fact has not changed, the decision has not been superseded — it has been forgotten**, and the accepted one stands |
| **A row that gave no reason for its position is a finding, not a licence** | It is the gap that produced the inversion in the corpus. Say the reason is missing and ask, rather than supplying one of your own — a re-derived reason reaches the opposite answer as easily as the same one |
| **A condition attached to the alternative is a condition to test** | *Only needed if X* is not a licence to start with it. Check X, and say what you found |
| **If the fact has changed, name which one, then proceed** | A substitution carrying its constraint is a decision. One without is a re-derivation |

**Stating your reason is not the check.** One of the two openings above gave a correct,
unprompted rationale for what it was building and built the wrong thing anyway. The check is
against the recorded constraint, not against your own account of it.

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

**Every one of those moments re-stamps the title.** `YYYY-MM-DD HH:MM` — the current date *and*
time of day, on **every write**, not only when the file is created. A stale stamp is worse than
a missing one: the read path's first staleness check reads exactly this line, so a handoff
rewritten at 16:40 and still headed with the morning's time is trusted by precisely as much as
it should not be. And **a date with no time cannot separate an hour-old handoff from a week-old
one** — a cold start then treats both as current.

The rule is mechanical: **if the body changed and the stamp did not, the stamp is wrong.**

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
| **Load-bearing decisions** | What must not be re-litigated, **and the fact that would have to change to re-open it** | A fresh session re-deriving a settled question and reaching the opposite answer |
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

**And where the order is not a hard dependency, the row still says why it sits there.** This is
the same rule as *Load-bearing decisions*' second column, applied to the sequence: an order is a
decision, and a decision with no reason gets re-derived. The corpus has the case — a handoff
correctly ordered a tool commit ahead of an issue, gave no reason, and the next session
re-derived one from the dependency graph and inverted it. The fact that would have settled it
was that the user was about to be physically at the bench, which is not in a dependency graph
and was never written down. A soft reason is exactly the kind that looks omissible and is not.

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

**The handoff's *Transcripts* table is curated, not a directory listing.** It names the few
worth reading and says why; an arc accumulates far more than that, and listing all of them is
the growth failure this document warns about below. **So nothing may compare that table
against the directory** — the staleness check in the read path above asks whether a session
ran after the handoff by mtime, which is the only question it needs answered.

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
| The narrative of how a decision was reached | The dev-log. *"We tried X, then Y"* is disposable. **The constraint that forces the decision is not** — it stays here, in the second column of *Load-bearing decisions*. A decision whose reason lives only in the dev-log is one the next session re-derives, and re-derivation reaches the opposite answer as easily as the same one |
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

**Which is also why overwriting it destroys something.** Gitignored means git cannot restore
it, so a rewrite takes the state this session was *given* with it. `hooks/handoff-archive`
copies it to `.arc-work/archive/<timestamp>/` at the session's **first tool call of any kind** —
not when the handoff is written, because a session that crashes never reaches its own write, and
not only on an edit, because `cat > HANDOFF.md`, `mv` and `rm` destroy it without going near
`Edit` or `Write`.
The same rule covers any file git cannot restore: tracked files need no copy, git is the copy.

The store is gitignored too. It is **recovery, not record** — nothing reads it as history,
nothing prunes it, and getting a file back is a plain `cp` from the timestamped directory.

**Add `/HANDOFF.md` *and* `.arc-work/` to `.gitignore` when starting an arc in a new repo.**
It is the one setup step this skill needs, and it is **two entries, not one**: `.arc-work/archive/`
is where the copies above land, so a repo that ignores only the handoff commits a copy of every
handoff the arc ever had straight into the record — the exact opposite of what the store is for.

Anchor the handoff entry at the root. A bare `HANDOFF.md` also matches `templates/handoff.md`,
which is a shipped artifact and must be committed.

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
