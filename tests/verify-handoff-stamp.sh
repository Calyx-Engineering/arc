#!/usr/bin/env bash
# verify-handoff-stamp.sh — the handoff header carries a date AND a time, re-stamped on every
# write.
#
#   tests/verify-handoff-stamp.sh            check this repository
#   tests/verify-handoff-stamp.sh selftest   run the fixture cases
#
# WHY. #153: the header carried a date and no time, so a cold start could not tell an hour-old
# handoff from a week-old one and treated both as current. Half of it was already true — the
# template's title placeholder held `YYYY-MM-DD HH:MM` and the skill said so once, at the very
# bottom, in the Template section. What was missing is the half that makes the stamp mean
# anything: that every write re-stamps it. A stamp written at creation and never moved is worse
# than none, because the read path's first staleness check reads exactly that line.
#
# THE INTERESTING CASE IS EXECUTABLE, NOT TEXTUAL. #153's "done when" asks for a case that
# asserts the stamp CHANGED after a rewrite, which no amount of grepping a skill can show. It is
# checkable because #152 landed first: `hooks/handoff-archive` leaves the prior version on disk,
# so the previous stamp and the current one both exist and can be compared. Case 7 below fires
# the real hook, rewrites the handoff without moving the stamp, and asserts this gate catches it.
#
# WHAT IT DOES AND DOES NOT ASSERT ABOUT THIS REPOSITORY'S OWN HANDOFF.md. It never checks that
# file's title FORMAT. A loop run's `HANDOFF.md` is written by tools/arc-loop.sh to carry an
# execution mode and says of itself that it is not a session handoff; requiring a session
# handoff's stamp of it would fail every loop run over a file that is not the thing being checked.
# So the format probes read the artifacts that TEACH the format — the template and the skill.
#
# Probe 5 does read it, but only to compare it against an archived prior copy, and only where one
# exists. Be precise about the consequence: if a handoff here carries a parseable stamp AND an
# archive of it exists AND the body changed with the stamp standing still, probe 5 fails — which
# is the defect, correctly reported, on whatever file it happens to be. Where either file has no
# parseable stamp the probe reports SKIP with its reason. It does not silently pass.
#
# WHAT IT CANNOT DO. It reads files, and compares two files where both exist. It does not invoke
# the skill; no gate here does — tests/verify-all.sh --list.
#
# REPORTS, NEVER BLOCKS beyond its exit code.

set -u

SELF="$(cd "$(dirname "$0")" && pwd)/$(basename "$0")"

SKILL_REL=skills/handoff/SKILL.md
TPL_REL=templates/handoff.md

# The stamp, wherever it sits in the title line. Date and time, separated by a space or a T.
STAMP_RE='[0-9]{4}-[0-9]{2}-[0-9]{2}[ T][0-9]{2}:[0-9]{2}'

stamp_of() {  # stamp_of <file> — prints the title's stamp, or nothing
  [ -f "$1" ] || return 1
  head -n 5 "$1" | grep -oE "$STAMP_RE" | head -n1
}

# ---- the shared rewrite check --------------------------------------------------------------
# Used by the live run and by the selftest, so the cases exercise the code the gate runs.
#
#   0  the stamp moved, or nothing was rewritten
#   1  the body changed and the stamp did not — #153's defect
#   2  nothing to compare
check_rewrite() {  # check_rewrite <prior-file> <current-file>
  local prior="$1" cur="$2" ps cs
  [ -f "$prior" ] && [ -f "$cur" ] || return 2
  ps="$(stamp_of "$prior")"; cs="$(stamp_of "$cur")"
  [ -n "$ps" ] && [ -n "$cs" ] || return 2
  # Identical files are not a rewrite; there is nothing for a stamp to have moved for.
  cmp -s "$prior" "$cur" && return 0
  [ "$ps" = "$cs" ] && return 1
  return 0
}

report() {
  local root="$1"
  local skill="$root/$SKILL_REL" tpl="$root/$TPL_REL"
  local passed=0 failed=0

  pass() { echo "  PASS  $1"; passed=$((passed + 1)); }
  fail() { echo "  FAIL  $1"; shift; for l in "$@"; do echo "        $l"; done; failed=$((failed + 1)); }
  skip() { echo "  SKIP  $1"; shift; for l in "$@"; do echo "        $l"; done; }

  echo "verify-handoff-stamp — a date, a time, and a stamp that moves"
  echo

  local f
  for f in "$skill" "$tpl"; do
    [ -f "$f" ] || { fail "$f exists" "no such file"; echo; echo "$passed passed, $failed failed"; return 1; }
  done

  # ---- 1 · the template's title placeholder carries both ---------------------------------
  if head -n 3 "$tpl" | grep -qF 'YYYY-MM-DD HH:MM'; then
    pass "the template's title placeholder carries a date and a time"
  else
    fail "the template's title placeholder carries a date and a time" \
         "a date alone cannot separate an hour-old handoff from a week-old one — #153" \
         "looked for YYYY-MM-DD HH:MM in the first 3 lines of $TPL_REL"
  fi

  # ---- 2 · and the rule sits in the WRITE path, not only in the template footnote ---------
  # It was already stated once, at the bottom of the skill, under Template. A rule about what
  # every write does has to be where writing is described, or a session writing the handoff
  # never reads it.
  local w_start w_end w_slice
  w_start=$(grep -n '^## Writing$' "$skill" | head -n1 | cut -d: -f1)
  if [ -n "$w_start" ]; then
    w_end=$(awk -v s="$w_start" 'NR>s && /^## /{print NR; exit}' "$skill")
    [ -n "$w_end" ] || w_end=$(wc -l < "$skill")
    w_slice=$(sed -n "${w_start},${w_end}p" "$skill")
  else
    w_slice=""
  fi

  if [ -z "$w_start" ]; then
    fail "the skill has a Writing section" "the write path is gone"
  elif printf '%s\n' "$w_slice" | grep -qiF 're-stamp'; then
    pass "the re-stamp rule is in the skill's write path"
  else
    fail "the re-stamp rule is in the skill's write path" \
         "stated only under Template, a session writing the handoff never reaches it — #153" \
         "looked for: re-stamp, between ## Writing and the next ## heading"
  fi

  # ---- 3 · and it says every write, not only creation ------------------------------------
  if printf '%s\n' "$w_slice" | grep -qiF 'every write'; then
    pass "the rule says every write, not only creation"
  else
    fail "the rule says every write, not only creation" \
         "a stamp set once and never moved is worse than none — the staleness check reads it" \
         "looked for: every write"
  fi

  # ---- 4 · the mechanical form, so it can be applied without judgement -------------------
  if printf '%s\n' "$w_slice" | grep -qiF 'if the body changed and the stamp did not'; then
    pass "the rule is stated mechanically"
  else
    fail "the rule is stated mechanically" \
         "'keep it current' is what the document said before and it did not bind" \
         "looked for: if the body changed and the stamp did not"
  fi

  # ---- 5 · the live rewrite check, where there is evidence of a rewrite -------------------
  # Deliberately not a check on this repository's own HANDOFF.md — see the header.
  local cur prior
  cur="$root/HANDOFF.md"
  prior="$(find "$root/.arc-work/archive" -type f -name 'HANDOFF.md' 2>/dev/null | sort | tail -n1)"
  if [ -z "$prior" ] || [ ! -f "$cur" ]; then
    skip "a rewrite moved the stamp" \
         "no archived prior handoff to compare against — nothing was rewritten here"
  else
    check_rewrite "$prior" "$cur"
    case $? in
      0) pass "the live handoff's stamp moved since the archived copy" ;;
      1) fail "the live handoff's stamp moved since the archived copy" \
              "the body changed and the title stamp did not — #153" \
              "prior: $prior" ;;
      2) skip "a rewrite moved the stamp" "one of the two files carries no parseable stamp" ;;
    esac
  fi

  echo
  echo "$passed passed, $failed failed"
  [ "$failed" = "0" ] || return 1
  return 0
}

# ---- the self-test ---------------------------------------------------------------------------
if [ "${1:-}" = "selftest" ]; then
  ROOT="$(cd "$(dirname "$SELF")/.." && pwd)"
  passed=0; failed=0
  WORK="$(mktemp -d)"; trap 'rm -rf "$WORK"' EXIT

  ok()  { echo "  PASS  $1"; passed=$((passed + 1)); }
  bad() { echo "  FAIL  $1"; shift; for l in "$@"; do echo "        $l"; done; failed=$((failed + 1)); }

  expect_rewrite() {  # expect_rewrite <name> <want-code> <prior-text> <current-text>
    local name="$1" want="$2" got
    printf '%s' "$3" > "$WORK/prior.md"
    printf '%s' "$4" > "$WORK/cur.md"
    check_rewrite "$WORK/prior.md" "$WORK/cur.md"; got=$?
    if [ "$got" = "$want" ]; then ok "$name"; else bad "$name" "wanted $want, got $got"; fi
  }

  echo "verify-handoff-stamp selftest — fixtures, and the real hook"
  echo

  # 1 — a stamp is read out of the title, date and time together.
  printf '# Handoff — 2026-09-07 14:32\n\nbody\n' > "$WORK/t.md"
  s=$(stamp_of "$WORK/t.md")
  if [ "$s" = "2026-09-07 14:32" ]; then ok "the stamp is read out of the title"
  else bad "the stamp is read out of the title" "got '$s'"; fi

  # 2 — a date with no time is not a stamp. This is #153's original defect, and a checker that
  #     accepted it would report the file as fine.
  printf '# Handoff — 2026-09-07\n\nbody\n' > "$WORK/d.md"
  s=$(stamp_of "$WORK/d.md")
  if [ -z "$s" ]; then ok "a date with no time is not accepted as a stamp"
  else bad "a date with no time is not accepted as a stamp" "got '$s'"; fi

  # 3 — the defect: the body changed and the stamp did not.
  expect_rewrite "a rewrite that did not move the stamp is caught" 1 \
    '# Handoff — 2026-09-07 09:00

first' \
    '# Handoff — 2026-09-07 09:00

rewritten, hours later'

  # 4 — the fix: the stamp moved with the body.
  expect_rewrite "a rewrite that moved the stamp passes" 0 \
    '# Handoff — 2026-09-07 09:00

first' \
    '# Handoff — 2026-09-07 16:40

rewritten, hours later'

  # 5 — an identical file is not a rewrite. Without this the gate would demand a new stamp for a
  #     write that changed nothing, and every no-op save would be a finding.
  expect_rewrite "an unchanged file is not a rewrite" 0 \
    '# Handoff — 2026-09-07 09:00

same' \
    '# Handoff — 2026-09-07 09:00

same'

  # 6 — nothing to compare is reported as such, never as a pass.
  expect_rewrite "an unstamped prior copy is not comparable" 2 \
    '# Handoff

no stamp' \
    '# Handoff — 2026-09-07 16:40

body'

  # 7 — end to end, through the real hook. This is #153's "done when": the prior version is on
  #     disk because #152 put it there, and the stamp is compared against it.
  repo="$WORK/live"; mkdir -p "$repo/src"
  git -C "$repo" init -q 2>/dev/null
  printf '.arc-work/\n' > "$repo/.gitignore"
  printf 'x\n' > "$repo/src/a.c"
  git -C "$repo" add -A 2>/dev/null
  git -C "$repo" -c user.email=v@x -c user.name=v commit -q -m init 2>/dev/null
  printf '# Handoff — 2026-09-07 09:00\n\nthe state the session was given\n' > "$repo/HANDOFF.md"

  KS="$WORK/home"; mkdir -p "$KS/.claude"
  printf '{"session_id":"stamp1","cwd":"%s","tool_name":"Write","tool_input":{"file_path":"%s"}}' \
    "$repo" "$repo/HANDOFF.md" | HOME="$KS" bash "$ROOT/hooks/handoff-archive" >/dev/null 2>&1

  # The rewrite a session would do — new body, stamp left alone.
  printf '# Handoff — 2026-09-07 09:00\n\nrewritten seven hours later\n' > "$repo/HANDOFF.md"
  prior="$(find "$repo/.arc-work/archive" -type f -name 'HANDOFF.md' 2>/dev/null | sort | tail -n1)"
  if [ -z "$prior" ]; then
    bad "the archived prior version is there to compare against" \
        "hooks/handoff-archive left nothing — #152's gate covers that, this case needs it"
  else
    ok "the archived prior version is there to compare against"
    check_rewrite "$prior" "$repo/HANDOFF.md"
    if [ $? = 1 ]; then
      ok "a real rewrite with an unmoved stamp is caught end to end"
    else
      bad "a real rewrite with an unmoved stamp is caught end to end" "check_rewrite did not report the defect"
    fi
  fi

  # 8 — and the same rewrite passes once the stamp moves.
  printf '# Handoff — 2026-09-07 16:40\n\nrewritten seven hours later\n' > "$repo/HANDOFF.md"
  check_rewrite "$prior" "$repo/HANDOFF.md"
  if [ $? = 0 ]; then ok "re-stamping the same rewrite clears it"
  else bad "re-stamping the same rewrite clears it" "still reported after the stamp moved"; fi

  # 9 to 12 — the live text probes, against fixture trees.
  mk() {
    local r="$WORK/$1"; mkdir -p "$r/skills/handoff" "$r/templates"
    printf '# Handoff — &lt;YYYY-MM-DD HH:MM&gt;\n' > "$r/templates/handoff.md"
    cat > "$r/skills/handoff/SKILL.md" <<'SKL'
# The handoff

## Writing

### When

**Every one of those moments re-stamps the title.** On every write, not only at creation.
The rule is mechanical: if the body changed and the stamp did not, the stamp is wrong.

## Template
SKL
    printf '%s' "$r"
  }
  run() { TERM=dumb bash "$SELF" --root "$1" 2>&1; }

  r=$(mk clean); out=$(run "$r"); st=$?
  if [ "$st" = 0 ]; then ok "the fixed form passes"; else bad "the fixed form passes" "$out"; fi

  r=$(mk nodate); printf '# Handoff — &lt;YYYY-MM-DD&gt;\n' > "$r/templates/handoff.md"
  out=$(run "$r"); st=$?
  if [ "$st" = 1 ] && [[ "$out" == *"carries a date and a time"* ]]; then
    ok "a template with a date and no time fails"
  else bad "a template with a date and no time fails" "exit $st"; fi

  r=$(mk footnote)
  cat > "$r/skills/handoff/SKILL.md" <<'SKL'
# The handoff

## Writing

### When

Write it at a break.

## Template

**The title carries a date and a time**, `YYYY-MM-DD HH:MM`.
SKL
  out=$(run "$r"); st=$?
  if [ "$st" = 1 ] && [[ "$out" == *"in the skill's write path"* ]]; then
    ok "the rule stated only under Template fails"
  else bad "the rule stated only under Template fails" "exit $st"; fi

  r=$(mk vague)
  cat > "$r/skills/handoff/SKILL.md" <<'SKL'
# The handoff

## Writing

### When

**Re-stamp the title** and keep it current on every write.

## Template
SKL
  out=$(run "$r"); st=$?
  if [ "$st" = 1 ] && [[ "$out" == *"stated mechanically"* ]]; then
    ok "a rule with no mechanical form fails"
  else bad "a rule with no mechanical form fails" "exit $st"; fi

  echo
  echo "$passed passed, $failed failed"
  [ "$failed" = "0" ] || exit 1
  exit 0
fi

if [ "${1:-}" = "--root" ]; then
  report "${2:-.}"
  exit $?
fi

report "$(cd "$(dirname "$0")/.." && pwd)"
exit $?
