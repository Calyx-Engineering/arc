# Mechanism — Configuration Management

**Status:** undefined — the software half is solved by convention; the hardware half is
deferred pending an interview.
**Home:** Arc — Workspace guard.
**Src:** 🔥 observed.
**Covers:** m22.

---

## What it would do

**What is in this revision, exactly.** Verified as work lands, not reconstructed afterwards.

| | State |
|---|---|
| **Software** | Solved. Branches, PRs, releases and semver answer it by convention |
| **Hardware** | **Unsolved.** Component versions and BOM state have no revision control |

---

## Why it is Workspace guard

Versioning is checked per commit, at the moment work lands — the guard's scale and trigger.
It is not a planning question about what an arc contains; it is a mechanical check that the
revision record matches what was actually changed.

---

## The gap is wider than "what is in this revision"

A related failure surfaced 2026-08-17, and it is worth recording because it was not
predicted by the original framing.

The client repo names an arc branch after the product component being revised. That vocabulary — the
five-ish component names an arc can belong to — **lives in a Google Sheet BOM, outside
version control.**

So configuration management is not only *"what is in this revision"* but *"what are the
legal names for work."* A branch guard that validates arc names against a convention needs
that vocabulary, and it is currently unavailable to anything automated.

---

## What the interview needs to establish

Named in
[friction-transcript-log §5](../../retrospectives/2026-08-plugin-line/friction-transcript-log.md#5-what-still-needs-the-interview):

| Question | |
|---|---|
| How is BOM state tracked today? | The sheet is the answer; whether it can move is the question |
| What is a hardware revision, exactly? | Schematic, layout, BOM and manufacturing outputs move at different rates |
| When does a component version matter? | Not every part substitution is a revision |
| What does the CM need to see? | The manufacturing package is the real artifact — see the client-repo workflow, steps 6–7 |
| Multi-user and PLM | A cloud PLM and Atlassian change the answer |

---

## Related

- the client repo workflow (private corpus, not in this repository) — steps 6–8, the manufacturing package and its record
- [branch-guard](m10-branch-guard.md) — needs the naming vocabulary this would own
- [friction-transcript-log §5](../../retrospectives/2026-08-plugin-line/friction-transcript-log.md#5-what-still-needs-the-interview) — the gap
