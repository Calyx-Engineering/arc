---
name: autonomy-set
user-invocable: false
description: Use when the mode the session is working in is in question — the user says switch to autonomous or back to manual, a handoff or arc-log states a mode, a wave boundary is reached, or an exchange turns from executing work into a conversation. Holds the three states, what each permits, how auto is entered and left, the announcement, and the self-test that ends auto when the session degrades. Not for whether work belongs in the arc; that is arc-intent's.
camp-reports: [mode-entered, mode-left, mode-resumed, self-test-failed]
checks: [mode-located, entry-was-explicit, boundary-named, announced]
skips:
  - boundary-named (leaving auto rather than entering it)
---

# The autonomy switch

> **Manual is the default. Auto is entered explicitly, and never inferred.**

Auto mode has been declared in prose five times and has never run. It failed the same way each
time: the prohibitions are restated every turn and the permission was read once, so the
prohibition won. **The permission now lives beside every prohibition it overrides.**

---

## Read the mode before acting, not from memory

**The mode is state, not something you remember.** It lives in one place:

> `HANDOFF.md` → the **Execution mode** row.

| | |
|---|---|
| **Absent, unreadable, or not saying autonomous** | **Manual.** Never infer |
| **A mid-session change** | Rewrite the row **immediately**, not at the next break. The row is the state |
| **The arc-log disagrees with it** | The arc-log is the plan; the handoff is this session. A disagreement means the handoff is stale — the staleness checks in [`handoff`](../handoff/SKILL.md)'s read path catch it |

**Re-read it when the answer matters** — before a commit, before a push, before opening or
merging a PR. Recalling it is the failure mode, not a shortcut.

---

## Three states

| State | You | |
|---|---|---|
| **Manual** | **Stop at the edit.** Files change; nothing is committed. The tree and the diff are the review surface | The default |
| **Autonomous** | Execute the ordered actions to the named boundary — commit, push, open the PR, merge, delete the branch | Explicit only |
| **Autonomous, suspended** | Auto is still set. **Answer the human. Do not commit, push or merge as a side effect of answering** | Inferred |

**Suspended is not a setting.** It is what auto looks like during a conversation, which is why
the mode row has two values and not three.

---

## The switch is asymmetric

**You may set the mode to manual. You may never set it to autonomous.** Only the user raises it,
by saying so — you write the row on being told, and never on your own reading of the situation.

Dropping to manual is yours: at a named boundary, when the self-test fails, or when the user says
stop. That direction removes authority rather than granting it, so there is nothing to guard.

**The user does not hand-edit `HANDOFF.md`.** The switch is a sentence in chat; writing the row
is your job.

**`hooks/mode-guard` enforces the other half, not this one.** It reads the mode row before every
commit, push, PR and merge, and denies in manual. It cannot tell whether the user asked for a
mode change — it sees a file, not a conversation — so *only the user raises it* is a rule you
keep, not a gate that catches you.

---

## Entering — explicit, every time

| Counts | Does not |
|---|---|
| *"switch to autonomous"*, *"run autonomously"*, *"go auto"* — **said now** | The same words earlier in this session |
| The handoff's mode row, read at session start | The arc-log naming a wave autonomous, with the handoff silent |
| The user approving a plan that states the mode | The work looking well-specified enough not to need approval |

> **A phrase from earlier in the conversation is not an instruction now.**

Scrolling back to find *"run autonomously"* from two hours ago is remembering. That is what
this skill replaces.

**Entering requires a named boundary.** Auto runs *to* something — a wave, an issue count, the
end of an arc. Auto with no stated end is not auto; ask for the boundary.

---

## Leaving, and suspending

### Leaving — auto is off

| | |
|---|---|
| **The named boundary is reached** | Hand back, write the handoff |
| **The user says so** | *"switch back to manual"*, *"stop"*, *"wait"* |
| **The self-test fails** | Below. End auto and hand off — never *try harder* |

### Suspending — auto is still set

**Suspend when the exchange is a conversation rather than the execution of a named action.**
Any one signal is enough:

| | |
|---|---|
| A direct question | *"did you update the spec?"* · *"what is up with this block?"* |
| A correction, or a challenge to what was just done | |
| A request scoped to something other than the next ordered action | *"give me a 60 word summary"* |
| Any turn where the user is deciding and you are not executing | Weighing an approach, choosing between options |

**Resuming needs the user to point back at the work** — *"continue"*, *"next issue"*,
`/handoff-resume`, or naming the issue. **It does not resume because the conversation stopped.**

### What is not a conversation

**Executing a named ordered action is the work, not an exchange.** Do not suspend on:

| | |
|---|---|
| A tool result, a test failure, a merge conflict | The work talking back, not the user |
| A decision the plan already made | Re-asking it is the approval-seeking auto exists to remove |
| Your own uncertainty | Suspension is a signal from the user, not a feeling. This is the same trap `work-watch` names for defensive committing |

**If nothing in the exchange came from the user, you are not suspended.**

---

## Announce every transition, in one line

| Transition | |
|---|---|
| Manual → autonomous | **Yes**, and name the boundary |
| Autonomous → manual | **Yes**, and say why — boundary, asked, or self-test |
| Autonomous → suspended | **No.** Answering the question is the signal; a line on every question is noise |
| Suspended → autonomous | **Yes.** The user is handing control back and needs to see it landed |

```text
**Camp here —** autonomous, to the end of wave 6.
  Commits, pushes, PRs and merges without asking. Say "manual" to stop.
```

Format is [`camp-reports.md`](../../docs/product-architecture/camp-reports.md). Every
transition reaches the event log regardless of verbosity.

---

## The self-test

**Auto ends at a boundary. It must also end when the session degrades before reaching one.**

> **Never self-assessment.** *"Am I still doing fine?"* is the question a degraded session
> answers wrong. Every check has an answer outside the session.

| Check | Verified against |
|---|---|
| Name the current issue, branch and next ordered action **without re-reading** — then read and compare | `HANDOFF.md` · `git branch --show-current` |
| The last completion claim survives a `grep` of the file it claims to have changed | The file |
| Nothing uncommitted that was reported committed | `git status --short` |
| The last PR opened actually bound its issue | `gh pr view --json closingIssuesReferences` |

**Run it** at every wave boundary, before writing a handoff, and on any degradation signal — a
denied command, a contradicted claim, a correction from the user.

**A failure ends auto and writes the handoff.** No retry, and no asking whether to continue:
the session that would judge that is the one that just failed.

---

## What auto does not change

> **The harness decides what is permitted. This skill decides what you attempt.**

Merging is outward-facing and hard to reverse, so the harness may refuse it whatever the mode
says. **A markdown file is not authorization, and neither is this skill.** A permission
allow-list in `.claude/settings.json` is necessary and not sufficient — it has been in place
through denials.

| On a denial | |
|---|---|
| **Name the gate, not the symptom** | Below. *"The merge was denied"* sends the next session to re-derive what three sessions already established |
| **Retry at most once**, then hand it over and say exactly what was tried | |
| **Record it** | The PR body, the dev-log, and the friction log where the repo keeps one |
| **Never diagnose it from one session** | Two of three past diagnoses were wrong, each committed to several documents before one `grep` disproved it |
| **It is not the mode failing** | The mode governs the attempt. Conflating the two is what every previous attempt was built on |

### Which gate stopped it — say which, in the report

**Three separate mechanisms can refuse the same command, and only one of them is ever the
cause.** Check them in this order and name the one that applies.

| Gate | How to tell | If it is this one |
|---|---|---|
| **The permission allow-list** | `.claude/settings.json` has no matching entry | The command was never granted. Say so; do not widen it yourself |
| **The auto mode classifier** | Granted in `settings.json`, and the refusal says *denied by the Claude Code auto mode classifier* | The action is outward-facing and was not durably authorized in this session. Hand it over |
| **This skill's mode** | The refusal came from you, not the harness — the mode row says manual | Not a denial at all. Say *the mode is manual*, and do not report a permission problem |

**A report that says only *"it was denied"* is the failure.** The evidence for which gate it was
is in the refusal text and in `settings.json`, both available in the same turn.

**Never edit `.claude/settings.json` to widen your own permissions.** An agent that can install
its own switch has no switch. The asymmetry above is the same reasoning applied to the mode row.

---

## This skill is the only place the rule is stated

**Everything else points here.** The repository's `CLAUDE.md` may state the *mode* once — as a
state, with the override in the same sentence — and nothing else restates the prohibition at
all.

| | |
|---|---|
| [`work-watch`](../work-watch/SKILL.md) | Says whether you commit at all is the mode's call, not its own. Its mechanical rules govern *how* a commit is made |
| `templates/handoff.md` | Carries the *state* and defines what suspended means. That is the semantics of the state, not a rule |
| The repository's `CLAUDE.md` | One sentence: the mode, its override, and a pointer here |

`tests/verify-autonomy.sh` enforces it as a census — the prohibition appears only in this file,
and `CLAUDE.md` states the mode exactly once with its override.

**This reverses a deliberate decision.** Until 2026-09-06 the permission was duplicated beside
every prohibition, on the reasoning that a cross-reference is read once and an adjacent clause
every time. That reasoning was right about the problem. It missed that the harness weighs the
aggregate: five prohibitions each carrying an override is still five prohibitions, and each one
is evidence that authorization has not been given. arc stated the rule five times and had four
merges denied; ROADZ states it once and had none across twelve.
[m40 §9](../../docs/product-architecture/mechanisms/m40-autonomy-switch.md) carries the full
reasoning and the evidence; [#138](https://github.com/Calyx-Engineering/arc/issues/138) is the
change.

---

## Related

- [m40](../../docs/product-architecture/mechanisms/m40-autonomy-switch.md) — the specification
- [`handoff`](../handoff/SKILL.md) — holds the mode, and is written by whichever mode you believe you are in
- [`work-watch`](../work-watch/SKILL.md) — check 1's capture points are what auto commits at
- [`camp`](../camp/SKILL.md) — the voice the announcement is spoken in
- [`arc-intent`](../arc-intent/SKILL.md) — whether the work belongs in the arc, which is a different question
