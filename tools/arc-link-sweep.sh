#!/usr/bin/env bash
# arc-link-sweep.sh — the arc-checkpoint sweep for issues linked to nothing. m12 §4, row 4.
#
#   tools/arc-link-sweep.sh <milestone-title>   every issue in that milestone
#   tools/arc-link-sweep.sh selftest            the decision, on fixtures
#
# WHY A SWEEP AND NOT A PER-BRANCH CHECK. `tools/verify-linked-branch.sh <NN> <branch>` asks
# about one branch at one moment, and m12 §4 names the decisive moment as branch creation —
# before the PR exists. A run that skipped that moment leaves nothing behind that says so, and
# the drift accumulates across days. This is the checkpoint read that catches it, and the only
# one of m12 §4's four rows that has to look at both link fields at once.
#
# IT ASKS THE WEAKER QUESTION, AND PERMANENTLY SO. Promotion — a PR opening on a linked branch,
# which converts the branch record into that PR's closing reference — survives the PR being
# closed, and nothing detaches it: the whole GraphQL mutation list was grepped 2026-09-07 and
# holds `createLinkedBranch` and `deleteLinkedBranch` only, both of which act on branch records.
# So an issue that ever had a closing PR reads as linked forever, #206 included, which carries
# closed probe PR #219 that closed nothing. What this sweep finds is issues linked to NOTHING AT
# ALL — no branch record, no closing PR, open or closed. That is a real defect and the sweep's
# whole claim; "linked" here is not a claim that the right thing is linked.
#
# BOTH FIELDS, NEVER ONE. `issue.linkedBranches` reading empty is a defect before a PR exists
# and correct after one does — #155 read one field at one moment and concluded the mutation was
# broken when it was not. A sweep that counted `linkedBranches` alone would report every issue
# past its PR as unlinked, which is most of an arc.
#
# THE FIX IT HANDS BACK IS A CLICK, NOT A CALL. No API creates or removes a hand-attached link
# — tested in m42, and `POST /repos/{o}/{r}/issues/{n}/links` does not exist. On a work PR whose
# base was never the default branch the closing keyword cannot bind either, so for those the
# route is the Development panel and then `gh issue close`. `skills/issue-write` carries it.
#
# REPORTS, NEVER REWRITES. Same precedent as every verifier here. Exit 1 names the issues with
# no link; exit 2 is a read that could not be made, which is a different answer and must never
# be reported as "no link".

set -u

usage() {
  cat >&2 <<'USAGE'
usage:
  tools/arc-link-sweep.sh <milestone-title>
  tools/arc-link-sweep.sh selftest
USAGE
}

# ---- the decision ----------------------------------------------------------------
# A pure function over the two counts, so the part that was wrong in #155 — which field is
# consulted — is exercised with no network and no repository.
#
#   $1  issue number   $2  issue state   $3  linkedBranches count   $4  closing-PR count
#
# Prints one line and returns 0 when the issue is linked to something, 1 when it is linked to
# nothing, and 2 when a count could not be read — which is the distinction the header calls this
# file's whole point, and not a variant of 1. The line names WHICH field holds the link, because
# "linked" alone is the reading that hid #155 — and a checkpoint report that cannot be argued
# with has to say what it saw, including the value it could not parse.
classify_issue() {
  local num="$1" state="$2" refs="$3" prs="$4"

  # Non-numeric counts are a read that did not parse, not a zero. Saying so is the whole
  # distinction this file's header draws between exit 1 and exit 2.
  #
  # EMPTY IS ALSO NOT A ZERO, and the guard has to catch it here rather than at the call site.
  # `*[!0-9]*` does not match the empty string, so an absent count falls through to
  # `[ "" -gt 0 ]` — a bash error on stderr and a `NO LINK` verdict on an issue nothing was
  # read about, which is the exact confusion exit 2 exists to prevent.
  #
  # EACH COUNT SEPARATELY, NEVER CONCATENATED. `"$refs$prs"` with an empty `refs` and a `1` in
  # `prs` yields `1`, which passes both patterns and lands the empty one in the arithmetic.
  # THE RAW VALUE IS WHAT GOES IN THE MESSAGE, so the normalisation writes to its own variables.
  # Blanking in place made a malformed count and an absent one print identically, and a run
  # cannot then tell a parse bug from a field the query did not return.
  local refs_ok=1 prs_ok=1
  case "${refs:-}" in ''|*[!0-9]*) refs_ok=0 ;; esac
  case "${prs:-}" in ''|*[!0-9]*) prs_ok=0 ;; esac
  if [ "$refs_ok" = 0 ] || [ "$prs_ok" = 0 ]; then
    printf 'UNREAD  #%s — the link counts did not parse (branches=%s, closing PRs=%s)\n' \
      "$num" "${refs:-<absent>}" "${prs:-<absent>}"
    return 2
  fi

  if [ "$refs" -gt 0 ]; then
    printf 'LINKED  #%s (%s) — %s branch record(s) in issue.linkedBranches\n' "$num" "$state" "$refs"
    return 0
  fi
  if [ "$prs" -gt 0 ]; then
    printf 'LINKED  #%s (%s) — %s closing PR(s); the branch record is gone, and that is correct\n' "$num" "$state" "$prs"
    return 0
  fi
  printf 'NO LINK #%s (%s) — issue.linkedBranches is empty and no PR closes it\n' "$num" "$state"
  return 1
}

# ---- what to do about one --------------------------------------------------------
# Two different repairs, and the issue's own state decides which. An open issue can still be
# given the link the ordinary way; a closed one cannot — its merge event has already fired, so
# the only route left is the hand-attached link, which no API can make.
repair_note() {
  local state="$1"
  case "$state" in
    OPEN|open)
      echo "        Open: delete the ref if no PR heads it and re-run \`createLinkedBranch\`, or"
      echo "        open the PR with a \`Closes #NN\` line on its own last line, then read it back"
      echo "        with \`tools/verify-linked-branch.sh <NN> <branch>\`."
      ;;
    *)
      echo "        Closed: the merge event has already fired, so nothing binds now. Attach the"
      echo "        link by hand — PR → Development panel → the issue — which no API can do."
      ;;
  esac
}

# ---- live ------------------------------------------------------------------------
# ONE SEARCH, NOT AN ISSUE LIST AND THEN A CALL PER ISSUE. A checkpoint sweep over an arc's
# fifty issues would be fifty round trips, which is the shape nobody runs.
#
# EVERY READ THAT DECIDES A VERDICT IS CHECKED. An empty answer from a failed read is
# indistinguishable from an arc with no issues in it, and reporting the second when the first
# happened is the false negative this whole mechanism is about.
#
# Call it as `x="$(gh_read …)" || exit $?` — the `exit 2` runs in the command substitution's
# subshell and kills only that subshell, so the `|| exit` is what makes the guard real.
gh_read() {
  local what="$1"; shift
  local out
  if ! out="$(gh api graphql "$@" 2>&1)"; then
    echo "the $what read failed — cannot tell which issues are linked:" >&2
    printf '%s\n' "$out" >&2
    exit 2
  fi
  printf '%s' "$out"
}

live() {
  local milestone="$1"
  command -v gh >/dev/null 2>&1 || { echo "gh not on PATH" >&2; exit 2; }

  local nwo
  nwo="$(gh repo view --json nameWithOwner --jq .nameWithOwner 2>/dev/null)"
  [ -n "$nwo" ] || { echo "cannot read the repository from here" >&2; exit 2; }

  # `is:issue`, so pull requests never enter the sweep. A PR has no `linkedBranches` field and
  # would be reported as linked to nothing on every run.
  local q="repo:$nwo is:issue milestone:\"$milestone\""

  echo "arc-link-sweep — $nwo, milestone \`$milestone\`"
  echo

  local cursor="" page rows total=0 unlinked=0 unread=0
  while :; do
    page="$(gh_read "issue search" \
      -f query='query($q:String!,$after:String){search(query:$q,type:ISSUE,first:50,after:$after){pageInfo{hasNextPage endCursor} nodes{... on Issue{number state linkedBranches(first:1){totalCount} closedByPullRequestsReferences(first:1,includeClosedPrs:true){totalCount}}}}}' \
      -F q="$q" -F after="${cursor:-}" \
      --jq '.data.search.pageInfo.endCursor + "\t" + (.data.search.pageInfo.hasNextPage|tostring), (.data.search.nodes[]? | select(.number != null) | "\(.number)\t\(.state)\t\(.linkedBranches.totalCount)\t\(.closedByPullRequestsReferences.totalCount)")')" || exit $?

    local head
    head="$(printf '%s\n' "$page" | head -n1)"
    rows="$(printf '%s\n' "$page" | tail -n +2)"

    local num state refs prs out rc
    while IFS="$(printf '\t')" read -r num state refs prs; do
      [ -n "${num:-}" ] || continue
      total=$((total + 1))
      out="$(classify_issue "$num" "$state" "${refs:-}" "${prs:-}")"; rc=$?
      echo "  $out"
      if [ "$rc" = "1" ]; then
        unlinked=$((unlinked + 1))
        repair_note "$state"
      elif [ "$rc" = "2" ]; then
        unread=$((unread + 1))
      fi
    done <<EOF
$rows
EOF

    case "$head" in
      *"	true") cursor="${head%%	*}" ;;
      *) break ;;
    esac
    [ -n "$cursor" ] || break
  done

  echo
  if [ "$total" = "0" ]; then
    echo "no issues found in milestone \`$milestone\` — check the title, this is not a clean sweep"
    exit 2
  fi
  if [ "$unread" -gt 0 ]; then
    echo "$total issues, $unlinked linked to nothing, $unread unreadable"
    exit 2
  fi
  if [ "$unlinked" = "0" ]; then
    echo "$total issues, all linked to something"
    exit 0
  fi
  echo "$total issues, $unlinked linked to nothing"
  exit 1
}

# ---- selftest --------------------------------------------------------------------
# Cases inline: each is four short values, and a file per case would be more scaffolding than
# case.
#
# EVERY CASE ASSERTS THE MESSAGE, NOT ONLY THE EXIT CODE. Naming which field holds the link is
# the sweep's whole job, and an exit-code-only selftest passes with the two verdicts swapped.
selftest() {
  run=0; passed=0; failed=0

  ok()  { passed=$((passed + 1)); echo "  ok    $1"; }
  bad() { failed=$((failed + 1)); echo "  FAIL  $1"; }

  case_is() {
    local want="$1" want_text="$2" name="$3" num="$4" state="$5" refs="$6" prs="$7"
    run=$((run + 1))
    local out status
    out="$(classify_issue "$num" "$state" "$refs" "$prs")"; status=$?
    if [ "$status" != "$want" ]; then
      bad "$name — wanted exit $want, got $status: $out"; return
    fi
    if ! printf '%s' "$out" | grep -qF -- "$want_text"; then
      bad "$name — exit $status is right but the message never says \"$want_text\": $out"; return
    fi
    ok "$name — $out"
  }

  note_is() {
    local want="$1" forbid="$2" name="$3" state="$4"
    run=$((run + 1))
    local out
    out="$(repair_note "$state")"
    if ! printf '%s' "$out" | grep -qF -- "$want"; then
      bad "$name — the note never says \"$want\""; return
    fi
    if printf '%s' "$out" | grep -qF -- "$forbid"; then
      bad "$name — the note also says \"$forbid\", which it must not"; return
    fi
    ok "$name"
  }

  # A structural case, not a behavioural one. `gh_read`'s `exit 2` is inert unless the call site
  # propagates it, and that propagation cannot be exercised without a network. Anchored on a
  # real call site — a `--jq` line ending in the guard — so this file's own prose about the
  # guard cannot satisfy it.
  source_has() {
    local want="$1" count="$2" name="$3"
    run=$((run + 1))
    local got
    got="$(grep -cE -- "$want" "${BASH_SOURCE[0]}")"
    if [ "$got" = "$count" ]; then ok "$name"; else
      bad "$name — expected $count call site(s) matching /$want/, found $got"; fi
  }

  echo "arc-link-sweep selftest"
  echo

  # Before its PR exists, the branch record is the only evidence — and it is enough.
  case_is 0 "branch record"  "branch record only"   9 OPEN   1 0

  # After its PR exists, `linkedBranches` is empty and that is correct. #155's case, swept.
  case_is 0 "closing PR"     "promoted to a PR"     9 CLOSED 0 1

  # Both, which happens while a second branch is linked and a PR is already open on the first.
  case_is 0 "branch record"  "both fields"          9 OPEN   2 1

  # The finding this whole sweep exists for.
  case_is 1 "NO LINK"        "linked to nothing, open"   9 OPEN   0 0
  case_is 1 "NO LINK"        "linked to nothing, closed" 9 CLOSED 0 0

  # A read that did not parse is not a zero, and must not be reported as a missing link.
  case_is 2 "did not parse"  "counts unreadable"    9 OPEN   x 0
  case_is 2 "did not parse"  "both unreadable"      9 OPEN   x x

  # Empty is the one `*[!0-9]*` does not catch, and each half has to be asked separately — an
  # empty `refs` beside a `1` concatenates to a string that looks like a clean number.
  case_is 2 "did not parse"  "empty branch count"   9 OPEN   "" 1
  case_is 2 "did not parse"  "empty PR count"       9 OPEN   1 ""
  case_is 2 "did not parse"  "both empty"           9 OPEN   "" ""

  # The repair differs by state, and the closed one must not tell a run to do something that
  # cannot work — nothing binds after the merge event has fired.
  note_is "Development panel" "createLinkedBranch"  "a closed issue gets the click" CLOSED
  note_is "createLinkedBranch" "Development panel"  "an open issue gets the branch" OPEN

  # The guard that cannot be exercised offline.
  source_has '^[[:space:]]+--jq .*\)" \|\| exit \$\?$' 1 "the search read propagates a failed gh_read"

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
  '')        usage; exit 2 ;;
  *)         [ "$#" -eq 1 ] || { echo "too many arguments" >&2; usage; exit 2; }
             live "$1" ;;
esac
