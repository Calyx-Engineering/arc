# Mechanism — Verification Planning

**Status:** undefined — deferred pending an interview.
**Home:** Arc — Campaign.
**Src:** 📐 designed.
**Covers:** m24.

---

## What it would do

**Requirements get proven, and the matrix moves.** Turns unproven requirements into a
validation milestone, and reports results back to Lodestar so the verification matrix
updates.

The top-down twin of [test-obligation-capture](m23-test-obligation-capture.md): that one accretes
test items from design decisions as they happen; this one starts from what must be proven and
plans a campaign.

**They meet at the milestone.** A board-checkout list built only from requirements misses
everything incidental — the standby current on a PWM node nobody wrote a requirement for. A
list built only from design decisions misses requirements nobody happened to touch.

---

## Why it is deferred

Two dependencies, neither satisfied:

**Lodestar does not exist.** The input is the RVTM — requirement × configuration ×
verification method × status. Nothing produces one today. Both repos surveyed during the
retrospective had two stories each and hand-written test plans as issues.

**The practice has never been observed.** All evidence behind the plan is discovery-phase.
How a verification campaign actually gets planned, run and recorded is one of the named gaps
in [friction-transcript-log §5](../../retrospectives/2026-08-plugin-line/friction-transcript-log.md#5-what-still-needs-the-interview).

---

## What the interview needs to establish

| Question | Why it decides the design |
|---|---|
| How is a campaign planned today? | Whether this automates a practice or invents one |
| Where do results get recorded? | The output has no home yet |
| What triggers it? | No git event corresponds to a board arriving |
| Who runs it — engineer, technician, external lab? | Changes what the artifact produces |
| How does a failure feed back? | A failed verification weeks after merge has no defined path |

---

## Related

- [test-obligation-capture](m23-test-obligation-capture.md) — the bottom-up twin
- [human-gate](m28-human-gate.md) — the gate this plans toward
- [friction-transcript-log §5](../../retrospectives/2026-08-plugin-line/friction-transcript-log.md#5-what-still-needs-the-interview) — the gap
