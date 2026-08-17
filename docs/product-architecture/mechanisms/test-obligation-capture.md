# Mechanism — Test Obligation Capture

**Status:** specified. Already run by hand throughout ROADZ rev B.
**Home:** Arc — Knowledge.
**Form:** hook + skill. Composes with [`issue-writing`](../../reference-roadz/issue-writing/SKILL.md)
and [commit-rhythm](commit-rhythm.md).

---

## The problem

Design work creates test obligations that cannot be executed yet — the board does not
exist, the bracket is not machined, the firmware is not written. The obligation is
specific at the moment of design and forgotten by the time hardware arrives.

> *"this issue can NOT be blocked by **building hardware** we need to update the design.
> we should probably talk about validation tests, but that is a seperate subject and set
> of issues"* — David, ROADZ

**The design issue must not block on hardware. The test must not be lost.**

---

## What it does

**Evaluates the work in progress and nudges when a test obligation has just been
created** — the same evaluator pattern as [commit-rhythm](commit-rhythm.md), which
watches for a reviewable point and proposes a commit.

| Step | |
|---|---|
| 1 | Notice that a design decision implies later physical verification |
| 2 | Propose the test item, and whether it appends to an existing test issue or warrants a new one |
| 3 | On approval, hand the content to **`issue-writing`** to append or file it |
| 4 | Link back to the originating design issue |

**This is one of the things the design-time evaluator watches for**, alongside commit
timing. Not a separate always-on process — a check in the same sweep.

**Append or spawn is a judgement call.** ROADZ practice leans hard toward append:

> *"i don't want 100 issues for each little one. So please spin up the board checkout
> issue in that milestone and then add checking out this LCPHOTO functionality"*

But a new issue is right when the test is substantial, needs its own procedure, or
belongs to a different subsystem. The mechanism proposes; the user decides.

---

## What ROADZ already establishes

| Behaviour | Evidence |
|---|---|
| A **separate testing milestone**, distinct from design work | *"do we have a basic board checkout (design validation) test issue in the testing milestone?"* |
| Items **accumulate on one issue** rather than spawning many | *"i don't want 100 issues for each little one"* |
| Captured **at design time**, executed weeks later | *"make sure in the test #53 that we check the standby current draw (especially around this PWM setup)"* |
| Some become **milestone-end checklists** | *"spawn an issue from this one for the end of the milestone for a review checklist. add to the checklist to verify the pinout table matches the schematic"* |

**The checklist is a specification, not a reminder:**

> *"My expectation is that we'll also build up enough tests on there that you could ingest
> that to create a test firmware to assist in board checkout to make it faster and
> easier."*

Each line must therefore carry the component, the expected behaviour, and a link to the
design issue that caused it — enough for someone to write firmware from it months later.

---

## Why this is not the RVTM

| | RVTM (Lodestar) | This (Arc) |
|---|---|---|
| Unit | A **requirement** | A **design decision just made** |
| Direction | Top-down from the story set | Bottom-up from the bench |
| Question | *"How will this requirement be proven?"* | *"I just changed this — what do I check when the board arrives?"* |
| Timing | Planned up front | Accretes during design |

**They meet at the milestone.** A board-checkout list built only from the RVTM misses
everything incidental — the standby current on a PWM node nobody wrote a requirement
for.

---

## Open questions

| Question | Notes |
|---|---|
| Which test issue receives an append | Board checkout, review checklist, per-subsystem — needs a routing rule |
| Cross-repo test items | ROADZ firmware tests belong to `roadz_pb_firmware`, the design issue does not |
| Does the testing milestone generate itself | Or is it created by hand at arc kickoff |

---

## Related

- [commit-rhythm](commit-rhythm.md) — same evaluator, same nudge pattern
- [issue-write-back](issue-write-back.md) — same failure class: agreed actions never filed
