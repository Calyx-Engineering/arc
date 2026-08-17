# Mechanism — Arc Decomposition and Checkpoints

**Status:** partial — checkpoint placement is designed; decomposition for discovered work is
not.
**Home:** Arc — Campaign.
**Src:** 📐 designed.
**Covers:** m20.

---

## What it is

**Work arrives in reviewable chunks, and the human stops at the right moments.** Sequences
issues, and places checkpoints after the riskiest work rather than on an even cadence.

---

## Checkpoints — risk-weighted, not calendar-weighted

The whole value of delegation is the human stepping back, which removes the corrective
signal. **Checkpoint placement is therefore everything.**

> Put checkpoints right after the riskiest and most-ambiguous chunks, not on an even
> cadence. Get this right and 2–3 checkpoints can responsibly replace per-issue human
> testing — but only because traceability coverage is mechanically re-verified at each one.
> — [doc 04](../../suite-architecture/04-arc-execution-and-roles.md#checkpoints--risk-weighted-not-calendar-weighted)

Semantic completeness stays a human judgement. Traceability — no orphans — is the guarantee
that earns the batching.

---

## Two decomposition modes

The autonomy switch (m40) bites hardest here:

| | Autonomous | Guided |
|---|---|---|
| Issue granularity | Many, small, AI-sized | Fewer, checklist-heavy |
| Sequence | Planned up front, partitioned into tracks | **Discovered as the work runs** |
| Parallelism | Disjoint-file waves | Usually serial |

**Guided decomposition is the harder case and the less designed one.** A hardware arc starts
with 3–8 issues and generates more as understanding develops — so "decompose the arc" is not
a single act at kickoff. See [arc-tree](m21-arc-tree.md).

---

## What is not decided

**Whether decomposition is one act or continuous.** Software decomposes at kickoff. Guided
work decomposes continuously, which makes this less a step and more a standing behavior —
and possibly part of `skills/work-watch` rather than `skills/kickoff`.

**What makes a chunk the right size.** TimeScope sizes chunks so one feature loop completes
reliably. Guided hardware has no equivalent unit; the ROADZ rule is one issue per
function or problem, with sub-steps left to the engineer.

**How risk is judged.** "Riskiest and most ambiguous" is the placement rule and it is
unoperationalised. Candidates: irreversibility, cost of being wrong, how much is being
assumed. Related to Star's derive-versus-escalate gate, which uses the same axis.

**Whether checkpoints survive hardware's latency.** Doc 04 assumes a checkpoint is a
conversation. In hardware the meaningful gate can be weeks away — a board arriving. That is
m28's problem too, and it is flagged as an open question in the suite architecture.

---

## Related

- [doc 04](../../suite-architecture/04-arc-execution-and-roles.md) — checkpoint design
- [kickoff-scope-gate](m09-kickoff-scope-gate.md) — the other half of `skills/kickoff`
- [arc-tree](m21-arc-tree.md) — what discovered decomposition produces
- [human-gate](m28-human-gate.md) — the checkpoint's hardware-latency problem
