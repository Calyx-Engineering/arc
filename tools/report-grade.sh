#!/usr/bin/env bash
# report-grade.sh — score the eval cases in evals/report-shape: does a report open with the
# conclusion, or with the story of how the conclusion was reached?
#
#   tools/report-grade.sh              score every case from its stored excerpt
#   tools/report-grade.sh --strict     also fail when a case's corpus is not on this machine
#   tools/report-grade.sh selftest     fixtures only, no corpus needed
#   tools/report-grade.sh --file F     grade one document. Exit 1 when its opening fails
#
#   --threshold N    the rate the suite must clear. Default 0.67
#   --corpus DIR     where the source repositories live. Default $REPORT_CORPUS_DIR, else R:/work_lantern
#
# WHY THIS EXISTS. #159: reports, READMEs and one spec are written as an account of the
# exploration rather than as the current state of knowledge — five post-install corrections,
# cluster C3 of the 2026-09 retrospective. skills/engineering-report has said "Findings first"
# since it was written and nothing has ever checked a document against it.
#
# IT IS THE FIRST INSTRUMENT HERE THAT READS A DOCUMENT. skill-cases.sh, response-length.sh and
# topic-numbering.sh all score a REPLY out of a transcript. A report is not a reply: it is a
# file, it is edited over days, and the turn it was written on says nothing about the shape it
# ended in. #155 recorded Fire-5 as "unmeasured" for that reason — engineering-report fired once
# in fifteen sessions, and no session has it firing while a report stayed narrative. This scores
# the shape; whether the skill fired stays tools/skill-cases.sh's question.
#
# IT DOES NOT NEED A MODEL TO GRADE IT. "Is the first section a findings section, and is there a
# sentence above it explaining what the document is" is countable, the same way a word count and
# a label are. `claude plugin eval` is still gated (#181) and is still what a judgement-shaped
# grader would need; this is not one.
#
# THE EXCERPT IS THE CASE. Each case carries excerpt.md — the opening of a real report, copied
# verbatim — plus the document and line range it came from. Scoring reads the excerpt, so the
# suite runs on any machine. When the corpus IS present the excerpt is compared against those
# lines and a mismatch fails the run, which is the same verbatim claim topic-numbering.sh makes
# about turns/<n>.md, checked the same way. Only the selftest is fully portable, which is why it
# is the part wired into tools/verify-all.sh.
#
# A LOW RATE IS A MEASUREMENT. The suite is drawn from documents that were written before any of
# this existed, so a baseline that fails is the baseline. Raising the threshold until it passes,
# or picking only well-shaped documents, would produce a number that means nothing.

set -u
# Resolved BEFORE the cd, or `dirname "$0"` is read against the new working directory and a run
# started from anywhere but the repo root looks for its scorer in the wrong place.
HERE="$(cd "$(dirname "$0")" && pwd)"
cd "${RG_CD:-$HERE/..}" || exit 1
STRICT=0
SELFTEST=0
CORPUS="${REPORT_CORPUS_DIR:-R:/work_lantern}"

while [ "$#" -gt 0 ]; do
  case "$1" in
    selftest) SELFTEST=1 ;;
    --strict) STRICT=1 ;;
    --corpus) CORPUS="${2:-}"; shift ;;
    --file) RG_FILE="${2:-}"; export RG_FILE; shift ;;
    --threshold) RG_THRESHOLD="${2:-0.67}"; export RG_THRESHOLD; shift ;;
    -h|--help) sed -n "2,40p" "$0"; exit 0 ;;
    *) echo "unknown argument: $1" >&2; exit 2 ;;
  esac
  shift
done

score() {  # score <corpus-root> <eval-dir>
  RG_CORPUS_DIR="$1" RG_EVAL_DIR="$2" RG_STRICT="$STRICT" python "$HERE/report-grade.py"
}

if [ "$SELFTEST" = "1" ]; then
  T="$(mktemp -d)"
  trap 'rm -rf "$T"' EXIT
  E="$T/evals"
  C="$T/corpus"
  mkdir -p "$C/fixture/docs"

  # mk <slug> <document-basename> <lines> — writes the case, and the corpus copy the drift
  # check reads. The excerpt is written by the caller.
  mk() {
    mkdir -p "$E/$1/graders"
    printf 'corpus: fixture\ndocument: docs/%s\nlines: %s\n' "$2" "$3" > "$E/$1/case.yaml"
    printf '# grader\n' > "$E/$1/graders/conclusion-first.md"
  }
  # sync <slug> <document-basename> — the corpus copy is the excerpt, so a clean run has no drift
  sync() { cp "$E/$1/excerpt.md" "$C/fixture/docs/$2"; }

  mk good good.md 1-7
  printf '# A title\n\n**Status:** current\n\n## 1. Findings\n\nThe part is fast enough.\n' \
    > "$E/good/excerpt.md"; sync good good.md

  mk question question.md 1-7
  printf '# A title\n\n**Status:** current\n\n## Question\n\nDoes the PSE belong on the board?\n' \
    > "$E/question/excerpt.md"; sync question question.md

  mk deferred deferred.md 1-7
  # The status header carries the pointer. The preamble check exempts bold-label lines and the
  # deferred check must not, or the corpus's clearest instance scores clean.
  printf '# A title\n\n**Status:** complete. Conclusion in Section 9.\n\n## Findings\n\nIt works.\n' \
    > "$E/deferred/excerpt.md"; sync deferred deferred.md

  mk preamble preamble.md 1-9
  printf '# A title\n\n**Author:** D\n\nThis document describes the sweep and its results.\n\n## Findings\n\nGain is 19x.\n' \
    > "$E/preamble/excerpt.md"; sync preamble preamble.md

  mk unclear unclear.md 1-5
  printf '# A title\n\n## Load switch rise time\n\n336 to 546 us.\n' \
    > "$E/unclear/excerpt.md"; sync unclear unclear.md

  mk nosection nosection.md 1-3
  printf '# A title\n\nProse and nothing else.\n' \
    > "$E/nosection/excerpt.md"; sync nosection nosection.md

  mk scopeline scopeline.md 1-8
  # "**Scope:** ..." is the status header the skill requires, not a framing preamble. Failing it
  # would make the check unusable on a correctly structured report — the real case is
  # evals/report-shape/cellular-recommendation-first.
  printf '# A title\n\n**Status:** selected\n**Scope:** replace the RUT241 on rev B\n\n## 1. Recommendation\n\nLay down one land pattern.\n' \
    > "$E/scopeline/excerpt.md"; sync scopeline scopeline.md

  mk callout callout.md 1-8
  # A safety callout is a finding. The skill has a whole section demanding one, and failing a
  # report for carrying it would invert the rule.
  printf '# A title\n\n> [!WARNING]\n> This document was measured on a damaged unit.\n\n## Findings\n\nThe signature is 25 kohm.\n' \
    > "$E/callout/excerpt.md"; sync callout callout.md

  mk fenced fenced.md 1-9
  # A heading inside a fenced sample is sample text. Counting it would make "## Question" the
  # first section of a report whose first section is "Findings".
  printf '# A title\n\n```\n## Question\n```\n\n## Findings\n\nIt holds.\n' \
    > "$E/fenced/excerpt.md"; sync fenced fenced.md

  mk midtable midtable.md 40-44
  # A region cut from the middle of a document is evidence about a table or a section, not about
  # an opening. Grading it for conclusion-first would score the absence of a status header — the
  # part the excerpt simply does not contain — as a defect. The real cases cut this way are
  # #164's: evals/report-shape/pin-allocation-ledger and poe-device-under-test.
  printf '| Ref | Value |
|---|---|
| R2 | 24.9 kohm |
| L3 | 1 uH |
'     > "$E/midtable/excerpt.md"
  { printf 'filler
%.0s' $(seq 1 39); cat "$E/midtable/excerpt.md"; } > "$C/fixture/docs/midtable.md"

  out="$(score "$C" "$E" 2>&1)"; st=$?
  P=0; F=0
  t() {
    if printf '%s' "$out" | grep -qE -- "$2"; then echo "  PASS  $1"; P=$((P+1))
    else
      echo "  FAIL  $1"; echo "        wanted /$2/"; echo "        got:"
      printf '%s\n' "$out" | sed 's/^/          /'; F=$((F+1))
    fi
  }

  echo "report-grade selftest"
  echo

  t "a findings section with nothing above it passes"     "CONCLUSION +good$"
  t "a question-first report scores NARRATIVE"            "NARRATIVE +question +flags: background-first"
  t "a conclusion pointed at from the header is DEFERRED" "DEFERRED +deferred +flags: deferred"
  t "a framing preamble is a fail on its own"             "PREAMBLE +preamble +flags: preamble"
  t "an unclassified first heading is not scored"         "UNCLEAR +unclear"
  t "the unclassified heading is named, not swallowed"    "first section: Load switch rise time +\[unclassified\]"
  t "a document with no section is not scored"            "NOSECTION +nosection"
  t "a bold-label Scope line is status header, not prose" "CONCLUSION +scopeline$"
  t "a warning callout is content, not a preamble"        "CONCLUSION +callout$"
  t "a heading inside a fence is not the first section"   "CONCLUSION +fenced$"
  t "fails are counted by kind"                           "narrative 1, deferred 1, preamble 1"
  t "a region that is not an opening is not scored"       "NOTOPENING +midtable +\(region 40-44 does not start at line 1\)"
  t "unscored verdicts are counted apart, by kind"        "not scored 3 \(unclear heading 1, no section 1, not an opening 1\)"
  t "the rate counts every fail in the denominator"       "opens with the conclusion +4/7"
  t "a rate below the threshold is a FAIL verdict"        "^verdict +FAIL"
  t "the score is not what the exit code reports"         "Not the score"
  t "a matching corpus is not reported as drift"          "report-grade — 10 case"
  if printf '%s' "$out" | grep -q "EXCERPT DRIFT"; then
    echo "  FAIL  a matching excerpt is not reported as drift"; F=$((F+1))
  else
    echo "  PASS  a matching excerpt is not reported as drift"; P=$((P+1))
  fi
  [ "$st" = "0" ] && { echo "  PASS  a clean run exits 0"; P=$((P+1)); } \
                  || { echo "  FAIL  a clean run exits 0 (got $st)"; F=$((F+1)); }

  # Drift must fail, and must fail loudly. An excerpt that no longer matches the document it
  # claims to copy is a case that has quietly stopped being evidence.
  printf '# A title\n\n**Status:** current\n\n## 1. Findings\n\nThe part is NOT fast enough.\n' \
    > "$C/fixture/docs/good.md"
  dout="$(score "$C" "$E" 2>&1)"; dst=$?
  if printf '%s' "$dout" | grep -q "EXCERPT DRIFT" && [ "$dst" != "0" ]; then
    echo "  PASS  an edited source document is caught as drift and exits non-zero"; P=$((P+1))
  else
    echo "  FAIL  an edited source document is caught as drift and exits non-zero (exit $dst)"
    F=$((F+1))
  fi

  # An absent corpus is reported and the case is still scored from its excerpt — that is the
  # portability the suite is built for. --strict is what turns it into a failure.
  aout="$(RG_CORPUS_DIR="$T/nowhere" RG_EVAL_DIR="$E" python "$HERE/report-grade.py" 2>&1)"; ast=$?
  if printf '%s' "$aout" | grep -q "CORPUS NOT CHECKED" && [ "$ast" = "0" ] \
     && printf '%s' "$aout" | grep -qE "opens with the conclusion +4/7"; then
    echo "  PASS  an absent corpus is reported, and the cases still score"; P=$((P+1))
  else
    echo "  FAIL  an absent corpus is reported, and the cases still score (exit $ast)"; F=$((F+1))
  fi
  sst="$(RG_CORPUS_DIR="$T/nowhere" RG_EVAL_DIR="$E" RG_STRICT=1 python "$HERE/report-grade.py" >/dev/null 2>&1; echo $?)"
  [ "$sst" != "0" ] && { echo "  PASS  --strict fails on an absent corpus"; P=$((P+1)); } \
                    || { echo "  FAIL  --strict fails on an absent corpus"; F=$((F+1)); }

  # --file grades one document and its exit code IS the verdict, which is the opposite of the
  # suite's contract. Both directions, or the flag is an option nothing tests.
  gout="$(bash "$HERE/report-grade.sh" --file "$E/good/excerpt.md" 2>&1)"; gst=$?
  if printf '%s' "$gout" | grep -q "CONCLUSION" && [ "$gst" = "0" ]; then
    echo "  PASS  --file exits 0 on a conclusion-first document"; P=$((P+1))
  else
    echo "  FAIL  --file exits 0 on a conclusion-first document (exit $gst)"; F=$((F+1))
  fi
  bout="$(bash "$HERE/report-grade.sh" --file "$E/question/excerpt.md" 2>&1)"; bst=$?
  if printf '%s' "$bout" | grep -q "NARRATIVE" && [ "$bst" = "1" ]; then
    echo "  PASS  --file exits 1 on a narrative opening"; P=$((P+1))
  else
    echo "  FAIL  --file exits 1 on a narrative opening (exit $bst)"; F=$((F+1))
  fi
  mout="$(bash "$HERE/report-grade.sh" --file "$T/nosuchfile.md" 2>&1)"; mst=$?
  [ "$mst" = "2" ] && { echo "  PASS  --file on a missing file exits 2"; P=$((P+1)); }                    || { echo "  FAIL  --file on a missing file exits 2 (got $mst)"; F=$((F+1)); }

  # A threshold the fixture clears must flip the verdict, or the verdict is not reading it.
  tout="$(RG_CORPUS_DIR="$T/nowhere" RG_EVAL_DIR="$E" RG_THRESHOLD=0.5 python "$HERE/report-grade.py" 2>&1)"
  if printf '%s' "$tout" | grep -qE "^verdict +PASS"; then
    echo "  PASS  the threshold is read, not hardcoded"; P=$((P+1))
  else
    echo "  FAIL  the threshold is read, not hardcoded"; F=$((F+1))
  fi

  # The line above sets the variable directly, which does not exercise this script's own flag
  # plumbing. --threshold has to reach the scorer or it is an option nothing tests.
  fout="$(RG_EVAL_DIR_OVERRIDE="$E" REPORT_CORPUS_DIR="$T/nowhere" \
          bash "$HERE/report-grade.sh" --threshold 0.5 2>&1)"
  if printf '%s' "$fout" | grep -qE "^threshold +0\.50" && printf '%s' "$fout" | grep -qE "^verdict +PASS"; then
    echo "  PASS  --threshold reaches the scorer"; P=$((P+1))
  else
    echo "  FAIL  --threshold reaches the scorer"; F=$((F+1))
  fi

  echo
  echo "$P passed, $F failed"
  [ "$F" = "0" ] || exit 1
  exit 0
fi

# --file grades one document and exits on its verdict. It is what makes the rule in
# skills/engineering-report runnable against the report being written, rather than only against
# the suite — a check nobody can run on their own document is a check nobody runs.
if [ -n "${RG_FILE:-}" ]; then
  [ -f "$RG_FILE" ] || { echo "no such file: $RG_FILE" >&2; exit 2; }
  RG_EVAL_DIR="" python "$HERE/report-grade.py"
  exit $?
fi

EVAL_DIR="${RG_EVAL_DIR_OVERRIDE:-evals/report-shape}"
score "$CORPUS" "$EVAL_DIR"
exit $?
