# Case — a merged PR binds a closing keyword added after the merge

**Run it:** `bash tools/verify-tracker-body.sh live-bind <merged-pr> <issue>`

Not a text fixture and not run by `verify-all.sh`. The claim is about what GitHub does, so the
only honest test writes to the API and reads it back. The runner restores the PR body it
changed, and refuses rather than clobber — the PR must be merged, its base must be the
repository's default branch, and its body must carry no closing keyword already.

## The claim

| | |
|---|---|
| **Binds** | A `Closes #NN` line appended to an already-merged PR populates `closingIssuesReferences` |
| **Condition** | The PR's base was the repository's **default branch**. Where it was not, the keyword cannot bind at all and nothing recovers it — [m42](../../../docs/product-architecture/mechanisms/m42-default-branch-flip.md), [#136](https://github.com/Calyx-Engineering/arc/issues/136) |
| **It is a keyword link** | `closingIssuesReferences(userLinkedOnly:true)` stays empty, so it did not come from the UI's Development panel |
| **It does not close the issue** | The merge event that closes an issue has already fired. The link comes back; the closure does not. Close it with `gh issue close` |
| **Removing the keyword unbinds** | Symmetric. Restoring the body clears the reference |
| **The read-back is not instant** | The read immediately after the edit returns an empty array. Poll |

## Runs

| Date | PR | Issue | Result |
|---|---|---|---|
| 2026-09-07 | [#192](https://github.com/Calyx-Engineering/arc/pull/192) | #144 | Bound. The observation [#193](https://github.com/Calyx-Engineering/arc/issues/193) was filed from |
| 2026-09-07 | [#215](https://github.com/Calyx-Engineering/arc/pull/215) | [#225](https://github.com/Calyx-Engineering/arc/issues/225) | Bound, on the second read. Issue stayed **open**. Body restored, reference cleared |

**The second run is why two of the rows above exist.** The first read after the edit returned
`[]` — a single read would have recorded the recovery as failed. And #225 stayed open, so the
one-line framing *"the recovery is two commands"* is wrong: it is three, and the third is
`gh issue close`.
