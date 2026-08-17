# Mechanism — Knowledge Tiers (K1–K4)

**Status:** definition. This file is the **single source of truth** for the tier ladder.
Other documents reference it; none redefine it.
**Home:** Arc — Knowledge. Consumed by every mechanism that reads or writes the
record.

---

## The ladder

Tiers are **depth of knowledge**, not folder location. A tier says how detailed the
material is and who it is for.

| Tier | Depth | Files | Loaded |
|---|---|---|---|
| **K1** | High-level summary, situational, conclusions | `arc-log`, `dev-log` | **Always — but only the current arc and current issue.** Two files, not the whole history |
| **K2** | Detailed working knowledge for AI context | `arc-work/`, `scratch/`, the wiki | **Selectively** — K1 points at what is relevant |
| **K3** | Deep, user-facing research and reporting | `report/` | **Current issue only** |
| **K4** | Raw and filtered conversation | Claude transcripts + the mining index | **Queried, never loaded** |

---

## The loading rule

**K1 loads for the current arc and issue only. Nothing below K1 loads by default.**

Five finished arcs and fifty closed issues are **history, not context** — a session
opens the `arc-log` for the arc it is working and the `dev-log` for the issue it is
working. Two files. Older ones are read only when the current work reaches back to them,
and at that point they behave like K2: opened deliberately, because something pointed at
them.

Loading all of K1 would reproduce the exact failure the ladder exists to prevent — a
cold start that saturates on record before it reaches the work.

K1 is read every session and names what else matters. Working on PWM dimming means the
PWM dimming report is opened; the cell-modem PoE report is not, unless the work reaches
it. The same applies to K2 — the arc-log identifies which `scratch/` files are relevant,
rather than loading all of them.

This is what makes the ladder work rather than merely describing where files live. A
single deep file, or an "open everything" rule, saturates a session by itself — the
failure the ladder exists to prevent.

---

## K4 is machine-local

Transcripts live in `~/.claude/projects/`, outside any repo. They are **never pushed and
never backed up by git.**

Consequences worth stating plainly:

- A second machine has entirely different K4. Same repo, different raw history.
- A drive failure loses K4 permanently.
- **Promoting K4 → K2 is therefore the only path from machine-local reasoning to a
  durable record.**

That last point is why the mining mechanisms exist at all. Knowledge mining is not a
convenience feature — it is what keeps reasoning from dying with the machine. See
[transcript-mining](m30-transcript-mining.md).

---

## What is *not* a tier

**Concerns are a second axis.** EMI analysis for PWM dimming lives *with* PWM dimming,
not in an EMI folder. A flat agent index says where to find things across subjects, and
carries no status — otherwise it competes with Lodestar's requirements document.

Concern-first folder structure was considered and rejected: the subject is the folder,
the concern is a facet.

**K3 is not per-issue.** A report documents a *capability*. Several issues may feed one
report; most feed none. Three hundred reports means none get read.

---

## Naming — why K, and the two other ladders

Three numbered ladders exist in this architecture. They are deliberately given different
letters so a bare number is never ambiguous:

| Ladder | Values | Measures |
|---|---|---|
| **Knowledge tiers** | K1–K4 | Depth of recorded knowledge — *this file* |
| **Delegation tiers** | T0-Inline · T1-Squad · T2-Wave | How work is dispatched to agents |
| *(retired)* | R1–R9 | An early responsibility decomposition, no longer used |

Concise usage is the bare token — "that belongs in K2", "doing T1 delegation now".
Descriptive usage pairs it with the name — "T1-Squad level delegation".

---

## Related

- [hardware-record-structure](m16-hardware-record-structure.md) — the folder layout that
  realises K1–K3
- [handoff-spine](m15-handoff-spine.md) — the reading order across the ladder
- [transcript-mining](m30-transcript-mining.md) — promotes K4 → K2
- [session-preservation](m32-session-preservation.md) — keeps K4 findable
