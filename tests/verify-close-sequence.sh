#!/usr/bin/env bash
# verify-close-sequence.sh — the close sequence's step count is the same everywhere.
#
#   tests/verify-close-sequence.sh
#   tests/verify-close-sequence.sh selftest
#
# WHY THIS EXISTS. close-sequence.md's value is invariance: two sessions closing two issues
# produce the same steps in the same order. The count is therefore load-bearing, and it is
# written down in more than one place — the heading, the opening paragraph, and once in every
# live artifact that states it, whether or not it cites the file by name. #140 adds a step. The
# failure this guards against is the one #140 is about: an edit lands correctly in one place
# while other places keep describing the old behaviour, and nothing executable disagrees.
#
# WHAT COUNTS AS A STEP. A row of the Closing table whose number cell is bare digits. `4b` is a
# sub-step of 4 and is not counted — that is what the letter means.
#
# FOUR RECOGNISED FORMS, not a scan for any number beside the word "steps". A count claim reads
# `## Closing — ten steps`, `**Ten steps, in one order**`, `the same ten steps in the same order`
# or `the ten steps` — and the fourth form counts ONLY on a line that also names the sequence:
# `close-sequence`, `close sequence` or the whole word `closing`, which covers `the ten closing
# steps` and a count written beside the file's link. In any form the word `closing` may sit
# between the count and `steps`, and the count is a number word, never a digit. The first three
# are claim shapes on their own; `the <number> steps` is ordinary English, and #226 is what the
# scan cost when it was taken as a claim wherever it appeared: "The three steps are independent",
# about three shell commands in a file that cites the sequence for another reason, was reported
# as drift and rewritten to say "commands". "Five steps remain on #41" and "a session three
# steps in" are prose about one particular close, not claims about the sequence's length, and
# match no form. A claim written some fifth way is invisible here — which is why the heading form
# is required to exist rather than merely to agree, and why tests/close-sequence-cases/ holds a
# drifted case per form.
#
# HISTORY IS NOT EDITED. docs/dev-log/ and docs/arc-log/ record what was true when they were
# written; a dev-log saying "nine steps" in 2026-08 is correct and must not be rewritten to
# agree with today. They are excluded deliberately, not by omission.
#
# WHAT IT CANNOT DO. It checks the count, never the content. A step whose text is wrong, or a
# `step N` cross-reference that now points at the wrong step, passes here. Renumbering still
# has to be read — which is the whole of #140's point about prose.
#
# REPORTS, NEVER BLOCKS. Exit 1 marks a finding to read.
#
# CLOSE_SEQUENCE_ROOT points the whole gate at another tree. It exists so the gate can be made to
# fail on purpose against a fixture — the gate that has never failed is the gate nobody tested.
# tests/verify-all.sh never sets it; `selftest` below does, once per case.

set -u

SELF="$(cd "$(dirname "$0")" && pwd)/$(basename "$0")"
CASES="$(dirname "$SELF")/close-sequence-cases"

# ---- selftest ------------------------------------------------------------------------
# Each case is ONE markdown file that cites the sequence, planted as `skills/case/SKILL.md` in
# a temporary root beside a ten-step stand-in for close-sequence.md, and the whole gate is run
# against that root. `pass/` cases must exit 0 and `fail/` cases must exit 1.
#
# A pass case can also say WHICH pass it expects, as `<!-- expect: … -->` on its first line.
# The distinction it draws is the one #226 is about: "cites the sequence, states no count" says
# the file's prose was not read as a claim, and "agrees on ten" says a real claim was still
# recognised. Without it, a regex loosened into matching nothing would pass every case here —
# the fix that stops catching drift is worse than the false positive it removes.
selftest() {
  local passed=0 failed=0 kind f root out rc verdict expect
  [ -f "$CASES/close-sequence.md" ] || { echo "no fixture document: $CASES/close-sequence.md" >&2; exit 2; }
  for kind in pass fail; do
    for f in "$CASES/$kind"/*.md; do
      [ -e "$f" ] || continue
      root="$(mktemp -d)"
      mkdir -p "$root/docs/product-architecture" "$root/skills/case"
      cp "$CASES/close-sequence.md" "$root/docs/product-architecture/close-sequence.md"
      cp "$f" "$root/skills/case/SKILL.md"
      out="$(CLOSE_SEQUENCE_ROOT="$root" bash "$SELF" 2>&1)"; rc=$?
      rm -rf "$root"
      [ "$rc" -eq 0 ] && verdict=pass || verdict=fail
      expect="$(head -n1 "$f" | tr -d '\r' | sed -n 's/^<!-- expect: \(.*\) -->$/\1/p')"
      if [ "$verdict" != "$kind" ]; then
        printf '  FAIL  %-5s %s — got %s\n' "$kind" "$(basename "$f")" "$verdict"
        printf '%s\n' "$out" | sed 's/^/          /'
        failed=$((failed + 1))
      elif [ -n "$expect" ] && ! printf '%s\n' "$out" | grep -qF "skills/case/SKILL.md $expect"; then
        printf '  FAIL  %-5s %s — exit was right, but not for the expected reason: %s\n' "$kind" "$(basename "$f")" "$expect"
        printf '%s\n' "$out" | sed 's/^/          /'
        failed=$((failed + 1))
      else
        printf '  PASS  %-5s %s%s\n' "$kind" "$(basename "$f")" "${expect:+ — $expect}"
        passed=$((passed + 1))
      fi
    done
  done
  echo
  echo "$passed passed, $failed failed"
  [ "$failed" -eq 0 ] || exit 1
  exit 0
}
[ "${1:-}" = "selftest" ] && selftest

cd "${CLOSE_SEQUENCE_ROOT:-$(dirname "$0")/..}" || exit 1

DOC="docs/product-architecture/close-sequence.md"

PASSED=0
FAILED=0
pass() { echo "  PASS  $1"; PASSED=$((PASSED + 1)); }
fail() { echo "  FAIL  $1"; shift; for l in "$@"; do echo "        $l"; done; FAILED=$((FAILED + 1)); }
summary() {
  echo
  if [ "$FAILED" = "0" ]; then echo "$PASSED passed, 0 failed — every count claim says ${EXPECT:-?} steps"; exit 0; fi
  echo "$((PASSED + FAILED)) checks, $FAILED failed"
  exit 1
}

if [ ! -f "$DOC" ]; then
  echo "  FAIL  $DOC is missing — the close sequence has no owner"
  exit 1
fi

# ---- the count the table actually has ----------------------------------------------
# Rows of the Closing table only: the "Starting the next issue" table below it is numbered too,
# so the scan stops at the next `## ` heading.
STEPS=$(awk '
  /^## Closing/                   { in_closing = 1; next }
  /^## /                          { in_closing = 0 }
  in_closing && /^\| *[0-9]+ *\|/ { n++ }
  END                             { print n + 0 }
' "$DOC")

if [ "$STEPS" = "0" ]; then
  fail "no numbered steps found under '## Closing' in $DOC" \
       "the table shape changed, and this gate can no longer see the count"
  summary
fi

WORDS="zero one two three four five six seven eight nine ten eleven twelve thirteen fourteen fifteen"
EXPECT=$(printf '%s\n' $WORDS | sed -n "$((STEPS + 1))p")
if [ -z "$EXPECT" ]; then
  fail "$STEPS steps is past this gate's number-word table" \
       "extend WORDS in tests/verify-close-sequence.sh"
  summary
fi
pass "the Closing table has $STEPS steps ($EXPECT)"

# ---- the heading has to carry the count --------------------------------------------
if grep -qEi "^## Closing[^0-9]*[ —-]${EXPECT}[ -]steps" "$DOC"; then
  pass "$DOC heading says $EXPECT"
else
  fail "$DOC has no '## Closing — $EXPECT steps' heading" \
       "the table has $STEPS steps; the heading has to say so, and this gate reads that form"
fi

# ---- every count claim, here and in what cites it ----------------------------------
# A live artifact is one that states the rule now. The two log trees are the record of what was
# stated then.
# A file qualifies by citing the document OR by saying "closing steps" — skills/decompose says
# the second without ever naming the file, and a scan keyed only to the filename cannot see it.
# Case-insensitive, like every line match below: a file whose only tie is a sentence-initial
# "Closing steps" would otherwise never be scanned, and its drift would pass in silence.
# The list is an array, not a space-joined string: a path with a space in it would split into
# fragments that each fail the file test, and a gate that skips a whole file in silence is the
# failure this one exists to catch.
FILES=("$DOC")
while IFS= read -r f; do
  f="${f#./}"
  [ -n "$f" ] || continue
  case "$f" in
    "$DOC"|docs/dev-log/*|docs/arc-log/*|tests/close-sequence-cases/*) continue ;;
  esac
  FILES+=("$f")
done < <(grep -rliE 'close-sequence\.md|closing steps' --include='*.md' . 2>/dev/null | sort)

# A COUNT IS A NUMBER WORD. The slot before "steps" takes only the words WORDS knows, so "the
# closing steps" and "the same steps" are not claims of a count called "closing" or "same" —
# which `[a-z]+` in that slot made them, and which the scan reported as "not ten".
NUM="($(printf '%s' "$WORDS" | tr ' ' '|'))"
# The three shapes that are claims wherever they appear: the heading, a bold lead-in opening
# with the count, and "the same <n> steps".
CLAIM="(^## Closing[^0-9]*[ —-]|\*\*|same )${NUM}( closing)?[ -]steps"
# The fourth, "the <n> steps", is a claim only on a line that names the sequence. `closing` is
# the sequence's own adjective here — "the ten closing steps" — and the file's name or title is
# how a count sits beside its link. As a whole word: "enclosing" and "disclosing" tie nothing.
PROSE="the ${NUM}( closing)?[ -]steps"
TIE="close[ -]sequence|(^|[^a-z])closing([^a-z]|$)"

# EACH CLAIM IS TESTED, NOT EACH LINE. Dropping a line because the right count appears somewhere
# on it passes "had nine steps and now has ten steps" — so the count word is extracted from every
# match and compared on its own.
#
# The tied form is extracted line by line so the tie and the match are judged on the same line:
# a file-wide grep for the tie followed by a file-wide grep for the form would pair a citation
# on line 3 with "the three steps" on line 40, which is the false positive again with one more
# step in it.
tied_claims() {
  local file="$1" n text
  while IFS= read -r line; do
    n="${line%%:*}"; text="${line#*:}"
    printf '%s\n' "$text" | grep -iE "$TIE" >/dev/null || continue
    printf '%s\n' "$text" | grep -oiE "$PROSE" | sed "s/^/$n:/"
  done < <(grep -n '' "$file")
}

for f in "${FILES[@]}"; do
  [ -f "$f" ] || { fail "$f is listed but not readable" "the scan and the filesystem disagree"; continue; }
  claims=$(
    { grep -noiE "$CLAIM" "$f" || true; tied_claims "$f"; } | sort -t: -k1,1n -s
  )
  bad=$(printf '%s\n' "$claims" | grep -viE ":.*[^a-z]${EXPECT}( closing)?[ -]steps$" || true)
  if [ -n "$bad" ]; then
    lines=$(printf '%s\n' "$bad" | cut -d: -f1 | sort -un | tr '\n' ' ')
    fail "$f states a step count that is not $EXPECT" \
         "$(printf '%s\n' "$bad" | sed 's/^/  /')" \
         "  read lines: $lines"
  elif [ -z "$claims" ]; then
    # Saying "agrees" of a file that states nothing is a claim of coverage it does not have. A
    # count deleted rather than corrected shows up here as a file that stopped claiming.
    pass "$f cites the sequence, states no count"
  else
    pass "$f agrees on $EXPECT"
  fi
done

summary
