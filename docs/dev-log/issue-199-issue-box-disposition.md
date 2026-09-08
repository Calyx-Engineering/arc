# Issue #199 — check every issue box is dispositioned before a PR is ready

> Dev-log, not a spec.

**Issue:** [#199](https://github.com/Calyx-Engineering/arc/issues/199)  ·  **PR:** written in once it opens

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
| **Named in a closing PR's body, with words of its own** | The box's opening words appear on an entry that also carries at least three words the box itself does not |

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

## Where it runs, and why not earlier

**`gh pr ready`, not `gh pr create`.** A draft is allowed to be incomplete — that is what a draft
is for, and [`run-instructions.md`](../arc-work/04-dogfood/run-instructions.md) §2 opens every PR
as one so pass 4 can still take commits. Asking at open would fire on every correctly-opened PR
in the arc, which is how a check gets turned off.

`hooks/tracker-verify` already fires on `gh pr create|edit|merge` and `gh issue create|edit|close`
and owns this moment, so it gained the command and shells out to the tool rather than counting
boxes itself. Two copies of a rule is one copy that goes stale, and the question has to stay
answerable by hand — `bash tools/verify-issue-boxes.sh <NN>`.

## What was built

| | |
|---|---|
| `tools/verify-issue-boxes.sh` | The count. Three forms — an issue, `--pr <NN>` for the hook, and `selftest` |
| `hooks/tracker-verify` | Fires on `gh pr ready`; new check `issue-boxes`, new event `pr-ready` |
| `tools/hook-cases/tracker-verify/` | Four new cases — clean, unreadable, no linked issue, undispositioned — plus a truncated payload |
| `tools/verify-all.sh` | The gate runs the selftest, and `--list` says what the live read still needs |
| `close-sequence.md`, `skills/issue-write` | Step 1's confirmation is now an exit code, and the two documents that restated #140's constraint say which half is judgement |

**Exit 2 is never 1.** A read that could not be made and a box nobody accounted for are different
answers, and only one is a defect — the same distinction
[`tools/verify-linked-branch.sh`](../../tools/verify-linked-branch.sh) draws, for the same reason
[#155](https://github.com/Calyx-Engineering/arc/issues/155) exists.

## The fixture backend

`ARC_BOXES_FIXTURES=<dir>` swaps the `gh` reads for files of the same shape, so the selftest runs
the whole script — argument parsing, both entry points, the missing-object paths, the exit codes
— with no network and no live issue. The precedent is `hooks/tracker-verify`'s own `arc_test_*`
keys.

**A selftest calling the decision function directly would have passed with the entry points
broken**, which is the shape of every case here that exits 2. Seventeen cases, and each asserts
the message as well as the code: exit 1 is reached by *unticked and unmentioned* and by *quoted
with nothing beside it*, and a code-only selftest passes with the two confused — which would tell
an author to write a reason they already wrote.

## Evidence

```text
$ bash tools/verify-issue-boxes.sh selftest
17 cases, 17 passed, 0 failed

$ bash tools/verify-hook.sh hooks/tracker-verify
52 passed, 0 failed

$ bash tools/verify-activation-log.sh hooks/tracker-verify
167 passed, 0 failed

$ bash tools/verify-all.sh
38 gates, all clean
```

Live, against this repository:

```text
$ bash tools/verify-issue-boxes.sh 140
PASS  #140 — 9 boxes, all ticked

$ bash tools/verify-issue-boxes.sh 199        # before the boxes were ticked
FAIL  #199 — 7 of 7 boxes unticked, 7 of them undispositioned
```

## Rejected approaches

| | |
|---|---|
| **A keyword list for the reason** | *declined*, *moved*, *deferred*, *blocked by* — four synonyms and a fifth arriving. A word count says the same thing and cannot go stale |
| **Requiring the whole box text quoted** | A box wraps in the issue and not in the PR. It would have demanded a transcription and reported every honest disposition |
| **Checking at `gh pr create`** | Every draft in this arc opens incomplete on purpose. The check would have fired on all of them |
| **Counting boxes inside the hook** | The question has to be answerable by hand too, and a rule kept in two places is kept in one |
| **A local copy of the issue body** | A checklist is edited on GitHub. A stale file is exactly what would let this pass while the tracker still shows open boxes |

## Not done

Nothing in `Required` is outstanding.
