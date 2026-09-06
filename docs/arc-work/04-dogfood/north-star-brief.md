# North-star brief — arc 04 dogfood

**The instruction this plan is built against.** Written down rather than left in a chat window,
because an instruction that lives only in context has no trigger — which is
[C4](../../retrospectives/2026-09-dogfood/README.md#c4--skills-not-loaded-until-demanded), the
retrospective's largest finding, applied to instructions instead of skills.

Recorded 2026-09-05. **Read this at the start of every planning pass.**

---

## The instruction, verbatim

> loop over this at least 10 times.
>
> - Evaluate what the issues are
> - what the scope is
> - no more than 4 general groups of work - from my perspective the groups are
>   - Make all the skills fire appropriately
>   - Make the handoff work REALLY REALLY REALLY well. that means getting the right things done
>     and not forgetting critical and incidental information plus other things.
>   - Write issues correctly
>   - house keeping
> - how can you break this down so that you can
>   - evaluate what the problem really is
>   - identify how to fix the problem
>   - implement a fix to the problem
>   - test it.
> - evaluate against the constraints below and general constraints

## Constraints, verbatim

> - next session i want to spend no more than 2 hours agreeing on the "north start" of "what is
>   the problem" and "What does a working solution look like"
> - once those are agreed to - i want your work here to have defined everything well enought that
>   you could autonomously execute each group of work.
>   - that is a requirement.
>   - I just want to review your solution at the end of a group of work along with a short report
>     of what was done, which files changed and why.
>   - report size limited to 600 words or less, diagrams are helpful.
> - you have a lot of information, once we set the north star together i expect you to be able to
>   execute the solution.
> - your plan will stop at the end of each group of work
> - your plan should assume the first issue we tackle is fixing your inability to merge PRs without
>   explicit permission from me. i can guide you through that solution when we implement that issue.

## What these constraints require of the plan

Each is a test the plan either passes or fails.

| Constraint | What the plan must contain to satisfy it |
|---|---|
| **≤ 2 hours to agree the north star** | Every group states *the problem* and *what working looks like* in a form that can be read and agreed, not derived. A group needing discovery during that session fails this |
| **Autonomous execution after agreement** | Every issue carries acceptance criteria checkable **without the user**. A criterion only he can judge is a blocker, not an acceptance criterion |
| **Stop at the end of each group** | Group boundaries are the only stopping points. No issue may straddle two groups |
| **Report ≤ 600 words, diagrams welcome** | The report template is part of the plan, not improvised at the end |
| **Merge permission first** | Group 0 is [#138](https://github.com/Calyx-Engineering/arc/issues/138). Without it every group ends unable to land its own work |

## The requirement that decides whether this is possible

**Autonomous execution requires a test, and until 2026-09-05 nothing in this repository executed
a skill.**

`claude plugin eval` closes that. It runs cases against an installed plugin, grades them,
supports `tool_used: Skill` as a **plugin-fired indicator**, defaults to 3 runs per case, and
exits 1 below `--threshold`. That makes *"did the skill fire"* a number with a gate rather than
an assertion.

**So the eval suite is a precondition, not a deliverable.** Groups 1 and 2 cannot be executed
autonomously without it, because their acceptance criteria are behavioural.

## Standing rules this plan inherits

From `CLAUDE.md` and the retrospective. Listed because an autonomous run will not have the
conversation that established them.

| | |
|---|---|
| **Groups are the stopping points** | Autonomy ends at each group boundary — `skills/autonomy-set` |
| **A merge runs only on an explicit request** | Until [#138](https://github.com/Calyx-Engineering/arc/issues/138) is fixed. Group 0 exists for this |
| **Branches are created through `createLinkedBranch`** | `git checkout -b` produces no branch↔issue link |
| **Every merged unit gets a dev-log** | `skills/record-route` |
| **Soak before a plugin change leaves the machine** | A commit with no soak line is unsoaked |
| **No development narrative in any document** | State the conclusion. This applies to the reports too |
| **Read the work back against the issue before a PR** | [#140](https://github.com/Calyx-Engineering/arc/issues/140). Two passes, whole files |
