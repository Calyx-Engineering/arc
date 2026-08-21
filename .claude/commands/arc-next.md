---
description: Resume the arc from the handoff — read it, then execute its ordered actions
---

Invoke the `handoff` skill and take the reading path.

Read `HANDOFF.md` first, before anything else — before exploring the tree, before `git log`,
before opening a spec. It names the reading order for everything else, and reading in the
wrong order is what makes a cold start expensive.

Then read only what it points at: this repo's `CLAUDE.md`, the arc-log for the current arc,
the dev-log for the current issue, and whatever those name. **Do not read the whole record.**

## Check the handoff is still true, before acting on it

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

## Then execute

Execute *Do these in order*, top to bottom. The rows are instructions, not topics —
start the first one without asking what to do.

**If `HANDOFF.md` does not exist**, say so and stop. This command has nothing to resume from,
and guessing the arc's state is the failure the handoff exists to prevent.

**If the handoff has no *Do these in order* section**, report where the arc stands from what
it does carry, and ask for the next step. A handoff missing its ordered actions is a finding
worth naming, not a gap to fill by inference.

$ARGUMENTS
