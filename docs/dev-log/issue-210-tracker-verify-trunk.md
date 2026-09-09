# Issue #210 — tracker-verify misfires while the default branch is flipped

**Issue:** [#210](https://github.com/Calyx-Engineering/arc/issues/210)  ·  **Parent:** [#145](https://github.com/Calyx-Engineering/arc/issues/145) — Fire

Same root cause as [#183](https://github.com/Calyx-Engineering/arc/issues/183), in the rules
#183 did not reach. `hooks/tracker-verify` used `$DEFAULT` in three places and meant three
different things by it.

| Rule | What it means by the default | Correct comparison |
|---|---|---|
| `pr-base` | where an issue PR must **not** be based | the arc branch — fixed in #183 |
| `closing-keyword` | where GitHub will parse a keyword | **`$DEFAULT`** — unchanged, and right |
| arc-PR merge | where the arc itself merges | **the trunk** |

## The trunk is now resolved, not assumed

`tools/arc-default-branch.sh flip` writes the trunk into the git dir before it moves anything,
so the hook reads `<git-common-dir>/arc-default-branch-trunk` first. With no record, a default
that is not arc-shaped **is** the trunk; an arc-shaped one means the flip is on, and `main` is
the same answer `arc-default-branch.sh` itself defaults to. `--git-common-dir`, not `.git`,
because in a worktree `.git` is a file.

## The arc-PR merge rule was wrong in both directions

```sh
if [ "$WANTS_CLOSE" -eq 0 ] && [ -n "$DEFAULT" ] && [ "$BASE" = "$DEFAULT" ]; then
```

While the flip is on, `$DEFAULT` is `arc/04-dogfood`. So the rule:

1. **missed the arc PR** it exists for — that PR targets `main`, which is no longer the default
2. **fired on every issue PR merging into the arc** — where closure correctly defers to the arc PR

Reading `$TRUNK` fixes both with one comparison. The `pr-base` finding also names the trunk when
that is what a PR is wrongly based on, per [m42](../product-architecture/mechanisms/m42-default-branch-flip.md)'s
phrasing rule — "trunk branch `main`", never a bare name.

## Cases

Both were written first and both failed against the tree before the change:

| Case | Expect |
|---|---|
| `pass/pr-merge-into-flipped-default.json` | an issue PR merging into its arc, default flipped onto that arc — silent |
| `report/pr-merge-arc-into-trunk-no-keyword.json` | the arc PR merging into the trunk, default still flipped — reports |
| `report/pr-base-trunk-while-flipped.json` | a wrong base while the flip is on — the finding still names the trunk, which is not the default |

The recorded-trunk path was checked separately: a throwaway repo with
`trunk-was-master` in `.git/arc-default-branch-trunk` produces
*"merges to trunk branch `trunk-was-master` with no closing keyword"*.

## Two gaps this left, named rather than closed

**The recorded-trunk branch of `resolve_trunk` has no case.** Every case runs against a fresh
`git init` fixture with no `arc-default-branch-trunk` file, so all of them fall through to the
heuristic. A fixture repo carrying the record would have to be built in `tools/verify-hook.sh`,
and that file is hard-excluded from autonomous edits. The branch is covered by the manual check
below and by nothing in the gate.

**`arc-default-branch.sh` cannot write the record from a worktree.** `flip` does
`printf '%s\n' "$TRUNK" > .git/arc-default-branch-trunk` — a literal relative `.git`, which in a
linked worktree is a file, so the redirect fails. The script has `set -u` and no `set -e`, so it
flips the default anyway and leaves no record; `restore`'s `rm -f .git/...` is a matching no-op.
Nothing is broken today — `R:/arc/.git/arc-default-branch-trunk` holds `main`, written from the
main worktree — and the hook's heuristic covers the missing record. Recorded in *Findings*
below; out of scope for both issues in this batch.

## Evidence

`bash tools/verify-hook.sh hooks/tracker-verify` — 33 passed, 0 failed, exit 0 at this commit;
37 after the review passes added four cases and rewrote the malformed PR-fixture one.
`bash tests/verify-all.sh` — 13 gates, all clean, exit 0.

**The issue's third box was left unticked at the time.** `bash tools/verify-hook.sh tracker-verify` exits 2
with `usage:` — the script takes a path, not a hook name. The substance is done and the gate
passes on `hooks/tracker-verify`, but ticking a box whose command errors would assert something
the tree contradicts. The reason is recorded in the issue body; correcting the criterion is the
user's call.

**Resolved on [#264](https://github.com/Calyx-Engineering/arc/issues/264)**, which is where the
user made that call. The criterion was the defect. Box 3 now reads
`bash tools/verify-hook.sh hooks/tracker-verify` and is ticked.

## Findings

Moved verbatim from #210's body under [#271](https://github.com/Calyx-Engineering/arc/issues/271).

| | |
|---|---|
| **`arc-default-branch.sh` cannot write the trunk record from a worktree** | `flip` redirects into a literal relative `.git/arc-default-branch-trunk`, and `.git` is a *file* in a linked worktree, so the redirect fails. No `set -e`, so it flips the default anyway and leaves no record. `restore`'s `rm -f` on the same path is a matching no-op. Not currently biting: the record exists, written from the main worktree, and `tracker-verify`'s heuristic covers its absence. Routes to this arc's Fire workstream ([#145](https://github.com/Calyx-Engineering/arc/issues/145)) |
| **`verify-hook.sh`'s kill-switch proof uses a path global to the user** | It creates `$HOME/.claude/HOOKS_OFF`, runs a report case, and deletes it. Anything else invoking a hook in that window is silenced — another gate run, another worktree, or a live session, of which three were running here. Measured on one payload: 0 silent runs in 120 under a private `HOME`, 18 in 120 under the real one. The gate goes intermittently red; the live-session half means every Arc hook on the machine is briefly inert with nothing saying so. `verify-hook.sh` is hard-excluded from autonomous edits. Routes to this arc's Fire workstream ([#145](https://github.com/Calyx-Engineering/arc/issues/145)) |
| **`resolve_trunk`'s recorded-trunk branch has no case** | Every `verify-hook.sh` fixture is a fresh `git init` with no `arc-default-branch-trunk`, so all cases take the heuristic. A fixture carrying the record needs an edit to `tools/verify-hook.sh`, which is hard-excluded from autonomous edits. Checked by hand instead — see the dev-log |
