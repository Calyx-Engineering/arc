# Arc 04 dogfood — how a run behaves

**You are one iteration of a loop.** Fresh session, no memory of the iterations before you. The
repository is the only state that survives you — nothing you hold in context reaches the next run.

**The driver tells you which kind of run you are, and they share almost nothing.**

| | Does | Reads |
|---|---|---|
| **An issue run** | One issue — or one **batch** the driver hands it, §1 — start to finish, then stops. Its record is three things: **the issue's own checklist, ticked with evidence**, the dev-log, and the PR body. It never writes a boundary report, having seen one issue | **§1–§5**, then §7 |
| **A report run** | No work at all. Reads a closed workstream's merged PRs and dev-logs, writes its boundary report, and hands back | **§6**, then §7 |

**§7 applies to both.** If you are an issue run, §6 is not yours; if you are a report run, §2's
review passes are not.

## 1 What you read

| | |
|---|---|
| **The issue body** | The spec. Its `Required` checklist is the acceptance criteria, and the only definition of done |
| **What the issue names** | The files, mechanisms and skills it links — and nothing beyond them |
| **`CLAUDE.md`** | Loaded for you. Branching, commit rules, soak, safe hook editing, how David works |
| **A batch, if the driver hands you one** | Two or three issues that share one deliverable — the same hook, the same skill. One branch named for the first, one PR closing every one, **one commit per issue, in the order given**. Finish an issue's checklist before starting the next. `CLAUDE.md`'s one-hook-per-commit holds inside a batch |

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
| 1 | **Read the issue, then label it `in-progress`.** `gh issue edit <NN> --add-label in-progress`. **Then cut the branch and read the link back** — `createLinkedBranch`, then `bash tests/verify-linked-branch.sh <NN> <branch>`, §4. It is the only moment that reading is decisive; by step 8 a PR exists and the answer has moved. Then **write the test or eval case** — it is the spec, and writing it after the fix is grading your own homework |
| 2 | **Implement, ticking each box as it is satisfied.** Not at the end — the tracker is where someone watching an unattended run learns where it got to, and a box ticked in a batch at step 6 tells them nothing while it matters. **Read the body back after each write:** [#87](https://github.com/Calyx-Engineering/arc/issues/87) is open, a failed edit silently restores the original, and one write per box is one exposure per box |
| 3 | **Run the gate. The exit code, not a claim.** `bash tests/verify-all.sh` always, plus whatever the issue's *Done when* names — `bash tools/verify-hook.sh`, `bash tools/skill-firing.sh`, a `gh` read-back |
| 4 | **Pass 1 — is every requirement met?** Read every changed file end to end against the issue. **Whole files, never the diff** — the defect is in the section the diff does not show |
| 5 | **Pass 2 — what did pass 1 introduce?** Its own edits are unreviewed |
| 6 | **Pass 3 — audit the checklist, box by box, against what is actually in the tree.** Step 2 ticked the boxes; this pass asks whether each tick has evidence behind it, and unticks any that does not. Every box ends ticked with its evidence, or named as not done with the reason. **A tick is a claim about the tree, not a record of intent** — a checklist ticked from memory leaves the tracker describing work that did not happen, and a silently unticked box is how [#17](https://github.com/Calyx-Engineering/arc/issues/17) shipped missing two of five requirements |
| 7 | **Dev-log, commit, open the PR as a draft** |
| 8 | **Pass 4 — read it as a reviewer who was not here.** The diff, the title, the body, the closing keyword, the base branch, the milestone, the branch↔issue and PR↔issue links — `bash tests/verify-linked-branch.sh <NN> <branch>`, which by now answers from the PR, so it confirms the closure binding and not the branch link, §4. This class of defect is invisible until the unit is a PR |
| 9 | **Fix what pass 4 found, then mark it ready** |

**Passes 1 to 3 are the ones a run skips under time pressure. They are the reason this file
exists.** Pass 4 is why the PR opens as a draft — it can still take commits.

**Passes 1 to 3 are read by a sub-agent, not by you.** Each pass dispatches one read-only
sub-agent carrying the issue body and the list of changed files. It reads the whole files and
returns findings; you act on them. The passes are unchanged — the same three questions, whole
files, never the diff. What changes is where the reading lands: a run that read every file itself
carried 140K tokens of context into every later turn, and 180 turns of that was the cost of
[#158](https://github.com/Calyx-Engineering/arc/issues/158). §3 permits exactly this — a large
read that collapses to a small answer.

## 3 Sub-agents — read and return only

| | |
|---|---|
| **Use one for** | A large read that collapses to a small answer — scanning transcripts, sweeping a directory, scoring a corpus, **and §2's passes 1 to 3** |
| **Never for** | Implementation |

**A sub-agent that edits files and reports *done* is the failure this arc exists to fix.** You
cannot verify work you did not see, and step 4 is not satisfiable on a report.

**Nothing runs in the background — no sub-agent, no Bash task, no gate, however slow.** You are
a `claude -p` session: it ends when you end your turn, and a background task's notification never
arrives. The run for [#151](https://github.com/Calyx-Engineering/arc/issues/151) ended after 62
minutes with a draft PR, waiting on a suite it had sent to the background; three S12 runs on
2026-09-12 ended the same way, each with its edits uncommitted, each waiting on `verify-all.sh`.
Give a slow command a long timeout and wait for it. `verify-all.sh` is 68 gates and takes ten to
twenty-five minutes when several runs share the machine — call it as
`LANG=en_US.UTF-8 bash tests/verify-all.sh` with the tool's maximum timeout, and if it times out,
call it again the same way; every S12 run that backgrounded it instead ended before the result.

**Nobody answers a question.** A run that stops to ask — *run it now, or leave it?* — ends its
turn and gets no reply; the run for [#314](https://github.com/Calyx-Engineering/arc/issues/314)
did, with its second issue untouched. Decide, write the assumption into the dev-log, and continue.
A decision the issue's constraints already settle is not yours to reopen; one they leave open is
yours to make and state.

## 4 Where the work goes

Branch, commit and PR mechanics are `CLAUDE.md`'s. What this arc pins down:

| | |
|---|---|
| **Branch** | `arc/04-dogfood-issue-<NN>-<hint>`, cut from `arc/04-dogfood`. From `createLinkedBranch`, never `git checkout -b` — otherwise no branch↔issue link forms, and the mutation cannot link a branch that already exists |
| **Then read the link back** | `bash tests/verify-linked-branch.sh <NN> <branch>`, straight after the mutation and **before the PR exists — that is the only moment the answer is decisive.** The mutation's own return value is not evidence; it reports what it was asked to do, not what the tracker holds. Once the PR is open the link has moved into its `closingIssuesReferences`, where a `Closes #NN` keyword produces the same reading a real branch link does. [#206](https://github.com/Calyx-Engineering/arc/issues/206) |
| **Worktree** | `tools/arc-loop.sh` put you in a worktree of your own — the prompt names it, `git worktree list` confirms it. Check your branch out **there**. Never `cd` to the main tree: another run, or the orchestrator, is working in it |
| **Dev-log** | `docs/dev-log/issue-<NN>-<slug>.md` |
| **A run commits** | A loop cannot ask, so the driver dispatches into autonomous mode and `HANDOFF.md`'s row says so. **If it does not, `hooks/mode-guard` denies the commit** — that is correct, and the fix is the mode row, never a workaround |
| **A run merges its own PR** | In autonomous mode, and only there. `hooks/mode-guard` reads `HANDOFF.md` before the merge as it does before the commit, so manual stops it at the same place. The row it reads is the one in **your worktree** |

## 5 When you stop

| | |
|---|---|
| **Done** | Every box in `Required` resolved — ticked with evidence, or named as not done with the reason. Pass 4 done, PR marked ready, and merged if the mode allows it. **Then `gh issue edit <NN> --remove-label in-progress`** |
| **Blocked** | The issue cannot be done as written. **Say why and stop.** Do not redesign the issue, and do not do an adjacent issue instead. **Remove the label here too** — a run that stops still stops, and a label left behind says work is underway when nothing is |
| **Scope grew** | **A finding goes in the dev-log** — a wrong premise, a defect spotted in passing, an approach ruled out. **A filed issue goes in a `Related` row**, and only a filed issue does. Then finish what you were given: a discovery is not permission to widen the unit |

**An issue body has no `Spawned` heading, and one row shape is the only shape.** `Spawned` is a
row in the issue's `Related` table — three columns, the kind, the link, one clause — and
`Related` is the body's last section. Add the row to **the issue that caused the work**, which is
usually yours.

```markdown
| | Link | What it is |
| :--- | :--- | :--- |
| **Spawned** | [#NN](https://github.com/Calyx-Engineering/arc/issues/NN) | <one clause> |
```

**The edge is written from both ends.** The new issue's own body carries the same table with a
`Spawned by` row naming yours. An issue filed without one cannot be reconstructed later, so
`hooks/tracker-verify` reports a `gh issue create` whose body has none. It asks only when the
branch you are on names an issue or a PR, which on §4's branch it always does.

**A finding is not a unit of work, so it has no row.** Only an issue you actually filed, or a PR
opened with no issue behind it, is a unit — [`skills/issue-write`](../../../skills/issue-write/SKILL.md),
*`Spawned` holds units of work. Nothing else*. Everything else this run learned goes in the
dev-log it writes at §2 step 7. `hooks/tracker-verify` reports a `Spawned` heading on
`gh issue create` and `gh issue edit`.

## 6 A report run — the workstream boundary

**Only for a report run.** An issue run never reaches this section. Its record is the issue's own
checklist ticked with evidence (§2 step 6), the dev-log and the PR body (§2 step 7) — the issue
body has to end up saying what was actually done, or the tracker and the work disagree.

### 6.1 At the boundary, in this order

**The boundary is a handover, not a finish line.** Seven steps, and the last three are what makes
it a review rather than an announcement.

| | |
|---|---|
| 1 | The workstream's last issue closes and its PR merges |
| 2 | **Read the workstream's record**, and only that: every child issue's body, every merged PR, every dev-log. **The issue bodies are the point** — a box left unticked, or ticked with no evidence, is what section 6.2's *Not done* is for. Do not read the issue plan, and do not open the code |
| 3 | Write the report into the arc-log's status section, as `#### <n>.<m>.1` onward |
| 4 | Post the same report as a comment on the **workstream parent issue** — that is where it gets read |
| 5 | **Check `HANDOFF.md`'s Execution mode row says Manual.** The named boundary is reached, so the grant is spent. `tools/arc-loop.sh` sets it on every exit path — if you were dispatched by it, confirm rather than write. If you were not, set it yourself: dropping to manual is yours to do, raising it never is |
| 6 | **Leave the parent issue open. A workstream parent closes when the user says so, not when its children do.** All children closed is mechanical completion, not review. Closing it removes the surface the report is read on and buries the report in a closed issue — [#144](https://github.com/Calyx-Engineering/arc/issues/144) was closed the moment its children closed, and had to be reopened |
| 7 | Stop. The next workstream is a separate invocation and a separate grant |

**Step 5 before step 7, not after.** A run that finishes the work and then keeps going has not
reached a boundary — it has passed one.

### 6.2 The boundary report — 200 words maximum

**Seven sections, in this order, as `####` headings numbered under the report's own number** —
`#### 6.2.1 Delivered`, `#### 6.2.2 Spawned`. They are sections, not list items: a heading is
citable, appears in the document outline, and can be answered by number. A bold lead-in inside
a paragraph is none of those.

| | Holds |
|---|---|
| **1 Delivered** | What the workstream produced, in the user's terms. **A numbered list**, one line each. Not a list of commits |
| **2 Spawned** | Every issue this workstream filed. **A table**: the number, one clause, and **where it routed** — this workstream, another one, elsewhere in the arc, or out of it. Routing is the half a reader needs and the half most often left out. If none, say none |
| **3 Unexpected** | What was not foreseen — a wrong premise, a blocked dependency, a defect found in passing. **The section most likely to be omitted, and the one worth most** |
| **4 Unplanned but needed** | Functional changes nobody scoped that the work could not proceed without, and why |
| **5 Evidence** | Gate output. `verify-all.sh` exit, scores before and after |
| **6 Not done** | Named, with the reason |
| **7 What it changed** | The diagram, where one helps. Optional — see below |

**A list is a list.** Items separated by `·` inside a paragraph are prose wearing a list's
clothes: they cannot be scanned, and they cannot be answered by number. **Sections 1, 3 and 6 are
lists; 2, 4 and 5 are tables; 7 is the diagram.** Nothing in a report is a run-on sentence of
items.

**Section 7 is optional and does not count against the 200.** Where there is no diagram, the
report has six sections. Where there is one, it gets a heading — loose after section 6 it reads
as a picture of what was not done.

**The budget is checked — `bash tests/verify-report-budget.sh`, and `verify-all.sh` runs it.**
Loop's first report was 302 words and the user caught it, because the budget was stated in three
documents — this one, the arc-log and `execution-process.md` — and read by nothing. What counts
as a word is in that script's header and is worth knowing before writing: section 7 and every
fenced block, the section headings, the `**Workstream:**` line and the `*End of ...*` line are all
outside the count, as are table pipes, delimiter rows, list markers and the URL half of a link.
It reports and never truncates, and it does not check a report's self-declared count — that number
is a hand count, and only the one the script prints binds.

**Number the heading and frame the block.** The arc-log numbers every heading, `## 6`, `### 6.1`;
a report landing there as an unnumbered `###` breaks the document's own convention and cannot be
cited. And a report sits between a status table and the next workstream's block, so without rules
it reads as more of the page.

```markdown
---

### <n> <Workstream> — boundary report

**Workstream:** <name> · **Closed:** <date> · **<N> words**, diagram excluded

…sections 1 to 6, then 7 if there is a diagram…

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
| Take on an issue you were not given | What the driver handed you — one issue, or one batch — is the unit. Stop |
| Choose your own issue | The driver picks — [arc-log §3.1](../../arc-log/arc-04-dogfood.md#31-how-a-run-knows-which-issue-is-next). A run that selects its own work has read the whole milestone to do it |
| Commit, push, PR or merge when the mode says manual | Propose and wait. `hooks/mode-guard` denies it, and a denial is the rule working, not an obstacle |
| Set the mode to autonomous | Only the user raises it. You may set it to manual — that removes authority rather than granting it |
| Close a workstream parent | It stays open until the user closes it. All children closed is completion, not review — §6.1 |
