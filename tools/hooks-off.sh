#!/usr/bin/env bash
# hooks-off.sh — a delegator. The command itself is `hooks/hooks-off.sh`.
#
# Every form works through it — `bash tools/hooks-off.sh status`, `… clear`, `… <hook> 30` —
# and `-h` prints the real file's usage, because `exec` has already replaced this process by
# then. There is deliberately no copy of that usage here: two statements of one interface is
# one more than can be kept in step.
#
# WHY THE REAL FILE IS NOT HERE. Arc installs as a plugin, and an installed plugin ships
# `hooks/` — it does not ship `tools/`. A kill switch whose only documented invocation is
# `bash tools/hooks-off.sh …` therefore works in this repository and nowhere else, which is
# the 2026-09-07 failure relocated rather than removed: a line typed by someone already
# dealing with a broken guardrail, that silently does nothing. So the command lives beside
# the hooks it mutes, and this file exists only so the path muscle-memory of this repository
# keeps working. #202.
#
# Nothing but the delegation belongs here. Two implementations of a kill switch is one more
# than can be kept in step.

exec bash "$(dirname "$0")/../hooks/hooks-off.sh" "$@"
