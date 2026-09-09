# Issue #305 — tracker-verify executes text from its own comments

**Issue:** [#305](https://github.com/Calyx-Engineering/arc/issues/305)  ·  **PR:** [#307](https://github.com/Calyx-Engineering/arc/pull/307) — predicted at branch time, confirmed below

## Problem

`hooks/tracker-verify` at the `arc/04-dogfood` tip, since PR #301, executed the backtick spans of its own header comments on an ordinary `git commit -m x` payload: a real commit titled `ran gh issue close 42` in the repository at `cwd`, and `gh -R owner/repo issue close 163` against the live API. Found by #273's run, which reverted two stray commits and exhausted the account's GraphQL hour; the S9 runs' gate suites then exhausted it again at every reset, which is what stopped the orchestrator dispatching anything.

## Intent and north star

| | |
|---|---|
| **What this issue is really for** | A hook's comments are inert, and a gate says so before a merge |
| **North star** | The commit payload above creates nothing and calls nothing; `verify-all.sh` completes |
| **What makes it durable** | The check is structural — odd backtick count outside a comment — so the next mis-pasted escape fails a gate rather than a session |
| **Out of scope** | The extraction rewrite itself (#230) is correct and untouched |

## Cause

The #230 header comment describing `json_string` was written with **real** newline, tab and carriage-return characters where the two-character escapes were meant. Line 59 therefore began with a bare backtick outside any comment. Bash read it as code — the start of a backtick command substitution — and every backtick span in the comments after it alternated in and out of that substitution, so the example commands in the comments ran. `bash -n` passed: the file was valid shell.

Reproduced in a scratch repository with `bash -x`: six executions of comment text, one commit created. After the fix: zero, none, and a clean activation-log entry.

## Decisions

| | |
|---|---|
| **Fix the comment, not the parser** | The code was never wrong. Four lines rewritten with the escapes as text |
| **A structural gate, `tools/verify-hook-source.sh`** | `bash -n` cannot see this. The gate fails any hook or library line outside a comment with an odd backtick count. Selftest: a good file, a stray-backtick file, an unparseable file |
| **A pass case with the payload it was found on** | `git-commit-payload-runs-nothing.json`. The harness cannot assert *no commit was made*; the gate above is the assertion, the case is the record |
| **Not a reload** | The installed plugin carried the pre-#301 hook throughout, so no live session ran the defect. The fixtures did, hundreds of times |

## Evidence

| | |
|---|---|
| Scratch repro, before | commit `ran gh issue close 42` created; 6 comment executions in the trace |
| Scratch repro, after | no commit; 0 executions; entry written |
| `verify-hook-source.sh` | selftest 3/3; every hook passes; the unfixed tip hook fails naming lines 59 and 62 |
| `verify-hook.sh hooks/tracker-verify` | see the PR body |
| `verify-all.sh` | see the PR body, with wall time |

## Soak

Merged unsoaked by construction; the next run's gate suite soaks it. Soak row in the arc-log §10 when one has.
