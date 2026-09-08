# The close sequence, and starting the next issue

> **The authority on the order.** `skills/camp` names these steps and points here rather
> than restating them, so there is one list to change.

**The point is invariance.** Two different sessions closing two different issues produce the
same ten steps in the same order — so the process does not vary with how much context the
session still holds. A session that is nearly full closes an issue the same way a fresh one
does.

**Camp performs none of these.** It names which remain, in order, and confirms each landed
before naming the next — **step 5 excepted**, whose record is written into the PR at step 6 and
so is confirmed one step late. **Every step is owned** — by an artifact, by the person the mode
says, or, for step 5, by a read-only sub-agent, because that one is judgement.

---

## Closing — ten steps

| # | Step | Owned by | Confirmed by |
|---|---|---|---|
| 1 | **Every checklist item resolved** — ticked with evidence, named as not done with the reason, or moved to the issue that owns it | Camp names what is unresolved | `tools/verify-issue-boxes.sh <NN>`, which [`hooks/tracker-verify`](../../hooks/tracker-verify) also runs on `gh pr ready`. Its exit code, not the issue body read by eye |
| 2 | The `dev-log` written for this **unit** — `issue-<NN>-` or `pr-<NN>-`, whichever identifier it carries | [`skills/record-route`](../../skills/record-route/SKILL.md) | The file exists |
| 3 | The `arc-log` status row updated | [`skills/record-route`](../../skills/record-route/SKILL.md) | The row says what merged |
| 4 | Changes committed — nothing uncommitted in the tree | [`skills/work-watch`](../../skills/work-watch/SKILL.md) | `git status --short` is empty |
| 4b | **Every gate clean** | `tools/verify-all.sh` | Its own exit code — one command, not a claim per gate |
| 5 | **The work read back against the issue** — every changed file, whole, against the issue body | A read-only sub-agent the session dispatches — **judgement, so never a gate script**. [See below](#step-5-is-the-one-no-gate-can-do) | Its findings, and a disposition for each — the one step confirmed after the fact, since the record of them lands in the PR body at step 6 |
| 6 | PR opened, titled with the arc prefix, milestone set | [`skills/issue-write`](../../skills/issue-write/SKILL.md) | `gh pr view` |
| 7 | `Closes #NN` present, and **verified to have bound** | [`hooks/tracker-verify`](../../hooks/tracker-verify) | **See below** |
| 8 | Soak line appended, if the change touched the plugin | The repo's `CLAUDE.md` soak rule | The arc-log |
| 9 | **The PR is merged** | **Whoever the mode says** — the user in manual, the agent in autonomous ([m40](mechanisms/m40-autonomy-switch.md)) | `gh pr view --json state` |
| 10 | Branch deleted once merged | The same — the user in manual, the agent in autonomous. **Never `--delete-branch` on the merge**; delete separately | `git branch -a` |

**Steps 1 to 8 are Camp's to name. Steps 9 and 10 are performed by whoever the mode says** — the
user in manual, the agent in autonomous. An issue is not closed because the work is done; it is
closed because someone merged it.

**The harness may refuse the merge whatever the mode says.** Retry at most once, then hand it
over and say what was tried — [m40 §7](mechanisms/m40-autonomy-switch.md).

**The intent check fires inside step 6, not as a step of its own.** `issue-write` runs
[`skills/arc-intent`](../../skills/arc-intent/SKILL.md) before it writes the PR body — *does
what this delivers serve the arc.* It is a checkpoint that already existed, which is why it
adds no step and cannot change the count.

### Step 5 is the one no gate can do

Every other step is confirmed by something that can be looked at — an exit code, a file, a row,
an API read. This one is confirmed by reading, because what it checks is whether the prose is
true, and prose is not executable.

**Step 1 is not part of that, and [#140](https://github.com/Calyx-Engineering/arc/issues/140)'s
constraint originally read as if it were.** Whether every `- [ ]` in the issue body is still
unticked is a `gh` query and a count — `tools/verify-issue-boxes.sh`. Whether a tick has
evidence behind it is this step. The mechanical half was silent for want of the distinction,
in both directions: [#17](https://github.com/Calyx-Engineering/arc/issues/17) shipped missing
two of five requirements, and [#194](https://github.com/Calyx-Engineering/arc/issues/194)
reached its PR with twelve unticked boxes that were all actually done. Seventy-eight offline checks passed on the change that
shipped a README whose Requirements, Results, Troubleshooting and *What it does* sections each
named something that change had removed. All four were in sections the diff did not touch.

**The issue is the specification.** Each changed file is evaluated against the issue body, never
against the diff and never against what the session meant to write. A diff shows what moved; the
issue says what was supposed to be true afterwards.

**Whole files, never diffs.** The defect is in the part the diff does not show.

**A file the change gives a new capability to is a file whose whole text is now suspect.** A new
capability changes what every other sentence in that file is claiming, including the sentences
nobody touched.

**Two passes, not one — and two dispatches.** Pass 1 asks what the change broke. The session
disposes those findings, and pass 2 is a second dispatch asking what pass 1's own fixes
introduced: those edits arrived after the reading and are themselves unread. Pass 2 carries the
same issue body and the files the dispositions changed. One pass run twice asks the same
question twice, and the second run finds nothing.

**Step 1 dispositioned the boxes; this is where each tick is checked against the tree.** That is
the half a session cannot do from memory — a box ticked from intent leaves the tracker describing
work that did not happen. A tick with no evidence behind it comes off, and the box is then
resolved like any other: named as not done with the reason, or **moved to the issue that owns
it**, since a box this unit cannot meet belongs to another issue and left unticked here records
nothing. Partial completion stays approvable — the requirement is that the state is stated, not
that everything is done.

#### Who performs it — and why not the session

**A read-only sub-agent.** By the time a unit reaches its PR, the session that did the work is
carrying the whole history of how that work was reasoned into being, and it reads the files it
wrote as the files it meant to write. The agent reads the issue and the changed files and
nothing else — no memory of the arguments, no attachment to the wording. Same reasoning as
[`agents/transcript-miner`](../../agents/transcript-miner.md).

| | |
|---|---|
| **It gets** | The issue body verbatim, and the files to read — the unit's changed files on pass 1, what the dispositions changed on pass 2. It reads them whole |
| **Not** | A brief derived from the issue — a brief is written by the session whose bias the agent exists to remove. Nor the whole repository |
| **It returns** | Findings. Never edits, never a verdict — a sub-agent that edits and reports *done* is unverifiable, because nobody saw the work |
| **It runs** | Twice for every unit, before its PR — once on the changed files, once on what the dispositions changed. Never on a size threshold, which would be judged by the session this step distrusts |
| **It costs** | Two dispatches whose context dies with them, against two whole-file readings carried in the session's own context for the rest of the unit. Delegating changes where the reading lands, never what is asked |
| **It blocks** | Nothing. Findings are dispositioned in the PR body, like every other verifier here |

**Acting on a finding dirties the tree again, and step 4 is re-established before step 6** —
each round of dispositions is committed, and the gate re-run, so the PR opens on a clean tree.

**The session disposes each finding in the PR body** — acted on, or declined with the reason. A
pass that returned nothing is recorded as having returned nothing, because **silence in the body
is indistinguishable from a step nobody ran.**

### Step 7 is the one that fails silently

A closing keyword on a PR into an arc branch **reports success and binds nothing** — the
keyword only binds against the repository's default branch. See
[m42](mechanisms/m42-default-branch-flip.md).

```sh
gh pr view <N> --json closingIssuesReferences
```

**An empty array means the issue is not closed, whatever the body says.** Read the array, not
the keyword.

> **Camp refuses to call an issue closeable while step 7 is unverified.** This is the one step
> phrased as a refusal, because a silently unbound keyword is the failure the whole sequence
> exists to catch — and it is invisible in every other surface.

### Naming what remains

Camp names the steps still outstanding, in order, and stops at the first one that is not
done. It does not list all ten every time; a session three steps in hears about steps 4
onward.

```text
**Camp here —** #41 looks closeable. Five steps remain:
  4 · two files uncommitted
  5 · the read-back — no findings dispositioned yet
  6 · no PR yet
  7 · unverified — check closingIssuesReferences after it opens
  8 · plugin change, so a soak line is due
```

---

## Starting the next issue — four steps

| # | Step | Owned by |
|---|---|---|
| 1 | The next issue, from the arc-log's order and its merged dependencies | Camp names it |
| 2 | Branch created from the arc branch, `arc/<nn>-<slug>-issue-<NN>-<slug>` — or `-pr<NN>-` where there is no issue, via `tools/new-direct-pr.sh` ([m46 §9](mechanisms/m46-work-navigation.md)) | The main thread, after approval |
| 3 | The record loaded — arc intent, the issue, the handoff if one exists | Camp |
| 4 | The issue checklist becomes the session's working state | [`skills/work-watch`](../../skills/work-watch/SKILL.md) |

**A dependency that has not merged is a blocker, not a note.** Step 1 checks merge state, not
whether an issue exists.

**The crossing completes at step 4, not step 2.** An issue being open and a branch existing is
not the same as a session being ready to work on it.

---

## The handoff at a transition

A transition is exactly the moment the record must survive. [`skills/handoff`](../../skills/handoff/SKILL.md)
owns what a handoff contains and how it is written. **Camp owns noticing one is due, and
confirming it landed.**

| Step | Owner |
|---|---|
| Recognising a transition is happening | **Camp** |
| Writing the handoff | `skills/handoff` |
| Confirming it was written, and is current | **Camp** |
| Reading it back at the next session's start | `skills/handoff`, invoked by Camp |

**Camp never authors the handoff.** It fires the mechanism that does and verifies the result —
the same posture as the report, where the artifact does the work and Camp reports on it.

### When it fires, and when it does not

| | Fires a handoff |
|---|---|
| A session is ending mid-arc | **Yes** |
| A planned break at a wave boundary | **Yes** |
| Moving to the next issue in the same session | **No** |

Firing one at an issue boundary inside a live session produces a file that duplicates context
the session already holds — and a second source that drifts from the record.

### Two reads when work resumes

| | Holds | When it exists |
|---|---|---|
| **The handoff** | Where the last session left off | Only when a session ended mid-arc. Session-scoped, gitignored |
| **The record** | The arc's intent, the `dev-log`, the issue | Always |

**Camp loads the record either way, and the handoff when one exists** — which is why the two
are named separately rather than treated as one step.

---

## Status — what it is assembled from

**Camp holds no state of its own.** Status is assembled per invocation:

| Source | Gives |
|---|---|
| The `arc-log` status table | What merged, what is next, where the breaks are |
| The `dev-log` for the current issue | This issue's *why* and its open questions |
| Open issues on the tracker | Real merge state, rather than what a table claims |
| The handoff, when one exists | Where the last session stopped |

A cached status is a second source that drifts from the record. **Anything Camp reports is
re-read at the moment it is asked.**

An answer is three or four lines — which issues are open, what merged, what is next.

---

## Related

- [m43 §3.2](mechanisms/m43-camp-assistant.md) — status and flow, which this implements
- [m42](mechanisms/m42-default-branch-flip.md) — why step 7 fails silently
- [`camp-reports.md`](camp-reports.md) — the declaration every acting artifact carries
