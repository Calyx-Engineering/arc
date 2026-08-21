#!/usr/bin/env bash
# verify-autonomy.sh — every prohibition auto mode overrides states its auto arm beside it.
#
#   tools/verify-autonomy.sh
#
# WHY THIS EXISTS. Auto mode was declared in prose five times and never ran once. The cause was
# a read-frequency asymmetry, not a missing document: the repo's CLAUDE.md and an always-on
# work-watch restate "never commit unasked" every turn, while the arc-log's execution section
# is read once at session start. The fresher instruction wins, and it was never the permission.
#
# m40's fix is to put the permission in the same row as each prohibition — four copies of one
# clause, deliberately. This script is what keeps the four honest. It is the reason duplicating
# them is acceptable rather than reckless.
#
# WHAT IT CANNOT DO. Nothing in this repository runs a skill, so no check here proves the agent
# behaves. It tests the half that is decidable from text — which is the half that actually
# failed, five times.
#
# REPORTS, NEVER BLOCKS. Same precedent as verify-hook.sh. Exit 1 marks a finding to read.

set -u

cd "${AUTONOMY_ROOT:-$(dirname "$0")/..}" || exit 1

PASSED=0
FAILED=0

pass() { echo "  PASS  $1"; PASSED=$((PASSED + 1)); }
fail() { echo "  FAIL  $1"; shift; for l in "$@"; do echo "        $l"; done; FAILED=$((FAILED + 1)); }

# A prohibition is only safe to keep once its row also says what auto does instead. Matching is
# per-line: the clause must be in the SAME row, because a clause a paragraph away is a
# cross-reference wearing the costume of one.
check_row() {
  local label="$1" file="$2" needle="$3"
  if [ ! -f "$file" ]; then
    fail "$label" "no such file: $file"
    return
  fi
  local row
  row="$(grep -F -- "$needle" "$file" | head -n1)"
  if [ -z "$row" ]; then
    fail "$label" "the rule is gone from $file — if it moved, this check must move with it" \
                  "looked for: $needle"
    return
  fi
  if printf '%s' "$row" | grep -qiE 'autonomous|auto mode|in auto\b'; then
    pass "$label"
  else
    fail "$label" "$file states the rule with no auto arm in the same row." \
                  "A cross-reference elsewhere in the file does not count — see m40 §9." \
                  "row: $(printf '%s' "$row" | cut -c1-100)"
  fi
}

echo "verify-autonomy — the permission sits beside the prohibition"
echo

# ---- the four artifacts m40 §9 names ---------------------------------------------
check_row "CLAUDE.md scopes never-commit-unasked to manual" \
  CLAUDE.md "Never commit unasked"

check_row "work-watch's mechanical rule names auto" \
  skills/work-watch/SKILL.md "Never commit unasked"

check_row "m14 scopes the standing instruction" \
  docs/product-architecture/mechanisms/m14-commit-rhythm.md "Standing instruction"

check_row "m14's proposed-shape row scopes it too" \
  docs/product-architecture/mechanisms/m14-commit-rhythm.md "Never-commit-unasked"

check_row "close-sequence step 8 is mode-dependent" \
  docs/product-architecture/close-sequence.md "| 8 |"

check_row "close-sequence step 9 is mode-dependent" \
  docs/product-architecture/close-sequence.md "| 9 |"

# ---- the spec and its skill both exist -------------------------------------------
# A spec with no artifact is what shipped five times. Both, or neither is exercised.
for f in docs/product-architecture/mechanisms/m40-autonomy-switch.md skills/autonomy-set/SKILL.md; do
  if [ -f "$f" ]; then
    pass "exists: $f"
  else
    fail "exists: $f" "m40 without its skill is the document-only failure, repeated"
  fi
done

# ---- the switch names its state, and only one place holds it ---------------------
if grep -q 'Execution mode' skills/autonomy-set/SKILL.md 2>/dev/null; then
  pass "the skill names where the mode lives"
else
  fail "the skill names where the mode lives" \
       "autonomy-set must point at HANDOFF.md's Execution mode row, or the mode is memory again"
fi

# A second store is the failure m40 §3 rejects by name. Catch one being added.
others="$(grep -rlE '^\s*(mode|MODE)\s*[:=]' .claude/arc/ 2>/dev/null || true)"
if [ -z "$others" ]; then
  pass "no second store for the mode"
else
  fail "no second store for the mode" \
       "the mode lives in HANDOFF.md's Execution mode row and nowhere else — m40 §3" \
       "$others"
fi

# ---- the template teaches suspension ---------------------------------------------
# Two states cannot express a conversation, and the template is what a fresh repo copies.
if grep -qi 'suspend' templates/handoff.md 2>/dev/null; then
  pass "the handoff template carries the suspended state"
else
  fail "the handoff template carries the suspended state" \
       "without it a fresh repo gets a two-state switch, which cancels auto on the first question"
fi

# ---- the boundary is stated, not implied -----------------------------------------
# Conflating "the mode failed" with "the harness refused" is what three attempts were built on.
if grep -qiE 'harness|classifier' docs/product-architecture/mechanisms/m40-autonomy-switch.md 2>/dev/null &&
   grep -qiE 'harness|classifier' skills/autonomy-set/SKILL.md 2>/dev/null; then
  pass "both say what the switch cannot do"
else
  fail "both say what the switch cannot do" \
       "m40 §7 and the skill must both state that auto does not change what the harness permits"
fi

# ---- the registry agrees -----------------------------------------------------------
if grep -q '| m40 |' docs/product-architecture/README.md 2>/dev/null &&
   grep '| m40 |' docs/product-architecture/README.md | grep -q 'm40-autonomy-switch.md'; then
  pass "the registry links m40's spec"
else
  fail "the registry links m40's spec" \
       "the m40 row still shows a dash, which is what #73 was filed about"
fi

echo
echo "$PASSED passed, $FAILED failed"
[ "$FAILED" = "0" ] || exit 1
exit 0
