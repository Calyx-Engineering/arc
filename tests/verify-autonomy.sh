#!/usr/bin/env bash
# verify-autonomy.sh — the mode rule is stated once, and everything else points at it.
#
#   tests/verify-autonomy.sh
#
# WHY THIS EXISTS. Auto mode was declared in prose five times and never ran once. m40 read that
# as a read-frequency problem and put the permission beside every prohibition — four copies of
# one clause, deliberately. This script enforced that.
#
# THE INVARIANT IS INVERTED, 2026-09-06, #138. Five prohibitions each carrying an override is
# still five prohibitions, and the harness permits an outward-facing action only when it is
# durably authorized. arc stated the rule five times and had four merges denied. ROADZ states it
# once, in CLAUDE.md, with the override inside the sentence, and had none denied across twelve.
#
# So: skills/autonomy-set is the authority. CLAUDE.md may state the mode once, as a state, with
# the override in the same sentence. No other read-every-turn artifact restates the prohibition
# at all.
#
# SCOPE. This polices what is in a session's context every turn — CLAUDE.md, shipping skills,
# templates, hooks, agents, commands. It does not police docs/, which is opened deliberately
# rather than loaded. m14 and close-sequence still carry the old shape for that reason.
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

echo "verify-autonomy — the mode rule is stated once, everything else points"
echo

# ---- one authority, and no restatements anywhere it is read every turn ------------
# The failure being prevented is aggregate weight, so the check is a census, not a per-row read.
BANNED='never commit unasked|the user merges'
SCOPE="CLAUDE.md skills templates hooks agents commands"

strays="$(grep -rniE "$BANNED" $SCOPE 2>/dev/null           | grep -v '^skills/autonomy-set/'           | grep -v '^\.claude/' || true)"
if [ -z "$strays" ]; then
  pass "the prohibition is stated only by autonomy-set"
else
  fail "the prohibition is stated only by autonomy-set"        "each of these restates a rule skills/autonomy-set owns. Point at it instead — #138"        "$strays"
fi

# autonomy-set has to actually carry what everything else now points at.
if grep -qiE 'manual is the default' skills/autonomy-set/SKILL.md 2>/dev/null; then
  pass "autonomy-set states the rule it owns"
else
  fail "autonomy-set states the rule it owns"        "everything else points here. If the rule is not here it is nowhere"
fi

# CLAUDE.md states the mode as a state, once, with the override in the same sentence.
mode_lines="$(grep -c 'Execution mode is manual' CLAUDE.md 2>/dev/null)"
mode_lines="${mode_lines:-0}"
mode_row="$(grep -A1 'Execution mode is manual' CLAUDE.md 2>/dev/null | head -2 | tr '
' ' ')"
if [ "$mode_lines" = "1" ] && printf '%s' "$mode_row" | grep -qiE 'unless asked|autonomous'; then
  pass "CLAUDE.md states the mode once, with its override"
elif [ "$mode_lines" = "0" ]; then
  fail "CLAUDE.md states the mode once, with its override"        "the mode statement is gone. A session with no stated mode stops at the first action"
else
  fail "CLAUDE.md states the mode once, with its override"        "found $mode_lines statements, or the override is not in the same sentence"        "row: $(printf '%s' "$mode_row" | cut -c1-110)"
fi

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
