# Mechanism — The event log

**Status:** partial — implemented and unsoaked. Every registered hook writes an entry on
every exit path, via `hooks/lib/activation-log`
([#166](https://github.com/Calyx-Engineering/arc/issues/166)). The artifact, its independence
from verbosity, its consumers, the entry format and volume control
([#238](https://github.com/Calyx-Engineering/arc/issues/238)) are settled.
Per-arc rotation is specified, performed and gated
([#239](https://github.com/Calyx-Engineering/arc/issues/239)); retention after an arc closes
is open.
**Home:** Arc — Self-improvement.
**Src:** 🔥 observed.
**Covers:** m44.
**Tracked by:** [#37](https://github.com/Calyx-Engineering/arc/issues/37).

---

## Rationale

Arc's artifacts fire without leaving a record. Whether a hook denied an edit, a skill verified
a tracker write, or a check was declared and skipped, the only trace is what surfaced in
conversation — and conversation is transient.

**Verbosity makes this worse rather than better.** [m43](m43-camp-assistant.md) governs how
much of Arc's operation surfaces in chat. At `quiet` nothing surfaces at all. Without a
separate record, turning verbosity down destroys the evidence that Arc ran.

That coupling is the defect: **a display setting must not determine what is retained.**

> The chain that produced this mechanism: artifacts report their firing in conversation →
> verbosity can suppress those reports → suppressed events leave no evidence → therefore
> persist every event independently of what is displayed.

Once persisted, the record answers questions no other artifact can. The `arc-log` records what
was **decided**; the event log records what **occurred**.

---

## Definition

**An append-only record of every Arc artifact firing, written independently of any verbosity
setting.**

```text
.claude/arc/log.md
```

**Plugin-level, not owned by any one mechanism.** It records what *every* artifact did — a
`branch-guard` denial, an `issue-write` verification, a PR report. Filing it under a
consumer's directory would imply an ownership no consumer has.

**The live file is untracked; rotation is what commits an arc's events.** Every hook firing
appends, so a tracked live log leaves every worktree dirty at every moment and one
`git add -u` sweeps thousands of machine-written lines into a review diff
([#273](https://github.com/Calyx-Engineering/arc/issues/273)). The path does not move — every
reader still resolves `.claude/arc/log.md` — and nothing is lost, because the arc-close move
to `docs/arc-log/events/` lands it somewhere git does carry.

| | |
|---|---|
| **Live** | `.claude/arc/log.md` · gitignored · this arc's events, being appended to |
| **Archived** | `docs/arc-log/events/arc-<NN>-<slug>.log.md` · tracked · a closed arc's events, committed by the rotation that moved them |

**A record git does not hold is a record one `rm -rf` ends**, and that is the cost accepted
here: an arc's events are recoverable only from the moment they are rotated. The alternative —
a tracked file rewritten by machine on every tool call — makes every human diff unreadable,
which loses the review the tracking was for.

---

## Consumers

| Consumer | Purpose |
|---|---|
| The retrospective · [m31](m31-self-improvement-loop.md) | What fired, what never fired, what fired excessively |
| **The user, manually** | First weeks of operation |
| [m30](m30-transcript-mining.md) | A structured companion to transcript mining — what ran, beside what was said |

**The second consumer is why it ships before any tooling reads it.** Prior to automated
analysis, a human reading the log is the entire evaluation loop, and the only means of setting
an over-firing threshold on evidence rather than estimate.

**Not a consumer: [m43](m43-camp-assistant.md)'s intent check.** The intent check evaluates
whether proposed work serves the arc's intent — a question about direction, answered against
the `arc-log`'s stated intent. It does not read history to locate past errors. Log-based firing
was considered and rejected.

---

## Requirements

| | |
|---|---|
| **Written regardless of verbosity** | Reducing verbosity loses display, never data |
| **Append-only** | Rewriting history defeats the purpose |
| **Cheap to append** | A log costing a tool call per entry is skipped under load |
| **Readable unaided** | A human reads it before any tooling does; the format is for people |
| **Declared by the artifact** | Matching the `camp-reports:` header that drives reporting, so one declaration serves both |

### Entry content

Timestamp · artifact · event · what was checked · outcome.

**Serialised as plain lines, not a table** — appending a table row means locating the header
first, and an append that must read the file is an append that gets skipped under load. The
authority on the format is [`templates/event-log.md`](../../../templates/event-log.md); it is
not restated here, so the two cannot drift.

**An entry states what was checked, not only what was found** — the same reporting rule
[m43](m43-camp-assistant.md) applies to conversation. A check that passed is evidence the
machinery ran; only recording failures makes a silent artifact indistinguishable from a
working one.

### Volume

**The rate is kept and the entry is what got smaller.** Five hook registrations sit on the
`Bash` matcher — `mode-guard`, `handoff-archive` and `session-index` before the call,
`tracker-verify` and `camp-branch-check` after — so an ordinary Bash tool call appends five
entries. The log rotated out at arc 03's close measured **14,734 entries and 4.43 MB**, and
**11,156 of them (75%)** recorded a hook that returned before any declared check ran. Every
number in this section is measured against that file,
[`docs/arc-log/events/arc-03-camp.log.md`](../../arc-log/events/arc-03-camp.log.md), as
committed.

| Considered | |
|---|---|
| **Sample** | Rejected. Sampling makes a missing entry ordinary, so a hook that stopped firing is indistinguishable from one that was not sampled — the absence m44 exists to fix. It also ends `tools/verify-activation-log.sh` as a gate, which can only assert *one entry per firing* if that is true on every path |
| **Log at a lower rate** | Rejected. The hooks fire at that rate because the tool calls happen at that rate; a hook that logs only sometimes is the sampling case wearing different clothes |
| **Accept the rate, shrink the entry** | **Chosen.** Every firing still writes exactly one entry |

**An entry where no declared check ran, and which reports nothing, carries no `skipped:`
line** — the whole line, not only the part of it the artifact did not write. **2.26 MB of
4.43 MB, 50% of the file.** What that line held on such an entry is two things, and neither
is evidence about the firing:

| | |
|---|---|
| **The unreached list** | The artifact's own `checks:` declaration copied back, every name marked `not reached` — seventeen names for `tracker-verify`, 1.21 MB of that one log |
| **Explicit skip reasons** | `arc_log_skip` calls made on the way out, which on a firing that reached nothing say what the `outcome:` line says: `skipped: index-entry (this session was already indexed) · orphan-sweep (this session was already indexed)` under `outcome: ok — already indexed this session`. 1.05 MB |

**The narrowness is the design, and it is a guard rather than a measurement.** A `denied`,
`failed` or `repaired` entry keeps its `skipped:` line whatever else is true. No entry in that
log was both — a hook that reports something has always reached a check first — so the clause
costs nothing today and is what keeps the compression away from the entries someone reads.

---

## Relationship to the `arc-log`

| | Records | Owner |
|---|---|---|
| Arc-log · [m17](m17-k1-upkeep.md) | What was **decided** — intent, load-bearing decisions, status | K1 upkeep |
| **Event log** | What **occurred** — every artifact firing | This mechanism |

Neither substitutes for the other. Development drift is the gap between them, which is why
both are required for a retrospective to say anything useful.

---

## What is not designed

**Retention after an arc closes.** Per-arc rotation is settled — the log moves to
`docs/arc-log/events/` beside that arc's arc-log. How long it is kept there, and whether it
is ever pruned, is undecided. The move preserves the file until that question has an answer.

---

## Related

- [m43](m43-camp-assistant.md) — the verbosity setting whose suppression this mechanism makes safe
- [m31](m31-self-improvement-loop.md) — the retrospective that reads it
- [m30](m30-transcript-mining.md) — what was said, beside this record of what ran
- [m17](m17-k1-upkeep.md) — the `arc-log`, which records decisions rather than events
- [`hooks/lib/activation-log`](../../../hooks/lib/activation-log) — the library every hook sources to write one
- [`tools/verify-activation-log.sh`](../../../tools/verify-activation-log.sh) — the gate that asserts one entry per firing, on every path
- [`tools/verify-log-rotation.sh`](../../../tools/verify-log-rotation.sh) — the gate that asserts the live log names the arc writing to it
- [#37](https://github.com/Calyx-Engineering/arc/issues/37) — the issue that built the format and the file
- [#166](https://github.com/Calyx-Engineering/arc/issues/166) — the issue that gave it producers
