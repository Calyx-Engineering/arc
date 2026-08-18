# Mechanism — Relief Valve

**Status:** partial — the friction is clear, the trigger is not designed.
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

## The proposed form — a third party, not self-noticing

**2026-08-18.** The design above has the agent noticing its own depth problem, which is the
thing least likely to work: the agent is *in* the hole it needs to notice.

**Camp is structurally better placed.** A delivery-lead personality that reads the record but
is not inside the stuck conversation can say so from outside it:

> *"Camp here — I see what you and Claude are doing. We might want to step back."*

Then help get the work back to the critical point. That is a different mechanism from
self-noticing, and it removes the conflict of interest rather than asking the agent to
overcome it.

**Open:** whether camp is invoked by a trigger the main thread fires, or watches
independently. The first is cheap and inherits the trigger problem below; the second is a
running process, which the architecture otherwise avoids.

---

## What is not designed

**The trigger.** This is the hard part, and it is the same problem named in
[what-the-tools-do §3](../archive/what-the-tools-do.md) — ambient work has no git event to bind to.
Candidates:

| Candidate | Against |
|---|---|
| Turn count without a commit | Fires during legitimate long analysis |
| Questions asked without a decision landing | Needs a definition of "decision landed" |
| Model judgment on conversation shape | Not mechanically checkable, so it can silently stop working |
| User-invoked only — *"back out"* | Puts the load back on the user, which is the friction |

**The threshold.** Over-firing recreates the annoyance in a new form. Commit rhythm has the
same open question and the two should probably answer it together.

**Whether it composes with the design-time evaluator.** Commit rhythm (14) and test
obligation capture (23) both watch work in progress and nudge. This is a third watcher, and
three separate always-on checks is likely wrong.

---

## Related

- [commit-rhythm](m14-commit-rhythm.md) — the same propose-never-act posture, same threshold question
- [`chat-response`](../../../.claude/skills/chat-response/SKILL.md) — governs asking versus deciding; this fires when that guidance is not enough
