#!/usr/bin/env bash
# report-shape-probe.sh — have the installed plugin WRITE a report, and grade what it wrote.
#
#   tools/report-shape-probe.sh --label before --runs 3
#   tools/report-shape-probe.sh --label after  --runs 3
#   RSP_PROBE_OUT=<dir> tools/report-shape-probe.sh --label after --runs 3   keep every report
#   tools/report-shape-probe.sh selftest        the loop only, on canned reports. Bills nothing
#
#   --label NAME     names the side. Files land as NAME-runN.md beside NAME-runN.grade.txt
#   --runs N         sessions on this side. Default 1
#   --threshold N    the rate a scored column must clear. Default 0.67
#
#   RSP_PROBE_OUT=<dir>  where the reports are kept. Default a temp directory, and then they
#                        die with it — see below
#   RSP_PY=<file>        the billed half, replaced. The selftest's only use for it
#   RSP_SKIP_CLI_CHECK=1 do not require `claude` on PATH. Set with RSP_PY and nothing else
#   RSP_BRIEF=<file>     the brief, overridden. The selftest's only use for it — the brief is
#                        FIXED by design, and a probe run on a different brief is a different
#                        instrument whose figure cannot be set beside the one before it
#
# WHY THIS EXISTS, AND WHY tools/report-grade.sh COULD NOT ANSWER IT. That suite grades frozen
# excerpts of documents written before the conclusion-first rule existed. The skill is not one of
# its inputs, so no edit to skills/engineering-report can move it — #159 said so, and #260's
# first run proved it three ways: control, strengthened and EMPTIED all scored 1/3 on the
# opening. An emptied skill scoring what the real one scores is the definition of an instrument
# that is not measuring the skill.
#
# The frozen suite is still the baseline and it is still right to keep: it says what the corpus
# on disk looks like. This says what the plugin DOES when asked for a report today. Two
# questions, two instruments — the same relationship tools/skill-probe.sh has to
# tools/skill-cases.sh, and the same reason: history cannot see an edit.
#
# THE GRADER IS UNCHANGED, DELIBERATELY. This calls `tools/report-grade.sh --file` and reads its
# three verdict lines. Nothing here re-implements the scoring and nothing here relaxes it, so a
# probe figure and a suite figure are the same measurement of two different corpora. #260's
# constraint says the probe adds an input and does not change the scoring; a second copy of the
# rules in this file would have broken that on the first drift.
#
# ALL THREE COLUMNS, NOT ONLY THE OPENING. `--file`'s EXIT CODE is the opening alone, on purpose
# — over a whole file the other two are region-scoped and noisy, and a pre-commit check that
# fails on every document gets turned off. That reasoning is about a check an author runs; it is
# not about a probe. Here the document is one page written to one brief that was built to put
# material in all three columns, so all three are read off the printed verdicts and each is
# scored on its own. A repaired opening beside an unsourced table is two facts, and averaging
# them into one would let either half report the other's work as its own.
#
# A COLUMN WITH NO DENOMINATOR IS NOT A PASS. If no run produced a table, the table column
# measured nothing and says so. It never scores 0/0 and it never gates — the same rule
# tools/report-grade.py applies to TABLE, ONESIDED and UNCLEAR, and the same rule
# tools/skill-probe.sh applies to a case that measured no runs. A probe whose conflict column
# never got a denominator has measured two questions, so the summary says which it measured.
#
# NOT A DETERMINISTIC GATE, AND NOT IN tests/verify-all.sh. Every run is a real billed session
# and shape is a model decision, which is why --runs exists and why the answer is a rate against
# a threshold rather than a pass or a fail. The threshold COLOURS the printed verdict; the
# fractions beside it are the measurement. Exit 0 when the suite ran, 2 when it could not —
# tools/skill-probe.sh's convention and its reason: a wrapper that redirects this to a file must
# not record a halted run as a clean one.
#
# THE TWO FIGURES, SIDE BY SIDE. #260, 2026-09-09, threshold 0.67, `claude -p` against the
# plugin installed from this tree. The frozen suite is the BASELINE: it is a property of six
# documents on disk and no skill edit moves it, which is the whole reason this file exists.
#
#                          opening        table source   conflict
#   frozen suite           1/3   0.333    1/4   0.250    2/2   1.000    (six frozen excerpts)
#   probe, before          2/2   1.000    1/3   0.333    3/3   1.000    (n=3)
#   probe, after           1/1   1.000    3/3   1.000    2/3   0.667    (n=3)
#   probe, after           4/4   1.000    3/6   0.500    4/6   0.667    (n=6, same plugin)
#
# THE TWO AFTER SIDES ARE THE FINDING, NOT THE PASS. Same installed plugin, same brief, same
# grader: the table column read 1.000 at n=3 and 0.500 at n=6. n=3 cannot tell 1.00 from 0.50,
# so a side of three runs is not evidence for a claim against a 0.67 bar and this file's --runs
# default of 1 is a smoke test, never a measurement. Across all nine after runs the table column
# is 6/9 and the conflict column 6/9 — both 0.667, both a hair under a threshold compared with
# `>=`, the same arithmetic tools/report-grade.py and tools/skill-probe.sh use.
#
# IT READS THE INSTALLED PLUGIN, NOT THIS TREE. The plugin is served from
# ~/.claude/plugins/cache/, so an edit to skills/engineering-report is invisible here until
# tools/plugin-reload.sh runs. Reload between the before and the after, or the two sides measure
# the same thing.
#
# KEEP THE REPORTS. Without RSP_PROBE_OUT they die with the temp directory and a billed side
# cannot be re-read when its numbers are questioned — what #158's and #160's runs cost. Each run
# keeps the report AND the grader output that produced its verdict, so the figure can be checked
# without paying for the side again.
#
# THE PARTS THAT DO NOT BILL HAVE SELFTESTS:
#   python tools/report-shape-probe.py selftest   which runs are measurements, where a report goes
#   bash tools/report-shape-probe.sh selftest     what this loop does with the reports it is handed
# Both run in tests/verify-all.sh. This one replaces the billed half through RSP_PY, so it bills
# nothing: what it exercises is JSON and text in, verdicts out — the column tallies, the empty
# denominator, the abandon branch, the halt and the measured-runs denominator. Everything else
# here needs a billed session and is not covered.

set -u
SELF="$(cd "$(dirname "$0")" && pwd)/$(basename "$0")"
cd "${RSP_CD:-$(dirname "$0")/..}" || exit 1


# ---- the three columns ------------------------------------------------------------------
# Which verdicts are a pass, which are a fail, and which are neither. Taken from
# tools/report-grade.py's own docstrings and kept in one place so a reader can check them
# against it: grade_opening, grade_tables, grade_conflict.
#
#   opening        CONCLUSION                    pass
#                  NARRATIVE DEFERRED PREAMBLE   fail
#                  UNCLEAR NOSECTION             neither — the scorer cannot say
#   table source   ROWS                          pass
#                  NONE                          fail
#                  TABLE NOTABLE                 neither — TABLE is weaker than a column and
#                                                is not the defect #164 names
#   conflict       RESOLVED                      pass
#                  SILENT                        fail
#                  ONESIDED WEAKWINS UNREADABLE  neither — WEAKWINS obeys the rule and is
#                                                reported, never scored
PASS_opening="CONCLUSION"
FAIL_opening="NARRATIVE DEFERRED PREAMBLE"
PASS_table="ROWS"
FAIL_table="NONE"
PASS_conflict="RESOLVED"
FAIL_conflict="SILENT"


# ---- selftest ---------------------------------------------------------------------------
# What this loop does with the reports it is handed, on canned reports. RSP_PY replaces the
# billed half, so nothing here opens a session — but tools/report-grade.sh is the REAL grader,
# invoked as it is on disk. That is the point: if the verdict strings this file classifies ever
# drift from the ones the grader prints, this selftest is what notices.
selftest() {
  # A path python can open. On Windows a /tmp path is bash's fiction; `cygpath -m` returns the
  # mixed form, which both bash and python accept. Where cygpath does not exist the two
  # spellings are already the same. tools/skill-probe.sh carries the same note for RSP_PY's
  # equivalent; here the OUT directory is handed to python too, so it is converted as well.
  winpath() {
    if command -v cygpath >/dev/null 2>&1; then cygpath -m "$1"; else printf '%s' "$1"; fi
  }
  RAWTMP="$(mktemp -d)"
  TMP="$(winpath "$RAWTMP")"
  trap 'rm -rf "$RAWTMP"' EXIT

  printf 'write a report\n' > "$TMP/brief.md"

  # Three canned reports whose verdicts were read off the real grader before they were pinned
  # here, so this selftest asserts the loop's arithmetic and not an assumption about scoring.
  cat > "$TMP/good.md" <<'GOOD'
# THERM-4 fan stall

**Status:** complete

## Findings

The bulk capacitor fitted to the 12V rail is roughly half its specified value, so the rail
collapses to 9.4 V at spin-up, below the voltage the fan needs to start.

| Claim | Value | Provenance |
|---|---|---|
| Rail minimum at spin-up | 9.4 V | measured |
| Fan minimum start voltage | 10.8 V | datasheet |

The vendor product page rates that part number at 470 uF, but the LCR meter reads 180-240 uF on
every one of 12 parts, and the bench figure is the one the design is held to.

## Method
GOOD

  cat > "$TMP/bad.md" <<'BAD'
# THERM-4 fan stall

## Background

This report describes three days of bench work on the THERM-4 fan controller. Forty boards came
back from the field. The conclusion is in section 4.

| Claim | Value |
|---|---|
| Rail minimum at spin-up | 9.4 V |
| Fan minimum start voltage | 10.8 V |

The vendor product page rates that part number at 470 uF. The LCR meter reads 180-240 uF.

## Method
BAD

  # A report with no table and one source in play. Two columns with an empty denominator, which
  # is the case a probe must never print as 0/0 and never gate on.
  cat > "$TMP/nocols.md" <<'NOCOLS'
# THERM-4 fan stall

## Findings

The rail collapses to 9.4 V at spin-up, below what the fan needs to start. Every figure here
was measured on the bench.

## Method
NOCOLS

  cat > "$TMP/fake.py" <<'FAKE'
import os, shutil, sys, json
mode = os.environ.get("FAKE", "good")
d = os.path.dirname(os.path.abspath(__file__))
out = sys.argv[2]
n = os.path.join(d, "count.txt")
c = int(open(n).read()) if os.path.exists(n) else 0
open(n, "w").write(str(c + 1))

def wrote(src, **kw):
    shutil.copyfile(os.path.join(d, src), out)
    r = {"fired": ["engineering-report"], "turns": 3, "cost": 0.4, "cut": "",
         "retried": "", "unusable": "", "file": out}
    r.update(kw)
    return r

bad_run = {"fired": [], "turns": 0, "cost": 0.0, "cut": "error_during_execution",
           "retried": "error_during_execution", "unusable": "error_during_execution",
           "file": ""}
if mode == "unusable":
    print(json.dumps(bad_run))
elif mode == "retried":
    print(json.dumps(wrote("good.md", retried="error_during_execution")))
elif mode == "late-unusable":
    print(json.dumps(wrote("good.md") if c == 0 else bad_run))
elif mode == "nofile":
    print(json.dumps(dict(wrote("good.md"), file="", unusable="")))
elif mode == "crash":
    sys.exit(3)
elif mode == "garbage":
    print("this is not json")
elif mode == "schemaless":
    print(json.dumps({"cut": "", "retried": "", "unusable": ""}))
else:
    print(json.dumps(wrote(mode + ".md")))
FAKE

  RUN=0; PASSED=0; FAILED=0
  # EVERY tunable is pinned, not only the ones a case sets. A gate reading RSP_THRESHOLD or
  # RSP_PROBE_OUT out of whoever's shell invoked verify-all.sh fails for reasons that have
  # nothing to do with the code, and writes reports outside $TMP that the trap does not clean.
  probe() {
    rm -f "$TMP/count.txt"
    rm -rf "$TMP/out"
    FAKE="$1"; shift
    FAKE="$FAKE" RSP_SKIP_CLI_CHECK=1 RSP_THRESHOLD=0.67 RSP_CD="" \
      RSP_PROBE_OUT="$TMP/out" RSP_BRIEF="$TMP/brief.md" RSP_PY="$TMP/fake.py" \
      bash "$SELF" "$@" 2>&1
  }
  # Runs of spaces are squeezed on BOTH sides before matching. The summary is column-aligned
  # with printf, so a needle written with the real padding pins this selftest to a layout —
  # widen one column for readability and nine behavioural cases fail for a cosmetic reason,
  # which teaches the next reader to loosen the assertions rather than the format.
  squeeze() { printf '%s' "$1" | tr -s ' '; }
  want() {
    NAME="$1"; NEEDLE="$(squeeze "$2")"; HAY="$(squeeze "$3")"
    RUN=$((RUN + 1))
    case "$HAY" in
      *"$NEEDLE"*) PASSED=$((PASSED + 1)); echo "  ok    $NAME" ;;
      *) FAILED=$((FAILED + 1)); echo "  FAIL  $NAME"; echo "        expected to find: $NEEDLE" ;;
    esac
  }
  wantnot() {
    NAME="$1"; NEEDLE="$(squeeze "$2")"; HAY="$(squeeze "$3")"
    RUN=$((RUN + 1))
    case "$HAY" in
      *"$NEEDLE"*) FAILED=$((FAILED + 1)); echo "  FAIL  $NAME"; echo "        did not expect: $NEEDLE" ;;
      *) PASSED=$((PASSED + 1)); echo "  ok    $NAME" ;;
    esac
  }

  echo "report-shape-probe.sh selftest — what this loop does with the reports it is handed"
  echo

  O="$(probe good --label s --runs 2)"
  want "a conclusion-first report scores the opening"  "opening         PASS  2/2" "$O"
  want "and its sourced table scores the table column" "table source    PASS  2/2" "$O"
  want "and its stated override scores the conflict"   "conflict        PASS  2/2" "$O"
  want "every column clearing the bar is the verdict"  "verdict                          PASS" "$O"
  wantnot "a clean side does not halt"                 "STOPPED EARLY" "$O"

  O="$(probe bad --label s --runs 2)"
  want "a background-first opening scores 0"           "opening         FAIL  0/2" "$O"
  want "an unsourced claim table scores 0"             "table source    FAIL  0/2" "$O"
  want "a silent conflict scores 0"                    "conflict        FAIL  0/2" "$O"
  want "and one failing column fails the side"         "verdict                          FAIL" "$O"

  # A column with nothing in its denominator. Neither a pass nor a fail, and it must not decide
  # the verdict — the same rule the grader applies to TABLE, ONESIDED and UNCLEAR.
  O="$(probe nocols --label s --runs 2)"
  want "no table means the column measured nothing"    "table source    not scored" "$O"
  want "one source in play means the same"             "conflict        not scored" "$O"
  wantnot "an empty column never prints a fraction"    "0/0" "$O"
  want "and the verdict rests on what was measured"    "verdict                          PASS" "$O"
  want "the summary names the columns it could score"  "scored: opening" "$O"

  O="$(probe unusable --label s --runs 3)"
  want "an unusable run says so, naming the reason"    "UNUSABLE: error_during_execution" "$O"
  want "a side that measured nothing prints NO DATA"   "NO DATA" "$O"
  want "the side stops rather than billing on"         "STOPPED EARLY: error_during_execution" "$O"
  wantnot "and no column is scored from it"            "FAIL  0/" "$O"

  O="$(probe late-unusable --label s --runs 3)"
  want "a side that measured 1 of 3 divides by 1"      "opening         PASS  1/1" "$O"
  want "and says how many runs it actually measured"   "(1 of 3 runs measured)" "$O"

  O="$(probe retried --label s --runs 1)"
  want "a run that needed its retry is marked as such" "(retried after error_during_execution)" "$O"

  O="$(probe crash --label s --runs 2)"
  want "a runner that exits non-zero is unusable"      "UNUSABLE: the probe runner exited 3" "$O"
  O="$(probe garbage --label s --runs 2)"
  want "output that is not JSON is unusable"           "UNUSABLE: the probe runner printed something that is not JSON" "$O"
  O="$(probe schemaless --label s --runs 2)"
  want "JSON with no file path is unusable"            "UNUSABLE: the probe runner printed JSON with no 'file' path" "$O"
  # A run that reported a usable session and no report is the shape unique to this instrument:
  # there is no document, so there is nothing to grade. Graded anyway it lands in every column
  # as a fail, which is #213's confusion in a new place.
  O="$(probe nofile --label s --runs 2)"
  want "a run that wrote no report is unusable"        "UNUSABLE: the probe runner reported no report file" "$O"

  # A crashed or silent runner made ONE attempt. Saying the retry failed sends the operator
  # looking for a back-off that was never waited out.
  O="$(probe crash --label s --runs 1)"
  want "a runner that never spoke claims no retry"     "no retry was possible" "$O"
  O="$(probe unusable --label s --runs 1)"
  want "a runner that did retry says the retry failed" "the retry failed too" "$O"

  # The reports are the point of a billed side. A run whose report is not on disk afterwards is
  # a run that cannot be re-read, which is the cost #158 and #160 both paid.
  probe good --label s --runs 2 >/dev/null 2>&1
  [ -f "$TMP/out/s-run1.md" ] && [ -f "$TMP/out/s-run2.md" ] && K=kept || K=lost
  want "every run's report is kept"                    "kept" "$K"
  [ -f "$TMP/out/s-run1.grade.txt" ] && G=kept || G=lost
  want "and the grader output that judged it"          "kept" "$G"

  # Refusing to overwrite a kept side. Re-running --label before after the before side is
  # measured would otherwise destroy it silently, and the two sides are the whole comparison.
  O="$(FAKE=good RSP_SKIP_CLI_CHECK=1 RSP_CD="" RSP_PROBE_OUT="$TMP/out" \
       RSP_BRIEF="$TMP/brief.md" RSP_PY="$TMP/fake.py" bash "$SELF" --label s --runs 1 2>&1)"
  want "a label whose reports exist is refused"        "already holds a report" "$O"

  # The halt has to reach the exit status, or a wrapper records a side that stopped on its
  # first run as a clean one.
  probe good --label s --runs 1 >/dev/null 2>&1; ST=$?
  want "a side that ran exits 0"                       "status 0" "status $ST"
  probe unusable --label s --runs 1 >/dev/null 2>&1; ST=$?
  want "a halted side exits 2"                         "status 2" "status $ST"

  echo
  echo "$RUN cases, $PASSED passed, $FAILED failed"
  [ "$FAILED" = "0" ]
}

if [ "${1:-}" = "selftest" ]; then
  selftest
  exit $?
fi

BRIEF="${RSP_BRIEF:-evals/report-shape-probe/brief.md}"
RUNS=1
LABEL="probe"
THRESHOLD="${RSP_THRESHOLD:-0.67}"

while [ "$#" -gt 0 ]; do
  case "$1" in
    --runs) RUNS="${2:-1}"; shift ;;
    --label) LABEL="${2:-probe}"; shift ;;
    --threshold) THRESHOLD="${2:-0.67}"; shift ;;
    # The header ends where the code starts. A fixed last line silently truncates --help every
    # time the header grows, which it did twice in tools/skill-probe.sh over one issue.
    -h|--help) sed -n "2,$(($(grep -n '^set -u' "$0" | head -n1 | cut -d: -f1) - 1))p" "$0"; exit 0 ;;
    *) echo "unknown argument: $1" >&2; exit 2 ;;
  esac
  shift
done

[ -f "$BRIEF" ] || { echo "no brief at $BRIEF" >&2; exit 2; }

if [ -z "${RSP_SKIP_CLI_CHECK:-}" ]; then
  command -v claude >/dev/null 2>&1 || { echo "claude CLI not on PATH — nothing to probe" >&2; exit 2; }
fi

HERE="$(cd "$(dirname "$0")" && pwd)"
# The billed half, overridable so the selftest can hand this loop canned reports. It is a
# python FILE PATH and is passed to python, not to bash.
RSP_PY="${RSP_PY:-$HERE/report-shape-probe.py}"

OUT="${RSP_PROBE_OUT:-$(mktemp -d)/reports}"
mkdir -p "$OUT" 2>/dev/null
# A label whose reports are already on disk is REFUSED, not overwritten. The before side and
# the after side are the whole comparison, and a second `--label before` would destroy the half
# that was already paid for with nothing said. Same instinct as RL_PROBE_OUT's guard in
# tools/response-length.sh, one artifact along.
for r in $(seq 1 "$RUNS"); do
  if [ -e "$OUT/$LABEL-run$r.md" ]; then
    echo "$OUT already holds a report for --label $LABEL — refusing to overwrite it." >&2
    echo "Use a different label, or move the kept side aside first." >&2
    exit 2
  fi
done

echo "report-shape-probe — label ${LABEL}, ${RUNS} run(s), threshold ${THRESHOLD}"
echo "The plugin AS INSTALLED writes a report from ${BRIEF}; tools/report-grade.sh grades it."
echo "Run tools/plugin-reload.sh after an edit or this repeats the run before it."
echo "Reports kept in ${OUT}"
echo

# Per-column hits and denominators. Plain counters rather than an associative array: this has to
# run under the bash that ships on Windows, which is why tools/skill-probe.sh carries a string
# accumulator for the same reason.
OP_H=0; OP_N=0
TB_H=0; TB_N=0
CF_H=0; CF_N=0
DONE=0
HALT=""
TOTALCOST=0

# score <column-name> <verdict> <pass-list> <fail-list> — echoes hit/miss/unscored.
classify() {
  case " $3 " in *" $2 "*) echo hit; return ;; esac
  case " $4 " in *" $2 "*) echo miss; return ;; esac
  echo unscored
}

for r in $(seq 1 "$RUNS"); do
  REPORT="$OUT/$LABEL-run$r.md"
  # stderr is NOT swallowed. report-shape-probe.py states its back-off there, and a warning
  # routed into /dev/null is the same as no warning — which is what #213 had.
  RAW="$(python "$RSP_PY" "$BRIEF" "$REPORT")"; RC=$?

  FILE=""; RETRIED=""; UNUSABLE=""; FIRED=""; COST=""
  if [ "$RC" -ne 0 ] || [ -z "$RAW" ]; then
    if [ "$RC" -ne 0 ]; then
      UNUSABLE="the probe runner exited $RC with no readable output"
    else
      UNUSABLE="the probe runner printed nothing"
    fi
  else
    # A parse failure is an unusable run, not a report that failed. python exits non-zero on bad
    # JSON, and the || is what turns that into a stated reason instead of three silent zeros.
    UNUSABLE="$(printf '%s' "$RAW" | python -c "import json,sys; print(json.loads(sys.stdin.read()).get('unusable',''))" 2>/dev/null)" \
      || UNUSABLE="the probe runner printed something that is not JSON"
    RETRIED="$(printf '%s' "$RAW" | python -c "import json,sys; print(json.loads(sys.stdin.read()).get('retried',''))" 2>/dev/null)" \
      || RETRIED=""
    FIRED="$(printf '%s' "$RAW" | python -c "import json,sys; print(' '.join(json.loads(sys.stdin.read()).get('fired') or []))" 2>/dev/null)" \
      || FIRED=""
    COST="$(printf '%s' "$RAW" | python -c "import json,sys; c=json.loads(sys.stdin.read()).get('cost'); print('%.3f'%c if c else '')" 2>/dev/null)" \
      || COST=""
    if [ -z "$UNUSABLE" ]; then
      # `file` is REQUIRED, not defaulted. Reading a missing key as "no report" would be right
      # by accident here and wrong the moment the key is renamed; and a run that reported a
      # session and no document has nothing to grade either way.
      FILE="$(printf '%s' "$RAW" | python -c "import json,sys; print(json.loads(sys.stdin.read())['file'])" 2>/dev/null)" \
        || UNUSABLE="the probe runner printed JSON with no 'file' path"
      if [ -z "$UNUSABLE" ] && { [ -z "$FILE" ] || [ ! -f "$FILE" ]; }; then
        UNUSABLE="the probe runner reported no report file"
      fi
    fi
  fi

  if [ -n "$UNUSABLE" ]; then
    # Said BEFORE the next run would start. report-shape-probe.py has already retried once and
    # the retry failed too, so the side stops: continuing bills another attempt and another
    # back-off per remaining run into a limit this tool already knows about.
    NOTE="$([ -n "$RETRIED" ] && printf 'the retry failed too' || printf 'no retry was possible')"
    printf '  run %-3d UNUSABLE: %s — %s; abandoning this side after %d measured run(s)\n' \
      "$r" "$UNUSABLE" "$NOTE" "$DONE"
    HALT="$UNUSABLE"
    break
  fi

  GRADE="$OUT/$LABEL-run$r.grade.txt"
  # The grader's own output is kept beside the report, so a figure can be checked later without
  # re-grading and without paying for the side again. Its exit code is the OPENING's verdict
  # only — deliberately, and documented in tools/report-grade.py — so it is not read here; the
  # three printed verdicts are, each scored on its own.
  bash "$HERE/report-grade.sh" --file "$FILE" > "$GRADE" 2>&1
  OPV="$(sed -n 's/^  opening  *\([A-Z][A-Z]*\).*/\1/p' "$GRADE" | head -n1)"
  TBV="$(sed -n 's/^  table source  *\([A-Z][A-Z]*\).*/\1/p' "$GRADE" | head -n1)"
  CFV="$(sed -n 's/^  conflict  *\([A-Z][A-Z]*\).*/\1/p' "$GRADE" | head -n1)"

  DONE=$((DONE + 1))
  [ -n "$COST" ] && TOTALCOST="$(python -c "print('%.3f' % ($TOTALCOST + $COST))")"

  case "$(classify opening "$OPV" "$PASS_opening" "$FAIL_opening")" in
    hit)  OP_H=$((OP_H + 1)); OP_N=$((OP_N + 1)) ;;
    miss) OP_N=$((OP_N + 1)) ;;
  esac
  case "$(classify table "$TBV" "$PASS_table" "$FAIL_table")" in
    hit)  TB_H=$((TB_H + 1)); TB_N=$((TB_N + 1)) ;;
    miss) TB_N=$((TB_N + 1)) ;;
  esac
  case "$(classify conflict "$CFV" "$PASS_conflict" "$FAIL_conflict")" in
    hit)  CF_H=$((CF_H + 1)); CF_N=$((CF_N + 1)) ;;
    miss) CF_N=$((CF_N + 1)) ;;
  esac

  printf '  run %-3d opening %-11s table %-9s conflict %-11s $%-6s fired: %s%s\n' \
    "$r" "${OPV:-?}" "${TBV:-?}" "${CFV:-?}" "${COST:-?}" "${FIRED:-—}" \
    "$([ -n "$RETRIED" ] && printf '   (retried after %s)' "$RETRIED")"
done

echo
if [ "$DONE" -eq 0 ]; then
  # No verdict and no column row. A side that produced no measurement contributes nothing:
  # printing FAIL 0/0 here is how a rate limit gets recorded as a shape defect.
  echo "  (nothing measured)                 NO DATA"
  echo
  echo "STOPPED EARLY: $HALT"
  echo "No report was graded, so no column has a figure. Nothing here is a measurement of the plugin."
  exit 2
fi

MEASURED=""
[ "$DONE" -lt "$RUNS" ] && MEASURED="   ($DONE of $RUNS runs measured)"

BAD=0
SCORED=""
row() {  # row <label> <hits> <total>
  if [ "$3" -eq 0 ]; then
    printf '  %-14s not scored   no run put anything in this column\n' "$1"
    return
  fi
  V="$(python -c "print('PASS' if $2/$3 >= $THRESHOLD else 'FAIL')")"
  # THREE DECIMALS, NOT TWO. The comparison is against the raw rate, so 2/3 is 0.6667 and fails
  # a 0.67 threshold — correctly, and the same way tools/skill-probe.sh fails it. Printed to two
  # places that reads `FAIL 2/3 0.67`, a verdict contradicting the number beside it, and the
  # first thing a reader does is doubt the arithmetic instead of the sample size.
  R="$(python -c "print('%.3f' % ($2/$3))")"
  printf '  %-14s %s  %d/%d  %s%s\n' "$1" "$V" "$2" "$3" "$R" "$MEASURED"
  [ "$V" = "FAIL" ] && BAD=$((BAD + 1))
  SCORED="$SCORED $1"
}
row "opening" "$OP_H" "$OP_N"
row "table source" "$TB_H" "$TB_N"
row "conflict" "$CF_H" "$CF_N"

echo
# Which columns the side actually measured, said out loud. A probe whose conflict column never
# got a denominator has answered two questions, and a verdict that does not say so reads as an
# answer to three.
echo "  scored:$([ -n "$SCORED" ] && printf '%s' "$SCORED" || printf ' nothing')"
printf '  %-32s %s\n' "threshold" "$THRESHOLD"
printf '  %-32s %s\n' "verdict" "$([ "$BAD" -eq 0 ] && printf 'PASS' || printf 'FAIL')"
printf '  %-32s $%s over %d run(s)\n' "cost" "$TOTALCOST" "$DONE"

echo
if [ -n "$HALT" ]; then
  echo "STOPPED EARLY: $HALT"
  echo "The fractions above cover the runs that were measured. Any run after this one did not happen."
  echo
fi
echo "A rate here is a measurement of the plugin as installed, not of this working tree."
echo "Run tools/plugin-reload.sh after an edit or the after-side repeats the before-side."
echo "The frozen suite — bash tools/report-grade.sh — is the corpus baseline this cannot move."

# 2, not 0 and not 1. A halt is "I could not measure what you asked", the same answer
# tests/verify-linked-branch.sh gives to a read it could not make. The threshold verdict is NOT
# in the exit code: shape is a model decision and a rate against a threshold is a reading, not
# a gate — tools/skill-probe.sh's convention, for the same reason.
[ -n "$HALT" ] && exit 2
exit 0
