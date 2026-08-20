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
| **The hooks, registered and verified** | Including the kill switch. A hook that fires wrong in a fresh repo is the expensive failure |
| **The default-branch decision** | [m42](m42-default-branch-flip.md)'s warning put in front of the user at the moment it matters |
| **The mechanism registry's source** | Where this repository looks up the next free number — [lodestar#9](https://github.com/Calyx-Engineering/lodestar/issues/9) is the same gap in another repo |

**A rule that only a skill carries is not onboarded.** A skill fires when something invokes
it; a repository instruction is always loaded. Behaviours that must hold regardless of which
skill is running belong in the second kind — which is why this mechanism exists rather than
each skill carrying its own copy.

---

## 4 What is not designed

**The sequence.** What is asked, in what order, and what is inferred rather than asked.

**Idempotency.** Onboarding a repository that is already partly configured must not overwrite
a tuned agreement or duplicate a rule. Nothing says how it detects that state.

**What writes each artifact.** Camp is the voice; whether Camp, a skill, or a script performs
each write is open.

**Importing from another repository.** [m43 §11](m43-camp-assistant.md) names this — taking an
agreement from a repo where tuning already happened, rather than starting from stock. The
mechanics are undesigned.

**Where a genre-independent rule lives once it is in `CLAUDE.md`.** The three skills keep
their genre-specific versions; what the repository instruction says, and how the two avoid
drifting, is open.

---

## 5 Related

- [m43 §11](m43-camp-assistant.md) — Camp runs onboarding; Camp is the voice, not the owner
- [m42](m42-default-branch-flip.md) — the flip decision onboarding surfaces
- [m46](m46-work-navigation.md) — branch naming, one of the rules needing a carrier
- m39 — mechanism numbering; the registry a fresh repository must be pointed at. No spec yet
- [#73](https://github.com/Calyx-Engineering/arc/issues/73) — states the zero-re-teaching requirement this mechanism answers
- [#79](https://github.com/Calyx-Engineering/arc/issues/79) — naming the skill that authors each record destination, the same "nothing fired" failure shape
