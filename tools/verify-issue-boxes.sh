#!/usr/bin/env bash
# verify-issue-boxes.sh — is every `Required` box dispositioned before the PR is ready?
#
#   tools/verify-issue-boxes.sh <issue-number>     the issue's boxes, against its closing PRs
#   tools/verify-issue-boxes.sh --pr <pr-number>   every issue that PR closes
#   tools/verify-issue-boxes.sh selftest
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
#   named, with a reason    the box's opening words appear in a closing PR's body, on an entry
#                           that also carries at least three words the box itself does not.
#                           `— moved to #250` and `not done: the API has no such field` both
#                           pass; the box pasted back verbatim does not, because a checklist
#                           copied into a PR body states nothing
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
#      defect. Same distinction tools/verify-linked-branch.sh draws, for the same reason
#
# THE FIXTURE BACKEND. `ARC_BOXES_FIXTURES=<dir>` swaps the `gh` reads for files of the same
# shape, so the selftest exercises this file end to end — argument parsing, exit codes and all
# — with no network and no live issue. The precedent is `hooks/tracker-verify`'s `arc_test_*`
# keys: a verifier whose only path needs GitHub is a verifier nobody runs the day it matters.
#
#   issue-<N>.md      the issue body. ABSENT MEANS THE ISSUE DOES NOT EXIST
#   issue-<N>.prs     numbers of the PRs that close it, one per line. Absent means none
#   pr-<N>.md         the PR body. ABSENT MEANS THE PR DOES NOT EXIST
#   pr-<N>.issues     numbers of the issues it closes, one per line. Absent means none

set -u

SELF="${BASH_SOURCE[0]}"

usage() {
  cat >&2 <<'USAGE'
usage:
  tools/verify-issue-boxes.sh <issue-number>
  tools/verify-issue-boxes.sh --pr <pr-number>
  tools/verify-issue-boxes.sh selftest
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

# One unticked box per line, its continuation lines folded in. A `- [x]` closes the box before
# it and contributes nothing; so does a blank line or a new list item.
unticked() {
  awk '
    function flush() { if (cur != "") { print cur; cur = "" } }
    {
      line = $0
      if (line ~ /^[ \t]*[-*+] \[ \]/) {
        flush(); sub(/^[ \t]*[-*+] \[ \][ \t]*/, "", line); cur = line; next
      }
      if (line ~ /^[ \t]*[-*+] \[[xX]\]/) { flush(); next }
      if (cur != "") {
        if (line ~ /^[ \t]+[^ \t]/ && line !~ /^[ \t]*[-*+] / && line !~ /^[ \t]*[0-9]+\. /) {
          sub(/^[ \t]+/, " ", line); cur = cur line; next
        }
        flush()
      }
    }
    END { flush() }
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
  local n="$1" fx="${ARC_BOXES_FIXTURES:-}" raw owner repo num b64 pr line
  if [ -n "$fx" ]; then
    if [ ! -f "$fx/issue-$n.md" ]; then
      echo "issue #$n could not be read — it does not exist, or the read failed" >&2
      exit 2
    fi
    cp "$fx/issue-$n.md" "$TMP/body"
    : > "$TMP/prs"
    [ -f "$fx/issue-$n.prs" ] && grep -E '^[0-9]+$' "$fx/issue-$n.prs" > "$TMP/prs"
    while IFS= read -r pr; do
      [ -n "$pr" ] || continue
      if [ -f "$fx/pr-$pr.md" ]; then cp "$fx/pr-$pr.md" "$TMP/pr-$pr.body"; else : > "$TMP/pr-$pr.body"; fi
    done < "$TMP/prs"
    return 0
  fi

  resolve_repo
  owner="${NWO%%/*}"; repo="${NWO##*/}"

  # One round trip for the body and every closing PR's body. Bodies come back base64-encoded so
  # that one PR stays on one line whatever the body contains — the same shape
  # tools/verify-linked-branch.sh uses, for the same reason.
  raw="$(gh_or_die "issue #$n" \
    -f query='query($o:String!,$r:String!,$n:Int!){repository(owner:$o,name:$r){issue(number:$n){body closedByPullRequestsReferences(first:50,includeClosedPrs:true){nodes{number body}}}}}' \
    -F o="$owner" -F r="$repo" -F n="$n" \
    --jq 'if .data.repository.issue == null then "MISSING" else (["BODY \(.data.repository.issue.body // "" | @base64)"] + [.data.repository.issue.closedByPullRequestsReferences.nodes[]? | "\(.number) \(.body // "" | @base64)"] | join("\n")) end')" || exit $?

  if [ "$raw" = "MISSING" ] || [ -z "$raw" ]; then
    echo "issue #$n could not be read — it does not exist, or the read failed" >&2
    exit 2
  fi

  : > "$TMP/prs"
  while IFS= read -r line; do
    case "$line" in
      "BODY "*) printf '%s' "${line#BODY }" | base64 -d > "$TMP/body" 2>/dev/null ;;
      "") ;;
      *)
        num="${line%% *}"; b64="${line#* }"
        printf '%s\n' "$num" >> "$TMP/prs"
        printf '%s' "$b64" | base64 -d > "$TMP/pr-$num.body" 2>/dev/null
        ;;
    esac
  done <<RAW
$raw
RAW
  [ -f "$TMP/body" ] || : > "$TMP/body"
  return 0
}

# The issues a PR closes, one per line on stdout. EMPTY IS A LEGITIMATE ANSWER — a no-issue PR
# is ordinary work (m46 §4) and has no checklist to disposition.
pr_issues() {
  local n="$1" fx="${ARC_BOXES_FIXTURES:-}" owner repo out
  if [ -n "$fx" ]; then
    if [ ! -f "$fx/pr-$n.md" ]; then
      echo "PR #$n could not be read — it does not exist, or the read failed" >&2
      exit 2
    fi
    [ -f "$fx/pr-$n.issues" ] && grep -E '^[0-9]+$' "$fx/pr-$n.issues"
    return 0
  fi
  resolve_repo
  owner="${NWO%%/*}"; repo="${NWO##*/}"
  out="$(gh_or_die "PR #$n" \
    -f query='query($o:String!,$r:String!,$n:Int!){repository(owner:$o,name:$r){pullRequest(number:$n){number closingIssuesReferences(first:50){nodes{number}}}}}' \
    -F o="$owner" -F r="$repo" -F n="$n" \
    --jq 'if .data.repository.pullRequest == null then "MISSING" else ([.data.repository.pullRequest.closingIssuesReferences.nodes[]?.number] | map(tostring) | join("\n")) end')" || exit $?
  if [ "$out" = "MISSING" ]; then
    echo "PR #$n could not be read — it does not exist, or the read failed" >&2
    exit 2
  fi
  printf '%s\n' "$out" | grep -E '^[0-9]+$'
  return 0
}

# ---- one issue -------------------------------------------------------------------
# 0 clean, 1 findings. Never 2 — every read that could fail has already been made.
check_issue() {
  local n="$1"
  local total=0 open=0 accounted=0 findings="" box box_norm verdict where pr prs

  total="$(grep -cE '^[ \t]*[-*+] \[[ xX]\]' "$TMP/body" 2>/dev/null)"
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
$(unticked < "$TMP/body")
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
  echo "      Tick it, or name it in the PR body with what happened — not done and why, or"
  echo "      moved to the issue that owns it. Partial completion stays approvable; silence"
  echo "      about it does not."
  [ -n "$prs" ] || echo "      No PR closes #$n yet. This answers at PR-ready time, not at PR-open."
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
