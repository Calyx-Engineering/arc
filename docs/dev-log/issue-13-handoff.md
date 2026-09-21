# Issue #13 — the handoff

> Dev-log, not a spec.

**Issue:** [#13](https://github.com/Calyx-Engineering/arc/issues/13)  ·  **PR:** [#23](https://github.com/Calyx-Engineering/arc/pull/23)

## Problem

Cold starts cost 20+ minutes and sometimes send the work down the wrong path. Guided
hardware sessions run at 250k+ context, so restarting is necessary rather than accidental —
the mechanism must make restarts cheap, not prevent them.

## Decisions & trade-offs

**Gitignored, and it dies with the arc.** Committing it puts a file in the record that is
stale the moment it is written, and a fresh session cannot tell which of two overlapping
documents to trust. The test for what belongs in it: if a fact would still be true and
useful in six months, it goes in the committed record instead.

**A document, not a window.** TimeScope holds arc state in a coordinating chat window, which
dies under context pressure — and hardware work kills windows constantly. Inverting it means
any fresh session becomes the spine by reading. The same reasoning rules out a running
agent, a held context, or an open tab.

**The skill leads with reading, not writing.** The write is instrumental. A skill organised
write-first would be read as a session-end chore rather than the thing that makes a cold
start cheap.

## Rejected approaches

**Committing it to `docs/arc-log/`.** It survives worktree death, which is the argument for
it, but it duplicates the arc-log at a different freshness and the stale one wins. Worktree
death is not the failure being solved here — context death is, and a local file survives
that.

## Spawned

Nothing filed. The gap found by the cold-start test was fixed in this issue rather than
deferred.

## Retrospective

Shipped `skills/handoff` and `templates/handoff.md`.

**Two cold starts, not an assertion.** The issue required the read path be exercised, so a
fresh agent was given the handoff and nothing else. It answered all four questions correctly
from four files — and found a gap I would not have.

**The gap:** the reading order points at the current issue's dev-log, but a dev-log is
written at plan time, so **the first session on an issue always arrives before one exists.**
The agent had to infer the issue's scope from the roadmap, which is exactly the inference the
skill exists to prevent. It said so plainly rather than papering over it.

Fixed with a one-line scope row in the handoff, deleted once the dev-log exists, and by
stating that writing the dev-log is step one of the work rather than a detour. A second cold
start then answered the same question from what it read and reported nothing missing.

**A second, smaller bug fell out.** `.gitignore` carried a bare `HANDOFF.md`, which matches
at any depth — so it silently ignored `templates/handoff.md`, a shipped artifact. Caught
because `git add` refused the file. Anchored to `/HANDOFF.md`.
