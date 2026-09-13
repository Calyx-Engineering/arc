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
# IT ALSO CHECKS THAT MENU VISIBILITY WAS DECIDED, NOT INHERITED. A skill with no
# `user-invocable` key defaults to `true` — a slash entry nobody chose. #283 found thirteen
# skills in exactly that state: fired on wording, but each also sitting in the `/` menu because
# nothing said otherwise. The fix is per skill; this is the check that keeps a fourteenth from
# landing the same way. A skill clears it either by carrying the `user-invocable` key at all —
# either value, because the decision is what matters, not which way it went — or by shipping its
# own `commands/<name>.md`, which is its own explicit menu entry.
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

  # assert_case <wanted-exit> <name> <root> <text> <text-or-empty>
  # The tail every case_* builder below shares: run $SELF against a fixture root already built,
  # check its exit code, then check both text substrings. Fixture construction is deliberately
  # NOT folded in here — case_is and case_row build different trees, and that divergence is the
  # isolation the fixtures need, not duplication to remove.
  assert_case() {
    local want="$1" name="$2" root="$3" t1="$4" t2="$5" out rc t
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
    local root="$tmp/$name" f
    mkdir -p "$root/docs/product-architecture"
    : > "$root/docs/product-architecture/README.md"
    for f in "$@"; do
      mkdir -p "$root/$(dirname "$f")"
      : > "$root/$f"
      # A planted shipping skill gets its registry row and a `user-invocable` key, so only the
      # check under test can fail — otherwise every case here would also trip the menu-decided
      # check below, which is exercised on its own fixtures instead.
      case "$f" in
        skills/*/SKILL.md)
          printf '| `%s` | m99 |\n' "$(dirname "$f")" >> "$root/docs/product-architecture/README.md"
          printf -- '---\nuser-invocable: true\n---\n' > "$root/$f" ;;
      esac
    done
    assert_case "$want" "$name" "$root" "$t1" "$t2"
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
  # missing row. It asserts the premise, not the registry checks themselves — those get their
  # own negative cases next, via `case_row`.
  case_is 0 "registry-row-present" \
          "PASS  every shipping skill has a row in the artifact table" \
          "PASS  every row carries a mechanism number" \
          -- skills/camp/SKILL.md

  # case_row <want> <name> <t1> <t2> -- [registry-line ...]
  # #142 wrote the two registry checks with no failing-direction case — #227. `case_is`'s plant
  # loop always gives a planted skill a mechanism-numbered row, which is what isolates the
  # shadowing checks it exists for. These two invert that: the row is exactly what's under test,
  # so they write the registry by hand instead of going through it.
  case_row() {
    local want="$1" name="$2" t1="$3" t2="$4"; shift 4
    if [ "${1:-}" != "--" ]; then
      echo "  FAIL  $name — malformed case: expected -- before the registry lines, got \"${1:-}\""
      failed=$((failed + 1)); return
    fi
    shift
    local root="$tmp/$name" line
    mkdir -p "$root/docs/product-architecture" "$root/skills/$name"
    # A `user-invocable` key, so the row/mechanism check under test is the only one that can
    # fail — otherwise this fixture also trips the menu-decided check below, silently.
    printf -- '---\nuser-invocable: true\n---\n' > "$root/skills/$name/SKILL.md"
    : > "$root/docs/product-architecture/README.md"
    for line in "$@"; do
      printf '%s\n' "$line" >> "$root/docs/product-architecture/README.md"
    done
    assert_case "$want" "$name" "$root" "$t1" "$t2"
  }

  # No row at all: the skill exists, the registry does not mention it.
  case_row 1 "registry-row-missing" \
           "FAIL  every shipping skill has a row in the artifact table" \
           "missing: registry-row-missing" \
           --

  # A row exists but carries no `m##`.
  case_row 1 "registry-row-no-mech" \
           "FAIL  every row carries a mechanism number" \
           "no mechanism: registry-row-no-mech" \
           -- '| `skills/registry-row-no-mech` | no mechanism here |'

  # case_menu <want> <name> <t1> <t2> <SKILL.md-content> [command-file-basename]
  # #283: a skill's menu visibility has to be a decision, not the default it inherits by saying
  # nothing. The registry row is planted directly, same as `case_row`, so only the menu check
  # under test can move the exit code.
  case_menu() {
    local want="$1" name="$2" t1="$3" t2="$4" content="$5" cmd="${6:-}"
    local root="$tmp/$name"
    mkdir -p "$root/docs/product-architecture" "$root/skills/$name" "$root/commands"
    printf '%s\n' "$content" > "$root/skills/$name/SKILL.md"
    printf '| `skills/%s` | m99 |\n' "$name" > "$root/docs/product-architecture/README.md"
    [ -n "$cmd" ] && : > "$root/commands/$cmd"
    assert_case "$want" "$name" "$root" "$t1" "$t2"
  }

  # Neither a command nor the key: exactly the state all thirteen skills were in before #283.
  case_menu 1 "menu-undeclared" \
            "FAIL  every skill declares user-invocable, or ships its own command" \
            "undeclared: menu-undeclared" \
            $'---\nname: menu-undeclared\n---'

  # The key clears it whichever way it's set — the decision is what's checked, not its direction.
  case_menu 0 "menu-hidden" \
            "PASS  every skill declares user-invocable, or ships its own command" "" \
            $'---\nname: menu-hidden\nuser-invocable: false\n---'
  case_menu 0 "menu-kept" \
            "PASS  every skill declares user-invocable, or ships its own command" "" \
            $'---\nname: menu-kept\nuser-invocable: true\n---'

  # No key, but the skill ships its own command — an explicit menu entry by a different route.
  case_menu 0 "menu-commanded" \
            "PASS  every skill declares user-invocable, or ships its own command" "" \
            $'---\nname: menu-commanded\n---' \
            menu-commanded.md

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

# ---- every skill's menu visibility was decided, not inherited -------------------------
# A skill with no `user-invocable` key defaults to `true` — a slash entry nobody chose. #283
# found all thirteen shipping skills in that state. A skill clears this either by carrying the
# key at all (either value — the decision is what's checked, not its direction) or by shipping
# its own `commands/<name>.md`, which is its own explicit menu entry.
noflag=""
for d in skills/*/; do
  [ -f "$d/SKILL.md" ] || continue
  s=$(basename "$d")
  [ -f "commands/$s.md" ] && continue
  grep -qE '^user-invocable:' "$d/SKILL.md" && continue
  noflag="$noflag $s"
done
if [ -z "$noflag" ]; then
  pass "every skill declares user-invocable, or ships its own command"
else
  fail "every skill declares user-invocable, or ships its own command" \
       "no commands/<name>.md wires it and no user-invocable key says whether it belongs" \
       "in the menu — its slash entry is inherited, not decided" \
       "undeclared:$noflag"
fi

echo
echo "$PASSED passed, $FAILED failed"
[ "$FAILED" = "0" ] || exit 1
exit 0
