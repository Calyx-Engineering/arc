# Issue #276 — a gate that reports a skill over 500 lines

> Dev-log, not a spec.

**Issue:** [#276](https://github.com/Calyx-Engineering/arc/issues/276)  ·  **PR:** pending

## Problem

Nothing measured `skills/*/SKILL.md` length. Twelve of thirteen skills exceeded the old limit for
weeks unnoticed, and `verify-all.sh` had no gate that would have caught it.

## What was built

`tools/verify-skill-length.sh` — counts every `skills/*/SKILL.md`'s lines and reports any over
500. **Reports, never fails**: the live invocation always exits 0, so `verify-all.sh` does not go
red over pre-existing length — two skills (`issue-write` at 836 lines, `work-watch` at 608) are
already over on the day this shipped, and the list is for a human to act on, not a build blocker.

Wired into `tests/verify-all.sh`: added to the `KNOWN` verifier list, and two `run_gate` lines —
`skill length cases` (the selftest) and `skill length` (the live report against this repository).

## Review passes

| | |
|---|---|
| **Pass 1** | Requirements met — boundary logic, exit-0 contract, and the `KNOWN`-list wiring all read correctly. Nothing found |
| **Pass 2** | Three real defects in the new script. **`run_gate`'s summarizer only echoes a gate's own tail line when it matches `passed`/`copied`/`are current`** — every other live gate here ends `"$PASSED passed, $FAILED failed"`, and the first draft's `"N skill(s) over 500 lines"` line didn't match, so the finding this gate exists to surface never appeared in a plain `verify-all.sh` run. Fixed: the report's last line is now `"$passed passed, $hits over 500 lines"`, honest and matching. **`wc -l` counts newlines, not lines** — a `SKILL.md` whose last line has no trailing newline would be undercounted by exactly one, a false negative at the exact boundary this tool polices. Fixed: switched to `awk 'END{print NR}'`, which counts the final unterminated line. **`mktemp -d`'s return value went unchecked** in the selftest, unlike `tools/environment-blame.sh`'s same pattern. Fixed: added the same guard |
| **Pass 3** | Checklist audit against the tree — both boxes verified with real command output before Pass 2's fixes landed; re-run after, unchanged |

## Retrospective

Soak: next work stretch that touches `skills/`. The measure is whether `verify-all.sh` keeps
naming any skill that crosses 500 lines, in the terminal, without a human reaching for the tool by
hand.
