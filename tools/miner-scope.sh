#!/usr/bin/env bash
# miner-scope.sh — which transcript directories a briefed mining run may read.
#
#   tools/miner-scope.sh <briefed-slug> [<briefed-slug>...]
#
# WHY THIS EXISTS. agents/transcript-miner said "glob across every matching raw directory,
# never one", because worktrees get their own slug and a scoped search misses a deleted
# worktree's orphaned directory silently — 45 MB of the richest material, once. Matching on a
# shared prefix then pulled in a sibling repository: briefed on roadz-sound-system, the first
# real run also read R--work-lantern-roadz-pb-firmware, which is a different product. #141.
#
# THE RULE. A directory is in scope when, case-insensitively, its slug either
#   (a) equals a briefed slug, or
#   (b) begins with a briefed slug followed by "--"  — the worktree form,
#       <slug>--claude-worktrees-<branch>
# A shared stem is not enough. "roadz-sound-system" is not a prefix of "roadz-pb-firmware"
# under (b), because the separator has to be there.
#
# OUTPUT is two columns so a caller can act on it and a packet can quote it:
#   IN    <dir>
#   NEAR  <dir>   shares a stem with a briefed slug, and is not one — the #141 case
#   SKIP  <dir>   unrelated
# Every present directory appears on exactly one line. A skipped directory named in the packet
# is information; a skipped directory nobody mentions is indistinguishable from one that does
# not exist.
#
# EXIT. 0 when every briefed slug matched at least one directory. 1 when one matched nothing —
# that is a wrong brief, not an empty result, and it must not read as "no friction found".

set -u

ROOT="${MINER_PROJECTS_ROOT:-$HOME/.claude/projects}"

# ---- selftest ------------------------------------------------------------------------
# Throwaway fixture trees, the same precedent as verify-tracker-body.sh selftest. Every case
# below is a real shape from the raw store.
if [ "${1:-}" = "selftest" ]; then
  T="$(mktemp -d)"
  trap 'rm -rf "$T"' EXIT
  mkdir -p "$T/r--work-lantern-roadz-sound-system"            "$T/R--work-lantern-roadz-sound-system--claude-worktrees-interface-pcba-rev-b-issue-1"            "$T/R--work-lantern-roadz-pb-firmware"            "$T/r--arc"            "$T/r--lodestar"
  P=0; F=0
  t() { # t <label> <expected-substring> <args...>
    local label="$1" want="$2"; shift 2
    local got; got="$(MINER_PROJECTS_ROOT="$T" bash "$0" "$@" 2>&1)"
    if printf '%s' "$got" | grep -qF -- "$want"; then
      echo "  PASS  $label"; P=$((P+1))
    else
      echo "  FAIL  $label"; echo "        wanted: $want"; echo "        got:"; printf '%s
' "$got" | sed 's/^/          /'
      F=$((F+1))
    fi
  }
  te() { # te <label> <expected-exit> <args...>
    local label="$1" want="$2"; shift 2
    MINER_PROJECTS_ROOT="$T" bash "$0" "$@" >/dev/null 2>&1
    local got=$?
    if [ "$got" = "$want" ]; then echo "  PASS  $label"; P=$((P+1))
    else echo "  FAIL  $label"; echo "        wanted exit $want, got $got"; F=$((F+1)); fi
  }

  echo "miner-scope selftest"
  echo
  t  "the briefed directory is in scope"      "IN    r--work-lantern-roadz-sound-system" r--work-lantern-roadz-sound-system
  t  "a worktree of the briefed slug is in scope, despite the case difference"      "IN    R--work-lantern-roadz-sound-system--claude-worktrees" r--work-lantern-roadz-sound-system
  t  "a sibling repository sharing a stem is NEAR, not IN — the #141 case"      "NEAR  R--work-lantern-roadz-pb-firmware" r--work-lantern-roadz-sound-system
  t  "an unrelated repository is SKIP"      "SKIP  r--lodestar" r--work-lantern-roadz-sound-system
  t  "a second briefed slug brings its directory in"      "IN    r--arc" r--work-lantern-roadz-sound-system r--arc
  t  "nothing is silently omitted — every directory is on a line"      "SKIP  r--arc" r--work-lantern-roadz-sound-system
  te "a briefed slug matching nothing exits 1, not 0" 1 r--does-not-exist
  te "no arguments exits 2" 2
  te "a valid brief exits 0" 0 r--work-lantern-roadz-sound-system

  echo
  echo "$P passed, $F failed"
  [ "$F" = "0" ] || exit 1
  exit 0
fi

if [ "$#" -eq 0 ]; then
  echo "usage: tools/miner-scope.sh <briefed-slug> [<briefed-slug>...]" >&2
  echo "       a briefed slug is a directory name under $ROOT" >&2
  exit 2
fi

[ -d "$ROOT" ] || { echo "no transcript root: $ROOT" >&2; exit 1; }

lower() { printf '%s' "$1" | tr '[:upper:]' '[:lower:]'; }

# How many leading characters two slugs must share before a miss is worth a reader's attention.
# The slug is <drive>--<path>, so a handful of characters is the drive and means nothing; the
# #141 pair shared 22. Ten is comfortably above the noise and below the real case.
NEAR_CHARS="${NEAR_CHARS:-10}"

missing=""
for b in "$@"; do
  bl="$(lower "$b")"
  hit=0
  for d in "$ROOT"/*/; do
    [ -d "$d" ] || continue
    n="$(basename "$d")"; nl="$(lower "$n")"
    case "$nl" in
      "$bl"|"$bl"--*) hit=1 ;;
    esac
  done
  [ "$hit" = "1" ] || missing="$missing $b"
done

for d in "$ROOT"/*/; do
  [ -d "$d" ] || continue
  n="$(basename "$d")"; nl="$(lower "$n")"
  keep=0
  for b in "$@"; do
    bl="$(lower "$b")"
    case "$nl" in
      "$bl"|"$bl"--*) keep=1 ;;
    esac
  done
  if [ "$keep" = "1" ]; then
    echo "IN    $n"
    continue
  fi
  # A directory sharing a leading segment with a briefed slug is the case that caused #141.
  # It is reported differently because it is the one a reader has to actually consider.
  near=0
  for b in "$@"; do
    bl="$(lower "$b")"
    i=0
    while [ "$i" -lt "${#bl}" ] && [ "$i" -lt "${#nl}" ]; do
      [ "${bl:$i:1}" = "${nl:$i:1}" ] || break
      i=$((i + 1))
    done
    [ "$i" -ge "$NEAR_CHARS" ] && near=1
  done
  if [ "$near" = "1" ]; then
    echo "NEAR  $n   shares a stem with a briefed slug, not briefed"
  else
    echo "SKIP  $n   unrelated"
  fi
done

if [ -n "$missing" ]; then
  echo "briefed slug matched no directory:$missing" >&2
  exit 1
fi
exit 0
