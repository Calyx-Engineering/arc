---
name: autonomy-set
description: Use when the mode the session is working in is in question — the user says switch to autonomous or back to manual, a handoff or arc-log states a mode, a wave boundary is reached, or an exchange turns from executing work into a conversation. Holds the three states, what each permits, how auto is entered and left, the announcement, and the self-test that ends auto when the session degrades. Not for whether work belongs in the arc; that is arc-intent's.
camp-reports: [mode-entered, mode-left, mode-resumed, self-test-failed]
checks: [mode-located, entry-was-explicit, boundary-named, announced]
skips:
  - boundary-named (leaving auto rather than entering it)
---

> **Copy — do not edit.** The source is [`skills/autonomy-set/SKILL.md`](../../../skills/autonomy-set/SKILL.md),
> which is what the plugin ships. This copy exists only so the skill is live in this repo
> before Arc is installed here. **Edit the source, then re-run `tools/sync-local-skills.sh`.**

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
| **The arc-log disagrees with it** | The arc-log is the plan; the handoff is this session. A disagreement means the handoff is stale — `/arc-next`'s checks catch it |

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

**Resuming needs the user to point back at the work** — *"continue"*, *"next issue"*, `/arc-next`,
or naming the issue. **It does not resume because the conversation stopped.**

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

Format is [`camp-reports.md`](../../../docs/product-architecture/camp-reports.md). Every
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
| **Retry at most once**, then hand it over and say exactly what was tried | |
| **Record it** | The PR body, the dev-log, and the friction log where the repo keeps one |
| **Never diagnose it from one session** | Two of three past diagnoses were wrong, each committed to several documents before one `grep` disproved it |
| **It is not the mode failing** | The mode governs the attempt. Conflating the two is what every previous attempt was built on |

**Never edit `.claude/settings.json` to widen your own permissions.** An agent that can install
its own switch has no switch.

---

## The rule appears beside every prohibition it overrides

**Deliberate duplication.** These say *never commit unasked* or *the user merges*, and each
states its auto arm in the same row:

- The repo's `CLAUDE.md`
- [`work-watch`](../work-watch/SKILL.md) — its mechanical rules
- [m14](../../../docs/product-architecture/mechanisms/m14-commit-rhythm.md)
- [`close-sequence.md`](../../../docs/product-architecture/close-sequence.md) steps 8 and 9

A cross-reference is read once; the clause beside the rule is read whenever the rule is, and
that asymmetry is what defeated every earlier attempt. `tools/verify-autonomy.sh` fails when an
artifact states one of these prohibitions with no auto arm.

---

## Related

- [m40](../../../docs/product-architecture/mechanisms/m40-autonomy-switch.md) — the specification
- [`handoff`](../handoff/SKILL.md) — holds the mode, and is written by whichever mode you believe you are in
- [`work-watch`](../work-watch/SKILL.md) — check 1's capture points are what auto commits at
- [`camp`](../camp/SKILL.md) — the voice the announcement is spoken in
- [`arc-intent`](../arc-intent/SKILL.md) — whether the work belongs in the arc, which is a different question
