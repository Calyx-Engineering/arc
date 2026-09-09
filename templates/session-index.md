# Session index — where each session's transcript went

> **Written by `hooks/session-index`** at the first tool call of a session, and never by hand —
> the hook rewrites the whole table. One row per working directory and branch. **The index is
> committed; the transcripts it points at are not**, and they never leave the machine.
>
> Format and rules: this file · Spec: [m32](https://github.com/Calyx-Engineering/arc/blob/main/docs/product-architecture/mechanisms/m32-session-preservation.md)

| Transcript | Worktree | Branch | Issue | Arc | Dates | Status |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |

&lt;rows, in the order they were first written&gt;

---

# The format

**This section is the authority.** It is deleted from a live index; it lives here so the shape has
one definition rather than being inferred from whatever the hook last wrote.

## What the index is for

Transcripts survive worktree deletion. **What dies is the ability to find them.** Claude Code
stores a session under `~/.claude/projects/<path-slug>/`, and the slug comes from the *working
directory* — so a worktree gets its own directory, and deleting the worktree leaves that directory
named after a path that no longer exists, tied to no issue, branch or arc.

The measurements that produced this are [m32](https://github.com/Calyx-Engineering/arc/blob/main/docs/product-architecture/mechanisms/m32-session-preservation.md)'s
and are not restated here — a template is copied into other repositories, where "measured in this
repository" would be a number about somewhere else.

**It is an index, not a copy.** Copying duplicates gigabytes and drifts, and transcripts hold
client and employer material that must never enter a repository. This file holds names.

## A row

```text
| `<transcript slug>` | `<worktree path>` | `<branch>` | <issue> | `<arc>` | <first> to <last> | <status> |
```

**Backticks mark a name the filesystem or git would recognise** — the slug, the worktree, the
branch, the arc. The issue, the dates and the status are prose. `-` is the absent marker and is
never backticked, so an empty cell cannot read as a branch called `-`.

| Field | | Example |
|---|---|---|
| `Transcript` | The directory under `~/.claude/projects/`, backticked. From the session's own `transcript_path` where the payload carries one; otherwise the working directory with every character that is not `[A-Za-z0-9]` replaced by `-`, corrected against the store's real spelling | `R--arc-wt-16` |
| `Worktree` | The repository root the session ran in. **May no longer exist** — that is the whole point | `R:/arc-wt/16` |
| `Branch` | What was checked out. `detached` when the worktree is still at a detached HEAD | `arc/04-dogfood-issue-16-session-index` |
| `Issue` | `#NN` from `-issue-NN`, `PR #NN` from a direct-PR branch, `-` when the branch names neither | `#16` |
| `Arc` | The arc branch the work branch descends from, `-` outside an arc | `arc/04-dogfood` |
| `Dates` | First and last session seen in that directory on that branch, `<first> to <last>` | `2026-09-08 to 2026-09-11` |
| `Status` | `live` while the worktree exists · `orphaned` once it is gone | `orphaned` |

## The unit is a directory and a branch, not a session

One transcript directory holds **every** session ever run in that working directory, so a row per
session would be a row per firing of the hook. A later session in the same place extends the date
span instead.

It is keyed on the branch as well because of m32's measured case: ROADZ's #39 was worked on a
branch **in the main repo**, and its eighteen transcripts piled into one shared directory spanning
every branch ever checked out there. The branch column is the only per-issue boundary such a
directory can be given.

## Written at creation, marked orphaned later

**At deletion the branch and the issue are already gone** — the worktree that knew them is what was
removed. So the row is written at the first tool call of the first session in a directory, and a
later firing *from somewhere else* flips its status. **Nothing is written at deletion, because
nothing can be.**

**The sweep is scoped to this machine.** The index is committed and the transcripts are not, so a
second machine pulling this file sees worktree paths that never existed on it. A row is marked
`orphaned` only when its worktree is absent **and** its transcript directory is present here — the
transcript directory is what proves this machine ran that session. Without that half, one machine
declares the other's live worktrees dead.

## What it does not promise

**Findable is not durable.** Transcripts can be rotated, cleaned, or lost with the machine, and
this file does nothing to stop that. Anything that matters is distilled into a committed artifact —
the [dev-log](../../docs/dev-log/), the [arc-log](../../docs/arc-log/), or the record proper. The
index buys the chance to go back for it, and only while the transcript is still there.

**Rows written before the hook shipped do not exist.** A directory orphaned earlier has to be
backfilled by hand from `~/.claude/projects/`, which is exactly the live context this mechanism
exists to capture and cannot reconstruct.

**A row rides on its own branch merging.** It is written into the working tree it describes, so a
worktree whose branch is abandoned takes its row with it — and an abandoned worktree is the kind
most likely to be forgotten. The index merges with the work, like the dev-log.

**The file is created untracked.** `git add .claude/arc/sessions.md` the first time it appears;
`skills/handoff`'s setup step says so, and `tools/verify-session-index.sh` fails when it exists and
git does not know about it. An un-ignored file that nobody committed is not a committed one.

## Who reads it

| | |
|---|---|
| [`agents/transcript-miner`](https://github.com/Calyx-Engineering/arc/blob/main/agents/transcript-miner.md) | Reads it before globbing, so an orphaned directory arrives with its branch and issue attached instead of as a bare path |
| A human, at a cold start | "What happened in that worktree?" — the row names the directory to open |

## Rotation

**None.** Unlike the [event log](https://github.com/Calyx-Engineering/arc/blob/main/templates/event-log.md), this file is never rotated or moved: an entry's
whole value is that it still resolves years after the worktree is gone. It grows by one row per
working directory and branch, which is a handful per arc.
