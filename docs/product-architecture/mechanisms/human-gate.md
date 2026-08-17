# Mechanism — Human Gate

**Status:** partial — proven where the gate is minutes away; hardware's weeks-long gate is
an open architectural question.
**Home:** Arc — Campaign.
**Src:** ⚙️ inherited.
**Covers:** row 28.

---

## What it is

**The step only a person can do, happens.** Every domain has a verification step no agent
can run. Agents build, self-verify, and return a draft gate packet; a verifier assembles one
packet and leaves the environment staged; the human is handed a one-line mission header in
their own terms.

**One gate per feature-complete state — not per slice.**

| Domain | The gate |
|---|---|
| VS Code extension | F5 — launch the extension host |
| Hardware design | CAD review by a second engineer |
| Hardware, after fabrication | A bench test, weeks later |

---

## The latency problem

This is the mechanism's real open question, and it is flagged in the suite architecture.

TimeScope's gate is minutes away: the agent stages the environment, the human presses F5,
the answer comes back in the same session. The whole design assumes that.

**Hardware has two gates, and the second is weeks out.**

| | At merge | After fabrication |
|---|---|---|
| Software | Tests, CI | *(same event)* |
| Hardware | **Design review** — human judgement | **Verification** — bench, weeks later |

Hardware merges on a design review with everything still unproven. The board is fabricated,
assembled, then tested — and can fail long after the arc closed.

**Consequence:** the second gate has no branch event to bind to. Every enforcement mechanism
that works today hangs off a git moment; this one hangs off physical hardware arriving on a
desk.

---

## Design review is unowned

The first hardware gate — CAD review — has inputs, a human decision, and gates a merge. No
mechanism claims it. The
[ROADZ workflow](../../reference-roadz/ROADZ%20Interface%20PCBA%20Revision%20Workflow.md)
step 5 describes it as practice: request review, review the branch in Altium, feedback via
GitHub threads, iterate until both approve.

That loop is real and running. Whether it is this mechanism, or a mechanism of its own, is
undecided.

---

## What is not decided

**Whether one mechanism covers both gates.** They share a shape — a human must act — and
share nothing else. The design review is synchronous and blocks a merge; the bench test is
asynchronous and happens after the arc closed.

**What the gate packet holds for hardware.** In software: what to run, what to look for, what
was already verified. For a CAD review the reviewer opens Altium and forms their own view,
so the packet may be a summary of what changed and why rather than a checklist.

**How a deferred gate is tracked.** A test that cannot run for weeks is a test obligation
(row 23) — but the gate is not the obligation. Something has to notice the board arrived.

---

## Related

- [test-obligation-capture](test-obligation-capture.md) — captures what the deferred gate will check
- [arc-decomposition](arc-decomposition.md) — places the checkpoints this sits at
- [ROADZ workflow](../../reference-roadz/ROADZ%20Interface%20PCBA%20Revision%20Workflow.md) — steps 5–8, the guided gates
- [suite-architecture](../../suite-architecture/README.md#open-questions) — gate latency as an open question
