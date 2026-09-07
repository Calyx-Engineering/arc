# PR #215 — arc-loop dispatches batched, detached runs into worktrees

> Decision log, not a spec.

**Issue:** none  ·  **PR:** [#215](https://github.com/Calyx-Engineering/arc/pull/215)

## Problem

One issue run costs more than a fifth of a day's session budget and takes 35 minutes or more.
Summed from the `.jsonl` transcripts under `~/.claude/projects/r--arc/`:

| Run | Turns | Input (M) | Cache read | Output (K) | Min | Context/turn (K) |
|---|---|---|---|---|---|---|
| #158 run 1 (died) | 171 | 16.4 | 98% | 140 | 22 | 96 |
| #158 run 2 | 180 | 25.5 | 98% | 205 | 68 | 142 |
| #157 run 1 (died) | 104 | 10.5 | 97% | 101 | 22 | 101 |
| #157 run 2 | 206 | 23.1 | 98% | 157 | 33 | 112 |
| #156 | 138 | 13.9 | 98% | 123 | 21 | 101 |
| #155 run 1 (died) | 84 | 6.5 | 96% | 112 | 11 | 78 |
| #155 run 2 | 301 | 52.4 | 99% | 372 | 41 | 174 |
| Orchestrator, whole day | 509 | 93.0 | 98% | 338 | 584 | 183 |

Two things the numbers say that the brief did not:

| | |
|---|---|
| **Cold start is not the cost** | Cache read is 97–99% inside every run. The cost is turn count × context per turn |
| **Three of four first runs died at ~20 minutes** | With the session that launched them. Dead runs were ~35% of the workstream's spend |

And the constraint everything else follows from: every run shares one working tree, so nothing
runs alongside a run, and an uncommitted edit in the main tree follows a run onto its branch.

## Intent and north star

Speed execution, hold quality, cut token cost — in that order of what was actually broken. The
four review passes stay: they are why this arc exists.

## Decisions & trade-offs

| Decision | Why | Not chosen |
|---|---|---|
| **One script. `arc-loop.sh` gains `--issues`, `--status` and the worktree dispatch; nothing new beside it** | A second script was drafted and withdrawn the same hour: `arc-next`, `arc-run` and `arc-loop` are already three entry points, and a fourth is the confusion this arc is meant to remove. Selection and the report run are unchanged; only how a run is launched changed | `tools/arc-dispatch.sh` |
| **Detached via PowerShell `Start-Process`** | A child of the shell dies with the shell, and the shell dies with the Claude session that ran it. `nohup … &` does not survive a Windows console going away | `nohup`, `setsid` |
| **Prompt to a file, exit code to a file** | A detached process has no stdin from us and nobody waiting on it | Piping |
| **Worktree per run at `../arc-wt/<id>`, detached at `origin/<arc>`** | The main tree's HEAD is never touched. The run creates its issue branch inside the worktree, as it does today | Worktrees inside the repo |
| **A minimal `HANDOFF.md` written into the worktree, carrying only the mode table** | `hooks/mode-guard` reads `HANDOFF.md` from the payload's cwd; it is gitignored, so a worktree has none and every commit is denied. Writing it there — and only there — means **the main tree's row is not touched**: the grant lives and dies with the worktree | Copying the real handoff; setting the main tree autonomous |
| **Batching by shared deliverable, one commit per issue** | Two issues editing one hook in two PRs is a merge conflict; in one PR with one commit each, `git revert` stays surgical | Batching by count |
| **Passes 1 to 3 dispatched to read-only sub-agents** | Each pass is a large read that collapses to a small answer — `run-instructions.md` §3's own definition. The whole-file reads leave the main context; the passes do not change | Cutting passes |
| **A run still merges its own PR** | #155–#158 did, from the worktree's autonomous row. The classifier denial the brief recorded was one run; not reason enough to move the merge until it recurs | Orchestrator merges |
| **`--issues` must name open children of the workstream** | A batch is the playlist's call, but it cannot smuggle work in from outside the queue | Free-form issue lists |

**Parallelism saves wall time, not tokens.** Two runs at today's per-run cost cost twice as much.
That is why the dispatch and the sub-agent passes land together and the parallel schedule waits
for the numbers.

## Retrospective

**First exercise: [#183](https://github.com/Calyx-Engineering/arc/issues/183) +
[#210](https://github.com/Calyx-Engineering/arc/issues/210), one run.** Same hook, tree-only gates,
no dependency on the installed plugin. Nothing else running, so the measurement isolates the
sub-agent passes. `tools/arc-loop.sh 145 --issues 183,210`; compare its usage lines against the
table above.

**Result, same day.** Run 183 — #183 and #210, one worktree, `claude-opus-5`, two other runs
alongside it for the last 35 minutes:

| | Run 183 (two issues) | #158 alone, before |
|---|---|---|
| Turns | 90 | 351 over two runs |
| Input tokens | 12.4M, 99% cache | 42M |
| Output | 92K | 345K |
| Wall | 76 min | 90 min |
| Cost | $14.08 by the CLI's own count | — |
| Outcome | PR #216 merged by the run, both issues closed, worktree removed by the loop | merged |

Per issue, roughly a quarter of the tokens and 40% of the wall time — before any parallelism is
counted. Not attributable to one change: the sub-agent passes, no dead first run, and a batch
sharing one read of the hook all landed together.

First launch died at turn 1: the `~/.local/bin` CLI was 2.1.241 and rejected the account's new
default model. `--model claude-opus-5` was the fix and is also the baseline-matching choice.

Still unexercised: a rate-limit resume; a run that leaves its issue open; the report run from
this tree; `--track` on a session list.
