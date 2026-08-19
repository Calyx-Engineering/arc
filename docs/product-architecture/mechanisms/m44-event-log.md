# Mechanism — The event log

**Status:** partial — the artifact, its independence from verbosity and its consumers are
settled. Entry format, rotation and retention are open.
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

**Not a consumer: [m43](m43-camp-assistant.md)'s obligation 0.** Obligation 0 evaluates
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

**An entry states what was checked, not only what was found** — the same reporting rule
[m43](m43-camp-assistant.md) applies to conversation. A check that passed is evidence the
machinery ran; only recording failures makes a silent artifact indistinguishable from a
working one.

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

**Rotation and retention.** Per-arc rotation is the assumption. Whether logs are kept after an
arc closes, and where they go if so, is undecided.

**Entry format specifics.** The content list above is settled; its serialisation is not.
Whichever form is chosen must stay readable by a human without tooling.

**Volume control.** An artifact firing on every tool call could dominate the file. Whether
that needs sampling, or whether the artifact simply should not log at that rate, is unanswered
until real volume exists.

---

## Related

- [m43](m43-camp-assistant.md) — the verbosity setting whose suppression this mechanism makes safe
- [m31](m31-self-improvement-loop.md) — the retrospective that reads it
- [m30](m30-transcript-mining.md) — what was said, beside this record of what ran
- [m17](m17-k1-upkeep.md) — the `arc-log`, which records decisions rather than events
- [#37](https://github.com/Calyx-Engineering/arc/issues/37) — the issue that builds this
