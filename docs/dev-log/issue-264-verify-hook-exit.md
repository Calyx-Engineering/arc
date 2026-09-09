# Issue #264 — `verify-hook.sh tracker-verify` exits 2 on a passing hook

**Issue:** [#264](https://github.com/Calyx-Engineering/arc/issues/264)  ·  **Parent:** [#145](https://github.com/Calyx-Engineering/arc/issues/145) — Fire

## The cause is the argument form, not the hook

`tools/verify-hook.sh` takes a **path**. `tracker-verify` is not one, so the usage guard fires
before a single case runs:

```
$ bash tools/verify-hook.sh tracker-verify
usage: tools/verify-hook.sh <path-to-hook>
$ echo $?
2
```

```bash
HOOK="${1:-}"
if [ -z "$HOOK" ] || [ ! -f "$HOOK" ]; then
  echo "usage: tools/verify-hook.sh <path-to-hook>" >&2
  exit 2
fi
```

The path form runs the hook and passes:

```
$ bash tools/verify-hook.sh hooks/tracker-verify
…
78 passed, 0 failed
$ echo $?
0
```

**Not `LANG`, and not the case-directory shape.** Both were candidates in the issue. Neither is
reached — the usage line is the whole of stdout and stderr, and `CASES_DIR` is computed after the
guard. `tools/hook-cases/tracker-verify` exists and its cases all pass under the path form.

Exit 2 is the script's usage code. It collides with the report verdict the script itself uses for
`PostToolUse` hooks, which is why it reads as a hook failure rather than a mistyped argument.

## What was changed

[#210](https://github.com/Calyx-Engineering/arc/issues/210)'s third box named the failing form as
its acceptance criterion, so the criterion was the defect. The box now reads
`bash tools/verify-hook.sh hooks/tracker-verify` and is ticked, with the exit code recorded — the
substance behind it was already in the tree when #210 closed. In the issue body the paragraph
explaining the unticked box is replaced by what resolved it; in `issue-210-tracker-verify-trunk.md`
it is kept and superseded, because a dev-log is a record of what was true at the time.

`tools/verify-hook.sh` itself is untouched. It is on CLAUDE.md's never-edited-autonomously list,
and #264's constraint row repeats it, so the ergonomic fix — resolving a bare name against
`hooks/` — is written up as a proposal instead:
[`proposed-verify-hook-bare-name.md`](../arc-work/proposed-verify-hook-bare-name.md).

## Gate

| | |
|---|---|
| `bash tools/verify-all.sh` | 52 gates, all clean, exit 0 |
| `bash tools/verify-hook.sh hooks/tracker-verify` | 78 passed, 0 failed, exit 0 |
| `bash tools/verify-linked-branch.sh 264 arc/04-dogfood-issue-264-verify-hook-exit` | PASS, exit 0 |

## Spawned

**`proposed-verify-hook-declaration-check.md` is stale.** Its change is applied — the
`camp-reports:` declaration check is in `tools/verify-hook.sh` today, tally-excluded as the
proposal specified — but the document still opens *"Not applied."* Recorded on #264, not acted on;
it is a different file and a different decision.
