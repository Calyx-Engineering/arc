#!/usr/bin/env bash
# verify-case-reader.sh — run the shared case-reader cases.
#
#   tests/verify-case-reader.sh            the cases
#   tests/verify-case-reader.sh selftest   the same cases — this script has no separate fixtures
#
# WHY A WRAPPER AT ALL. The cases live in `tools/case_reader.py selftest`, beside the code they
# cover. This file exists so the gate is a `tests/verify-*.sh` like every other one: verify-all.sh
# checks its invocation table against that glob and fails on a verifier it does not know, and a
# gate invoked as `python tools/x.py` sits outside that check. Same shape as verify-set-mode.sh.
#
# BOTH ARGUMENTS RUN THE SAME THING. `tools/case_reader.py` reads case files and text and needs
# no corpus and no transcripts, so every case is a fixture and there is no live half to skip.
#
# WHAT IT CANNOT DO. It does not prove the four graders still score what they scored — that is
# `tools/report-grade.sh`, `tools/topic-numbering.sh`, `tools/response-length.sh` and
# `tools/skill-cases.sh`, run before and after, and the figures are in
# docs/dev-log/issue-265-shared-case-reader.md. This gate covers the reader's own behaviour.
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

python "$HERE/../tools/case_reader.py" selftest
exit $?
