# Case — a merged PR binds a closing keyword added after the merge

**Run it:** `bash tools/verify-tracker-body.sh live-bind <merged-pr> <issue>`

Not a text fixture and not run by `verify-all.sh`. The claim is about what GitHub does, so the
only honest test writes to the API and reads it back.

| The runner | |
|---|---|
| **Refuses rather than clobber** | The PR must be merged, its base must be the repository's default branch, and its body must carry no closing keyword already |
| **The issue must be OPEN** | One of the assertions is that the bind does not close it, so a closed issue fails the run. Use a fresh probe issue, not a previous run's — #225 is closed and `live-bind 215 225` fails today |
| **Checks every read that feeds a write** | An unchecked `gh pr view` that failed would hand the restore an empty file and destroy the body it is protecting — [#87](https://github.com/Calyx-Engineering/arc/issues/87)'s shape |
| **Restores from a trap** | Armed before the write, so an interrupt between the write and the restore still puts the body back |
| **Asserts the restore on the body**, not on the reference | A reference read that has not caught up would otherwise report a failed restore as a pass |
| **Compares normalised text, not bytes** | GitHub normalises a body it is given — line endings, and trailing blank lines. Measured 2026-09-07 on PR #215: the restore landed, the keyword was gone, and `cmp` still failed |

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
| 2026-09-07 | [#215](https://github.com/Calyx-Engineering/arc/pull/215) | [#225](https://github.com/Calyx-Engineering/arc/issues/225) | The finished runner, end to end. Bound, restored, reference cleared. Two assertions failed correctly: #225 was already closed, and the byte-for-byte body comparison — since fixed to compare normalised text |
| 2026-09-07 | [#200](https://github.com/Calyx-Engineering/arc/pull/200) | [#233](https://github.com/Calyx-Engineering/arc/issues/233) | **`bash tools/verify-tracker-body.sh live-bind 200 233` — five assertions, all PASS, exit 0.** The runner in its current form, green end to end |

**The second run is why two of the rows above exist.** The first read after the edit returned
`[]` — a single read would have recorded the recovery as failed. And #225 stayed open, so the
one-line framing *"the recovery is two commands"* is wrong: it is three, and the third is
`gh issue close`.

**The third run found the normalisation.** Running the finished check against PR #215 restored
the body correctly — no keyword, nothing bound — and its own byte-for-byte assertion still
reported a failure. GitHub does not store back exactly what it was handed.

**The fourth run is the discharge.** Everything above was measured by hand or by a runner that
had since changed. The fourth is the current code, run to completion against the live API, exit
0 — which is what makes the claim a test rather than a memory.
