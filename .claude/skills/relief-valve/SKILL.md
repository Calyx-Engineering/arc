---
name: relief-valve
description: Use when questioning has run long without producing an artifact — eight turns since the last write, three questions with nothing changed, forty-five minutes with no checklist movement, or any emphasis marker in the user's messages. Offers a way back to the critical point. Runs inside work-watch's sweep, not as its own always-on check.
camp-reports: [depth-flagged, exit-offered]
checks: [turns-since-write, questions-since-write, checklist-stall, emphasis-marker, direction]
skips:
  - checklist-stall (no active issue with a checklist)
---

> **Copy — do not edit.** The source is [`skills/relief-valve/SKILL.md`](../../../skills/relief-valve/SKILL.md),
> which is what the plugin ships. This copy exists only so the skill is live in this repo
> before Arc is installed here. **Edit the source, then re-run `tools/sync-local-skills.sh`.**

# The relief valve

> *"you'll keep asking detail questions and pushing deeper and deeper until i get frustrated
> instead of giving yourself an escape path or relief valve so we can get back to the
> critical point."*

**It is not that the questions are wrong. It is that there is no way out of them.** Each
answer opens two more, and the only exit is the person's patience running out.

**Most critical before a branch or issue exists.** There, the work is untracked — an hour of
structural decisions leaves no artifact at all, and the reasoning dies with the transcript.

---

## Where this runs

**Inside [`work-watch`](../work-watch/SKILL.md)'s single sweep, as its depth check.** Not a
separate always-on process.

`work-watch` watches for depth by judgment. This skill is what that check runs when the
mechanical precondition below trips — the countable version, invoked rather than felt.

---

## The precondition — what makes the check fire

**Mechanical trigger, judged response.** No signal means *too deep* on its own. The
combination fires the check; judgment then decides whether the depth is real.

| Signal | Counted as | Threshold |
|---|---|---|
| Turns since the last commit or file write | Turn count since the last write tool call | **8** |
| Questions asked with no artifact changed | Questions in assistant turns, since the last write | **3** |
| Time in one issue with no checklist movement | Minutes since the active issue's checklist last changed | **45** |
| Emphasis markers in the user's messages | See below | **any** |

> **Two of the first three fire the check. An emphasis marker fires it alone.**

The first three are **cumulative and none is sufficient alone** — a long analysis legitimately
runs many turns without a write.

### Emphasis markers

| Marker | Example |
|---|---|
| Words in all caps | *"YOU HAVENT TOUCHED THE REPO"* |
| Bold or italic on a correction | Emphasis where plain text would do |
| Profanity | Both appear in the record |
| A sharp drop in message length | Terse replies after long ones |

**An emphasis marker is a direct report from the person this mechanism exists to protect**,
which is why one is enough.

**It is also a late signal — by the time it appears, the valve has already failed.** It ships
crude because it produces no false negatives, and a late signal that fires beats an early
signal that does not exist.

### The numbers are provisional

**Every threshold above is an estimate, not a measurement.** They are placed so the mechanism
is buildable and so first use produces evidence to correct them.
[#36](https://github.com/Calyx-Engineering/arc/issues/36) mines this repository, ROADZ and
TimeScope for real instances and works backwards — what was countable *before* the
frustration surfaced.

Tuning belongs in the repository's operating agreement, not in this file.

---

## What it does when it fires

**Ask the direction question first** — run [`arc-intent`](../arc-intent/SKILL.md).

> **Does the work still serve the arc?**

| Answer | Nudge |
|---|---|
| **Agreed · Derived** | **Light** — name the depth, offer a checkpoint |
| **Escalate** | **Strong** — name the drift, offer the way back to the critical point |

```text
[light]   Deep on this. Worth a checkpoint, or keep going?

[strong]  Four questions into naming, and it has left the arc's scope.
          Back out to the decision?
```

**Where a question inventory exists, quote it.** [`spec-interview`](../spec-interview/SKILL.md)
puts one in the issue before the first set, and a nudge that names the remaining count is the
only form that answers *how much longer is this?*

```text
[light]   Three of five sets settled, N and X left — but we are four
          questions into naming. Pick and move, or settle it?
```

**A count with no denominator asks the person to judge depth with no scale.** That is the
failure this skill exists for, reproduced inside its own nudge.

> **A fired precondition always produces a nudge.** Direction sets the strength, never
> whether it speaks — the precondition already established that something is worth
> remarking on.

**The nudge is always a question, and it never blocks.** The valve offers the exit; the
person takes it. Offering the exit is not the same as taking it — do not back out
unilaterally.

The direction question is [`arc-intent`](../arc-intent/SKILL.md) — the intent check, which shares
this precondition rather than carrying its own. **It answers on the three-level ladder, and
this skill maps that answer to the nudge's strength.** Direction never gates the nudge, so an
*escalate* here still produces a question rather than a stop.

---

## Untracked work is what makes depth expensive

Before a branch or issue exists, every answer lives in chat alone — machine-local, lost with
the transcript.

| | With a branch | Without one |
|---|---|---|
| Where the reasoning lands | Commits, issue bodies, specs | Chat only |
| Recoverable later | Yes | Only by mining the transcript, weeks on |
| Cost of over-depth | Time | Time, **and the record** |

**When decisions are landing and nothing can record them, say so and propose tracking it.**
That is the same failure class as the branch guard — work in the wrong place — except here
the wrong place is nowhere.

---

## What this cannot do

> **A skill the agent invokes is self-detection, and failing to notice is the condition being
> detected.**

The mechanical precondition limits how much this matters — the check fires on countable
signals rather than on self-awareness — **but it does not remove it.** An agent deep enough
to stop counting turns is deep enough to skip this skill.

| | Detects depth | Cost |
|---|---|---|
| **This skill** — a mechanical precondition | What the main thread is capable of noticing | Per fire |
| **Deferred** — an observer outside the conversation | Also what it is not | Continuous conversation reading |

The deferred form is better because it is **outside** the stuck conversation:

> *"**Camp here —** I see what you and Claude are doing. We might want to step back."*

That removes the conflict of interest rather than asking the agent to overcome it. Independence
is the expensive property, and it is the one cost Arc cannot currently carry — see
[m43 §4](../../../docs/product-architecture/mechanisms/m43-camp-assistant.md).

**This limitation is stated here, in the shipping artifact, and not only in the spec.** A
limitation recorded only in a document nobody opens at runtime is not a stated limitation.

---

## Related

- [m41](../../../docs/product-architecture/mechanisms/m41-relief-valve.md) — the precondition and its thresholds
- [m43 §3.6](../../../docs/product-architecture/mechanisms/m43-camp-assistant.md) — the behaviour, and why the observer form is deferred
- [`work-watch`](../work-watch/SKILL.md) — the sweep this runs inside
- [`arc-intent`](../arc-intent/SKILL.md) — the intent check, which answers the direction question this fires
- [`spec-interview`](../spec-interview/SKILL.md) — the question inventory that gives a scoping session's depth a denominator
- [#36](https://github.com/Calyx-Engineering/arc/issues/36) — replaces the provisional thresholds with mined evidence
