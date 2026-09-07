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
#   opening   the first N user messages of a session, default 3. A skill fired "at the opening"
#             when its first fire came before user message N+1. Three, because a session's
#             subject is set by then — the handoff read, the correction, the first instruction.
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
    -h|--help) sed -n "2,25p" "$0"; exit 0 ;;
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
  mkdir -p "$P/r--fixture" "$P/r--other" "$S/alpha" "$S/beta" "$S/gamma"
  for k in alpha beta gamma; do echo "# $k" > "$S/$k/SKILL.md"; done

  u()   { printf '{"type":"user","timestamp":"%s","message":{"content":"hi"}}\n' "$1"; }
  res() { printf '{"type":"user","timestamp":"%s","message":{"content":[{"type":"tool_result","content":"x"}]}}\n' "$1"; }
  sk()  { printf '{"type":"assistant","timestamp":"%s","message":{"content":[{"type":"tool_use","name":"Skill","input":{"skill":"arc:%s"}}]}}\n' "$1" "$2"; }

  # alpha fires after one user turn — at the opening
  { u 2026-09-01T10:00; sk 2026-09-01T10:01 alpha; u 2026-09-01T10:02; } > "$P/r--fixture/s1.jsonl"
  # beta fires after five user turns — a fire, not an opening fire. The tool_result must not count.
  { u 2026-09-01T11:00; res 2026-09-01T11:00; u 2026-09-01T11:01; u 2026-09-01T11:02; u 2026-09-01T11:03; u 2026-09-01T11:04; sk 2026-09-01T11:05 beta; } > "$P/r--fixture/s2.jsonl"
  # gamma fires, but the whole session predates --since
  { u 2026-08-01T09:00; sk 2026-08-01T09:01 gamma; } > "$P/r--fixture/s3.jsonl"
  # a directory that was not briefed
  { u 2026-09-01T12:00; sk 2026-09-01T12:01 gamma; } > "$P/r--other/s4.jsonl"

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
  t "a session entirely before --since is out of the corpus"  "corpus: 2 sessions"
  t "an unbriefed directory is not read"                      "in 1 directorie"
  t "a fire within the first 3 user turns is at the opening"  "^alpha +1 +1/2 +1/2"
  t "a fire after 5 user turns is a fire, not an opening"     "^beta +1 +1/2 +0/2"
  t "a tool_result on a user envelope is not a user turn"     "^beta +1 +1/2 +0/2"
  t "a skill that never fired is reported with zeros"         "^gamma +0 +0/2 +0/2"
  t "never-fired skills are named"                            "never fired: gamma"
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
