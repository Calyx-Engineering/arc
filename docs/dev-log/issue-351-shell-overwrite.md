# Issue #351 — fix: handoff-archive misses a shell overwrite of an untracked file

> Dev-log, not a spec. Started at plan time, finalised as a retrospective at PR time.

**Issue:** [#351](https://github.com/Calyx-Engineering/arc/issues/351)  ·  **PR:** TBD

## Problem

`hooks/handoff-archive` takes a copy of the handoff at every session's first tool call, and a
copy of any other user-authored file the moment an `Edit`, `Write` or `NotebookEdit` is about
to replace it. A Bash redirect over some other untracked file — `cat > notes.md`, `mv`, `rm`,
`cp` — names no target the edit-tool matchers can see, so that file was destroyed with no copy
kept. Named as uncovered in #152's dev-log; never filed until now.

## Decisions & trade-offs

- **A word split, not a shell parse.** `bash_overwrite_target()` runs `read -ra` over the raw
  `command` string and recognises four plain forms: a bare `>`/`1>`, `mv`, `rm`, `cp`. A
  pipeline, `&&`, a subshell, `sed -i`, a glued operator (`cat>file`) or a quoted path with a
  space in it are not parsed — a wrong guess would copy the wrong file while reporting success,
  and this hook never denies. Named as accepted gaps in the hook's own comments rather than
  handled.
- **`>>` (append) and `2>`/`&>` are excluded on purpose.** They do not destroy the file's prior
  content the way a plain overwrite does.
- **`--` end-of-options is honoured** for `mv`, `cp` and `rm` — `mv -- foo -bar` and
  `rm -- -confidential.txt` are the standard idiom for a dash-named path, and treating the
  word after `--` as a flag misses the target (`rm`) or archives the wrong file (`mv`).

## Two defects found by review pass 2, fixed before commit

Pass 1 confirmed the feature worked for the cases it was shown. Pass 2 read the new code
adversarially and found two real bugs, both verified live against the actual hook before and
after the fix — neither is a documented gap, both defeat the feature on ordinary input:

1. **`field()` truncated `command` at the first quote, escaped or not.** `field()` was written
   for `file_path`/`session_id`/`tool_name` values, which never carry an internal quote — its
   comment said so explicitly. `command` routinely does: `echo "note" > file` truncated the
   parsed command at `echo \` and `bash_overwrite_target` never saw the `>` at all, so the file
   was destroyed with zero recovery. Fixed by walking the string character by character,
   unescaping `\"` and `\\`, rather than cutting at the first `"`.
2. **A word after `--` was still treated as a flag.** `mv -- foo -bar` archived `foo` (the
   source) instead of `-bar` (the destination whose content is actually lost); `rm --
   -confidential.txt` found no target at all. Fixed by tracking the last bare `--` token and
   treating everything after it as literal regardless of a leading dash.

Both are now permanent regression cases in `tests/verify-handoff-archive.sh` selftest
(10k, 10l, 10m), driven against real repositories with real file content, not just a verdict
check.

## Verification

- `tests/verify-handoff-archive.sh selftest` — **26 passed, 0 failed**, including four cases
  per Bash form (10e–10h), the tracked-file exception (10i), the `>>` exclusion (10j), and the
  two regression cases above (10k, 10l, 10m).
- `tools/verify-hook.sh hooks/handoff-archive` output is in this commit's body.

## Spawned

Nothing filed. The remaining named gaps (a pipeline, `&&`, `sed -i`, a glued operator, a quoted
path with a space) are documented in the hook's own comments as accepted trade-offs of a word
split, not new findings that warrant an issue.
