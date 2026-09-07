#!/usr/bin/env bash
# topic-numbering.sh — score the eval cases in evals/topic-numbering: when a reply raised
# several topics, could the user answer it by number?
#
#   tools/topic-numbering.sh              replay the transcripts the cases came from
#   tools/topic-numbering.sh --strict     also fail when a case's transcript is not on this machine
#   tools/topic-numbering.sh --probe      re-run the turns live against the installed plugin
#   tools/topic-numbering.sh selftest     fixtures only, no corpus needed
#
#   --threshold N    the rate a case must clear. Default 0.67
#   --case NAME      probe one case only. Ignored in replay, which always scores every case
#   --runs N         repeat each case N times under --probe, scoring between runs
#
#   TN_PROBE_OUT=path   keep the probe's raw replies instead of losing them with the temp
#                       directory. Without it a billed run cannot be re-scored later, which
#                       is how six runs had to be re-taken when the scorer was corrected
#   RL_PROBE_BUDGET=n   per-turn cost cap, passed through to the shared probe runner
#
# WHY THIS EXISTS. #160: numbered discussion topics are used at the start of a reply and
# dropped part-way through, so the user cannot answer by number. tools/response-length.sh
# counts words and tools/skill-cases.sh counts activations; neither can see whether the
# sections of a reply carry labels. This is a third question and needs a third instrument.
#
# IT DOES NOT NEED A MODEL TO GRADE IT, for the same reason response-length.sh does not.
# "Does every top-level section of this reply start with a label" is countable. `claude plugin
# eval` is still gated (#181) and is still what a judgement-shaped grader would need; this is
# not one.
#
# PARTIAL NUMBERING IS A FAIL. A reply that labels its first two topics and drops the rest is
# scored beside the reply that labelled none. The user cannot tell which topics they may
# answer by number, so they restate all of them — and it reads like progress, which is worse
# than plainly having none. tools/topic-numbering.py carries the rest of the rules.
#
# TWO MODES, AND ONLY ONE CAN SEE A FIX.
#
#   replay (default)  Reads the recorded transcript. Free, deterministic, and blind to any
#                     edit made after the session. It is the baseline: what happened.
#   --probe           Replays the turns as one live conversation. Billed. This is the half
#                     that can score a change to the skill.
#
# THE PROBE RUNNER IS SHARED. --probe calls tools/response-length-probe.py, which replays a
# case's turns/ as one session and records what came back. Nothing in it is length-specific —
# it produces replies, and the scorer asks the question. A second copy would be a second place
# for the allow/deny tool lists and the cut-detection to drift.
#
# THE VERBATIM CLAIM IS CHECKED, NOT TRUSTED. Every turns/<n>.md is compared against the turn
# it claims to copy, both directions, and drift fails the run.
#
# THE CORPUS IS LOCAL. Transcripts live under ~/.claude/projects on one machine, so a case
# whose session is absent is reported and skipped. Only the selftest is portable, which is why
# it is the part wired into tools/verify-all.sh.

set -u
# Resolved BEFORE the cd, or `dirname "$0"` is read against the new working directory and a
# run started from anywhere but the repo root looks for its scorer in the wrong place.
HERE="$(cd "$(dirname "$0")" && pwd)"
cd "${TN_CD:-$HERE/..}" || exit 1
STRICT=0
SELFTEST=0
PROBE=0
RUNS=1
ONLY=""

while [ "$#" -gt 0 ]; do
  case "$1" in
    selftest) SELFTEST=1 ;;
    --strict) STRICT=1 ;;
    --probe) PROBE=1 ;;
    --runs) RUNS="${2:-1}"; shift ;;
    --case) ONLY="${2:-}"; shift ;;
    --threshold) TN_THRESHOLD="${2:-0.67}"; export TN_THRESHOLD; shift ;;
    -h|--help) sed -n "2,53p" "$0"; exit 0 ;;
    *) echo "unknown argument: $1" >&2; exit 2 ;;
  esac
  shift
done

score() {  # score <projects-root> <eval-dir> [probe-json]
  # As in response-length.sh: set the mode either way, so an empty TN_PROBE_JSON does not
  # leave the mode as the empty string and silently drop the replay-only notes.
  local mode=replay
  [ -n "${3:-}" ] && mode=probe
  TN_ROOT_DIR="$1" TN_EVAL_DIR="$2" TN_STRICT="$STRICT" \
  TN_MODE="$mode" TN_PROBE_JSON="${3:-}" python "$HERE/topic-numbering.py"
}

if [ "$SELFTEST" = "1" ]; then
  T="$(mktemp -d)"
  trap 'rm -rf "$T"' EXIT
  P="$T/projects/r--fixture"
  E="$T/evals"
  mkdir -p "$P"

  hu() { printf '{"type":"user","origin":{"kind":"human"},"timestamp":"%s","message":{"content":%s}}\n' "$1" "$2"; }
  as() { printf '{"type":"assistant","timestamp":"t","message":{"content":[{"type":"text","text":%s}]}}\n' "$(python -c 'import json,sys;print(json.dumps(sys.stdin.read()))' <<<"$1")"; }

  {
    hu 2026-09-01T10:00 '"several topics please"'
    as "$(printf '## D1 - the first thing\n\nsome prose.\n\n## D2 - the second thing\n\nmore prose.\n')"
    hu 2026-09-01T10:01 '"again"'
    # Labelled, then not. This is the defect: the user cannot tell which half is answerable.
    as "$(printf '## V1 - the first thing\n\nsome prose.\n\n## Where this lands\n\nmore prose.\n')"
    hu 2026-09-01T10:02 '"and again"'
    as "$(printf '## What I got wrong\n\na.\n\n## What holds up\n\nb.\n\n## On the name\n\nc.\n')"
    hu 2026-09-01T10:03 '"once more"'
    as "$(printf '## 1. Branch from the sub-branch\n\na.\n\n## 2. Patch series\n\nb.\n')"
    hu 2026-09-01T10:04 '"one thing"'
    # One top-level section. The deeper heading is its internals and the fenced one is sample
    # text; counting either would invent a second topic and score the reply UNNUMBERED.
    as "$(printf '## Just the one\n\n### a sub-point\n\ntext\n\n```\n## Not a topic\n## Also not a topic\n```\n')"
    hu 2026-09-01T10:05 '"no sections"'
    as "$(printf 'Plain prose with no sections at all, so there is nothing here to number.\n')"
    hu 2026-09-01T10:06 '"bold only"'
    # Two bold lead-ins, neither labelled — indistinguishable from ordinary emphasis, and the
    # shape of the skill's own single-decision template. No evidence of topics: NOTOPICS.
    as "$(printf '**First thing**\n\ntext\n\n**Second thing**\n\ntext\n')"
    hu 2026-09-01T10:07 '"designators"'
    # Component designators and back-references, not labels: no separator after the token.
    as "$(printf '## F5 test plan\n\na.\n\n## R3 estimate\n\nb.\n')"
    hu 2026-09-01T10:08 '"inline bold"'
    # The shape of session 0c28d2ed t127 — no headings, labels inline with prose after them,
    # and an ordinary emphasis lead-in beside them. A pattern anchored to the end of the line
    # sees none of it. Two of the three carry labels and one does not, and nothing separates a
    # dropped topic from an emphasis opening: BOLDONLY, reported rather than guessed.
    as "$(printf '**D1 - new mechanism or extend m12?** I lean new. m12 is issue linking.\n\n**D2 - on or off?** I lean off, offered at arc start.\n\n**Fails closed.** Any check errors and it does not flip.\n')"
    hu 2026-09-01T10:09 '"title over sections"'
    # A lone title above the sections. Taking the shallowest level unconditionally would call
    # this one topic and drop three unlabelled ones out of the measurement entirely.
    as "$(printf '# The answer\n\n## What I got wrong\n\na.\n\n## What holds up\n\nb.\n\n## On the name\n\nc.\n')"
    hu 2026-09-01T10:10 '"dot and paren"'
    as "$(printf '## D1. the first thing\n\na.\n\n## D2) the second thing\n\nb.\n')"
    hu 2026-09-01T10:11 '"nested fence"'
    # A ~~~ line inside a ``` block does not close it. If it did, ## Sneaky becomes a topic.
    as "$(printf '## Only one\n\n```\n~~~\n## Sneaky\n```\n')"
    hu 2026-09-01T10:12 '"bold, all labelled"'
    # Every lead-in labelled: nothing was dropped, so there is nothing ambiguous to withhold.
    as "$(printf '**D1 - the first thing** I lean this way.\n\n**D2 - the second thing** And this.\n')"
    hu 2026-09-01T10:13 '"section with sub-points"'
    # One section with two sub-points. Descending to the level that has siblings would score a
    # one-topic reply as two unlabelled topics — a fail, in the denominator.
    as "$(printf '## Only section\n\n### a sub-point\n\na.\n\n### another\n\nb.\n')"
    hu 2026-09-01T10:14 '"fence inside a fence"'
    # A ``` run inside a ```` block is content. Closing on it leaks ## Sneaky into the topics.
    as "$(printf '## Only one\n\n````\n```\n## Sneaky\n```\n````\n')"
  } > "$P/ccc33333.jsonl"

  mk() {  # mk <slug> <session> <first> <last>
    mkdir -p "$E/$1/turns" "$E/$1/graders"
    printf 'min_topics: 2\nsource:\n  session: %s\n  first_turn: %s\n  last_turn: %s\n' \
      "$2" "$3" "$4" > "$E/$1/case.yaml"
    printf '# grader\n' > "$E/$1/graders/every-topic-labelled.md"
  }

  mk shapes ccc33333 1 15
  printf 'several topics please\n' > "$E/shapes/turns/1.md"
  printf 'again\n'                 > "$E/shapes/turns/2.md"
  printf 'and again\n'             > "$E/shapes/turns/3.md"
  printf 'once more\n'             > "$E/shapes/turns/4.md"
  printf 'one thing\n'             > "$E/shapes/turns/5.md"
  printf 'no sections\n'           > "$E/shapes/turns/6.md"
  printf 'bold only\n'             > "$E/shapes/turns/7.md"
  printf 'designators\n'           > "$E/shapes/turns/8.md"
  printf 'inline bold\n'           > "$E/shapes/turns/9.md"
  printf 'title over sections\n'   > "$E/shapes/turns/10.md"
  printf 'dot and paren\n'         > "$E/shapes/turns/11.md"
  printf 'nested fence\n'          > "$E/shapes/turns/12.md"
  printf 'bold, all labelled\n'    > "$E/shapes/turns/13.md"
  printf 'section with sub-points\n' > "$E/shapes/turns/14.md"
  printf 'fence inside a fence\n'  > "$E/shapes/turns/15.md"

  mk absent zzz99999 1 2
  printf 'not on this machine\n' > "$E/absent/turns/1.md"

  out="$(score "$T/projects" "$E" 2>&1)"; st=$?
  Pc=0; Fc=0
  t() {
    if printf '%s' "$out" | grep -qE -- "$2"; then echo "  PASS  $1"; Pc=$((Pc+1))
    else
      echo "  FAIL  $1"; echo "        wanted /$2/"; echo "        got:"
      printf '%s\n' "$out" | sed 's/^/          /'; Fc=$((Fc+1))
    fi
  }

  echo "topic-numbering selftest"
  echo

  t "every topic labelled scores NUMBERED"            "NUMBERED +t1 +2/2 labelled"
  t "some topics labelled scores PARTIAL"             "PARTIAL +t2 +1/2 labelled"
  t "no topic labelled scores UNNUMBERED"             "UNNUMBERED +t3 +0/3 labelled"
  t "a bare number is not a label"                    "UNNUMBERED +t4 +0/2 labelled, by headings, 2 bare numbers"
  t "a sub-heading is not a second topic"             "SINGLE +t5 +0/1 labelled, by headings"
  t "a heading inside a fence is not a topic"         "SINGLE +t5"
  t "a reply with no sections scores NOTOPICS"        "NOTOPICS +t6"
  t "bold lead-ins with no labels are NOTOPICS, not a fail" "NOTOPICS +t7 +0/2 labelled, by bold lead-ins"
  t "a designator with no separator is not a label"   "UNNUMBERED +t8 +0/2 labelled"
  t "labels inline with prose after them are seen"    "BOLDONLY +t9 +2/3 labelled, by bold lead-ins"
  t "a partly labelled bold reply is never credited"  "BOLDONLY +t9"
  t "a lone title does not collapse the reply to one topic" "UNNUMBERED +t10 +0/3 labelled, by headings"
  t "a dot or a paren is a label separator"           "NUMBERED +t11 +2/2 labelled"
  t "a ~~~ line inside a fenced block does not close it" "SINGLE +t12 +0/1 labelled"
  t "bold lead-ins all labelled score NUMBERED"       "NUMBERED +t13 +2/2 labelled, by bold lead-ins"
  t "a section with sub-points is one topic"          "SINGLE +t14 +0/1 labelled, by headings"
  t "a shorter fence run does not close a longer one" "SINGLE +t15 +0/1 labelled"
  t "partial is counted as a fail, not part marks"    "partial 1 \(fails, not part marks\), unnumbered 4"
  t "the rate counts partial in the denominator"      "every topic labelled: 3/8"
  t "unscorable turns are counted apart, by shape"    "not scored 7 \(single topic 4, no sections 2, unlabelled bold lead-ins 1, cut short by the runner 0\)"
  t "a rate below the threshold is a FAIL verdict"    "^verdict +FAIL"
  t "replay says it cannot see a skill change"        "cannot see a change to skills/chat-response"
  t "a missing transcript is reported, not scored"    "NOT SCORED"
  if printf '%s' "$out" | grep -q "TURN DRIFT"; then
    echo "  FAIL  a matching turn set is not reported as drift"; Fc=$((Fc+1))
  else
    echo "  PASS  a matching turn set is not reported as drift"; Pc=$((Pc+1))
  fi
  [ "$st" = "0" ] && { echo "  PASS  a clean run exits 0"; Pc=$((Pc+1)); } \
                  || { echo "  FAIL  a clean run exits 0 (got $st)"; Fc=$((Fc+1)); }

  # Drift must fail, and must fail loudly. Both directions: an edited turn, and a turn the
  # transcript has that the case does not — the second is how a case silently narrows.
  printf 'several topics please, now\n' > "$E/shapes/turns/1.md"
  dout="$(score "$T/projects" "$E" 2>&1)"; dst=$?
  if printf '%s' "$dout" | grep -q "TURN DRIFT" && [ "$dst" != "0" ]; then
    echo "  PASS  an edited turn is caught as drift and exits non-zero"; Pc=$((Pc+1))
  else
    echo "  FAIL  an edited turn is caught as drift and exits non-zero (exit $dst)"; Fc=$((Fc+1))
  fi
  printf 'several topics please\n' > "$E/shapes/turns/1.md"
  rm "$E/shapes/turns/3.md"
  mout="$(score "$T/projects" "$E" 2>&1)"; mst=$?
  if printf '%s' "$mout" | grep -q "no turns/3.md" && [ "$mst" != "0" ]; then
    echo "  PASS  a transcript turn with no case file is caught as drift"; Pc=$((Pc+1))
  else
    echo "  FAIL  a transcript turn with no case file is caught as drift (exit $mst)"; Fc=$((Fc+1))
  fi
  printf 'and again\n' > "$E/shapes/turns/3.md"

  # --strict turns an absent transcript into a failure; the default does not.
  sst="$(TN_ROOT_DIR="$T/projects" TN_EVAL_DIR="$E" TN_STRICT=1 python "$HERE/topic-numbering.py" >/dev/null 2>&1; echo $?)"
  [ "$sst" != "0" ] && { echo "  PASS  --strict fails on an absent transcript"; Pc=$((Pc+1)); } \
                    || { echo "  FAIL  --strict fails on an absent transcript"; Fc=$((Fc+1)); }

  # Probe mode, on a fixture rather than a billed run. The rule under test is CUT: a reply the
  # runner stopped is truncated, and a truncated reply has lost its later sections. Scored as
  # written it would report topics that were never reached.
  PJ="$T/probe.json"
  python - "$PJ" <<'PYJSON'
import json, sys
json.dump({"shapes": {
    "1": {"text": "## D1 - one\n\na.\n\n## D2 - two\n\nb.\n", "cut": "", "fired": ["chat-response"]},
    "2": {"text": "## What I got wrong\n\na.\n\n## What holds up\n\nb.\n", "cut": "", "fired": []},
    "3": {"text": "## V1 - one\n\na.\n\n## and then", "cut": "error_max_budget", "fired": []},
}}, open(sys.argv[1], "w"))
PYJSON
  pout="$(score "$T/projects" "$E" "$PJ" 2>&1)"
  p() {
    if printf '%s' "$pout" | grep -qE -- "$2"; then echo "  PASS  $1"; Pc=$((Pc+1))
    else
      echo "  FAIL  $1"; echo "        wanted /$2/"; echo "        got:"
      printf '%s\n' "$pout" | sed 's/^/          /'; Fc=$((Fc+1))
    fi
  }
  p "a turn the runner cut short scores CUT"          "CUT +t3"
  p "a cut turn is not counted in the rate"           "every topic labelled: 1/2"
  p "cut turns are reported in the unscored column"   "cut short by the runner 1"
  p "the turns chat-response fired on are named"      "chat-response fired on: t1"
  if printf '%s' "$pout" | grep -q "cannot see a change to skills/chat-response"; then
    echo "  FAIL  probe mode does not print the replay-only caveat"; Fc=$((Fc+1))
  else
    echo "  PASS  probe mode does not print the replay-only caveat"; Pc=$((Pc+1))
  fi

  # A threshold the fixture clears must flip the verdict, or the verdict is not reading it.
  tout="$(TN_ROOT_DIR="$T/projects" TN_EVAL_DIR="$E" TN_THRESHOLD=0.1 python "$HERE/topic-numbering.py" 2>&1)"
  if printf '%s' "$tout" | grep -qE "^verdict +PASS"; then
    echo "  PASS  the threshold is read, not hardcoded"; Pc=$((Pc+1))
  else
    echo "  FAIL  the threshold is read, not hardcoded"; Fc=$((Fc+1))
  fi

  # The line above sets the variable directly, which does not exercise this script's own flag
  # plumbing. --threshold has to reach the scorer or it is an option nothing tests.
  # "$HERE/…", not "$0" — $0 is whatever the caller typed and the cd above has already moved
  # away from their directory, so a run started from tools/ would not find this script.
  fout="$(TN_EVAL_DIR_OVERRIDE="$E" MINER_PROJECTS_ROOT="$T/projects" \
          bash "$HERE/topic-numbering.sh" --threshold 0.1 2>&1)"
  if printf '%s' "$fout" | grep -qE "^threshold +0\.10" && printf '%s' "$fout" | grep -qE "^verdict +PASS"; then
    echo "  PASS  --threshold reaches the scorer"; Pc=$((Pc+1))
  else
    echo "  FAIL  --threshold reaches the scorer"; Fc=$((Fc+1))
  fi

  echo
  echo "$Pc passed, $Fc failed"
  [ "$Fc" = "0" ] || exit 1
  exit 0
fi

ROOT="${MINER_PROJECTS_ROOT:-$HOME/.claude/projects}"
EVAL_DIR="${TN_EVAL_DIR_OVERRIDE:-evals/topic-numbering}"

if [ "$PROBE" = "0" ]; then
  score "$ROOT" "$EVAL_DIR"
  exit $?
fi

command -v claude >/dev/null 2>&1 || { echo "claude CLI not on PATH — nothing to probe" >&2; exit 2; }

# TN_PROBE_OUT keeps the raw replies. Without it the JSON dies with the temp directory, and
# the only record of a billed run is whatever got copied into a dev-log by hand.
#
# The probe runner opens it "w" unconditionally, so a mistyped path is destroyed rather than
# refused. Anything that exists and is not already probe JSON stops the run before a turn is
# billed — the check costs nothing and the alternative is silent data loss.
OUT="${TN_PROBE_OUT:-$(mktemp -d)/probe.json}"
if [ -n "${TN_PROBE_OUT:-}" ]; then
  mkdir -p "$(dirname "$OUT")" 2>/dev/null
  if [ -e "$OUT" ] && ! python -c "import json,sys;json.load(open(sys.argv[1]))" "$OUT" 2>/dev/null; then
    echo "TN_PROBE_OUT=$OUT exists and is not probe JSON — refusing to overwrite it" >&2
    exit 2
  fi
fi
echo "topic-numbering --probe — ${RUNS} run(s) per case, live against the INSTALLED plugin"
echo "Run tools/plugin-reload.sh first or this measures the version before your edit."
echo

for CASEDIR in $(find "$EVAL_DIR" -name case.yaml | sort); do
  DIR="$(dirname "$CASEDIR")"
  NAME="$(printf '%s' "${DIR#"$EVAL_DIR"/}" | tr '\\' '/')"
  [ -n "$ONLY" ] && [ "$NAME" != "$ONLY" ] && continue
  for r in $(seq 1 "$RUNS"); do
    echo "  $NAME  run $r"
    RL_PROBE_CWD="$(pwd)" python "$HERE/response-length-probe.py" "$DIR" "$NAME" "$OUT" || exit 1
    # Each run overwrites the case's entry, so score between runs to keep them all.
    score "$ROOT" "$EVAL_DIR" "$OUT"
  done
done
