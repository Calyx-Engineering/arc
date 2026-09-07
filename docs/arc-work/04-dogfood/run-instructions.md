# Arc 04 dogfood — executing one issue

**You are one iteration of a loop.** Fresh session, no memory of the iterations before you. One
issue, start to finish, then stop. The repository is the only state that survives you — nothing
you hold in context reaches the next run.

## 1 What you read

| | |
|---|---|
| **The issue body** | The spec. Its `Required` checklist is the acceptance criteria, and the only definition of done |
| **What the issue names** | The files, mechanisms and skills it links — and nothing beyond them |
| **`CLAUDE.md`** | Loaded for you. Branching, commit rules, soak, safe hook editing, how David works |

**Do not read [`issue-plan.md`](issue-plan.md).** It is the human's forest view of all five
workstreams. Pulling it in puts the whole arc in your context, which is the exact failure this
loop exists to avoid.

**If the issue does not say enough to do the work, stop and say so.** Do not go reading around
to find out. An under-specified issue is a finding about how this arc writes issues; guessing
buries it.

## 2 The sequence

**Four review passes, three before the PR and one after.** Each asks a different question — a
repeated pass asking the same one finds nothing.

| | |
|---|---|
| 1 | **Read the issue. Write the test or eval case first.** It is the spec — writing it after the fix is grading your own homework |
| 2 | **Implement** |
| 3 | **Run the gate. The exit code, not a claim.** `bash tools/verify-all.sh` always, plus whatever the issue's *Done when* names — `claude plugin eval --threshold`, `bash tools/verify-hook.sh`, a `gh` read-back |
| 4 | **Pass 1 — is every requirement met?** Read every changed file end to end against the issue. **Whole files, never the diff** — the defect is in the section the diff does not show |
| 5 | **Pass 2 — what did pass 1 introduce?** Its own edits are unreviewed |
| 6 | **Pass 3 — the checklist, box by box.** Every box ticked with the evidence for it, or named as not done with the reason. A silently unticked box is how [#17](https://github.com/Calyx-Engineering/arc/issues/17) shipped missing two of five requirements |
| 7 | **Dev-log, commit, open the PR as a draft** |
| 8 | **Pass 4 — read it as a reviewer who was not here.** The diff, the title, the body, the closing keyword, the base branch, the milestone, the branch↔issue and PR↔issue links. This class of defect is invisible until the unit is a PR |
| 9 | **Fix what pass 4 found, then mark it ready** |

**Passes 1 to 3 are the ones a run skips under time pressure. They are the reason this file
exists.** Pass 4 is why the PR opens as a draft — it can still take commits.

## 3 Sub-agents — read and return only

| | |
|---|---|
| **Use one for** | A large read that collapses to a small answer — scanning transcripts, sweeping a directory, scoring a corpus |
| **Never for** | Implementation |

**A sub-agent that edits files and reports *done* is the failure this arc exists to fix.** You
cannot verify work you did not see, and step 4 is not satisfiable on a report.

## 4 Where the work goes

Branch, commit and PR mechanics are `CLAUDE.md`'s. Four things this arc pins down:

| | |
|---|---|
| **Branch** | `arc/04-dogfood-issue-<NN>-<hint>`, cut from `arc/04-dogfood`. From `createLinkedBranch`, never `git checkout -b` — otherwise no branch↔issue link forms, and the mutation cannot link a branch that already exists |
| **Dev-log** | `docs/dev-log/issue-<NN>-<slug>.md` |
| **A run commits** | A loop cannot ask, so the driver dispatches into autonomous mode and `HANDOFF.md`'s row says so. **If it does not, `hooks/mode-guard` denies the commit** — that is correct, and the fix is the mode row, never a workaround |
| **A run does not merge** | Until [#138](https://github.com/Calyx-Engineering/arc/issues/138) lands, merging needs a route that does not exist. Open the PR and stop |

## 5 When you stop

| | |
|---|---|
| **Done** | Every box in `Required` resolved — ticked with evidence, or named as not done with the reason. Pass 4 done, PR marked ready |
| **Blocked** | The issue cannot be done as written. **Say why and stop.** Do not redesign the issue, and do not do an adjacent issue instead |
| **Scope grew** | Record it in the issue's `Spawned` table and finish what you were given. A discovery is not permission to widen the unit |

## 6 What you write

**There are two kinds of run.** The driver tells you which one you are.

| | |
|---|---|
| **An issue run** | Does the work. Writes the dev-log and the PR body. That is its whole record — it never writes the boundary report, because it only ever saw one issue |
| **A report run** | Does no work. Reads the workstream's merged PRs and dev-logs, writes the boundary report, stops |

### The boundary report — 200 words maximum

**Six numbered sections, in this order.** Numbered so the user can answer by number, and because
an unnumbered report reads as one block and gets skimmed.

| | Holds |
|---|---|
| **1 Delivered** | What the workstream actually produced, in the user's terms. Two sentences. Not a list of commits |
| **2 Spawned** | Every issue this workstream filed, by number, one clause each. If none, say none |
| **3 Unexpected** | What was not foreseen — a wrong premise, a blocked dependency, a defect found in passing. **The section most likely to be omitted, and the one worth most** |
| **4 Unplanned but needed** | Functional changes nobody scoped that the work could not proceed without, and why |
| **5 Evidence** | Gate output. `verify-all.sh` exit, scores before and after |
| **6 Not done** | Named, with the reason |

A diagram may follow and does not count against the 200.

**Number the heading and frame the block.** The arc-log numbers every heading, `## 6`, `### 6.1`;
a report landing there as an unnumbered `###` breaks the document's own convention and cannot be
cited. And a report sits between a status table and the next workstream's block, so without rules
it reads as more of the page.

```markdown
---

### <n> <Workstream> — boundary report

**Workstream:** <name> · **Closed:** <date> · **<N> words**, diagram excluded

…the six sections, then the diagram…

*End of <Workstream>'s boundary report.*

---
```

**Silence about what did not get done is the failure this arc exists to fix.** A report run that
finds an issue closed without its boxes resolved says so — it is reading the record, not
defending it.

## 7 Never

| | |
|---|---|
| Read the issue plan | §1 |
| Let a sub-agent edit | §3 |
| Claim a gate passed without the exit code | §2 step 3 |
| Retry a failed tracker write silently | Report the mismatch — `skills/issue-write` |
| Rename the branch of an open PR | It closes the PR. Tested |
| Commit to the default branch | `CLAUDE.md` — everything happens on a branch |
| Take on a second issue | One issue is the unit. Stop |
| Choose your own issue | The driver picks — [arc-log §3.1](../../arc-log/arc-04-dogfood.md#31-how-a-run-knows-which-issue-is-next). A run that selects its own work has read the whole milestone to do it |
