# PR #108 — A no-issue branch carries its PR number

> Decision log, not a spec. **A no-issue PR is a unit of work like any other**
> ([m46 §6.1](../product-architecture/mechanisms/m46-work-navigation.md)), so it gets a
> dev-log under the identifier it does have.

**Issue:** none  ·  **PR:** [#108](https://github.com/Calyx-Engineering/arc/pull/108)

## Problem

Three no-issue branches were created in one session — `arc/03-camp-merge-step-autonomy`,
`arc/03-camp-wave5-close`, `arc/03-camp-spec-related-artifacts`. **None carried a number.**
[m46 §9](../product-architecture/mechanisms/m46-work-navigation.md) requires one and gives the
form; nothing routed anyone to it.

> *"we've talked about naming the branches for a direct pr before. its still failing on you —
> so we have to change the rule because you're not doing it."* — 2026-08-21

## Why it kept failing

| | |
|---|---|
| **The rule lives where the case never looks** | m46 §9 is read when an issue traces to m46. Every one of these was a no-issue PR |
| **Six artifacts declare the issue form; one declares both** | Four hooks pattern-match `-issue-`, `close-sequence.md` restates it, and only m46 §9 names the `pr<NN>` form |
| **The enforcing hook did not know the second form existed** | `camp-branch-check` matched `arc/*-issue-*`, then fell through to *"is an arc branch, not a work branch"* — **a false warning on a correctly named no-issue branch** |
| **The rule was not followable as written** | The PR number is issued when the PR opens. m46 §9 required a number that does not exist at branch time and said nothing about how to get it |

## Decisions & trade-offs

| | |
|---|---|
| **Predict-then-confirm, not rename-always** | Two proposals: rename every branch after the PR opens, or predict the number and correct only on a miss. **Predict-then-confirm** — its failure is visible immediately and cheap, and the happy path needs no API at all |
| **The rename is not usable as a correction** | It was to be the preferred one, on the user's call to test it. **The test disproved it** — see below. *Close, re-branch, re-open* is the only correction |
| **`CLAUDE.md` was rejected as the home** | It was the first proposal and it is wrong — `CLAUDE.md` is repo-specific and this process must be portable. The hook and the skill both ship with the plugin |
| **The `pr` label is mandatory, not decorative** | Issues and PRs share one counter. A bare number names whichever object happens to hold it — the failure m46 §9 already warns about for issue-versus-PR confusion |

## The rename API — tested, and it fails

**The user asked for this to be tested rather than assumed. It was, and the assumption was
wrong.**

[PR #109](https://github.com/Calyx-Engineering/arc/pull/109) was opened as a throwaway for exactly this question, on branch
`arc/03-camp-pr109-rename-probe`. Then:

```sh
gh api repos/Calyx-Engineering/arc/branches/arc%2F03-camp-pr109-rename-probe/rename   -X POST -f new_name='arc/03-camp-pr109-renamed'
# → arc/03-camp-pr109-renamed
```

| Checked after | Result |
|---|---|
| Branch list | Only `arc/03-camp-pr109-renamed` exists |
| [PR #109](https://github.com/Calyx-Engineering/arc/pull/109) state | `OPEN` → **`CLOSED`**, `closedAt` 15:06:36Z |
| [PR #109](https://github.com/Calyx-Engineering/arc/pull/109) head | Still `arc/03-camp-pr109-rename-probe` — a branch that no longer exists |

**A rename behaves like a delete to an open PR**, and GitHub closes a PR whose head branch
disappears. The API is fine on a branch with no PR against it; the combination is what fails.

**This is the argument for predicting the number rather than assigning it afterwards** — there
is no cheap repair once the PR exists. Had the sequencing been rename-always, every no-issue
PR would have been closed on creation.

**A first attempt at this test was abandoned deliberately**: running it before opening
[PR #108](https://github.com/Calyx-Engineering/arc/pull/108) would have consumed number 108, which this branch is named for. The
probe ran afterwards as 109, which cost one burned number and nothing else.

## Rejected approaches

| | |
|---|---|
| **Slug only, number in the PR title and dev-log** | Proposed first, rejected by the user: *"number and pr label required"*. The branch name is the reference that stays visible while the PR is read |
| **Rename after opening, every time** | Uses an unverified API on every branch instead of only on a miss, and has no fallback if the retarget does not happen. **The test then showed it does not retarget at all — it closes the PR**, so this approach would have failed on every single use |

## What this did not fix

- **[PR #100](https://github.com/Calyx-Engineering/arc/pull/100), [PR #104](https://github.com/Calyx-Engineering/arc/pull/104) and [PR #107](https://github.com/Calyx-Engineering/arc/pull/107) have no dev-log**, which
  [m46 §6.1](../product-architecture/mechanisms/m46-work-navigation.md) requires of every
  merged unit. Same cause as the branch names — the rule lives in a spec the no-issue case
  never reads. **Not swept here**; naming it is what §6.1.3 asks for
- The three badly-named branches are already merged and deleted. Renaming history is not worth
  the cost
