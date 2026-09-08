#!/usr/bin/env bash
# verify-handoff-rationale.sh — the handoff carries the constraint behind a decision, not only
# the decision.
#
#   tools/verify-handoff-rationale.sh            check this repository
#   tools/verify-handoff-rationale.sh selftest   run the fixture cases
#
# WHY THIS EXISTS. #151: a populated, correct, freshly-read handoff does not bind. The session
# reports status correctly and then does the wrong work. The baseline
# (docs/arc-work/04-dogfood/handoff-baseline.md) found the rationale absent from the document in
# three of the five bad openings, and its opening 4 is the sharpest case: the handoff was CORRECT
# and the session still inverted its step order, because an order with no reason gets re-derived
# from circumstances that look different.
#
# THE DEFECT WAS WRITTEN DOWN. Both artifacts explicitly forbade the thing that was missing —
# `templates/handoff.md` said "**What** was decided, not why — the why is in the dev-log", and
# `skills/handoff/SKILL.md` routed "Why a decision was made" to the dev-log. The strip was not an
# omission by a tired session; it was the rule being followed.
#
# THE DISCRIMINATOR IS THE POINT, NOT THE EXHORTATION. "Include the why" is what every previous
# attempt said, and it does not separate the disposable from the load-bearing — which is #151's
# whole hypothesis. What separates them is a form: a load-bearing reason can be written as a fact
# that would have to CHANGE for the decision to change. "We tried X, then Y" cannot be. So the
# probes below look for that form, not for the word "why".
#
# WHAT IT CANNOT DO. It reads files for content. It does not invoke the skill, and no gate in
# this repository does — tools/verify-all.sh --list. A rule found here is present, not proven to
# be followed. Whether the change moved the score is
# docs/arc-work/04-dogfood/handoff-rationale.md, and re-running an opening against the changed
# format needs #181.
#
# REPORTS, NEVER BLOCKS beyond its exit code. Same precedent as every verifier here.

set -u

SELF="$(cd "$(dirname "$0")" && pwd)/$(basename "$0")"

SKILL_REL=skills/handoff/SKILL.md
HANDOFF_REL=templates/handoff.md
DEVLOG_REL=templates/dev-log.md

report() {
  local root="$1"
  local skill="$root/$SKILL_REL" handoff="$root/$HANDOFF_REL" devlog="$root/$DEVLOG_REL"
  local passed=0 failed=0

  pass() { echo "  PASS  $1"; passed=$((passed + 1)); }
  fail() { echo "  FAIL  $1"; shift; for l in "$@"; do echo "        $l"; done; failed=$((failed + 1)); }

  echo "verify-handoff-rationale — the constraint travels with the decision"
  echo

  local f
  for f in "$skill" "$handoff" "$devlog"; do
    [ -f "$f" ] || { fail "$f exists" "no such file"; echo; echo "$passed passed, $failed failed"; return 1; }
  done

  # ---- 1 · the handoff's decisions section carries the constraint behind each decision ------
  # Sliced, not searched whole: the phrase anywhere in the file would pass for a template whose
  # decisions table had drifted back to holding only the decision.
  local lb_start lb_end lb_slice
  lb_start=$(grep -n '^## Load-bearing decisions' "$handoff" | head -n1 | cut -d: -f1)
  if [ -n "$lb_start" ]; then
    lb_end=$(awk -v s="$lb_start" 'NR>s && /^## /{print NR; exit}' "$handoff")
    [ -n "$lb_end" ] || lb_end=$(wc -l < "$handoff")
    lb_slice=$(sed -n "${lb_start},${lb_end}p" "$handoff")
  else
    lb_slice=""
  fi

  if [ -z "$lb_start" ]; then
    fail "the handoff template has a Load-bearing decisions section" \
         "the section the constraint travels in is gone"
  elif printf '%s\n' "$lb_slice" | grep -qF 'What would have to change'; then
    pass "the decisions table asks what would have to change for the decision to change"
  else
    fail "the decisions table asks what would have to change for the decision to change" \
         "a decision with no falsifiable constraint is re-derived by the next session — #151" \
         "looked for: What would have to change"
  fi

  # ---- 2 · and no longer forbids the reason outright ---------------------------------------
  # This is the exact sentence #151 names. It is checked separately from probe 1 because a
  # template can gain the column and keep the rule, which is how the two would fight.
  if printf '%s\n' "$lb_slice" | grep -qF 'not why'; then
    fail "the handoff template no longer forbids the reason" \
         "the section held both the new column and the old prohibition" \
         "still present: 'not why'"
  else
    pass "the handoff template no longer forbids the reason"
  fi

  # ---- 3 · the skill routes the NARRATIVE away, not the constraint --------------------------
  local nd_start nd_end nd_slice
  nd_start=$(grep -n '^### What does NOT go in it' "$skill" | head -n1 | cut -d: -f1)
  if [ -n "$nd_start" ]; then
    nd_end=$(awk -v s="$nd_start" 'NR>s && /^## /{print NR; exit}' "$skill")
    [ -n "$nd_end" ] || nd_end=$(wc -l < "$skill")
    nd_slice=$(sed -n "${nd_start},${nd_end}p" "$skill")
  else
    nd_slice=""
  fi

  if [ -z "$nd_start" ]; then
    fail "the skill has a 'What does NOT go in it' section" "the routing table is gone"
  elif printf '%s\n' "$nd_slice" | grep -qF 'Why a decision was made'; then
    fail "the skill sends the narrative to the dev-log, not the constraint" \
         "'Why a decision was made | The dev-log' is the rule that stripped the constraint" \
         "the row that must change is still there — #151"
  elif printf '%s\n' "$nd_slice" | grep -qiF 'narrative of how'; then
    pass "the skill sends the narrative to the dev-log, not the constraint"
  else
    fail "the skill sends the narrative to the dev-log, not the constraint" \
         "the row has to name what it excludes; excluding the reason wholesale is the defect" \
         "looked for: narrative of how"
  fi

  # ---- 4 · the approach-replacement trigger, in the read path ------------------------------
  # Baseline openings 4 and 7: the unit was accepted, the approach inside it was swapped, and
  # nothing fired. The trigger has to sit where the accepted approach is read, so its position
  # is checked as well as its presence.
  local trig_line write_line exec_line
  trig_line=$(grep -n '^### When you are about to do it a different way' "$skill" | head -n1 | cut -d: -f1)
  exec_line=$(grep -n '^### Then execute$' "$skill" | head -n1 | cut -d: -f1)
  write_line=$(grep -n '^## Writing$' "$skill" | head -n1 | cut -d: -f1)

  if [ -z "$trig_line" ]; then
    fail "the skill carries the approach-replacement trigger" \
         "an approach swapped inside an accepted unit fires nothing — baseline openings 4 and 7" \
         "looked for heading: ### When you are about to do it a different way"
  elif [ -z "$exec_line" ] || [ -z "$write_line" ]; then
    fail "the skill carries the approach-replacement trigger" \
         "a heading its position depends on is missing" \
         "### Then execute: ${exec_line:-absent}   ## Writing: ${write_line:-absent}"
  elif [ "$exec_line" -lt "$trig_line" ] && [ "$trig_line" -lt "$write_line" ]; then
    pass "the approach-replacement trigger sits in the read path, after execute and above the write"
  else
    fail "the approach-replacement trigger sits in the read path, after execute and above the write" \
         "a trigger below the write path is one a cold start reaches after it has already acted" \
         "trigger at $trig_line, execute at $exec_line, writing at $write_line"
  fi

  # ---- 5 · and it tests the condition rather than announcing the swap -----------------------
  # Baseline opening 7 stated its rationale correctly, unprompted, and still built the wrong rig.
  # Saying it is not enough; the trigger has to send the session back to the fact that would have
  # had to change.
  local trig_end trig_slice
  if [ -n "$trig_line" ]; then
    trig_end=$(awk -v s="$trig_line" 'NR>s && /^###? /{print NR; exit}' "$skill")
    [ -n "$trig_end" ] || trig_end=$(wc -l < "$skill")
    trig_slice=$(sed -n "${trig_line},${trig_end}p" "$skill")
    if printf '%s\n' "$trig_slice" | grep -qF 'What would have to change'; then
      pass "the trigger sends the session back to the constraint, not only to an announcement"
    else
      fail "the trigger sends the session back to the constraint, not only to an announcement" \
           "baseline opening 7 stated its reason unprompted and still built the wrong rig" \
           "looked for: What would have to change"
    fi
  fi

  # ---- 6 · out of scope carries its reason --------------------------------------------------
  local oos
  oos=$(grep -n '\*\*Out of scope\*\*' "$devlog" | head -n1 | cut -d: -f1)
  if [ -z "$oos" ]; then
    fail "the dev-log template has an Out of scope row" "the row is gone"
  elif sed -n "${oos}p" "$devlog" | grep -qiF 'why'; then
    pass "out of scope says why each exclusion is out"
  else
    fail "out of scope says why each exclusion is out" \
         "a bare list of exclusions is re-litigated — the next session cannot see the reason" \
         "row $oos of $DEVLOG_REL"
  fi

  echo
  echo "$passed passed, $failed failed"
  [ "$failed" = "0" ] || return 1
  return 0
}

# ---- the self-test ---------------------------------------------------------------------------
# Fixture trees under mktemp, never this repository's own. A live run alone cannot show a check
# can fail, because a live tree that passes exercises only one branch of each probe.
if [ "${1:-}" = "selftest" ]; then
  passed=0; failed=0
  WORK="$(mktemp -d)"; trap 'rm -rf "$WORK"' EXIT

  write_handoff() {  # write_handoff <root> — the fixed form
    cat > "$1/templates/handoff.md" <<'TPL'
# Handoff

## Load-bearing decisions — do not re-litigate

| Decision | What would have to change to re-open it |
|---|---|
| <decision> | <the fact that forces it> |

## Open threads
TPL
  }

  write_skill() {  # write_skill <root> — the fixed form
    cat > "$1/skills/handoff/SKILL.md" <<'SKL'
# The handoff

### Then execute

Execute the rows.

### When you are about to do it a different way

Check it against What would have to change.

## Writing

### What does NOT go in it

| Not here | Where |
|---|---|
| The narrative of how a decision was reached | The dev-log |

## Template
SKL
  }

  make_tree() {  # make_tree <name> — a miniature tree carrying the fixed form
    local root="$WORK/$1"
    mkdir -p "$root/skills/handoff" "$root/templates"
    write_handoff "$root"
    write_skill "$root"
    printf '| **Out of scope** | What this must not grow into, and why each exclusion is out |\n' \
      > "$root/templates/dev-log.md"
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

  echo "verify-handoff-rationale selftest — fixture trees, never the live tree"
  echo

  # 1 — the fixed form passes. Every later case is this tree with one thing broken.
  root=$(make_tree clean); out=$(run "$root"); status=$?
  case_is "the fixed form passes" 0 "6 passed, 0 failed" "$status" "$out"

  # 2 — the decisions table holding only the decision. The state #151 was filed against.
  root=$(make_tree nocolumn)
  cat > "$root/templates/handoff.md" <<'TPL'
# Handoff

## Load-bearing decisions — do not re-litigate

| | |
|---|---|
| <decision> | <the constraint it imposes> |

## Open threads
TPL
  out=$(run "$root"); status=$?
  case_is "a decisions table with no constraint column fails" 1 "what would have to change" "$status" "$out"

  # 3 — the column added and the old prohibition kept. Probe 2 exists for exactly this: the two
  #     would fight, and a session following the prose would strip what the column asks for.
  root=$(make_tree bothrules)
  cat > "$root/templates/handoff.md" <<'TPL'
# Handoff

## Load-bearing decisions — do not re-litigate

**What** was decided, not why — the why is in the dev-log.

| Decision | What would have to change to re-open it |
|---|---|
| <decision> | <the fact> |

## Open threads
TPL
  out=$(run "$root"); status=$?
  case_is "the new column with the old prohibition still fails" 1 "no longer forbids the reason" "$status" "$out"

  # 4 — the skill's routing row unchanged. The rule that did the stripping.
  root=$(make_tree oldrouting)
  cat > "$root/skills/handoff/SKILL.md" <<'SKL'
# The handoff

### Then execute

Execute the rows.

### When you are about to do it a different way

Check it against What would have to change.

## Writing

### What does NOT go in it

| Not here | Where |
|---|---|
| Why a decision was made | The dev-log. The handoff says *what was decided*, not the reasoning |

## Template
SKL
  out=$(run "$root"); status=$?
  case_is "the skill still routing the reason to the dev-log fails" 1 "is the rule that stripped the constraint" "$status" "$out"

  # 5 — no trigger at all.
  root=$(make_tree notrigger)
  cat > "$root/skills/handoff/SKILL.md" <<'SKL'
# The handoff

### Then execute

Execute the rows.

## Writing

### What does NOT go in it

| Not here | Where |
|---|---|
| The narrative of how a decision was reached | The dev-log |

## Template
SKL
  out=$(run "$root"); status=$?
  case_is "a missing approach-replacement trigger fails" 1 "carries the approach-replacement trigger" "$status" "$out"

  # 6 — the trigger present but below the write path, where a cold start reaches it after it has
  #     already acted. Presence anywhere in the file would have passed this.
  root=$(make_tree triggerlate)
  cat > "$root/skills/handoff/SKILL.md" <<'SKL'
# The handoff

### Then execute

Execute the rows.

## Writing

### What does NOT go in it

| Not here | Where |
|---|---|
| The narrative of how a decision was reached | The dev-log |

### When you are about to do it a different way

Check it against What would have to change.

## Template
SKL
  out=$(run "$root"); status=$?
  case_is "a trigger below the write path fails" 1 "sits in the read path" "$status" "$out"

  # 7 — the trigger announcing the swap without testing the condition. Baseline opening 7 is
  #     this case: the reason was stated correctly, unprompted, and the wrong rig was built.
  root=$(make_tree triggerannounce)
  cat > "$root/skills/handoff/SKILL.md" <<'SKL'
# The handoff

### Then execute

Execute the rows.

### When you are about to do it a different way

Say so before starting.

## Writing

### What does NOT go in it

| Not here | Where |
|---|---|
| The narrative of how a decision was reached | The dev-log |

## Template
SKL
  out=$(run "$root"); status=$?
  case_is "a trigger that only announces fails" 1 "back to the constraint" "$status" "$out"

  # 8 — out of scope with no reason.
  root=$(make_tree noreason)
  printf '| **Out of scope** | What refinement must not grow this into |\n' > "$root/templates/dev-log.md"
  out=$(run "$root"); status=$?
  case_is "out of scope with no reason fails" 1 "says why each exclusion is out" "$status" "$out"

  # 9 — a missing artifact is reported, not skipped into a pass.
  root=$(make_tree missing); rm -f "$root/templates/dev-log.md"
  out=$(run "$root"); status=$?
  case_is "a missing template is reported" 1 "no such file" "$status" "$out"

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
