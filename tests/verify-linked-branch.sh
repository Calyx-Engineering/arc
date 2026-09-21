#!/usr/bin/env bash
# verify-linked-branch.sh — read the branch↔issue link back after creating it.
#
#   tests/verify-linked-branch.sh <issue-number> <branch-name>
#   tests/verify-linked-branch.sh <issue-number>            # is this issue linked to anything?
#   tests/verify-linked-branch.sh selftest
#
# WHY. `createLinkedBranch` returns a `linkedBranch` node on success, and a run that reads that
# return value as evidence has verified nothing — the mutation reports what it was asked to do,
# not what the tracker now holds. #206 exists because a run took the mutation's word.
#
# THE LINK MOVES, AND THAT IS THE TRAP. Measured 2026-09-07, live:
#
#   moment                            issue.linkedBranches   the issue's closing PRs
#   after createLinkedBranch          the branch             (no PR yet)
#   after commits are pushed          the branch             (no PR yet)
#   after a force-push                the branch             (no PR yet)
#   after a PR is opened on the ref   EMPTY                  the PR
#   after that PR is closed again     EMPTY                  the PR
#   after the ref is deleted          EMPTY                  the PR
#
# Opening a PR from a linked branch PROMOTES the link: GitHub converts the branch record into
# the PR's closing reference and drops it from `linkedBranches`. The conversion is one-way —
# closing the PR does not give it back — and it needs no closing keyword in the body.
#
# CHECK IT AT BRANCH CREATION. THAT IS THE ONLY DECISIVE MOMENT. `closedByPullRequestsReferences`
# is fed by a keyword-parsed reference as well as a promoted one, and every arc PR is required to
# end with `Closes #NN`. So once the PR exists with that keyword in it, a branch made through the
# mutation and a branch made with `git checkout -b` are indistinguishable from the tracker —
# tested on #17, whose `git checkout -b` branch reads as linked through PR #139's keyword. The
# discriminator survives in exactly one case: a closing reference on a PR whose body carries NO
# keyword can only have come from the branch. This script reports which of the three it found.
#
# So `linkedBranches` reading empty is a defect BEFORE a PR exists and correct AFTER one does.
# Reading one field at one moment is how #155 concluded the mutation was broken when it was not.
#
# PASS <NN> AND <branch>, NOT <NN> ALONE. The one-argument form asks only "is this issue linked
# to anything at all", and promotion is permanent — an issue that ever had a closing PR answers
# yes forever, #206 included, which carries closed probe PR #219. Nothing detaches it: the whole
# mutation list was grepped 2026-09-07 and holds `createLinkedBranch` and `deleteLinkedBranch`
# only, both about branch records. Use the short form for a sweep hunting issues linked to
# NOTHING. To ask about a particular branch, name it.
#
# REPORTS, NEVER BLOCKS. Same precedent as every other verifier here. Exit 1 marks a finding;
# nothing denies a tool call. A read that could not be made exits 2, never 1 — "the link is
# missing" and "I could not tell" are different answers and only one is a defect. That
# distinction is the point: an unchecked read that comes back empty is #155's false negative
# with an exit code bolted on.

set -u

usage() {
  cat >&2 <<'USAGE'
usage:
  tests/verify-linked-branch.sh <issue-number> <branch-name>
  tests/verify-linked-branch.sh <issue-number>
  tests/verify-linked-branch.sh selftest
USAGE
}

# ---- the decision ----------------------------------------------------------------
# A pure function over two lists, so the selftest exercises the part that was wrong in #155 —
# which field is consulted — with no network and no repository.
#
#   $1  branch name, or empty to accept any link
#   $2  newline-separated refs from issue.linkedBranches
#   $3  newline-separated "<pr-number> <head-ref> <keyword|nokeyword>" from the issue's closing
#       PRs. The third column says whether that PR's body carries a closing keyword for this
#       issue, which is the only thing that separates a promoted link from a parsed one.
classify() {
  local branch="$1" refs="$2" prs="$3"

  if [ -n "$branch" ]; then
    if printf '%s\n' "$refs" | grep -qxF -- "$branch"; then
      echo "PASS  branch link — \`$branch\` is in issue.linkedBranches"
      return 0
    fi
    local line pr kw
    line="$(printf '%s\n' "$prs" | awk -v b="$branch" '$2 == b { print; exit }')"
    if [ -n "$line" ]; then
      pr="$(printf '%s' "$line" | awk '{print $1}')"
      kw="$(printf '%s' "$line" | awk '{print $3}')"
      if [ "$kw" = "nokeyword" ]; then
        echo "PASS  promoted link — PR #$pr heads \`$branch\` and closes this issue with no closing keyword in its body, so the link came from the branch"
      else
        echo "PASS  PR link — PR #$pr heads \`$branch\` and closes this issue. Its body carries a closing keyword, so promoted and parsed cannot be told apart — this does not confirm the branch was ever linked"
      fi
      return 0
    fi
    echo "FAIL  no link — \`$branch\` is in neither issue.linkedBranches nor a closing PR"
    return 1
  fi

  if [ -n "$(printf '%s' "$refs" | tr -d '[:space:]')" ]; then
    echo "PASS  branch link — $(printf '%s\n' "$refs" | grep -c .) in issue.linkedBranches"
    return 0
  fi
  if [ -n "$(printf '%s' "$prs" | tr -d '[:space:]')" ]; then
    echo "PASS  PR link — $(printf '%s\n' "$prs" | grep -c .) closing PR(s). Name a branch to ask about that branch"
    return 0
  fi
  echo "FAIL  no link — issue.linkedBranches is empty and no PR closes this issue"
  return 1
}

# ---- the keyword test ------------------------------------------------------------
# A closing reference on a PR whose body carries NO closing keyword can only have come from the
# branch, so this decides which verdict `classify` is allowed to give. GitHub parses FOUR
# reference forms, and recognising only `#NN` classifies the other three as `nokeyword` — which
# prints the one verdict this tool presents as decisive, wrongly:
#
#   Closes #206
#   Closes GH-206
#   Closes owner/repo#206
#   Closes https://github.com/owner/repo/issues/206
#
# The keyword vocabulary matches `tests/verify-tracker-body.sh`, deliberately: one list, tuned in
# one place.
#
#   $1  issue number   $2  body text
body_has_keyword() {
  local issue="$1" body="$2"
  printf '%s\n' "$body" | grep -Eqi \
    "(close[sd]?|fix(e[sd])?|resolve[sd]?)[[:space:]]+[^[:space:]]*(#|gh-|issues/)${issue}([^0-9]|$)"
}

# ---- the repair ------------------------------------------------------------------
# Which repair is safe depends on whether a PR already sits on the ref. GitHub closes a pull
# request whose head branch is deleted, so the obvious advice is the destructive one at exactly
# the moment an unattended run is most likely to follow it. Not measured here — the advice is
# conservative BECAUSE it is unmeasured, and run-instructions §7 records the tested neighbour,
# that RENAMING the branch of an open PR closes it.
#
#   $1  branch name
#   $2  newline-separated "<pr-number>" for OPEN PRs on that ref, closing this issue or not,
#       or the literal `unknown` if that read could not be made
repair_note() {
  local branch="$1" on_ref="$2"
  echo
  if [ -z "$branch" ]; then
    echo "      No branch was named, so there is no ref to advise about. This issue is linked to"
    echo "      nothing: no branch record and no closing PR. Cut the branch with"
    echo "      \`createLinkedBranch\` and read this back before the PR exists."
  elif [ "$on_ref" = "unknown" ]; then
    echo "      DO NOT delete this ref. Whether a PR heads it could not be read, and deleting the"
    echo "      head branch of an open PR closes that PR. Bind from the PR side instead: a"
    echo "      \`Closes #NN\` line on its own last line, then read this back again."
  elif [ -n "$(printf '%s' "$on_ref" | tr -d '[:space:]')" ]; then
    echo "      DO NOT delete this ref. $(printf '%s\n' "$on_ref" | awk 'NF{printf "#%s ", $1}')head(s) it, and"
    echo "      deleting the head branch of an open PR closes that PR. Bind from the PR side"
    echo "      instead: a \`Closes #NN\` line on its own last line, then read this back again."
  else
    echo "      No open PR heads \`$branch\`. The mutation cannot link a branch that already exists,"
    echo "      so there is no retry — delete the ref and re-run \`createLinkedBranch\`, or open the"
    echo "      PR with a \`Closes #NN\` line on its own last line, then read this back again."
  fi
}

# ---- live ------------------------------------------------------------------------
# EVERY READ THAT DECIDES THE VERDICT IS CHECKED, because an empty answer from a failed read is
# indistinguishable from a missing link.
#
# `closedByPullRequestsReferences` is asked of the ISSUE, not swept from `gh pr list`. A sweep
# needs a `--limit`, and any link promoted to a PR older than that window would read as absent —
# the same false negative in a new place.
#
# CALL IT AS `x="$(gh_read …)" || exit $?`. Its `exit 2` runs inside the command substitution's
# subshell and kills only that subshell — the caller carries on with an empty string, which is
# the very confusion this wrapper exists to prevent. The status does propagate as the
# substitution's own, so the `|| exit` is what makes the guard real. Proven, not assumed; the
# first draft of this file omitted it and was inert.
gh_read() {
  local what="$1"; shift
  local out
  if ! out="$(gh api graphql "$@" 2>&1)"; then
    echo "the $what read failed — cannot tell whether the link formed:" >&2
    printf '%s\n' "$out" >&2
    exit 2
  fi
  printf '%s' "$out"
}

live() {
  local issue="$1" branch="${2:-}"
  command -v gh >/dev/null 2>&1 || { echo "gh not on PATH" >&2; exit 2; }

  local nwo owner repo
  nwo="$(gh repo view --json nameWithOwner --jq .nameWithOwner 2>/dev/null)"
  [ -n "$nwo" ] || { echo "cannot read the repository from here" >&2; exit 2; }
  owner="${nwo%%/*}"; repo="${nwo##*/}"

  local refs prs on_ref
  refs="$(gh_read "linkedBranches" \
    -f query='query($o:String!,$r:String!,$n:Int!){repository(owner:$o,name:$r){issue(number:$n){linkedBranches(first:50){nodes{ref{name}}}}}}' \
    -F o="$owner" -F r="$repo" -F n="$issue" \
    --jq '.data.repository.issue.linkedBranches.nodes[]?.ref.name')" || exit $?

  prs="$(gh_read "closing PRs" \
    -f query='query($o:String!,$r:String!,$n:Int!){repository(owner:$o,name:$r){issue(number:$n){closedByPullRequestsReferences(first:50,includeClosedPrs:true){nodes{number headRefName body}}}}}' \
    -F o="$owner" -F r="$repo" -F n="$issue" \
    --jq '.data.repository.issue.closedByPullRequestsReferences.nodes[]? | "\(.number) \(.headRefName) \(.body // "" | @base64)"')" || exit $?

  # The body arrives base64-encoded so that one PR stays on one line whatever the body contains.
  # The keyword test itself is shell rather than jq, so the selftest can exercise it — GitHub
  # parses four reference forms and the first draft of this file recognised one.
  prs="$(printf '%s\n' "$prs" | while IFS=' ' read -r num ref b64; do
    [ -n "${num:-}" ] || continue
    if body_has_keyword "$issue" "$(printf '%s' "${b64:-}" | base64 -d 2>/dev/null)"; then
      printf '%s %s keyword\n' "$num" "$ref"
    else
      printf '%s %s nokeyword\n' "$num" "$ref"
    fi
  done)"

  # ADVICE ONLY, SO ITS FAILURE MUST NOT SUPPRESS A VERDICT THE OTHER TWO ALREADY DECIDED. It
  # degrades to `unknown`, which repair_note reads as "assume a PR heads it" — the safe side.
  on_ref=""
  if [ -n "$branch" ]; then
    on_ref="$(gh_read "PRs on the ref" \
      -f query='query($o:String!,$r:String!,$b:String!){repository(owner:$o,name:$r){ref(qualifiedName:$b){associatedPullRequests(first:20,states:[OPEN]){nodes{number}}}}}' \
      -F o="$owner" -F r="$repo" -F b="refs/heads/$branch" \
      --jq '.data.repository.ref?.associatedPullRequests.nodes[]?.number')" || on_ref="unknown"
  fi

  echo "issue #$issue in $nwo"
  [ -n "$branch" ] && echo "branch  $branch"
  echo

  if classify "$branch" "$refs" "$prs"; then
    exit 0
  fi
  repair_note "$branch" "$on_ref"
  exit 1
}

# ---- selftest --------------------------------------------------------------------
# Cases live inline rather than in a fixtures directory: each is two short lists, and a file per
# case would be more scaffolding than case.
#
# EVERY CASE ASSERTS THE MESSAGE, NOT ONLY THE EXIT CODE. Naming which field holds the link is
# the tool's whole job, and an exit-code-only selftest passes with the two verdicts swapped.
# `note_is` asserts an absence as well as a presence, because a repair_note printing BOTH
# branches would satisfy a presence-only check while telling a run to delete a ref an open PR
# stands on.
selftest() {
  run=0; passed=0; failed=0

  ok()   { passed=$((passed + 1)); echo "  ok    $1"; }
  bad()  { failed=$((failed + 1)); echo "  FAIL  $1"; }

  case_is() {
    local want="$1" want_text="$2" name="$3" branch="$4" refs="$5" prs="$6"
    run=$((run + 1))
    local out status
    out="$(classify "$branch" "$refs" "$prs")"; status=$?
    if [ "$status" != "$want" ]; then
      bad "$name — wanted exit $want, got $status: $out"; return
    fi
    if ! printf '%s' "$out" | grep -qF -- "$want_text"; then
      bad "$name — exit $status is right but the message never says \"$want_text\": $out"; return
    fi
    ok "$name — $out"
  }

  note_is() {
    local want="$1" forbid="$2" name="$3" branch="$4" on_ref="$5"
    run=$((run + 1))
    local out
    out="$(repair_note "$branch" "$on_ref")"
    if ! printf '%s' "$out" | grep -qF -- "$want"; then
      bad "$name — the note never says \"$want\""; return
    fi
    if printf '%s' "$out" | grep -qF -- "$forbid"; then
      bad "$name — the note also says \"$forbid\", which it must not"; return
    fi
    ok "$name"
  }

  kw_is() {
    local want="$1" name="$2" issue="$3" body="$4"
    run=$((run + 1))
    local status
    if body_has_keyword "$issue" "$body"; then status=0; else status=1; fi
    if [ "$status" = "$want" ]; then ok "keyword: $name"; else
      bad "keyword: $name — wanted $([ "$want" = 0 ] && echo found || echo "not found"), got the other"; fi
  }

  # A structural case, not a behavioural one. `gh_read`'s `exit 2` is inert unless every call
  # site propagates it, that propagation cannot be exercised without a network, and the first
  # draft of this file shipped without it. So the check is that the call sites still carry it.
  # The pattern is anchored to a real call site — a `--jq` line ending in the guard — so that
  # this file's own prose about the guard, and this case's own arguments, cannot satisfy it.
  source_has() {
    local want="$1" count="$2" name="$3"
    run=$((run + 1))
    local got
    got="$(grep -cE -- "$want" "${BASH_SOURCE[0]}")"
    if [ "$got" = "$count" ]; then ok "$name"; else
      bad "$name — expected $count call site(s) matching /$want/, found $got"; fi
  }

  echo "verify-linked-branch selftest"
  echo

  # Before a PR exists, the branch record is the only evidence.
  case_is 0 "branch link"   "fresh mutation"      "arc/x-issue-9-a" "arc/x-issue-9-a" ""
  case_is 1 "no link"       "mutation lied"       "arc/x-issue-9-a" ""                ""

  # After a PR exists, linkedBranches is empty and that is correct. This is #155's case: the run
  # read an empty list at pass 4 and called the mutation broken.
  case_is 0 "promoted link" "promoted, no keyword" "arc/x-issue-9-a" "" "42 arc/x-issue-9-a nokeyword"

  # With a keyword in the body the two are indistinguishable, and saying so is the point — a
  # `git checkout -b` branch reaches exactly this state.
  case_is 0 "cannot be told apart" "keyworded, so undecidable" "arc/x-issue-9-a" "" "42 arc/x-issue-9-a keyword"

  # A closing PR on some other branch does not vouch for this one.
  case_is 1 "no link"       "wrong head branch"   "arc/x-issue-9-a" "" "42 arc/x-issue-9-b nokeyword"

  # A named branch must match exactly — a prefix is a different branch.
  case_is 1 "no link"       "prefix is not match" "arc/x-issue-9-a" "arc/x-issue-9-ab" ""

  # A name that looks like an option is matched, not parsed.
  case_is 0 "branch link"   "leading dash"        "-weird-branch"   "-weird-branch"   ""

  # Several links, one of which is ours.
  case_is 0 "branch link"   "one of several"      "arc/x-issue-9-a" "arc/x-issue-9-z
arc/x-issue-9-a" ""

  # No branch named: any link at all passes, none fails.
  case_is 0 "branch link"   "unnamed, branch"     "" "arc/x-issue-9-a" ""
  case_is 0 "PR link"       "unnamed, promoted"   "" "" "42 arc/x-issue-9-a nokeyword"
  case_is 1 "no link"       "unnamed, nothing"    "" "" ""

  # The advice must never tell a run to delete a ref an open PR is built on, and must not hedge
  # both ways when the ref is free.
  note_is "DO NOT delete this ref"    "delete the ref and re-run" "an open PR on the ref"      "arc/x-issue-9-a" "42"
  note_is "DO NOT delete this ref"    "delete the ref and re-run" "the ref read failed"        "arc/x-issue-9-a" "unknown"
  note_is "delete the ref and re-run" "DO NOT delete this ref"    "the ref is free"            "arc/x-issue-9-a" ""
  note_is "No branch was named"       "delete the ref and re-run" "no branch was named at all" ""                ""

  # All four reference forms GitHub parses. Missing one of them turns a keyworded PR into the
  # `nokeyword` reading, which is the strongest claim this tool makes.
  kw_is 0 "hash form"      206 "Some prose.

Closes #206"
  kw_is 0 "GH- form"       206 "Closes GH-206"
  kw_is 0 "owner/repo form" 206 "Fixes Calyx-Engineering/arc#206"
  kw_is 0 "URL form"       206 "Resolves https://github.com/Calyx-Engineering/arc/issues/206"
  kw_is 0 "lowercase verb" 206 "resolved #206"
  kw_is 1 "no keyword"     206 "Throwaway probe. No issue reference in this body at all."
  kw_is 1 "bare mention"   206 "Follows on from #206, but does not close it"
  kw_is 1 "another issue"  206 "Closes #2061"
  kw_is 1 "empty body"     206 ""

  # The guard that cannot be exercised offline.
  source_has '^[[:space:]]+--jq .*\)" \|\| exit \$\?$' 2 "both verdict reads propagate a failed gh_read"
  source_has '^[[:space:]]+--jq .*\)" \|\| on_ref="unknown"$' 1 "the advice read degrades instead of exiting"

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
  *[!0-9]*)  usage; exit 2 ;;
  *)
    [ "$#" -le 2 ] || { echo "too many arguments" >&2; usage; exit 2; }
    live "$1" "${2:-}" ;;
esac
