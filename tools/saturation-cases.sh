#!/usr/bin/env bash
# saturation-cases.sh — score evals/saturation: did the session propose handing off before the
# user said the context was full?
#
#   tools/saturation-cases.sh             score every case against the transcript it came from
#   tools/saturation-cases.sh --strict    also fail when a case's transcript is not on this machine
#   tools/saturation-cases.sh --probe     replay the case's turns live and score the replies. BILLED
#   tools/saturation-cases.sh --case <s>  restrict --probe to one case directory
#   tools/saturation-cases.sh selftest    fixtures only, no corpus needed
#
#   SAT_PROBE_OUT=path   keep the probe's raw replies instead of losing them with the temp dir
#   ARC_EVAL_CORPUS=DIR  where the cases live when they are not in this repository — DIR holds
#                        saturation/. Unset, the cases are read from evals/saturation.
#
# WHY THIS EXISTS. tools/skill-cases.sh asks whether a skill fired in response to one prompt.
# Self-saturation has no prompt: the whole defect is that the user has not said anything yet.
# The condition is a property of the session — turns spent, ground re-covered, the subject the
# load has drifted onto — so the case is a turn SEQUENCE and the question is which turn in it
# the proposal landed on. #154.
#
# WHY IT REUSES tools/response-length-probe.py. That runner already replays a case's turns as
# ONE conversation, which is the only way a long session exists to be measured; its header says
# it is not length-specific. A second copy would be a second place for the allow/deny lists to
# drift.
#
# THE PROBE IS NOT A GATE. It bills per turn and the case is 52 turns long, so tests/verify-all.sh
# runs the selftest — fixtures, free, portable — exactly as it does for every other eval suite.
#
# THE CORPUS IS LOCAL. Transcripts live under ~/.claude/projects on one machine, so a case whose
# session is absent is reported and skipped rather than failed.

set -u
cd "${SAT_CD:-$(dirname "$0")/..}" || exit 1

HERE="$(cd "$(dirname "$0")" && pwd)"
STRICT=0
SELFTEST=0
PROBE=0
ONLY=""

while [ "$#" -gt 0 ]; do
  case "$1" in
    selftest) SELFTEST=1 ;;
    --strict) STRICT=1 ;;
    --probe) PROBE=1 ;;
    --case) ONLY="${2:-}"; shift ;;
    -h|--help) sed -n "2,30p" "$0"; exit 0 ;;
    *) echo "unknown argument: $1" >&2; exit 2 ;;
  esac
  shift
done

score() {  # score <projects-root> <eval-dir> [probe-json]
  local mode=replay
  [ -n "${3:-}" ] && mode=probe
  SAT_ROOT_DIR="$1" SAT_EVAL_DIR="$2" SAT_STRICT="$STRICT" \
  SAT_MODE="$mode" SAT_PROBE_JSON="${3:-}" python "$HERE/saturation-cases.py"
}

if [ "$SELFTEST" = "1" ]; then
  T="$(mktemp -d)"
  [ -n "$T" ] || { echo "mktemp -d returned nothing" >&2; exit 2; }
  trap 'rm -rf "$T"' EXIT
  P="$T/projects/r--fixture"
  E="$T/evals"
  mkdir -p "$P"

  hu() { printf '{"type":"user","origin":{"kind":"human"},"timestamp":"t","message":{"content":"%s"}}\n' "$1"; }
  as() { printf '{"type":"assistant","timestamp":"t","message":{"content":[{"type":"text","text":"%s"}]}}\n' "$1"; }
  fire() { printf '{"type":"assistant","timestamp":"t","message":{"content":[{"type":"tool_use","name":"Skill","input":{"skill":"arc:work-watch"}}]}}\n'; }

  filename() { printf '{"type":"assistant","timestamp":"t","message":{"content":[{"type":"text","text":"Added the next steps to HANDOFF.md and committed a checkpoint of the table."}]}}\n'; }
  other() { printf '{"type":"assistant","timestamp":"t","message":{"content":[{"type":"tool_use","name":"Skill","input":{"skill":"arc:handoff"}}]}}\n'; }

  # mkcase <slug> <turns> <callout> <fires_from> <fire-turn|0> <say-turn|0> [variant]
  # A case's transcript is <turns> plain exchanges, with the skill fired on <fire-turn> and the
  # proposal wording said on <say-turn>. Separating the two is what lets one fixture assert
  # "proposed with no skill fire" without also asserting a verdict change.
  #
  # variant  filename   <say-turn> instead mentions the FILE called HANDOFF.md, which is what
  #                     the corpus is full of and what the first version of this scan matched
  #          other      <fire-turn> fires a different skill, so `expect` is what has to reject it
  mkcase() {
    local slug="$1" n="$2" callout="$3" from="$4" ft="$5" st="$6" variant="${7:-}" i
    mkdir -p "$E/$slug/turns" "$E/$slug/graders"
    printf 'callout_turn: %s\nfires_from: %s\nexpect:\n  - work-watch\nsource:\n  session: %s\n  first_turn: 1\n  last_turn: %s\nwhy: fixture\n' \
      "$callout" "$from" "sess$slug" "$n" > "$E/$slug/case.yaml"
    printf '# grader\n' > "$E/$slug/graders/before-the-user.md"
    {
      for i in $(seq 1 "$n"); do
        hu "turn $i please"
        if [ "$i" = "$ft" ]; then
          [ "$variant" = "other" ] && other || fire
        fi
        if [ "$i" = "$st" ]; then
          if [ "$variant" = "filename" ]; then
            filename
          else
            as "we are deep in this one. want me to checkpoint and hand off to a fresh session?"
          fi
        else
          as "done, turn $i"
        fi
      done
    } > "$P/sess$slug.jsonl"
    for i in $(seq 1 "$n"); do
      printf 'turn %s please\n' "$i" > "$E/$slug/turns/$i.md"
    done
  }

  mkcase held     8 8 4 5 5
  mkcase late     8 8 4 8 8
  mkcase early    8 8 4 2 2
  mkcase silent   8 8 4 0 0
  mkcase guessed  8 8 4 0 5
  mkcase editing  8 8 4 5 5 filename
  mkcase wrongsk  8 8 4 5 5 other

  mkdir -p "$E/absent/turns" "$E/absent/graders"
  printf 'callout_turn: 8\nfires_from: 4\nexpect:\n  - work-watch\nsource:\n  session: nowhere9\n  first_turn: 1\n  last_turn: 8\nwhy: fixture\n' \
    > "$E/absent/case.yaml"
  printf '# grader\n' > "$E/absent/graders/before-the-user.md"
  printf 'turn 1 please\n' > "$E/absent/turns/1.md"

  out="$(score "$T/projects" "$E" 2>&1)"; st=$?
  Pc=0; Fc=0
  t() {
    if printf '%s' "$out" | grep -qE -- "$2"; then echo "  PASS  $1"; Pc=$((Pc+1))
    else
      echo "  FAIL  $1"; echo "        wanted /$2/"; echo "        got:"
      printf '%s\n' "$out" | sed 's/^/          /'; Fc=$((Fc+1))
    fi
  }

  t "a fire inside the window is held"                 "^  held +HELD"
  t "a fire on the callout turn is late, not a pass"   "^  late +LATE"
  t "a fire before fires_from is early, not a pass"    "^  early +EARLY"
  t "a session that never proposed is silent"          "^  silent +SILENT"
  t "a proposal with no skill fire is not a pass"      "^  guessed +SILENT"
  t "and that turn is named, with its sentence"        "turn 5 proposed with no skill fire — the model guessing: want me to checkpoint"
  t "the matching sentence is printed, not summarised" "turn 5: want me to checkpoint and hand off"
  t "a reply about the FILE HANDOFF.md is not a proposal" "^  editing +SILENT"
  t "a fire of the wrong skill is not the expected one" "^  wrongsk +SILENT"
  t "an absent transcript is reported and skipped"     "^  absent +transcript nowhere9 not on this machine"
  t "the tally separates scored from total"            "7 of 8 case\(s\) scored: 1 held, 1 late, 1 early, 4 silent, 0 thin"
  t "replay says it cannot see a change to the skill"  "Replay is the baseline"
  [ "$st" = "0" ] && { echo "  PASS  a clean run exits 0"; Pc=$((Pc+1)); } \
                  || { echo "  FAIL  a clean run exits 0 (got $st)"; Fc=$((Fc+1)); }

  # Drift must fail, and must fail loudly.
  printf 'turn 5 please, but tidied up\n' > "$E/held/turns/5.md"
  dout="$(score "$T/projects" "$E" 2>&1)"; dst=$?
  if printf '%s' "$dout" | grep -q "PROMPT DRIFT" && [ "$dst" != "0" ]; then
    echo "  PASS  an edited turn is caught as drift and exits non-zero"; Pc=$((Pc+1))
  else
    echo "  FAIL  an edited turn is caught as drift and exits non-zero (exit $dst)"; Fc=$((Fc+1))
  fi
  printf 'turn 5 please\n' > "$E/held/turns/5.md"

  # --strict turns an absent transcript into a failure; the default does not.
  sst="$(SAT_ROOT_DIR="$T/projects" SAT_EVAL_DIR="$E" SAT_STRICT=1 SAT_MODE=replay \
         python "$HERE/saturation-cases.py" >/dev/null 2>&1; echo $?)"
  [ "$sst" != "0" ] && { echo "  PASS  --strict fails on an absent transcript"; Pc=$((Pc+1)); } \
                    || { echo "  FAIL  --strict fails on an absent transcript"; Fc=$((Fc+1)); }

  # Probe mode scores the runner's JSON, and asks the same two questions of it.
  # The eval dir is the parent of the cases, so point it at a directory holding only `held`.
  PJ="$T/probe.json"
  mkdir -p "$T/one" && cp -r "$E/held" "$T/one/held"
  printf '{"held":{"5":{"text":"want me to checkpoint and hand off to a fresh session?","cut":"","fired":["work-watch"]}}}\n' > "$PJ"
  pout="$(SAT_ROOT_DIR="$T/projects" SAT_EVAL_DIR="$T/one" SAT_STRICT=0 \
          SAT_MODE=probe SAT_PROBE_JSON="$PJ" python "$HERE/saturation-cases.py" 2>&1)"
  if printf '%s' "$pout" | grep -qE "^  held +HELD" && ! printf '%s' "$pout" | grep -q "Replay is the baseline"; then
    echo "  PASS  probe mode scores the runner's replies and drops the replay caveat"; Pc=$((Pc+1))
  else
    echo "  FAIL  probe mode scores the runner's replies and drops the replay caveat"
    printf '%s\n' "$pout" | sed 's/^/          /'; Fc=$((Fc+1))
  fi

  # A turn the runner cut is truncated, and its truncated text can still carry the wording. The
  # cut turn here is BEFORE fires_from and proposal-shaped: without the drop the case scores
  # EARLY on turn 3 — a verdict about the runner's budget, not about the session.
  printf '{"held":{"3":{"text":"want me to hand off?","cut":"error_max_budget","fired":["work-watch"]},"6":{"text":"want me to checkpoint and hand off?","cut":"","fired":["work-watch"]}}}\n' > "$PJ"
  cout="$(SAT_ROOT_DIR="$T/projects" SAT_EVAL_DIR="$T/one" SAT_STRICT=0 \
          SAT_MODE=probe SAT_PROBE_JSON="$PJ" python "$HERE/saturation-cases.py" 2>&1)"
  if printf '%s' "$cout" | grep -qE "^  held +HELD" \
     && printf '%s' "$cout" | grep -q "1 turn(s) cut by the runner and not scored: 3"; then
    echo "  PASS  a cut turn is dropped from the scan, not scored as a verdict"; Pc=$((Pc+1))
  else
    echo "  FAIL  a cut turn is dropped from the scan, not scored as a verdict"
    printf '%s\n' "$cout" | sed 's/^/          /'; Fc=$((Fc+1))
  fi

  # A cut OUTSIDE the window says nothing about the window, so the verdict stays SILENT. Without
  # this case, "any cut makes it thin" would pass every other assertion here.
  printf '{"held":{"2":{"text":"","cut":"error_max_budget","fired":[]},"6":{"text":"done","cut":"","fired":["work-watch"]}}}\n' > "$PJ"
  oout="$(SAT_ROOT_DIR="$T/projects" SAT_EVAL_DIR="$T/one" SAT_STRICT=0 \
          SAT_MODE=probe SAT_PROBE_JSON="$PJ" python "$HERE/saturation-cases.py" 2>&1)"
  if printf '%s' "$oout" | grep -qE "^  held +SILENT" \
     && ! printf '%s' "$oout" | grep -q "inside the window"; then
    echo "  PASS  a cut outside the window leaves the verdict alone"; Pc=$((Pc+1))
  else
    echo "  FAIL  a cut outside the window leaves the verdict alone"
    printf '%s\n' "$oout" | sed 's/^/          /'; Fc=$((Fc+1))
  fi

  # And a window that was never fully run is not a session that stayed quiet.
  printf '{"held":{"5":{"text":"","cut":"error_max_budget","fired":[]},"6":{"text":"","cut":"error_max_budget","fired":[]}}}\n' > "$PJ"
  tout="$(SAT_ROOT_DIR="$T/projects" SAT_EVAL_DIR="$T/one" SAT_STRICT=0 \
          SAT_MODE=probe SAT_PROBE_JSON="$PJ" python "$HERE/saturation-cases.py" 2>&1)"
  if printf '%s' "$tout" | grep -qE "^  held +THIN" \
     && printf '%s' "$tout" | grep -q "2 inside the window, so the window was never fully run"; then
    echo "  PASS  a cut inside the window is thin, never silent"; Pc=$((Pc+1))
  else
    echo "  FAIL  a cut inside the window is thin, never silent"
    printf '%s\n' "$tout" | sed 's/^/          /'; Fc=$((Fc+1))
  fi

  # The probe REPLAYS the stored turns, so it is the run that most needs the verbatim claim
  # checked — and the one that would never check it if drift were a replay-mode concern.
  printf '{"held":{"6":{"text":"want me to checkpoint and hand off?","cut":"","fired":["work-watch"]}}}\n' > "$PJ"
  printf 'turn 5 please, but tidied up\n' > "$T/one/held/turns/5.md"
  gout="$(SAT_ROOT_DIR="$T/projects" SAT_EVAL_DIR="$T/one" SAT_STRICT=0 \
          SAT_MODE=probe SAT_PROBE_JSON="$PJ" python "$HERE/saturation-cases.py" 2>&1)"; gst=$?
  if printf '%s' "$gout" | grep -q "PROMPT DRIFT" && [ "$gst" != "0" ]; then
    echo "  PASS  probe mode checks the turns against the transcript too"; Pc=$((Pc+1))
  else
    echo "  FAIL  probe mode checks the turns against the transcript too (exit $gst)"
    printf '%s\n' "$gout" | sed 's/^/          /'; Fc=$((Fc+1))
  fi
  printf 'turn 5 please\n' > "$T/one/held/turns/5.md"

  echo
  echo "$Pc passed, $Fc failed"
  [ "$Fc" = "0" ] || exit 1
  exit 0
fi

# #320: the case is a verbatim 52-turn client session, so it lives outside the published
# repository. ARC_EVAL_CORPUS says where — the directory that holds saturation/.
EVAL_DIR="${ARC_EVAL_CORPUS:+$ARC_EVAL_CORPUS/saturation}"
EVAL_DIR="${EVAL_DIR:-evals/saturation}"
[ -d "$EVAL_DIR" ] || { echo "no cases at $EVAL_DIR — set ARC_EVAL_CORPUS to the directory that holds saturation/" >&2; exit 2; }

if [ "$PROBE" = "0" ]; then
  score "${MINER_PROJECTS_ROOT:-$HOME/.claude/projects}" "$EVAL_DIR"
  exit $?
fi

command -v claude >/dev/null 2>&1 || { echo "claude CLI not on PATH — nothing to probe" >&2; exit 2; }

# The raw replies outlive the run only when asked for. The runner opens the path "w"
# unconditionally, so anything there that is not already probe JSON stops the run before a
# turn is billed.
OUT="${SAT_PROBE_OUT:-$(mktemp -d)/probe.json}"
if [ -n "${SAT_PROBE_OUT:-}" ] && [ -e "$OUT" ]; then
  if ! python -c "import json,sys;json.load(open(sys.argv[1]))" "$OUT" 2>/dev/null; then
    echo "SAT_PROBE_OUT=$OUT exists and is not probe JSON — refusing to overwrite it" >&2
    exit 2
  fi
fi

echo "saturation --probe — live against the INSTALLED plugin. This bills per turn."
for DIR in "$EVAL_DIR"/*/; do
  NAME="$(basename "$DIR")"
  [ -n "$ONLY" ] && [ "$NAME" != "$ONLY" ] && continue
  echo "  $NAME"
  RL_PROBE_CWD="$(pwd)" python "$HERE/response-length-probe.py" "$DIR" "$NAME" "$OUT" || exit 1
done

score "${MINER_PROJECTS_ROOT:-$HOME/.claude/projects}" "$EVAL_DIR" "$OUT"
