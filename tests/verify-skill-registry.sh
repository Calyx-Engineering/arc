#!/usr/bin/env bash
# verify-skill-registry.sh — every shipping artifact is reachable from the product definition.
#
#   tests/verify-skill-registry.sh
#
# WHY THIS EXISTS. This is the half of tools/sync-local-skills.sh that outlived it. That script
# kept .claude/skills/ in step with skills/, and did one other job on the side: fail when a
# shipping skill has no row in the product definition's artifact table. #142 deleted the copies
# — Arc is installed in this repository now — and the sync went with them. The registry check
# did not, because a skill the definition does not name is one nothing traces to.
#
# It checks the same thing of commands. A repo-local command is allowed; one that shadows a
# shipping command is #142's defect in the directory #142's scope did not name — #177.
#
# REPORTS, NEVER BLOCKS beyond its exit code. Same precedent as the other verifiers.

set -u

# Absolute, captured before the `cd` — the selftest re-runs this same file against fixture roots.
SELF="$(cd "$(dirname "$0")" && pwd)/$(basename "$0")"

# ---- selftest ----------------------------------------------------------------------
# It sits above the checks because the checks run at top level: the branch has to be taken
# before them. Each case builds a throwaway root and re-runs this file against it with
# SKILLREG_ROOT, so what is exercised is the gate's real exit code and not a copy of its logic.
#
# A FIXTURE ISOLATES ONE CHECK. Planting `skills/<s>/SKILL.md` alone would also trip the
# missing-row check, and the case would then exit 1 whether or not the shadowing check existed
# at all. So the fixture writes a registry row, carrying a mechanism number, for every skill it
# plants: the other two checks pass, and the only thing that can move the exit code is the
# shadowing check under test.
#
# EVERY CASE ASSERTS THE MESSAGE, INCLUDING ITS PASS/FAIL PREFIX. Four checks print into one
# stream and one exit code, so a bare exit 1 does not say which of them fired — a case can go
# green on a failure somewhere else in the file. The prefix is what makes the assertion
# discriminating: `pass` and `fail` print the same label, so the label alone greps identically
# against either and proves nothing the exit code had not already said.
selftest() {
  local passed=0 failed=0 tmp
  tmp="$(mktemp -d)" || { echo "mktemp -d failed" >&2; return 2; }
  # Empty would make every fixture path absolute and the trap an `rm -rf ""`.
  [ -n "$tmp" ] || { echo "mktemp -d returned nothing" >&2; return 2; }
  # Expanded now, not at EXIT: `tmp` is local to selftest and unset by the time the trap runs.
  # %q rather than literal quotes, so a TMPDIR holding a quote cannot break the trap open.
  trap "rm -rf $(printf %q "$tmp")" EXIT

  # case_is <wanted-exit> <name> <text> <text-or-empty> -- <paths to plant>
  # `shift 4` is what lets the second text be empty; the `--` is there so a call that omits a
  # slot is caught rather than silently asserting "--" as its wanted text. It is checked,
  # because an unchecked separator documents an invariant it does not hold.
  case_is() {
    local want="$1" name="$2" t1="$3" t2="$4"; shift 4
    if [ "${1:-}" != "--" ]; then
      echo "  FAIL  $name — malformed case: expected -- before the paths, got \"${1:-}\""
      failed=$((failed + 1)); return
    fi
    shift
    local root="$tmp/$name" out rc f t
    mkdir -p "$root/docs/product-architecture"
    : > "$root/docs/product-architecture/README.md"
    for f in "$@"; do
      mkdir -p "$root/$(dirname "$f")"
      : > "$root/$f"
      # A planted shipping skill gets its registry row, so only the check under test can fail.
      case "$f" in
        skills/*/SKILL.md)
          printf '| `%s` | m99 |\n' "$(dirname "$f")" >> "$root/docs/product-architecture/README.md" ;;
      esac
    done

    out="$(SKILLREG_ROOT="$root" bash "$SELF" 2>&1)"; rc=$?
    if [ "$rc" != "$want" ]; then
      echo "  FAIL  $name — wanted exit $want, got $rc"
      printf '%s\n' "$out" | sed 's/^/          /'
      failed=$((failed + 1)); return
    fi
    for t in "$t1" "$t2"; do
      [ -n "$t" ] || continue
      if ! printf '%s' "$out" | grep -qF -- "$t"; then
        echo "  FAIL  $name — exit $rc is right but the output never says \"$t\""
        printf '%s\n' "$out" | sed 's/^/          /'
        failed=$((failed + 1)); return
      fi
    done
    echo "  ok    $name"
    passed=$((passed + 1))
  }

  echo "verify-skill-registry selftest"
  echo

  # The defect #177 closed: a copy of a shipping command loads alongside the plugin's, and
  # /arc-next resolves to two identical candidates. The second text is what makes this a check
  # on the command half — a failure anywhere else would not name the file.
  case_is 1 "command-shadow" \
          "FAIL  no .claude/commands/ copy shadows a shipping command" \
          "shadowing: arc-next.md" \
          -- commands/arc-next.md .claude/commands/arc-next.md
  case_is 0 "command-clean" \
          "PASS  no .claude/commands/ copy shadows a shipping command" "" \
          -- commands/arc-next.md

  # A repo-local command that ships nowhere is allowed, and must not be read as shadowing.
  case_is 0 "command-local-only" \
          "PASS  no .claude/commands/ copy shadows a shipping command" "" \
          -- commands/arc-next.md .claude/commands/scratch.md

  # The skills half, unchanged by #177 and still the thing #142 deleted.
  case_is 1 "skill-shadow" \
          "FAIL  no .claude/skills/ copy shadows a shipping skill" \
          "shadowing: camp" \
          -- skills/camp/SKILL.md .claude/skills/camp/SKILL.md
  case_is 0 "skill-clean" \
          "PASS  no .claude/skills/ copy shadows a shipping skill" "" \
          -- .claude/skills/scratch/SKILL.md

  # The fixture's own premise, which `skill-shadow` rides: a planted skill WITH its row clears
  # both registry checks, so that case's exit 1 comes from the shadowing check and not from a
  # missing row. It asserts the premise, not the registry checks themselves — those have no
  # negative case, which is #142's gap rather than #177's — filed as #227.
  case_is 0 "registry-row-present" \
          "PASS  every shipping skill has a row in the artifact table" \
          "PASS  every row carries a mechanism number" \
          -- skills/camp/SKILL.md

  echo
  echo "$passed passed, $failed failed"
  [ "$failed" -eq 0 ] || return 1
  return 0
}

case "${1:-}" in
  "")       ;;
  selftest) selftest; exit $? ;;
  *)        echo "usage: $(basename "$0") [selftest]" >&2; exit 2 ;;
esac

cd "${SKILLREG_ROOT:-$(dirname "$0")/..}" || exit 1

REGISTRY=docs/product-architecture/README.md
PASSED=0
FAILED=0
pass() { echo "  PASS  $1"; PASSED=$((PASSED + 1)); }
fail() { echo "  FAIL  $1"; shift; for l in "$@"; do echo "        $l"; done; FAILED=$((FAILED + 1)); }

echo "verify-skill-registry — every shipping skill is named by the product definition"
echo

[ -f "$REGISTRY" ] || { fail "the registry exists" "no such file: $REGISTRY"; echo; echo "0 passed, 1 failed"; exit 1; }

# ---- every shipping skill has a row, and the row carries a mechanism number ----------
missing=""
nomech=""
for d in skills/*/; do
  [ -f "$d/SKILL.md" ] || continue
  s=$(basename "$d")
  row=$(grep -F "| \`skills/$s\` |" "$REGISTRY" 2>/dev/null)
  if [ -z "$row" ]; then
    missing="$missing $s"
  elif ! printf '%s' "$row" | grep -qE 'm[0-9]{2}'; then
    nomech="$nomech $s"
  fi
done

if [ -z "$missing" ]; then
  pass "every shipping skill has a row in the artifact table"
else
  fail "every shipping skill has a row in the artifact table" \
       "a skill the definition does not name is one nothing traces to" \
       "missing:$missing"
fi

if [ -z "$nomech" ]; then
  pass "every row carries a mechanism number"
else
  fail "every row carries a mechanism number" \
       "the row exists but names no mechanism, so the capability has no owner" \
       "no mechanism:$nomech"
fi

# ---- the copies are gone, and stay gone ----------------------------------------------
# Arc is installed here. A reappearing .claude/skills/ copy puts every skill in context twice,
# which is #138's defect at thirteen times the scale.
dupes=""
for d in .claude/skills/*/; do
  [ -d "$d" ] || continue
  s=$(basename "$d")
  [ -d "skills/$s" ] && dupes="$dupes $s"
done
if [ -z "$dupes" ]; then
  pass "no .claude/skills/ copy shadows a shipping skill"
else
  fail "no .claude/skills/ copy shadows a shipping skill" \
       "Arc is installed here — a copy loads alongside the plugin's, and selection sees two" \
       "identical candidates. #142 deleted these; something put them back." \
       "shadowing:$dupes"
fi

# ---- a repo-local command is allowed; one that shadows a shipping command is not -------
# Arc is installed here, so a copy of a shipping command loads alongside the plugin's and
# /arc-next resolves to two identical candidates. #142 deleted the thirteen skill copies and
# left these, its scope having named skills; #177 deleted them and made the check block.
#
# The test is `commands/$c` existing, not the files matching. Two copies that have drifted
# apart are worse than two that agree, not better.
#
# THE GLOB IS FLAT, where the skills one walks `*/`. A namespaced `.claude/commands/arc/next.md`
# is invisible to it, and cannot shadow anything while `commands/` is flat. Revisit if it is not.
cmddupes=""
for f in .claude/commands/*.md; do
  [ -f "$f" ] || continue
  c=$(basename "$f")
  [ -f "commands/$c" ] && cmddupes="$cmddupes $c"
done
if [ -z "$cmddupes" ]; then
  pass "no .claude/commands/ copy shadows a shipping command"
else
  fail "no .claude/commands/ copy shadows a shipping command" \
       "Arc is installed here — a copy loads alongside the plugin's, and the slash command" \
       "resolves to two identical candidates. Delete the copy; the shipping one is the product." \
       "shadowing:$cmddupes"
fi

echo
echo "$PASSED passed, $FAILED failed"
[ "$FAILED" = "0" ] || exit 1
exit 0
