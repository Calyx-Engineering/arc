#!/usr/bin/env bash
# verify-handoff-checks.sh — the staleness checks are reachable from the skill, not only the command.
#
#   tools/verify-handoff-checks.sh
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

cd "${HANDOFFCHK_ROOT:-$(dirname "$0")/..}" || exit 1

SKILL=skills/handoff/SKILL.md
CMD=commands/arc-next.md
SHADOW=.claude/commands/arc-next.md

PASSED=0
FAILED=0
pass() { echo "  PASS  $1"; PASSED=$((PASSED + 1)); }
fail() { echo "  FAIL  $1"; shift; for l in "$@"; do echo "        $l"; done; FAILED=$((FAILED + 1)); }

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

echo
echo "$PASSED passed, $FAILED failed"
[ "$FAILED" = "0" ] || exit 1
exit 0
