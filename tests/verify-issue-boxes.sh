#!/usr/bin/env bash
# verify-issue-boxes.sh — is every `Required` box dispositioned before the PR is ready?
#
#   tests/verify-issue-boxes.sh <issue-number>     the issue's boxes, against its PRs' bodies
#   tests/verify-issue-boxes.sh --pr <pr-number>   every issue that PR is answerable for
#   tests/verify-issue-boxes.sh selftest
#
# WHY. #140 put a read-back before the PR and ruled a script out — "prose correctness is not
# mechanically checkable. This is judgement, so it is not a gate script." That is right about
# the prose and too broad. Whether every `- [ ]` in the issue body is still unticked is a `gh`
# query and a count, and it has failed in both directions: #17 shipped missing two of five
# requirements, and #194 reached its PR with twelve unticked boxes that were all actually done.
#
# WHAT IT ANSWERS, and the line it will not cross:
#
#   mechanical   is each box ticked, or NAMED in the PR body with words of its own beside it
#   judgement    is the work right, and is the reason a real reason — #140's read-back, still
#
# So a clean run is not a claim that the unit is complete. It is a claim that the record says
# what happened to every box, which is the half that was silent.
#
# WHAT COUNTS AS RESOLVED
#
#   ticked                  `- [x]`
#   named, with a reason    THE BOX'S FIRST EIGHT WORDS, quoted in a PR body on an entry that
#                           also carries at least three words the box itself does not. So:
#
#                             - Selftest cases for every shape — moved to #250
#
#                           `Box 4: not done` does NOT satisfy it, and nor does the box pasted
#                           back verbatim: a checklist copied into a PR body states nothing.
#                           Quoting the box is what makes the disposition matchable to it, and
#                           the failure message and skills/issue-write both say so, because a
#                           rule an author cannot read is a rule that reports honest work
#
# The moved-box case falls out of the same rule rather than needing one of its own: #140 allows
# moving a box this unit cannot meet, and a row naming where it went is a row with words of its
# own. Which is also why the reason test is a word count and not a vocabulary — "declined",
# "moved", "deferred" and "blocked by" are all the same shape, and a keyword list would be a
# fourth vocabulary to keep in step with three documents.
#
# IT READS THE LIVE ISSUE, NEVER A LOCAL COPY. A checklist is edited on GitHub as often as in a
# body pasted from a file, and a stale local copy is exactly the artifact that would let this
# pass while the tracker still shows unticked boxes.
#
# REPORTS, NEVER BLOCKS. Same precedent as every other verifier here.
#
#   0  clean — no unticked box, or every one of them accounted for
#   1  a finding — an unticked box the PR bodies do not account for
#   2  the read could not be made, or the arguments were wrong. NEVER 1: "the record does not
#      account for this box" and "I could not tell" are different answers, and only one is a
#      defect. Same distinction tests/verify-linked-branch.sh draws, for the same reason
#
# THE FIXTURE BACKEND. `ARC_BOXES_FIXTURES=<dir>` swaps the `gh` reads for files of the same
# shape, so the selftest exercises this file end to end — argument parsing, exit codes and all
# — with no network and no live issue. The precedent is `hooks/tracker-verify`'s `arc_test_*`
# keys: a verifier whose only path needs GitHub is a verifier nobody runs the day it matters.
#
#   issue-<N>.md         the issue body. ABSENT MEANS THE ISSUE DOES NOT EXIST
#   issue-<N>.prs        PRs GitHub already binds to it, one number per line. Absent means none
#   issue-<N>.crossrefs  PRs that only mention it — candidates, admitted by the same test the
#                        live path applies. This is where the arc case lives
#   pr-<N>.md            the PR body. ABSENT MEANS THE PR DOES NOT EXIST
#   pr-<N>.branch        its head branch name
#   pr-<N>.issues        issues GitHub already binds it to, one per line. Absent means none

set -u

SELF="${BASH_SOURCE[0]}"

usage() {
  cat >&2 <<'USAGE'
usage:
  tests/verify-issue-boxes.sh <issue-number>
  tests/verify-issue-boxes.sh --pr <pr-number>
  tests/verify-issue-boxes.sh selftest
USAGE
}

TMP=""
cleanup() { [ -n "$TMP" ] && rm -rf "$TMP"; return 0; }
trap cleanup EXIT

# ---- text ------------------------------------------------------------------------
# Normalisation is what makes "named in the PR body" mechanical. A box is written once in the
# issue and quoted once in the PR, and between the two it picks up a different link target, a
# bold run, a wrapped line — none of which changes which box it is. Markdown link text survives
# and the URL does not, because the words are the identity and the target is not.
norm() {
  printf '%s' "$1" \
    | sed -E -e 's/\[([^]]*)\]\([^)]*\)/\1/g' -e 's/[`*_~]+//g' \
    | tr 'A-Z' 'a-z' \
    | sed -E -e 's/[^a-z0-9]+/ /g' -e 's/^ +//' -e 's/ +$//'
}

# The first eight words identify the box. NOT the whole text: a box wraps over three lines in
# the issue and is quoted in one line in the PR, and demanding the tail back is demanding a
# transcription rather than a disposition.
KEY_WORDS=8
key_of() {
  printf '%s' "$1" | tr ' ' '\n' | grep -v '^$' | head -n "$KEY_WORDS" | tr '\n' ' ' \
    | sed -E 's/ +$//'
}

# ONE SCANNER FOR BOTH COUNTS, so the total and the open list can never disagree about what a
# box is. `mode=open` prints one unticked box per line with its continuation lines folded in;
# `mode=total` prints how many checkboxes of either state there are. A `- [x]` closes the box
# before it and contributes nothing; so does a blank line or a new list item.
#
# FENCED BLOCKS ARE NOT CHECKLISTS. An issue that shows a checklist — a body template, an
# example of the shape this tool accepts, a quoted `Required` section from somewhere else — is
# not an issue that HAS one. Counting those reports a finding for a box that does not exist and
# cannot be ticked, and a check that fires on a correctly dispositioned PR is one somebody turns
# off. (Inline code spans need no rule: `- [ ]` inside backticks on one line is not at the start
# of that line, so it was never a box. #199's own first requirement is written that way.)
#
# AN UNBALANCED FENCE TURNS THE RULE OFF, and this is the important half. A single toggle on
# either marker made an unclosed ``` — or a ~~~ line inside a backtick block — swallow every box
# after it, and the run then printed `0 boxes, all ticked`. That is a UNIVERSAL SILENT PASS, and
# the first draft of this repair shipped it while fixing the over-count. So the markers are
# matched to each other, and the whole body is read twice: if a fence is still open at the end,
# the body's fencing cannot be trusted and every box is counted. Over-reporting is a finding a
# human can dismiss in a second; under-reporting is the silence this check exists to end.
box_scan() {
  awk -v mode="$1" '
    function marker_of(l) {
      if (l ~ /^[ \t]*```/) return "```"
      if (l ~ /^[ \t]*~~~/) return "~~~"
      return ""
    }
    function flush() { if (cur != "") { if (mode == "open") print cur; cur = "" } }
    { line[NR] = $0 }
    END {
      # Pass A — are the fences balanced? A closing marker must match the one that opened.
      open_marker = ""
      for (i = 1; i <= NR; i++) {
        fm = marker_of(line[i])
        if (fm == "")                      continue
        if (open_marker == "")             { open_marker = fm; continue }
        if (fm == open_marker)             open_marker = ""
      }
      honour = (open_marker == "")

      # Pass B — the scan.
      open_marker = ""
      for (i = 1; i <= NR; i++) {
        l = line[i]
        fm = marker_of(l)
        if (honour && fm != "") {
          if (open_marker == "")      { flush(); open_marker = fm; continue }
          if (fm == open_marker)      { open_marker = ""; continue }
          continue
        }
        if (honour && open_marker != "") continue

        if (l ~ /^[ \t]*[-*+] \[[ xX]\]/) total++
        if (l ~ /^[ \t]*[-*+] \[ \]/) {
          flush(); sub(/^[ \t]*[-*+] \[ \][ \t]*/, "", l); cur = l; continue
        }
        if (l ~ /^[ \t]*[-*+] \[[xX]\]/) { flush(); continue }
        if (cur != "") {
          if (l ~ /^[ \t]+[^ \t]/ && l !~ /^[ \t]*[-*+] / && l !~ /^[ \t]*[0-9]+\. /) {
            sub(/^[ \t]+/, " ", l); cur = cur l; continue
          }
          flush()
        }
      }
      flush()
      if (mode == "total") print total + 0
    }
  '
}

# The same folding over an arbitrary body, so a mention that wrapped in the PR is one entry and
# not two. The reason test counts the words of ONE entry, and a mention split across a line
# break would otherwise lose its reason to the entry after it.
entries() {
  awk '
    function flush() { if (cur != "") { print cur; cur = "" } }
    {
      line = $0
      if (line ~ /^[ \t]*$/) { flush(); next }
      if (cur != "" && line ~ /^[ \t]+[^ \t]/ && line !~ /^[ \t]*[-*+] / && line !~ /^[ \t]*[0-9]+\. /) {
        sub(/^[ \t]+/, " ", line); cur = cur line; next
      }
      flush(); cur = line
    }
    END { flush() }
  '
}

# How many words this entry carries that the box does not. Three is the threshold: `moved to
# #250` is three, and a box pasted back unchanged is zero.
REASON_WORDS=3
extra_words() {
  local entry="$1" box="$2" w n=0
  for w in $entry; do
    case " $box " in *" $w "*) ;; *) n=$((n + 1)) ;; esac
  done
  printf '%s' "$n"
}

# ---- the decision ----------------------------------------------------------------
# accounted · no-reason · unmentioned, for one box against one PR body. A pure function over
# two strings, which is the part the selftest can hold still.
classify_box() {
  local box_norm="$1" pr_body="$2"
  local key entry entry_norm best=unmentioned extra
  key="$(key_of "$box_norm")"
  if [ -n "$key" ]; then
    while IFS= read -r entry; do
      entry_norm="$(norm "$entry")"
      case " $entry_norm " in
        *" $key "*)
          extra="$(extra_words "$entry_norm" "$box_norm")"
          if [ "$extra" -ge "$REASON_WORDS" ]; then printf 'accounted'; return 0; fi
          best=no-reason
          ;;
      esac
    done <<ENTRIES
$(printf '%s' "$pr_body" | entries)
ENTRIES
  fi
  printf '%s' "$best"
  return 0
}

# ---- the backends ----------------------------------------------------------------
# Each read either answers or exits 2. An empty answer from a failed read is indistinguishable
# from a real absence, and that confusion is what #155 shipped.
#
# CALL IT AS `x="$(gh_or_die …)" || exit $?`. Its `exit 2` runs inside the command
# substitution's subshell and kills only that subshell; the status propagates as the
# substitution's own, and the `|| exit` is what makes the guard real.
gh_or_die() {
  local what="$1"; shift
  local out
  if ! out="$(gh api graphql "$@" 2>&1)"; then
    echo "the $what read failed — cannot tell whether the boxes were dispositioned:" >&2
    printf '%s\n' "$out" >&2
    exit 2
  fi
  printf '%s' "$out"
}

# Bodies travel base64-encoded so one PR stays on one line whatever the body contains. A DECODE
# THAT FAILS MUST NOT LOOK LIKE AN EMPTY BODY: `base64` absent from PATH, a BSD build wanting
# `-D`, a truncated payload — each would otherwise leave an empty file, and an empty issue body
# reads as `0 boxes, all ticked`, which is a universally clean pass. That is the same confusion
# the exit-code rule above exists to prevent, one layer down.
b64_to_file() {
  local b64="$1" dest="$2" what="$3"
  if ! printf '%s' "$b64" | base64 -d > "$dest" 2>/dev/null; then
    echo "the $what could not be decoded — cannot tell whether the boxes were dispositioned" >&2
    exit 2
  fi
  return 0
}

# GitHub parses FOUR closing-reference forms, and recognising only `#NN` misses three of them.
# The vocabulary matches tests/verify-linked-branch.sh and tests/verify-tracker-body.sh
# deliberately: one list, tuned in one place.
#
#   Closes #206 · Closes GH-206 · Closes owner/repo#206 · Closes https://…/issues/206
KEYWORDS='(close[sd]?|fix(e[sd])?|resolve[sd]?)'

body_closes_issue() {
  local issue="$1" body="$2"
  printf '%s\n' "$body" | grep -Eqi \
    "${KEYWORDS}[[:space:]]+[^[:space:]]*(#|gh-|issues/)${issue}([^0-9]|$)"
}

# Every issue number a body closes, one per line.
body_closes_which() {
  printf '%s\n' "$1" | grep -Eoi "${KEYWORDS}[[:space:]]+[^[:space:]]*(#|gh-|issues/)[0-9]+" \
    | grep -oE '[0-9]+$'
}

# THE HEAD BRANCH IS A CLAIM ABOUT WHICH ISSUE THIS IS, and inside an arc it is often the only
# one the tracker can be asked for. m46 §9: `arc/<nn>-<slug>-issue-<NN>-<hint>`.
branch_issue() {
  printf '%s' "$1" | sed -n 's#.*-issue-\([0-9][0-9]*\)\(-.*\)\?$#\1#p'
}

# ---- why the resolution is not just `closingIssuesReferences` --------------------
# AN ARC ISSUE PR CLOSES NOTHING, AS FAR AS GitHub IS CONCERNED. A closing keyword is parsed
# only on a PR targeting the repository default, and every issue PR in an arc targets the arc
# branch — `hooks/tracker-verify` says so in as many words when it fires: "closure defers to the
# arc PR. A keyword cannot bind on a base of `<arc branch>`". Measured in this repository and
# recorded in docs/arc-work/02-foundation/closing-keywords-and-base-branch.md: PR #7 on `main`
# linked five issues, PR #20 on `arc/02-foundation` linked none, same session and same keyword.
#
# So a resolution that trusts that field alone answers "this PR closes no issue" for exactly the
# PRs this check exists for — #17 and #194 were both arc issue PRs — and exits 0 having counted
# nothing. Two more sources close the gap, and both are claims the author made on purpose:
#
#   the body's own closing keyword   `Closes #NN`, which every arc PR is required to carry
#   the head branch's `-issue-<NN>`  which `createLinkedBranch` put there
#
# Neither is a guess. A PR that says `Closes #199` is answerable for #199's checklist whether or
# not GitHub was willing to bind the keyword on that base.

NWO=""
resolve_repo() {
  [ -n "$NWO" ] && return 0
  command -v gh >/dev/null 2>&1 || { echo "gh not on PATH" >&2; exit 2; }
  NWO="$(gh repo view --json nameWithOwner --jq .nameWithOwner 2>/dev/null)"
  [ -n "$NWO" ] || { echo "cannot read the repository from here" >&2; exit 2; }
  return 0
}

# Fills TMP with `body` and `prs`, and one `pr-<n>.body` per closing PR.
load_issue() {
  local n="$1" fx="${ARC_BOXES_FIXTURES:-}" raw owner repo num ref b64 kind pr line
  if [ -n "$fx" ]; then
    if [ ! -f "$fx/issue-$n.md" ]; then
      echo "issue #$n could not be read — it does not exist, or the read failed" >&2
      exit 2
    fi
    cp "$fx/issue-$n.md" "$TMP/body"
    : > "$TMP/prs"
    # `.prs` are the PRs GitHub already binds; `.crossrefs` are the ones that only mention it,
    # which is where the arc case lives. Candidates run the same acceptance test as live.
    [ -f "$fx/issue-$n.prs" ] && grep -E '^[0-9]+$' "$fx/issue-$n.prs" > "$TMP/prs"
    while IFS= read -r pr; do
      [ -n "$pr" ] || continue
      if [ -f "$fx/pr-$pr.md" ]; then cp "$fx/pr-$pr.md" "$TMP/pr-$pr.body"; else : > "$TMP/pr-$pr.body"; fi
    done < "$TMP/prs"
    if [ -f "$fx/issue-$n.crossrefs" ]; then
      while IFS= read -r pr; do
        case "$pr" in ''|*[!0-9]*) continue ;; esac
        grep -qxF "$pr" "$TMP/prs" && continue
        ref=""
        [ -f "$fx/pr-$pr.branch" ] && ref="$(head -n1 "$fx/pr-$pr.branch")"
        accept_candidate "$n" "$pr" "$ref" "$(cat "$fx/pr-$pr.md" 2>/dev/null)" || continue
        printf '%s\n' "$pr" >> "$TMP/prs"
        if [ -f "$fx/pr-$pr.md" ]; then cp "$fx/pr-$pr.md" "$TMP/pr-$pr.body"; else : > "$TMP/pr-$pr.body"; fi
      done < "$fx/issue-$n.crossrefs"
    fi
    return 0
  fi

  resolve_repo
  owner="${NWO%%/*}"; repo="${NWO##*/}"

  # One round trip for the body and every PR that could answer for this checklist. The timeline's
  # cross-references are what reach an arc issue PR at all — see the note above
  # `body_closes_issue`. They are CANDIDATES: anything may cross-reference an issue, so each is
  # admitted only on its own claim, below.
  raw="$(gh_or_die "issue #$n" \
    -f query='query($o:String!,$r:String!,$n:Int!){repository(owner:$o,name:$r){issue(number:$n){body closedByPullRequestsReferences(first:50,includeClosedPrs:true){nodes{number headRefName body}} timelineItems(first:100,itemTypes:[CROSS_REFERENCED_EVENT]){nodes{... on CrossReferencedEvent{source{... on PullRequest{number headRefName body}}}}}}}}' \
    -F o="$owner" -F r="$repo" -F n="$n" \
    --jq 'if .data.repository.issue == null then "MISSING" else (["BODY \(.data.repository.issue.body // "" | @base64)"] + [.data.repository.issue.closedByPullRequestsReferences.nodes[]? | "PR \(.number) bound \(.headRefName // "-") \(.body // "" | @base64)"] + [.data.repository.issue.timelineItems.nodes[]? | select(.source != null and (.source.number != null)) | "PR \(.source.number) candidate \(.source.headRefName // "-") \(.source.body // "" | @base64)"] | join("\n")) end')" || exit $?

  if [ "$raw" = "MISSING" ] || [ -z "$raw" ]; then
    echo "issue #$n could not be read — it does not exist, or the read failed" >&2
    exit 2
  fi

  : > "$TMP/prs"
  while IFS= read -r line; do
    case "$line" in
      "BODY "*) b64_to_file "${line#BODY }" "$TMP/body" "body of issue #$n" ;;
      "PR "*)
        line="${line#PR }"
        num="${line%% *}"; line="${line#* }"
        kind="${line%% *}"; line="${line#* }"
        ref="${line%% *}"; b64="${line#* }"
        grep -qxF "$num" "$TMP/prs" 2>/dev/null && continue
        [ "$ref" = "-" ] && ref=""
        if [ "$kind" = candidate ]; then
          # DECODED THROUGH THE SAME GUARD as the two writes below. A bare decode here would
          # hand `accept_candidate` an empty body on a `base64` that is absent or BSD-flavoured,
          # the candidate would be rejected in silence, and an issue whose only answering PR is
          # an unbound arc PR would exit 1 — a finding — where it owes exit 2.
          b64_to_file "$b64" "$TMP/candidate" "body of PR #$num"
          accept_candidate "$n" "$num" "$ref" "$(cat "$TMP/candidate")" || continue
        fi
        printf '%s\n' "$num" >> "$TMP/prs"
        b64_to_file "$b64" "$TMP/pr-$num.body" "body of PR #$num"
        ;;
    esac
  done <<RAW
$raw
RAW
  [ -f "$TMP/body" ] || : > "$TMP/body"
  return 0
}

# Does this PR claim to answer for that issue's checklist? TWO claims the author made on purpose,
# and no inference beyond them. The third source — `closedByPullRequestsReferences` — needs no
# test: it is what produced the bound list in the first place.
#
# The branch test is the weaker of the two and stays for the `git checkout -b` case. A branch
# made through `createLinkedBranch` does not need it: m12 measured that opening a PR on a linked
# branch PROMOTES the record into that PR's closing reference, so such a PR arrives already
# bound, whatever its body says.
accept_candidate() {
  local issue="$1" pr="$2" ref="$3" body="$4"
  body_closes_issue "$issue" "$body" && return 0
  [ -n "$ref" ] && [ "$(branch_issue "$ref")" = "$issue" ] && return 0
  return 1
}

# The issues a PR is answerable for, one per line on stdout. EMPTY IS A LEGITIMATE ANSWER — a
# no-issue PR is ordinary work (m46 §4) and has no checklist to disposition.
#
# Three sources, unioned, for the reason recorded above `body_closes_issue`: inside an arc,
# `closingIssuesReferences` is empty on a correctly written PR.
pr_issues() {
  local n="$1" fx="${ARC_BOXES_FIXTURES:-}" owner repo out body ref bound i
  if [ -n "$fx" ]; then
    if [ ! -f "$fx/pr-$n.md" ]; then
      echo "PR #$n could not be read — it does not exist, or the read failed" >&2
      exit 2
    fi
    body="$(cat "$fx/pr-$n.md" 2>/dev/null)"
    ref=""; [ -f "$fx/pr-$n.branch" ] && ref="$(head -n1 "$fx/pr-$n.branch")"
    bound=""; [ -f "$fx/pr-$n.issues" ] && bound="$(grep -E '^[0-9]+$' "$fx/pr-$n.issues")"
  else
    resolve_repo
    owner="${NWO%%/*}"; repo="${NWO##*/}"
    out="$(gh_or_die "PR #$n" \
      -f query='query($o:String!,$r:String!,$n:Int!){repository(owner:$o,name:$r){pullRequest(number:$n){number headRefName body closingIssuesReferences(first:50){nodes{number}}}}}' \
      -F o="$owner" -F r="$repo" -F n="$n" \
      --jq 'if .data.repository.pullRequest == null then "MISSING" else (["REF \(.data.repository.pullRequest.headRefName // "-")", "BODY \(.data.repository.pullRequest.body // "" | @base64)"] + [.data.repository.pullRequest.closingIssuesReferences.nodes[]? | "NUM \(.number)"] | join("\n")) end')" || exit $?
    if [ "$out" = "MISSING" ]; then
      echo "PR #$n could not be read — it does not exist, or the read failed" >&2
      exit 2
    fi
    ref=""; body=""; bound=""
    while IFS= read -r i; do
      case "$i" in
        "REF "*)  ref="${i#REF }"; [ "$ref" = "-" ] && ref="" ;;
        # NO TEMP FILE HERE. `run_pr` calls this before it has a `TMP`, so a `$TMP/prbody` write
        # resolved to `/prbody` — failing outright on a POSIX box and littering the msys root on
        # Windows. This is the hook's ONLY path, and no fixture case could reach it, so all 24
        # selftest cases passed over it. The decode keeps its guard: this loop is not a subshell,
        # so `exit 2` leaves the function, and every caller uses `|| exit $?`.
        "BODY "*)
          if ! body="$(printf '%s' "${i#BODY }" | base64 -d 2>/dev/null)"; then
            echo "the body of PR #$n could not be decoded — cannot tell whether the boxes were dispositioned" >&2
            exit 2
          fi
          ;;
        "NUM "*)  bound="$bound${bound:+
}${i#NUM }" ;;
      esac
    done <<OUT
$out
OUT
  fi

  { printf '%s\n' "$bound"
    body_closes_which "$body"
    [ -n "$ref" ] && branch_issue "$ref"
  } | grep -E '^[0-9]+$' | sort -un
  return 0
}

# ---- one issue -------------------------------------------------------------------
# 0 clean, 1 findings. Never 2 — every read that could fail has already been made.
check_issue() {
  local n="$1"
  local total=0 open=0 accounted=0 findings="" box box_norm verdict where pr prs

  # `box_scan`, never a `grep -c`. GNU ERE reads `\` literally inside a bracket expression, so
  # `[ \t]*` matches space, backslash and the letter `t` and NOT a tab — a tab-indented box was
  # counted by the scanner and missed by the grep, and the report then carried `1 of 0 boxes`.
  # One scanner cannot disagree with itself.
  total="$(box_scan total < "$TMP/body")"
  prs="$(tr '\n' ' ' < "$TMP/prs" 2>/dev/null | sed -E 's/ +$//')"

  while IFS= read -r box; do
    [ -n "$box" ] || continue
    open=$((open + 1))
    box_norm="$(norm "$box")"
    verdict=unmentioned
    where=""
    for pr in $prs; do
      case "$(classify_box "$box_norm" "$(cat "$TMP/pr-$pr.body" 2>/dev/null)")" in
        accounted) verdict=accounted; where="#$pr"; break ;;
        no-reason) [ "$verdict" = unmentioned ] && { verdict=no-reason; where="#$pr"; } ;;
      esac
    done
    case "$verdict" in
      accounted) accounted=$((accounted + 1)) ;;
      no-reason) findings="$findings
        - PR $where quotes it and says nothing else about it: \"$box\"" ;;
      *)         findings="$findings
        - unticked, and no closing PR names it: \"$box\"" ;;
    esac
  done <<BOXES
$(box_scan open < "$TMP/body")
BOXES

  if [ -z "$findings" ]; then
    if [ "$open" = "0" ]; then
      echo "PASS  #$n — $total boxes, all ticked"
    else
      echo "PASS  #$n — $total boxes: $((total - open)) ticked, $accounted named in a closing PR with a reason"
    fi
    return 0
  fi

  echo "FAIL  #$n — $open of $total boxes unticked, $((open - accounted)) of them undispositioned:$findings"
  echo
  echo "      Tick it, or write a line in the PR body that QUOTES THE BOX'S FIRST $KEY_WORDS WORDS,"
  echo "      unbroken and in order, and then says what happened — not done and why, or moved to"
  echo "      the issue that owns it:"
  echo
  echo "        - <the box's first $KEY_WORDS words, copied> — moved to #250"
  echo
  echo "      The quote is what ties the disposition to the box; a reason with no quote reads as"
  echo "      prose about something else. The part after it must carry at least $REASON_WORDS words the box"
  echo "      does not, so the box pasted back unchanged is not a disposition. Partial completion"
  echo "      stays approvable; silence about it does not."
  [ -n "$prs" ] || echo "      Nothing answers for #$n yet — no PR closes it, names it in a closing keyword, or"
  [ -n "$prs" ] || echo "      heads a branch named for it. This answers at PR-ready time, not at PR-open."
  return 1
}

# ---- entry points ----------------------------------------------------------------
run_issue() {
  TMP="$(mktemp -d)"
  load_issue "$1"
  check_issue "$1"
  exit $?
}

run_pr() {
  local n="$1" issues status=0 i
  issues="$(pr_issues "$n")" || exit $?
  if [ -z "$(printf '%s' "$issues" | tr -d '[:space:]')" ]; then
    echo "PASS  PR #$n closes no issue — no checklist to disposition"
    exit 0
  fi
  for i in $issues; do
    TMP="$(mktemp -d)"
    load_issue "$i"
    check_issue "$i" || status=1
    rm -rf "$TMP"; TMP=""
  done
  exit "$status"
}

# ---- selftest --------------------------------------------------------------------
# THE WHOLE SCRIPT, NOT ONLY THE DECISION. Each case builds a fixture directory and runs this
# file as a subprocess, so argument parsing, the two entry points, the missing-object paths and
# the exit codes are all exercised. A selftest that called `classify_box` directly would pass
# with the entry points broken, which is the shape of every case below that exits 2.
#
# EVERY CASE ASSERTS THE MESSAGE AS WELL AS THE EXIT CODE. Exit 1 is reached by "unticked and
# unmentioned" and by "quoted with nothing beside it", and a code-only selftest passes with the
# two confused — which would tell an author to write a reason they already wrote.
selftest() {
  local run=0 passed=0 failed=0

  FX="$(mktemp -d)"   # NOT local: the EXIT trap below fires after this function has returned
  trap 'rm -rf "$FX"; cleanup' EXIT

  ok()  { passed=$((passed + 1)); echo "  ok    $1"; }
  bad() { failed=$((failed + 1)); echo "  FAIL  $1"; shift; for m in "$@"; do [ -n "$m" ] && echo "        $m"; done; }

  # $1 want-exit  $2 want-text  $3 name  $4… arguments to this script
  case_is() {
    local want="$1" want_text="$2" name="$3"; shift 3
    run=$((run + 1))
    local out status
    out="$(ARC_BOXES_FIXTURES="$FX" bash "$SELF" "$@" 2>&1)"; status=$?
    if [ "$status" != "$want" ]; then
      bad "$name — wanted exit $want, got $status" "$(printf '%s' "$out" | head -n 3)"; return
    fi
    if ! printf '%s' "$out" | grep -qF -- "$want_text"; then
      bad "$name — exit $status is right, but the message never says \"$want_text\"" "$(printf '%s' "$out" | head -n 3)"; return
    fi
    ok "$name"
  }

  echo "verify-issue-boxes selftest"
  echo

  # ---- all ticked ----------------------------------------------------------------
  cat > "$FX/issue-901.md" <<'BODY'
## Required

- [x] The script reports every remaining box
- [x] It reads the live issue
BODY
  case_is 0 "2 boxes, all ticked" "all ticked, no PR" 901

  # ---- one unticked, and no PR body mentions it ------------------------------------
  cat > "$FX/issue-902.md" <<'BODY'
## Required

- [x] The script reports every remaining box
- [ ] Selftest cases for every shape the check can meet
BODY
  printf '801\n' > "$FX/issue-902.prs"
  cat > "$FX/pr-801.md" <<'BODY'
Adds the checker.

Closes #902
BODY
  case_is 1 "unticked, and no closing PR names it" "unticked and unmentioned" 902

  # ---- one unticked, named in the PR body with a reason ----------------------------
  cat > "$FX/issue-903.md" <<'BODY'
## Required

- [x] The script reports every remaining box
- [ ] Selftest cases for every shape the check can meet
BODY
  printf '802\n' > "$FX/issue-903.prs"
  cat > "$FX/pr-802.md" <<'BODY'
Adds the checker.

Not done:

- Selftest cases for every shape the check can meet — deferred, the harness lands in #904

Closes #903
BODY
  case_is 0 "1 ticked, 1 named in a closing PR with a reason" "unticked, named with a reason" 903

  # ---- a box moved to another issue is resolved ------------------------------------
  # #140 allows moving a box this unit cannot meet, and the constraint says the check must
  # accept a row that names where it went. Three words of its own is all that takes.
  cat > "$FX/issue-905.md" <<'BODY'
- [ ] Selftest cases for every shape the check can meet
BODY
  printf '803\n' > "$FX/issue-905.prs"
  cat > "$FX/pr-803.md" <<'BODY'
- Selftest cases for every shape the check can meet — moved to #904

Closes #905
BODY
  case_is 0 "named in a closing PR with a reason" "a box moved to another issue" 905

  # ---- quoted back with nothing beside it -------------------------------------------
  # The checklist pasted into the PR body. This is #194's failure with a copy step added: the
  # boxes are visible and still nobody said what happened to them.
  cat > "$FX/issue-906.md" <<'BODY'
- [ ] Selftest cases for every shape the check can meet
BODY
  printf '804\n' > "$FX/issue-906.prs"
  cat > "$FX/pr-804.md" <<'BODY'
## Required

- [ ] Selftest cases for every shape the check can meet

Closes #906
BODY
  case_is 1 "quotes it and says nothing else about it" "quoted with no reason" 906

  # ---- the mention wrapped over two lines -------------------------------------------
  # A PR body is written by a human at 100 columns. Folding continuation lines is what keeps
  # the reason attached to the mention it belongs to.
  cat > "$FX/issue-907.md" <<'BODY'
- [ ] Selftest cases for every shape the check can meet
BODY
  printf '805\n' > "$FX/issue-907.prs"
  cat > "$FX/pr-805.md" <<'BODY'
- Selftest cases for every shape the check
  can meet — not done, the harness cannot run offline yet

Closes #907
BODY
  case_is 0 "named in a closing PR with a reason" "the mention wrapped over two lines" 907

  # ---- the box itself wrapped in the issue -------------------------------------------
  # #140's own boxes wrap at six spaces. The key is the first eight words, so a one-line
  # mention still matches a three-line box.
  cat > "$FX/issue-908.md" <<'BODY'
- [ ] A read-back step in [`close-sequence.md`](../docs/close-sequence.md),
      between step 4b and step 5, so it runs before the PR opens
BODY
  printf '806\n' > "$FX/issue-908.prs"
  cat > "$FX/pr-806.md" <<'BODY'
- A read-back step in close-sequence.md — not done, it belongs to the skill instead

Closes #908
BODY
  case_is 0 "named in a closing PR with a reason" "the box wrapped in the issue" 908

  # ---- an unticked box and no PR at all ----------------------------------------------
  # PR-open time. The check answers, and says which moment it is answering for.
  cat > "$FX/issue-909.md" <<'BODY'
- [ ] Selftest cases for every shape the check can meet
BODY
  case_is 1 "This answers at PR-ready time" "no PR closes it yet" 909

  # ---- an issue with no checklist at all ---------------------------------------------
  cat > "$FX/issue-910.md" <<'BODY'
Prose only. No checklist in this issue.
BODY
  case_is 0 "0 boxes, all ticked" "no boxes at all" 910

  # ---- the arc case: a PR that closes it, that GitHub does not bind -----------------------
  # A closing keyword is parsed only on a PR targeting the repository default, so every issue PR
  # inside an arc has an EMPTY closingIssuesReferences and appears on the issue only as a
  # cross-reference. Measured in this repository: PR #7 on `main` linked five issues, PR #20 on
  # `arc/02-foundation` linked none, same session and same keyword. A resolution that trusted
  # that field answered "closes no issue" for #17 and #194, which are the two failures this
  # whole check exists for.
  cat > "$FX/issue-912.md" <<'BODY'
- [ ] Selftest cases for every shape the check can meet
BODY
  printf '809\n' > "$FX/issue-912.crossrefs"
  cat > "$FX/pr-809.md" <<'BODY'
- Selftest cases for every shape the check can meet — not done, deferred to #904

Closes #912
BODY
  case_is 0 "named in a closing PR with a reason" "an arc PR, bound only by its keyword" 912

  # The same shape with the keyword written as a URL. GitHub parses four reference forms and
  # recognising one of them classifies the other three as "closes no issue".
  cat > "$FX/issue-913.md" <<'BODY'
- [ ] Selftest cases for every shape the check can meet
BODY
  printf '810\n' > "$FX/issue-913.crossrefs"
  cat > "$FX/pr-810.md" <<'BODY'
- Selftest cases for every shape the check can meet — not done, deferred to #904

Resolves https://github.com/Calyx-Engineering/arc/issues/913
BODY
  case_is 0 "named in a closing PR with a reason" "an arc PR bound by a URL keyword" 913

  # Bound by the head branch alone — what `createLinkedBranch` put there, and the only claim
  # left on a PR whose body was written before the keyword rule.
  cat > "$FX/issue-914.md" <<'BODY'
- [ ] Selftest cases for every shape the check can meet
BODY
  printf '811\n' > "$FX/issue-914.crossrefs"
  printf 'arc/04-dogfood-issue-914-boxes\n' > "$FX/pr-811.branch"
  cat > "$FX/pr-811.md" <<'BODY'
- Selftest cases for every shape the check can meet — not done, deferred to #904
BODY
  case_is 0 "named in a closing PR with a reason" "an arc PR bound by its head branch" 914

  # A CROSS-REFERENCE IS NOT A CLAIM. Any PR may mention an issue; one that neither closes it
  # nor heads a branch named for it is not answerable for its checklist, and admitting it would
  # let an unrelated PR's prose resolve boxes by accident.
  cat > "$FX/issue-915.md" <<'BODY'
- [ ] Selftest cases for every shape the check can meet
BODY
  printf '812\n' > "$FX/issue-915.crossrefs"
  printf 'arc/04-dogfood-issue-77-other\n' > "$FX/pr-812.branch"
  cat > "$FX/pr-812.md" <<'BODY'
Follows on from #915, but does not close it.

- Selftest cases for every shape the check can meet — not done, deferred to #904
BODY
  case_is 1 "unticked, and no closing PR names it" "a bare cross-reference does not count" 915

  # ---- a `- [ ]` inside a fenced block is not a checklist item ------------------------------
  # An issue that shows a checklist is not an issue that has one. Counting the example reports a
  # finding for a box that does not exist and cannot be ticked.
  cat > "$FX/issue-916.md" <<'BODY'
## Required

- [x] The script reports every remaining box

A body may show the shape it accepts:

```markdown
- [ ] this is an example, not a requirement
```
BODY
  case_is 0 "1 boxes, all ticked" "a fenced example box is not a box" 916

  # ---- an unbalanced fence must not silence the checklist -------------------------------------
  # THE FIRST DRAFT OF THE FENCE RULE SHIPPED A UNIVERSAL SILENT PASS. A single toggle on either
  # marker meant an unclosed ``` swallowed every box after it and the run printed `0 boxes, all
  # ticked`. Over-reporting is a finding a human dismisses in a second; this was the other
  # direction, and it is the one this whole check exists to end.
  printf 'Body\n\n```sh\ngh pr ready\n\n## Required\n\n- [ ] a real requirement\n- [ ] another one\n' > "$FX/issue-919.md"
  case_is 1 "2 of 2 boxes unticked" "an unclosed fence counts everything" 919

  # A `~~~` inside a backtick block used to flip the state off, so the real closing fence flipped
  # it back on and hid the rest of the body. Markers are matched to each other now.
  printf '```\n~~~\n```\n- [ ] a real requirement\n' > "$FX/issue-920.md"
  case_is 1 "1 of 1 boxes unticked" "a mismatched marker does not close a fence" 920

  # And the balanced tilde form still works, or the repair would have bought silence back by
  # honouring only one marker.
  cat > "$FX/issue-921.md" <<'BODY'
- [x] The script reports every remaining box

~~~markdown
- [ ] this is an example, not a requirement
~~~
BODY
  case_is 0 "1 boxes, all ticked" "a balanced tilde fence is honoured" 921

  # ---- the total and the open list cannot disagree -------------------------------------------
  # A tab-indented box. The count used to come from a `grep -E '[ \t]'`, where GNU ERE reads the
  # backslash literally inside a bracket expression — so the scanner saw the box and the count
  # did not, and the report said `1 of 0 boxes unticked`.
  printf '## Required\n\n\t- [ ] a tab-indented box\n' > "$FX/issue-917.md"
  case_is 1 "1 of 1 boxes unticked" "a tab-indented box counts once" 917

  # ---- a PR whose issues come only from its own keyword -------------------------------------
  # The hook's path inside an arc: `gh pr ready` on a PR GitHub binds to nothing.
  cat > "$FX/pr-813.md" <<'BODY'
Adds the checker.

Closes #918
BODY
  cat > "$FX/issue-918.md" <<'BODY'
- [ ] Selftest cases for every shape the check can meet
BODY
  printf '813\n' > "$FX/issue-918.crossrefs"
  case_is 1 "unticked, and no closing PR names it" "--pr resolves through its own keyword" --pr 813

  # ---- an issue that does not exist ----------------------------------------------------
  # EXIT 2, NEVER 1. A read that could not be made is not a finding, and reporting it as one
  # would put a defect on the record that nothing observed.
  case_is 2 "could not be read" "an issue that does not exist" 999

  # ---- a PR with no linked issue --------------------------------------------------------
  # m46 §4: work is spawned from no-issue PRs too, and one has no checklist to disposition.
  cat > "$FX/pr-807.md" <<'BODY'
A direct PR with no issue behind it.
BODY
  case_is 0 "closes no issue" "a PR with no linked issue" --pr 807

  # ---- a PR that closes an issue with an undispositioned box ------------------------------
  # The hook's own path: `gh pr ready` names a PR, and the boxes belong to the issue it closes.
  cat > "$FX/pr-808.md" <<'BODY'
Adds the checker.

Closes #911
BODY
  printf '911\n' > "$FX/pr-808.issues"
  cat > "$FX/issue-911.md" <<'BODY'
- [ ] Selftest cases for every shape the check can meet
BODY
  printf '808\n' > "$FX/issue-911.prs"
  case_is 1 "unticked, and no closing PR names it" "a PR whose issue has an open box" --pr 808

  # ---- a PR that does not exist ------------------------------------------------------------
  case_is 2 "could not be read" "a PR that does not exist" --pr 998

  # ---- arguments ---------------------------------------------------------------------------
  case_is 2 "usage" "no arguments"        # shellcheck: intentionally none
  case_is 2 "usage" "not a number" abc
  case_is 2 "usage" "--pr with no number" --pr
  case_is 2 "usage" "too many arguments" 901 902

  echo
  if [ "$failed" = "0" ]; then
    echo "$run cases, $passed passed, 0 failed"
    return 0
  fi
  echo "$run cases, $passed passed, $failed failed"
  return 1
}

case "${1:-}" in
  selftest)  [ "$#" -eq 1 ] || { echo "selftest takes no arguments" >&2; usage; exit 2; }
             selftest ;;
  -h|--help) usage; exit 0 ;;
  --pr)      [ "$#" -eq 2 ] || { usage; exit 2; }
             case "$2" in ''|*[!0-9]*) usage; exit 2 ;; esac
             run_pr "$2" ;;
  '')        usage; exit 2 ;;
  *[!0-9]*)  usage; exit 2 ;;
  *)         [ "$#" -eq 1 ] || { echo "too many arguments" >&2; usage; exit 2; }
             run_issue "$1" ;;
esac
