#!/usr/bin/env bash
# verify-set-mode.sh — run the set-mode cases.
#
#   tests/verify-set-mode.sh            the cases
#   tests/verify-set-mode.sh selftest   the same cases — this script has no separate fixtures
#
# WHY A WRAPPER AT ALL. The cases live in `tools/set-mode.py selftest`, where #198 asked for
# them: they drive the real script in throwaway directories and one of them fires
# `hooks/mode-guard` against what it wrote. This file exists so the gate is a `tests/verify-*.sh`
# like every other one — verify-all.sh checks its invocation table against that glob and fails on
# a verifier it does not know, and a gate invoked as `python tools/x.py` sits outside that check.
# Same shape as report-grade.sh, environment-blame.sh and the other python-backed gates.
#
# BOTH ARGUMENTS RUN THE SAME THING. There is no corpus here and no live half: every case is a
# fixture, so `selftest` and no argument are the same run. verify-all.sh calls it one way; a
# person checking a change to set-mode.py will type the other.
#
# WHAT IT CANNOT DO. It never runs set-mode.py against this repository's own HANDOFF.md — that
# file is gitignored session state, and a test that edited it would leave the session in the
# wrong execution mode. #198's constraint.
#
# REPORTS, NEVER BLOCKS beyond its exit code.

set -u

HERE="$(cd "$(dirname "$0")" && pwd)"

case "${1:-}" in
  ""|selftest) ;;
  # The whole leading comment block, however long it grows. A fixed line range silently
  # truncates its own help the first time a paragraph is added above it.
  -h|--help) awk 'NR>1 && /^#/ {print; next} NR>1 {exit}' "$0"; exit 0 ;;
  *) echo "unknown argument: $1" >&2; exit 2 ;;
esac

python "$HERE/../tools/set-mode.py" selftest
exit $?
