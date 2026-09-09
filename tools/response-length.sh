#!/usr/bin/env bash
# response-length.sh — score the eval cases in evals/response-length: was a stated length
# budget still being applied ten turns after the user set it?
#
#   tools/response-length.sh              replay the transcripts the cases came from
#   tools/response-length.sh --strict     also fail when a case's transcript is not on this machine
#   tools/response-length.sh --probe      re-run the turns live against the installed plugin
#   tools/response-length.sh selftest     fixtures only, no corpus needed
#
#   RL_PROBE_OUT=path   keep the probe's raw replies instead of losing them with the temp
#                       directory, so a billed run can be re-scored after the scorer changes
#                       ONE RUN PER PATH: the runner writes the case's entry whole, so
#                       --runs N leaves only the last. Give each run its own path.
#
# WHY THIS EXISTS. tools/skill-cases.sh and tools/skill-probe.sh both measure ONE thing:
# whether a Skill was invoked. #155 established that firing is neither necessary nor sufficient
# for the rule to be followed — chat-response fired on a 2251-character reply, and a 60-word
# budget was met once with the skill never firing at all. A reply's LENGTH is a different
# question and needs a different instrument. This is it.
#
# IT DOES NOT NEED A MODEL TO GRADE IT. Length is arithmetic. `claude plugin eval` is still
# gated (#181) and is still what a judgement-shaped grader would need, but "is this reply 60
# words or fewer" is countable, so this closes without it.
#
# WHAT IT COUNTS. Prose only. skills/chat-response exempts tables, code blocks and headings
# from the budget, so the counter drops them — a grader that counted them would be measuring
# a rule nobody wrote.
#
# TWO MODES, AND ONLY ONE CAN SEE A FIX.
#
#   replay (default)  Reads the recorded transcript. Free, deterministic, and blind to any
#                     edit made after the session — the same limitation as skill-cases.sh.
#                     It is the baseline: what happened.
#   --probe           Replays the turns as one live conversation. Billed. This is the half
#                     that can score a change to the skill, and the reason the turns share a
#                     session: eleven separate runs cannot see a budget decay.
#
# THE VERBATIM CLAIM IS CHECKED, NOT TRUSTED. Every turns/<n>.md is compared against the turn
# it claims to copy, both directions, and drift fails the run.
#
# THE CORPUS IS LOCAL. Transcripts live under ~/.claude/projects on one machine, so a case
# whose session is absent is reported and skipped. Only the selftest is portable, which is why
# it is the part wired into tests/verify-all.sh.

set -u
cd "${RL_CD:-$(dirname "$0")/..}" || exit 1

HERE="$(cd "$(dirname "$0")" && pwd)"
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
    --threshold) RL_THRESHOLD="${2:-0.67}"; export RL_THRESHOLD; shift ;;
    -h|--help) sed -n "2,41p" "$0"; exit 0 ;;
    *) echo "unknown argument: $1" >&2; exit 2 ;;
  esac
  shift
done

score() {  # score <projects-root> <eval-dir> [probe-json]
  # ${3:+probe} leaves RL_MODE as the empty string when there is no probe file, which is not
  # "replay" and silently drops the replay-only notes. Set it either way.
  local mode=replay
  [ -n "${3:-}" ] && mode=probe
  RL_ROOT_DIR="$1" RL_EVAL_DIR="$2" RL_STRICT="$STRICT" \
  RL_MODE="$mode" RL_PROBE_JSON="${3:-}" python "$HERE/response-length.py"
}

if [ "$SELFTEST" = "1" ]; then
  T="$(mktemp -d)"
  trap 'rm -rf "$T"' EXIT
  P="$T/projects/r--fixture"
  E="$T/evals"
  mkdir -p "$P"

  # A user turn, and an assistant reply of exactly N prose words plus untouchable furniture.
  hu() { printf '{"type":"user","origin":{"kind":"human"},"timestamp":"%s","message":{"content":%s}}\n' "$1" "$2"; }
  # words <n> — n one-character words, so the expected count is unambiguous.
  words() { python -c "import sys; print(' '.join('w'*int(sys.argv[1])))" "$1"; }
  as() { printf '{"type":"assistant","timestamp":"t","message":{"content":[{"type":"text","text":%s}]}}\n' "$(python -c 'import json,sys;print(json.dumps(sys.stdin.read()))' <<<"$1")"; }

  {
    hu 2026-09-01T10:00 '"keep it to 20 words or less. now explain the thing"'
    as "$(words 18)"
    hu 2026-09-01T10:01 '"go on"'
    # 18 prose words — over the thin floor, under the budget — plus a table, a heading and a
    # fenced block that must NOT be counted. If any were, this turn would score OVER.
    as "$(printf '# A heading with many extra words in it\n\n%s\n\n| a | b |\n| --- | --- |\n| lots of words here | and more here |\n\n```\ncode words words words words words\n```\n' "$(words 18)")"
    hu 2026-09-01T10:02 '"and again"'
    as "$(words 60)"
    hu 2026-09-01T10:03 '"once more"'
    as "$(words 3)"
    hu 2026-09-01T10:04 '"and shorter"'
    # 12 words against a 20-word budget. Under a flat 15-word floor this is discarded as THIN
    # — which deletes exactly the behaviour #213's undershoot rule asks for. The floor is
    # min(15, budget/2) = 10 here, so it counts.
    as "$(words 12)"
    hu 2026-09-01T10:05 '"last one"'
    # Keeps the fixture rate under the 0.67 default, so the FAIL-verdict case still tests a
    # verdict rather than the threshold's own arithmetic.
    as "$(words 40)"
  } > "$P/bbb22222.jsonl"

  mk() {  # mk <slug> <budget> <session> <first> <last> ; turns are copied from the fixture
    mkdir -p "$E/$1/turns" "$E/$1/graders"
    printf 'budget: %s\nunit: words\nsource:\n  session: %s\n  first_turn: %s\n  last_turn: %s\n  set_on: %s\n' \
      "$2" "$3" "$4" "$5" "$4" > "$E/$1/case.yaml"
    printf '# grader\n' > "$E/$1/graders/within-budget.md"
  }

  mk held 20 bbb22222 1 6
  printf 'keep it to 20 words or less. now explain the thing\n' > "$E/held/turns/1.md"
  printf 'go on\n'    > "$E/held/turns/2.md"
  printf 'and again\n' > "$E/held/turns/3.md"
  printf 'once more\n' > "$E/held/turns/4.md"
  printf 'and shorter\n' > "$E/held/turns/5.md"
  printf 'last one\n' > "$E/held/turns/6.md"

  mk absent 20 zzz99999 1 2
  printf 'not on this machine\n' > "$E/absent/turns/1.md"

  # A fixture case: no session, no transcript, and a budget that came from an operating
  # agreement rather than from anything a user said. The checked box carries its own number,
  # so a repository that edits 40 down to 25 is scored at 25 — the setting is the user's, and
  # a scorer holding its own copy of the value would be scoring a different agreement. #174
  agree() {  # agree <slug> <clause block>
    mkdir -p "$E/$1/turns" "$E/$1/replies" "$E/$1/graders"
    printf 'unit: words\nagreement: agreement.md\nsource:\n  kind: fixture\n  first_turn: 1\n  last_turn: 3\n' \
      > "$E/$1/case.yaml"
    printf '# grader\n' > "$E/$1/graders/within-budget.md"
    { printf '## 1 Settings\n\n### Report verbosity\n\n- [x] **normal**\n\n### Response verbosity\n\n'
      printf '%s\n' "$2"
      printf '\n### Friction log\n\n- [x] **off**\n'
    } > "$E/$1/agreement.md"
  }
  qs() { for i in $(seq 1 "$2"); do printf 'q%s\n' "$i" > "$E/$1/turns/$i.md"; done; }
  # The shipped clause, copied verbatim from templates/camp/operating-agreement.md — the same
  # three lines a repository gets on install, `normal` checked.
  NORMAL_LINE='- [ ] **normal** — `chat-response`'"'"'s own table: ~150 words for a finding, ~200 for a proposal'
  BRIEF_LINE='- [ ] **brief** — the answer and nothing after it. **40 words** of prose'

  # brief, with the number in the clause. 21 / 149 / 12 words against it.
  agree brief "$(printf -- '%s\n%s\n- [ ] Other:' "${BRIEF_LINE/\[ \]/[x]}" "$NORMAL_LINE")"
  printf '%s\n' "$(words 21)"  > "$E/brief/replies/1.md"
  printf '%s\n' "$(words 149)" > "$E/brief/replies/2.md"
  printf '%s\n' "$(words 12)"  > "$E/brief/replies/3.md"
  qs brief 3

  # A number typed into `Other:` is the budget. Same three replies, so only the clause moved:
  # at 25 words t1 is still UNDER, and the floor drops from 15 to 12.
  agree other "$(printf -- '%s\n%s\n- [x] Other: 25 words' "$BRIEF_LINE" "$NORMAL_LINE")"
  printf '%s\n' "$(words 21)"  > "$E/other/replies/1.md"
  printf '%s\n' "$(words 149)" > "$E/other/replies/2.md"
  printf '%s\n' "$(words 12)"  > "$E/other/replies/3.md"
  qs other 3

  # THE EDIT THE SETTING EXISTS FOR: the user changes 40 to 25, without bolding it, and is
  # scored at 25. Asserting the shipped 40 tests nothing — it is also LEVEL_DEFAULT's fallback,
  # so every assertion about it stays green with the number-reading deleted entirely.
  agree edited "$(printf -- '- [x] **brief** — the answer and nothing after it. 25 words of prose\n%s\n- [ ] Other:' "$NORMAL_LINE")"
  printf '%s\n' "$(words 21)"  > "$E/edited/replies/1.md"
  printf '%s\n' "$(words 149)" > "$E/edited/replies/2.md"
  qs edited 2

  # `normal` IS THE SHIPPED STATE, and it must not produce a budget. Its line says "~150 words
  # for a finding, ~200 for a proposal" — prose about chat-response's table, not a number the
  # user set. A scorer reading 150 out of it hands every repository that never edited its
  # agreement a flat budget it did not choose, which breaks the issue's second constraint in
  # the one configuration almost every repository is in.
  agree normal "$(printf -- '%s\n%s\n- [ ] Other:' "$BRIEF_LINE" "${NORMAL_LINE/\[ \]/[x]}")"
  printf '%s\n' "$(words 149)" > "$E/normal/replies/1.md"
  qs normal 1

  # `full` is a level with no ceiling. It must report as unscorable, never pass by default —
  # an agreement saying "as long as it takes" has not set a budget, and inventing one for it
  # would be grading a rule nobody wrote.
  agree full "$(printf -- '%s\n- [x] **full** — the reasoning first, at whatever length that takes\n- [ ] Other:' "$BRIEF_LINE")"
  printf '%s\n' "$(words 149)" > "$E/full/replies/1.md"
  qs full 1

  # A clause present with every box unchecked, and a clause with two boxes checked. Both are
  # states a mid-edit agreement is genuinely in, and neither may be reported as the OTHER
  # states: "no clause found" points the user at the wrong fix, and resolving two checked boxes
  # by file order makes the answer depend on the order the levels are listed in.
  agree blank "$(printf -- '%s\n%s\n- [ ] Other:' "$BRIEF_LINE" "$NORMAL_LINE")"
  printf '%s\n' "$(words 149)" > "$E/blank/replies/1.md"
  qs blank 1

  agree twice "$(printf -- '%s\n%s\n- [ ] Other:' "${BRIEF_LINE/\[ \]/[x]}" "${NORMAL_LINE/\[ \]/[x]}")"
  printf '%s\n' "$(words 149)" > "$E/twice/replies/1.md"
  qs twice 1

  # No clause at all — the constraint the issue states as "default unchanged". A repository
  # that never wrote the setting must not acquire a budget from this scorer. The heading is
  # removed rather than left empty: an agreement written before the clause existed does not
  # have the section, and that is the shape the fallback has to survive.
  agree none "- [ ] Other:"
  printf '## 1 Settings\n\n### Report verbosity\n\n- [x] **normal**\n' > "$E/none/agreement.md"
  printf '%s\n' "$(words 149)" > "$E/none/replies/1.md"
  qs none 1

  out="$(score "$T/projects" "$E" 2>&1)"; st=$?
  Pc=0; Fc=0
  t() {
    if printf '%s' "$out" | grep -qE -- "$2"; then echo "  PASS  $1"; Pc=$((Pc+1))
    else
      echo "  FAIL  $1"; echo "        wanted /$2/"; echo "        got:"
      printf '%s\n' "$out" | sed 's/^/          /'; Fc=$((Fc+1))
    fi
  }

  echo "response-length selftest"
  echo

  t "a reply inside the budget scores UNDER"          "UNDER +t1 +18 words"
  # If the heading, the table or the fence were counted, t2 would be well over 20 and score OVER.
  t "a table, a heading and a code fence are not budgeted" "UNDER +t2 +18 words"
  t "a reply over the budget scores OVER"             "OVER +t3 +60 words"
  # The whole point of the floor: 3 words is not evidence the budget was held.
  t "a reply under the thin floor scores THIN"        "THIN +t4 +3 words"
  t "the thin reply is not counted in the rate"       "within budget \(20 words\): 3/5"
  # A flat 15-word floor would call this THIN and drop it, which is how the instrument came to
  # discard the behaviour #213's undershoot rule asks for. min(15, budget/2) = 10 keeps it.
  t "the floor is relative to the budget, not flat"   "UNDER +t5 +12 words"
  t "the effective floor is reported per case"        "thin floor 10 words"
  t "the first breach turn is named"                  "first breach t3"
  t "how long the budget held is reported"            "held 2 turns after it was stated"
  t "the turn the budget was stated on is marked"     "budget stated here"
  t "the final-block count is reported beside it"     "final block only:"
  t "a rate below the threshold is a FAIL verdict"    "^verdict +FAIL"
  t "replay says it cannot see a skill change"        "cannot see a change to skills/chat-response"

  # ---- the budget the agreement sets, #174 -----------------------------------------
  t "a fixture case is scored without a transcript"   "^brief +\[fixture\]"
  t "the budget is read out of the agreement"         "budget from agreement.md: brief, 40 words"
  t "a long answer is graded against it"              "OVER +t2 +149 words"
  t "a reply inside it still passes"                  "UNDER +t1 +21 words"
  t "the case is scored at the agreement's number"    "within budget \(40 words\)"
  t "a standing budget is not attributed to a turn"   "held 1 turns after it came into force"
  # The setting belongs to the user, so the number in the clause is the number applied. A
  # scorer keeping its own copy of "brief" would score every repository the same.
  t "an edited level number is the budget"            "budget from agreement.md: brief, 25 words"
  t "an edited number does not need to be bold"       "^edited +\[fixture\]"
  t "a number typed into Other: is the budget"        "budget from agreement.md: other, 25 words"
  t "the floor follows the agreement's number"        "thin floor 12 words"
  # `full` and a missing clause are both "no budget stated", and neither may pass by default.
  t "an uncapped level is not scored"                 "sets no scorable response verbosity — full"
  t "the shipped level sets no budget"                "sets no scorable response verbosity — normal"
  t "an agreement with no clause is not scored"       "sets no scorable response verbosity — no clause found"
  # Distinct from "no clause found": the section is there and the user left it blank.
  t "an unchecked clause says so, not no clause"      "sets no scorable response verbosity — nothing checked"
  t "two checked boxes are not resolved by order"     "sets no scorable response verbosity — 2 boxes checked"
  if printf '%s' "$out" | grep -qE "^(full|normal|none|blank|twice) +\[fixture\]"; then
    echo "  FAIL  a case with no budget is not scored as though it had one"; Fc=$((Fc+1))
  else
    echo "  PASS  a case with no budget is not scored as though it had one"; Pc=$((Pc+1))
  fi
  if printf '%s' "$out" | grep -qE "(brief|other) t[0-9]"; then
    echo "  FAIL  a whole fixture case reports no drift"; Fc=$((Fc+1))
  else
    echo "  PASS  a whole fixture case reports no drift"; Pc=$((Pc+1))
  fi
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
  printf 'keep it to 20 words or less. now explain the thing please\n' > "$E/held/turns/1.md"
  dout="$(score "$T/projects" "$E" 2>&1)"; dst=$?
  if printf '%s' "$dout" | grep -q "TURN DRIFT" && [ "$dst" != "0" ]; then
    echo "  PASS  an edited turn is caught as drift and exits non-zero"; Pc=$((Pc+1))
  else
    echo "  FAIL  an edited turn is caught as drift and exits non-zero (exit $dst)"; Fc=$((Fc+1))
  fi
  printf 'keep it to 20 words or less. now explain the thing\n' > "$E/held/turns/1.md"
  rm "$E/held/turns/3.md"
  mout="$(score "$T/projects" "$E" 2>&1)"; mst=$?
  if printf '%s' "$mout" | grep -q "no turns/3.md" && [ "$mst" != "0" ]; then
    echo "  PASS  a transcript turn with no case file is caught as drift"; Pc=$((Pc+1))
  else
    echo "  FAIL  a transcript turn with no case file is caught as drift (exit $mst)"; Fc=$((Fc+1))
  fi
  printf 'and again\n' > "$E/held/turns/3.md"

  # A fixture case has no transcript to drift from, so its two halves check each other. Both
  # directions again: a reply nothing asked for widens the case, a turn whose reply was deleted
  # narrows it, and neither leaves a trace anywhere else.
  rm "$E/brief/turns/2.md"
  printf '%s\n' "$(words 21)" > "$E/brief/replies/4.md"
  printf 'q4\n' > "$E/brief/turns/4.md"
  fout="$(score "$T/projects" "$E" 2>&1)"; fst=$?
  if printf '%s' "$fout" | grep -q "replies/2.md with no turns/2.md" && [ "$fst" != "0" ]; then
    echo "  PASS  a fixture reply with no turn is caught as drift"; Pc=$((Pc+1))
  else
    echo "  FAIL  a fixture reply with no turn is caught as drift (exit $fst)"; Fc=$((Fc+1))
  fi
  # turns/4.md is inside the case's turns directory but outside first_turn..last_turn, so
  # fixture_rows never reaches replies/4.md. An out-of-range pair must not be reported as drift.
  if printf '%s' "$fout" | grep -q "brief t4"; then
    echo "  FAIL  a pair outside first_turn..last_turn is not drift"; Fc=$((Fc+1))
  else
    echo "  PASS  a pair outside first_turn..last_turn is not drift"; Pc=$((Pc+1))
  fi
  printf 'q2\n' > "$E/brief/turns/2.md"
  rm "$E/brief/replies/3.md" "$E/brief/replies/4.md" "$E/brief/turns/4.md"
  gout="$(score "$T/projects" "$E" 2>&1)"; gst=$?
  if printf '%s' "$gout" | grep -q "turns/3.md with no replies/3.md" && [ "$gst" != "0" ]; then
    echo "  PASS  a fixture turn with no reply is caught as drift"; Pc=$((Pc+1))
  else
    echo "  FAIL  a fixture turn with no reply is caught as drift (exit $gst)"; Fc=$((Fc+1))
  fi
  printf '%s\n' "$(words 12)" > "$E/brief/replies/3.md"

  # Every reply deleted, not just one. Without the pairing check running BEFORE the scorer
  # bails on an empty case, this is the one narrowing that reports as "not scored" and exits 0.
  mv "$E/brief/replies" "$E/brief/replies.keep"
  mkdir -p "$E/brief/replies"
  eout="$(score "$T/projects" "$E" 2>&1)"; est=$?
  if printf '%s' "$eout" | grep -q "turns/1.md with no replies/1.md" && [ "$est" != "0" ]; then
    echo "  PASS  a fixture case emptied of replies is caught as drift"; Pc=$((Pc+1))
  else
    echo "  FAIL  a fixture case emptied of replies is caught as drift (exit $est)"; Fc=$((Fc+1))
  fi
  rmdir "$E/brief/replies"; mv "$E/brief/replies.keep" "$E/brief/replies"

  # No turns/ directory at all. One line naming the directory, not one per reply blaming a
  # turn nobody ever wrote.
  mv "$E/brief/turns" "$E/brief/turns.keep"
  nout="$(score "$T/projects" "$E" 2>&1)"; nst=$?
  if printf '%s' "$nout" | grep -q "fixture case has no turns/ directory" && [ "$nst" != "0" ]; then
    echo "  PASS  a fixture case with no turns/ names the directory"; Pc=$((Pc+1))
  else
    echo "  FAIL  a fixture case with no turns/ names the directory (exit $nst)"; Fc=$((Fc+1))
  fi
  if [ "$(printf '%s' "$nout" | grep -c "brief t[0-9]")" -gt 0 ]; then
    echo "  FAIL  it does not also blame each reply individually"; Fc=$((Fc+1))
  else
    echo "  PASS  it does not also blame each reply individually"; Pc=$((Pc+1))
  fi
  mv "$E/brief/turns.keep" "$E/brief/turns"

  # --strict turns an absent transcript into a failure; the default does not.
  sst="$(RL_ROOT_DIR="$T/projects" RL_EVAL_DIR="$E" RL_STRICT=1 python "$HERE/response-length.py" >/dev/null 2>&1; echo $?)"
  [ "$sst" != "0" ] && { echo "  PASS  --strict fails on an absent transcript"; Pc=$((Pc+1)); } \
                    || { echo "  FAIL  --strict fails on an absent transcript"; Fc=$((Fc+1)); }

  # Probe mode, on a fixture rather than a billed run. The rule under test is CUT: a turn the
  # runner stopped has a truncated reply, and a truncated reply is short. Scored as held it
  # would report the fix working every time the probe ran out of budget.
  PJ="$T/probe.json"
  python - "$PJ" <<'PYJSON'
import json, sys
w = lambda n: " ".join("w" * n)
json.dump({"held": {
    "1": {"text": w(18), "cut": "",                  "fired": ["chat-response"]},
    "2": {"text": w(60), "cut": "",                  "fired": []},
    "3": {"text": w(4),  "cut": "error_max_budget",  "fired": []},
    "4": {"text": w(2),  "cut": "",                  "fired": []},
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
  p "a turn the runner cut short scores CUT, not UNDER" "CUT +t3 +4 words"
  p "a cut turn is not counted in the rate"             "within budget \(20 words\): 1/2"
  p "cut turns are counted separately from thin ones"   "thin 2 \(of which cut short by the runner: 1\)"
  p "the turns chat-response fired on are named"        "chat-response fired on: t1"
  if printf '%s' "$pout" | grep -q "cannot see a change to skills/chat-response"; then
    echo "  FAIL  probe mode does not print the replay-only caveat"; Fc=$((Fc+1))
  else
    echo "  PASS  probe mode does not print the replay-only caveat"; Pc=$((Pc+1))
  fi

  # A threshold the fixture clears must flip the verdict, or the verdict is not reading it.
  tout="$(RL_ROOT_DIR="$T/projects" RL_EVAL_DIR="$E" RL_THRESHOLD=0.5 python "$HERE/response-length.py" 2>&1)"
  if printf '%s' "$tout" | grep -qE "^verdict +PASS"; then
    echo "  PASS  the threshold is read, not hardcoded"; Pc=$((Pc+1))
  else
    echo "  FAIL  the threshold is read, not hardcoded"; Fc=$((Fc+1))
  fi

  echo
  echo "$Pc passed, $Fc failed"
  [ "$Fc" = "0" ] || exit 1
  exit 0
fi

ROOT="${MINER_PROJECTS_ROOT:-$HOME/.claude/projects}"
EVAL_DIR="${RL_EVAL_DIR_OVERRIDE:-evals/response-length}"

if [ "$PROBE" = "0" ]; then
  score "$ROOT" "$EVAL_DIR"
  exit $?
fi

command -v claude >/dev/null 2>&1 || { echo "claude CLI not on PATH — nothing to probe" >&2; exit 2; }

# RL_PROBE_OUT keeps the raw replies. Without it the JSON dies with the temp directory and a
# billed run cannot be re-scored later — which is what #158's runs cost when their numbers had
# to be revisited, and what #160's cost again until tools/topic-numbering.sh grew the same
# option. The probe runner opens the path "w" unconditionally, so anything that exists and is
# not already probe JSON stops the run before a turn is billed.
OUT="${RL_PROBE_OUT:-$(mktemp -d)/probe.json}"
if [ -n "${RL_PROBE_OUT:-}" ]; then
  mkdir -p "$(dirname "$OUT")" 2>/dev/null
  if [ -e "$OUT" ] && ! python -c "import json,sys;json.load(open(sys.argv[1]))" "$OUT" 2>/dev/null; then
    echo "RL_PROBE_OUT=$OUT exists and is not probe JSON — refusing to overwrite it" >&2
    exit 2
  fi
fi
echo "response-length --probe — ${RUNS} run(s) per case, live against the INSTALLED plugin"
echo "Run tools/plugin-reload.sh first or this measures the version before your edit."
echo

for CASEDIR in $(find "$EVAL_DIR" -name case.yaml | sort); do
  DIR="$(dirname "$CASEDIR")"
  NAME="$(printf '%s' "${DIR#"$EVAL_DIR"/}" | tr '\\' '/')"
  [ -n "$ONLY" ] && [ "$NAME" != "$ONLY" ] && continue
  # A fixture case has nothing to probe. Its budget is a clause in an operating agreement, and
  # the probe cannot install one into the session it opens — a live run would score the reply
  # against THIS repository's agreement rather than the case's, and report the wrong number
  # with no sign anything was substituted. Scored from its stored replies, never billed.
  if grep -qE '^\s*kind:\s*fixture' "$CASEDIR"; then
    echo "  $NAME  skipped — fixture case, no session to probe"
    continue
  fi
  for r in $(seq 1 "$RUNS"); do
    echo "  $NAME  run $r"
    RL_PROBE_CWD="$(pwd)" python "$HERE/response-length-probe.py" "$DIR" "$NAME" "$OUT" || exit 1
    # Each run overwrites the case's entry, so a multi-run probe scores the last one. Score
    # between runs to keep them all; --runs is here for repeatability, not for averaging.
    score "$ROOT" "$EVAL_DIR" "$OUT"
  done
done
