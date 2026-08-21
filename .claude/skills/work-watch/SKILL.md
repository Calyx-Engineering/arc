---
name: work-watch
description: Use continuously while work is in progress — one sweep that watches for six things and proposes, never acts. Whether the work has reached a point worth committing, whether a design decision just created a test obligation that will be forgotten, whether questioning has gone deeper than the decision warrants, whether an edit reported as done is contradicted somewhere else in the file, whether a settled decision has been written down before the next topic opens, and whether Arc itself just cost the work something. Run it at natural pauses, not every turn.
camp-reports: [commit-point-proposed, test-obligation-caught, depth-flagged, stale-claim-caught, decision-unwritten, friction-caught]
checks: [commit-point, test-obligation, depth, edit-completeness, working-surface, friction]
skips:
  - friction (the operating agreement has the friction log off)
---

> **Copy — do not edit.** The source is [`skills/work-watch/SKILL.md`](../../../skills/work-watch/SKILL.md),
> which is what the plugin ships. This copy exists only so the skill is live in this repo
> before Arc is installed here. **Edit the source, then re-run `tools/sync-local-skills.sh`.**

# Watching the work

Six mechanisms watch work as it proceeds. **One sweep, not six always-on checks
competing for the same attention.**

| Watches for | Proposes | |
|---|---|---|
| The work reached a reviewable point | A commit | m14 |
| A decision implies later physical verification | A test item | m23 |
| Questioning has gone deeper than the decision needs | Backing out to the critical point | m41 · [`relief-valve`](../relief-valve/SKILL.md) |
| An edit was reported done while the file still contradicts it | The grep that settles it | m13 |
| A decision is settled and the next topic is opening | Writing it down first | m13 · m15 |
| Arc itself cost the work something | A line in the arc's friction log | m17 · [`record-route`](../record-route/SKILL.md) |

> **Propose, never act.** Checks 1, 2, 3 and 6 nudge; the human decides. This is the whole
> posture, and violating it on the first — committing unasked — is the single most repeated
> correction in the record.
>
> **Checks 4 and 5 are gates, not nudges.** They govern your own behaviour rather than
> proposing anything: check 4 runs before you claim an edit is done, check 5 before you open
> the next topic. **Check 4 is the only one that blocks.** Check 5 nudges in one case — when
> the working surface itself has stopped holding the state, which is not something writing
> one more thing down repairs.

---

## When to sweep

At a natural pause: a document reached a readable state, a decision landed, a sub-analysis
finished, a question was answered. **Not every turn.**

Over-firing recreates the annoyance in a new form. The first three checks share one
threshold and it is judgment, not a count: *has anything actually changed since the last
sweep?* If not, say nothing.

**Checks 4 and 5 are exempt from the threshold.** Neither is triggered by a pause but by an
act — you are about to report an edit complete, or about to open the next topic. They run
every time, at that moment.

---

## 1. Has the work reached a capture point?

The rule, stated by the person who reviews the diffs:

> **"i think we want to commit at the first semi-mature state. not when it is first
> created."**

Committing at creation captures churn. Committing at a semi-mature state captures a
reviewable unit.

| A capture point | Not a capture point |
|---|---|
| A document reached "good enough to read" | A file exists but is still being drafted |
| An issue's work is functionally complete | A typo fix mid-iteration |
| A distinct sub-analysis finished | Every turn, or every tool call |
| About to change branch or worktree | **You feel uncertain and want a safety net** |
| About to start unrelated work | |
| Session is ending | |
| Before a long or risky operation | |

**The last exclusion is the cause of the over-commit failure.** An agent that has previously
lost work commits defensively, and that instinct is what fills a log with noise nobody can
review. Defensive committing is a feeling, not a capture point.

### Both directions fail

| | Cost |
|---|---|
| **Over-commit** — committing unasked, or too often | Destroys the review surface. *"i can't tell what you changed"* |
| **Under-commit** — nothing committed because nobody asked | Work at risk, sync blocked, and capture tracks someone's calendar rather than the state of the work |

Every commit across four weeks was human-initiated, several prompted by an interview or a
laptop switch rather than by the work reaching a natural point. Watching for the capture
point is what this fixes.

### Mechanical rules, each learned the hard way

| Rule | |
|---|---|
| **Never commit unasked** | Standing. Propose and wait |
| **Check files are saved first** | See below — this is upstream of half the problem |
| **Never squash merge** | It destroys reviewability |
| **Verify the commit identity** | Committing as one account and commenting as another makes no sense and has happened |
| **Watch for silently dropped staged files** | Recurred twice, weeks apart. Confirm what actually got staged |
| **Verify the issue closed** | A `Closes #NN` that did not bind reports success. See [issue-write](../issue-write/SKILL.md) |
| **Never amend or rebase a pushed branch** | See below — it is the one rule here whose damage is permanent |

The last two are **silent** — they report success and do the wrong thing.

### Never amend or rebase a branch that has been pushed

Once a branch is on the remote, `--amend`, `rebase`, and `push --force` rewrite history other
things already point at.

**The damage is to the graph, and it is permanent.** One amend on a pushed branch during arc
02 produced a three-way crossing in the merge graph that no later commit can clean up — the
arc's shape is harder to read forever, and the review surface is what a merge graph is *for*.

| Instead | |
|---|---|
| Wrong commit message | A follow-up commit, or fix it at merge |
| Forgot a file | A second commit. Small commits are not the problem |
| Messy history | It is a record of what happened. Leave it |

The exception is a branch nobody has pulled and no PR points at — which is difficult to be
certain of, and the certainty is worth less than the graph.

### Unsaved buffers

Several merge conflicts traced to one sequence: a file edited in VS Code, not saved, then
handed to the agent. The agent read stale content from disk, wrote its own version, and the
two diverged. **Those conflicts are what produced the defensive over-committing above.**

**VS Code exposes no dirty-buffer signal to an external process.** Checked directly — the
hot-exit backup directory is written when a window closes, not while editing. So the fix is
setup, not detection:

```json
{ "files.autoSave": "onFocusChange" }
```

Saves when focus leaves the editor, including clicking into the chat — the exact failure
moment, and a deliberate boundary rather than mid-keystroke. Ship it in the repo's
`.vscode/settings.json` at setup and say what it does, because editor changes then land in
the working tree continuously.

---

## 2. Did a decision just create a test obligation?

Design work creates obligations that cannot be executed yet — the board does not exist, the
bracket is not machined, the firmware is not written. **The obligation is specific at the
moment of design and forgotten by the time hardware arrives.**

> *"this issue can NOT be blocked by **building hardware** we need to update the design. we
> should probably talk about validation tests, but that is a seperate subject"*

The design issue must not block on hardware. The test must not be lost.

| Step | |
|---|---|
| 1 | Notice a design decision implies later physical verification |
| 2 | Propose the test item, and whether it appends or warrants a new issue |
| 3 | On approval, hand the content to [issue-write](../issue-write/SKILL.md) |
| 4 | Link back to the originating design issue |

**Append is the default.** *"i don't want 100 issues for each little one."* A new issue is
right when the test is substantial, needs its own procedure, or belongs to a different
subsystem.

**Each line is a specification, not a reminder.** The expectation is that the accumulated
list can be ingested to generate test firmware months later — so a line carries the
component, the expected behaviour, and a link to the design decision that caused it.

**This is not a requirements traceability matrix.** That is top-down from the story set and
belongs to Lodestar. This is bottom-up from the bench: *I just changed this — what do I
check when the board arrives?* A checkout list built only from requirements misses the
standby current on a PWM node nobody wrote a requirement for.

---

## 3. Has the questioning gone too deep?

> *"you'll keep asking detail questions and pushing deeper and deeper until i get frustrated
> instead of giving yourself an escape path or relief valve so we can get back to the
> critical point."*

**It is not that the questions are wrong. It is that there is no way out of them.** Each
answer opens two more, and the only exit is the human's patience running out.

| Watch for | |
|---|---|
| Several questions deep on one decision | Depth without the scope changing |
| Repeated clarification, no decision landing | |
| Stakes and depth mismatched | A four-hour milestone does not warrant the questioning a four-week one does |
| **Real decisions being made with no branch, issue, or repo** | Escalate — see below |

**Offer the exit; do not take it.**

> *"We are three questions into naming. Want me to pick and move, or is this worth
> settling?"*

### Untracked work is what makes it expensive

Before a branch or issue exists, every answer lives in chat alone — machine-local, lost with
the transcript. An hour of structural decisions can leave no artifact at all.

| | With a branch | Without one |
|---|---|---|
| Where the reasoning lands | Commits, issue bodies, specs | Chat only |
| Recoverable later | Yes | Only by mining the transcript, weeks on |
| Cost of over-depth | Time | Time, **and the record** |

When decisions are landing and nothing can record them, say so and propose tracking it. That
is the same failure class as the branch guard — work in the wrong place — except here the
wrong place is nowhere.

### The trigger is a mechanical precondition, then judgment

**No single signal means *too deep*.** Turn count alone fires during legitimate long
analysis; *"questions without a decision landing"* needs a definition of *landed*;
user-invoked puts the load back on the person the mechanism exists to protect.

**A combination of them does work**, and that is what fires this check:

| Signal | Threshold |
|---|---|
| Turns since the last commit or file write | 8 |
| Questions asked with no artifact changed | 3 |
| Minutes in one issue with no checklist movement | 45 |
| Emphasis markers — caps, bolded corrections, profanity, sharply shorter replies | any |

**Two of the first three fire it. An emphasis marker fires it alone.** The thresholds are
provisional estimates, replaced by mined evidence in
[#36](https://github.com/Calyx-Engineering/arc/issues/36).

**[`relief-valve`](../relief-valve/SKILL.md) is what this check runs when that precondition
trips** — the countable version of the same check, invoked rather than felt. It is not a
separate always-on process; it runs inside this sweep.

**Mechanical trigger, judged response.** The precondition decides whether to look; judgment
decides whether the depth is real, and the direction question sets the nudge's strength.

**What neither form fixes:** a skill the agent invokes is self-detection, and failing to
notice is the condition being detected. The precondition limits how much this matters; it does
not remove it. If a session ends with the person frustrated at depth, that is evidence the
check did not fire — and it belongs in a retrospective.

---

## 4. Is the edit actually finished, everywhere the claim appears?

> **Before reporting any edit done, `grep` the file for the string you replaced. Zero hits,
> or it is not done.**

One claim lives in several forms at once — a summary row, a table cell, a diagram label, a
prose sentence. Editing the form the person pointed at, then reporting the change complete,
leaves the others stating the opposite.

**This is not hypothetical and it is not rare.** It happened four times consecutively in one
session on a single file, each time reported as complete, each time caught by the person
rather than by any check.

### The rule

| Step | |
|---|---|
| 1 | Before editing, `grep` the file for the claim in **every** form it takes — not the sentence you were shown |
| 2 | Edit all of them |
| 3 | Before reporting done, `grep` for the replaced string again. **Zero hits, or it is not done** |
| 4 | Report the count you got, not the fact that you checked |

### Naming one location does not scope the edit

> *"fix the summary row"* means the claim is wrong, not that one row is wrong.

A person points at the instance they happened to see. They are reporting a defect, not
bounding a change. **Treat a named location as the symptom.**

### Where a claim hides

| Form | Why it is missed |
|---|---|
| **Diagram labels** | Inside a Mermaid block; a prose grep phrased in sentence form misses `W3["<b>Wave 3</b>…"]` |
| **Summary and header rows** | Written early, read as furniture, never re-read |
| **Section headings** | A heading asserting the old state survives a body rewrite |
| **Counts** | *"three modes"* over a four-row table. Changing the rows leaves the number |
| **The description in frontmatter** | Not visible in the rendered document at all |
| **A second file** | Mirrored files, and `skills/` versus `.claude/skills/`. See CLAUDE.md |

**A count is a claim.** Adding a row to a table whose sentence says *"three"* is the same
failure with no string to grep for — so when the edit changes a quantity, re-read the number.

### Grep for the old string, not the new one

Grepping for what you wrote confirms you wrote it. It says nothing about what survived.
**The check is that the thing you replaced is gone.**

```sh
grep -n "waves 3-6 are reviewed first" docs/arc-log/arc-03-camp.md   # expect zero
```

A structural check — links resolve, YAML parses, markdown lints — does not catch this. Three
defects have shipped in this repo past passing checks.

### Why it lives here and not in a tracker skill

[m13](../../../docs/product-architecture/mechanisms/m13-issue-write-back.md) records this
failure shape for tracker writes and states that file edits are *"verified routinely"*. **That
is disproved.** The same shape occurs in files; the difference is only that a diff makes it
recoverable, not that it is caught.

---

## 5. Does the working surface still say where the work is?

> **A decision that lives only in the conversation is lost at compaction. Write it to its
> artifact before the next topic opens.**

**Focus degrades with context length regardless of intent. Structure outside the context does
not** — a checklist read fresh each turn is as good on turn 200 as on turn 10. That is
[m15](../../../docs/product-architecture/mechanisms/m15-handoff-spine.md)'s argument applied
inside a session rather than between them.

**The transcript holds the reasoning; the tracker holds the state.** Losing the transcript
should cost the *why* behind a few decisions and nothing else.

| Fires when | The gate |
|---|---|
| **A decision was settled and the next topic is opening** | Write it to its artifact first — the spec, the dev-log, the issue. Then move |
| **A tangent or a spawned idea appeared** | File it now. *"I will file that later"* is the failure this prevents; [`issue-write`](../issue-write/SKILL.md)'s `Spawned` section is where it goes |
| **A checklist item is done and still unticked** | Tick it and read it back. `gh issue view <N> --json body` — a tracker write reports success whether or not it landed |
| **Re-anchoring cost the transcript** | If working out where things stand meant re-reading the conversation, the surface has stopped holding the state. Say so |

### Mostly a gate, like check 4

**Check 4 gates your own reporting; this gates your own moving on.** Both fire on an act
rather than a pause. Announcing *"I am about to open the next topic"* is narration; writing
the decision down first is the whole behaviour.

**The last row is the exception, and it is a nudge.** *Re-anchoring cost the transcript* is
not something you can fix by writing one thing down — the surface itself has stopped working,
and only the human can decide whether to rebuild it, split the work, or carry on. Say it
once, propose, and move.

### Cheap to re-read, or it is not a working surface

| | |
|---|---|
| **Nine lines, not a page** | A surface that costs a page to load gets skipped, and a skipped surface holds nothing |
| **It is whatever the work is running against** | A scoping inventory ([`spec-interview`](../spec-interview/SKILL.md)), an issue's `Required` checklist, the dev-log's plan table. **This check does not create one** — it notices when the one in use has stopped being current |
| **Countable beats complete** | *Three of five* re-anchors in one glance. A prose paragraph describing progress does not |

### Where it stops

**Deciding what gets tracked is not this.** [m46](../../../docs/product-architecture/mechanisms/m46-work-navigation.md)
owns where a discovery goes and whether to ascend or descend to it; this check only fires the
moment one appears and nothing has been written down.

---

## 6. Did Arc itself just cost the work something?

**Only when the operating agreement has the friction log on** — off is the default, and off
means this check does not run. Where it is on, the log is
`docs/arc-work/<arc-slug>/friction-log.md` and [`record-route`](../record-route/SKILL.md)
routes to it.

**The subject is the tooling, not the work.** A wrong analysis is the work being hard; a step
that would not run is Arc being in the way. Only the second belongs here.

| Fires on | |
|---|---|
| **A step in a documented loop did not execute** | It was skipped, denied, or silently did nothing |
| **A correction given twice** | The second time is the signal. The first is a conversation |
| **Time lost to Arc rather than to the problem** | Hunting for a file the record should have named, re-deriving something already written down |
| **A tool call denied** | And the denial was *recorded* rather than diagnosed. What was refused is not the same question as which part |

**An entry is written at the moment, not at the break.** Reconstructed friction is what m17's
transcript mining exists to replace, and doing it by hand a week late is strictly worse than
both.

**Propose the entry; do not append it silently.** The user decides whether it was friction —
they are the one who felt it.

---

## Before the PR — does the build match the spec's diagram?

**A spec section that defines a feature opens with a diagram. That diagram is the compact
statement of what the feature is**, and it is the cheapest check available on whether the
right thing got built.

| Step | |
|---|---|
| **At the start of the work** | Read the section and its diagram. Every node is something the issue delivers |
| **Before opening the PR** | Walk the diagram node by node against what exists |

**A mismatch is escalated, never reconciled silently.** Two things produce one, and they need
opposite responses:

| | |
|---|---|
| The spec is wrong | Building revealed something the design missed. **The spec changes** — and a human decides that |
| The build is wrong | It drifted. **The build changes** |

An agent that quietly picks one has made a design decision on its own. State the mismatch, say
which you believe it is and why, and wait.

**A diagram that is merely incomplete is still a mismatch.** A node with nothing behind it is
a feature nobody built — the most common shape this catches, and invisible in a diff.

---

## Why one sweep

**Checks 1 to 3 and 6 are the same shape:** notice something about the work in progress, and
say so. Four separate always-on checks would compete for the same attention and share the same
over-firing failure, so they share one threshold and one moment.

**Checks 4 and 5 are gates, not nudges.** They fire on an act — reporting an edit done,
opening the next topic — and they govern your own behaviour rather than proposing anything.
They sit here because the moment each matters is a moment this sweep is already watching.

**Check 6 is the only one with an off switch.** The other five are about the work and hold
everywhere. This one is about Arc, and a repository consuming Arc has no reason to record its
rough edges.

**Check 4 is here because it is the same sweep, not the same shape.** It fires on an act
rather than a pause, and it gates your own report rather than proposing to the human. It sits
with the others because the moment it matters — an edit just landed and is about to be called
done — is a moment this sweep is already looking at.
