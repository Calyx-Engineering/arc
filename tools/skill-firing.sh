#!/usr/bin/env bash
# skill-firing.sh — how often each shipping skill actually fires, from real sessions.
#
#   tools/skill-firing.sh <briefed-slug> [<briefed-slug>...] [--since <ISO8601>] [--opening N]
#   tools/skill-firing.sh selftest
#
# WHY THIS EXISTS. Nothing measured whether a skill fires, so no change to a skill could be
# shown to have worked. claude plugin eval was the plan and is gated behind early access —
# #181. The measurement did not need it: every invocation is already a Skill tool_use in the
# transcript, as {"type":"tool_use","name":"Skill","input":{"skill":"arc:chat-response"}}.
#
# WHAT IT IS NOT. This reports what happened. It cannot re-run a case against a changed skill,
# so it gives a baseline and detects drift after the fact — not regression testing.
#
# DEFINITIONS, because the numbers are meaningless without them.
#   session   one .jsonl transcript
#   opening   the first N prompt turns of a session, default 3. A skill fired "at the opening"
#             when its first fire came before prompt turn N+1. Three, because a session's
#             subject is set by then — the handoff read, the correction, the first instruction.
#   turn      a prompt the user typed, or one the loop dispatched. NOT a tool result, a skill
#             injection, a slash command's echo, an interrupt marker or a task notification —
#             all of which arrive on a "user" envelope too. See is_prompt_turn() in the .py.
#             Counting them was #155's finding; it biased "at opening" downward.
#   fires     every Skill tool_use naming that skill
#   sessions  distinct sessions it fired in, over sessions in the corpus
#
# THE DENOMINATOR IS ALWAYS PRINTED. "arc:handoff fired 3 times" is unreadable without how many
# openings it had.
#
# Scope comes from tools/miner-scope.sh — briefed directories only, never a prefix glob (#141).

set -u
cd "${FIRING_ROOT:-$(dirname "$0")/..}" || exit 1

HERE="$(cd "$(dirname "$0")" && pwd)"
SINCE=""
OPENING=3
SLUGS=""
SELFTEST=0

while [ "$#" -gt 0 ]; do
  case "$1" in
    selftest)  SELFTEST=1 ;;
    --since)   shift; SINCE="${1:-}" ;;
    --opening) shift; OPENING="${1:-3}" ;;
    -h|--help) sed -n "2,30p" "$0"; exit 0 ;;
    -*) echo "unknown option: $1" >&2; exit 2 ;;
    *) SLUGS="$SLUGS $1" ;;
  esac
  shift
done

report() {  # report <projects-root> <skills-dir> <briefed-slug>...
  local root="$1" skdir="$2"
  shift 2
  local dirs
  dirs="$(MINER_PROJECTS_ROOT="$root" bash "$HERE/miner-scope.sh" "$@" 2>/dev/null | sed -n "s/^IN  *//p")"
  if [ -z "$dirs" ]; then
    echo "no directory in scope for: $*" >&2
    return 1
  fi
  FIRING_DIRS="$dirs" FIRING_ROOT_DIR="$root" FIRING_SKILLS="$skdir" \
  FIRING_SINCE="$SINCE" FIRING_OPENING="$OPENING" python "$HERE/skill-firing.py"
}

if [ "$SELFTEST" = "1" ]; then
  T="$(mktemp -d)"
  trap 'rm -rf "$T"' EXIT
  P="$T/projects"
  S="$T/skills"
  mkdir -p "$P/r--fixture" "$P/r--other" "$S"
  for k in alpha beta gamma delta epsilon zeta eta theta iota; do
    mkdir -p "$S/$k"; echo "# $k" > "$S/$k/SKILL.md"
  done

  # Every envelope below has type "user", and only u() and disp() are prompt turns.
  #
  # Four of the five rejected shapes are given promptSource "sdk" here, which is the one
  # condition in which each shape's own guard is load-bearing. As they appear in the raw store
  # they carry no promptSource and the final clause of is_prompt_turn() rejects them anyway — so
  # a fixture built from the store's shape would pass with that shape's guard deleted, and
  # assert nothing. The fifth, cmd(), is the shape the final clause itself rejects, so it is
  # left as the store writes it. The guards exist so that a format change cannot silently
  # re-inflate the count the way #155 found it inflated; these fixtures make deleting one go red.
  u()      { printf '{"type":"user","promptSource":"sdk","origin":{"kind":"human"},"timestamp":"%s","message":{"content":"typed by the user"}}\n' "$1"; }
  disp()   { printf '{"type":"user","promptSource":"sdk","timestamp":"%s","message":{"content":"dispatched by the loop"}}\n' "$1"; }
  meta()   { printf '{"type":"user","isMeta":true,"timestamp":"%s","message":{"content":"Base directory for this skill: ..."}}\n' "$1"; }
  metask() { printf '{"type":"user","promptSource":"sdk","isMeta":true,"timestamp":"%s","message":{"content":"Base directory for this skill: ..."}}\n' "$1"; }
  ressk()  { printf '{"type":"user","promptSource":"sdk","timestamp":"%s","message":{"content":[{"type":"tool_result","content":"x"}]}}\n' "$1"; }
  note()   { printf '{"type":"user","promptSource":"sdk","origin":{"kind":"task-notification"},"timestamp":"%s","message":{"content":"an agent finished"}}\n' "$1"; }
  intrsk() { printf '{"type":"user","promptSource":"sdk","timestamp":"%s","message":{"content":[{"type":"text","text":"[Request interrupted by user]"}]}}\n' "$1"; }
  cmd()    { printf '{"type":"user","timestamp":"%s","message":{"content":[{"type":"text","text":"<command-name>/plugin</command-name>"}]}}\n' "$1"; }
  sk()     { printf '{"type":"assistant","timestamp":"%s","message":{"content":[{"type":"tool_use","name":"Skill","input":{"skill":"arc:%s"}}]}}\n' "$1" "$2"; }

  # ---- one session per rule, each built so the wrong answer scores differently ---------------

  # alpha fires after one prompt turn — at the opening. The injection its own firing causes
  # sits between, in the shape the store actually writes, and must not push the next turn out.
  { u 2026-09-01T10:00; sk 2026-09-01T10:01 alpha; meta 2026-09-01T10:01; u 2026-09-01T10:02; } > "$P/r--fixture/s1.jsonl"
  # beta fires after five prompt turns — a fire, not an opening fire.
  { u 2026-09-01T11:00; u 2026-09-01T11:01; u 2026-09-01T11:02; u 2026-09-01T11:03; u 2026-09-01T11:04; sk 2026-09-01T11:05 beta; } > "$P/r--fixture/s2.jsonl"
  # gamma fires, but the whole session predates --since
  { u 2026-08-01T09:00; sk 2026-08-01T09:01 gamma; } > "$P/r--fixture/s3.jsonl"
  # a directory that was not briefed
  { u 2026-09-01T12:00; sk 2026-09-01T12:01 gamma; } > "$P/r--other/s4.jsonl"

  # Two prompt turns, three of the envelope under test. At the opening iff it is not counted.
  { u 2026-09-02T10:00; metask 2026-09-02T10:01; metask 2026-09-02T10:02; metask 2026-09-02T10:03; u 2026-09-02T10:04; sk 2026-09-02T10:05 delta;   } > "$P/r--fixture/s5.jsonl"
  { u 2026-09-02T11:00; ressk  2026-09-02T11:01; ressk  2026-09-02T11:02; ressk  2026-09-02T11:03; u 2026-09-02T11:04; sk 2026-09-02T11:05 epsilon; } > "$P/r--fixture/s6.jsonl"
  { u 2026-09-02T12:00; note   2026-09-02T12:01; note   2026-09-02T12:02; note   2026-09-02T12:03; u 2026-09-02T12:04; sk 2026-09-02T12:05 zeta;    } > "$P/r--fixture/s7.jsonl"
  { u 2026-09-02T13:00; intrsk 2026-09-02T13:01; intrsk 2026-09-02T13:02; intrsk 2026-09-02T13:03; u 2026-09-02T13:04; sk 2026-09-02T13:05 eta;     } > "$P/r--fixture/s8.jsonl"
  # A slash command's echo carries no promptSource, no origin and no isMeta, and is not a
  # tool_result — the final clause of is_prompt_turn() is the only thing that rejects it.
  { u 2026-09-02T15:00; cmd 2026-09-02T15:01; cmd 2026-09-02T15:02; cmd 2026-09-02T15:03; u 2026-09-02T15:04; sk 2026-09-02T15:05 iota; } > "$P/r--fixture/s10.jsonl"
  # Four loop-dispatched prompts and nothing typed. Outside the window iff disp IS counted.
  { disp 2026-09-02T14:00; disp 2026-09-02T14:01; disp 2026-09-02T14:02; disp 2026-09-02T14:03; sk 2026-09-02T14:04 theta; } > "$P/r--fixture/s9.jsonl"

  SINCE="2026-08-24T00:00"
  OPENING=3
  out="$(report "$P" "$S" r--fixture 2>&1)"
  Pc=0
  Fc=0
  t() {
    if printf '%s' "$out" | grep -qE -- "$2"; then
      echo "  PASS  $1"
      Pc=$((Pc + 1))
    else
      echo "  FAIL  $1"
      echo "        wanted /$2/"
      echo "        got:"
      printf '%s\n' "$out" | sed 's/^/          /'
      Fc=$((Fc + 1))
    fi
  }

  echo "skill-firing selftest"
  echo
  t "a session entirely before --since is out of the corpus"   "corpus: 8 sessions"
  t "an unbriefed directory is not read"                       "in 1 directorie"
  t "a fire within the first 3 prompt turns is at the opening" "^alpha +1 +1/8 +1/8"
  t "a fire after 5 prompt turns is a fire, not an opening"    "^beta +1 +1/8 +0/8"
  t "a skill injection is not a prompt turn"                   "^delta +1 +1/8 +1/8"
  t "a tool_result is not a prompt turn"                       "^epsilon +1 +1/8 +1/8"
  t "a task notification is not a prompt turn"                 "^zeta +1 +1/8 +1/8"
  t "an interrupt marker is not a prompt turn"                 "^eta +1 +1/8 +1/8"
  t "a loop-dispatched prompt IS a prompt turn"                "^theta +1 +1/8 +0/8"
  t "a slash command's echo is not a prompt turn"              "^iota +1 +1/8 +1/8"
  t "a skill that never fired is reported with zeros"          "^gamma +0 +0/8 +0/8"
  t "never-fired skills are named"                             "never fired: gamma"
  echo
  echo "$Pc passed, $Fc failed"
  [ "$Fc" = "0" ] || exit 1
  exit 0
fi

if [ -z "$SLUGS" ]; then
  echo "usage: tools/skill-firing.sh <briefed-slug> [...] [--since ISO] [--opening N]" >&2
  echo "       a briefed slug is a directory name under ~/.claude/projects" >&2
  exit 2
fi

# shellcheck disable=SC2086
report "${MINER_PROJECTS_ROOT:-$HOME/.claude/projects}" skills $SLUGS
