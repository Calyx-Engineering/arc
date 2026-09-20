# Skill firing — baseline, 2026-09-07

Measured before any skill was edited for firing. Every Fire issue is scored against this table.

> **Corrected on 2026-09-07 by [#155](https://github.com/Calyx-Engineering/arc/issues/155).** The
> **At opening** column below was measured with a turn counter that counted skill injections,
> tool results, slash-command echoes, interrupt markers and task notifications as user turns —
> so a skill firing early pushed the session's later turns out of the opening window. The column
> is biased downward. Section [Corrected numbers](#corrected-numbers) has the re-measurement;
> the **Fires** and **Sessions** columns are unaffected.

```sh
bash tools/skill-firing.sh r--work-northwind-zephyr-system r--arc --since 2026-08-24T09:40
```

**Corpus:** 11 sessions across 3 directories — this repository and the client repo, including its worktree
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
| **`handoff` fired at no opening in 11 sessions** | The retrospective inferred this from 8 openings. **Corrected:** 1 of 15 under the fixed counter — and that one fire is the bulk load in `c4fe2b5c`, not a trigger that worked. The conclusion survives the correction |
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

## Corrected numbers

Re-measured 2026-09-07 with `is_prompt_turn()`, over 15 sessions rather than 11 — four sessions
were added to the corpus between the two runs, so this is not a like-for-like re-run of the table
above.

```sh
bash tools/skill-firing.sh r--work-northwind-zephyr-system r--arc --since 2026-08-24T09:40
```

| Skill | Fires | Sessions | At opening |
|---|---|---|---|
| `arc-intent` | 2 | 2/15 | 2/15 |
| `autonomy-set` | 3 | 3/15 | 2/15 |
| `camp` | 2 | 2/15 | 1/15 |
| `chat-response` | 5 | 5/15 | 3/15 |
| `decompose` | 1 | 1/15 | 1/15 |
| `engineering-report` | 1 | 1/15 | 1/15 |
| `handoff` | 3 | 3/15 | 1/15 |
| `issue-write` | 8 | 8/15 | 4/15 |
| `plugin-retrospective` | 2 | 2/15 | 2/15 |
| `record-route` | 8 | 8/15 | 5/15 |
| `relief-valve` | 1 | 1/15 | 1/15 |
| `spec-interview` | 2 | 2/15 | 1/15 |
| `work-watch` | 1 | 1/15 | 1/15 |

**Most of the gain in At opening is one session.** In `c4fe2b5c` the user typed *"please load all
the skills from Arc"* and eleven skills fired on turn 2. A corpus rate cannot separate that from a
trigger that worked, which is why [#155](https://github.com/Calyx-Engineering/arc/issues/155)
scores per prompt instead — see [the decision](skill-firing-decision.md), and
`bash tools/skill-cases.sh`.
