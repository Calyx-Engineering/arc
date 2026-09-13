#!/usr/bin/env bash
# verify-skill-method.sh — the skill-writing method is recorded, and its retirement is real.
#
#   tests/verify-skill-method.sh            check this repository
#   tests/verify-skill-method.sh selftest   fixtures only
#
# WHY THIS EXISTS. #275 settles which tool reviews a skill, which writes one, the four buckets a
# skill's rules route into, that the length limit is 500 lines and not 180, and what fires when a
# skill changes. Each is a decision, and a decision with no gate is a sentence in a document
# nobody re-reads. Eleven of
# thirteen skills sat over the old limit for weeks because the limit was written down and read by
# nothing — the same failure this file exists to not repeat about the method itself.
#
# WHAT IT CHECKS, AND WHAT IT DELIBERATELY DOES NOT. It checks that the decision record exists
# and still carries every decision, and that no live artifact contradicts the retirement by
# asserting a 180-line limit. It does NOT measure any skill's length: that is #276's
# `tools/verify-skill-length.sh`, and two gates reporting the same number is how they drift.
#
# THE RETIREMENT IS CHECKED WHERE IT BINDS, NOT EVERYWHERE. `docs/dev-log/` is history — the
# dev-logs for #42 and #73 record the 180 limit as what was true when they were written, and
# rewriting them would be falsifying the record. The scope below is the live tree: what a session
# reads before it edits a skill. `evals/` is excluded for the same reason plus one more — its
# fixture prose carries dollar amounts and capacitances that contain the digits.
#
# REPORTS, NEVER BLOCKS beyond its exit code. Same precedent as the other verifiers.

set -u

# Absolute, captured before the `cd` — the selftest re-runs this same file against fixture roots.
SELF="$(cd "$(dirname "$0")" && pwd)/$(basename "$0")"

DOC="docs/arc-work/04-dogfood/skill-method-decision.md"

# EACH PATTERN MATCHES THE DECISION, NOT THE LABEL IT SITS UNDER. An earlier draft anchored on
# `^\| \*\*Reviews a skill\*\*` and on the heading `^## 5 The keeper`, and got both halves
# backwards: every tool name in the document could be replaced with `TBD` and the gate still
# reported all decisions present, while renumbering a heading in a tidy-up failed it. So a pattern
# names the thing chosen — `writing-skills`, `skill-creator`, `hooks/skill-guard` — which cannot be
# reworded without changing what was decided, and no pattern depends on a section number.
#
# tab-separated: label <TAB> extended regex
DECISIONS="$(cat <<'EOF'
review tool	^\| \*\*Reviews a skill\*\*.*writing-skills
write tool	^\| \*\*Writes a skill\*\*.*skill-creator
the 500-line limit	\*\*500 lines\*\*
180 retired	180.*[Rr]etired|[Rr]etired.*180
the four buckets	^\| \*\*D\*\* \| \*\*Deviation\*\*
the keeper	hooks/skill-guard
EOF
)"

# ---- selftest ----------------------------------------------------------------------
# It sits above the checks because the checks run at top level. Each case builds a throwaway
# root and re-runs this file against it with SKILLMETHOD_ROOT, so what a case exercises is this
# gate's real exit code rather than a copy of its logic.
#
# EVERY CASE ASSERTS THE MESSAGE AS WELL AS THE CODE. Two checks print into one exit code, so a
# bare exit 1 does not say which fired — and a case can go green on the wrong failure. The
# `PASS`/`FAIL` prefix is what makes the assertion discriminating.
selftest() {
  local passed=0 failed=0 tmp
  tmp="$(mktemp -d)" || { echo "mktemp -d failed" >&2; return 2; }
  # Empty would make every fixture path absolute and the trap an `rm -rf ""`.
  [ -n "$tmp" ] || { echo "mktemp -d returned nothing" >&2; return 2; }
  # Expanded now, not at EXIT: `tmp` is local and unset by the time the trap runs. %q rather
  # than literal quotes, so a TMPDIR holding a quote cannot break the trap open.
  trap "rm -rf $(printf %q "$tmp")" EXIT

  # A COMPLETE DECISION RECORD, and every line of it is load-bearing. The fixture names the real
  # tools because the patterns match the tools, not the labels — a fixture saying `something` would
  # go red and take every case with it.
  good_doc() {
    cat <<'EOF'
# The skill-writing method

## 1 The choice

| | Tool |
|---|---|
| **Reviews a skill** | superpowers `writing-skills`, applied statically |
| **Writes a skill** | `skill-creator` |

## 2 Length

**500 lines** of body. The 180-line working limit is retired.

## 4 The buckets

| | Bucket | Where it goes |
|---|---|---|
| **D** | **Deviation** — flagged and kept anyway | Recorded once |

## 5 The keeper

`hooks/skill-guard`, on the write.
EOF
  }

  # assert_case <wanted-exit> <name> <root> <text> <text-or-empty>
  assert_case() {
    local want="$1" name="$2" root="$3" t1="$4" t2="${5:-}" out code
    out="$(SKILLMETHOD_ROOT="$root" bash "$SELF" 2>&1)"; code=$?
    local why=""
    [ "$code" = "$want" ] || why="exit $code, wanted $want"
    case "$out" in *"$t1"*) ;; *) why="${why:+$why; }missing: $t1" ;; esac
    if [ -n "$t2" ]; then
      case "$out" in *"$t2"*) ;; *) why="${why:+$why; }missing: $t2" ;; esac
    fi
    if [ -z "$why" ]; then
      passed=$((passed + 1)); echo "  ok    $name"
    else
      failed=$((failed + 1)); echo "  FAIL  $name — $why"; echo "$out" | sed 's/^/          /'
    fi
  }

  # build_root <dir> — a tree that passes everything, for a case to then break
  build_root() {
    local r="$1"
    mkdir -p "$r/docs/arc-work/04-dogfood" "$r/skills/example" "$r/docs/dev-log"
    good_doc > "$r/$DOC"
    printf 'a skill body\n' > "$r/skills/example/SKILL.md"
    printf 'the 180 line limit was what we had then\n' > "$r/docs/dev-log/issue-1-old.md"
  }

  local r

  r="$tmp/clean"; build_root "$r"
  assert_case 0 "a complete record, and no live 180" "$r" \
    "PASS  the decision record" "PASS  180 retired"

  r="$tmp/nodoc"; build_root "$r"; rm -f "$r/$DOC"
  assert_case 1 "the record is missing" "$r" \
    "FAIL  the decision record"

  r="$tmp/nokeeper"; build_root "$r"; grep -v 'hooks/skill-guard' "$r/$DOC" > "$r/d" && mv "$r/d" "$r/$DOC"
  assert_case 1 "a decision dropped out of the record" "$r" \
    "FAIL  the decision record" "the keeper"

  # THE INVERSION THIS GATE WAS WRITTEN WRONG FOR, BOTH HALVES. Anchored on labels and a heading
  # number, it passed a record whose every tool name had been replaced with TBD, and failed one
  # whose sections had merely been renumbered. Both are cases now.
  r="$tmp/gutted"; build_root "$r"
  sed -e 's/superpowers `writing-skills`, applied statically/TBD/' \
      -e 's/`skill-creator`/TBD/' \
      -e 's/`hooks\/skill-guard`, on the write./TBD/' "$r/$DOC" > "$r/d" && mv "$r/d" "$r/$DOC"
  assert_case 1 "the labels survive, the decisions are gutted" "$r" \
    "FAIL  the decision record" "review tool, write tool, the keeper"

  r="$tmp/renumbered"; build_root "$r"
  sed -e 's/^## 1 The choice/## 2 The choice/' -e 's/^## 5 The keeper/## 7 The keeper/' \
      "$r/$DOC" > "$r/d" && mv "$r/d" "$r/$DOC"
  assert_case 0 "a tidy-up renumbered the sections" "$r" \
    "PASS  the decision record"

  # THE WORD ALONE IS NOT THE DECISION. `retired` unanchored passes on any sentence carrying it,
  # including one retiring something else, so the pattern requires 180 and `retired` on ONE LINE.
  # That is weaker than it sounds — it does not check that 180 is what is being retired, only that
  # the sentence holds both. It catches a record that dropped the claim, not one that inverted it.
  r="$tmp/retired-elsewhere"; build_root "$r"
  sed 's/^\*\*500 lines\*\* of body\. The 180-line working limit is retired\./**500 lines** of body. The word budget is retired./' \
    "$r/$DOC" > "$r/d" && mv "$r/d" "$r/$DOC"
  assert_case 1 "retired, but not about 180" "$r" \
    "FAIL  the decision record" "180 retired"

  # THE CASE THE GATE IS FOR. The record can say 180 is retired while a skill still asserts it.
  r="$tmp/live180"; build_root "$r"
  printf 'Keep this under 180 lines.\n' >> "$r/skills/example/SKILL.md"
  assert_case 1 "a live skill still asserts 180 lines" "$r" \
    "FAIL  180 retired" "skills/example/SKILL.md"

  # THE WIDENED TARGETS ARE EXERCISED, not just listed. `agents/`, `commands/`, `reference/` and
  # `docs/suite-architecture/` hold no 180 today, so dropping one back out of the target list would
  # leave the live run green and the loss invisible. This case plants the claim in `agents/`.
  r="$tmp/agents180"; build_root "$r"
  mkdir -p "$r/agents"
  printf 'Keep the brief under 180 lines.\n' > "$r/agents/example.md"
  assert_case 1 "a live agent definition asserts 180 lines" "$r" \
    "FAIL  180 retired" "agents/example.md"

  # 1800, 180 ms and PR #180 are not the limit. A gate that trips on them gets muted.
  r="$tmp/nearmiss"; build_root "$r"
  mkdir -p "$r/tools"
  printf 'TTL=1800  # lines below\nthe rail sags for 180 ms, lines of it\nreal firing on PR #180, lines checked\n' > "$r/tools/x.sh"
  assert_case 0 "1800, 180 ms and PR #180 are not the limit" "$r" \
    "PASS  180 retired"

  # History is not a contradiction. The dev-log fixture above says 180 in every case; this one
  # says so loudly, to pin that the exclusion is the scope and not an accident of wording.
  r="$tmp/history"; build_root "$r"
  printf 'the 180 lines limit\n' > "$r/docs/dev-log/issue-2-old.md"
  assert_case 0 "a dev-log recording the old limit is history" "$r" \
    "PASS  180 retired"

  echo
  echo "selftest: $passed passed, $failed failed"
  [ "$failed" = "0" ]
}

if [ "${1:-}" = "selftest" ]; then
  selftest
  exit $?
fi

[ "$#" = "0" ] || { sed -n '2,24p' "$0"; exit 2; }

cd "${SKILLMETHOD_ROOT:-$(dirname "$0")/..}" || exit 1

RC=0

# ---- 1 the decision record carries all four decisions -------------------------------
if [ ! -f "$DOC" ]; then
  echo "FAIL  the decision record — $DOC does not exist"
  RC=1
else
  MISSING=""
  # Counted from the table, not written as a literal — a pattern added without touching the
  # message is how "all four decisions" outlived the fourth being joined by a fifth.
  WANTED="$(printf '%s
' "$DECISIONS" | grep -c .)"
  while IFS="$(printf '\t')" read -r label pattern; do
    [ -n "${label:-}" ] || continue
    grep -Eq -- "$pattern" "$DOC" || MISSING="${MISSING:+$MISSING, }$label"
  done <<EOF
$DECISIONS
EOF
  if [ -n "$MISSING" ]; then
    echo "FAIL  the decision record — $DOC does not state: $MISSING"
    RC=1
  else
    echo "PASS  the decision record — $DOC states all $WANTED decisions"
  fi
fi

# ---- 2 no live artifact asserts a 180-line limit -------------------------------------
# 180 HAS TO BE ADJACENT TO THE WORD. Requiring only that both appear on the line trips on
# `the rail sags for 180 ms, lines of it` and on `real firing on PR #180` in a comment that
# happens to say lines — both real strings in this repository. So: `180` then at most a space or
# hyphen then `line`, or `line` then up to twelve non-digits then `180`. That second half is what
# catches `a line limit of 180`, which the first half cannot see.
#
# The digit boundary on both sides of 180 keeps 1800 and 18000 out — `tools/arc-claim.sh` is full
# of 1800-second TTLs.
PAT='(^|[^0-9])180[ -]?lines?|lines?[^0-9]{0,12}(^|[^0-9])180([^0-9]|$)'

# TWO FILES ARE EXCLUDED, AND NAMED RATHER THAN PATTERNED. The decision record and this gate are
# where the retirement is *written*: both have to say 180 in order to retire it, and a gate that
# cannot survive its own vocabulary gets muted rather than fixed. The record is not unchecked —
# check 1 above is what asserts what it says about the limit.
HITS=""
for target in CLAUDE.md README.md skills agents commands reference templates hooks tools tests \
              docs/product-architecture docs/suite-architecture docs/arc-log docs/arc-work; do
  [ -e "$target" ] || continue
  while IFS= read -r hit; do
    [ -n "$hit" ] && HITS="${HITS:+$HITS
}$hit"
  done <<EOF
$(grep -rEn -- "$PAT" "$target" 2>/dev/null \
    | grep -v "^$DOC:" \
    | grep -v '^tests/verify-skill-method\.sh:' \
    | grep -v '^[^:]*/hook-cases/' || true)
EOF
done

if [ -n "$HITS" ]; then
  echo "FAIL  180 retired — a live artifact still ties a limit to 180:"
  printf '%s\n' "$HITS" | sed 's/^/        /'
  RC=1
else
  echo "PASS  180 retired — no live artifact ties a skill limit to 180"
fi

exit "$RC"
