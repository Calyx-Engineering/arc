#!/usr/bin/env bash
# verify-tracker-body.sh — catch a tracker write that promises the wrong thing.
#
#   tools/verify-tracker-body.sh body <path-to-body.md>
#   tools/verify-tracker-body.sh title <title> [path-to-body.md]
#   tools/verify-tracker-body.sh title-findings <title> [path-to-body.md]   # raw, for hooks
#   tools/verify-tracker-body.sh binding <pr-number> <intent>     # intent: closes | refs
#   tools/verify-tracker-body.sh selftest
#
# GitHub's parser matches a closing keyword and an issue number and ignores everything
# around it, including the word "not". So a heading that says a PR does *not* close an issue
# closes it. `skills/issue-write` documents that trap in prose; this script is the check that
# derives from it.
#
# A title makes the same kind of promise one step earlier — `Closes` asks whether merging
# ships the thing the issue asked for, the title asks whether merging ships the thing the
# title names. Both are decidable from text alone, so both live here.
#
# FOUR CHECKS, TWO MOMENTS. Placement and title are decidable from text alone and must be
# checked BEFORE the write — a PostToolUse hook is too late, the wrong body is already in
# the tracker. Binding is only decidable after, from the API. Neither subsumes the other.
#
# `body` carries two rules, not one: where the closing keyword sits, and whether a `Spawned`
# heading is the last section. Both are decidable from the file alone and both are the same
# caller's question — "is this body safe to write" — so they share one subcommand and one exit
# code. #135.
#
# `hooks/tracker-verify` shells out to `title-findings` rather than carrying its own copy of
# these rules, so a threshold is tuned in one place. It runs this as a subprocess, never
# sources it — `set -u` here must not leak into a guardrail that has to fail open.
#
# REPORTS, NEVER BLOCKS. Same precedent as verify-hook.sh's declaration check. Exit 1 marks
# a finding for a human to read; nothing here denies a tool call.

set -u

KEYWORD_RE='\b(close[sd]?|closed|fix|fixes|fixed|resolve[sd]?)[[:space:]]+#[0-9]+'

usage() {
  cat >&2 <<'USAGE'
usage:
  verify-tracker-body.sh body <path-to-body.md>
  verify-tracker-body.sh title <title> [path-to-body.md]
  verify-tracker-body.sh title-findings <title> [path-to-body.md]
  verify-tracker-body.sh binding <pr-number> <closes|refs>
  verify-tracker-body.sh selftest
USAGE
  exit 2
}

# ---- check 1 — placement --------------------------------------------------------
# A keyword-plus-number is allowed exactly once, on the last non-empty line. Anywhere else
# it is either a second binding nobody intended or a mention inside prose that will bind.
check_keyword_placement() {
  local file="$1"
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

# ---- check 1b — Spawned is the last section -------------------------------------
# `Spawned` holds the units of work this effort caused, and the arc-log's tree is built by
# reading it. A heading after it means a later section was appended past the spawn rows,
# which is where the next writer adds to the wrong one. #135.
#
# REPORTS THE MISPLACED HEADING, NEVER THE ROWS. Whether a row is a unit of work is the
# author's judgement and is not decidable from text; where the section sits is.
#
# Headings inside a fenced block are not headings — a `# comment` in a shell snippet would
# otherwise read as a section after `Spawned`. The fence state is tracked, so it does not.
check_spawned_last() {
  local file="$1" headings spawn_no after

  headings="$(awk '/^(```|~~~)/ { f = !f; next } f { next } /^#+[ 	]/ { print NR": "$0 }' "$file")"

  spawn_no="$(printf '%s
' "$headings" | grep -iE '^[0-9]+: *#+ .*spawned' | head -n1 | cut -d: -f1)"
  if [ -z "$spawn_no" ]; then
    echo "PASS  no Spawned heading — the spawn rows are in Related, or there are none"
    return 0
  fi

  after="$(printf '%s
' "$headings" | awk -F: -v n="$spawn_no" '$1 + 0 > n + 0')"
  if [ -n "$after" ]; then
    echo "FAIL  a Spawned heading on line $spawn_no is followed by another heading"
    printf '%s
' "$after" | sed 's/^/        /'
    echo "        Spawned is the last section. A heading after it puts later rows outside the spawn edges."
    return 1
  fi

  echo "PASS  the Spawned heading on line $spawn_no is the last section"
  return 0
}

# ---- body — both file-decidable rules, one exit code ----------------------------
# Every rule runs; the caller wants every finding in one read, not the first one.
check_body() {
  local file="$1" rc=0
  [ -f "$file" ] || { echo "no such file: $file" >&2; exit 2; }
  check_keyword_placement "$file" || rc=1
  check_spawned_last "$file" || rc=1
  return "$rc"
}

# ---- check 2 — the title --------------------------------------------------------
# A title is a promise about what merging delivers, and it breaks in two directions: it
# claims more than merges, or it explains instead of naming. Judging whether the scope is
# genuinely one unit is skills/decompose's; these are the mechanical signals a human skims
# past. Thresholds are set from this repo's own tracker, not guessed — see the dev-log for
# #32.
#
# Prints one finding per line. No findings is a clean title. Never exits non-zero; the
# caller decides what a finding means.
title_findings() {
  local title="$1" body="${2:-}" name words commas type multi=0

  # `arc:` and `workstream:` are containers, not units of work. Their children are the
  # deliverables; the title names a boundary and holds an ordered list. Every check below
  # asks "does merging this ship the thing the title names", and nothing merges a container
  # — so the checks are category errors here, not lenient exceptions. #194.
  case "$title" in
    arc:*|workstream:*) return 0 ;;
  esac

  # The type prefix and a trailing mechanism or issue tag are bookkeeping, not part of the
  # name, and a free-standing dash joins two halves of one name. Strip all three before
  # counting, or every title spends words on punctuation.
  #
  # Only `(mNN)` and `(#NN)` are stripped, not any trailing parenthetical — `feat: the
  # relief valve (three thresholds)` names its deliverable inside the brackets.
  name="$(printf '%s' "$title" \
    | sed -e 's/^[A-Za-z][A-Za-z]*\(([^)]*)\)\{0,1\}!\{0,1\}: *//' \
          -e 's/ *([m#][0-9][0-9]*) *$//' \
          -e 's/ [^[:alnum:]] / /g')"
  words="$(printf '%s' "$name" | wc -w | tr -d ' ')"
  commas="$(printf '%s' "$name" | tr -cd ',' | wc -c | tr -d ' ')"

  # Roughly eight words is the guidance in skills/issue-write. This reports at twelve so it
  # names only what nobody would defend — at ten it flagged three of this repo's open titles
  # that were doing their job. Judgement lives in the skill.
  [ "$words" -gt 12 ] \
    && echo "the title is $words words. Past a dozen it is summarising the body rather than naming the deliverable."

  # Word count misses the worst real case, because a list of artifacts costs one word per
  # comma: six file names came to eleven words and read as a table inlined into a title.
  # Three separators is the signal — a serial list inside a single name needs two at most.
  [ "$commas" -ge 3 ] \
    && echo "the title lists $((commas + 1)) items. Naming the affected artifacts in a title is the body's table, inlined."

  # A clause after the deliverable is body material: the mechanism, the consequence, the
  # reason it matters. Each of these joined an already-complete title to its explanation.
  #
  # `which` and `without` also read as prepositions inside a deliverable's own name —
  # "publish without a milestone" is the thing being built. They count only after a comma,
  # where they can only be starting a clause. The rest subordinate wherever they appear.
  printf '%s' "$name" | grep -qiE '[ ,](so|because|until|while) |, *(which|without) ' \
    && echo "the title carries a clause after the deliverable. The explanation belongs in the body."

  # Two deliverables in one title means the second is the one that quietly does not get
  # done. A serial list inside a single name reads identically to a regex — "X, Y, and Z"
  # against "do X, and do Y" — so the second comma is what tells them apart, and the length
  # gate keeps a short name out of the check entirely.
  if [ "$words" -gt 6 ]; then
    printf '%s' "$name" | grep -qiE ' (and|plus) .* (and|plus) | as well as ' && multi=1
    [ "$commas" -lt 2 ] && printf '%s' "$name" | grep -qiE ', and ' && multi=1
    [ "$multi" -eq 1 ] \
      && echo "the title names more than one deliverable. If merging it leaves part undone, it is more than one issue."
  fi

  # An issue whose output is a decision or a decomposition takes `scope:`. Under `feat:` it
  # inherits a capability-sized title, and every child it spawns then reads as part of an
  # unfinished promise rather than a finished piece of work. The body is the only place that
  # intent is visible at write time, since the children do not exist yet.
  if [ -n "$body" ]; then
    # A path that does not resolve would otherwise skip this check silently, which reads
    # as a pass. Say so on stderr — findings go to stdout, so this cannot be mistaken for one.
    if [ ! -f "$body" ]; then
      echo "note: no such body file '$body' — the scope-type check did not run" >&2
    else
      type="$(printf '%s' "$title" | grep -oiE '^(feat|fix)(\([^)]*\))?!?:')"
      if [ -n "$type" ] && grep -qiE 'decompos' "$body"; then
        echo "the title is \`$type\` and the body describes a decomposition. \`scope:\` is the type whose deliverable is the decision, not the capability it decomposes."
      fi
    fi
  fi
  return 0
}

check_title() {
  local findings
  findings="$(title_findings "$@")"
  if [ -z "$findings" ]; then
    echo "PASS  the title names one deliverable, at the size merging delivers it"
    return 0
  fi
  echo "FAIL  the title promises something other than what merging delivers"
  printf '%s\n' "$findings" | sed 's/^/        - /'
  return 1
}

# ---- check 3 — binding ----------------------------------------------------------
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
#
# A title case is a `.txt` whose first line is the title. Anything after it is the body the
# scope-type check reads — omit it and that check has nothing to run on.
selftest() {
  local base passed=0 failed=0 out rc verdict f kind
  base="$(dirname "$0")/tracker-cases"
  [ -d "$base/body" ] || { echo "no case directory: $base/body" >&2; exit 2; }

  for kind in pass fail; do
    [ -d "$base/body/$kind" ] || continue
    for f in "$base/body/$kind"/*.md; do
      [ -e "$f" ] || continue
      out="$(check_body "$f" 2>&1)"; rc=$?
      [ "$rc" -eq 0 ] && verdict=pass || verdict=fail
      if [ "$verdict" = "$kind" ]; then
        printf '  PASS  body  %-5s %s\n' "$kind" "$(basename "$f")"
        passed=$((passed + 1))
      else
        printf '  FAIL  body  %-5s %s — got %s\n' "$kind" "$(basename "$f")" "$verdict"
        printf '%s\n' "$out" | sed 's/^/          /'
        failed=$((failed + 1))
      fi
    done
  done

  local tmp title
  tmp="$(mktemp)"
  for kind in pass fail; do
    [ -d "$base/title/$kind" ] || continue
    for f in "$base/title/$kind"/*.txt; do
      [ -e "$f" ] || continue
      # Strip a trailing CR. `.gitattributes` pins these to LF, but a fixture that arrived
      # any other way would otherwise carry a carriage return into every word count.
      title="$(head -n1 "$f" | tr -d '\r')"
      tail -n +2 "$f" > "$tmp"
      out="$(check_title "$title" "$tmp" 2>&1)"; rc=$?
      [ "$rc" -eq 0 ] && verdict=pass || verdict=fail
      if [ "$verdict" = "$kind" ]; then
        printf '  PASS  title %-5s %s\n' "$kind" "$(basename "$f")"
        passed=$((passed + 1))
      else
        printf '  FAIL  title %-5s %s — got %s\n' "$kind" "$(basename "$f")" "$verdict"
        printf '%s\n' "$out" | sed 's/^/          /'
        failed=$((failed + 1))
      fi
    done
  done
  rm -f "$tmp"

  echo
  echo "$passed passed, $failed failed"
  [ "$failed" -eq 0 ] || return 1
}

case "${1:-}" in
  body)     [ $# -eq 2 ] || usage; check_body "$2" ;;
  title)    [ $# -ge 2 ] && [ $# -le 3 ] || usage; check_title "$2" "${3:-}" ;;
  # Raw findings, one per line, exit 0 always. `hooks/tracker-verify` reads this so the
  # rules have one home; a hook must never inherit a non-zero exit from a helper.
  title-findings) [ $# -ge 2 ] && [ $# -le 3 ] || usage; title_findings "$2" "${3:-}" ;;  binding)  [ $# -eq 3 ] || usage; check_binding "$2" "$3" ;;
  selftest) selftest ;;
  *)        usage ;;
esac
