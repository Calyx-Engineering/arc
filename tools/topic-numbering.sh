#!/usr/bin/env bash
# topic-numbering.sh — score the eval cases in evals/topic-numbering: when a reply raised
# several topics, could the user answer it by number?
#
#   tools/topic-numbering.sh              replay the transcripts the cases came from
#   tools/topic-numbering.sh --strict     also fail when a case's transcript is not on this machine
#   tools/topic-numbering.sh --probe      re-run the turns live against the installed plugin
#   tools/topic-numbering.sh selftest     fixtures only, no corpus needed
#
#   --compare BEFORE.json AFTER.json     score two kept probe runs against each other
#
#   --threshold N    the rate a case must clear. Default 0.67
#   --case NAME      probe or compare one case only. Ignored in replay, which always scores
#                    every case. Separation is a property of one case, so --compare needs it
#   --runs N         repeat each case N times under --probe, scoring between runs
#
#   TN_PROBE_OUT=path   keep the probe's raw replies instead of losing them with the temp
#                       directory. Without it a billed run cannot be re-scored later, which
#                       is how six runs had to be re-taken when the scorer was corrected.
#                       ONE RUN PER PATH: the runner writes the case's entry whole, so
#                       --runs N leaves only the last. Give each run its own path.
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
# AND A THIRD THAT ASKS WHETHER THE FIX MOVED ANYTHING — #259. A probe rate on its own does not
# say that. `camp-thoughts-multi-topic` scores 1.00 under --probe with #160's rule and 1.00
# without it: the case passes and the control passes, so passing is not evidence.
#
#   --compare BEFORE.json AFTER.json
#                     Scores two runs TN_PROBE_OUT already kept, side by side, and prints
#                     `separates` FOR EACH CASE, never pooled — a suite's regression floor
#                     would otherwise lend its passes to a case that did not move. Three
#                     answers, because "did not separate" covers two different findings:
#                       YES  below the threshold before, at or above it after
#                       NO   HAD headroom and did not cross. A result about the change
#                       n/a  no headroom, and the reason is printed beside it: a side had no
#                            scorable turn, or the before side already passed
#                     --case NAME asks about one. Bills nothing, and needs no corpus:
#                     the scores come from the JSONs and the transcript is only what the drift
#                     check reads, so a kept pair re-scores on any machine (--strict still
#                     fails on the absence, because what is lost is the verbatim check).
#                     It does not know which skill produced which file; that is the run's
#                     record to state. One run per JSON, so take the two sides with separate
#                     TN_PROBE_OUT paths.
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
# it is the part wired into tests/verify-all.sh.

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
CMP_BEFORE=""
CMP_AFTER=""

while [ "$#" -gt 0 ]; do
  case "$1" in
    selftest) SELFTEST=1 ;;
    --strict) STRICT=1 ;;
    --probe) PROBE=1 ;;
    --runs) RUNS="${2:-1}"; shift ;;
    --case) ONLY="${2:-}"; shift ;;
    --threshold) TN_THRESHOLD="${2:-0.67}"; export TN_THRESHOLD; shift ;;
    # Two operands, and both are required. A --compare given one path would otherwise read the
    # next flag as the second JSON and report a comparison of a file that is not one.
    --compare)
      CMP_BEFORE="${2:-}"; CMP_AFTER="${3:-}"; shift 2
      if [ -z "$CMP_BEFORE" ] || [ -z "$CMP_AFTER" ]; then
        echo "--compare needs two paths: BEFORE.json AFTER.json" >&2; exit 2
      fi ;;
    -h|--help) sed -n "2,77p" "$0"; exit 0 ;;
    *) echo "unknown argument: $1" >&2; exit 2 ;;
  esac
  shift
done

score() {  # score <projects-root> <eval-dir> [probe-json] [before-json]
  # As in response-length.sh: set the mode either way, so an empty TN_PROBE_JSON does not
  # leave the mode as the empty string and silently drop the replay-only notes.
  local mode=replay
  [ -n "${3:-}" ] && mode=probe
  [ -n "${4:-}" ] && mode=compare
  TN_ROOT_DIR="$1" TN_EVAL_DIR="$2" TN_STRICT="$STRICT" TN_MODE="$mode" TN_ONLY="$ONLY" \
  TN_PROBE_JSON="${3:-}" TN_PROBE_JSON_BASE="${4:-}" python "$HERE/topic-numbering.py"
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
    hu 2026-09-01T10:15 '"numbered bold lead-ins"'
    # #259, and this is a live probe reply, not a fixture shape. Enumerated and not one label
    # on it. Ordinary emphasis does not open "2 — ", so nothing here is ambiguous: the reply
    # has topics and none of them can be answered by number. UNNUMBERED, a fail.
    as "$(printf '**0 - Read status.** a.\n\n**1 - Files read.** b.\n\n**2 - What to change.** c.\n')"
    hu 2026-09-01T10:16 '"labelled, then enumerated"'
    # "Labels the first few, then stops" WITH the evidence that the rest are topics. The
    # ambiguity BOLDONLY exists to respect is absent here, so the verdict is not withheld:
    # PARTIAL, a fail. #160 recorded PARTIAL as reachable in the heading form only; two
    # numbered unlabelled lead-ins put it within reach here for the same reason.
    as "$(printf '**D1 - the first thing** a.\n\n**2 - the second** b.\n\n**3 - the third** c.\n')"
    hu 2026-09-01T10:17 '"one number, otherwise emphasis"'
    # A single numbered lead-in beside plain ones is a figure in a sentence, not an
    # enumeration. Below the evidence bar, so the ambiguity stands: NOTOPICS.
    as "$(printf '**1 - the first thing** a.\n\n**Fails closed.** Any check errors and it stops.\n')"
  } > "$P/ccc33333.jsonl"

  mk() {  # mk <slug> <session> <first> <last>
    mkdir -p "$E/$1/turns" "$E/$1/graders"
    printf 'min_topics: 2\nsource:\n  session: %s\n  first_turn: %s\n  last_turn: %s\n' \
      "$2" "$3" "$4" > "$E/$1/case.yaml"
    printf '# grader\n' > "$E/$1/graders/every-topic-labelled.md"
  }

  mk shapes ccc33333 1 18
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
  printf 'numbered bold lead-ins\n' > "$E/shapes/turns/16.md"
  printf 'labelled, then enumerated\n' > "$E/shapes/turns/17.md"
  printf 'one number, otherwise emphasis\n' > "$E/shapes/turns/18.md"

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
  t "numbered bold lead-ins with no labels are a fail" "UNNUMBERED +t16 +0/3 labelled, by bold lead-ins, 3 bare numbers"
  t "labelled then enumerated is PARTIAL, not withheld" "PARTIAL +t17 +1/3 labelled, by bold lead-ins, 2 bare numbers"
  t "one numbered lead-in is not an enumeration"      "NOTOPICS +t18 +0/2 labelled, by bold lead-ins, 1 bare number"
  t "partial is counted as a fail, not part marks"    "partial 2 \(fails, not part marks\), unnumbered 5"
  t "the rate counts partial in the denominator"      "every topic labelled: 3/10"
  t "unscorable turns are counted apart, by shape"    "not scored 8 \(single topic 4, no sections 3, unlabelled bold lead-ins 1, cut short by the runner 0\)"
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

  # --compare, #259. Two kept runs of the SAME case scored against each other. The "before"
  # side is the shape the corpus actually holds — the user's own step numbers carried onto the
  # headings — and the "after" side is the same reply with labels. Fixtures, so the mode that
  # decides whether a billed pair separates is itself checked without billing anything.
  BJ="$T/before.json"
  AJ="$T/after.json"
  python - "$BJ" <<'PYJSON'
import json, sys
json.dump({"shapes": {
    "1": {"text": "## 2. What repo trying to do\n\na.\n\n## 3. What to change\n\nb.\n",
          "cut": "", "fired": []},
    "2": {"text": "## What I got wrong\n\na.\n\n## What holds up\n\nb.\n", "cut": "", "fired": []},
}}, open(sys.argv[1], "w"))
PYJSON
  # ensure_ascii=False and a UTF-8 handle, so the em dashes reach the file as bytes rather
  # than as \u escapes. A probe JSON is the model's own prose and always looks like this; a
  # fixture that escaped them would not exercise the guard the run below checks.
  python - "$AJ" <<'PYJSON'
import io, json, sys
json.dump({"shapes": {
    "1": {"text": "## D1 — what repo trying to do\n\na.\n\n## D2 — what to change\n\nb.\n",
          "cut": "", "fired": ["chat-response"]},
    "2": {"text": "## V1 — what I got wrong\n\na.\n\n## V2 — what holds up\n\nb.\n",
          "cut": "", "fired": ["chat-response"]},
}}, io.open(sys.argv[1], "w", encoding="utf-8"), ensure_ascii=False)
PYJSON
  cout="$(TN_EVAL_DIR_OVERRIDE="$E" MINER_PROJECTS_ROOT="$T/projects" \
          bash "$HERE/topic-numbering.sh" --compare "$BJ" "$AJ" 2>&1)"
  cst=$?
  c() {
    if printf '%s' "$cout" | grep -qE -- "$2"; then echo "  PASS  $1"; Pc=$((Pc+1))
    else
      echo "  FAIL  $1"; echo "        wanted /$2/"; echo "        got:"
      printf '%s\n' "$cout" | sed 's/^/          /'; Fc=$((Fc+1))
    fi
  }
  c "--compare scores both sides of one case"      "shapes +\[before\]"
  c "the after side is scored too"                 "shapes +\[after\]"
  c "the two rates print side by side"             "^ +every topic labelled +0/2  0\.00 +2/2  1\.00"
  c "a moved rate is reported as separating"       "^separates +YES"
  c "a separating pair is a PASS"                  "^verdict +PASS"
  c "compare mode does not print the replay caveat" "^Neither side is billed here"
  [ "$cst" = "0" ] && { echo "  PASS  a clean --compare exits 0"; Pc=$((Pc+1)); } \
                   || { echo "  FAIL  a clean --compare exits 0 (got $cst)"; Fc=$((Fc+1)); }

  # The mode's whole reason for existing: #160's case scored 1.00 with the rule and 1.00
  # without, and the run reported it as a pass. Compared against itself, that must read NO.
  sout="$(TN_EVAL_DIR_OVERRIDE="$E" MINER_PROJECTS_ROOT="$T/projects" \
          bash "$HERE/topic-numbering.sh" --compare "$AJ" "$AJ" 2>&1)"
  if printf '%s' "$sout" | grep -qE "^separates +NO" && printf '%s' "$sout" | grep -qE "^verdict +FAIL"; then
    echo "  PASS  two identical runs do not separate"; Pc=$((Pc+1))
  else
    echo "  FAIL  two identical runs do not separate"; Fc=$((Fc+1))
  fi

  # SEPARATION IS PER CASE, NEVER POOLED. A second case that passes on both sides is a
  # regression floor; pooled with a case that did not move it can carry the suite over the
  # threshold and print YES about the one question this mode exists to answer. `floor` scores
  # 2/2 on both sides, `shapes` 0/2 then 2/2 — pooled that is 2/4 then 4/4, which clears 0.67
  # from below. The verdict must still be FAIL, because `floor` did not move.
  # The fixture is built so the POOL and the CASES give opposite answers.
  #   floor   2/2 · 1.00 both sides — a saturated regression floor. It has no headroom, which
  #           is not the same as failing to use it: n/a, and it neither lends its passes nor
  #           withholds a verdict.
  #   shapes  0/2 · 0.00 then 1/2 · 0.50 — headroom, and it did not cross 0.67. NO.
  # Pooled that is 2/4 · 0.50 before and 3/4 · 0.75 after, which crosses the threshold from
  # below and would print YES about a case that plainly did not move. Per case: FAIL.
  mk floor ccc33333 1 2
  printf 'several topics please\n' > "$E/floor/turns/1.md"
  printf 'again\n'                 > "$E/floor/turns/2.md"
  python - "$T/floor-before.json" <<'PYJSON'
import io, json, sys
floor = {"1": {"text": "**D1 — one**\n\na.\n\n**D2 — two**\n\nb.\n", "cut": "", "fired": []},
         "2": {"text": "**V1 — one**\n\na.\n\n**V2 — two**\n\nb.\n", "cut": "", "fired": []}}
json.dump({"floor": floor,
           "shapes": {"1": {"text": "**1 — one**\n\na.\n\n**2 — two**\n\nb.\n", "cut": "", "fired": []},
                      "2": {"text": "**3 — one**\n\na.\n\n**4 — two**\n\nb.\n", "cut": "", "fired": []}}},
          io.open(sys.argv[1], "w", encoding="utf-8"), ensure_ascii=False)
PYJSON
  python - "$T/floor.json" <<'PYJSON'
import io, json, sys
floor = {"1": {"text": "**D1 — one**\n\na.\n\n**D2 — two**\n\nb.\n", "cut": "", "fired": []},
         "2": {"text": "**V1 — one**\n\na.\n\n**V2 — two**\n\nb.\n", "cut": "", "fired": []}}
json.dump({"floor": floor,
           "shapes": {"1": {"text": "**D1 — one**\n\na.\n\n**D2 — two**\n\nb.\n", "cut": "", "fired": []},
                      "2": {"text": "**3 — one**\n\na.\n\n**4 — two**\n\nb.\n", "cut": "", "fired": []}}},
          io.open(sys.argv[1], "w", encoding="utf-8"), ensure_ascii=False)
PYJSON
  fl="$(TN_EVAL_DIR_OVERRIDE="$E" MINER_PROJECTS_ROOT="$T/projects" \
        bash "$HERE/topic-numbering.sh" --compare "$T/floor-before.json" "$T/floor.json" 2>&1)"
  if printf '%s' "$fl" | grep -qE "every topic labelled +2/4  0\.50 +3/4  0\.75" \
     && printf '%s' "$fl" | grep -qE "^ +shapes +NO" \
     && printf '%s' "$fl" | grep -qE "^verdict +FAIL"; then
    echo "  PASS  a case that did not move is not carried by the pool"; Pc=$((Pc+1))
  else
    echo "  FAIL  a case that did not move is not carried by the pool"; Fc=$((Fc+1))
    printf '%s\n' "$fl" | sed 's/^/          /'
  fi

  # A SATURATED CASE IS n/a, NOT NO. `floor` never dropped below the threshold, so neither
  # side can show the rule working through it. Filing that as a failure would make a verdict
  # unreachable for any suite that keeps a regression floor — which this one does, by design.
  if printf '%s' "$fl" | grep -qE "^ +floor +n/a +the before side already scored at or above" \
     && printf '%s' "$fl" | grep -qE "^separates +NO +shapes had headroom"; then
    echo "  PASS  a saturated case reads n/a, not a failure"; Pc=$((Pc+1))
  else
    echo "  FAIL  a saturated case reads n/a, not a failure"; Fc=$((Fc+1))
    printf '%s\n' "$fl" | sed 's/^/          /'
  fi

  # ...and --case is how you ask about one of them. Without it there is no way to put the
  # question the issue asks to a single case. It narrows what is SCORED and nothing else.
  fc="$(TN_EVAL_DIR_OVERRIDE="$E" MINER_PROJECTS_ROOT="$T/projects" \
        bash "$HERE/topic-numbering.sh" --compare "$T/floor-before.json" "$T/floor.json" \
        --case floor 2>&1)"
  if printf '%s' "$fc" | grep -qE "^ +floor +n/a" \
     && ! printf '%s' "$fc" | grep -q "^shapes " \
     && printf '%s' "$fc" | grep -qE "^the case compared" \
     && printf '%s' "$fc" | grep -qE "^verdict +FAIL"; then
    echo "  PASS  --compare --case scores the named case alone"; Pc=$((Pc+1))
  else
    echo "  FAIL  --compare --case scores the named case alone"; Fc=$((Fc+1))
    printf '%s\n' "$fc" | sed 's/^/          /'
  fi

  # --case must not narrow the DRIFT check. A drifted turn in a case nobody selected is still
  # drift, and a --case that hid it would turn the verbatim guarantee into an opt-in.
  printf 'drifted\n' > "$E/floor/turns/1.md"
  dc="$(TN_EVAL_DIR_OVERRIDE="$E" MINER_PROJECTS_ROOT="$T/projects" \
        bash "$HERE/topic-numbering.sh" --compare "$T/floor-before.json" "$T/floor.json" \
        --case shapes 2>&1)"; dcst=$?
  if printf '%s' "$dc" | grep -q "TURN DRIFT" && printf '%s' "$dc" | grep -q "floor t1" \
     && [ "$dcst" != "0" ]; then
    echo "  PASS  --case does not hide drift in an unselected case"; Pc=$((Pc+1))
  else
    echo "  FAIL  --case does not hide drift in an unselected case (exit $dcst)"; Fc=$((Fc+1))
  fi
  rm -rf "$E/floor"

  # A KEPT PAIR RE-SCORES WITHOUT THE CORPUS. Replay needs the transcript; compare does not —
  # its scores come from the two JSONs, and the transcript is only what the drift check reads.
  # `absent`'s session is not on this machine, and skipping it outright would mean a pair of
  # billed runs could not be re-scored on any machine but the one that took them, which is the
  # whole claim TN_PROBE_OUT is sold on. It is scored, and the absence is still reported.
  python - "$T/absent-before.json" <<'PYJSON'
import io, json, sys
json.dump({"absent": {"1": {"text": "**1 — one**\n\na.\n\n**2 — two**\n\nb.\n", "cut": "", "fired": []}}},
          io.open(sys.argv[1], "w", encoding="utf-8"), ensure_ascii=False)
PYJSON
  python - "$T/absent-after.json" <<'PYJSON'
import io, json, sys
json.dump({"absent": {"1": {"text": "**D1 — one**\n\na.\n\n**D2 — two**\n\nb.\n", "cut": "", "fired": []}}},
          io.open(sys.argv[1], "w", encoding="utf-8"), ensure_ascii=False)
PYJSON
  ab="$(TN_EVAL_DIR_OVERRIDE="$E" MINER_PROJECTS_ROOT="$T/projects" \
        bash "$HERE/topic-numbering.sh" --compare "$T/absent-before.json" "$T/absent-after.json" \
        --case absent 2>&1)"
  abst=$?
  if printf '%s' "$ab" | grep -qE "^ +absent +YES" \
     && printf '%s' "$ab" | grep -q "scored anyway from the probe JSONs, turns unchecked" \
     && [ "$abst" = "0" ]; then
    echo "  PASS  compare scores a case whose transcript is absent"; Pc=$((Pc+1))
  else
    echo "  FAIL  compare scores a case whose transcript is absent (exit $abst)"; Fc=$((Fc+1))
    printf '%s\n' "$ab" | sed 's/^/          /'
  fi

  # --strict still fails on it. What the absence costs is the verbatim check, not the score,
  # and the two have to be separable or "scored anyway" becomes "checked anyway".
  #
  # The output is KEPT and checked, not discarded. Asserting only "exit != 0" would pass on a
  # traceback — which is exactly the regression this branch could introduce, since it is the
  # one path that scores a case with no transcript behind it.
  sout2="$(TN_ROOT_DIR="$T/projects" TN_EVAL_DIR="$E" TN_STRICT=1 TN_MODE=compare TN_ONLY=absent \
           TN_PROBE_JSON="$T/absent-after.json" TN_PROBE_JSON_BASE="$T/absent-before.json" \
           python "$HERE/topic-numbering.py" 2>&1)"
  sabst=$?
  if [ "$sabst" != "0" ] \
     && ! printf '%s' "$sout2" | grep -q "Traceback" \
     && printf '%s' "$sout2" | grep -q "SCORED, TURNS NOT CHECKED" \
     && printf '%s' "$sout2" | grep -qE "^ +absent +YES"; then
    echo "  PASS  --strict still fails on an absent transcript in compare"; Pc=$((Pc+1))
  else
    echo "  FAIL  --strict still fails on an absent transcript in compare (exit $sabst)"; Fc=$((Fc+1))
    printf '%s\n' "$sout2" | sed 's/^/          /'
  fi

  # Backwards is not a pass either. The sides are swapped, so the rate falls 1.00 to 0.00 —
  # and it reads n/a rather than NO, because a before side already at or above the threshold
  # never had headroom and neither side can show the rule working through it. What must not
  # happen, and is what this asserts, is YES.
  rout="$(TN_EVAL_DIR_OVERRIDE="$E" MINER_PROJECTS_ROOT="$T/projects" \
          bash "$HERE/topic-numbering.sh" --compare "$AJ" "$BJ" 2>&1)"
  if printf '%s' "$rout" | grep -qE "every topic labelled +2/2  1\.00 +0/2  0\.00" \
     && printf '%s' "$rout" | grep -qE "^ +shapes +n/a" \
     && ! printf '%s' "$rout" | grep -qE "^separates +YES" \
     && printf '%s' "$rout" | grep -qE "^verdict +FAIL"; then
    echo "  PASS  a rate that moved the wrong way does not separate"; Pc=$((Pc+1))
  else
    echo "  FAIL  a rate that moved the wrong way does not separate"; Fc=$((Fc+1))
  fi

  # A side where every turn was unscorable has NO rate, and n/a for that reason must not read
  # as n/a for the other one — "nothing could be scored" and "it already passed" are opposite
  # findings. Reported as 0.00 it reads as "scored
  # zero", which is a measurement — and it is the number the before side is expected to give,
  # so the one line a reader takes away would be the one that misleads. Both billed runs of
  # #259 hit this: the before side was 0/0.
  NJ="$T/nothing.json"
  python - "$NJ" <<'PYJSON'
import io, json, sys
json.dump({"shapes": {
    "1": {"text": "Plain prose, no sections, nothing to number.\n", "cut": "", "fired": []},
}}, io.open(sys.argv[1], "w", encoding="utf-8"), ensure_ascii=False)
PYJSON
  nout="$(TN_EVAL_DIR_OVERRIDE="$E" MINER_PROJECTS_ROOT="$T/projects" \
          bash "$HERE/topic-numbering.sh" --compare "$NJ" "$AJ" 2>&1)"
  # Two claims: the rate reads n/a rather than 0.00, and a side with no denominator can never
  # be called a separation — 0/0 against 2/2 must not read as "moved from 0.00 to 1.00".
  if printf '%s' "$nout" | grep -qE "every topic labelled +0/0  n/a" \
     && ! printf '%s' "$nout" | grep -q "0\.00" \
     && printf '%s' "$nout" | grep -qE "^ +shapes +n/a +the before side had no scorable turn" \
     && printf '%s' "$nout" | grep -qE "^separates +NO +no case had headroom"; then
    echo "  PASS  an unscorable side is not reported as 0.00"; Pc=$((Pc+1))
  else
    echo "  FAIL  an unscorable side is not reported as 0.00"; Fc=$((Fc+1))
  fi

  # A probe JSON holds the model's own prose, so it holds em dashes. Read in the platform
  # encoding it raises on Windows, and the guard below then calls a perfectly good run "not
  # probe JSON" — which is how the first --compare of this issue's two billed runs was
  # refused. Both guards here and response-length.sh's read it as UTF-8 now.
  uout="$(TN_EVAL_DIR_OVERRIDE="$E" MINER_PROJECTS_ROOT="$T/projects" \
          bash "$HERE/topic-numbering.sh" --compare "$BJ" "$AJ" 2>&1)"
  if printf '%s' "$uout" | grep -q "not probe JSON"; then
    echo "  FAIL  a probe JSON holding non-ASCII prose is readable"; Fc=$((Fc+1))
  else
    echo "  PASS  a probe JSON holding non-ASCII prose is readable"; Pc=$((Pc+1))
  fi

  # One path given, or one that is not JSON: refused before anything is scored, because an
  # empty side scores 0.00 and 0.00 is exactly what the before side is expected to produce.
  for bad in "one-path" "not-json"; do
    case "$bad" in
      one-path) oout="$(TN_EVAL_DIR_OVERRIDE="$E" MINER_PROJECTS_ROOT="$T/projects" \
                        bash "$HERE/topic-numbering.sh" --compare "$BJ" 2>&1)"; ost=$? ;;
      not-json) printf 'not json\n' > "$T/junk.json"
                oout="$(TN_EVAL_DIR_OVERRIDE="$E" MINER_PROJECTS_ROOT="$T/projects" \
                        bash "$HERE/topic-numbering.sh" --compare "$T/junk.json" "$AJ" 2>&1)"; ost=$? ;;
    esac
    if [ "$ost" = "2" ] && ! printf '%s' "$oout" | grep -q "separates"; then
      echo "  PASS  --compare refuses a bad operand ($bad)"; Pc=$((Pc+1))
    else
      echo "  FAIL  --compare refuses a bad operand ($bad) (exit $ost)"; Fc=$((Fc+1))
    fi
  done

  echo
  echo "$Pc passed, $Fc failed"
  [ "$Fc" = "0" ] || exit 1
  exit 0
fi

ROOT="${MINER_PROJECTS_ROOT:-$HOME/.claude/projects}"
EVAL_DIR="${TN_EVAL_DIR_OVERRIDE:-evals/topic-numbering}"

if [ -n "$CMP_BEFORE" ]; then
  # Named before either is opened, so a typo reads as a typo rather than as an empty side
  # scoring 0.00 — which is the answer the "before" side is expected to give.
  for f in "$CMP_BEFORE" "$CMP_AFTER"; do
    [ -f "$f" ] || { echo "--compare: no such file: $f" >&2; exit 2; }
    # An object, not merely valid JSON. `123` parses and then dies inside the scorer with an
    # AttributeError, which reads as a bug in the tool rather than as the wrong file.
    python -c "import io,json,sys;d=json.load(io.open(sys.argv[1],encoding='utf-8'));sys.exit(0 if isinstance(d,dict) else 1)" \
      "$f" 2>/dev/null || { echo "--compare: not probe JSON: $f" >&2; exit 2; }
  done
  score "$ROOT" "$EVAL_DIR" "$CMP_AFTER" "$CMP_BEFORE"
  exit $?
fi

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
  if [ -e "$OUT" ] && ! python -c "import io,json,sys;d=json.load(io.open(sys.argv[1],encoding='utf-8'));sys.exit(0 if isinstance(d,dict) else 1)" "$OUT" 2>/dev/null; then
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
