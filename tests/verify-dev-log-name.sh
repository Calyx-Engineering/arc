#!/usr/bin/env bash
# verify-dev-log-name.sh — the dev-log is called the dev-log, everywhere it is named.
#
#   tools/verify-dev-log-name.sh            check this repository
#   tools/verify-dev-log-name.sh selftest   run the fixture cases
#
# WHY. `templates/dev-log.md` opened by calling itself a *decision log*. The file is
# `dev-log.md`, the artifact is the dev-log in m17 and everywhere else, and the name a cold
# session reads first is the one in the banner — so the document disagreed with itself at line
# three. #168. Three mechanism specs quoted that banner verbatim, and `tools/new-direct-pr.sh`
# writes it into every stub it opens, so the wrong name reproduced itself into each new dev-log.
# Thirty-seven of them carried it.
#
# A RENAME NEEDS A GATE OR IT COMES BACK. The sweep is the easy half; the stub generator is why
# it would not have stayed swept. This is the grep that keeps it.
#
# TWO KINDS OF EXCEPTION, EACH NAMED WITH ITS REASON — never a list held in a variable, because
# a list is what lets the next one in without anyone deciding.
#
# Whole areas that are not this repository's live vocabulary:
#
#   docs/product-architecture/archive/         a frozen record of what was true then
#   docs/reference-timescope/                  another system's vocabulary, not ours
#
# Documents whose SUBJECT is this rename, which cannot describe it without naming it:
#
#   docs/arc-work/04-dogfood/issue-plan.md     the plan entry that raised it
#   docs/dev-log/issue-168-dev-log-name.md     the dev-log of the change that made it
#
# This script excludes itself too, which is mechanical rather than an exception: it has to hold
# the wrong name in order to search for it.
#
# REPORTS, NEVER BLOCKS. Exit 1 names the file and line. Same precedent as every verifier here.

set -u

SELF="$(cd "$(dirname "$0")" && pwd)/$(basename "$0")"

# The name the dev-log must not call itself. Matched case-insensitively: "decision log" is as
# wrong as "Decision log", and a rename that only fixed the capitalised form is not a rename.
WRONG='decision log'
RIGHT='dev-log'

scan() {  # scan <root> — prints one "path:line:text" per offending occurrence
  local root="$1"
  ( cd "$root" 2>/dev/null || return 0
    grep -rni --binary-files=without-match -- "$WRONG" . 2>/dev/null \
      | sed 's|^\./||' \
      | grep -v '^\.git/' \
      | grep -v '^\.arc-work/' \
      | grep -v '^\.claude/arc/' \
      | grep -v '^docs/product-architecture/archive/' \
      | grep -v '^docs/reference-timescope/' \
      | grep -v '^docs/arc-work/04-dogfood/issue-plan\.md:' \
      | grep -v '^docs/dev-log/issue-168-dev-log-name\.md:' \
      | grep -v '^tools/verify-dev-log-name\.sh:'
  )
}

report() {
  local root="$1" hits
  echo "verify-dev-log-name — the dev-log names itself consistently"
  echo

  hits="$(scan "$root")"
  if [ -z "$hits" ]; then
    echo "  PASS  no artifact calls the dev-log a '$WRONG'"
    return 0
  fi

  local n
  n="$(printf '%s\n' "$hits" | wc -l | tr -d ' ')"
  echo "  FAIL  $n occurrence(s) of '$WRONG' — the artifact is the '$RIGHT'"
  printf '%s\n' "$hits" | sed 's/^/        /'
  echo
  echo "  The banner in templates/dev-log.md is the source; tools/new-direct-pr.sh copies it"
  echo "  into every stub, and the mechanism specs quote it. Fix all of them together."
  return 1
}

# ---- the self-test --------------------------------------------------------------------------
# Fixture trees under mktemp, never this repository's own — the same shape the other verifiers
# here use. A live run alone cannot show the check can fail, because the live tree is clean.
if [ "${1:-}" = "selftest" ]; then
  passed=0; failed=0
  WORK="$(mktemp -d)"; trap 'rm -rf "$WORK"' EXIT

  make_tree() {  # make_tree <name> — a clean miniature repo
    local root="$WORK/$1"
    mkdir -p "$root/templates" "$root/docs/dev-log" "$root/tools" \
             "$root/docs/product-architecture/archive" "$root/docs/reference-timescope" \
             "$root/docs/arc-work/04-dogfood"
    printf '# Issue #<N>\n\n> Dev-log, not a spec.\n' > "$root/templates/dev-log.md"
    printf '# Issue #1\n\n> Dev-log, not a spec.\n'   > "$root/docs/dev-log/issue-1-x.md"
    printf 'echo "> Dev-log, not a spec."\n'          > "$root/tools/new-direct-pr.sh"
    printf '%s' "$root"
  }

  case_is() {
    local name="$1" want_status="$2" want_text="$3" got_status="$4" got="$5"
    if [ "$got_status" = "$want_status" ] && [[ "$got" == *"$want_text"* ]]; then
      echo "  PASS  $name"; passed=$((passed + 1))
    else
      echo "  FAIL  $name"
      echo "        wanted exit $want_status containing: $want_text"
      echo "        got exit $got_status:"
      printf '%s\n' "$got" | sed 's/^/        | /'
      failed=$((failed + 1))
    fi
  }

  run() { TERM=dumb bash "$SELF" --root "$1" 2>&1; }

  echo "verify-dev-log-name selftest — fixture trees, never the live tree"
  echo

  # 1 — a swept tree passes.
  root=$(make_tree clean)
  out=$(run "$root"); status=$?
  case_is "a swept tree passes" 0 "no artifact calls the dev-log" "$status" "$out"

  # 2 — the template itself. The source of the name, and #168's subject.
  root=$(make_tree template)
  printf '# Issue #<N>\n\n> Decision log, not a spec.\n' > "$root/templates/dev-log.md"
  out=$(run "$root"); status=$?
  case_is "the template using the old name fails" 1 "templates/dev-log.md" "$status" "$out"

  # 3 — the stub generator. This is why a sweep alone would not have held: every new dev-log
  #     would have carried the old name back in.
  root=$(make_tree generator)
  printf 'echo "> Decision log, not a spec."\n' > "$root/tools/new-direct-pr.sh"
  out=$(run "$root"); status=$?
  case_is "the stub generator using the old name fails" 1 "tools/new-direct-pr.sh" "$status" "$out"

  # 4 — an existing dev-log.
  root=$(make_tree existing)
  printf '# Issue #1\n\n> Decision log, not a spec.\n' > "$root/docs/dev-log/issue-1-x.md"
  out=$(run "$root"); status=$?
  case_is "an existing dev-log using the old name fails" 1 "docs/dev-log/issue-1-x.md" "$status" "$out"

  # 5 — lower case is the same defect. Without this the check could match only the capitalised
  #     form and a rename would be half done.
  root=$(make_tree lowercase)
  printf 'the per-issue decision log\n' > "$root/docs/dev-log/issue-2-y.md"
  out=$(run "$root"); status=$?
  case_is "the lower-case form fails too" 1 "docs/dev-log/issue-2-y.md" "$status" "$out"

  # 6 to 8 — the three named exceptions. Each keeps the old name for a stated reason, and a
  #          check that failed on them would be reporting the record rather than the drift.
  root=$(make_tree archive)
  printf 'Per-issue decision log — how it was described then.\n' \
    > "$root/docs/product-architecture/archive/HANDOFF.md"
  out=$(run "$root"); status=$?
  case_is "the archive keeps the old name" 0 "no artifact calls the dev-log" "$status" "$out"

  root=$(make_tree timescope)
  printf 'issue -> decision log -> PR, in that system.\n' \
    > "$root/docs/reference-timescope/agent-process-foundation.md"
  out=$(run "$root"); status=$?
  case_is "another system's vocabulary is left alone" 0 "no artifact calls the dev-log" "$status" "$out"

  root=$(make_tree issueplan)
  printf 'the dev-log template calls itself a decision log\n' \
    > "$root/docs/arc-work/04-dogfood/issue-plan.md"
  out=$(run "$root"); status=$?
  case_is "the plan may name the defect it describes" 0 "no artifact calls the dev-log" "$status" "$out"

  # 8b — and so may the dev-log of the change that made the rename. Found by review pass 4:
  #      the gate failed on its own dev-log, which cannot describe the defect without naming it.
  root=$(make_tree ownlog)
  printf '# the dev-log template calls itself a decision log\n' \
    > "$root/docs/dev-log/issue-168-dev-log-name.md"
  out=$(run "$root"); status=$?
  case_is "the rename's own dev-log may name it" 0 "no artifact calls the dev-log" "$status" "$out"

  # 8c — but only THAT dev-log. Another dev-log using the old name is the ordinary defect, and
  #      without this case the exception could widen to docs/dev-log/ and nobody would see it.
  root=$(make_tree otherlog)
  printf '# a decision log\n' > "$root/docs/dev-log/issue-99-other.md"
  out=$(run "$root"); status=$?
  case_is "another dev-log is not covered by that exception" 1 "docs/dev-log/issue-99-other.md" "$status" "$out"

  # 9 — the exception is the archive DIRECTORY, not any file called HANDOFF.md. A path-suffix
  #     match would let the live handoff drift.
  root=$(make_tree livehandoff)
  printf 'Per-issue decision log.\n' > "$root/HANDOFF.md"
  out=$(run "$root"); status=$?
  case_is "a live file is not covered by the archive exception" 1 "HANDOFF.md" "$status" "$out"

  echo
  echo "$passed passed, $failed failed"
  [ "$failed" = "0" ] || exit 1
  exit 0
fi

# `--root` exists for the selftest. The live invocation takes no arguments.
if [ "${1:-}" = "--root" ]; then
  report "${2:-.}"
  exit $?
fi

report "$(cd "$(dirname "$0")/.." && pwd)"
exit $?
