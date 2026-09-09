# Issue #239 — Nothing rotates the event log at an arc boundary

> Dev-log, not a spec. Started at plan time, finalised as a retrospective at PR time.

**Issue:** [#239](https://github.com/Calyx-Engineering/arc/issues/239)  ·  **PR:** [#303](https://github.com/Calyx-Engineering/arc/pull/303)

## Problem

`templates/event-log.md` specifies rotation at arc open and at arc close. Nothing performed
either, so `.claude/arc/log.md` carried `**Arc:** arc/03-camp` in its header for the whole of
arc 04 and every arc-04 firing was filed under arc 03's name.

## Intent and north star

| | |
|---|---|
| **What this issue is really for** | A specified step nobody performs is not a specification, it is a note. The header disagreeing with the branch was visible on every read of the file and nobody read the file |
| **North star** | The live log's header names the arc that is writing to it, and something says so next time it does not |
| **What makes it durable** | `tools/verify-log-rotation.sh`, in `tools/verify-all.sh`. The rotation itself is a one-off; the gate is what survives to the next arc boundary |
| **Out of scope** | Retention — how long an archived log is kept and whether it is ever pruned. m44 still lists it as undesigned, and this issue only had to give it something to retain |

## Decisions & trade-offs

| | |
|---|---|
| **The assertion that survives #273 reads the archive, not the live log** | The header check needs `.claude/arc/log.md`, which [#273](https://github.com/Calyx-Engineering/arc/issues/273) made untracked — so in CI and in every new worktree there is no header and it can only stay quiet. Review pass 2 found the gate silent in exactly the trees where work happens. The `archive` assertion answers it: the arc before this one must have its log in `docs/arc-log/events/`, which is tracked, so it reads the same everywhere and fails on precisely the omission this issue opened on |
| **A gate, not a script that rotates** | The issue offered "a gate **or** a step". A rotation script would be a fourth thing to remember to run; the gate names the two commands in its failure message, which is the same instruction delivered at the moment it is needed |
| **Rotation cannot be a hook** | An arc opens when a human decides one has. There is no tool call to hang the move on, and a hook guessing from a branch name would rotate on the first push of a topic branch |
| **The arc comes from the branch, not from a config** | `arc/04-dogfood-issue-238-log-volume` belongs to `arc/04-dogfood`. CLAUDE.md's two work-branch forms — `-issue-<N>-` and `-pr<N>-` — are the whole vocabulary, and a name that is neither is not an arc branch, which the gate treats as *nothing to compare* rather than as a failure |
| **Four silences, each deliberate** | No live log, a non-arc branch, a live log a firing created before rotation opened it, and a `Previous:` that names no file. The first and third are the normal state of a fresh clone after [#273](https://github.com/Calyx-Engineering/arc/issues/273) — nothing writes the header, so the first firing creates a headerless log seconds after checkout — and failing on any of them would fail `verify-all.sh` on every new worktree |
| **`Previous:` is resolved, not just read** | The chain back through the arcs is the only thing making an archived log findable. A link into nothing looks exactly like a link |
| **The arc-04 entries stay in arc 03's file** | The log is append-only, and moving an entry out of it is an edit. The archived header says so instead |

## Rejected approaches

| | |
|---|---|
| **Split the file at the arc boundary** | Would put the arc-04 entries where they belong, and would mean rewriting an append-only record on the strength of a timestamp guess. The note costs nothing and lies about nothing |
| **Derive the current arc from `docs/arc-log/`** | Three arc-logs sit there and none of them says which is current. The branch does |

## Spawned

**A commit nobody in this session made.** At 10:45:17, seconds after the `git mv` that performed
the rotation, `0bda7a0` appeared on this branch — message `ran gh issue close 42`, contents
exactly the staged rename, 0 insertions and 0 deletions. That string exists nowhere in the
repository except as a comment example inside `hooks/tracker-verify`, and nothing in `tools/` or
`hooks/` — working tree or installed plugin — executes a payload command or runs `git commit`.
`R:/arc/.git/worktrees/238/COMMIT_EDITMSG` holds the message with a later mtime than the commit,
so a second `git commit` ran from this worktree afterwards. Reset with `git reset --soft` and the
rotation recommitted properly. **Unattributed**, and it wants its own issue: something can commit
a worktree's staged index without the session asking.

## Retrospective

The gate found the defect before the fix went in — run against the tree it reported the live log
headed `arc/03-camp` against a branch belonging to `arc/04-dogfood`, exit 1, which is the whole
of #239 stated by a machine. After the rotation it reports two passes.

The archived file carries all 58,466 lines, and the old path keeps its own history — what
moved is the content, not the path's record. Its header's
relative links were rewritten for the two extra levels of depth — `templates/event-log.md` now
warns about that, because a rotation that leaves them breaks every link in the header and the
gate does not check them.
