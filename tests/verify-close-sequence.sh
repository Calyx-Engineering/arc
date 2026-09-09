#!/usr/bin/env bash
# verify-close-sequence.sh — the close sequence's step count is the same everywhere.
#
#   tests/verify-close-sequence.sh
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
# or `the ten steps`. "Five steps remain on #41" and "a session three steps in" are prose about
# one particular close, not claims about the sequence's length. A claim written some fifth way is
# invisible here — which is why the heading form is required to exist rather than merely to agree.
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
# tests/verify-all.sh never sets it.

set -u

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
# The list is an array, not a space-joined string: a path with a space in it would split into
# fragments that each fail the file test, and a gate that skips a whole file in silence is the
# failure this one exists to catch.
FILES=("$DOC")
while IFS= read -r f; do
  f="${f#./}"
  [ -n "$f" ] || continue
  case "$f" in
    "$DOC"|docs/dev-log/*|docs/arc-log/*) continue ;;
  esac
  FILES+=("$f")
done < <(grep -rlE 'close-sequence\.md|closing steps' --include='*.md' . 2>/dev/null | sort)

CLAIM="(^## Closing[^0-9]*[ —-]|\*\*|same |the )([a-z]+)( closing)?[ -]steps"

# EACH CLAIM IS TESTED, NOT EACH LINE. Dropping a line because the right count appears somewhere
# on it passes "had nine steps and now has ten steps" — so the count word is extracted from every
# match and compared on its own.
for f in "${FILES[@]}"; do
  [ -f "$f" ] || { fail "$f is listed but not readable" "the scan and the filesystem disagree"; continue; }
  claims=$(grep -noiE "$CLAIM" "$f" || true)
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
