# Case — a closing keyword on a PR whose base was never the default branch

**Run it by hand — the steps below.** Not a text fixture, not run by `verify-all.sh`, and not
a `verify-tracker-body.sh` mode: the claim is about what GitHub does, and isolating it needs a
base branch that has never been the repository's default, which no existing PR in this
repository can supply. [#287](https://github.com/Calyx-Engineering/arc/issues/287).

## The two claims under test

| Spec | Claim | Predicts |
|---|---|---|
| [m12](../../../docs/product-architecture/mechanisms/m12-issue-linking.md) *The test that changes the design*, **as it read before #287** | The keyword is parsed when the body is written, against whatever the default was at that moment — a parse-time quirk, not a base-branch restriction | `closingIssuesReferences` **non-empty** on any base, so long as the body is (re)saved |
| [m42](../../../docs/product-architecture/mechanisms/m42-default-branch-flip.md) opening | GitHub ignores a closing keyword unless the PR targets the default branch | `closingIssuesReferences` **empty**, before and after the merge, and a re-save does not change it |

**Why the 2026-08-16 data cannot decide it.** A client repo's PR #55 was opened after `widget-board/rev_b`
became the default, so its base *was* the default at parse time — consistent with both claims.
Every PR in this repository into an arc branch has the same problem: `arc/04-dogfood` is the
default today, and whether it was at any given PR's parse time is a history question, not a
measurement.

## The procedure

A base that was **created for this run** has never been the default. Nothing else isolates it.

| | |
|---|---|
| 1 | Open a probe issue. It must be **open** — one assertion is whether the merge closes it |
| 2 | Push a fresh base branch from the arc branch tip: `git push origin <tip>:refs/heads/probe/<NN>-base`. Never make it the default |
| 3 | Push a head one empty commit ahead of it: `git commit-tree <tip>^{tree} -p <tip> -m probe`, then push the result to `refs/heads/probe/<NN>-head` |
| 4 | `gh pr create --base probe/<NN>-base --head probe/<NN>-head`, body ending in `Closes #<probe>` on its own last line |
| 5 | Read `closingIssuesReferences` — poll, one read is a false negative |
| 6 | `gh pr merge --merge`, then read again, polling, and read the probe issue's state |
| 7 | Re-save the body unchanged (`gh pr edit --body-file`) and read again — m12's parse-time claim, as it read before #287, predicts this is what binds it |
| 8 | Delete the probe base branch, close the probe issue by hand if the merge did not |

The default branch is read at steps 4 and 6 (`repository.defaultBranchRef`) so the record shows
what it was while the PR was open.

## Runs

| Date | PR | Base | Default at the time | Issue | Before merge | After merge | After re-save | Issue closed by merge |
|---|---|---|---|---|---|---|---|---|
| 2026-09-11 | [#323](https://github.com/Calyx-Engineering/arc/pull/323) | `probe/287-base` | `arc/04-dogfood` | [#322](https://github.com/Calyx-Engineering/arc/issues/322) | `[]` × 5 polls over 15 s | `[]` × 6 polls over 24 s | `[]` × 6 polls over 24 s | **No** — `OPEN`, closed by hand |

**m42's rule holds and m12's parse-time reading is struck.** The keyword form was the one
`verify-tracker-body.sh` accepts — own last line, `Closes #322` — and the body was confirmed to
still carry it after the re-save. `closingIssuesReferences(userLinkedOnly:true)` was also empty,
so nothing was hand-attached. The same keyword form on a default base binds and closes at the
merge ([m42](../../../docs/product-architecture/mechanisms/m42-default-branch-flip.md),
2026-08-17) and binds after it ([merged-pr-keyword-bind.md](merged-pr-keyword-bind.md)), so
the base is the only variable that changed.

**What this does not measure.** Whether a PR opened on a base that *later* became the default
binds on re-save. m42 measured it negative in this repository on 2026-08-17 — five merged PRs,
a flip, a re-save, still unbound — and that client repo's CLAUDE.md claims the opposite for that
repository. Not re-run here; #323's base was never the default, which is the state this case
isolates.
