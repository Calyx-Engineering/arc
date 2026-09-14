# Issue #234 — The body check rejects a PR that closes several issues

> Dev-log, not a spec. Started at plan time, finalised as a retrospective at PR time.

**Issue:** [#234](https://github.com/Calyx-Engineering/arc/issues/234)  ·  **PR:** batched with [#226](https://github.com/Calyx-Engineering/arc/issues/226), one PR

## Problem

`tests/verify-tracker-body.sh body` allowed exactly one closing keyword, on the last line.
`skills/issue-write` says a PR closing several issues lists them in the body, and every batch
PR this arc's loop produces does. The #87 #135 #193 batch was reported: *"3 closing keywords;
exactly one is allowed, on the last line"*. The rule the check exists for is *no keyword
anywhere but the closing block*; *one keyword* was an over-reading of it.

## Intent and north star

| | |
|---|---|
| **What this issue is really for** | A batch PR passes the body check without weakening the negation trap |
| **North star** | `Closes #a` / `Closes #b` / `Closes #c` as the final three lines passes; `## This does not close #45` above them still fails |
| **Out of scope** | Whether the keywords bind on a non-default base — `binding` and the hook's `merge-close` own that |

## Decisions & trade-offs

| | |
|---|---|
| **The block is read from the bottom up** | Skip trailing blank lines, then collect every line that is a bare keyword-plus-number until the first line that is not. Everything with a line number above the block's top is reported. No block at all means every keyword is above it |
| **A blank line ends the block** | "Consecutive non-empty lines" read strictly. Two keyword lines with a blank between them fail. GitHub would bind both, but a gap is where prose gets inserted next — the shape the check is for |
| **A keyword line is one keyword by construction** | `KEYWORD_LINE_RE` anchors the whole line, so `Closes #1 and closes #2` is not a block line and is reported as outside the block. The old `-o` match count was no longer used and was removed (pass 1) |
| **Two headlines** | *above the closing block* when a block exists, *outside a closing block* when the body does not end in keyword-only lines. The old headline misdescribed a last line carrying two keywords (pass 1) |
| **The rule's prose follows** | `skills/issue-write`'s two statements of *one keyword, on the last line* and `templates/pr.md`'s row now say the closing block. `docs/dev-log/issue-55-keyword-scan.md` states the old rule and stays as written — history is not edited |

## Rejected approaches

| | |
|---|---|
| **Allowing N keywords anywhere in the last N non-empty lines** | Lets `Closes #a` / prose / `Closes #b` through when the prose is the last thing before the block — the gap the strict reading closes |
| **Reading the count from the title** | The title has no number when a PR closes several; the body is the only statement |

## What the run hit

| | |
|---|---|
| **`tests/verify-all.sh` takes over ten minutes here** | Two runs went to the background; the second was waited on with an `until` loop rather than ending the turn |

## Evidence

`bash tests/verify-tracker-body.sh selftest` — 30 passed, 0 failed, exit 0. `bash tests/verify-all.sh` — in the commit body.

## Spawned

None.
