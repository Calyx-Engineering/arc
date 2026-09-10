# Issue #202 — the kill switch is a command, not a file

**Issue:** [#202](https://github.com/Calyx-Engineering/arc/issues/202)  ·  **PR:** not opened

## Problem

Every Arc hook opened with `[ -f "$HOME/.claude/HOOKS_OFF" ] && exit 0`. Four properties, and the last is the one that decided this:

| | |
|---|---|
| Global | One file muted every hook in every repository on the machine |
| Permanent | A forgotten file disabled every guard indefinitely, and silently |
| All-or-nothing | Muting `branch-guard` to get past it also muted `mode-guard` |
| Unusable under stress | An extensionless file, in a hidden folder, created with a verb PowerShell does not have, on a platform where Explorer appends `.txt` |

Observed 2026-09-07 ([PR #200's dev-log](pr-200-run-and-dispatch-fixes.md)): the switch was needed, attempted, and landed at `r:\arc\HOOKS_OFF.txt` — wrong directory, wrong name, no effect, and nothing said so. It is reached for only when something is already broken, which is the worst moment to be given four ways to get it wrong and feedback on none.

The global scope had already cost the gate twice on its own. `tools/verify-hook.sh` proved the switch worked by creating the real `$HOME/.claude/HOOKS_OFF` and deleting it afterwards; with five worktrees sharing one `$HOME`, overlapping runs left it on disk and every hook on the machine went inert. [#160](https://github.com/Calyx-Engineering/arc/issues/160) found it, [#210](https://github.com/Calyx-Engineering/arc/issues/210) measured it — 18 silent runs in 120 under the real `$HOME`, 0 in 120 under a private one.

## What it is now

```bash
bash tools/hooks-off.sh branch-guard 30      # mute one hook here for thirty minutes
bash tools/hooks-off.sh status               # what is muted, and when each lapses
bash tools/hooks-off.sh clear branch-guard   # end it early
```

Two files carry it. `hooks/lib/hooks-off` is the read side, sourced as the first line of code in every hook; `tools/hooks-off.sh` is the write side, typed by a human. The command sources the library rather than recomputing the state path, because a writer and a reader that each work the location out separately eventually disagree — and that failure is silent in the direction that matters, a switch reporting success while muting nothing.

## Decisions and trade-offs

| | |
|---|---|
| **State inside `.git`** | `<git common dir>/arc-hooks-off`. Untracked by construction, so a muted repository can never be committed or pushed to anyone else — no `.gitignore` line to forget. The COMMON directory, so every worktree of one repository shares one switch: five worktrees run on this machine, and the terminal already open is rarely the one that is stuck |
| **Repository from `CLAUDE_PROJECT_DIR`, falling back to `$PWD`** | Claude Code sets it for every hook. The kill switch runs before stdin is read, so the payload's `cwd` is not available to it — this is the only repository identity a hook has at that point |
| **No subprocesses on the common path** | The same requirement `lib/activation-log` records. Five hooks fire on one Bash tool call, and this runs before any of them do anything else. The walk up to `.git` is `[ -d ]`, `[ -f ]`, `read` and parameter expansion; `date` is forked only where the shell has no time builtin AND a state file exists. With nothing muted — almost always — the cost is a handful of stats |
| **It fails towards the guard being ON** | A missing library, an unresolvable repository, an unparseable line: each leaves `arc_hooks_off` returning non-zero and the hook doing its job. The opposite failure is a guardrail that reports success while off |
| **A cap, not just a default** | Thirty minutes by default, 480 at most, and the cap is announced when it bites. Expiry is only a property if nobody can opt out of it |
| **The command validates the hook name** | An unknown name is refused with the real names printed, and nothing is written. This is the 2026-09-07 failure directly: a name that is not a hook used to be accepted in silence |
| **One bash implementation, no PowerShell twin** | `bash tools/hooks-off.sh …` runs verbatim in PowerShell, cmd and bash — `bash` is on PATH from PowerShell here (`C:\Program Files\Git\usr\bin\bash.exe`), and every hook and gate in this repository is already invoked through it. A `.ps1` twin would be a second implementation to keep in step for no reachability gained |
| **`all` is kept** | Per-hook scope is the point, but `all` is the entry a human under pressure actually writes, and refusing it would send them back to editing JSON |

## Two bash traps, both measured

`${d//\\//}` written inline **does not** replace backslashes with slashes — bash parses it as "delete every slash", and the walk up to `.git` then never matches anything. Holding the separators in variables fixes that, and introduces the second trap: an **unquoted** `$bs` in the pattern is read as an escape rather than as a backslash, so `${d//$bs/$fs}` is a no-op. Both were found by tracing, not by reading. The working form is `${d//"$bs"/$fs}` with `local bs='\' fs='/'`, and a comment above it says so.

Windows paths matter here because `CLAUDE_PROJECT_DIR` arrives as Claude Code received it, and `${d%/*}` cannot walk a backslash.

## A defect in the test being replaced

The kill-switch assertion in `tools/verify-hook.sh` recognised only a `deny` decision and `exit 2`. Three of the seven hooks — `camp-session-start`, `camp-branch-check`, `tracker-verify` — speak by returning a `permissionDecisionReason` instead, so for those the failing branch was **unreachable**: the assertion printed `PASS  kill switch suppresses report` whether the switch worked or not. Found by writing the *absent* case, which expects the hook to speak and went red on hooks whose speech the harness could not see.

The new section asserts both shapes, and it opens with an **absent** case for exactly this reason: a suppression test with no unsuppressed control passes against a hook that never speaks at all.

## Where the scope check runs from, and why not `cd`

The first version of the new cases ran each hook from inside a throwaway repository, so `$PWD` resolved the switch. That loses `camp-branch-check` entirely: several of its payloads carry a repo-**relative** `cwd` — `.`, and a path under `tools/hook-cases/` — which only means anything from the repository root. The verifier moved, those cases stopped reporting, and the harness read the silence as a working kill switch. `CLAUDE_PROJECT_DIR` is the lever instead. Either way every entry the gate writes lands inside its own `$FIXTURES`, so a verifier can no longer mute the repository it is running in.

`camp-session-start` and `handoff-archive` act once per session and are silent afterwards. The switch section fires the same case six times, so it clears the fixtures' session markers before each run; without that the whole section reads as "the hook never speaks".

## An edit to two hard-excluded files

`hooks/TEMPLATE` and `tools/verify-hook.sh` are both on `CLAUDE.md`'s *never edited autonomously* list. The user's approval for this issue is on record in the dispatch — 2026-09-09 22:20, *"you have my approval for that"* — and the issue's `Required` list names the `verify-hook.sh` cases as acceptance criteria, so the approval is read as covering both. Neither file is edited beyond what the switch needs: the template swaps its kill-switch block, and `verify-hook.sh` swaps its kill-switch section and gains two fixtures.

## What else moved

The switch is quoted verbatim in six places outside the hooks, and leaving any of them would have the repository documenting a mechanism it no longer has: `README.md` (the section a user reads when a hook misbehaves), `CLAUDE.md` (*Safe hook editing*), [m10](../product-architecture/mechanisms/m10-branch-guard.md), [m31](../product-architecture/mechanisms/m31-self-improvement-loop.md), `docs/release/pre-release-review.md`, and a comment in `tools/set-mode.py`. Five gates carried the old switch in their own fixtures and now write a mute into the repository under test — four of them gained an **expired** case alongside, which the old switch had no version of.

Dev-log and arc-log references to `HOOKS_OFF` are left as they stand: they are a record of what was true when they were written.

## Verification

See the PR body for the full gate output.
