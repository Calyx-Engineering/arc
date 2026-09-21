# Issue #199 — check every issue box is dispositioned before a PR is ready

> Dev-log, not a spec.

**Issue:** [#199](https://github.com/Calyx-Engineering/arc/issues/199)  ·  **PR:** [#251](https://github.com/Calyx-Engineering/arc/pull/251)

## Problem

Nothing mechanically read an issue's `Required` boxes before its PR. It failed in both
directions, and both were caught by hand:

| | |
|---|---|
| [#17](https://github.com/Calyx-Engineering/arc/issues/17) | shipped missing two of five requirements |
| [#194](https://github.com/Calyx-Engineering/arc/issues/194) | reached its PR with twelve unticked boxes that were all actually done |

[#140](https://github.com/Calyx-Engineering/arc/issues/140) put a read-back before the PR and
ruled a script out — *"prose correctness is not mechanically checkable. This is judgement, so it
is not a gate script."* That constraint was written as if the prose and the box count were one
thing. They are not: whether every `- [ ]` is still unticked is a `gh` query and a count.

## Intent and north star

| | |
|---|---|
| **What this issue is really for** | The tracker and the work disagreed silently. A checklist is the only definition of done this arc has, and nothing ever read it back |
| **North star** | At `gh pr ready`, an exit code says whether the record accounts for every box |
| **What it must not become** | A judge of whether the work is right. That is still [#140](https://github.com/Calyx-Engineering/arc/issues/140)'s read-back |
| **Out of scope** | Blocking. Every verifier here reports, and partial completion stays approvable |

## What counts as resolved

Two states, and the second is the one that needed deciding.

| | |
|---|---|
| **Ticked** | `- [x]`. Whether the tick has evidence behind it is the read-back's question, not this one |
| **Named in a closing PR's body, with words of its own** | The box's first eight words appear on an entry that also carries at least three words the box itself does not |

**The reason test is a word count, not a vocabulary.** `— moved to #250` passes and so does
`not done: the API has no such field`; the box pasted back verbatim does not. A keyword list
— *declined*, *moved*, *deferred*, *blocked by* — would have been a fourth vocabulary to keep in
step with three documents, and would have failed on the fifth word somebody reached for.

**The moved-box case needed no rule of its own.** [#140](https://github.com/Calyx-Engineering/arc/issues/140)
allows moving a box this unit cannot meet, and a row naming where it went is a row with words of
its own. It falls out of the same test.

**Matching is on the first eight normalised words.** A box wraps over three lines in the issue
and is quoted in one line in the PR; demanding the tail back would be demanding a transcription
rather than a disposition. Normalisation drops markdown link targets and keeps their text,
because the words are the identity and the URL is not.

**Both numbers are stated where an author reads them** — eight quoted words and three of their
own, in the failure message and in
[`skills/issue-write`](../../skills/issue-write/SKILL.md). Two drafts got this wrong in
different ways. The first enforced the quote and said only *name it in the PR body*, so
`Box 4: not done, the API has no such field` exited 1 and the message told the author to do what
they had already done. The second said *quote the box's opening words* and named neither number,
which is the same defect with a smaller radius: `- A read-back step — moved to #250` is opening
words, and it is four of the eight the check wants. **A rule an author cannot read is a rule
that reports honest work.**

## Which PRs answer for an issue

**`closingIssuesReferences` alone is empty for exactly the PRs this check exists for.** GitHub
parses a closing keyword only on a PR targeting the repository default, and every issue PR inside
an arc targets the arc branch — `hooks/tracker-verify` says so in as many words when it fires.
Measured in this repository and recorded in
[`closing-keywords-and-base-branch.md`](../arc-work/02-foundation/closing-keywords-and-base-branch.md):
PR #7 on `main` linked five issues, PR #20 on `arc/02-foundation` linked none, same session and
same keyword.

**The first draft trusted that field, and would have answered *this PR closes no issue* for
[#17](https://github.com/Calyx-Engineering/arc/issues/17) and
[#194](https://github.com/Calyx-Engineering/arc/issues/194) — the two failures it was built
for — exiting 0 having counted nothing.** Found by pass 1, not by the author.

Three sources now, unioned, and none of them a guess:

| | |
|---|---|
| `closingIssuesReferences` | What GitHub already binds |
| The PR body's own closing keyword | All four reference forms — `#NN`, `GH-NN`, `owner/repo#NN`, the URL. A PR that says `Closes #199` is answerable for #199 whether or not the keyword bound |
| The head branch's `-issue-<NN>` | What `createLinkedBranch` put there |

**On the issue side the last two are applied to the timeline's cross-references**, which is the
only place an unbound arc PR appears on its issue at all. The first needs no test — it is what
produced the bound list. A cross-reference on its own is **not** a claim: any PR may mention an
issue, and one that neither closes it nor heads a branch named for it is rejected, or an
unrelated PR's prose could resolve boxes by accident.

**The branch test is the weaker of the two, and mostly redundant.** [m12](../product-architecture/mechanisms/m12-issue-linking.md)
measured that opening a PR on a `createLinkedBranch` branch **promotes** the branch record into
that PR's closing reference, so such a PR arrives already bound whatever its body says. What the
branch test still covers is a `git checkout -b` branch on a PR that mentions its issue without a
keyword.

## Where it runs, and why not earlier

**`gh pr ready`, not `gh pr create`.** A draft is allowed to be incomplete — that is what a draft
is for, and [`run-instructions.md`](../arc-work/04-dogfood/run-instructions.md) §2 opens every PR
as one so pass 4 can still take commits. Asking at open would fire on every correctly-opened PR
in the arc, which is how a check gets turned off.

`hooks/tracker-verify` already fires on `gh pr create|edit|merge` and `gh issue create|edit|close`
and owns this moment, so it gained the command and shells out to the tool rather than counting
boxes itself. Two copies of a rule is one copy that goes stale, and the question has to stay
answerable by hand — `bash tests/verify-issue-boxes.sh <NN>`.

## What was built

| | |
|---|---|
| `tests/verify-issue-boxes.sh` | The count. Three forms — an issue, `--pr <NN>` for the hook, and `selftest` |
| `hooks/tracker-verify` | Fires on `gh pr ready`; new check `issue-boxes`, new event `pr-ready` |
| `tools/hook-cases/tracker-verify/` | Four new cases — clean, unreadable, no linked issue, undispositioned — plus a truncated payload |
| `tests/verify-all.sh` | The gate runs the selftest, and `--list` says what the live read still needs |
| `close-sequence.md`, `skills/issue-write` | Step 1 gains an exit code once its PR exists, and the two places that restated #140's constraint say which half is judgement. `issue-write` also states the quoting rule an author has to follow |
| `docs/product-architecture/README.md` | The artifact index's `tracker-verify` row named three firing moments where the hook has six. Not a restatement of #140's constraint — an index that had gone stale |

**Exit 2 is never 1.** A read that could not be made and a box nobody accounted for are different
answers, and only one is a defect — the same distinction
[`tests/verify-linked-branch.sh`](../../tests/verify-linked-branch.sh) draws, for the same reason
[#155](https://github.com/Calyx-Engineering/arc/issues/155) exists.

## The fixture backend

`ARC_BOXES_FIXTURES=<dir>` swaps the `gh` reads for files of the same shape, so the selftest runs
the whole script — argument parsing, both entry points, the missing-object paths, the exit codes
— with no network and no live issue. The precedent is `hooks/tracker-verify`'s own `arc_test_*`
keys.

**A selftest calling the decision function directly would have passed with the entry points
broken**, which is the shape of every case here that exits 2. Twenty-seven cases, and each asserts
the message as well as the code: exit 1 is reached by *unticked and unmentioned* and by *quoted
with nothing beside it*, and a code-only selftest passes with the two confused — which would tell
an author to write a reason they already wrote.

## Evidence

```text
$ bash tests/verify-issue-boxes.sh selftest
27 cases, 27 passed, 0 failed

$ bash tools/verify-hook.sh hooks/tracker-verify
60 passed, 0 failed

$ bash tests/verify-activation-log.sh hooks/tracker-verify
191 passed, 0 failed

$ bash tests/verify-all.sh
38 gates, all clean
```

Live, against this repository. The `FAIL` was taken on the first build, before this issue's own
boxes were ticked; everything below it is the finished code. Neither #199 nor #140 carries a
fenced block, so the fence repair does not sit between the two #199 runs.

```text
$ bash tests/verify-issue-boxes.sh 199        # first build, boxes still open
FAIL  #199 — 7 of 7 boxes unticked, 7 of them undispositioned:
        - unticked, and no closing PR names it: "`tests/verify-issue-boxes.sh <issue>` reports every `- [ ]` remaining in the issue body"
        …six more

$ bash tests/verify-issue-boxes.sh 199
PASS  #199 — 7 boxes, all ticked

$ bash tests/verify-issue-boxes.sh 140
PASS  #140 — 9 boxes, all ticked

$ bash tests/verify-issue-boxes.sh 194
PASS  #194 — 13 boxes, all ticked
```

**#194 is the issue that motivated this**, and it reads clean now because its twelve boxes were
ticked by hand after the fact. What the run proves is the read: thirteen boxes found on a live
issue whose PR is long merged.

## Rejected approaches

| | |
|---|---|
| **A keyword list for the reason** | *declined*, *moved*, *deferred*, *blocked by* — four synonyms and a fifth arriving. A word count says the same thing and cannot go stale |
| **Requiring the whole box text quoted** | A box wraps in the issue and not in the PR. It would have demanded a transcription and reported every honest disposition |
| **Checking at `gh pr create`** | Every draft in this arc opens incomplete on purpose. The check would have fired on all of them |
| **Counting boxes inside the hook** | The question has to be answerable by hand too, and a rule kept in two places is kept in one |
| **A local copy of the issue body** | A checklist is edited on GitHub. A stale file is exactly what would let this pass while the tracker still shows open boxes |
| **`closingIssuesReferences` as the only resolution** | Empty on every arc issue PR, which is every PR this check is for. Held for one pass of review before pass 1 caught it |
| **Admitting any cross-referencing PR** | Anything may mention an issue. An unrelated PR's prose would resolve boxes by accident, which is a false clean — the worse direction |
| **Counting boxes with `grep -cE '[ \t]'`** | GNU ERE reads the backslash literally inside a bracket expression, so `[ \t]` is space, backslash and `t` — not tab. The count and the scanner disagreed on a tab-indented box. One scanner now answers both |

## Not done

Nothing in `Required` is outstanding.
