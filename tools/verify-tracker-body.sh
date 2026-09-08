#!/usr/bin/env bash
# verify-tracker-body.sh — catch a tracker write that promises the wrong thing.
#
#   tools/verify-tracker-body.sh body <path-to-body.md>
#   tools/verify-tracker-body.sh title <title> [path-to-body.md]
#   tools/verify-tracker-body.sh title-findings <title> [path-to-body.md]   # raw, for hooks
#   tools/verify-tracker-body.sh binding <pr-number> <intent>     # intent: closes | refs
#   tools/verify-tracker-body.sh live-bind <merged-pr> <issue>    # live, mutates and restores
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
  verify-tracker-body.sh live-bind <merged-pr-number> <issue-number>
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

# ---- check 1b — the closing section is last -------------------------------------
# The spawn edges are the last thing in a body: `skills/issue-write` puts them in `Related`,
# which is the last section, and older bodies carry a `Spawned` section instead. Either way a
# heading after that section means later rows were appended past the spawn edges, where the
# next writer adds to the wrong one. #135.
#
# REPORTS THE MISPLACED HEADING, NEVER THE ROWS. Whether a row is a unit of work is the
# author's judgement and is not decidable from text; where the section sits is.
#
# THE TITLE MUST BE THE WHOLE HEADING. `### Spawned versus related` and `## Related — one
# table, four kinds` are prose headings about the sections, not the sections, and a substring
# match reports them. Bold and backticks are stripped; nothing else is allowed after the word.
#
# Headings inside a fenced block are not headings — a `# comment` in a shell snippet would
# otherwise read as a section after the spawn rows. The fence state is tracked, so it does not.
check_spawned_last() {
  local file="$1" headings terminal_no terminal_txt after

  headings="$(awk '/^(```|~~~)/ { f = !f; next } f { next } /^#+[ 	]/ { print NR": "$0 }' "$file")"

  # `[ 	]` after the hashes here too — the awk pass accepts a tab and this must not disagree
  # with it, or a tab-indented heading is found by one and missed by the other.
  local terminal_re='^[0-9]+:[ 	]*#+[ 	]+[*`]*(Spawned|Related)[*`]*[ 	]*$'
  # No `-n` on the grep: the stream already carries the file's line number as field 1, and
  # grep's own index would shadow it.
  terminal_no="$(printf '%s
' "$headings" | grep -iE "$terminal_re" | head -n1 | cut -d: -f1)"
  if [ -z "$terminal_no" ]; then
    echo "PASS  no Spawned or Related section heading — nothing to place"
    return 0
  fi

  terminal_txt="$(printf '%s
' "$headings" | awk -F': ' -v n="$terminal_no" '$1 + 0 == n + 0 { print $2 }')"

  after="$(printf '%s
' "$headings" | awk -F: -v n="$terminal_no" '$1 + 0 > n + 0')"
  if [ -n "$after" ]; then
    echo "FAIL  '$terminal_txt' on line $terminal_no is followed by another heading"
    printf '%s
' "$after" | sed 's/^/        /'
    echo "        The spawn edges are the last thing in the body. A heading after them puts later rows outside."
    return 1
  fi

  echo "PASS  '$terminal_txt' on line $terminal_no is the last section"
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

# ---- check 4 — the merged-PR bind, live -----------------------------------------
# `tools/tracker-cases/binding/merged-pr-keyword-bind.md` is this check's case. It cannot be a
# text fixture: the claim is about what GitHub does, so the only honest test writes to the API
# and reads it back. #193.
#
# WHAT IT ASSERTS. A `Closes #NN` line appended to an ALREADY-MERGED PR binds, provided the
# base was the repository's default branch. Removing it again unbinds. It does NOT close the
# issue — the merge event that would have closed it has already fired.
#
# THE READ-BACK IS NOT INSTANT. Measured 2026-09-07 on PR #215: the read immediately after the
# edit returned an empty array and the read seconds later returned the binding. A single read
# is a false negative, which is #155's failure with an exit code on it. Hence the poll.
#
# EVERY READ THAT FEEDS A WRITE IS CHECKED. This check overwrites a real merged PR's body and
# puts it back, so an unchecked `gh pr view` that failed would hand the restore an empty file
# and destroy the body it was protecting. That is #87's shape — an input never checked to have
# landed — and a tool added in the same batch that fixed #87 does not get to reintroduce it.
#
# A FAILED READ IS NEVER A PASS. A `gh` call that errors returns an empty string, which reads
# identically to "the query ran and found nothing". Where that difference carries the
# assertion — the `userLinkedOnly` probe — the exit status is captured separately.
#
# IT REFUSES RATHER THAN CLOBBER: the PR must be merged, its base must be the default branch,
# and its body must carry no closing keyword already. The restore also runs from a trap, so an
# interrupt between the write and the restore still puts the body back.
#
# NOT IN verify-all.sh. It needs the network and it writes to the tracker. Run it deliberately.

LIVE_PR=""
LIVE_ORIG=""
LIVE_TMP=""

# Strip carriage returns and trailing blank lines. GitHub normalises both when it stores a
# body, so a restore that landed correctly still fails a byte-for-byte comparison.
live_norm() {
  sed 's/\r$//' "$1" \
    | awk '{ l[NR] = $0 } END { last = 0
             for (i = 1; i <= NR; i++) if (l[i] ~ /[^ \t]/) last = i
             for (i = 1; i <= last; i++) print l[i] }'
}

live_restore() {
  if [ -n "$LIVE_PR" ] && [ -n "$LIVE_ORIG" ] && [ -s "$LIVE_ORIG" ]; then
    echo "restoring PR $LIVE_PR's body" >&2
    gh pr edit "$LIVE_PR" --body-file "$LIVE_ORIG" >/dev/null 2>&1 \
      || echo "RESTORE FAILED — PR $LIVE_PR still carries the probe keyword. Body kept at: $LIVE_ORIG" >&2
  fi
  [ -n "$LIVE_TMP" ] && rm -f "$LIVE_TMP"
  return 0
}

check_live_bind() {
  local pr="$1" issue="$2" rc=0
  command -v gh >/dev/null 2>&1 || { echo "gh not on PATH" >&2; exit 2; }

  local state base default bound hand hand_rc istate i
  state="$(gh pr view "$pr" --json state --jq .state)" \
    || { echo "cannot read PR $pr" >&2; exit 2; }
  base="$(gh pr view "$pr" --json baseRefName --jq .baseRefName)" \
    || { echo "cannot read PR $pr's base" >&2; exit 2; }
  default="$(gh repo view --json defaultBranchRef --jq .defaultBranchRef.name)" \
    || { echo "cannot read the repository's default branch" >&2; exit 2; }

  # Empty compares equal to empty, so a pair of silent failures would read as a match.
  [ -n "$base" ] && [ -n "$default" ] \
    || { echo "refusing: base '$base' or default branch '$default' came back empty" >&2; exit 2; }
  [ "$state" = "MERGED" ] \
    || { echo "refusing: PR $pr is $state, the case needs a merged one" >&2; exit 2; }
  [ "$base" = "$default" ] \
    || { echo "refusing: PR $pr's base '$base' is not the default branch '$default'" >&2; exit 2; }

  local orig tmp back
  orig="$(mktemp)"; tmp="$(mktemp)"
  if ! gh pr view "$pr" --json body --jq .body > "$orig" || [ ! -s "$orig" ]; then
    rm -f "$orig" "$tmp"
    echo "refusing: could not read PR $pr's body, or it came back empty — nothing to restore from" >&2
    exit 2
  fi
  if grep -qEi "$KEYWORD_RE" "$orig"; then
    rm -f "$orig" "$tmp"
    echo "refusing: PR $pr already carries a closing keyword — restoring it is not this check's risk to take" >&2
    exit 2
  fi

  cp "$orig" "$tmp" || { rm -f "$orig" "$tmp"; echo "cannot stage the edit" >&2; exit 2; }
  printf '\n\nCloses #%s\n' "$issue" >> "$tmp"

  # Armed BEFORE the write, so an interrupt during it still restores.
  LIVE_PR="$pr"; LIVE_ORIG="$orig"; LIVE_TMP="$tmp"
  trap live_restore EXIT INT TERM

  # The guarded write-back the skill teaches: the edit must have changed the file, or `gh`
  # writes the original back and reports success. #87.
  if ! { ! cmp -s "$orig" "$tmp" && gh pr edit "$pr" --body-file "$tmp" >/dev/null; }; then
    echo "could not write the keyword to PR $pr" >&2
    exit 2
  fi

  # Poll, do not read once. See the note above.
  bound=""
  for i in 1 2 3 4 5 6 7 8 9 10; do
    bound="$(gh pr view "$pr" --json closingIssuesReferences \
      --jq '[.closingIssuesReferences[].number] | join(",")')" || bound=""
    case ",$bound," in *",$issue,"*) break ;; esac
    sleep 3
  done

  case ",$bound," in
    *",$issue,"*) echo "PASS  a keyword added after the merge bound #$issue on merged PR $pr" ;;
    *) echo "FAIL  keyword added to merged PR $pr, nothing bound after 30s (got [$bound])"; rc=1 ;;
  esac

  # A hand-attached link populates the same field, so this probe is what proves the keyword did
  # it. A failed query must not fall through to the pass branch.
  local owner name
  owner="$(gh repo view --json owner --jq .owner.login)" || owner=""
  name="$(gh repo view --json name --jq .name)" || name=""
  if [ -z "$owner" ] || [ -z "$name" ]; then
    echo "FAIL  could not resolve owner/name, so the keyword-versus-hand-attached probe did not run"
    rc=1
  else
    hand="$(gh api graphql -f query="{repository(owner:\"$owner\",name:\"$name\"){pullRequest(number:$pr){closingIssuesReferences(first:10,userLinkedOnly:true){nodes{number}}}}}" \
      --jq '[.data.repository.pullRequest.closingIssuesReferences.nodes[].number] | join(",")')"
    hand_rc=$?
    if [ "$hand_rc" -ne 0 ]; then
      echo "FAIL  the userLinkedOnly query failed — an empty result here is not evidence"
      rc=1
    else
      case ",$hand," in
        *",$issue,"*) echo "FAIL  #$issue is hand-attached, so this proves nothing about the keyword"; rc=1 ;;
        *) echo "PASS  userLinkedOnly is [$hand] — the link came from the keyword, not the UI" ;;
      esac
    fi
  fi

  # The link forms; the close does not. The merge event that closes an issue has already fired.
  istate="$(gh issue view "$issue" --json state --jq .state)" || istate=""
  case "$istate" in
    OPEN) echo "PASS  issue #$issue is still OPEN — the bind restores the link, never the closure" ;;
    "")   echo "FAIL  could not read issue #$issue's state"; rc=1 ;;
    *)    echo "FAIL  issue #$issue is $istate; the recorded behaviour is that it stays open"; rc=1 ;;
  esac

  # Restore, and assert on the BODY. Asserting on the reference alone would break out of the
  # poll on the first read that had not caught up, which is the one-read false negative this
  # check exists to document.
  #
  # NOT byte for byte. GitHub normalises a body it is given — line endings, and trailing blank
  # lines — so a body written back from an exact copy of what was read does not read back
  # identical. Measured 2026-09-07 on PR #215: the restore landed, the keyword was gone, and a
  # `cmp` still failed. Comparing normalised text is the assertion that means what it says.
  trap - EXIT INT TERM
  back="$(mktemp)"
  if ! gh pr edit "$pr" --body-file "$orig" >/dev/null; then
    echo "FAIL  restoring PR $pr's body failed — it still carries the probe keyword. Original: $orig"
    rm -f "$tmp" "$back"
    return 1
  fi
  if ! gh pr view "$pr" --json body --jq .body > "$back" || [ ! -s "$back" ]; then
    echo "FAIL  could not read PR $pr's body back after restoring it. Original: $orig"
    rm -f "$tmp" "$back"
    return 1
  fi
  if grep -qE "Closes #$issue\b" "$back"; then
    echo "FAIL  PR $pr still carries 'Closes #$issue' after the restore. Original: $orig"
    rc=1
  elif ! cmp -s <(live_norm "$orig") <(live_norm "$back"); then
    echo "FAIL  PR $pr's body does not read back as it was, beyond line endings and trailing blanks."
    echo "        Original: $orig"
    rc=1
  else
    echo "PASS  PR $pr's body reads back as it was, and the probe keyword is gone"
  fi

  # Only now the reference, and failing only if it is STILL bound at the end of the window.
  for i in 1 2 3 4 5 6 7 8 9 10; do
    bound="$(gh pr view "$pr" --json closingIssuesReferences \
      --jq '[.closingIssuesReferences[].number] | join(",")')" || bound="$issue"
    case ",$bound," in *",$issue,"*) sleep 3 ;; *) break ;; esac
  done
  case ",$bound," in
    *",$issue,"*) echo "FAIL  #$issue is still bound to PR $pr after 30s — check it by hand"; rc=1 ;;
    *) echo "PASS  #$issue unbound" ;;
  esac

  rm -f "$orig" "$tmp" "$back"
  return "$rc"
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

  # Say what this run did NOT cover. The binding cases are claims about GitHub's behaviour, so
  # the only honest test writes to the API — a silent omission here would read as coverage.
  local live
  live="$(find "$base/binding" -name '*.md' 2>/dev/null | grep -c . || true)"
  [ "${live:-0}" -gt 0 ]     && echo "$live live case not run — it writes to the tracker: verify-tracker-body.sh live-bind <merged-pr> <issue>"

  [ "$failed" -eq 0 ] || return 1
}

case "${1:-}" in
  body)     [ $# -eq 2 ] || usage; check_body "$2" ;;
  title)    [ $# -ge 2 ] && [ $# -le 3 ] || usage; check_title "$2" "${3:-}" ;;
  # Raw findings, one per line, exit 0 always. `hooks/tracker-verify` reads this so the
  # rules have one home; a hook must never inherit a non-zero exit from a helper.
  title-findings) [ $# -ge 2 ] && [ $# -le 3 ] || usage; title_findings "$2" "${3:-}" ;;  binding)  [ $# -eq 3 ] || usage; check_binding "$2" "$3" ;;
  live-bind) [ $# -eq 3 ] || usage; check_live_bind "$2" "$3" ;;
  selftest) selftest ;;
  *)        usage ;;
esac
