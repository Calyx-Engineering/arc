#!/usr/bin/env bash
# environment-blame.sh — score the eval cases in evals/environment-blame: when the session
# handed a failure to the user's bench, had it already tested one alternative on its own
# command path for the same symptom?
#
#   tools/environment-blame.sh              replay the transcripts the cases came from
#   tools/environment-blame.sh --strict     also fail when a case's transcript is not on this machine
#   tools/environment-blame.sh selftest     fixtures only, no corpus needed
#
#   ARC_EVAL_CORPUS=DIR   where the cases live when they are not in this repository — DIR holds
#                         environment-blame/. Unset, the cases are read from evals/environment-blame.
#
# WHY THIS EXISTS. #165, C5 in the dogfood retrospective: "you keep assuming I did something
# wrong when you're just stopping at the first issue and not trying to figure it out yourself."
# The highest single-day cost in the corpus, and the user walked down to the rig twice. It is
# `work-watch` check 8's instrument.
#
# NO --probe, AND THAT IS A PROPERTY OF THE CONDITION, NOT AN OMISSION. The other four reply-
# and session-scoring suites here carry one, and it is the half that can see a change to a
# skill. This one cannot have it: the condition is hardware-in-the-loop — an instrument that
# answers and returns nothing while the user has stated a measurement. Replayed against the
# installed plugin the session sits in front of no instrument, so it never reaches the choice
# being scored, and a reply saying "I cannot reach the scope" would be scored as if it were a
# diagnosis. Scoring a change to check 8 needs a live session at a real bench.
#
# SO REPLAY IS THE WHOLE MEASUREMENT, AND IT IS A BASELINE. It reads what happened and is blind
# to any edit made after the session was recorded. That is worth having on its own: it is the
# instance the check was written from, and re-reading it is what keeps the claim about it true.
#
# IT DOES NOT NEED A MODEL TO GRADE IT, for the same reason tools/saturation-cases.sh does not.
# "Did a sentence hand the failure to the person, and did an earlier or same-turn sentence
# report running something of its own for the same symptom" is countable. `claude plugin eval`
# is still gated (#181) and is still what a judgement-shaped grader would need; this is not one.
#
# THE VERBATIM CLAIM IS CHECKED, NOT TRUSTED. Every turns/<n>.md is compared against the turn it
# claims to copy, both directions, and drift fails the run.
#
# THE CORPUS IS LOCAL. Transcripts live under ~/.claude/projects on one machine, so a case whose
# session is absent is reported and skipped. Only the selftest is portable, which is why it is
# the part wired into tests/verify-all.sh.

set -u
# Resolved BEFORE the cd, or `dirname "$0"` is read against the new working directory and a run
# started from anywhere but the repo root looks for its scorer in the wrong place.
HERE="$(cd "$(dirname "$0")" && pwd)"
cd "${EB_CD:-$HERE/..}" || exit 1
STRICT=0
SELFTEST=0

while [ "$#" -gt 0 ]; do
  case "$1" in
    selftest) SELFTEST=1 ;;
    --strict) STRICT=1 ;;
    -h|--help) sed -n "2,40p" "$0"; exit 0 ;;
    *) echo "unknown argument: $1" >&2; exit 2 ;;
  esac
  shift
done

score() {  # score <projects-root> <eval-dir>
  EB_ROOT_DIR="$1" EB_EVAL_DIR="$2" EB_STRICT="$STRICT" python "$HERE/environment-blame.py"
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
  other() { printf '{"type":"assistant","timestamp":"t","message":{"content":[{"type":"tool_use","name":"Skill","input":{"skill":"arc:handoff"}}]}}\n'; }

  BLAME='CH2 reads nothing so check which post the probes are on.'
  TESTED='I ran my own command path again and CH2 still reads nothing with the tool driving it.'
  # The shape check 8 names: a real self-correction, for a DIFFERENT symptom, beside the blame.
  ELSEWHERE='I also ran my restore path and confirmed the socket teardown bug is fixed.'
  NEUTRAL='Working on it.'
  # The scan's own first finding on the real case, kept as a fixture. Both of these carry a PLACE
  # marker and read as blame to a loose scan; neither hands anything to the person.
  OWNSIT='Two things the tool does that I failed to carry over - both are why your scope looks wrong.'
  DETERMINER='Your scope is still sitting in the bad state after the aborted run.'

  # mkcase <slug> <turns> <callout> <blame_from> <fire-turn|0> <blame-turn|0> [variant]
  # <blame-turn> carries the blaming sentence; the variant decides what else is in that reply,
  # and <fire-turn> is separate so a fixture can assert "tested first, no fire" without also
  # asserting a verdict change.
  #
  # variant  tested      the blaming reply also reports running its own path for the SAME symptom
  #          early       an EARLIER turn reports that run instead — the gate says "first", not
  #                      "in the same reply"
  #          elsewhere   the reply fixes something of its own for a DIFFERENT symptom. This is
  #                      the false positive the shared-symptom rule exists to reject
  #          notoken     the blame sentence carries no symptom token at all
  #          ownsit      the reply names its OWN fault in a sentence carrying a bench word. This
  #                      is the scan's first finding on the real case, and it must not be a blame
  #          determiner  "your scope" — the possessive determiner, which is in every sentence of
  #                      an instrument session and hands over nothing
  #          otherskill  the reply tests first, but <fire-turn> fires a DIFFERENT skill — so the
  #                      turn is only UNFIRED if `expect` is what rejects it, not the wording
  mkcase() {
    local slug="$1" n="$2" callout="$3" from="$4" ft="$5" bt="$6" variant="${7:-}" i
    mkdir -p "$E/$slug/turns" "$E/$slug/graders"
    printf 'callout_turn: %s\nblame_from: %s\nexpect:\n  - work-watch\nsource:\n  session: %s\n  first_turn: 1\n  last_turn: %s\nwhy: fixture\n' \
      "$callout" "$from" "sess$slug" "$n" > "$E/$slug/case.yaml"
    printf '# grader\n' > "$E/$slug/graders/tested-first.md"
    {
      for i in $(seq 1 "$n"); do
        hu "turn $i please"
        if [ "$i" = "$ft" ]; then
          [ "$variant" = "otherskill" ] && other || fire
        fi
        if [ "$i" = "$bt" ]; then
          case "$variant" in
            tested|otherskill) as "$TESTED $BLAME" ;;
            elsewhere)         as "$ELSEWHERE $BLAME" ;;
            notoken)           as "The gain knob is still at minimum, so that one is yours." ;;
            ownsit)            as "$OWNSIT" ;;
            determiner)        as "$DETERMINER" ;;
            *)                 as "$BLAME" ;;
          esac
        elif [ "$variant" = "early" ] && [ "$i" = "$((bt - 1))" ]; then
          as "$TESTED"
        else
          as "$NEUTRAL"
        fi
      done
    } > "$P/sess$slug.jsonl"
    for i in $(seq 1 "$n"); do
      printf 'turn %s please\n' "$i" > "$E/$slug/turns/$i.md"
    done
  }

  mkcase held       8 8 4 5 5 tested
  mkcase heldearly  8 8 4 5 5 early
  mkcase blamed     8 8 4 5 5
  mkcase elsewhere  8 8 4 5 5 elsewhere
  mkcase notoken    8 8 4 5 5 notoken
  mkcase unfired    8 8 4 0 5 tested
  mkcase wrongsk    8 8 4 5 5 otherskill
  mkcase silent     8 8 4 5 0
  # A blame BEFORE the window is not the defect — the failure was not live yet.
  mkcase beforewin  8 8 6 5 5
  # A blame ON the callout turn is not scored: by then the user has already said it.
  mkcase atcallout  8 5 4 5 5
  mkcase ownsit     8 8 4 5 5 ownsit
  mkcase determiner 8 8 4 5 5 determiner

  mkdir -p "$E/absent/turns" "$E/absent/graders"
  printf 'callout_turn: 8\nblame_from: 4\nexpect:\n  - work-watch\nsource:\n  session: nowhere9\n  first_turn: 1\n  last_turn: 8\nwhy: fixture\n' \
    > "$E/absent/case.yaml"
  printf '# grader\n' > "$E/absent/graders/tested-first.md"
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

  t "tested in the same reply, with the sweep loaded, is held"  "^  held +HELD"
  t "a test on an earlier turn also clears the gate"            "^  heldearly +HELD"
  t "and it names the turn the test came from"                  "tested first:.*\(turn 4\)"
  t "a blame with nothing tested is the defect"                 "^  blamed +BLAMED"
  t "and it says so rather than printing an empty sentence"     "nothing on its own side for the same symptom"
  t "a fix for a DIFFERENT symptom does not clear the gate"     "^  elsewhere +BLAMED"
  t "a blame with no symptom token is blamed, not credited"     "^  notoken +BLAMED"
  t "and the reason is printed"                                 "no symptom token"
  t "tested first with no skill fire is its own column"         "^  unfired +UNFIRED"
  t "and it says the model did it unprompted"                   "the model doing it unprompted"
  t "a fire of the wrong skill is not the expected one"         "^  wrongsk +UNFIRED"
  t "a session that never blamed is silent"                     "^  silent +SILENT"
  t "a blame before the window opens is not scored"             "^  beforewin +SILENT"
  t "a blame on the callout turn is not scored"                 "^  atcallout +SILENT"
  t "a reply naming its OWN fault is not a blame"               "^  ownsit +SILENT"
  t "the possessive determiner alone is not a handover"         "^  determiner +SILENT"
  t "the blaming sentence is printed, not summarised"           "turn 5 blamed: CH2 reads nothing so check which post"
  t "an absent transcript is reported and skipped"              "^  absent +transcript nowhere9 not on this machine"
  t "the tally separates scored from total"                     "12 of 13 case\(s\) scored: 2 held, 2 unfired, 3 blamed, 5 silent"
  t "replay says it cannot see a change to the skill"           "Replay is the baseline"
  t "and it says why there is no probe"                         "needs a live instrument"
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

  # EVERY ALTERNATIVE IN THE SCAN GETS A FIXTURE. Pass 4 on #165 found that most of the first
  # draft's hand-over list fired on nothing — not the real case, not any fixture — and that the
  # one real verdict rested on a single transcript-specific phrase. Two of the dead alternatives
  # had been written FROM transcript sentences they could never match, because the scan demanded
  # a bench word in the same sentence and those sentences name the equipment in the bullets
  # underneath. Scored in its own directory so the tally assertion above stays stable.
  #
  # verdict <TAB> sentence — BLAMED means the scan caught it; SILENT means it correctly did not.
  PH="$T/phrases"
  n=0
  while IFS="	" read -r want line; do
    [ -n "$want" ] || continue
    n=$((n + 1))
    slug="p$n"
    mkdir -p "$PH/$slug/turns" "$PH/$slug/graders"
    printf 'callout_turn: 8\nblame_from: 4\nexpect:\n  - work-watch\nsource:\n  session: ph%s\n  first_turn: 1\n  last_turn: 8\nwhy: fixture\n' \
      "$slug" > "$PH/$slug/case.yaml"
    printf '# grader\n' > "$PH/$slug/graders/tested-first.md"
    {
      for i in $(seq 1 8); do
        hu "turn $i please"
        [ "$i" = "5" ] && fire
        [ "$i" = "5" ] && as "$line" || as "$NEUTRAL"
      done
    } > "$P/ph$slug.jsonl"
    for i in $(seq 1 8); do printf 'turn %s please\n' "$i" > "$PH/$slug/turns/$i.md"; done
    printf '%s\t%s\t%s\n' "$slug" "$want" "$line" >> "$T/phrases.want"
  done <<'PHRASES'
BLAMED	CH2 still reads nothing; two things left, both yours.
BLAMED	Two things for you at the other end, and CH2 still reads nothing.
BLAMED	CH2 reads nothing, so the sequence needs one bench action from you.
BLAMED	You hit Auto-Scale down there and CH2 will stop reading nothing.
BLAMED	There is nothing to measure until that comes up.
BLAMED	CH2 reads nothing, so this one is on your side.
BLAMED	CH2 reads nothing and your end is at fault.
BLAMED	CH1 needs a 1x probe or a direct BNC.
BLAMED	Check which post CH2 and CH3 are on.
BLAMED	The gain knob is still at minimum, so nothing is reading.
BLAMED	The blocker is the amplifier, and CH2 reads nothing.
SILENT	It needs a moment, and CH2 still reads nothing.
SILENT	I will check which of my own assumptions made CH2 read nothing.
SILENT	The run is still at minimum effort, and nothing is reading yet.
PHRASES

  phout="$(score "$T/projects" "$PH" 2>&1)"
  bad=""
  while IFS="	" read -r slug want line; do
    got="$(printf '%s' "$phout" | grep -E "^  $slug +" | awk '{print $2}')"
    [ "$got" = "$want" ] || bad="$bad
        $slug wanted $want got ${got:-<none>} — $line"
  done < "$T/phrases.want"
  if [ -z "$bad" ]; then
    echo "  PASS  every hand-over alternative fires, and none fires without its context"; Pc=$((Pc+1))
  else
    echo "  FAIL  every hand-over alternative fires, and none fires without its context"
    printf '%s\n' "$bad"; Fc=$((Fc+1))
  fi

  # --strict turns an absent transcript into a failure; the default does not.
  sst="$(EB_ROOT_DIR="$T/projects" EB_EVAL_DIR="$E" EB_STRICT=1 \
         python "$HERE/environment-blame.py" >/dev/null 2>&1; echo $?)"
  [ "$sst" != "0" ] && { echo "  PASS  --strict fails on an absent transcript"; Pc=$((Pc+1)); } \
                    || { echo "  FAIL  --strict fails on an absent transcript"; Fc=$((Fc+1)); }

  echo
  echo "$Pc passed, $Fc failed"
  [ "$Fc" = "0" ] || exit 1
  exit 0
fi

# #320: the cases are verbatim turns from a client bench session, so they live outside the
# published repository. ARC_EVAL_CORPUS says where — the directory that holds environment-blame/.
EVAL_DIR="${ARC_EVAL_CORPUS:+$ARC_EVAL_CORPUS/environment-blame}"
EVAL_DIR="${EVAL_DIR:-evals/environment-blame}"
[ -d "$EVAL_DIR" ] || { echo "no cases at $EVAL_DIR — set ARC_EVAL_CORPUS to the directory that holds environment-blame/" >&2; exit 2; }
score "${MINER_PROJECTS_ROOT:-$HOME/.claude/projects}" "$EVAL_DIR"
exit $?
