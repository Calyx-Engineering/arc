# Closing keywords bind only on a PR into the default branch

**Isolated 2026-08-17**, during arc 02. Previously suspected and recorded as unconfirmed in
The client repo's `issue-writing` skill: *"Observed on one repository, not isolated as a variable."*

It is isolated now.

## The evidence

Two PRs in this repo, identical keyword form — `Closes #NN` alone on the last line of the
body.

| PR | Base | `closingIssuesReferences` |
|---|---|---|
| [#7](https://github.com/Calyx-Engineering/arc/pull/7) | `main` | `[1, 2, 3, 4, 6]` |
| [#20](https://github.com/Calyx-Engineering/arc/pull/20) | `arc/02-foundation` | `[]` |

Same repo, same author, same session, same syntax. The only difference is the base branch.

## What was ruled out

**A re-parse fixes it.** It does not. PR #7 needed a body re-save before its links bound,
which made re-parse look like the general remedy. PR #20 was re-saved with byte-identical
content and stayed empty. Re-save fixes a *stale parse*; it cannot create a link the base
branch forbids.

**Hand-attached links confusing the query.** Checked with the GraphQL form directly rather
than `gh pr view`; both agree.

## Why it matters here

**Every issue PR in this arc reports success and links nothing.** The nested-branch workflow
— issue branches merging into an arc branch, the arc branch merging into `main` — puts every
issue PR on a non-default base by construction.

The issues close when the arc PR into `main` merges, or by hand. Nothing is lost, but the
per-issue Development sidebar stays empty for the life of the arc, and an issue that looks
orphaned is indistinguishable from one that was forgotten.

## Consequence for the product

This is the silent-success class in its purest form: the keyword is correct, the API accepts
it, the PR merges, and the link does not exist.

`hooks/tracker-verify` must check `closingIssuesReferences` after PR open and treat an empty
array as a finding **conditioned on the base branch** — empty on a PR into `main` is a
defect; empty on a PR into an arc branch is expected and should be reported as *deferred to
the arc PR*, not as a failure. A check that cries wolf on every issue PR in an arc gets
turned off.

The arc PR into `main` is where the check must actually bite: it needs a `Closes` line for
**every** issue the arc consumed, and that is the one PR where an empty array is a real bug.

## Related

- [m12](../../product-architecture/mechanisms/m12-issue-linking.md) — the mechanism
- [m13](../../product-architecture/mechanisms/m13-issue-write-back.md) — the evaluation set this joins
- The client repo's `issue-writing` — where the unconfirmed observation was recorded
