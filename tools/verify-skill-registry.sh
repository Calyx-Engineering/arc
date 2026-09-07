#!/usr/bin/env bash
# verify-skill-registry.sh — every shipping artifact is reachable from the product definition.
#
#   tools/verify-skill-registry.sh
#
# WHY THIS EXISTS. This is the half of tools/sync-local-skills.sh that outlived it. That script
# kept .claude/skills/ in step with skills/, and did one other job on the side: fail when a
# shipping skill has no row in the product definition's artifact table. #142 deleted the copies
# — Arc is installed in this repository now — and the sync went with them. The registry check
# did not, because a skill the definition does not name is one nothing traces to.
#
# It also reports a repo-local command, which is allowed but worth seeing.
#
# REPORTS, NEVER BLOCKS beyond its exit code. Same precedent as the other verifiers.

set -u

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

# ---- a repo-local command is allowed, and worth seeing --------------------------------
for f in .claude/commands/*.md; do
  [ -f "$f" ] || continue
  c=$(basename "$f")
  [ -f "commands/$c" ] && echo "  NOTE  .claude/commands/$c shadows commands/$c"
done

echo
echo "$PASSED passed, $FAILED failed"
[ "$FAILED" = "0" ] || exit 1
exit 0
