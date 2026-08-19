---
name: work-watch
description: Use continuously while work is in progress — one sweep that watches for three things and proposes, never acts. Whether the work has reached a point worth committing, whether a design decision just created a test obligation that will be forgotten, and whether questioning has gone deeper than the decision warrants. Run it at natural pauses, not every turn.
---

# Watching the work

Three mechanisms watch work as it proceeds. **One sweep, not three always-on checks
competing for the same attention.**

| Watches for | Proposes | |
|---|---|---|
| The work reached a reviewable point | A commit | m14 |
| A decision implies later physical verification | A test item | m23 |
| Questioning has gone deeper than the decision needs | Backing out to the critical point | m41 |

> **Propose, never act.** All three nudge; the human decides. This is the whole posture, and
> violating it on the first — committing unasked — is the single most repeated correction in
> the record.

---

## When to sweep

At a natural pause: a document reached a readable state, a decision landed, a sub-analysis
finished, a question was answered. **Not every turn.**

Over-firing recreates the annoyance in a new form. The three checks share one threshold and
it is judgment, not a count: *has anything actually changed since the last sweep?* If not,
say nothing.

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

### The trigger is judgment, and says so

Four mechanical triggers were considered and each fails: turn count fires during legitimate
long analysis; "questions without a decision landing" needs a definition of *landed*;
user-invoked puts the load back on the person the mechanism exists to protect.

**So this check is model judgment, and that is a stated limitation rather than a hidden
one.** A judgment check can silently stop working. If a session ends with the person
frustrated at depth, that is the evidence it did — and it belongs in a retrospective.

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

All three are the same shape: notice something about the work in progress, and say so. Three
separate always-on checks would compete for the same attention and share the same
over-firing failure, so they share one threshold and one moment.
