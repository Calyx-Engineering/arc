#!/usr/bin/env bash
# skill-probe.sh — re-run the eval prompts against the plugin as it is installed now.
#
#   tools/skill-probe.sh                       every case, one run each
#   tools/skill-probe.sh --openings --runs 3   only cases whose source says opening: true
#   tools/skill-probe.sh --case wrapped/handoff-camp-catch-up
#   tools/skill-probe.sh --openings --expect handoff --runs 3   only cases expecting one skill
#
#   PROBE_TRANSCRIPT_DIR=<dir> tools/skill-probe.sh --openings   keep every run's raw stream
#
#   PROBE_PY=<file>          the running half, replaced. The selftest's only use for it
#   PROBE_SKIP_CLI_CHECK=1   do not require `claude` on PATH. Set with PROBE_PY and nothing
#                            else — on the live path it removes the cheapest guard there is,
#                            and the suite then halts on "the probe runner exited 1 with no
#                            readable output" instead of saying the CLI is missing
#
# THE PARTS THAT DO NOT BILL HAVE SELFTESTS:
#   python tools/skill-probe.py selftest          the stop condition, on canned streams
#   bash tools/skill-probe.sh selftest            what this script does with the JSON it gets
#   bash tools/probe-handoff-checks.sh selftest   what a kept stream can be asked afterwards
# All three run in tools/verify-all.sh. This script's selftest replaces skill-probe.py with a
# canned one through PROBE_PY, so it bills nothing: what it exercises is the abandon branch,
# the denominator and the halt, all of which are JSON in and text out. Everything else here
# needs a billed session and is not covered.
#
# WHY THIS EXISTS. tools/skill-cases.sh scores frozen transcripts. It answers "did this skill
# fire when the user typed this, back then" and it CANNOT see a description change — the same
# 13 rows come back before and after an edit. #156 shipped a description fix with no
# behavioural evidence for exactly that reason. This runs the prompt again, so a fix has a
# before and an after.
#
# IT IS NOT `claude plugin eval`. That is gated behind early access (#181) and would score the
# reply against graders/. This scores one thing: whether the Skill tool was invoked before the
# answer, which is what every grader in this suite asks.
#
# IT READS THE INSTALLED PLUGIN, NOT THIS TREE. The plugin is served from
# ~/.claude/plugins/cache/, so an edit here is invisible until `tools/plugin-reload.sh` runs.
# Reload between the before and the after or the two runs measure the same thing.
#
# IT COSTS MONEY. Each probe is a real session. It runs until the session's `result` line, its
# PROBE_TURN_CAP turns or its PROBE_TIMEOUT seconds, whichever comes first, and PROBE_BUDGET
# caps the rest. That is why this is not in tools/verify-all.sh: a gate that bills per run is
# not a gate. It does NOT stop at the first Skill call and it does NOT stop at the first turn
# of prose — see tools/skill-probe.py, which explains what each of those cost when it did.
#
# A RUN A RATE LIMIT DESTROYED IS NOT A MISS. tools/skill-probe.py detects a session the CLI
# cut short, states its back-off, and retries once; if the retry fails too it returns
# `unusable` and this script STOPS — the case is abandoned and so is the rest of the suite,
# printed before the next run would start. Stopping at the case boundary is not enough: a limit
# that is still on would cost two more billed attempts and another back-off for every case left,
# after this tool already knew. The abandoned case's rate is a fraction of the runs actually
# MEASURED, and a case that measured none prints NO DATA and tallies nothing.
# #213 lost two billed runs with no warning of either kind. PROBE_BACKOFF sets the wait.
#
# A RUNNER THAT CRASHES IS TREATED THE SAME WAY. If skill-probe.py exits non-zero, prints
# nothing, or prints something that is not JSON, that is a run which measured nothing too. Read
# as an empty `fired` list it would be scored as a miss — #213's failure one level up.
#
# NOT A DETERMINISTIC GATE. Activation is a model decision and repeats are not identical,
# which is why --runs exists and why the verdict is a rate against a threshold rather than a
# single pass or fail.
#
# THE THRESHOLD IS THE TOOL'S, NOT THE ISSUE'S. --threshold only colours the printed PASS/FAIL;
# the fractions beside it are the measurement. An issue asking for a particular bar has to pass
# it in, or compare the fractions itself and say which it did.

set -u
SELF="$(cd "$(dirname "$0")" && pwd)/$(basename "$0")"
cd "${PROBE_CD:-$(dirname "$0")/..}" || exit 1


# ---- selftest --------------------------------------------------------------------------
# What this loop does with the JSON it is handed, on canned JSON. PROBE_PY replaces the billed
# half, so nothing here opens a session. The four behaviours #269 added are the four this
# covers: the abandon branch, the halt, the denominator, and a runner that fails to speak.
selftest() {
  TMP="$(mktemp -d)"
  trap 'rm -rf "$TMP"' EXIT
  mkdir -p "$TMP/evals/aaa" "$TMP/evals/bbb"
  for c in aaa bbb; do
    printf 'expect:\n  - handoff\n' > "$TMP/evals/$c/case.yaml"
    printf 'read handoff\n' > "$TMP/evals/$c/prompt.md"
  done

  # PROBE_PY is handed to python, not to bash. On Windows a /tmp path is bash's fiction and
  # python cannot open it, so it is converted where cygpath exists and left alone where it
  # does not — which is also the POSIX case, where the two spellings are the same.
  winpath() {
    if command -v cygpath >/dev/null 2>&1; then cygpath -w "$1"; else printf '%s' "$1"; fi
  }

  cat > "$TMP/fake.py" <<'FAKE'
import os, sys, json
mode = os.environ.get("FAKE", "good")
d = os.path.dirname(os.path.abspath(__file__))
n = os.path.join(d, "count.txt")
c = int(open(n).read()) if os.path.exists(n) else 0
open(n, "w").write(str(c + 1))
good = {"fired": ["handoff"], "cut": "", "retried": "", "unusable": ""}
bad = {"fired": [], "cut": "error_during_execution",
       "retried": "error_during_execution", "unusable": "error_during_execution"}
if mode == "bad":
    print(json.dumps(bad))
elif mode == "retried":
    print(json.dumps(dict(good, retried="error_during_execution")))
elif mode == "late-bad":
    print(json.dumps(good if c == 0 else bad))
elif mode == "crash":
    sys.exit(3)
elif mode == "garbage":
    print("this is not json")
elif mode == "schemaless":
    print(json.dumps({"cut": "", "retried": "", "unusable": ""}))
else:
    print(json.dumps(good))
FAKE

  RUN=0; PASSED=0; FAILED=0
  # EVERY tunable is pinned, not just the ones this selftest sets deliberately. A gate that
  # reads PROBE_THRESHOLD or PROBE_TRANSCRIPT_DIR out of whoever's shell invoked verify-all.sh
  # fails for reasons that have nothing to do with the code, and writes transcripts outside
  # $TMP that the trap does not clean.
  probe() {
    rm -f "$TMP/count.txt"
    FAKE="$1"; shift
    FAKE="$FAKE" PROBE_SKIP_CLI_CHECK=1 PROBE_BACKOFF=0 PROBE_THRESHOLD=0.67 \
      PROBE_TRANSCRIPT_DIR="" PROBE_CD="" PROBE_TIMEOUT=300 \
      PROBE_PY="$(winpath "$TMP/fake.py")" PROBE_EVAL_DIR="$TMP/evals" \
      bash "$SELF" "$@" 2>&1
  }
  want() {
    NAME="$1"; NEEDLE="$2"; HAY="$3"
    RUN=$((RUN + 1))
    case "$HAY" in
      *"$NEEDLE"*) PASSED=$((PASSED + 1)); echo "  ok    $NAME" ;;
      *) FAILED=$((FAILED + 1)); echo "  FAIL  $NAME"; echo "        expected to find: $NEEDLE" ;;
    esac
  }
  wantnot() {
    NAME="$1"; NEEDLE="$2"; HAY="$3"
    RUN=$((RUN + 1))
    case "$HAY" in
      *"$NEEDLE"*) FAILED=$((FAILED + 1)); echo "  FAIL  $NAME"; echo "        did not expect: $NEEDLE" ;;
      *) PASSED=$((PASSED + 1)); echo "  ok    $NAME" ;;
    esac
  }

  echo "skill-probe.sh selftest — what this loop does with the JSON it is handed"
  echo

  O="$(probe good --runs 2)"
  want "a clean pair of runs scores normally"        "handoff                              PASS  2/2" "$O"
  wantnot "a clean run does not halt the suite"      "STOPPED EARLY" "$O"
  want "every case runs when nothing is unusable"    "bbb " "$O"

  O="$(probe bad --runs 3)"
  want "an unusable run says so, naming the reason"  "UNUSABLE: error_during_execution" "$O"
  want "a case that measured nothing prints NO DATA" "NO DATA" "$O"
  wantnot "and tallies no fraction at all"           "0/0" "$O"
  want "the suite stops rather than billing on"      "STOPPED EARLY: error_during_execution" "$O"
  wantnot "so the second case is never reached"      "bbb " "$O"

  O="$(probe late-bad --runs 3)"
  want "a case that measured 1 of 3 divides by 1"    "PASS  1/1" "$O"
  want "and says how many runs it actually measured" "(1 of 3 runs measured)" "$O"

  O="$(probe retried --runs 1)"
  want "a run that needed its retry is marked as such" "(retried after error_during_execution)" "$O"

  O="$(probe crash --runs 2)"
  want "a runner that exits non-zero is unusable"    "UNUSABLE: the probe runner exited 3" "$O"
  wantnot "and is not scored as a miss"              "fired: —" "$O"

  O="$(probe garbage --runs 2)"
  want "output that is not JSON is unusable"         "UNUSABLE: the probe runner printed something that is not JSON" "$O"
  wantnot "and is not scored as a miss either"       "fired: —" "$O"

  O="$(probe schemaless --runs 2)"
  want "JSON with no fired list is unusable"         "UNUSABLE: the probe runner printed JSON with no 'fired' list" "$O"

  # A crashed or silent runner made ONE attempt. Saying the retry failed sends the operator
  # looking for a back-off that was never waited out.
  O="$(probe crash --runs 1)"
  want "a runner that never spoke claims no retry"   "no retry was possible" "$O"
  O="$(probe bad --runs 1)"
  want "a runner that did retry says the retry failed" "the retry failed too" "$O"

  # The halt has to reach the exit status, or a wrapper records a suite that stopped on its
  # first case as a clean run.
  probe good --runs 1 >/dev/null 2>&1; ST=$?
  want "a fully measured suite exits 0"              "status 0" "status $ST"
  probe bad --runs 1 >/dev/null 2>&1; ST=$?
  want "a halted suite exits 2"                      "status 2" "status $ST"

  echo
  echo "$RUN cases, $PASSED passed, $FAILED failed"
  [ "$FAILED" = "0" ]
}

if [ "${1:-}" = "selftest" ]; then
  selftest
  exit $?
fi

EVAL_DIR="${PROBE_EVAL_DIR:-evals/skill-firing}"
RUNS=1
OPENINGS=0
ONLY=""
EXPECTING=""
THRESHOLD="${PROBE_THRESHOLD:-0.67}"

while [ "$#" -gt 0 ]; do
  case "$1" in
    --runs) RUNS="${2:-1}"; shift ;;
    --openings) OPENINGS=1 ;;
    --case) ONLY="${2:-}"; shift ;;
    --expect) EXPECTING="${2:-}"; shift ;;
    --threshold) THRESHOLD="${2:-0.67}"; shift ;;
    # The header ends where the code starts. A fixed last line silently truncates --help
    # every time the header grows, which it did twice in one issue.
    -h|--help) sed -n "2,$(($(grep -n '^set -u' "$0" | head -n1 | cut -d: -f1) - 1))p" "$0"; exit 0 ;;
    *) echo "unknown argument: $1" >&2; exit 2 ;;
  esac
  shift
done

if [ -z "${PROBE_SKIP_CLI_CHECK:-}" ]; then
  command -v claude >/dev/null 2>&1 || { echo "claude CLI not on PATH — nothing to probe" >&2; exit 2; }
fi

HERE="$(cd "$(dirname "$0")" && pwd)"
# The running half, overridable so the selftest can hand this loop canned JSON instead of a
# billed session. It is a python FILE PATH and is passed to python, not to bash — on Windows
# the selftest converts it, because a /tmp path bash understands is not one python can open.
PROBE_PY="${PROBE_PY:-$HERE/skill-probe.py}"

echo "skill-probe — ${RUNS} run(s) per case, threshold ${THRESHOLD}"
[ "$OPENINGS" = "1" ] && echo "openings only (source.opening: true)"
echo

# Accumulators, kept as newline-separated "skill fired total" records so the summary can be
# built without an associative array — this has to run under the bash that ships on Windows.
TALLY=""
# Set once a run comes back unusable. Non-empty means the suite stops after the current case,
# and the summary says why — a partial measurement that says so beats a full one that is wrong.
HALT=""

for CASEDIR in $(find "$EVAL_DIR" -name case.yaml | sort); do
  DIR="$(dirname "$CASEDIR")"
  NAME="${DIR#"$EVAL_DIR"/}"
  [ -n "$ONLY" ] && [ "$NAME" != "$ONLY" ] && continue
  if [ "$OPENINGS" = "1" ]; then
    grep -qE '^[[:space:]]+opening:[[:space:]]*true' "$CASEDIR" || continue
  fi
  EXPECT="$(sed -n '/^expect:/,/^[^ ]/p' "$CASEDIR" | sed -n 's/^[[:space:]]*-[[:space:]]*//p')"
  # --expect narrows to the cases that name one skill. Without it, re-measuring one skill's
  # firing rate means either running every opening — most of which are about other skills and
  # are billed the same — or naming each case by hand and aggregating the tallies afterwards,
  # which is how a reported rate stops being one command anyone can re-run.
  if [ -n "$EXPECTING" ]; then
    case " $(printf '%s' "$EXPECT" | tr '\n' ' ') " in
      *" $EXPECTING "*) ;;
      *) continue ;;
    esac
  fi
  PROMPT="$(cat "$DIR/prompt.md")"

  RUNLOG=""
  # Runs ATTEMPTED and measured, which is not $RUNS once a case is abandoned. A rate limit
  # that ends a case after one usable run must divide by one, not by three — #213 lost two
  # billed runs to one, and a 0/3 printed from them would have been a fabricated rate.
  DONE=0
  for r in $(seq 1 "$RUNS"); do
    # PROBE_TRANSCRIPT_DIR keeps the raw stream of every run, one file per run, named for the
    # case. `fired` says a skill was invoked and cannot say what the session then READ. The
    # stream does not carry the skill text either — measured — but it does carry the QUALIFIED
    # name, which identifies the file that does. tools/probe-handoff-checks.sh reads these.
    # Unset by default; nothing is written unless it is asked for.
    if [ -n "${PROBE_TRANSCRIPT_DIR:-}" ]; then
      mkdir -p "$PROBE_TRANSCRIPT_DIR"
      PROBE_TRANSCRIPT="$PROBE_TRANSCRIPT_DIR/$(printf '%s' "$NAME" | tr '/' '-')-run$r.jsonl"
      export PROBE_TRANSCRIPT
    fi
    # stderr is NOT swallowed here. skill-probe.py states its back-off on stderr, and a
    # warning routed into /dev/null is the same as no warning — which is what #213 had.
    OUT="$(python "$PROBE_PY" "$PROMPT")"; RC=$?
    # RETRIED is skill-probe.py's own report that it already backed off and tried again. It is
    # the ONLY thing that licenses saying so, which is why the two guards below clear it: a
    # runner that died or never spoke made one attempt, not two, and a message claiming
    # otherwise sends the operator looking for a back-off that never happened.
    FIRED=""; RETRIED=""; UNUSABLE=""
    if [ "$RC" -ne 0 ] || [ -z "$OUT" ]; then
      if [ "$RC" -ne 0 ]; then
        UNUSABLE="the probe runner exited $RC with no readable output"
      else
        UNUSABLE="the probe runner printed nothing"
      fi
    else
      # A parse failure is an unusable run, not an empty `fired` list. python exits non-zero on
      # bad JSON, and the || is what turns that into a stated reason instead of a silent miss.
      UNUSABLE="$(printf '%s' "$OUT" | python -c "import json,sys; print(json.loads(sys.stdin.read()).get('unusable',''))" 2>/dev/null)" \
        || UNUSABLE="the probe runner printed something that is not JSON"
      # Read whether or not the run is usable: a run that WAS retried and failed anyway
      # reports both keys, and that is exactly the case the abandon message describes.
      RETRIED="$(printf '%s' "$OUT" | python -c "import json,sys; print(json.loads(sys.stdin.read()).get('retried',''))" 2>/dev/null)" \
        || RETRIED=""
      if [ -z "$UNUSABLE" ]; then
        # `fired` is REQUIRED, not defaulted. Reading a missing key as an empty list is the
        # same defect one line further on: a run that measured nothing scored as a miss.
        FIRED="$(printf '%s' "$OUT" | python -c "import json,sys; print(' '.join(json.loads(sys.stdin.read())['fired']))" 2>/dev/null)" \
          || UNUSABLE="the probe runner printed JSON with no 'fired' list"
      fi
    fi
    if [ -n "$UNUSABLE" ]; then
      # Said BEFORE the next run would start. skill-probe.py has already retried once and the
      # retry failed too, so the whole suite stops: continuing bills two more attempts and
      # another back-off per remaining case into a limit this tool already knows about, and
      # tallies each empty `fired` list as a miss.
      NOTE="$([ -n "$RETRIED" ] && printf 'the retry failed too' || printf 'no retry was possible')"
      printf '  %-38s run %d  UNUSABLE: %s — %s; abandoning this case after %d measured run(s)\n' \
        "$NAME" "$r" "$UNUSABLE" "$NOTE" "$DONE"
      HALT="$UNUSABLE"
      break
    fi
    DONE=$((DONE+1))
    RUNLOG="${RUNLOG}${FIRED}
"
    printf '  %-38s run %d  fired: %s%s\n' "$NAME" "$r" "${FIRED:-—}" \
      "$([ -n "$RETRIED" ] && printf '   (retried after %s)' "$RETRIED")"
  done

  if [ "$DONE" -eq 0 ]; then
    # No verdict and no tally row. A case that produced no measurement contributes nothing:
    # printing FAIL 0/0 here is how a rate limit gets recorded as a firing defect.
    printf '    %-36s %s\n' "(nothing measured)" "NO DATA"
    echo
    [ -n "$HALT" ] && break
    continue
  fi

  for SK in $EXPECT; do
    # "none" is a control and "*>=8" is the bulk-load case's count assertion. Neither is a
    # skill name, and a probe scores one skill at a time.
    [ "$SK" = "none" ] && continue
    case "$SK" in \**) continue ;; esac
    HIT=0
    while IFS= read -r line; do
      [ -z "$line" ] && continue
      case " $line " in *" $SK "*) HIT=$((HIT+1)) ;; esac
    done <<EOF
$RUNLOG
EOF
    VERDICT="$(python -c "import sys; h=$HIT; n=$DONE; print('PASS' if n and h/n >= $THRESHOLD else 'FAIL')")"
    printf '    %-36s %s  %d/%d%s\n' "$SK" "$VERDICT" "$HIT" "$DONE" \
      "$([ "$DONE" -lt "$RUNS" ] && printf '   (%d of %d runs measured)' "$DONE" "$RUNS")"
    TALLY="${TALLY}${SK} ${HIT} ${DONE}
"
  done
  echo
  [ -n "$HALT" ] && break
done

echo "skill expected               fired"
printf '%s' "$TALLY" | awk 'NF{h[$1]+=$2; n[$1]+=$3} END{for (k in h) printf "%-28s %d/%d\n", k, h[k], n[k]}' | sort

echo
if [ -n "$HALT" ]; then
  echo "STOPPED EARLY: $HALT"
  echo "The fractions above cover the runs that were measured. Any case after this one did not run."
  echo
fi
echo "A rate here is a measurement of the plugin as installed, not of this working tree."
echo "Run tools/plugin-reload.sh after an edit or the after-run repeats the before-run."

# 2, not 0 and not 1. A halt is "I could not measure what you asked", the same answer
# tools/verify-linked-branch.sh gives to a read it could not make — never 1, which in this
# repository marks a finding. A wrapper that redirects this to a file and moves on would
# otherwise record a suite that stopped on its first case as a clean run.
[ -n "$HALT" ] && exit 2
exit 0
