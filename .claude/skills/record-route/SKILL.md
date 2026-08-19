---
name: record-route
description: Use when writing down anything that outlives the current turn — a decision, a measurement, an analysis, a rejected approach, a finding, a report. Decides which file it belongs in across the K1–K4 ladder, and keeps the arc-log and dev-log current. Invoke at plan time, at a decision point, and at PR time.
---

> **Copy — do not edit.** The source is [`skills/record-route/SKILL.md`](../../../skills/record-route/SKILL.md),
> which is what the plugin ships. This copy exists only so the skill is live in this repo
> before Arc is installed here. **Edit the source, then re-run `tools/sync-local-skills.sh`.**


# Where the record goes

> **The dev-log and arc-log get written, not remembered.** A template alone produces
> nothing — ROADZ had one and it stayed an empty stub for a month. The mechanism is the
> trigger plus the template plus the enforcement, and this skill is the trigger.

Tier definitions are in [knowledge-tiers](../../reference/knowledge-tiers.md). This skill
decides **which file**, and **when to write**.

---

## Routing

Ask in this order. The first yes wins.

| Ask | Goes to |
|---|---|
| Is it *why we chose this*, for one issue? | `docs/dev-log/issue-<N>-<slug>.md` — K1 |
| Is it a decision that constrains **every** issue in the arc? | `docs/arc-log/arc-<slug>.md`, Load-bearing decisions — K1 |
| Is it working-out for one issue — measurements, a failed attempt, datasheet reasoning? | `docs/scratch/issue-<N>-<slug>/<topic>.md` — K2 |
| Does it span the whole arc — BOM, pinout, a budget? | `docs/arc-work/<arc-slug>/<topic>.md` — K2 |
| Does it document a product capability, for other people to read? | `docs/report/<capability-slug>/` — K3 |
| Is it a durable fact about the product, true after this arc ends? | `.claude/wiki/<topic>.md` — K2, permanent |

**When in doubt, scratch.** An unnecessary analysis file costs disk. An unnecessary report
costs the attention of every future reader, and three hundred reports means none get read.

### Two routing traps

**A report is not per-issue.** Its unit is the capability. Several issues can feed one
report; most feed none. `report/issue-01-.../` is the wrong name — what that folder
documents is *PWM dimming as a capability*, and the issue was only the vehicle.

**Scratch is created on demand, not per issue.** Unlike the dev-log, which every issue
gets. An empty scratch folder is worse than none — it implies work that never happened.

---

## When to write

**Not continuously.** Per-turn churn is narration by another name, and it destroys the
compactness that makes these files readable every session.

| Moment | Write |
|---|---|
| **Plan time** | Create the dev-log. Problem, and the decisions known so far |
| **A decision point** | The decision and what was rejected, while the reasoning is live |
| **Something is created** | Add it to the dev-log's Spawned section *then* — a document nothing points at is a document nobody finds |
| **PR time** | Fill in the Retrospective. Move the arc-log status table |
| **Arc close** | Sweep K2 and K3, graduate durable facts to the wiki, regenerate the tree, close the milestone by hand, restore the default branch |

---

## Keeping K1 compact

Both K1 files are deliberately short, and that constraint is the whole point — it is what
makes them readable every session, and it is what K2 exists to protect.

| Rule | |
|---|---|
| **Capture the why, not a blow-by-blow** | The diff already holds what changed |
| **Skip any section that doesn't apply** | An empty heading is noise |
| **The retrospective is an index into depth** | One paragraph, then links down. A reader gets the conclusion in ten seconds and descends only if they need to |
| **Link down, never absorb** | Working detail goes to K2. If a K1 file is growing, something belongs a tier lower |

**The symptom that K1 is failing:** a fresh session reads the arc-log and dev-log and still
does not know where the work stands. Usually that means detail crowded out the conclusion.

---

## Templates

- [dev-log](../../templates/dev-log.md) — one per issue, every issue
- [arc-log](../../templates/arc-log.md) — one per arc

Copy the template rather than writing from memory. Both carry their own rules in the
blockquote at the top, so the constraint travels with the file.

**The arc-log's build order is discovered, not planned.** A guided arc has no waves and no
parallel tracks. If a sequence genuinely is known up front, it is a load-bearing decision —
write it there rather than adding structure the table does not have.

### An arc-log records how the work runs, not only what it produces

**When any part of an arc will run without a human beside it, the arc-log says so before it
starts** — which issues run unattended, where the run stops for review, and what is least
certain about the ones that do.

| Without it | |
|---|---|
| The plan lives in a chat message | It dies with the session that agreed it |
| A later session cannot tell what was meant to be autonomous | So it either over-asks or over-reaches |
| Nothing records *why* a boundary was drawn there | The next arc redraws it from scratch |

**The uncertainty list is the load-bearing half.** Naming what is least specified is what
makes the stopping point defensible rather than arbitrary — and it is the first thing to check
when an autonomous run produces something wrong.

Prompt for this at kickoff, not at PR time. **A human should not have to ask for the execution
plan.**

---

## Verify the write landed

A scripted edit that never landed reports success. After writing, read back the section you
changed. This is the same silent-success class that
[issue-write](../issue-write/SKILL.md) exists for on the tracker side.
