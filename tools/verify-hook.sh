#!/usr/bin/env bash
# verify-hook.sh — run a hook standalone against pass, deny, and malformed input.
#
#   tools/verify-hook.sh hooks/branch-guard
#
# A hook is a program that reads JSON on stdin and writes a decision on stdout, so it runs
# outside Claude Code with no ceremony. This script is the gate that must run before a hook
# is registered, and its output is pasted into the commit body.
#
# WHY A SCRIPT AND NOT A HOOK. The instinct to make the gate itself a hook is right in
# spirit and wrong in mechanism: a hook validating hook changes can be broken by the change
# it is validating, and `HOOKS_OFF` would disable the gate along with everything else. A
# script works with hooks off and produces output a human can read, rather than a silent pass.
#
# This file is hard-excluded from autonomous edits. Changes come to the user as a proposal.

set -u

HOOK="${1:-}"
if [ -z "$HOOK" ] || [ ! -f "$HOOK" ]; then
  echo "usage: tools/verify-hook.sh <path-to-hook>" >&2
  exit 2
fi

CASES_DIR="$(dirname "$0")/hook-cases/$(basename "$HOOK")"
if [ ! -d "$CASES_DIR" ]; then
  echo "no case directory: $CASES_DIR" >&2
  echo "every hook needs pass/, deny/ and malformed/ cases before it is registered" >&2
  exit 2
fi

PASSED=0
FAILED=0

# ---- fixtures -------------------------------------------------------------------
# A branch check must read a real `git rev-parse`, not a mocked one, or it proves nothing
# about the hook as deployed. Throwaway repos are built on the branches the cases need and
# substituted into the payloads by placeholder.
FIXTURES="$(mktemp -d)"
trap 'rm -rf "$FIXTURES"' EXIT

make_repo() {
  local dir="$FIXTURES/$1" branch="$2"
  mkdir -p "$dir"
  git -C "$dir" init -q 2>/dev/null
  git -C "$dir" -c user.email=v@x -c user.name=v commit -q --allow-empty -m init 2>/dev/null
  git -C "$dir" checkout -q -B "$branch" 2>/dev/null
}

make_repo main   main
make_repo arc    arc/02-foundation
make_repo issue  arc/02-foundation-issue-10-skeleton
mkdir -p "$FIXTURES/norepo"

# Portable path form — a payload holds a JSON string, so backslashes would need escaping.
p() { printf '%s' "$FIXTURES/$1" | tr '\\' '/'; }

substitute() {
  sed -e "s#__FIXTURE_MAIN__#$(p main)#g" \
      -e "s#__FIXTURE_ARC__#$(p arc)#g" \
      -e "s#__FIXTURE_ISSUE__#$(p issue)#g" \
      -e "s#__FIXTURE_NOREPO__#$(p norepo)#g"
}

# A case file's first line is a `# ` description; the rest is the JSON payload.
run_case() {
  local expect="$1" file="$2"
  local desc payload out rc verdict

  desc="$(head -n1 "$file" | sed 's/^# *//')"
  payload="$(tail -n +2 "$file" | substitute)"

  out="$(printf '%s' "$payload" | bash "$HOOK" 2>&1)"
  rc=$?

  # Two hook shapes, two verdict vocabularies:
  #
  #   PreToolUse  — exit 0 always; a deny is JSON on stdout. A non-zero exit is a crash,
  #                 and a crashing PreToolUse hook blocks every matching tool call.
  #   PostToolUse — the write already happened, so there is nothing to deny. Exit 2 with
  #                 a message on stderr feeds context back; exit 0 is silence.
  if printf '%s' "$out" | grep -q '"permissionDecision" *: *"deny"'; then
    verdict=deny
  elif [ "$rc" -eq 2 ]; then
    verdict=report
  elif [ "$rc" -ne 0 ]; then
    verdict="CRASH (exit $rc)"
  else
    verdict=allow
  fi

  if [ "$verdict" = "$expect" ]; then
    printf '  PASS  %-6s  %s\n' "$verdict" "$desc"
    PASSED=$((PASSED + 1))
  else
    printf '  FAIL  %-6s  %s\n' "$verdict" "$desc"
    printf '        expected %s\n' "$expect"
    [ -n "$out" ] && printf '        output: %s\n' "$(printf '%s' "$out" | head -c 300)"
    FAILED=$((FAILED + 1))
  fi
}

echo "verify-hook.sh — $HOOK"
echo

# Malformed input must be silent. It is the case a hook is most likely to meet in the wild
# and least likely to have been written for.
#
# `deny/` and `report/` are the two ways a hook can speak up; a hook has one or the other,
# never both. An absent directory is skipped, so each hook declares its shape by which
# cases it ships.
for kind in pass deny report malformed; do
  [ -d "$CASES_DIR/$kind" ] || continue
  case "$kind" in
    pass|malformed) expect=allow ;;
    deny)           expect=deny ;;
    report)         expect=report ;;
  esac
  echo "$kind — expect $expect"
  for f in "$CASES_DIR/$kind"/*.json; do
    [ -e "$f" ] || continue
    run_case "$expect" "$f"
  done
  echo
done

# The kill switch is not a case the payloads can express — it is a file on disk. Assert the
# line is present rather than trusting it was not dropped in an edit.
if grep -q 'HOOKS_OFF' "$HOOK"; then
  echo "  PASS  kill switch present"
  PASSED=$((PASSED + 1))
else
  echo "  FAIL  kill switch line missing — HOOKS_OFF must make this hook inert"
  FAILED=$((FAILED + 1))
fi

# And prove it works, rather than only that the line exists.
KS="$HOME/.claude/HOOKS_OFF"
KS_PREEXISTING=0
[ -f "$KS" ] && KS_PREEXISTING=1
mkdir -p "$(dirname "$KS")" 2>/dev/null
touch "$KS" 2>/dev/null
SPEAKS_UP=deny
[ -d "$CASES_DIR/report" ] && SPEAKS_UP=report
if [ -d "$CASES_DIR/$SPEAKS_UP" ]; then
  for f in "$CASES_DIR/$SPEAKS_UP"/*.json; do
    [ -e "$f" ] || continue
    out="$(tail -n +2 "$f" | substitute | bash "$HOOK" 2>&1)"
    rc=$?
    if printf '%s' "$out" | grep -q '"permissionDecision" *: *"deny"' || [ "$rc" -eq 2 ]; then
      echo "  FAIL  kill switch did not suppress a $SPEAKS_UP case"
      FAILED=$((FAILED + 1))
    else
      echo "  PASS  kill switch suppresses $SPEAKS_UP"
      PASSED=$((PASSED + 1))
    fi
    break
  done
fi
[ "$KS_PREEXISTING" -eq 0 ] && rm -f "$KS"

echo
echo "$PASSED passed, $FAILED failed"
[ "$FAILED" -eq 0 ] || exit 1
