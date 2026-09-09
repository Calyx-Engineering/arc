#!/usr/bin/env bash
# verify-handoff-checks.sh — the staleness checks are reachable from the skill, not only the command.
#
#   tools/verify-handoff-checks.sh
#   tools/verify-handoff-checks.sh selftest
#
# WHY THIS EXISTS. m15 has two entry points into the same mechanism. `/arc-next` is a typed
# shortcut; `skills/handoff` is what fires when a session says "read the handoff" in any of the
# twenty wordings its description lists. The seven staleness checks lived only in the command, so
# an opening that reached the skill got the read path with no check against the tree — 76e54966 is
# that session — and an opening that reached the command got the checks without the skill's write
# path and transcript rules. #208 moved them into the skill.
#
# THE RULE THIS ENCODES. A cold start that loads `skills/handoff` and never touches `/arc-next`
# runs the staleness checks. That is a property of where the content lives, so it is checkable as
# text, and the split cannot silently re-open.
#
# THE PROBES TAKE A SLICE, NOT THE FILE. Presence anywhere would pass for a block that had drifted
# below the write path, and the rule is that the handoff is checked BEFORE it is acted on. So the
# read-path range is located first and every probe runs inside it.
#
# BOTH COMMAND FILES, IF BOTH EXIST. A `.claude/commands/arc-next.md` copy would shadow the
# plugin's and be the one that fires here, so checking only the plugin file would pass while
# the copy that actually runs was stale. #177 deleted that copy and made
# verify-skill-registry.sh fail on a shadowing command rather than report it, so the shadow
# probes below are a guard against it coming back, not a check on a file that is there.
#
# WHAT IT CANNOT DO. It reads files for content. It does not invoke the skill, and no gate in this
# repository does — see tools/verify-all.sh --list. A check named here is present, not proven to be
# performed.
#
# REPORTS, NEVER BLOCKS beyond its exit code. Same precedent as the other verifiers.

set -u

# Captured before the cd: the selftest re-invokes this script with HANDOFFCHK_ROOT pointing at a
# fixture tree, and after the cd a relative $0 no longer resolves.
SELF="$(cd "$(dirname "$0")" && pwd)/$(basename "$0")"

cd "${HANDOFFCHK_ROOT:-$(dirname "$0")/..}" || exit 1

SKILL=skills/handoff/SKILL.md
CMD=commands/arc-next.md
SHADOW=.claude/commands/arc-next.md

PASSED=0
FAILED=0
pass() { echo "  PASS  $1"; PASSED=$((PASSED + 1)); }
fail() { echo "  FAIL  $1"; shift; for l in "$@"; do echo "        $l"; done; FAILED=$((FAILED + 1)); }

# ---- selftest ---------------------------------------------------------------------------------
# Fixture skills with a known defect each, to prove the frontmatter block can fail. A gate nobody
# can make fail is a gate nobody should read a pass from — and the five denial runs this unit's
# record cites were ad-hoc until they were written down here.
#
# EACH FIXTURE IS THE REAL SKILL WITH ONE LINE CHANGED, and the mutations are ASCII-only: the
# entries they replace carry an em dash, and matching one through sed on Windows is a portability
# problem this does not need to have.
selftest() {
  T="$(mktemp -d)"
  trap 'rm -rf "$T"' EXIT
  ROOT="$T/root"
  mkdir -p "$ROOT/skills/handoff" "$ROOT/commands"
  cp "$CMD" "$ROOT/commands/arc-next.md"

  case_is() {  # <expected-exit> <label> <filter…>
    local want="$1" label="$2"; shift 2
    "$@" < "$SKILL" > "$ROOT/skills/handoff/SKILL.md"
    HANDOFFCHK_ROOT="$ROOT" bash "$SELF" >/dev/null 2>&1
    local got=$?
    if [ "$got" = "$want" ]; then
      pass "selftest — $label exits $got"
    else
      fail "selftest — $label exits $got, expected $want"
    fi
  }

  case_is 0 "the skill as it stands" cat
  case_is 1 "a check with no skips: entry"          grep -v '^  - stale-rows-removed ('
  case_is 1 "a condition naming no path"            sed 's/^  - stale-rows-removed (.*/  - stale-rows-removed (only when rows were consumed)/'
  case_is 1 "a path phrase appended to a condition" sed 's/^  - stale-rows-removed (.*/  - stale-rows-removed (only when rows were consumed on the read path)/'
  case_is 1 "a skip for a check not declared"       sed 's/^checks: \[handoff-exists, /checks: [handoff-present, /'
  case_is 1 "a name both skipped and both-path"     sed 's/^  - handoff-exists (/  - ordered-actions-present (/'
  case_is 1 "the both-path line deleted"            grep -v 'Both-path checks:'
}

if [ "${1:-}" = "selftest" ]; then
  echo "verify-handoff-checks selftest — the frontmatter block can fail"
  echo
  selftest
  echo
  echo "$PASSED passed, $FAILED failed"
  [ "$FAILED" = "0" ] || exit 1
  exit 0
fi

echo "verify-handoff-checks — the staleness checks live in the skill"
echo

for f in "$SKILL" "$CMD"; do
  [ -f "$f" ] || { fail "$f exists" "no such file"; echo; echo "$PASSED passed, $FAILED failed"; exit 1; }
done

# ---- where the read path begins and ends ------------------------------------------------
staleline=$(grep -n '^### Check the handoff is still true' "$SKILL" | head -n1 | cut -d: -f1)
execline=$(grep -n '^### Then execute$' "$SKILL" | head -n1 | cut -d: -f1)
writeline=$(grep -n '^## Writing$' "$SKILL" | head -n1 | cut -d: -f1)

SLICE=""
if [ -n "$staleline" ] && [ -n "$execline" ] && [ "$staleline" -lt "$execline" ]; then
  SLICE=$(sed -n "${staleline},${execline}p" "$SKILL")
fi

# ---- the seven checks are in that slice --------------------------------------------------
# One probe per check, each the mechanical thing the check runs. m15 requires a check to cost one
# command with one answer, so every one of them has a literal to match on.
CHECKS="
the handoff's title date|24 hours
transcripts newer than the handoff|-newer HANDOFF.md
the branch|git branch --show-current
the tree|git status --short
the commit log|git log --oneline
open PRs|gh pr list --state open
the first ordered action's issue|gh issue view
"

missing=""
while IFS='|' read -r name probe; do
  [ -n "$name" ] || continue
  printf '%s\n' "$SLICE" | grep -qF -- "$probe" || missing="$missing
        $name (looked for: $probe)"
done <<CHECKLIST
$CHECKS
CHECKLIST

if [ -z "$missing" ]; then
  pass "all seven staleness checks are in $SKILL's read path"
else
  fail "all seven staleness checks are in $SKILL's read path" \
       "a check the skill does not carry is one a skill-only cold start never runs" \
       "missing:$missing"
fi

# ---- the three rules that travel with them ------------------------------------------------
# Each was written because a check misfired or was read as covering something it does not.
RULES="
the mtime-not-the-table rule|modification times
what the checks cannot see|saved no transcript
the two exceptions that are not staleness|not staleness
"
missingrule=""
while IFS='|' read -r name probe; do
  [ -n "$name" ] || continue
  printf '%s\n' "$SLICE" | grep -qiF -- "$probe" || missingrule="$missingrule
        $name (looked for: $probe)"
done <<RULELIST
$RULES
RULELIST

if [ -z "$missingrule" ]; then
  pass "the mtime rule, the blind spot and the two exceptions travel with them"
else
  fail "the mtime rule, the blind spot and the two exceptions travel with them" \
       "the checks without them misfire — the transcript one tripped on every cold start" \
       "missing:$missingrule"
fi

# ---- and the slice sits in the read path, ahead of the execute step -------------------------
if [ -z "$staleline" ] || [ -z "$execline" ] || [ -z "$writeline" ]; then
  fail "the checks sit in the read path, ahead of the execute step" \
       "a heading the ordering depends on is missing" \
       "### Check the handoff is still true: ${staleline:-absent}" \
       "### Then execute: ${execline:-absent}" \
       "## Writing: ${writeline:-absent}"
elif [ "$staleline" -lt "$execline" ] && [ "$execline" -lt "$writeline" ]; then
  pass "the checks sit in the read path, ahead of the execute step"
else
  fail "the checks sit in the read path, ahead of the execute step" \
       "the handoff is checked before it is acted on, so the block cannot follow the execute" \
       "step or drop below the write path" \
       "checks at line $staleline, execute at $execline, writing at $writeline"
fi

# ---- no command file still carries them -----------------------------------------------------
# Two copies of a rule drift. Each command keeps the typed-shortcut role and delegates.
dupe=""
for f in "$CMD" "$SHADOW"; do
  [ -f "$f" ] || continue
  while IFS='|' read -r name probe; do
    [ -n "$name" ] || continue
    grep -qF -- "$probe" "$f" && dupe="$dupe
        $f: $name (found: $probe)"
  done <<CHECKLIST
$CHECKS
CHECKLIST
done

if [ -z "$dupe" ]; then
  pass "no command file still carries the checks"
else
  fail "no command file still carries the checks" \
       "the content moved to the skill; a second copy is the split reopening" \
       "still here:$dupe"
fi

# ---- and each still delegates to the skill ---------------------------------------------------
nodelegate=""
for f in "$CMD" "$SHADOW"; do
  [ -f "$f" ] || continue
  grep -qE '\bhandoff\b' "$f" || nodelegate="$nodelegate $f"
done
if [ -z "$nodelegate" ]; then
  pass "every command file delegates to the handoff skill"
else
  fail "every command file delegates to the handoff skill" \
       "a shortcut that names no skill is a shortcut to nothing" \
       "names no skill:$nodelegate"
fi

# ---- every declared check names the path it runs on ------------------------------------------
# camp-reports.md makes `skips` the only way a declared-but-unrun check stays visible. This skill
# has two paths, so a check that runs on one of them and is declared bare makes both reports
# wrong at once — a `handoff-read` listing checks only a write performs, and a `handoff-written`
# listing the staleness checks. #267.
#
# A PATH IS ASSERTED, NOT THE PRESENCE OF AN ENTRY, AND THE CONDITION HAS TO OPEN WITH IT.
# `skips` conditions are ordinarily content conditions — camp-reports.md's own example is
# `placeholder-scan (only when a body was edited)` — and one of those satisfies "has an entry"
# while saying nothing about which path ran. Matching the words anywhere in the condition is the
# same hole one step further in: `(only when a body was edited on the read path)` would pass. So
# the condition must BEGIN `the read path` or `the write path`, which is the form every entry in
# the skill uses and the form its own section states.
#
# THE FRONTMATTER IS PARSED, NOT GREPPED, and the both-path line is read from the section that
# declares it. A name present somewhere in the file proves nothing about the declaration; an
# empty parse would pass vacuously; and an example of the format written higher up would
# otherwise become the declaration.
fm() { sed -n '2,/^---$/p' "$SKILL"; }

# Charset-filtered on the way in. A name is a hyphenated word, and anything else reaching a
# `case` pattern below would glob rather than compare.
declared="$(fm | sed -n 's/^checks: *\[\(.*\)\] *$/\1/p' | tr ',' '\n' | tr -d ' ' \
            | grep -E '^[a-z][a-z0-9-]*$')"

# Only the items under `skips:`. A key added after it would otherwise feed its own list items in
# as check names, and they would read as orphans.
skipentries="$(fm | awk '/^skips:/{f=1;next} f && /^[A-Za-z][A-Za-z0-9_-]*:/{f=0} f' \
               | grep -E '^[[:space:]]*-[[:space:]]')"

# One line, deliberately: the set is whatever is backticked on the `**Both-path checks:**` line,
# which is what the skill's own section says. Reading the paragraph instead would take every
# backticked word in it as a check name. A name that wraps to the next line reads as bare, which
# fails — safely, and with a message that blames the skill rather than this parser.
bothline="$(grep -n '^## Which path each check runs on$' "$SKILL" | head -n1 | cut -d: -f1)"
both=""
[ -n "$bothline" ] && both="$(sed -n "${bothline},\$p" "$SKILL" \
    | grep -m1 -- '\*\*Both-path checks:\*\*' | grep -o '`[a-z0-9-]\{1,\}`' | tr -d '`')"

skipped=""
nopath=""
while IFS= read -r entry; do
  [ -n "$entry" ] || continue
  nm="$(printf '%s' "$entry" | sed -n 's/^[[:space:]]*-[[:space:]]\{1,\}\([a-z][a-z0-9-]*\).*/\1/p')"
  [ -n "$nm" ] || continue
  skipped="$skipped $nm"
  cond="${entry#*(}"
  case "$cond" in
    "the read path"*|"the write path"*) ;;
    *) nopath="$nopath $nm" ;;
  esac
done <<ENTRIES
$skipentries
ENTRIES

ndeclared="$(printf '%s' "$declared" | grep -c '[a-z]')"
if [ "$ndeclared" -lt 1 ]; then
  fail "the skill's checks: declaration parses" \
       "read no names — a declaration this gate cannot read is one it cannot check" \
       "checks: is one bracketed line, and this is what is there:" \
       "$(grep -m1 '^checks:' "$SKILL" | head -c 120)"
else
  pass "the skill's checks: declaration parses — $ndeclared checks"

  haystack=" $(printf '%s ' $skipped)$(printf '%s ' $both)"
  bare=""
  for c in $declared; do
    case "$haystack" in *" $c "*) ;; *) bare="$bare $c" ;; esac
  done

  if [ -z "$bare" ] && [ -z "$nopath" ]; then
    pass "every declared check names the path it runs on"
  else
    fail "every declared check names the path it runs on" \
         "a check whose path is undeclared reports as having run on both, and it ran on one" \
         "no skips: entry and not declared both-path:${bare:- none}" \
         "a skips: condition not opening \"the read path\" or \"the write path\":${nopath:- none}"
  fi

  # And the reverse. A skips entry for a check the skill no longer declares is a report line for
  # a check that does not exist; a name declared both-path AND skipped is the declaration
  # contradicting itself, which no report can resolve.
  orphan=""
  contra=""
  hay2=" $(printf '%s ' $declared)"
  for s in $skipped $both; do
    case "$hay2" in *" $s "*) ;; *) orphan="$orphan $s" ;; esac
  done
  for b in $both; do
    case " $(printf '%s ' $skipped)" in *" $b "*) contra="$contra $b" ;; esac
  done
  if [ -z "$orphan" ] && [ -z "$contra" ]; then
    pass "the declaration does not disagree with itself"
  else
    fail "the declaration does not disagree with itself" \
         "a skip for a check that is not declared reports nothing that ran, and a name that is" \
         "both skipped and both-path is a state no report can render" \
         "skipped or both-path, but not in checks::${orphan:- none}" \
         "declared both-path and skipped:${contra:- none}"
  fi
fi

echo
echo "$PASSED passed, $FAILED failed"
[ "$FAILED" = "0" ] || exit 1
exit 0
