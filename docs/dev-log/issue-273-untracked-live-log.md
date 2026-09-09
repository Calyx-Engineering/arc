# Issue #273 — The tracked activation log dirties every tree

> Dev-log, not a spec. Started at plan time, finalised as a retrospective at PR time.

**Issue:** [#273](https://github.com/Calyx-Engineering/arc/issues/273)  ·  **PR:** not yet opened

## Problem

`.claude/arc/log.md` was tracked and every hook firing appends to it, so every worktree was dirty
at every moment and `git add -u` swept thousands of machine-written lines into review diffs. The
repository's own history carries the evidence: commits titled *chore: activation-log entries*.

## Intent and north star

| | |
|---|---|
| **What this issue is really for** | Not the dirty tree by itself — the review diff. A human diff with a thousand machine lines in it is a diff nobody reads, which costs the review the tracking was for |
| **North star** | `.claude/arc/log.md` no longer appears in `git status` after a hook fires, with nothing lost from the record. `.claude/arc/sessions.md` still does, and deliberately — [m32](../product-architecture/mechanisms/m32-session-preservation.md) requires it committed |
| **What makes it durable** | The `.gitignore` entry is one line and could be undone by anyone; what makes it hold is that the record has somewhere else to be — [#239](https://github.com/Calyx-Engineering/arc/issues/239)'s rotation, which commits an arc's events into `docs/arc-log/events/` |
| **Out of scope** | Retention of the archived copies. Still open in m44 |

## Decisions & trade-offs

| | |
|---|---|
| **Untracked live, tracked archive** | The issue offered either. Both, in fact: the live file is gitignored and the arc-close rotation is the one deliberate step that commits it. Choosing only the second would have left the tree dirty for a whole arc between steps |
| **The path does not move** | `.claude/arc/log.md`, exactly as before. Every reader resolves a literal path — Camp, the operating agreement, `verify-activation-log.sh`, `verify-log-rotation.sh` — so moving the file would have been the change that broke them, and ignoring it is not |
| **Anchored `/.claude/arc/log.md`** | A bare `log.md` matches any file of that name anywhere in the repository. The same reasoning `/HANDOFF.md` already carries two entries above it |
| **The consuming repo gets the rule too** | `skills/handoff`'s setup step named two `.gitignore` entries; it names three now. The log lives in the consuming repo, so a rule only Arc's own repo has is a rule that fixes nothing for anyone who installs Arc |

## Rejected approaches

| | |
|---|---|
| **Write the live log outside the repository** | Under `~/.claude/` or a temp directory. It would end the dirty tree too, and it separates the log from the arc it belongs to, breaks the relative `Previous:` chain, and makes rotation a copy between filesystems rather than a move |
| **Keep it tracked and commit the entries deliberately** | What was already happening — the *chore: activation-log entries* commits. It does not clean the tree, it just names the sweeping |

## Retrospective

The trade accepted, and it is a real one: **a record git does not hold is a record one `rm -rf`
ends.** An arc's events are now recoverable only from the moment they are rotated. The
alternative was a machine-written file in every human diff, which loses the review that tracking
was for.

`verify-activation-log.sh`'s library checks were re-run against the untracked file and both
log-path assertions still hold, including the byte-compare regression that catches a firing
writing to the real log with no session set. m30's transcript miner never read this file — it
reads `.jsonl` transcripts — so nothing there had to change.
