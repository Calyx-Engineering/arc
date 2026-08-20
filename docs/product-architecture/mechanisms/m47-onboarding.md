# Mechanism — Onboarding

**Status:** partial — the need, the trigger and what must survive an install are settled.
The sequence, the idempotency rule and what writes each artifact are undesigned.
**Home:** Arc — Campaign.
**Src:** 🔥 observed, 2026-08-20.
**Covers:** m47.
**Tracked by:** [#80](https://github.com/Calyx-Engineering/arc/issues/80).

---

## 1 The friction

**Arc's behaviours die at the repository boundary.** A rule taught in one repo is absent in
the next, and the cost is paid by re-teaching it from scratch — in conversation, under
deadline, after the behaviour has already gone wrong once.

> *"that means we define that in *this* repo and then in the *very next* repo i have to spend
> 2 hours (like i am **RIGHT NOW** and **ALREADY HAVE 3 TIMES IN THIS REPO**) re-setting the
> behaviour."*

Three behaviours already need a carrier and have none:

| Behaviour | Specified in | Carrier today |
|---|---|---|
| Auto and manual mode, and what ends auto | [#73](https://github.com/Calyx-Engineering/arc/issues/73) | None — named as a portability requirement, unresolved |
| Branch naming with the number | [m46 §9](m46-work-navigation.md#9-branch-naming) | `CLAUDE.md` — hand-written, per repo |
| Lead with the finding and the ask | [`chat-response`](../../../skills/chat-response/SKILL.md) · [`engineering-report`](../../../skills/engineering-report/SKILL.md) | Genre-scoped skills, each covering its own genre and no other |

**The requirement is stated plainly and is not negotiable:**

> **Install Arc in a fresh repository and the behaviour is there. Zero re-teaching.**

---

## 2 What this is not

**Not Camp.** [m43 §11](m43-camp-assistant.md) records that *Camp runs onboarding* — Camp is
the voice that walks the user through it. This mechanism is what onboarding **is**. Camp
speaking for it does not make Camp its owner, the same separation that put the close sequence
outside Camp.

**Not the plugin's installation.** Adding Arc to a marketplace and installing it is a
packaging concern. This begins after Arc is present and the repository is not yet configured.

**Not per-arc setup.** [m09](m09-kickoff-scope-gate.md) opens an arc. This runs once per
repository, before any arc exists.

---

## 3 What it must produce

| | |
|---|---|
| **Behavioural rules that survive the boundary** | Written into the repository's own instructions, so they load without a skill firing |
| **Camp's three documents** | The operating agreement, the register, the verbosity level — [m43](m43-camp-assistant.md) |
| **The hooks' preconditions, checked** | The plugin registers its own hooks through `hooks.json`; onboarding does not install them. What it must confirm is that they can pass — the repo is a git repo, the kill switch is understood, and a hook denying an edit in an unconfigured repo is survivable |
| **The default-branch decision** | [m42](m42-default-branch-flip.md)'s warning put in front of the user at the moment it matters |
| **The mechanism registry's source** | Where this repository looks up the next free number — [lodestar#9](https://github.com/Calyx-Engineering/lodestar/issues/9) is the same gap in another repo |

**A rule that only a skill carries is not onboarded.** A skill fires when something invokes
it; a repository instruction is always loaded. Behaviours that must hold regardless of which
skill is running belong in the second kind — which is why this mechanism exists rather than
each skill carrying its own copy.

---

## 4 The hard problem — two copies of one rule

**A rule written into `CLAUDE.md` also lives in a skill, and the two will drift.** This is the
design problem onboarding has to solve, not a detail of it.

The failure is not hypothetical. `chat-response` and `engineering-report` each state
*lead with the finding* for their own genre; a third copy in `CLAUDE.md` makes three, in three
repositories, updated at different times.

Three shapes, and the choice is undesigned:

| | How it works | Cost |
|---|---|---|
| **Copy** | Onboarding writes the rule's text into `CLAUDE.md` | Drifts the moment the skill is edited. Every repo holds a different vintage |
| **Point** | `CLAUDE.md` names the principle in one line and defers to the skills | Survives edits, but a pointer only helps if something reads it — and the failure being fixed is that nothing fired |
| **Generate** | `CLAUDE.md`'s Arc section is regenerated from the plugin, and marked as generated | No drift, but it owns a region of a file the user also edits, and re-running must not destroy their content |

**Generate is the only one that holds the zero-re-teaching promise without decaying**, and it
is also the one that forces idempotency to be solved. That coupling is why the two are named
together below rather than as separate open questions.

---

## 5 The trigger

**Onboarding cannot wait to be asked for.** A user who does not know Arc has behaviours to
configure will not request the thing that configures them, and the failure is silent — the
repo simply behaves as though Arc were not installed.

| | |
|---|---|
| **Fires on first session in an unconfigured repo** | The detectable state is the absence of Arc's own artifacts, not a flag the user sets |
| **Offers, never performs unasked** | It writes to `CLAUDE.md` and the repository's configuration. The same rule that governs any hook change applies: a mistake must be survivable |
| **Declinable, and the decline is remembered** | Asked once per repo, not once per session. A prompt that returns every session is the friction it exists to remove |

---

## 6 The failure this must not produce

**A half-onboarded repository is worse than an un-onboarded one.** An un-onboarded repo
behaves predictably — Arc's rules are simply absent. A repo where onboarding ran, wrote some
artifacts and stopped, presents rules that partly apply, and the user cannot tell which.

Whatever the sequence turns out to be, it either completes or leaves nothing behind.

---

## 7 What is not designed

**Copy, point, or generate** — [§4](#4-the-hard-problem--two-copies-of-one-rule)'s three
shapes. Everything else here depends on this one, because it decides whether onboarding writes
text or owns a region.

**Idempotency**, which generate forces. Re-running must not overwrite a tuned agreement,
duplicate a rule, or destroy user-authored content in a file Arc shares. How the existing
state is detected is undesigned.

**The sequence.** What is asked, in what order, and what is inferred rather than asked. The
bar is that a user with no Arc knowledge can answer every question.

**What writes each artifact.** Camp is the voice; whether Camp, a skill, or a script performs
each write is open.

**How completion is guaranteed**, given [§6](#6-the-failure-this-must-not-produce). Whether
that is a transaction, a marker written last, or a check that repairs a partial state.

**Importing from another repository.** [m43 §11](m43-camp-assistant.md) names this — taking an
agreement from a repo where tuning already happened, rather than starting from stock. The
mechanics are undesigned.

**Which rules are portable at all.** Three are named in [§1](#1-the-friction). Nobody has
swept the skills for the rest, and a rule that turns out to be repo-specific must not be
onboarded.

---

## 8 Related

- [m43 §11](m43-camp-assistant.md) — Camp runs onboarding; Camp is the voice, not the owner
- [m42](m42-default-branch-flip.md) — the flip decision onboarding surfaces
- [m46](m46-work-navigation.md) — branch naming, one of the rules needing a carrier
- m39 — mechanism numbering; the registry a fresh repository must be pointed at. No spec yet
- [#73](https://github.com/Calyx-Engineering/arc/issues/73) — states the zero-re-teaching requirement this mechanism answers
- [#79](https://github.com/Calyx-Engineering/arc/issues/79) — naming the skill that authors each record destination, the same "nothing fired" failure shape
