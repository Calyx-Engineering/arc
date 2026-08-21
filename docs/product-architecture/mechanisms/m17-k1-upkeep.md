# Mechanism — K1 Upkeep

**Status:** partial — the artifacts and templates are proven; what changes for guided
hardware work is not decided.
**Home:** Arc — Knowledge.
**Src:** ⚙️ inherited.
**Covers:** m17.

---

## What it is

**The dev-log and arc-log get written, not remembered.** Two committed files carry K1 — the
tier a session reads every time it starts.

| File | Scope | Holds |
|---|---|---|
| `docs/arc-log/arc-<slug>.md` | One arc | Why the arc exists, target architecture, load-bearing decisions, build order, a live status table |
| `docs/dev-log/issue-<N>-<slug>.md`, or `pr-<NN>-<slug>.md` | **One merged unit** — an issue, or a PR that never had one ([m46 §6.1](m46-work-navigation.md#61-merged-work-always-has-a-dev-log)) | Problem · Decisions and trade-offs · Rejected approaches · Retrospective |

**Both are deliberately short.** The dev-log template says it outright: *"Decision log, not
a spec. Keep it short — capture the why, not a blow-by-blow."* That constraint is what makes
them readable every session, and it is what K2 exists to protect — working detail goes
there, not here.

---

## Why it is inherited

Both templates run in TimeScope today and are the reason a cold session there rehydrates in
one read. Thirteen dev-logs exist. ROADZ has the same structure as an empty stub, which is
the evidence that the template alone is not the mechanism — the enforcement is.

**The three-part rule applies exactly:** trigger (plan time and PR time), template (the two
files above), enforcement (a `Stop` hook gating the PR). ROADZ had the template and neither
of the others, and produced nothing.

---

## The two write moments

| Moment | What gets written |
|---|---|
| **Plan time** | The dev-log is created: Problem, and the decisions known so far |
| **Decision points** | Decisions and rejected approaches, as they happen — not narrated per turn |
| **PR time** | The retrospective is filled in, and the arc-log status table moves |

**Not continuous.** TimeScope learned this: *"Continuous per-turn dev-log churn is narration
by another name."* Writing at checkpoints is the mechanism; writing constantly destroys it.

---

## What is not decided

**Guided work has a third body of material.** Hardware generates analysis, measurements and
rejected topologies that fit neither compact file. That is K2, specified in
[hardware-record-structure](m16-hardware-record-structure.md) — but the seam between them is not
settled. The dev-log's retrospective gains a Spawned section pointing down into K2, and
whether that is the only link is open.

**Enforcement form.** TimeScope gates at PR time with a `Stop` hook. Whether Arc ships the
same hook, folds the check into `hooks/tracker-verify`, or makes it a step in the record
skill is undecided.

**Arc-log ownership during an arc.** The status table must move as work lands. Whether that
is the record skill, `agents/camp`, or a hook is open — and it interacts with m21, which
renders the arc's shape into the same file.

**Whether the arc-log template survives contact with hardware.** It is software-shaped:
waves, tracks, PRs. A guided hardware arc has no waves, and its build order is discovered
rather than planned. The sections may need replacing rather than tuning.

---

## Related

- [knowledge-tiers](knowledge-tiers.md) — K1's definition and the loading rule
- [hardware-record-structure](m16-hardware-record-structure.md) — the K2 layer below this
- [handoff-spine](m15-handoff-spine.md) — what a cold session reads, and in what order
- TimeScope `docs/dev-log/TEMPLATE.md` and `docs/arc-log/ARC-TEMPLATE.md` — the sources
