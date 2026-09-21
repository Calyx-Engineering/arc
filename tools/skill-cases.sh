#!/usr/bin/env bash
# skill-cases.sh — score the eval cases in evals/skill-firing against the sessions they came from.
#
#   tools/skill-cases.sh              score every case
#   tools/skill-cases.sh --strict     also fail when a case's transcript is not on this machine
#   tools/skill-cases.sh selftest     fixtures only, no corpus needed
#
# WHY THIS EXISTS. tools/skill-firing.sh answers "how often did each skill fire", over whole
# sessions. It cannot answer "did this skill fire in response to THIS prompt", which is the
# question #155 asks — the three shapes are properties of a single turn, not of a session.
#
# WHAT A PASS IS. The expected skill fired between the case's prompt turn and the next one.
# A fire twenty turns later is not a pass: by then the user has said the thing again, and the
# measurement would be crediting the skill for the user's persistence.
#
# WHAT IT IS NOT. This scores what happened. It cannot re-run a prompt against a changed skill.
# That is claude plugin eval, gated behind early access — #181. The prompts here are already in
# its layout, so the port is a rename.
#
# THE VERBATIM CLAIM IS CHECKED, NOT TRUSTED. Every prompt.md is compared against the turn it
# claims to copy. Drift fails the run — "drawn from real openings" stops being true the moment
# a prompt is tidied up.
#
# THE CORPUS IS LOCAL. Transcripts live under ~/.claude/projects on one machine, so a case whose
# session is absent is reported and skipped rather than failed. Only the selftest is portable,
# which is why it is the part wired into tests/verify-all.sh.

set -u
cd "${CASES_CD:-$(dirname "$0")/..}" || exit 1

HERE="$(cd "$(dirname "$0")" && pwd)"
STRICT=0
SELFTEST=0

while [ "$#" -gt 0 ]; do
  case "$1" in
    selftest) SELFTEST=1 ;;
    --strict) STRICT=1 ;;
    -h|--help) sed -n "2,26p" "$0"; exit 0 ;;
    *) echo "unknown argument: $1" >&2; exit 2 ;;
  esac
  shift
done

score() {  # score <projects-root> <eval-dir>
  CASES_ROOT_DIR="$1" CASES_EVAL_DIR="$2" CASES_STRICT="$STRICT" python "$HERE/skill-cases.py"
}

if [ "$SELFTEST" = "1" ]; then
  T="$(mktemp -d)"
  # The selftest never reads the live mask: it is untracked, so a suite that depended on it
  # would pass on one machine only. #320.
  export ARC_CORPUS_MASK="$T/no-mask"
  trap 'rm -rf "$T"' EXIT
  P="$T/projects/r--fixture"
  E="$T/evals"
  mkdir -p "$P"

  # Envelope shapes, all of which arrive as type "user". Only hu() is a prompt turn.
  # The loop-dispatched and slash-command shapes are covered by tools/skill-firing.sh,
  # which owns the corpus-wide counter; this fixture covers what shifts a case's turn.
  hu()   { printf '{"type":"user","origin":{"kind":"human"},"timestamp":"%s","message":{"content":%s}}\n' "$1" "$2"; }
  meta() { printf '{"type":"user","isMeta":true,"timestamp":"%s","message":{"content":"skill body injected here"}}\n' "$1"; }
  res()  { printf '{"type":"user","timestamp":"%s","message":{"content":[{"type":"tool_result","content":"x"}]}}\n' "$1"; }
  note() { printf '{"type":"user","origin":{"kind":"task-notification"},"timestamp":"%s","message":{"content":"a task finished"}}\n' "$1"; }
  sk()   { printf '{"type":"assistant","timestamp":"%s","message":{"content":[{"type":"tool_use","name":"Skill","input":{"skill":"arc:%s"}}]}}\n' "$1" "$2"; }

  {
    hu 2026-09-01T10:00 '"Hi Camp, where are we at?"'
    sk 2026-09-01T10:01 camp
    meta 2026-09-01T10:01
    res 2026-09-01T10:01
    note 2026-09-01T10:01
    hu 2026-09-01T10:02 '"read handoff then tell me the order"'
    hu 2026-09-01T10:04 '"log this in the friction log"'
    sk 2026-09-01T10:05 handoff
    hu 2026-09-01T10:06 '[{"type":"text","text":"can you check the branch?"}]'
  } > "$P/aaa11111.jsonl"

  mk() {  # mk <shape> <slug> <session> <turn> <expect-lines> <prompt>
    mkdir -p "$E/$1/$2/graders"
    printf 'shape: %s\nexpect:\n%s\nsource:\n  session: %s\n  turn: %s\n  opening: true\n' \
      "$1" "$5" "$3" "$4" > "$E/$1/$2/case.yaml"
    printf '%s\n' "$6" > "$E/$1/$2/prompt.md"
    printf '# grader\n' > "$E/$1/$2/graders/fired.md"
  }

  mk bare      hit        aaa11111 1 "  - camp"    "Hi Camp, where are we at?"
  mk wrapped   miss       aaa11111 2 "  - handoff" "read handoff then tell me the order"
  mk wrapped   late       aaa11111 3 "  - handoff" "log this in the friction log"
  mk situation control-ok aaa11111 4 "  - none"    "can you check the branch?"
  mk situation absent     zzz99999 1 "  - camp"    "not on this machine"

  out="$(score "$T/projects" "$E" 2>&1)"; st=$?
  Pc=0; Fc=0
  t() {
    if printf '%s' "$out" | grep -qE -- "$2"; then echo "  PASS  $1"; Pc=$((Pc+1))
    else
      echo "  FAIL  $1"; echo "        wanted /$2/"; echo "        got:"
      printf '%s\n' "$out" | sed 's/^/          /'; Fc=$((Fc+1))
    fi
  }

  echo "skill-cases selftest"
  echo
  t "a bare name that fired on its own turn passes"            "PASS +hit"
  t "a fire belonging to the NEXT turn does not score this one" "FAIL +miss +.*nothing fired"
  t "a fire on the case's own turn scores it"                  "PASS +late"
  t "a control turn with no fire passes"                       "PASS +control-ok"
  # If the skill injection, the tool result or the task notification after turn 1 counted,
  # turn 2 would resolve to the injected skill body and every later case would shift.
  # Drift is how that shows up, so no-drift is the assertion.
  if printf '%s' "$out" | grep -q "PROMPT DRIFT"; then
    echo "  FAIL  a skill injection is not counted as a prompt turn"; Fc=$((Fc+1))
  else
    echo "  PASS  a skill injection is not counted as a prompt turn"; Pc=$((Pc+1))
  fi
  t "a missing transcript is reported, not scored"             "NOT SCORED"
  t "the per-shape rate is printed"                            "^wrapped +1/2"
  t "the per-skill rate is printed"                            "^handoff +1/2"
  # source.opening was recorded by every case and read by nothing until #157. The Done when
  # there is about openings, so the rate has to be printable without re-deriving it by hand.
  t "the opening rate is printed"                              "^all opening cases +3/4"
  [ "$st" = "0" ] && { echo "  PASS  a clean run exits 0"; Pc=$((Pc+1)); } \
                  || { echo "  FAIL  a clean run exits 0 (got $st)"; Fc=$((Fc+1)); }

  # Drift must fail, and must fail loudly.
  printf 'Hi Camp, where are we at today?\n' > "$E/bare/hit/prompt.md"
  dout="$(score "$T/projects" "$E" 2>&1)"; dst=$?
  if printf '%s' "$dout" | grep -q "PROMPT DRIFT" && [ "$dst" != "0" ]; then
    echo "  PASS  an edited prompt.md is caught as drift and exits non-zero"; Pc=$((Pc+1))
  else
    echo "  FAIL  an edited prompt.md is caught as drift and exits non-zero (exit $dst)"; Fc=$((Fc+1))
  fi

  # #320: a stored prompt that holds a stand-in matches its transcript through the mask, and
  # without the mask the same pair is drift. The pair is what shows the mask is what passed it.
  printf 'Hi [the assistant], where are we at?
' > "$E/bare/hit/prompt.md"
  printf '# a comment

Camp~[the assistant]
' > "$T/mask"
  mout="$(ARC_CORPUS_MASK="$T/mask" score "$T/projects" "$E" 2>&1)"
  if printf '%s' "$mout" | grep -q "PROMPT DRIFT"; then
    echo "  FAIL  a masked prompt matches its transcript through the mask"; Fc=$((Fc+1))
  else
    echo "  PASS  a masked prompt matches its transcript through the mask"; Pc=$((Pc+1))
  fi
  nout="$(score "$T/projects" "$E" 2>&1)"
  if printf '%s' "$nout" | grep -q "PROMPT DRIFT"; then
    echo "  PASS  and without the mask the same prompt is drift"; Pc=$((Pc+1))
  else
    echo "  FAIL  and without the mask the same prompt is drift"; Fc=$((Fc+1))
  fi
  printf 'Hi Camp, where are we at?
' > "$E/bare/hit/prompt.md"

  # --strict turns an absent transcript into a failure; the default does not.
  sout="$(CASES_ROOT_DIR="$T/projects" CASES_EVAL_DIR="$E" CASES_STRICT=1 python "$HERE/skill-cases.py" >/dev/null 2>&1; echo $?)"
  [ "$sout" != "0" ] && { echo "  PASS  --strict fails on an absent transcript"; Pc=$((Pc+1)); } \
                     || { echo "  FAIL  --strict fails on an absent transcript"; Fc=$((Fc+1)); }

  echo
  echo "$Pc passed, $Fc failed"
  [ "$Fc" = "0" ] || exit 1
  exit 0
fi

score "${MINER_PROJECTS_ROOT:-$HOME/.claude/projects}" evals/skill-firing
