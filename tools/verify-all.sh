#!/usr/bin/env bash
# verify-all.sh — run every gate this repo has, and report one exit code.
#
#   tools/verify-all.sh            every gate
#   tools/verify-all.sh --list     what it would run, and what it cannot
#
# WHY. The repo had four verifiers and nothing that ran them. "The gates are clean" in a PR
# body was a claim a reviewer took on trust, and the close sequence asked for it without
# giving anyone a command. This is that command.
#
# A NEW VERIFIER CANNOT BE SILENTLY SKIPPED. The invocations below are a table, because the
# scripts take different arguments — but the table is checked against `tools/verify-*.sh` on
# disk, and an unknown one fails the run. That is #68's lesson: a hardcoded list makes a new
# thing invisible, and the check whose job is catching a gap reports success instead.
#
# REPORTS, NEVER BLOCKS. Same precedent as every verifier it calls. Exit 1 marks findings for
# a human to read; nothing here denies a tool call or gates a merge on its own.

set -u

cd "$(dirname "$0")/.." || exit 1

LIST=0
[ "${1:-}" = "--list" ] && LIST=1

# name  →  how to invoke it. Scripts needing a per-target argument are expanded below.
KNOWN="verify-autonomy verify-skill-registry verify-tracker-body verify-hook verify-template-links miner-scope"

RUN=0
FAILED=0
FAILED_NAMES=""

run_gate() {
  local label="$1"; shift
  RUN=$((RUN + 1))
  if [ "$LIST" = "1" ]; then
    echo "  would run   $label   ($*)"
    return
  fi
  local out status
  out="$("$@" 2>&1)"; status=$?
  if [ "$status" = "0" ]; then
    # The tail line of each verifier is its own summary; echoing more duplicates it.
    echo "  PASS  $label   $(printf '%s' "$out" | grep -E '[0-9]+ (passed|copied)|are current' | tail -n1)"
  else
    echo "  FAIL  $label"
    printf '%s\n' "$out" | sed 's/^/        /'
    FAILED=$((FAILED + 1))
    FAILED_NAMES="$FAILED_NAMES $label"
  fi
}

echo "verify-all — every gate in this repository"
echo

# ---- the table is checked against disk before anything runs ------------------------
# A verifier nobody wired in is worse than one that fails: it looks like coverage.
unknown=""
for f in tools/verify-*.sh; do
  [ -f "$f" ] || continue
  n="$(basename "$f" .sh)"
  [ "$n" = "verify-all" ] && continue
  case " $KNOWN " in
    *" $n "*) ;;
    *) unknown="$unknown $n" ;;
  esac
done
if [ -n "$unknown" ]; then
  echo "  FAIL  a verifier exists that this runner does not know:$unknown"
  echo "        add it to KNOWN and give it an invocation, or it is coverage nobody has."
  FAILED=$((FAILED + 1))
  FAILED_NAMES="$FAILED_NAMES unknown-verifier"
fi

# ---- the gates ---------------------------------------------------------------------
run_gate "skill registry" bash tools/verify-skill-registry.sh
run_gate "miner scope cases" bash tools/miner-scope.sh selftest
run_gate "autonomy switch" bash tools/verify-autonomy.sh
run_gate "tracker body rules" bash tools/verify-tracker-body.sh selftest
run_gate "template links" bash tools/verify-template-links.sh

# One per hook that has a case directory. A hook without cases is reported rather than
# skipped — CLAUDE.md requires pass, deny and malformed cases before a hook is registered.
for h in hooks/*; do
  [ -f "$h" ] || continue
  n="$(basename "$h")"
  case "$n" in TEMPLATE|*.json) continue ;; esac
  if [ -d "tools/hook-cases/$n" ]; then
    run_gate "hook: $n" bash tools/verify-hook.sh "$h"
  else
    echo "  FAIL  hook: $n   no case directory — CLAUDE.md requires pass, deny and malformed cases"
    FAILED=$((FAILED + 1))
    FAILED_NAMES="$FAILED_NAMES hook:$n"
  fi
done

if [ "$LIST" = "1" ]; then
  cat <<'CANNOT'

  cannot run — and no gate here should be read as covering them:
    hooks in a live session   Arc is installed here, so hooks do fire — camp-branch-check and
                              tracker-verify were both observed. The cases above still run each
                              hook standalone against the WORKING TREE; a live firing uses the
                              installed copy, which is only current after tools/plugin-reload.sh
    any skill                 no gate here invokes one. Every skill-carried rule is checked as
                              text, never as behaviour. claude plugin eval can execute a skill;
                              the suite is #149
CANNOT
  exit 0
fi

echo
if [ "$FAILED" = "0" ]; then
  echo "$RUN gates, all clean"
  echo
  echo "Not covered: hooks in a live session, and every skill. See --list."
  exit 0
fi

echo "$RUN gates, $FAILED failed —$FAILED_NAMES"
exit 1
