#!/usr/bin/env bash
# hooks-off.sh — a delegator. The command itself is `hooks/hooks-off.sh`.
#
#   bash tools/hooks-off.sh <hook|all> [minutes]   mute; minutes defaults to 30, caps at 480
#   bash tools/hooks-off.sh status                 what is muted here, and when each lapses
#   bash tools/hooks-off.sh clear [<hook|all>]     end it now; with no argument, all of it
#   bash tools/hooks-off.sh selftest               the gate
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
