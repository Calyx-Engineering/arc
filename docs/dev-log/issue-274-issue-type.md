# Issue #274 — the issue type says who does the work

**Issue:** [#274](https://github.com/Calyx-Engineering/arc/issues/274)  ·  **PR:** [#306](https://github.com/Calyx-Engineering/arc/pull/306)

## Problem

No issue in this repository carried a GitHub issue type. `tools/arc-loop.sh` selected on
*open child of this workstream* and nothing else, so an issue needing hardware, an account, or
a judgement call was one mis-filing away from being handed to an unattended `claude -p`.

## Intent and north star

| | |
|---|---|
| **What this issue is really for** | Giving *who does the work* a field of its own. The prefix and its label already answer *what kind of work is it*; there was no answer to *whose* |
| **North star** | The loop's queue is the Agent-typed children, the sweep reports an untyped open issue, and the Dogfood milestone answers the question for every open issue in it |
| **What makes it durable** | Three carriers, not one: a rule in `skills/issue-write`, a filter in the dispatcher, a gate in the sweep. A rule stated only in prose is re-derived wrongly by the next cold session |
| **Out of scope** | Backfilling the Self-improvement and Onboarding milestones and the six unmilestoned ones — the issue names Dogfood, and typing 24 more issues means deciding ownership for arcs nobody is running. `tools/verify-labels.sh` reports them, so the debt is visible rather than silent. Also out: judging *which* non-`Agent` type an issue takes, and adding a hook that denies an untyped write |

## Decisions & trade-offs

| | |
|---|---|
| **Presence is judged, never which type** | The rule is *who*, not *which*: `Task`, `Bug` and `Feature` all say "a human's". A sanctioned-set check would report every type the org adds as a defect on the day it is created, and the org's type set is not this repository's to hold |
| **The type check lands in `verify-labels.sh`, not a new script** | It is a verdict about one open issue read from one `gh issue list` sweep. A second script would make a second network read of the same rows to answer half a question |
| **…but as its own pure function, not a branch inside `classify`** | `classify` answers *does the label agree with the prefix*. Folding presence-of-type into it would make an issue with a right label and no type print a label finding, which is the wrong sentence. `classify_type` is separate and both verdicts are reported for one row |
| **One read, and the callers filter it** | `open_child_rows` returns every open child with its type. The report run is dispatched when that read comes back **empty**, so filtering the type inside it would have announced a workstream finished while a human's issues were still open. *Is anything left* and *is anything dispatchable* are different questions off one row set |
| **Three refusals on the `--issues` batch, not two** | It is the one path that names issue numbers directly, so selection cannot protect anything there. Not a child of this workstream · typed as a human's · carrying no type at all — the last is a defect in the issue rather than a decision about it, and the message says so |
| **The loop's terminal message split three ways** | Blocked waits on an issue, claimed waits on a dispatcher, a human's issue waits on a human and no dispatcher will ever take it. Reporting all three as "blocked" sends the reader hunting a dependency that does not exist |
| **`--resume` is gated on the issue's own type, not the parent's child list** | A resume takes no workstream argument, and retyping an issue to `Task` is how a human takes work back off the loop mid-run. Reading the parent would not have seen that; reading the issue does |
| **The rate-limit auto-resume is gated too, but fails open** | `wait_run` re-launches the same session up to `MAX_RETRY` times across hours of waiting, and never re-read anything. That is exactly the window in which a human notices and retypes. It refuses a resume when the type has moved off `Agent` — but a failed `gh` read leaves the run alone: starting blind and continuing work already in flight are different acts, and `--resume` dies where this one carries on |

### The backfill's ownership split

44 open Dogfood issues, all now typed. `Task` where a human is required:

| | |
|---|---|
| Containers | [#90](https://github.com/Calyx-Engineering/arc/issues/90), [#145](https://github.com/Calyx-Engineering/arc/issues/145), [#146](https://github.com/Calyx-Engineering/arc/issues/146), [#147](https://github.com/Calyx-Engineering/arc/issues/147), [#148](https://github.com/Calyx-Engineering/arc/issues/148), [#196](https://github.com/Calyx-Engineering/arc/issues/196) — nothing merges them, and a container closes when the user says so |
| Needs hardware | [#243](https://github.com/Calyx-Engineering/arc/issues/243) (a plugin reload on a quiet machine, 52 billed turns), [#246](https://github.com/Calyx-Engineering/arc/issues/246) (a scope, an amplifier and a driven signal) |
| Needs a decision, not a change | [#175](https://github.com/Calyx-Engineering/arc/issues/175) — whether `ROADMAP.md` is maintained or retired |
| Needs judgement about exposure | [#134](https://github.com/Calyx-Engineering/arc/issues/134) — what ships when Arc is published |
| Denied to a session already | [#242](https://github.com/Calyx-Engineering/arc/issues/242) — `gh label delete` was refused by the permission classifier, and the delete strips the label from everything wearing it |

The other 33 are `Agent`. [#287](https://github.com/Calyx-Engineering/arc/issues/287) is the
closest call and stayed `Agent`: it reads like a decision between two specs, but its `Required`
names a measurement that settles it.

## Rejected approaches

| | |
|---|---|
| **A `type:` prefix or a fourth label** | Types are an organisation-level set. A label would duplicate the field with no query behind it, which is exactly what [#84](https://github.com/Calyx-Engineering/arc/issues/84) retired six labels for |
| **Filtering the type inside the completeness read** | One line shorter and it breaks the report run — see the trade-off above. Written down because it is the obvious edit, and it survived one pass of review before being caught |
| **A hook that denies an untyped `gh issue create`** | The verifiers here report and never block, and nothing in the issue asks for a gate that fires on every tool call |

## Spawned

Nothing.

## Unplanned but needed

| | Why |
|---|---|
| **`--resume` gained the type gate** | It is the path that skips selection, so nothing else stops it. Every run directory created before this change was dispatched with no type check at all, and each is still `--resume`-able. Without it, `skills/issue-write`'s *dispatches these and nothing else* was false |
| **Three `gh` reads had their exit status checked** | `[ -n "$(…)" ]` around a command substitution discards it, so a failed `gh api graphql` returned empty and the loop read that as *nothing left* — dispatching the report run and announcing a workstream complete. Pre-existing on one read; this change would have added two more of the same shape. `verify-labels.sh` already states the principle in its own header (*a read that could not be made exits 2*) and arc-loop did not implement it |
| **`tools/verify-all.sh`'s `--list` caption** | It told the reader the live sweep covers *a label against its prefix, and the label set*. The sweep now also judges the type, and `--list` is the document that says what a green run does **not** cover |
| **Four documents describing the old selection rule** | `docs/arc-log/arc-04-dogfood.md` §3.1 is what `arc-loop.sh`'s own header cites as its reasoning, so leaving it saying *first open sub-issue* would have pointed the code at a spec contradicting it. The loop's Mermaid diagram in `docs/arc-work/04-dogfood/execution-process.md`, and `tools/arc-claim.sh`'s comment naming the removed `open_children`, are the same class |

## Retrospective

Three files carry the rule and one carries the record. `skills/issue-write` gained *The issue
type says who does the work* with the create, edit and read-back commands, an `issue-type` token
in its `checks:` frontmatter, and a `skips:` condition for the writes that have no type to set;
`templates/issue.md`'s *Set at creation* list went from three fields to four, and so did the
skill's own sentence citing it — the skill names that list as the authoritative one, so widening
only the template would have moved the false assertion rather than removed it.

**Both directions of the dispatcher filter were exercised against the live tracker**, not
reasoned about. Four dispatch paths reach a `claude -p`, and each refuses a non-`Agent` issue:
selection, the `--issues` batch, `--resume`, and `wait_run`'s automatic resume after a rate
limit. The last two were found by the review passes, not by the plan — the first draft gated the
two obvious ones and left the two that skip selection, which are the ones nothing else protects.

`tools/arc-loop.sh 148 --dry-run` before the backfill — every child untyped —
printed *every remaining issue in #148 is a human's — none is Agent-typed* and exited 1. The
`--issues` refusal was driven through a copy of the script with `run_batch` stubbed, because a
check that failed to fire would otherwise have launched a real unattended session at
[#134](https://github.com/Calyx-Engineering/arc/issues/134) — refused there, and dispatched
cleanly for [#271](https://github.com/Calyx-Engineering/arc/issues/271), which is `Agent`. Both
refusal messages were reworded after that run, so the wording it printed is not the wording
shipped here; what it demonstrated is that the branch is reached.

The selftest grew from 27 cases to 39. Six of the twelve new ones are parse cases: the type added a
**second empty-able field** between two populated ones, which is the same shape as the defect
[#84](https://github.com/Calyx-Engineering/arc/issues/84)'s sweep shipped with — a collapsing
separator putting the title into the wrong variable. The unit separator already handled it; the
cases are there so a future change to the row format cannot quietly reintroduce it.

`bash tools/verify-labels.sh` now exits 1 on 24 untyped issues outside the Dogfood milestone.
That is the check working, and the debt is deliberate — the *Out of scope* row above says why.

### The base moved twice, and the second move is why the gate went green

`bash tools/verify-all.sh` failed on this branch with `hook: tracker-verify — 60 passed, 57
failed`, every failure a bash syntax error thrown by the hook's own header. Nothing here
touches `hooks/`, and the base at the fork point passed the same gate 118/118 — so the first
reading was a corrupt checkout in this worktree. It was not. The blob genuinely differed:
`git diff origin/arc/04-dogfood...HEAD -- hooks/` is empty because `...` diffs from the
merge-base, and the merge-base was the tip this branch had already merged. **Two dots, not
three, is the question to ask of a branch that has merged its base once**, and
`git rev-parse <ref>:<path>` is the answer that cannot be argued with.

The defect was [#305](https://github.com/Calyx-Engineering/arc/issues/305) — a comment in
`hooks/tracker-verify` carrying literal control characters inside backticks, which bash parses
as a command substitution. It was filed and fixed on the base while this issue was in flight.
Merging the base a second time took the fix and the gate went green.

**That second merge silently rewrote a file this issue has nothing to do with.**
[#239](https://github.com/Calyx-Engineering/arc/issues/239) rotated `.claude/arc/log.md` into
`docs/arc-log/events/arc-03-camp.log.md`, so git saw a rename with content on both sides. The
conflict markers covered one hunk; 5,886 lines of this session's arc-04 entries merged into
arc 03's rotated archive **outside** it, with no marker and no prompt. Resolving the marked
hunk is not resolving the merge — `git diff origin/<base>..HEAD --stat` after the commit is
what catches it, and it is the reason a rename conflict is worth reading whole.
