# Issue #201 — mode-guard misses any command that commits from inside a script

**Issue:** [#201](https://github.com/Calyx-Engineering/arc/issues/201)  ·  **PR:** [#247](https://github.com/Calyx-Engineering/arc/pull/247)

## Problem

`hooks/mode-guard` matched five literal strings in the tool payload. `tools/new-direct-pr.sh`
branches, commits, pushes and opens a PR, and a payload that runs it holds none of them — so in
manual mode the guard never fired. Found running PR #200.

## Intent and north star

| | |
|---|---|
| **What this issue is really for** | The guard reads an *action*, not a spelling of one. A commit that happens one level down is still a commit |
| **North star** | `bash tools/new-direct-pr.sh …` and `bash tools/arc-loop.sh 145` are denied in manual mode, and every way of reading those files is not |
| **What makes it durable** | The knowledge lives in the script, not in the hook. A script says what it does; the hook has no list to fall out of date |
| **Out of scope** | Declaring `tools/arc-default-branch.sh` and `tools/verify-tracker-body.sh`, which also write outward under some subcommands — #201 named two scripts, and both of those need read-only exemptions worked out against `verify-all.sh`, which runs one of them. Recorded in **Spawned**. Also out: a repo-wide sweep for undeclared writers, for the same reason |

## Decisions & trade-offs

**What the guard inspects.** The command string, and the declaration of any script the command
invokes:

```bash
# mode-guard: writes-outward
# mode-guard-read-only: --dry-run --status --report
```

**Two halves that read different things, on purpose.** The literal match keeps scanning the
whole payload — its only failure mode is an extra deny, and the header's argument for that
still holds. The script half reads the `command` field only. It has two failure modes, and
both were reached in review by scanning the payload: `git status` denied for a description
reading *"see bash tools/arc-loop.sh for details"*, and a real dispatch allowed because a
`--dry-run` elsewhere in the payload looked like its own flag.

**A mention is not an invocation.** The command is split at `&` `;` `|` `(` and a backtick,
and each segment is read as a command — leading `VAR=x` assignments and wrapper words stepped
over, then an interpreter and its flags, and only the token in command position counts. That
is what keeps `cat`, `sed -n '1,50p'`, `grep -n "bash tools/arc-loop.sh"` and `bash -n` allowed.
The issue's one constraint is that the guard must not block reads, and reads are the common case.

**Read-only flags are matched per invocation, not per script.** The rest of the segment is that
invocation's argument list, so in `bash tools/arc-loop.sh --dry-run && bash tools/arc-loop.sh 145
--max 1` the second half is gated and the first is not.

**`need_cwd` is lazy.** `field cwd` is a five-process pipeline and this hook is PreToolUse on
Bash. Reading it before the gating decision cost it on every Bash call — measured at +50ms per
call, ~58% on top of the hook. It is read when a script path or a mode row actually needs it.

## Rejected approaches

| | |
|---|---|
| **Scan a script's text for `git commit`** | `tools/verify-activation-log.sh:185` carries that string inside a test payload. A content match would deny a read-only verifier — the exact thing the constraint forbids |
| **A list of gated scripts in the hook** | Puts the knowledge in the file furthest from the change. A script that starts committing does not edit the hook |
| **Regex over the payload for invocation forms** | Two passes of review killed it. It denied `sed -n '1,50p' tools/arc-loop.sh` because a closing quote looked like a command boundary, and it allowed a real dispatch whose *description* mentioned `--dry-run`. Parsing the command field into segments is both narrower and simpler to explain |

## Spawned

- **Issues:** none filed. Recorded on #201 — `tools/arc-default-branch.sh` (`gh api -X PATCH
  repos/… default_branch`) and `tools/verify-tracker-body.sh` (`gh pr edit --body-file` against a
  live PR) write outward and carry no declaration, and there is no sweep that would find the next
  one.

## Retrospective

The fix is ~110 net non-comment lines of hook and twenty new cases; the four review passes are what shaped it. Pass 1
found the read-only exemption matching the whole payload — a dispatch exempted by a sentence
Claude wrote itself — and found quoted reads being denied. Pass 2, reviewing pass 1's fixes,
found the same class again in a new shape: one script named twice, the first invocation's
`--dry-run` exempting the second. Both times the root cause was the same, and the third attempt
removed it rather than patching around it: read the command, split it into commands, and ask
each one what it is. Pass 4, reading it as a reviewer, found the largest one: a payload carries
a newline as `
`, so every line after the first was glued onto its predecessor and never read
as a command — most of the surface this issue set out to close, and invisible until someone
asked what an ordinary Bash call actually looks like.

**What a future reader needs:** the hook's own `WHAT THIS CANNOT DO` block is the honest list —
`cd tools && bash arc-loop.sh`, a path in a variable, `bash -o errexit tools/x.sh`, a description
carrying the quoted word `"command"` ahead of the real field, and the hook-root fallback resolving
against Arc's own copy in a consumer repo. None is closed here.

**Not covered by the cases:** the `$CWD` branch of path resolution. `tools/verify-hook.sh`
builds fixtures holding only `.git` and `HANDOFF.md`, so every case resolves through the
hook-root fallback, and that file is on `CLAUDE.md`'s never-edited-autonomously list.
