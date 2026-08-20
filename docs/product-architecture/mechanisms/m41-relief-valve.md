# Mechanism — Relief Valve

**Status:** specified — the form, the precondition and the response are settled. The
thresholds are provisional estimates, replaced with mined evidence by
[#36](https://github.com/Calyx-Engineering/arc/issues/36).
**Home:** Arc — Workspace guard.
**Src:** 🔥 observed.
**Covers:** m41.

---

## The friction

Observed live, 2026-08-17, during Arc's own product definition.

> *"you'll keep asking detail questions and pushing deeper and deeper until i get
> frustrated instead of giving yourself an escape path or relief valve so we can get back
> to the critical point."*

The session spent roughly an hour on structural questions before an issue or branch
existed. Each question was individually reasonable. Nothing noticed that the depth had
passed what the decision required, and the only thing that stopped it was the user's
patience running out.

> *"we are talking about a milestone that is going to be a total of maybe 4 hours of work.
> and you're expecting me to write and manage an issue with 6 requirements..."*

Same shape earlier the same day: a question about repo structure produced a walk through
untracked history instead of the plain answer.

---

## The defect

**It is not that the questions are wrong. It is that there is no way out of them.**

The agent has no sense of proportion between the depth of enquiry and the size of the
decision, and no move available except asking the next question. Escalating depth is
self-reinforcing: each answer opens two more questions, and the only exit is the user
stopping it.

**Untracked work is what makes it expensive.** Before a repo, issue or branch exists,
every answer lives in chat alone — K4, machine-local, lost with the transcript. An hour of
structural decisions can leave no artifact at all.

| | With a branch | Without one |
|---|---|---|
| Where the reasoning lands | Commits, issue bodies, specs | Chat only |
| Recoverable later | Yes | Only via transcript mining, weeks on |
| Cost of over-depth | Time | Time, and the record |

---

## What it must do

| | |
|---|---|
| **Notice depth** | Several questions deep on one decision, or repeated clarification without the scope changing |
| **Weigh against stakes** | A four-hour milestone does not warrant the questioning a four-week one does |
| **Offer the exit, do not take it** | *"We are three questions into naming. Want me to pick and move, or is this worth settling?"* |
| **Escalate when untracked** | No repo, no issue, no branch, and real decisions being made — say so and propose tracking it |

**Propose, never act.** Same posture as commit rhythm: the agent notices and says so; the
user decides.

---

## Why it belongs to Workspace guard

The guard catches work landing in the wrong place. The branch guard catches an edit on the
wrong branch; this catches work with **no** branch — decisions being made where nothing can
record them.

Both fire continuously, both are mechanical noticing rather than judgment about the work
itself.

---

## Form — a skill now, a third party later

**Settled 2026-08-18 during [m43](m43-camp-assistant.md)'s specification.**

The original design had the agent noticing its own depth problem, which is the least reliable
arrangement available: **the detecting party is inside the condition being detected.**

An observer reading from outside the affected conversation does not have that defect. That
observer is Camp — but independence requires continuously reading the conversation, which is
the one form Arc cannot afford by default. So the valve ships in two stages:

| Stage | Form | Honest limitation |
|---|---|---|
| **Now** | A skill the main thread runs when a mechanical precondition trips | Self-detection wearing a skill's clothes. Catches what the agent is *capable* of noticing |
| **Later** | Camp reading independently | Deferred on cost, not on design |

**A skill still beats bare judgment.** It is a named check with criteria, run at a defined
moment, rather than a standing obligation to be self-aware — converting *"should I have
noticed"* into *"did I run the check"*. It degrades safely: firing produces value, missing
leaves current behaviour unchanged.

---

## The precondition — what makes the check fire

**Mechanical trigger, judged response.** No signal means "too deep" on its own; the
combination fires the check, and judgment then decides whether the depth is real.

### The signals

| Signal | Countable as | Provisional threshold |
|---|---|---|
| Turns since the last commit or file write | Turn count since the last write tool call | **8** |
| Questions asked with no artifact changed | Questions in assistant turns, since the last write | **3** |
| Time in one issue with no checklist movement | Minutes since the active issue's checklist last changed | **45** |
| Emphasis markers in the user's messages | See below | **any** |

**The worked case: eight turns, no artifact written, three questions asked.** That combination
fires the check without any conversational reading.

### Combining them

The first three are **cumulative and none is sufficient alone** — a long analysis legitimately
runs many turns without a write. Two of three at threshold fires the check.

**Emphasis markers fire on their own**, because they are a direct report from the person the
mechanism exists to protect.

| Marker | Example |
|---|---|
| Words in all caps | *"YOU HAVENT TOUCHED THE REPO"* |
| Bold or italic on a correction | Emphasis where plain text would do |
| Profanity | Both appear in the record |
| A sharp drop in message length | Terse replies after long ones |

**Emphasis is a late signal — by the time it appears the valve has already failed.** It
produces no false negatives, which is why it ships crude. A late signal that fires beats an
early signal that does not exist.

### The numbers are provisional

**Every threshold above is an estimate, not a measurement.** They are placed so the mechanism
is buildable and so first use produces evidence to correct them.
[#36](https://github.com/Calyx-Engineering/arc/issues/36) mines this repository, ROADZ and
TimeScope for real instances and works backwards: what was countable *before* the frustration
surfaced.

Tuning is expected in the first weeks of use, and belongs in the repository's operating
agreement rather than in code.

---

## What the check does when it fires

**It always says something.** Direction sets the strength of the nudge, never whether it
speaks — the precondition already established that something is worth remarking on.

| Does the work still serve the arc? | Nudge |
|---|---|
| **Yes** | Light. Note the depth, offer a checkpoint — *"Deep on this. Worth a checkpoint, or keep going?"* |
| **No** | Strong. Name the drift and offer the exit — *"Four questions into naming and it has left the arc's scope. Back out to the decision?"* |

The direction question is [m43](m43-camp-assistant.md)'s intent check, which shares this
precondition rather than carrying its own.

**Propose, never act.** The valve offers the exit; the user takes it.

---

## What is not designed

**The over-firing budget.** This check, [m14](m14-commit-rhythm.md)'s commit rhythm and
[m23](m23-test-obligation.md)'s test capture all watch work in progress. They share one sweep
in `work-watch`, and how often that sweep may speak is unset. First use produces the number.

**Whether the thresholds hold outside this repository.** They were estimated from one
person's sessions in a docs-heavy repo. Hardware work in ROADZ may have a different natural
rhythm, in which case the numbers move to the operating agreement per repo.

---

## Related

- [m14](m14-commit-rhythm.md) — the same propose-never-act posture, and the sweep this check shares
- [m43](m43-camp-assistant.md) — Camp, which shares this precondition and is the deferred third party
- [#36](https://github.com/Calyx-Engineering/arc/issues/36) — replaces the provisional thresholds with mined evidence
- [`chat-response`](../../../.claude/skills/chat-response/SKILL.md) — governs asking versus deciding; this fires when that guidance is not enough
