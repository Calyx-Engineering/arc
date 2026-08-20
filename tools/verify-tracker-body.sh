#!/usr/bin/env bash
# verify-tracker-body.sh — catch a closing keyword that binds when it should not.
#
#   tools/verify-tracker-body.sh body <path-to-body.md>
#   tools/verify-tracker-body.sh binding <pr-number> <intent>     # intent: closes | refs
#   tools/verify-tracker-body.sh selftest
#
# GitHub's parser matches a closing keyword and an issue number and ignores everything
# around it, including the word "not". So a heading that says a PR does *not* close an issue
# closes it. `skills/issue-write` documents that trap in prose; this script is the check that
# derives from it.
#
# TWO CHECKS, TWO MOMENTS. Placement is decidable from the body text alone and must be
# checked BEFORE the write — a PostToolUse hook is too late, the wrong body is already in
# the tracker. Binding is only decidable after, from the API. Neither subsumes the other.
#
# REPORTS, NEVER BLOCKS. Same precedent as verify-hook.sh's declaration check. Exit 1 marks
# a finding for a human to read; nothing here denies a tool call.

set -u

KEYWORD_RE='\b(close[sd]?|closed|fix|fixes|fixed|resolve[sd]?)[[:space:]]+#[0-9]+'

usage() {
  cat >&2 <<'USAGE'
usage:
  verify-tracker-body.sh body <path-to-body.md>
  verify-tracker-body.sh binding <pr-number> <closes|refs>
  verify-tracker-body.sh selftest
USAGE
  exit 2
}

# ---- check 1 — placement --------------------------------------------------------
# A keyword-plus-number is allowed exactly once, on the last non-empty line. Anywhere else
# it is either a second binding nobody intended or a mention inside prose that will bind.
check_body() {
  local file="$1"
  [ -f "$file" ] || { echo "no such file: $file" >&2; exit 2; }

  local last_line_no hits count
  # The last non-empty line — trailing blank lines are normal in a written body and must not
  # shift where the keyword is allowed to sit.
  last_line_no="$(grep -n '[^[:space:]]' "$file" | tail -n1 | cut -d: -f1)"
  [ -n "$last_line_no" ] || last_line_no=0

  # `-o` counts MATCHES, not lines. `Closes #1 and closes #2` on one line is two bindings,
  # and a per-line count would report it as one and pass it.
  count="$(grep -oEi "$KEYWORD_RE" "$file" | grep -c . || true)"
  if [ "$count" -eq 0 ]; then
    echo "PASS  no closing keyword — this change closes nothing"
    return 0
  fi

  # Line-numbered form, for reporting only.
  hits="$(grep -nEi "$KEYWORD_RE" "$file" || true)"

  if [ "$count" -gt 1 ]; then
    echo "FAIL  $count closing keywords; exactly one is allowed, on the last line"
    printf '%s\n' "$hits" | sed 's/^/        /'
    return 1
  fi

  local hit_line
  hit_line="$(printf '%s' "$hits" | cut -d: -f1)"
  if [ "$hit_line" != "$last_line_no" ]; then
    echo "FAIL  closing keyword on line $hit_line, not the last line ($last_line_no)"
    printf '%s\n' "$hits" | sed 's/^/        /'
    echo "        A keyword anywhere but the last line still binds. Negation is not understood."
    return 1
  fi

  echo "PASS  one closing keyword, on the last line"
  return 0
}

# ---- check 2 — binding ----------------------------------------------------------
# Compare what bound against what was intended. The uncovered case is a populated
# closingIssuesReferences under a `Refs` intent: a binding that formed and should not have.
# A populated list reads as success everywhere else, which is why it was misread once already.
check_binding() {
  local pr="$1" intent="$2"
  command -v gh >/dev/null 2>&1 || { echo "gh not on PATH" >&2; exit 2; }

  # `gh --jq` is used rather than piping to jq or python, neither of which is guaranteed
  # present. gh ships its own jq engine.
  local base bound
  base="$(gh pr view "$pr" --json baseRefName --jq '.baseRefName' 2>/dev/null)" \
    || { echo "cannot read PR $pr" >&2; exit 2; }
  bound="$(gh pr view "$pr" --json closingIssuesReferences \
    --jq '[.closingIssuesReferences[].number] | join(",")' 2>/dev/null)"

  case "$intent" in
    refs)
      if [ -n "$bound" ]; then
        echo "FAIL  intent was Refs, but issues [$bound] are bound and will auto-close"
        echo "        A keyword somewhere in the body bound despite the intent. Run: body"
        return 1
      fi
      echo "PASS  intent Refs, nothing bound"
      ;;
    closes)
      if [ -n "$bound" ]; then
        echo "PASS  intent Closes, issues [$bound] bound"
      elif printf '%s' "$base" | grep -q '^arc/'; then
        echo "PASS  nothing bound, base is arc branch '$base' — defers to the arc PR"
      else
        echo "FAIL  intent Closes, but nothing bound and base '$base' is not an arc branch"
        return 1
      fi
      ;;
    *) usage ;;
  esac
  return 0
}

# ---- selftest -------------------------------------------------------------------
# Fixtures live beside the hook cases, same pass/fail shape.
selftest() {
  local dir passed=0 failed=0
  dir="$(dirname "$0")/tracker-cases/body"
  [ -d "$dir" ] || { echo "no case directory: $dir" >&2; exit 2; }

  for kind in pass fail; do
    [ -d "$dir/$kind" ] || continue
    for f in "$dir/$kind"/*.md; do
      [ -e "$f" ] || continue
      local out rc verdict
      out="$(check_body "$f" 2>&1)"; rc=$?
      [ "$rc" -eq 0 ] && verdict=pass || verdict=fail
      if [ "$verdict" = "$kind" ]; then
        printf '  PASS  %-5s %s\n' "$kind" "$(basename "$f")"
        passed=$((passed + 1))
      else
        printf '  FAIL  %-5s %s — got %s\n' "$kind" "$(basename "$f")" "$verdict"
        printf '%s\n' "$out" | sed 's/^/          /'
        failed=$((failed + 1))
      fi
    done
  done
  echo
  echo "$passed passed, $failed failed"
  [ "$failed" -eq 0 ] || return 1
}

case "${1:-}" in
  body)     [ $# -eq 2 ] || usage; check_body "$2" ;;
  binding)  [ $# -eq 3 ] || usage; check_binding "$2" "$3" ;;
  selftest) selftest ;;
  *)        usage ;;
esac
