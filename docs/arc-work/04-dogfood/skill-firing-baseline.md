# Skill firing — baseline, 2026-09-07

Measured before any skill was edited for firing. Every Fire issue is scored against this table.

```sh
bash tools/skill-firing.sh r--work-lantern-roadz-sound-system r--arc --since 2026-08-24T09:40
```

**Corpus:** 11 sessions across 3 directories — this repository and ROADZ, including its worktree
— from the plugin's install onward. *Opening* is the first 3 user turns of a session.

| Skill | Fires | Sessions | At opening |
|---|---|---|---|
| `arc-intent` | 2 | 2/11 | **0/11** |
| `autonomy-set` | 3 | 3/11 | 1/11 |
| `camp` | 2 | 2/11 | 1/11 |
| `chat-response` | 4 | 4/11 | 3/11 |
| `decompose` | 1 | 1/11 | 0/11 |
| `engineering-report` | 1 | 1/11 | 0/11 |
| `handoff` | 3 | 3/11 | **0/11** |
| `issue-write` | 8 | 8/11 | 1/11 |
| `plugin-retrospective` | 2 | 2/11 | 1/11 |
| `record-route` | 7 | 7/11 | 4/11 |
| `relief-valve` | 1 | 1/11 | 0/11 |
| `spec-interview` | 2 | 2/11 | 0/11 |
| `work-watch` | 1 | 1/11 | 0/11 |

**Every skill fired at least once.** The defect is not discoverability — it is frequency.

## What the numbers say

| | |
|---|---|
| **`handoff` fired at no opening in 11 sessions** | The retrospective inferred this from 8 openings. It is now measured, and the count is worse |
| **`work-watch` fired once in 11 sessions** | Its own description says *use continuously while work is in progress*. Once |
| **`chat-response` fired in 4 of 11** | It governs every reply. Seven sessions of replies were written without it |
| **`arc-intent` fired twice, never at an opening** | It is meant to run before a filing decision. 28 issues were filed on 2026-09-06 alone |
| **`issue-write` and `record-route` are the outliers** | 8 and 7 sessions. Both are named explicitly and often — which is the pattern the diagnosis predicts |

**Fired but not shipped here:** `amp-load-test`, `arc-next`, `arc:arc-next`, `artifact-design`,
`artifact-diagramming`. `arc-next` appearing both bare and namespaced is a command, not a skill,
and is worth a second look — the two forms may not resolve to the same thing.

## Re-measuring

Same command, same `--since`. A fix moves a row or it did not work.

**This measures what happened; it cannot re-run a case against a changed skill.** Regression
testing needs `claude plugin eval`, which is
[#181](https://github.com/Calyx-Engineering/arc/issues/181) and gated behind early access.
