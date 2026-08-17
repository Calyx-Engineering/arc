# Mechanism — Kickoff + Scope Gate

**Status:** partial — a working precedent exists for software; the guided-hardware kickoff
is described in a reference document but not specced.
**Home:** Arc — Campaign.
**Src:** ⚙️ inherited.
**Covers:** m09.

---

## What it is

**Scope is agreed before a branch exists.** A hard stop at the start of an arc: what is in,
what is out, and what the sequence looks like.

TimeScope enforces this as a literal stop before any branch is created. ROADZ has the same
shape in prose — the
[Interface PCBA revision workflow](../../reference-roadz/ROADZ%20Interface%20PCBA%20Revision%20Workflow.md)
steps 2 and 3: create the milestone, add in-scope issues, **freeze the scope**, then create
the revision branch.

> *"Prevents mid-rev churn and ensures both contributors have a shared understanding of the
> revision's goals."*

Both repos arrived at the same mechanism independently, which is the strongest evidence in
this spec.

---

## The guided flow

The hardware kickoff has parts the software one does not:

| Step | |
|---|---|
| Review all labelled issues | The backlog is the input, not a fresh conversation |
| Create the milestone | `Interface PCBA — Rev X` |
| Add in-scope issues, agree what defers | The negotiation |
| **Freeze** | The gate itself |
| Create the revision branch | Named for the thing being revised |

**Branch naming comes out of this step.** ROADZ names an arc after the product component
being revised — the vocabulary comes from the BOM. TimeScope uses a free slug. This is a
per-repo decision the kickoff has to make and record, because the branch guard reads it.

---

## What is not decided

**Where the frozen scope is written.** The milestone holds the issue list, but "what defers
and why" has no home. The arc-log is the candidate — its *Why this arc exists* section is
close.

**How a scope change is handled after the freeze.** Guided hardware work *generates* issues
as understanding develops ([arc-tree](m21-arc-tree.md)) — so the freeze cannot mean "no new
issues." It means new issues are a visible decision rather than drift. The distinction needs
stating.

**Whether it composes with decomposition (m20).** Both artifacts merge into
`skills/kickoff`, on the reasoning that scope agreement and decomposition happen in one
sitting. That holds for software. Guided work may agree scope up front and decompose
continuously.

**The Lodestar seam.** [Doc 04](../../suite-architecture/04-arc-execution-and-roles.md)
describes kickoff as a three-role ritual where Star represents the user during scope
sign-off. Lodestar does not exist yet, so pass 1's kickoff has a Star-shaped hole. What the
mechanism does in the meantime is open.

---

## Related

- [ROADZ Interface PCBA revision workflow](../../reference-roadz/ROADZ%20Interface%20PCBA%20Revision%20Workflow.md) — the guided flow, steps 1–3
- [doc 04](../../suite-architecture/04-arc-execution-and-roles.md) — the three-role kickoff
- [arc-decomposition](m20-arc-decomposition.md) — the other half of `skills/kickoff`
- [branch-guard](m10-branch-guard.md) — consumes the branch convention this sets
