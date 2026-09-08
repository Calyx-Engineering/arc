# PR #245 — arc-loop resumes across a reset; arc-run runs to a workstream boundary

> Decision log, not a spec.

**Issue:** none  ·  **PR:** [#245](https://github.com/Calyx-Engineering/arc/pull/245)

## Problem

Four things S3 and S4 exposed in the loop shipped by [PR #215](pr-215-loop-v2.md):

| | |
|---|---|
| **The retry budget gave up at the reset** | Three S4 runs hit the account's session limit at 00:20; the limit reset at 02:20; twelve ten-minute waits ended at 02:20 and every loop gave up with its worktree kept. Resumed by hand at 07:00 |
| **A run ended its turn waiting on background work** | The run for #151 sent a suite to the background and ended its turn expecting the notification. A `claude -p` session ends when the turn ends; the notification never arrives. 62 minutes of work sat in a worktree behind a draft PR |
| **Each set waited for a yes** | The user's checkpoint is the workstream boundary, where a report is read — not every set |
| **`verify-dev-log-name.sh` scanned gitignored paths** | It found the phrase it forbids inside `.arc-work/runs/*/prompt.md`, which carries the issue body that names the defect. Only in the main tree — a run's worktree has no `.arc-work/` |

And one that is not the loop's: MSYS `grep -i` on multibyte text aborts when `LANG` is empty. That is
the environment of this session's Bash tool, not the runs' login shell, and it made five gates fail
here while they passed in every worktree.

## Decisions & trade-offs

| Decision | Why | Not chosen |
|---|---|---|
| **Retry budget 36 × 10 min** | A session limit is a five-hour window; two hours covered none of it | Detecting the reset time from the message |
| **The resume message names both causes** | A limit and a turn that ended on background work are resumed the same way — `claude -p --continue` in the worktree | Two messages |
| **Sub-agents run in the foreground — `run-instructions.md` §3** | The only fix that prevents the failure rather than recovering from it | Polling for background completion in the loop |
| **The yes runs to a workstream boundary — `commands/arc-run.md`, `playlist.md` §5** | The boundary report is the review; a set that closes no workstream has nothing new to read | A yes per set |
| **`--report`, `--resume`, `--track`** | Landed in #215's later commits; recorded here because this PR is where they were first relied on | — |

## Retrospective

S3 and S4 through this loop: 15 issues, 9 runs, two of them resumed once and one twice. S4's wall
time was 9 h 25 including a two-hour limit stop and the overnight gap; its working time was under
three hours.
