# Issue #136 — Linking and closing without the default-branch flip

> Dev-log, not a spec. Started at plan time, finalised as a retrospective at PR time.

**Issue:** [#136](https://github.com/Calyx-Engineering/arc/issues/136)  ·  **PR:** opened after this commit

## Problem

[m12](../product-architecture/mechanisms/m12-issue-linking.md) §5 said to retire the
default-branch switch once verification was in place. [#25](https://github.com/Calyx-Engineering/arc/issues/25)
then shipped [m42](../product-architecture/mechanisms/m42-default-branch-flip.md) — *the switch* —
and closed without touching m12, so the two specs each described the other as the thing being
replaced. m12 read `specified` for three weeks with nothing carrying it.

The practical gap underneath the contradiction: this repository has the flip **off**. Trunk
branch `main` is the GitHub default and every work PR targets an arc branch, so `Closes #NN`
binds nothing and the merge closes nothing. Forty-seven of the 102 issues the Dogfood milestone
held on 2026-09-09 are linked to nothing at all — measured, not estimated, by the sweep this
issue added.

## Intent and north star

| | |
|---|---|
| **What this issue is really for** | The two mechanisms are alternatives, and the repository picks one. Recording that so the contradiction is not re-derived a third time |
| **North star** | A run working in a repository with the flip off can link and close its issue with no admin right, and something says so when it did not |
| **What makes it durable** | The click cannot be automated, so the mechanism has to *report and hand over* rather than promise. Both new artifacts are reports |
| **Out of scope** | Removing either mechanism — the issue's first constraint. Also: resolving m12's *"The test that changes the design"* section against m42's flat contradiction of it, which needs a live test and is spawned below rather than guessed at |

## Decisions & trade-offs

| | |
|---|---|
| **The hook reads the issue number off the head branch, not `closingIssuesReferences`** | The references are empty in exactly the case the check exists for. m46 §9's `-issue-<NN>` is what `createLinkedBranch` put in the branch name, and it survives the merge |
| **`merge-close` skips on two bases, not one** | `BASE = DEFAULT` is where the keyword binds and GitHub closes natively; `BASE = TRUNK` is the arc PR, which is `arc-merge-keyword`'s. The flip makes those two different branches, so a trunk-only test — which is what the first draft had, and what pass 1 caught — runs the check on every work PR in a flipped repo and prints *"a closing keyword cannot bind on a base that is not the default branch"* about a base that is the default. #183 and #210's class, a third time |
| **The PR's own `headRefName`, not `head_branch`** | `gh pr merge <NN>` runs from anywhere — an orchestrator merging a run's PR is not standing on that run's branch. `head_branch` stays right for `pr-base`, which is about a PR being created from here, and is the fallback when the field cannot be read |
| **One bounded network call, like `close-link`** | A synchronous PostToolUse hook that hangs hangs the session. `timeout` proven by `--version`, because Windows ships a `timeout.exe` that rejects the syntax and exits 1 |
| **The sweep is one GraphQL search, not an issue list and a call per issue** | An arc's hundred issues would be a hundred round trips, which is the shape nobody runs at a checkpoint. Paginated — Dogfood is 102 issues, past the 50-per-page window, and a sweep that silently stopped at 50 would be the false negative this mechanism is about |
| **The sweep reads both link fields** | `linkedBranches` alone reports every issue past its PR as unlinked, which is most of an arc. #155 read one field at one moment |
| **A count that does not parse is exit 2, never "no link"** | Same distinction `verify-linked-branch.sh` draws. An unreadable read reported as a missing link is the defect wearing the fix's clothes |
| **m12's status is `partial`, not `built`** | §4's four moments are now carried by artifacts; §1–§2's verify-and-repair loop and §3's `createLinkedBranch` call are still instructions to a session. The header names which is which rather than averaging them into one word |
| **The `Closes #NN` line stays on a non-default base** | Recorded intent. It is the only machine-readable statement of what the PR was for, and `tools/verify-issue-boxes.sh` reads it. Leaving it out to avoid implying a link that does not exist loses that and leaves the issue looking orphaned anyway |

## Rejected approaches

| | |
|---|---|
| **Automating the Development-panel link** | No mutation creates or removes a hand-attached link, and `POST /repos/{o}/{r}/issues/{n}/links` 404s with full `repo` scope. Tested in m42 and re-stated here rather than re-tested |
| **Closing the issue from the hook** | It is a PostToolUse report, and a guardrail that silently closes tracker objects is a different kind of artifact. It hands over two commands instead |
| **Marking m12's table row 🔵** | `partial` permits ⚪ or 🔵, and most of m12 — the repair loop, the link at branch creation — is still prose. ⚪ with a status line that names the built rows is the honest pair |

## Spawned

- **Issues:** [#286](https://github.com/Calyx-Engineering/arc/issues/286),
  [#287](https://github.com/Calyx-Engineering/arc/issues/287) — both found by pass 1

**[#286](https://github.com/Calyx-Engineering/arc/issues/286) caps this issue's own check.**
`hooks/tracker-verify` derives the PR number with `grep -oE '(issue|pr) (edit|merge|view)
+#?[0-9]+'`, which needs the digits immediately after the subcommand, and exits 0 without
reaching a single PR check when it finds none. The entry is still written — every check lands as
`(not reached)` — so the record shows the hook fired and says nothing about why it decided
nothing. `gh pr merge --squash --delete-branch`, the form a run merging its own PR from its own
worktree would naturally type, turns every PR check off that way. Pre-existing and shared with
`arc-merge-keyword`; fixing the extraction touches every PR check, which is a different unit.

**A second routing defect, found in pass 2 and folded into
[#286](https://github.com/Calyx-Engineering/arc/issues/286).** The arm selector tests
`*"gh issue"*` before `*"gh pr"*`, so `gh pr merge 200 && gh issue close 10` takes the **issue**
arm with `NUM=200` and scans issue #200's body as the merged PR's. The comment above the
fall-through says that chained form is what "reaching the PR checks it also deserves" is for, so
the file already believes it is covered.

**[#287](https://github.com/Calyx-Engineering/arc/issues/287) is the premise §5 rested on.** m12's
*"The test that changes the design"* concludes *"`Closes #NN` works against a non-default base
branch"* from ROADZ PR #55; m42 opens with *"GitHub ignores a closing keyword unless the PR
targets the repository's default branch"* and quotes GitHub's documentation. They may agree once
read closely — #55 was created *after* the default switch, so its base **was** the default at
parse time, which is m42's rule and not an exception to it — but m12 states the opposite
consequence in bold. §5 is rewritten here; settling the premise needs a live test against a base
that was never the default, which is #287.

## Retrospective

Six boxes; three documents rewritten, two artifacts added to, one gate runner wired. The two
documentation boxes were the issue's stated point — the contradiction between m12 and m42 — and
the four lines of it that mattered were m12's §5
heading, m12's status, m42's `Related` entry, and the skill's *"The fix is m42"* sentence, which
told a session to change a repository's default branch when a keyword did not bind.

The two build boxes are both reports, because neither can act: `merge-close` in
`hooks/tracker-verify` fires on a PR merging into a base that is neither the default branch nor
the trunk — where no keyword can bind — and names the issue that its head branch says it was
for, if that issue is still open. `tools/arc-link-sweep.sh` is m12 §4's fourth row and reads both link fields for
every issue in a milestone. The sweep found 47 of Dogfood's 102 issues linked to nothing, which
is the number the mechanism existed to produce and nobody had.

**What a future reader needs to know:** the sweep asks the weaker question permanently. Promotion
— a PR opening on a linked branch, which converts the branch record into that PR's closing
reference — survives the PR being closed, and no mutation detaches it. So an issue that ever had
a closing PR reads as linked forever, whatever it is linked to. `LINKED` from this tool means
*linked to something*; asking whether the right branch is linked means naming that branch, and
getting a decisive answer means asking before the PR exists.
