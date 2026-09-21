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
# it is validating, and a mute would disable the gate along with everything else. A
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

# ---- a mute in THIS repository would make this gate lie -----------------------------
# The cases below add nothing to the environment, so each hook resolves the kill switch the
# way it always does: CLAUDE_PROJECT_DIR if this environment carries one, otherwise the
# directory this script was started in. The question asked here is that same question, so it
# lands on whichever repository the hooks are about to consult.
#
# A live mute there silences every hook under test: the `deny` and `report` cases go red, but
# `pass` and `malformed` go green having proved nothing, and a reader cannot tell that from
# coverage.
#
# Refuse rather than warn. This is the failure mode #160 and #210 found in the switch this
# one replaces — a gate reporting on hooks that were inert — and the whole point of an
# expiring, per-repository switch is that the state is readable and short-lived.
if . "$(dirname "$0")/../hooks/lib/hooks-off" 2>/dev/null; then
  if arc_hooks_off all || arc_hooks_off "$(basename "$HOOK")"; then
    echo "verify-hook.sh: this repository carries a live mute, so every hook here is inert." >&2
    echo "                Nothing below would mean anything. Clear it first:" >&2
    echo "                  bash hooks/hooks-off.sh status" >&2
    echo "                  bash hooks/hooks-off.sh clear" >&2
    exit 2
  fi
fi

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

# mode-guard reads HANDOFF.md's Execution mode row, so it needs repos that have one. The
# branch is irrelevant to that hook; the file is the whole input. `norepo` covers absent.
make_repo manual     main
make_repo autonomous main
make_repo badmode    main
mode_file() { printf '## Execution mode

| | |
|---|---|
| **Mode** | **%s** |
' "$2" > "$FIXTURES/$1/HANDOFF.md"; }
mode_file manual     Manual
mode_file autonomous Autonomous
mode_file badmode    Paused

# Portable path form — a payload holds a JSON string, so backslashes would need escaping.
p() { printf '%s' "$FIXTURES/$1" | tr '\\' '/'; }

substitute() {
  sed -e "s#__FIXTURE_MAIN__#$(p main)#g" \
      -e "s#__FIXTURE_ARC__#$(p arc)#g" \
      -e "s#__FIXTURE_ISSUE__#$(p issue)#g" \
      -e "s#__FIXTURE_NOREPO__#$(p norepo)#g"       -e "s#__FIXTURE_MANUAL__#$(p manual)#g"       -e "s#__FIXTURE_AUTONOMOUS__#$(p autonomous)#g"       -e "s#__FIXTURE_BADMODE__#$(p badmode)#g"      -e "s#__FIXTURE_PR__#$(p pr)#g"
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
  elif printf '%s' "$out" | grep -q '"permissionDecisionReason" *: *"[^"]'; then
    verdict=report
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

# ---- the kill switch ------------------------------------------------------------
# Five states, and four of them are ways the switch can be OFF while a reader assumes it is
# on. It is no longer a file anyone can place by hand: `hooks/hooks-off.sh <hook> [minutes]`
# writes an entry scoped to one repository and one hook, and that entry lapses on its own. #202.
#
#   absent       no state file — the hook speaks up as normal
#   active       an unexpired entry naming this hook — suppressed
#   expired      an entry whose expiry has passed — speaks up again, nobody having restored it
#   per-hook     an unexpired entry naming a DIFFERENT hook — this one is unaffected
#   wrong scope  an unexpired `all` in ANOTHER repository — this one is unaffected
#
# The switch it replaced failed the last four by construction: one file, no expiry, every
# hook, every repository on the machine.

# The line, asserted rather than trusted. A hook that has lost it cannot be muted at all,
# which is the state the switch exists to rescue someone from.
if grep -q 'lib/hooks-off' "$HOOK"; then
  echo "  PASS  kill switch present"
  PASSED=$((PASSED + 1))
else
  echo "  FAIL  kill switch line missing — hooks/lib/hooks-off must make this hook inert"
  FAILED=$((FAILED + 1))
fi

# And prove it works, rather than only that the line exists.
#
# WHY `CLAUDE_PROJECT_DIR` AND NOT `cd`. The switch is repo-scoped, and a hook resolves its
# repository from `CLAUDE_PROJECT_DIR` first and the directory it was started in second. The
# environment variable is the lever here because `cd` is not available: several of
# `camp-branch-check`'s payloads carry a repo-RELATIVE `cwd` — `.`, and a path under
# `tools/hook-cases/` — which is only meaningful from the repository root, so a verifier that
# moves loses those cases silently and reads the loss as a working kill switch.
#
# What matters either way is that every entry written below lands inside `$FIXTURES`: a verifier
# cannot mute the repository it is running in. That is the promise the old test could not make —
# it wrote `$HOME/.claude/HOOKS_OFF`, and overlapping runs left it there (#160, #210).
make_repo ks      main
make_repo ksother main
HOOK_ABS="$(cd "$(dirname "$HOOK")" && pwd)/$(basename "$HOOK")"
HOOK_NAME="$(basename "$HOOK")"

SPEAKS_UP=deny
[ -d "$CASES_DIR/report" ] && SPEAKS_UP=report

ks_state() { printf '%s' "$FIXTURES/$1/.git/arc-hooks-off"; }

# ks_set <repo> <hook-or-all> <seconds-from-now>. A negative offset writes an expired entry.
ks_set() {
  local now
  now="$(date +%s)"
  printf '%s %s\n' "$((now + $3))" "$2" > "$(ks_state "$1")"
}

ks_clear() { rm -f "$(ks_state ks)" "$(ks_state ksother)"; }

# Several hooks act once per session and are silent afterwards — a marker in the fixture's
# `.git`, or a work directory. The cases above have already fired them, and each case below
# fires them again, so without this the whole section reads as "the hook never speaks" and the
# switch appears to work when nothing is being suppressed. Cleared before every run rather than
# once, because the runs are what consume it.
ks_reset() {
  rm -f  "$FIXTURES"/*/.git/arc-camp-session-* 2>/dev/null
  rm -f  "$FIXTURES"/*/.git/arc-archive-*      2>/dev/null
  rm -rf "$FIXTURES"/*/.git/arc-branch-guard   2>/dev/null
  rm -rf "$FIXTURES"/*/.arc-work               2>/dev/null
  return 0
}

# Run the hook's first speaking case from inside the `ks` repository, and say whether it spoke.
ks_speaks() {
  local f out rc
  for f in "$CASES_DIR/$SPEAKS_UP"/*.json; do
    [ -e "$f" ] || continue
    ks_reset
    out="$(tail -n +2 "$f" | substitute            | CLAUDE_PROJECT_DIR="$FIXTURES/ks" ARC_EVENT_LOG="$FIXTURES/ks-log.md" bash "$HOOK_ABS" 2>&1)"
    rc=$?
    # BOTH shapes, and the second is why this is not the old test with new cases. The switch
    # assertion that stood here recognised only a deny and `exit 2`, so for a `report/` hook —
    # camp-session-start, camp-branch-check, tracker-verify — the failing branch was
    # unreachable and the test passed whether the switch worked or not.
    printf '%s' "$out" | grep -q '"permissionDecision" *: *"deny"'      && return 0
    printf '%s' "$out" | grep -q '"permissionDecisionReason" *: *"[^"]' && return 0
    [ "$rc" -eq 2 ] && return 0
    return 1
  done
  return 1
}

# ks_case <label> <spoke|silent>
ks_case() {
  local got
  if ks_speaks; then got=spoke; else got=silent; fi
  if [ "$got" = "$2" ]; then
    printf '  PASS  %s\n' "$1"
    PASSED=$((PASSED + 1))
  else
    printf '  FAIL  %s\n' "$1"
    printf '        expected the hook to be %s, it was %s\n' "$2" "$got"
    FAILED=$((FAILED + 1))
  fi
}

if [ -d "$CASES_DIR/$SPEAKS_UP" ]; then
  ks_clear
  ks_case "kill switch absent — the hook speaks up" spoke

  ks_set ks all 600
  ks_case "kill switch active — \`all\` suppresses the $SPEAKS_UP" silent

  ks_set ks "$HOOK_NAME" 600
  ks_case "kill switch active — this hook by name suppresses the $SPEAKS_UP" silent

  ks_set ks "$HOOK_NAME" -600
  ks_case "kill switch expired — it lapses with nobody restoring it" spoke

  ks_set ks not-this-hook 600
  ks_case "kill switch per-hook — another hook's entry leaves this one on" spoke

  ks_clear
  ks_set ksother all 600
  ks_case "kill switch wrong scope — another repository's \`all\` leaves this one on" spoke

  ks_clear
fi

# ---- declaration check ----------------------------------------------------------
# Reports, never fails. A hook with no `camp-reports:` header still works — it is simply
# invisible when it fires, which is a gap worth naming at exactly the moment someone is
# already looking at the hook. Making it a failure would turn the convention into a cost
# paid while trying to fix something else.
#
# Deliberately outside the PASSED/FAILED tally and the exit code.
if ! grep -q '^# camp-reports:' "$HOOK"; then
  echo
  echo "  note  $HOOK has no \`camp-reports:\` declaration."
  echo "        It will not report when it fires, and will write nothing to the event log."
  echo "        Format: docs/product-architecture/camp-reports.md"
fi

echo
echo "$PASSED passed, $FAILED failed"
[ "$FAILED" -eq 0 ] || exit 1
