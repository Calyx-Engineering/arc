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

The recorded-trunk path was checked separately: a throwaway repo with
`trunk-was-master` in `.git/arc-default-branch-trunk` produces
*"merges to trunk branch `trunk-was-master` with no closing keyword"*.

## Evidence

`bash tools/verify-hook.sh hooks/tracker-verify` — 33 passed, 0 failed, exit 0.
`bash tools/verify-all.sh` — 13 gates, all clean, exit 0.

**The issue's command needs its path.** `bash tools/verify-hook.sh tracker-verify` exits 2 with
`usage:` — the script takes a path, not a hook name. `hooks/tracker-verify` is what was run.
