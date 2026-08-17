# Knowledge tiers — K1 to K4

The single source of truth for the tier ladder. Other artifacts link here; none redefine it.

A tier is **depth of knowledge**, not a folder. It says how detailed the material is, who it
is for, and when it gets read.

| Tier | Depth | Lives in | Loaded |
|---|---|---|---|
| **K1** | Summary, situational, conclusions | `arc-log`, `dev-log` | **Always — current arc and current issue only.** Two files, not the whole history |
| **K2** | Working detail for AI context | `arc-work/`, `scratch/`, the wiki | **Selectively** — K1 points at what is relevant |
| **K3** | Deep, user-facing research | `report/` | Current issue only |
| **K4** | Raw and filtered conversation | Claude transcripts, plus the mining index | **Queried, never loaded** |

---

## The loading rule

**K1 loads for the current arc and issue. Nothing below K1 loads by default.**

Five finished arcs and fifty closed issues are history, not context. A session opens the
arc-log for the arc it is working and the dev-log for the issue it is working — two files.
Older ones are read only when the current work reaches back to them, and at that point they
behave like K2: opened deliberately, because something pointed at them.

K1 is read every session and **names what else matters**. Working on PWM dimming means the
PWM dimming report is opened; the cell-modem report is not, unless the work reaches it.

Loading all of K1 reproduces the exact failure the ladder prevents — a cold start that
saturates on record before it reaches the work.

---

## Where a piece of work goes

| Ask | Answer |
|---|---|
| Does it span the whole arc? | `arc-work/<arc-slug>/` — BOM analysis, pinout unification |
| Is it working-out for one issue? | `scratch/issue-<N>-<slug>/` |
| Does it document a product capability, for other people? | `report/<capability-slug>/` |
| Is it a facet of a capability — EMI, safety, BOM impact? | Inside that capability's folder, as `analysis-<concern>.md` |
| Is it a concern spanning many subjects? | `.claude/index/<concern>.md` — **links only, no findings, no status** |

**The subject is the folder; the concern is a facet of it.** EMI analysis for PWM dimming
lives with PWM dimming, not in an EMI folder. Concern-first structure shatters one feature's
analysis across the tree, which is the wrong shape for someone who thinks in features.

Cross-cutting concerns get a flat index file, never a folder.

---

## What is not a tier

**K3 is not per-issue.** A report documents a *capability*. Several issues may feed one
report; most feed none. Three hundred reports means none get read.

**The index carries no status.** No "verified", no "open", no coverage claims. A user-facing
matrix of what is complete is a traceability matrix, which is Lodestar's job — building a
second one means two systems answering the same question and drifting.

**An index never holds findings.** The moment it does, the same fact exists in two places
and the stale copy is the one a future session trusts.

---

## K4 is machine-local

Transcripts live in `~/.claude/projects/`, outside any repo. Never pushed, never backed up
by git.

- A second machine has entirely different K4. Same repo, different raw history
- A drive failure loses K4 permanently
- **Promoting K4 to K2 is the only path from machine-local reasoning to a durable record**

That is why the mining mechanisms exist. It is not a convenience feature — it keeps
reasoning from dying with the machine.

---

## Graduation

The ladder is working memory. The wiki is long-term memory.

```text
scratch/issue-<N>/notes.md     it matured into a real finding
        ↓
report/<capability>/analysis-<concern>.md     register it
        ↓
.claude/index/<concern>.md     a link is added, content stays put
        ↓
.claude/wiki/<topic>.md     it outlived the arc as a durable product fact
```

Only the first step is a rewrite. Registering in an index is a link. Graduating to the wiki
replaces the ladder entry with a link, **never a copy** — duplication is the failure mode,
and the stale copy always wins.

| At | Do |
|---|---|
| Issue close | Retrospective links to the analyses; promote anything already cross-cutting |
| Arc close | Sweep K2 and K3; promote durable product facts to the wiki |

---

## The three ladders

A bare number is never ambiguous, so the ladders take different letters.

| Ladder | Values | Measures |
|---|---|---|
| **Knowledge tiers** | K1–K4 | Depth of recorded knowledge — *this file* |
| **Delegation tiers** | T0-Inline · T1-Squad · T2-Wave | How work is dispatched to agents |
| **Mechanisms** | m09–m41 | Which capability. An identifier, not a ladder |

Concise usage is the bare token — "that belongs in K2". Descriptive usage pairs it with the
name — "T1-Squad level delegation".
