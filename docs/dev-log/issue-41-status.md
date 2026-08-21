# Issue #41 — Where the arc stands, and the close sequence

> Decision log, not a spec. Started at plan time, finalised as a retrospective at PR time.

**Issue:** [#41](https://github.com/Calyx-Engineering/arc/issues/41)  ·  **Spec:** [m43 §3.2](../product-architecture/mechanisms/m43-camp-assistant.md)

## Problem

Status is reconstructed by hand every session, and the transition between issues is where a
session's context is lost. This is what a dedicated spine window was being used for — and a
window dies under context pressure, which is the whole reason the spine was inverted into a
document.

The close sequence is the deliverable. **Two different sessions closing two different issues
must produce the same nine steps in the same order**, so the process does not vary with how
much context the session still holds.

## Decisions & trade-offs

| | |
|---|---|
| **A reference document, not a section inside `skills/camp`** | `docs/product-architecture/close-sequence.md`. The nine steps are owned by five different artifacts; putting the list inside Camp would make Camp the authority on `record-route`'s and `issue-write`'s obligations. Same reasoning that put `camp-reports.md` outside Camp in [#45](https://github.com/Calyx-Engineering/arc/issues/45) |
| **Camp names the steps; it performs none of them** | The steps are already owned. Camp's contribution is that the *order is invariant* and that each is confirmed landed before the next is named |
| **Step 6 is verified, never trusted** | `Closes #NN` on a PR into an arc branch reports success and binds nothing — [m42](../product-architecture/mechanisms/m42-default-branch-flip.md). The check is `gh pr view <N> --json closingIssuesReferences`, and an empty array means not closed regardless of what the body says |
| **Camp refuses to call an issue closeable while step 6 is unverified** | An acceptance criterion, and the only one phrased as a refusal. A silently unbound keyword is the failure this whole sequence exists to catch |
| **Status and flow are one artifact, not two** | The intent check cannot evaluate direction without knowing where the work stands, so status is the substrate flow reads. Splitting them duplicates the assembly step |
| **Holds no state of its own** | Assembled per invocation from the arc-log, the dev-log, open issues and the handoff. Any cached status is a second source that drifts from the record — the exact failure the gitignored handoff avoids |
| **A handoff fires at a session break, not at an issue boundary** | Moving to the next issue in the same session reads only the record, because no handoff was written. Firing one anyway produces a file that duplicates live context |

## What this issue does not build

Everything it leans on exists. `skills/handoff` owns writing the handoff, `skills/record-route`
the logs, `skills/issue-write` the PR, `hooks/tracker-verify` the link check, `skills/work-watch`
the commit and the checklist.

**Camp reads and fires; it does not reimplement.** A step here that seemed to need a new
artifact would have meant the work was landing in the wrong place.

## The diagram walk — m43 §3.2

Required before the PR. Every node in the spec's diagram is something this issue delivers.

| Node | Delivered by |
|---|---|
| Current issue looks complete | The trigger — one of the four transition points |
| **Camp** names what closing requires | The close sequence, steps 1–7 named in order |
| **User** approves — Claude opens the PR, user merges | Steps 5 and 8. Camp proposes; the user owns the go-ahead |
| Session ending? | The handoff decision — the one branch in the diagram |
| **Camp** triggers the handoff and confirms it landed | Fires `skills/handoff`, then confirms. Camp never authors it |
| **Camp** names the next issue, branch and dependencies | The starting sequence, step 1 |
| **User** approves — Claude creates the branch | Starting sequence, step 2 |
| **Camp** loads the record — and the handoff, if one was written | Starting sequence, step 3. Two reads, named separately because only one always exists |
| Working in context on the next issue | The crossing completes here, not at the branch |

## Open

- **Nothing here has been executed.** No skill runs in this repo, so every acceptance criterion
  written as runtime behaviour is untested. Same status as the four merged issues before it
