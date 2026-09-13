#!/usr/bin/env bash
# verify-skill-length.sh — report every skills/*/SKILL.md over 500 lines.
#
#   tools/verify-skill-length.sh              this repository's skills
#   tools/verify-skill-length.sh selftest     fixture cases
#
# WHY. Nothing measured skill length. Twelve of thirteen skills exceeded the old limit for
# weeks unnoticed — #276.
#
# REPORTS, NEVER FAILS. Exit 0 always, hits or none. Twelve of thirteen skills were already
# over the limit the day this shipped, and a gate that fails on a hit would turn `verify-all.sh`
# red over pre-existing length rather than a regression this run introduced. The list is the
# point; a human decides which skill to split and when. Precedent: every verifier here reports
# rather than rewrites, and this one goes a step further because the state it measures already
# has widespread findings — a hit here names a candidate for splitting, not a defect to fix
# before the run can proceed.
#
# THE LAST LINE SAYS "N passed". `tests/verify-all.sh`'s run_gate only echoes a gate's own
# summary line when it matches `passed`/`copied`/`are current` — every other live gate here
# ends with "$PASSED passed, $FAILED failed", which is why its finding survives into a plain
# `verify-all.sh` run. A count-only line here would exit 0 same as everywhere else, but sit
# silent inside that summarizer, and a gate whose entire purpose is surfacing a count that
# nobody was tracking must not go quiet in the one place it is meant to be read.
#
# `wc -l` COUNTS NEWLINES, NOT LINES — a file whose last line has no trailing `\n` is
# undercounted by one, which would misjudge the exact boundary this script polices. `awk` counts
# every record it reads regardless of a trailing newline, so it is used instead.

set -u

HERE="$(cd "$(dirname "$0")" && pwd)"
LIMIT=500

# ---- the report ------------------------------------------------------------------
# $1  repository root — the directory holding skills/
report() {
  local root="$1" f n total=0 hits=0

  for f in "$root"/skills/*/SKILL.md; do
    [ -f "$f" ] || continue
    total=$((total + 1))
    n="$(awk 'END { print NR }' "$f")"
    if [ "$n" -gt "$LIMIT" ]; then
      printf '  %5d  %s\n' "$n" "${f#"$root"/}"
      hits=$((hits + 1))
    fi
  done

  echo "$((total - hits)) passed, $hits over $LIMIT lines"
}

# ---- selftest ----------------------------------------------------------------------
# Fixtures rather than this repository's own skills/, so the case is not at the mercy of
# whichever skill next crosses or drops below the line.
selftest() {
  local fixtures under_lines over_lines
  fixtures="$(mktemp -d)"
  [ -n "$fixtures" ] && [ -d "$fixtures" ] || { echo "mktemp -d returned nothing" >&2; return 2; }
  trap 'rm -rf "$fixtures"' RETURN

  mkdir -p "$fixtures/skills/under" "$fixtures/skills/over" "$fixtures/skills/exact"

  under_lines=10
  over_lines=501
  seq 1 "$under_lines" > "$fixtures/skills/under/SKILL.md"
  seq 1 "$over_lines" > "$fixtures/skills/over/SKILL.md"
  seq 1 "$LIMIT" > "$fixtures/skills/exact/SKILL.md"

  local out status=0
  out="$(report "$fixtures")"

  if ! printf '%s' "$out" | grep -qF "2 passed, 1 over $LIMIT lines"; then
    echo "  FAIL  count — wanted 2 passed, 1 over, got: $out"; status=1
  else
    echo "  ok    count — exactly one skill over the limit"
  fi

  if printf '%s' "$out" | grep -qF "over/SKILL.md"; then
    echo "  ok    names the skill that is over"
  else
    echo "  FAIL  names the skill that is over — got: $out"; status=1
  fi

  if printf '%s' "$out" | grep -qF "under/SKILL.md"; then
    echo "  FAIL  a skill under the limit must not be reported — got: $out"; status=1
  else
    echo "  ok    a skill under the limit is not reported"
  fi

  if printf '%s' "$out" | grep -qF "exact/SKILL.md"; then
    echo "  FAIL  exactly $LIMIT lines is not over the limit — got: $out"; status=1
  else
    echo "  ok    exactly $LIMIT lines is not reported"
  fi

  # An empty skills/ directory is a report of zero, not a crash.
  local empty_out
  mkdir -p "$fixtures/none/skills"
  empty_out="$(report "$fixtures/none")"
  if [ "$empty_out" = "0 passed, 0 over $LIMIT lines" ]; then
    echo "  ok    no skills at all — reports zero, not a crash"
  else
    echo "  FAIL  no skills at all — got: $empty_out"; status=1
  fi

  # A file whose last line has no trailing newline must still be counted fully — wc -l would
  # undercount it by one and misjudge the exact boundary this script polices.
  mkdir -p "$fixtures/skills/notrail"
  printf '%s' "$(seq 1 501)" > "$fixtures/skills/notrail/SKILL.md"
  local notrail_out
  notrail_out="$(report "$fixtures")"
  if printf '%s' "$notrail_out" | grep -qF "notrail/SKILL.md"; then
    echo "  ok    a 501-line file with no trailing newline is still counted as over"
  else
    echo "  FAIL  a 501-line file with no trailing newline was not flagged — got: $notrail_out"; status=1
  fi

  return "$status"
}

case "${1:-}" in
  selftest)
    [ "$#" -eq 1 ] || { echo "selftest takes no arguments" >&2; exit 2; }
    if selftest; then
      echo
      echo "skill length selftest — all cases passed"
      exit 0
    fi
    echo
    echo "skill length selftest — cases failed"
    exit 1
    ;;
  '')
    report "$(cd "$HERE/.." && pwd)"
    exit 0
    ;;
  *)
    echo "usage: tools/verify-skill-length.sh [selftest]" >&2
    exit 2
    ;;
esac
