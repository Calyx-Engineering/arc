# PR #133 — arc-04: scope: the dogfood arc

**Issue:** none  ·  **PR:** [#133](https://github.com/Calyx-Engineering/arc/pull/133)

## Problem

Three weeks of hardware work in another repository produced substantial friction with Arc and no
route from that friction to work. The transcripts sat unread, the two problems the user named —
a broken handoff and skills that do not fire — had no evidence behind them, and there was no
mechanism to turn either into issues an agent could execute.

## Intent and north star

Scope one arc from real evidence, and leave behind a queue an autonomous loop can run without the
user in the turn-by-turn path.

## Decisions and trade-offs

| | |
|---|---|
| **The corpus is post-install only** | 38 of the original 50 days predated Arc's install. Friction from before Arc existed says nothing about Arc |
| **C1's correction count is unusable** | Counting corrections measures how much was said, not how much went wrong. Run 2 dropping 11 to 3 exposed the instrument, not an improvement |
| **The retrospective is a `README.md`, written once** | A log is appended to as friction happens. This is evidence and freezes when the run ends. `skills/plugin-retrospective` was changed to say so |
| **The plan and the arc-log own different things** | The arc-log owns why, architecture, decisions, status and soak. The plan owns objective, scope, decomposition and done-when. Status was being tracked in both |
| **A run's unit is one issue, not one workstream** | A workstream is 5 to 12 issues. Running one in a single context is how a session saturates |
| **A run reads `run-instructions.md`, never the plan** | The plan is the human's forest view. Making it an execution input puts the whole arc back in the runner's context |
| **Four review passes, three before the PR and one after** | Repetition pays only when each pass asks a different question. Pass 4 catches the class that is invisible until the unit is a PR — this document is one of its findings |
| **The queue is GitHub sub-issues, not labels or a project board** | Five arc-scoped labels pollute a space the user reads, for something that expires with the arc. `reprioritizeSubIssue` gives native ordering, and one `workstream` label on the parents is reusable across arcs |
| **The driver is a script, not the orchestrator** | A session that picks and dispatches accumulates the whole workstream in its context, which is the failure the loop exists to prevent |
| **No new mechanism number** | This belongs to m25, autonomous execution. m48 was proposed before checking whether an existing mechanism covered it |

## What the interview settled

**A working handoff:** the first action is correct with no correction, **and** the session can state
why the current approach was chosen without being told.

The leading hypothesis for why a correct handoff produces the opposite conclusion is that rationale
is stripped along with narrative — the decision survives and the constraint that produced it does
not. Corroborated from the other direction: the manual process the handoff replaced worked, and it
worked by reading the previous session's transcript rather than a distillation of it.

## Retrospective

**What pass 4 caught on this PR:** a stale title, a body that still said *body written as the work
proceeds*, a `Spawned` table broken into six fragments by blank lines, 28 spawned issues missing
from it, and this dev-log as four empty headings. Every one was invisible while the work was in
progress and obvious the moment the unit was read as a PR.

**The planning session shrank from 110 minutes to about 15.** Five of its seven questions were
asking the user to re-approve decisions already made.

**Unexercised:** `tools/arc-loop.sh` has never dispatched a real run. Selection, skipping and its
three guards are tested; the dispatch path, the report run and the all-blocked stop are not.
