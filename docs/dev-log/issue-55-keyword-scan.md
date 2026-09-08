# Issue #55 — Rejecting a misplaced closing keyword

> Dev-log, not a spec. Started at plan time, finalised as a retrospective at PR time.

**Issue:** [#55](https://github.com/Calyx-Engineering/arc/issues/55)  ·  **PR:** _pending_

## Problem

A PR body carried `Refs #NN` as its intended keyword and a heading reading
`## This does not clo`+`se #NN`. GitHub bound the link anyway — the parser matches keyword
and number and ignores the negation around it. The issue would have auto-closed on merge
with a required item unapplied.

`skills/issue-write` documents this exact trap, with that exact string as its worked
example. The skill was loaded. The verify step ran, returned the defect, and it was
misread as a different problem.

**Everything the design calls for was in place and the defect still shipped.** That is what
makes this a tooling gap rather than an adherence failure: prose that is read and understood
does not stop a misread of the diagnostic, and every diagnostic the skill offered was
written for a link that *failed* to form.

## Decisions & trade-offs

| | |
|---|---|
| **Two checks, not one** | Placement is checkable before the write from the body text alone. Binding is only checkable after, from the API. They catch different halves of the same defect and neither subsumes the other |
| **One script, two subcommands** | `body` and `binding`. One call site for the skill to document, and the `gh` dependency stays inside the subcommand that needs it rather than becoming a precondition for the offline check |
| **Reports, never blocks** | The `verify-hook.sh` declaration-check precedent. A misplaced keyword is caught by a human reading the report; a blocking gate becomes a cost paid while trying to fix something else |
| **Not a hook alone** | Check 1 must run *before* the body is written. A `PostToolUse` hook is too late by definition — the wrong body already exists in the tracker |
| **Escaping is not the fix** | A zero-width space inside the keyword is a workaround for writing *about* the trap, in a document. The rule the check enforces is placement: keyword and number appear once, on the last non-empty line |
| **Fixtures mirror `hook-cases/`** | `tools/tracker-cases/`, same pass/fail directory shape. A second convention for the same job would be gratuitous |

## The five-hit fixture is reconstructed, not recovered

The issue names its own first draft — five keyword hits — as the regression fixture. **That
draft was not preserved anywhere in the repo**; the issue body describes it but does not
quote it. The fixture is therefore built to the described shape, not recovered.

It is a real fixture and it fails check 1 for the right reason. It is not the original text,
and it is recorded here so no later session mistakes it for one.

## Open

- Whether the branch name's `issue-NN` segment binds independently is **still untested**, and
  out of scope here. Isolating it needs one keyword-free PR on a non-arc base

## What the binding check was actually tested against

`binding` has no fixtures — it reads the API, so there is nothing to fake without mocking
`gh`. It was exercised against live PRs instead.

| Case | Tested | Result |
|---|---|---|
| `Refs` intent, non-empty binding | [PR #54](https://github.com/Calyx-Engineering/arc/pull/54) — the original defect | **FAIL**, correctly. #45 is still bound |
| `Closes` intent, non-empty binding | [PR #54](https://github.com/Calyx-Engineering/arc/pull/54) | PASS |
| `Closes` intent, empty binding, arc base | **Not exercised** | Both live PRs bind something. Code inspection only |
| `Closes` intent, empty binding, default base | **Not exercised** | Needs a PR into `main` that binds nothing |

The first row is the case with no prior coverage anywhere, and it is the one that shipped the
defect. It is verified against the real PR rather than a fixture.
