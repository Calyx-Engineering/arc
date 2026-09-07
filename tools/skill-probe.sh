#!/usr/bin/env bash
# skill-probe.sh — re-run the eval prompts against the plugin as it is installed now.
#
#   tools/skill-probe.sh                       every case, one run each
#   tools/skill-probe.sh --openings --runs 3   only cases whose source says opening: true
#   tools/skill-probe.sh --case wrapped/handoff-camp-catch-up
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
# IT COSTS MONEY. Each probe is a real session. It is stopped at the first Skill call, at the
# first answer given without one, or at PROBE_TURN_CAP turns, and PROBE_BUDGET caps the rest.
# That is why this is not in tools/verify-all.sh: a gate that bills per run is not a gate.
#
# NOT A DETERMINISTIC GATE. Activation is a model decision and repeats are not identical,
# which is why --runs exists and why the verdict is a rate against a threshold rather than a
# single pass or fail.

set -u
cd "${PROBE_CD:-$(dirname "$0")/..}" || exit 1

EVAL_DIR="${PROBE_EVAL_DIR:-evals/skill-firing}"
RUNS=1
OPENINGS=0
ONLY=""
THRESHOLD="${PROBE_THRESHOLD:-0.67}"

while [ "$#" -gt 0 ]; do
  case "$1" in
    --runs) RUNS="${2:-1}"; shift ;;
    --openings) OPENINGS=1 ;;
    --case) ONLY="${2:-}"; shift ;;
    --threshold) THRESHOLD="${2:-0.67}"; shift ;;
    -h|--help) sed -n "2,28p" "$0"; exit 0 ;;
    *) echo "unknown argument: $1" >&2; exit 2 ;;
  esac
  shift
done

command -v claude >/dev/null 2>&1 || { echo "claude CLI not on PATH — nothing to probe" >&2; exit 2; }

HERE="$(cd "$(dirname "$0")" && pwd)"

echo "skill-probe — ${RUNS} run(s) per case, threshold ${THRESHOLD}"
[ "$OPENINGS" = "1" ] && echo "openings only (source.opening: true)"
echo

# Accumulators, kept as newline-separated "skill fired total" records so the summary can be
# built without an associative array — this has to run under the bash that ships on Windows.
TALLY=""

for CASEDIR in $(find "$EVAL_DIR" -name case.yaml | sort); do
  DIR="$(dirname "$CASEDIR")"
  NAME="${DIR#"$EVAL_DIR"/}"
  [ -n "$ONLY" ] && [ "$NAME" != "$ONLY" ] && continue
  if [ "$OPENINGS" = "1" ]; then
    grep -qE '^[[:space:]]+opening:[[:space:]]*true' "$CASEDIR" || continue
  fi
  EXPECT="$(sed -n '/^expect:/,/^[^ ]/p' "$CASEDIR" | sed -n 's/^[[:space:]]*-[[:space:]]*//p')"
  PROMPT="$(cat "$DIR/prompt.md")"

  RUNLOG=""
  for r in $(seq 1 "$RUNS"); do
    OUT="$(python "$HERE/skill-probe.py" "$PROMPT" 2>/dev/null)"
    FIRED="$(printf '%s' "$OUT" | python -c 'import json,sys; print(" ".join(json.load(sys.stdin)["fired"]))' 2>/dev/null)"
    RUNLOG="${RUNLOG}${FIRED}
"
    printf '  %-38s run %d  fired: %s\n' "$NAME" "$r" "${FIRED:-—}"
  done

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
    VERDICT="$(python -c "import sys; h=$HIT; n=$RUNS; print('PASS' if n and h/n >= $THRESHOLD else 'FAIL')")"
    printf '    %-36s %s  %d/%d\n' "$SK" "$VERDICT" "$HIT" "$RUNS"
    TALLY="${TALLY}${SK} ${HIT} ${RUNS}
"
  done
  echo
done

echo "skill expected               fired"
printf '%s' "$TALLY" | awk 'NF{h[$1]+=$2; n[$1]+=$3} END{for (k in h) printf "%-28s %d/%d\n", k, h[k], n[k]}' | sort

echo
echo "A rate here is a measurement of the plugin as installed, not of this working tree."
echo "Run tools/plugin-reload.sh after an edit or the after-run repeats the before-run."
