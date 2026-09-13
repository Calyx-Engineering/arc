# Issue #336 — a commit message closes an issue by prose

> Dev-log, not a spec. Finalised at PR time.

**Issue:** [#336](https://github.com/Calyx-Engineering/arc/issues/336)  ·  **PR:** [#342](https://github.com/Calyx-Engineering/arc/pull/342)

## Problem

A closing keyword in a commit message closes the issue it names once the commit reaches the
default branch, and nothing in `hooks/tracker-verify` read commit messages for one — only `gh
issue`/`gh pr` invocations. Commit `81b5a41` (PR #301) put the word *resolve* and #300's number
in one prose clause of its body; GitHub closed #300 with all four boxes unticked, and the loop
refused to dispatch it two sets later because a checklist item still read undone.

## What was built

`hooks/tracker-verify` gained a `commit-keyword` check, independent of the existing `gh`-arm
dispatch:

- `commit_has_dash_m` answers "is there really a `git commit` invocation carrying `-m`,
  `--message`, or `--message=value` here", off a quote-stripped copy of the command — the same
  copy the existing `gh`-arm reader builds, and for the same reason: a `-m` sitting inside a
  quoted span elsewhere in the command must not count
- `commit_message_text` then reads the message value out of the *original* command, starting
  only after the literal `git commit` token — never the whole raw string — and
  `check_commit_keyword` scrubs every bare closing line (`Closes #NN` alone on its own line) and
  reports whatever the keyword pattern still finds afterward
- `skills/issue-write` states the rule for commit messages: a closing keyword belongs only on a
  bare line, never in prose, and the post-merge read-back — `gh pr view --json
  closingIssuesReferences` and the issue's own state — is what confirms what actually closed,
  never a memory of which line was meant to

Four cases in `tools/hook-cases/tracker-verify/`: the prose form (report), the bare-line form
that passes, and two regression cases for defects pass 1 found (below).

## What the passes found

| | |
|---|---|
| **Pass 1** | The keyword regex had no left word-boundary, so `fix(e[sd])?` matched inside `prefix` and `disclosed` — "the prefix #42 handling helper" would have reported a false positive. The message scan also read the *entire* raw command for `-m`/`--message`, so an unrelated command's own quoted `-m` ahead of a real `git commit -m` in a chain would leak into the reported text. `--message=value` (no space) was never detected at all. Fixed: `\<` word-boundary anchors on the keyword group, the message scan now starts at the literal `git commit` token, and `--message=*` was added to the structural detector. Two regression cases lock these in |
| **Pass 4** | The fix commit's own message read "GitHub closed #300 with all four boxes unticked" — a closing keyword sharing a line with prose, the exact shape this check exists to report. Caught by an outside-reviewer read of the diff, not by the hook itself (PostToolUse fires after the write). The commit was rewritten before merge to say "GitHub closed it…", verified against the hook's own regex, and force-pushed to the unmerged feature branch |

## Evidence

| | |
|---|---|
| `bash tools/verify-hook.sh hooks/tracker-verify` | 136 passed, 0 failed |
| `bash tests/verify-all.sh` | 69 gates, all clean |

## Findings not acted on

| | |
|---|---|
| **`-F <file>` is out of scope** | The message never appears on the command line for that form, so there is nothing here to read. Named explicitly in the issue's constraints |
| **Multiple `-m` paragraphs** | `commit_message_text` reads every `-m`/`--message` after the first `git commit` token and concatenates them, so a keyword in a later paragraph is still caught — not required by the issue, but free from the same loop |
