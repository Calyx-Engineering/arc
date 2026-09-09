#!/usr/bin/env bash
# arc-claim.sh — one dispatcher's claim on one issue, held in GitHub.
#
#   tools/arc-claim.sh take <issue>              claim it; prints the token, exit 1 if lost
#   tools/arc-claim.sh release <issue> <token>   drop the claim
#   tools/arc-claim.sh refresh <issue> <token>   push the expiry out — the heartbeat
#   tools/arc-claim.sh check <issue>             read-only: free, mine, or held by whom
#   tools/arc-claim.sh claimed <parent>          read-only: open sub-issues under a live claim
#   tools/arc-claim.sh selftest
#
# WHY. `tools/arc-loop.sh` holds its position in GitHub state alone — which sub-issues are still
# open — and nothing claims one. On 2026-09-07 two dispatchers read the same open list and both
# picked #158. One cut the linked branch, built the tool and measured; the other committed that
# working tree, wrote the dev-log, opened PR #212 and merged it while the first was still
# probing. Nothing was lost, but the dev-log shipped single-run numbers the still-running probe
# was in the middle of disproving. #214.
#
# THE CLAIM IS AN ISSUE COMMENT, and the alternatives were rejected for the same reason:
#
#   assignee   two dispatchers run as the SAME GitHub user, so an assignee cannot tell "mine"
#              from "theirs" — the one question a claim has to answer
#   a label    same, plus no room for a timestamp. `in-progress` is out twice over: PR #200 gave
#              it a human-facing contract, and it is set after selection rather than before it
#   a lockfile a lock on one machine is invisible to a dispatcher on another, and #214's
#              constraint is that position lives in GitHub so the loop can be killed and restarted
#
# A comment carries an owner token, a timestamp and a TTL in its own body, has a monotonic id
# that settles a race, and can be deleted — so a released claim leaves the issue as it found it.
#
# HOW THE RACE IS SETTLED. Posting is not atomic, so `take` posts first and reads second: it
# writes its claim, re-reads every comment, and the LIVE claim with the LOWEST comment id wins.
# A dispatcher that finds itself second deletes its own comment and reports the loss. That is
# decisive rather than hopeful:
#
#   each dispatcher reads after its own post          post_X < read_X, by construction
#   comment ids are monotonic and the list is         so with post_A < post_B,
#   read-after-write consistent per issue             post_A < post_B < read_B
#   therefore the later poster always sees the        B withdraws; A never sees B ahead of it
#   earlier one
#
# The case both dispatchers win needs both reads to precede both posts, which the first line
# forbids. `ARC_CLAIM_SETTLE` (default 2s) sits between the post and the read anyway, against
# replication lag on the read path, which is the assumption above and not a theorem.
#
# A STALE CLAIM EXPIRES. The body carries `epoch` and `ttl`; a claim is live while
# `epoch + ttl > now`. An expired claim is ignored by every read, and `take` — the only command
# that reaps — deletes the ones it finds on its way past. So a dispatcher killed mid-run leaks
# nothing beyond one TTL — the failure mode a lock without an expiry has, where one crash locks
# an issue until a human notices.
#
# The holder pushes its own expiry out with `refresh`, which `tools/arc-loop.sh` calls from the
# poll loop it is already running. TTL is therefore "how long after the dispatcher dies before
# the issue is free", not "how long a run may take".
#
# WHAT THIS CANNOT DO. It interlocks DISPATCHERS, not runs. A run is a detached `claude -p`
# that outlives the shell that launched it, by design — so a dispatcher killed while its run
# keeps working stops refreshing, and after one TTL another dispatcher may take an issue that
# is still being worked. That is strictly better than no claim at all and it is not nothing;
# `--status` shows the live run, and the fix if it bites is a longer TTL, not a lock without one.
# It also does not stop a human running two `claude -p` sessions by hand.
#
# NOT DECLARED `mode-guard: writes-outward`. The guard's contract is commit, push, PR and merge
# — #201. A claim comment is bookkeeping that deletes itself, `check` and `claimed` are reads,
# and declaring the file would deny those reads in manual mode. The caller that dispatches work,
# `tools/arc-loop.sh`, is declared, and that is where the gate belongs.
#
#   0  the claim is ours (take, refresh), or the issue is free (check)
#   1  someone else holds it — a verdict, not a failure
#   2  the read or write could not be made, or the arguments were wrong. NEVER 1: "another
#      dispatcher holds this" and "I could not tell" are different answers. Same distinction
#      tools/verify-linked-branch.sh draws, for the same reason
#
# THE FIXTURE BACKEND. `ARC_CLAIM_FIXTURES=<dir>` swaps every `gh` call for files of the same
# shape — and the files are WRITTEN as well as read, so the selftest drives take, refresh,
# release and the race end to end with no network and no issue. `ARC_CLAIM_NOW` fixes the clock
# so expiry is a case rather than a wait. The precedent is tools/verify-issue-boxes.sh.
#
#   comments-<N>.tsv   one comment per line: <id><TAB><base64 body>
#   nextid             the id the next posted comment gets; monotonic, as GitHub's are
#   children-<P>       open sub-issue numbers of parent <P>, one per line

set -u

SELF="${BASH_SOURCE[0]}"

usage() {
  cat >&2 <<'USAGE'
usage:
  tools/arc-claim.sh take <issue>
  tools/arc-claim.sh release <issue> <token>
  tools/arc-claim.sh refresh <issue> <token>
  tools/arc-claim.sh check <issue>
  tools/arc-claim.sh claimed <parent>
  tools/arc-claim.sh selftest
USAGE
}

TTL="${ARC_CLAIM_TTL:-1800}"
SETTLE="${ARC_CLAIM_SETTLE:-2}"
FIXTURES="${ARC_CLAIM_FIXTURES:-}"

now() { printf '%s' "${ARC_CLAIM_NOW:-$(date -u +%s)}"; }

# The owner token names this DISPATCHER PROCESS, not the GitHub account — two dispatchers share
# an account, which is why the account cannot be the identity. The random tail is what stops a
# restarted loop on the same host and pid from inheriting its predecessor's claim.
mint_token() {
  local host rnd
  host="$(hostname 2>/dev/null | tr -cd 'A-Za-z0-9.-')"
  [ -n "$host" ] || host="unknown"
  rnd="$( (od -An -N4 -tx1 /dev/urandom 2>/dev/null || echo "$RANDOM $RANDOM") | tr -cd 'a-f0-9' )"
  [ -n "$rnd" ] || rnd="$$"
  printf '%s/%s/%s' "$host" "$$" "${rnd:0:8}"
}

# ---- the marker ------------------------------------------------------------------
# One HTML comment, so the claim is machine-readable and invisible in rendered markdown, and the
# prose above it is for whoever opens the issue. Everything the decision needs is in the marker:
# an integer clock rather than a date, so no case has to parse one.
MARKER_RE='<!-- arc-claim v1 owner=([A-Za-z0-9._/-]+) epoch=([0-9]+) ttl=([0-9]+) -->'

claim_body() {  # claim_body <owner> <epoch> <ttl>
  local owner="$1" epoch="$2" ttl="$3" until
  until="$(iso "$((epoch + ttl))")"
  cat <<BODY
**Claimed by \`tools/arc-loop.sh\`** — dispatcher \`$owner\`, held until $until.

Another dispatcher skips this issue while the claim is live, and takes it if the claim expires.
The claim is removed when the run ends. It is not a status: \`in-progress\` is that.

<!-- arc-claim v1 owner=$owner epoch=$epoch ttl=$ttl -->
BODY
}

iso() { date -u -d "@$1" +%FT%TZ 2>/dev/null || printf 'epoch %s' "$1"; }

# settle <value> — the pause between the post and the read-back. `0` means none; a whole number
# of seconds is slept; anything else `sleep` understands (`20s`, `0.5`) is slept and said out
# loud, because an integer test on it is an error rather than a false and would skip the pause.
settle() {
  case "$1" in
    0|0s) return 0 ;;
    *[!0-9]*) echo "arc-claim: ARC_CLAIM_SETTLE=$1 is not a whole number of seconds" >&2
              sleep "$1" || echo "arc-claim: sleep $1 failed — the read-back is not settled" >&2
              return 0 ;;
    '') return 0 ;;
    *) sleep "$1"; return 0 ;;
  esac
}

# parse_marker <body> — prints "<owner> <epoch> <ttl>" if the body carries a claim, else nothing.
# A body with no marker is an ordinary comment and must produce no line at all: a claim tool that
# reads every comment as a claim locks an issue the moment somebody talks on it.
parse_marker() {
  printf '%s\n' "$1" | sed -nE "s/.*${MARKER_RE}.*/\1 \2 \3/p" | head -n1
}

# ---- the decision ----------------------------------------------------------------
# Pure functions over one list, so the cases that matter — two dispatchers racing, an expired
# claim, our own claim read back — run with no network and no fixture.
#
#   claims: newline-separated "<comment-id> <owner> <epoch> <ttl>"

live_claims() {  # live_claims <now> <claims>
  printf '%s\n' "$2" | awk -v now="$1" 'NF==4 && ($3 + $4) > now' | sort -n -k1,1
}

stale_claims() {  # stale_claims <now> <claims>
  printf '%s\n' "$2" | awk -v now="$1" 'NF==4 && ($3 + $4) <= now' | sort -n -k1,1
}

# verdict <now> <self-token-or-empty> <claims> — the whole interlock, in one place.
#   0  free / mine        1  held by another
verdict() {
  local now="$1" self="$2" claims="$3" live winner id owner epoch ttl
  live="$(live_claims "$now" "$claims")"
  if [ -z "$(printf '%s' "$live" | tr -d '[:space:]')" ]; then
    echo "free"
    return 0
  fi
  # THE LOWEST LIVE COMMENT ID WINS, and nothing else is consulted. Not the earliest epoch: a
  # refresh rewrites the epoch, so a holder that heartbeats once would hand the issue to the
  # dispatcher that arrived after it.
  winner="$(printf '%s\n' "$live" | head -n1)"
  id="$(printf '%s' "$winner" | awk '{print $1}')"
  owner="$(printf '%s' "$winner" | awk '{print $2}')"
  epoch="$(printf '%s' "$winner" | awk '{print $3}')"
  ttl="$(printf '%s' "$winner" | awk '{print $4}')"
  if [ -n "$self" ] && [ "$owner" = "$self" ]; then
    echo "mine  comment $id, held until $(iso "$((epoch + ttl))")"
    return 0
  fi
  echo "held  by $owner — comment $id, until $(iso "$((epoch + ttl))")"
  return 1
}

# ---- the backend -----------------------------------------------------------------
# Every read that decides a verdict is checked. An empty answer from a failed read is
# indistinguishable from an unclaimed issue, and that confusion is the whole defect this file is
# about — so a read that could not be made exits 2 rather than reporting "free".

fail() { echo "arc-claim: $*" >&2; exit 2; }

NWO=""
repo_nwo() {
  [ -n "$NWO" ] && { printf '%s' "$NWO"; return 0; }
  command -v gh >/dev/null 2>&1 || fail "gh not on PATH"
  NWO="$(gh repo view --json nameWithOwner --jq .nameWithOwner 2>/dev/null)"
  [ -n "$NWO" ] || fail "cannot read the repository from here"
  printf '%s' "$NWO"
}

fx() { printf '%s/%s' "$FIXTURES" "$1"; }

# read_comments <issue> — "<id><TAB><base64 body>" per comment, oldest id first.
read_comments() {
  if [ -n "$FIXTURES" ]; then
    # VERBATIM, not `sort`. The decision sorts for itself, and `sort` TERMINATES its output —
    # which is what hid the dropped-last-comment bug below from every case here.
    [ -f "$(fx "comments-$1.tsv")" ] && cat "$(fx "comments-$1.tsv")"
    return 0
  fi
  local nwo out
  nwo="$(repo_nwo)"
  if ! out="$(gh api --paginate "repos/$nwo/issues/$1/comments" \
       --jq '.[] | "\(.id)\t\(.body | @base64)"' 2>&1)"; then
    echo "$out" >&2
    fail "could not read the comments on #$1 — cannot tell whether it is claimed"
  fi
  printf '%s' "$out"
  return 0
}

post_comment() {  # post_comment <issue> <body> — prints the new comment id
  if [ -n "$FIXTURES" ]; then
    local id f
    f="$(fx nextid)"
    id="$(cat "$f" 2>/dev/null || echo 1000)"
    printf '%s\n' "$((id + 1))" > "$f"
    printf '%s\t%s\n' "$id" "$(printf '%s' "$2" | base64 | tr -d '\n')" >> "$(fx "comments-$1.tsv")"
    # FIXTURE ONLY. A hook that fires between the post and the read-back, so a case can make a
    # COMPETING claim appear exactly there. That is the one interleaving the pre-check cannot
    # short-circuit, and therefore the only one that exercises the read-back at all.
    [ -n "${ARC_CLAIM_AFTER_POST:-}" ] && eval "$ARC_CLAIM_AFTER_POST"
    printf '%s' "$id"
    return 0
  fi
  local nwo out
  nwo="$(repo_nwo)"
  if ! out="$(gh api -X POST "repos/$nwo/issues/$1/comments" -f body="$2" --jq .id 2>&1)"; then
    echo "$out" >&2
    fail "could not post the claim on #$1"
  fi
  printf '%s' "$out"
}

delete_comment() {  # delete_comment <issue> <comment-id>
  if [ -n "$FIXTURES" ]; then
    local f t
    f="$(fx "comments-$1.tsv")"
    [ -f "$f" ] || return 0
    t="$f.tmp"
    awk -v id="$2" -F'\t' '$1 != id' "$f" > "$t" && mv -f "$t" "$f"
    return 0
  fi
  local nwo
  nwo="$(repo_nwo)"
  # A DELETE THAT FAILS IS REPORTED AND NOT FATAL. The claim expires on its own, so a failed
  # release costs one TTL; exiting 2 here would take a finished run's exit code with it.
  gh api -X DELETE "repos/$nwo/issues/comments/$2" >/dev/null 2>&1 \
    || echo "arc-claim: could not delete comment $2 on #$1 — it expires on its own" >&2
  return 0
}

patch_comment() {  # patch_comment <issue> <comment-id> <body>
  if [ -n "$FIXTURES" ]; then
    local f t
    f="$(fx "comments-$1.tsv")"
    [ -f "$f" ] || return 1
    t="$f.tmp"
    awk -v id="$2" -v b="$(printf '%s' "$3" | base64 | tr -d '\n')" -F'\t' \
      '{ if ($1 == id) print $1 "\t" b; else print }' "$f" > "$t" && mv -f "$t" "$f"
    return 0
  fi
  local nwo
  nwo="$(repo_nwo)"
  gh api -X PATCH "repos/$nwo/issues/comments/$2" -f body="$3" >/dev/null 2>&1 || return 1
  return 0
}

# claims_on <issue> — the decision's input: "<id> <owner> <epoch> <ttl>" per claim comment.
#
# IT RETURNS 2 WHEN THE READ FAILED, and every caller propagates that. `read_comments` cannot do
# it alone: as the left side of a pipeline its `exit 2` kills only that subshell, so `claims_on`
# returned 0 with empty output and every caller read "nobody holds it" — #214's own defect,
# reachable through one rate limit. The read is therefore assigned first and piped second.
#
# `printf '%s'`, NOT `'%s\n'`: command substitution has already stripped the trailing newline, so
# the last comment arrives unterminated and `|| [ -n "$id" ]` is the only thing that reads it.
# Dropping that guard drops the NEWEST claim — the one a race turns on. 2026-09-08.
claims_on() {
  local raw line id b64
  raw="$(read_comments "$1")" || return 2
  printf '%s' "$raw" | while IFS=$'\t' read -r id b64 || [ -n "${id:-}" ]; do
    [ -n "${id:-}" ] || continue
    line="$(parse_marker "$(printf '%s' "${b64:-}" | base64 -d 2>/dev/null)")"
    [ -n "$line" ] && printf '%s %s\n' "$id" "$line"
  done
  # EXPLICIT. A `while` loop's status is that of the last command in its body, and the last body
  # line is an `&&` that is false for any comment that is not a claim — so an issue with one
  # ordinary comment at the end made this function report a failed read.
  return 0
}

# reap <issue> <claims> <now> — delete the expired ones. Hygiene, not correctness: an expired
# claim is already ignored. Left alone they pile up on a long-lived issue.
reap() {
  local id
  for id in $(stale_claims "$3" "$2" | awk '{print $1}'); do
    echo "  reaped an expired claim — comment $id on #$1" >&2
    delete_comment "$1" "$id"
  done
  return 0
}

# ---- commands --------------------------------------------------------------------

cmd_take() {  # cmd_take <issue>
  local issue="$1" self t n claims out status id
  self="${ARC_CLAIM_OWNER:-$(mint_token)}"
  t="$(now)"

  # Look before posting, so the common case — an issue somebody else already holds — costs one
  # read and leaves no comment behind.
  claims="$(claims_on "$issue")" || exit 2
  reap "$issue" "$claims" "$t"
  if ! out="$(verdict "$t" "$self" "$(live_claims "$t" "$claims")")"; then
    echo "#$issue $out" >&2
    return 1
  fi

  post_comment "$issue" "$(claim_body "$self" "$t" "$TTL")" >/dev/null
  # `[ "20s" -gt 0 ]` is an ERROR, not a false — so `2>/dev/null &&` silently skipped the settle
  # window for any value `sleep` would have accepted, and the guard against read-path replication
  # lag disappeared without a word. Same defect class tools/arc-loop.sh's sleep_heartbeat fixes.
  settle "$SETTLE"

  # THE READ-BACK IS THE INTERLOCK. The post's own return value says what we asked for, not what
  # the issue now holds — the same lesson tools/verify-linked-branch.sh is built on.
  claims="$(claims_on "$issue")" || exit 2
  n="$(now)"
  out="$(verdict "$n" "$self" "$claims")"; status=$?
  if [ "$status" != 0 ]; then
    echo "#$issue $out — withdrawing" >&2
    for id in $(live_claims "$n" "$claims" | awk -v s="$self" '$2 == s {print $1}'); do
      delete_comment "$issue" "$id"
    done
    return 1
  fi
  printf '%s\n' "$self"
  return 0
}

cmd_release() {  # cmd_release <issue> <token>
  local id found=0 claims
  claims="$(claims_on "$1")" || exit 2
  for id in $(printf '%s\n' "$claims" | awk -v s="$2" '$2 == s {print $1}'); do
    delete_comment "$1" "$id"
    found=1
  done
  [ "$found" = 1 ] || echo "arc-claim: no claim by $2 on #$1 — already released or expired" >&2
  return 0
}

cmd_refresh() {  # cmd_refresh <issue> <token>
  local id t ok=0 claims
  t="$(now)"
  claims="$(claims_on "$1")" || exit 2
  for id in $(live_claims "$t" "$claims" | awk -v s="$2" '$2 == s {print $1}'); do
    patch_comment "$1" "$id" "$(claim_body "$2" "$t" "$TTL")" && ok=1
  done
  # A HEARTBEAT THAT FINDS NO CLAIM IS A FINDING, not a no-op: it means the claim was reaped or
  # deleted while the run was working, and whoever is waiting on it needs to know.
  [ "$ok" = 1 ] || { echo "arc-claim: no live claim by $2 on #$1 to refresh" >&2; return 1; }
  return 0
}

cmd_check() {  # cmd_check <issue>
  local t out status claims
  t="$(now)"
  claims="$(claims_on "$1")" || exit 2
  out="$(verdict "$t" "${ARC_CLAIM_OWNER:-}" "$claims")"; status=$?
  echo "#$1 $out"
  return $status
}

# cmd_claimed <parent> — the numbers a dispatcher must skip. One GraphQL call for every open
# sub-issue and its comments: selection runs this once per pass, not once per candidate.
#
# IT IS A PRE-FILTER, NOT THE INTERLOCK, and it has two windows. `comments(last:100)`: an issue
# whose own run has commented a hundred times since the claim was posted pushes it out of view.
# `subIssues(first:50)`: a workstream with more children than that under-reports — the same cap
# `open_child_rows` in tools/arc-loop.sh selects through, so the two at least agree.
#
# Either miss reports an issue free that is not. `take` reads every comment with `--paginate` and
# is what actually decides, so the cost is a wasted selection, never a second dispatcher.
cmd_claimed() {
  local parent="$1" t rows nwo owner repo
  t="$(now)"
  if [ -n "$FIXTURES" ]; then
    local n c
    for n in $(cat "$(fx "children-$parent")" 2>/dev/null); do
      c="$(claims_on "$n")" || exit 2
      live_claims "$t" "$c" | head -n1 | awk -v n="$n" 'NF{print n, $2}'
    done
    return 0
  fi
  nwo="$(repo_nwo)"; owner="${nwo%%/*}"; repo="${nwo##*/}"
  if ! rows="$(gh api graphql \
      -f query='query($o:String!,$r:String!,$n:Int!){repository(owner:$o,name:$r){issue(number:$n){subIssues(first:50){nodes{number state comments(last:100){nodes{databaseId body}}}}}}}' \
      -F o="$owner" -F r="$repo" -F n="$parent" \
      --jq '.data.repository.issue.subIssues.nodes[] | select(.state=="OPEN") | . as $i | .comments.nodes[]? | "\($i.number) \(.databaseId) \(.body | @base64)"' 2>&1)"; then
    echo "$rows" >&2
    fail "could not read the sub-issues of #$parent — cannot tell which are claimed"
  fi
  printf '%s\n' "$rows" | awk 'NF' | while read -r n id b64; do
    local m
    m="$(parse_marker "$(printf '%s' "$b64" | base64 -d 2>/dev/null)")"
    [ -n "$m" ] && printf '%s %s %s\n' "$n" "$id" "$m"
  done | sort -n -k1,1 -k2,2 | awk -v now="$t" '($4 + $5) > now { if (!seen[$1]++) print $1, $3 }'
}

# ---- selftest --------------------------------------------------------------------
# THE WHOLE SCRIPT, NOT ONLY THE DECISION. The pure cases pin the race and expiry rules; the
# fixture cases drive take, refresh and release through the same argument parsing and exit codes
# a live run uses. #214 asks for four cases by name and each is labelled below.
selftest() {
  local run=0 passed=0 failed=0 TMP out status
  ok()  { passed=$((passed + 1)); echo "  ok    $1"; }
  bad() { failed=$((failed + 1)); echo "  FAIL  $1"; }

  # verdict_is <want-exit> <want-text> <name> <now> <self> <claims>
  verdict_is() {
    run=$((run + 1))
    local out status
    out="$(verdict "$4" "$5" "$6")"; status=$?
    if [ "$status" != "$1" ]; then bad "$3 — wanted exit $1, got $status: $out"; return; fi
    if ! printf '%s' "$out" | grep -qF -- "$2"; then
      bad "$3 — exit $status is right but the message never says \"$2\": $out"; return; fi
    ok "$3 — $out"
  }

  marker_is() {  # marker_is <want> <name> <body>
    run=$((run + 1))
    local got; got="$(parse_marker "$3")"
    if [ "$got" = "$1" ]; then ok "marker: $2"; else
      bad "marker: $2 — wanted \"$1\", got \"$got\""; fi
  }

  echo "arc-claim selftest"
  echo

  # ---- the decision -------------------------------------------------------------
  verdict_is 0 "free" "nothing claims it"        1000 "me" ""
  verdict_is 0 "mine" "our own claim, read back" 1000 "me" "7 me 900 1800"

  # CASE — TWO DISPATCHERS RACING. Both posted before either read, which is the interleaving the
  # read-back exists for. Both see the same list and both reach the same answer: 7 wins.
  verdict_is 0 "mine"    "racing, we posted first"  1000 "a" "7 a 990 1800
8 b 991 1800"
  verdict_is 1 "held  by a" "racing, we posted second" 1000 "b" "7 a 990 1800
8 b 991 1800"

  # The winner is the lowest ID, never the oldest epoch — a heartbeat rewrites the epoch, and
  # ordering on it would hand the issue to whoever arrived second.
  verdict_is 1 "held  by a" "the holder refreshed" 1000 "b" "7 a 999 1800
8 b 991 1800"

  # CASE — A CLAIM LEFT BY A KILLED RUN. epoch + ttl is in the past, so it is not live and the
  # issue is free. A lock with no expiry is the failure this rules out.
  verdict_is 0 "free" "an expired claim locks nothing" 99999 "me" "7 a 900 1800"
  verdict_is 0 "mine" "expired theirs, live ours"      99999 "me" "7 a 900 1800
9 me 99000 1800"
  # Exactly at the boundary the claim is over: `>`, not `>=`, so a claim cannot outlive its TTL.
  verdict_is 0 "free" "expiry is exclusive"            2700 "me" "7 a 900 1800"
  verdict_is 1 "held" "one second inside the TTL"      2699 "me" "7 a 900 1800"

  # A dispatcher with no token of its own asks only whether anyone holds it.
  verdict_is 1 "held  by a" "unowned check, held" 1000 "" "7 a 900 1800"
  verdict_is 0 "free"       "unowned check, free" 99999 "" "7 a 900 1800"

  # ---- the marker ---------------------------------------------------------------
  marker_is "host/12/ab12 1757 1800" "a real body" \
    "text above
<!-- arc-claim v1 owner=host/12/ab12 epoch=1757 ttl=1800 -->"
  # A comment QUOTING a marker is still an ordinary comment as far as the id ordering goes — it
  # parses, and that is accepted: the alternative is a claim that a stray paste can hide.
  marker_is "" "no marker at all" "Blocked by #211."
  marker_is "" "a v2 marker is not ours" "<!-- arc-claim v2 owner=x epoch=1 ttl=2 -->"

  # ---- the settle window ---------------------------------------------------------
  # `0` returns at once; a non-integer is slept and said out loud rather than skipped in silence.
  # THE LOWER BOUND IS THE ASSERTION. The defect was a pause skipped in silence, so a case that
  # only caps the elapsed time passes against it. The upper bound is slack for a second boundary.
  settle_is() {  # settle_is <min-seconds> <max-seconds> <want-warning|quiet> <name> <value>
    run=$((run + 1))
    local t0 t1 d err
    t0="$(date +%s)"
    err="$(settle "$5" 2>&1 >/dev/null)"
    t1="$(date +%s)"; d=$((t1 - t0))
    if [ "$d" -lt "$1" ] || [ "$d" -gt "$2" ]; then
      bad "settle: $4 — took ${d}s, wanted $1 to $2"; return; fi
    if [ "$3" = warning ] && [ -z "$err" ]; then
      bad "settle: $4 — slept without saying so"; return; fi
    if [ "$3" = quiet ] && [ -n "$err" ]; then
      bad "settle: $4 — said \"$err\""; return; fi
    ok "settle: $4"
  }
  settle_is 0 1 quiet   "0 is no pause"                     0
  settle_is 2 4 quiet   "a whole number of seconds sleeps"  2
  settle_is 2 4 warning "2s sleeps too, and says so"        2s

  # ---- end to end, against the fixture backend ----------------------------------
  TMP="$(mktemp -d 2>/dev/null || echo "${TMPDIR:-/tmp}/arc-claim.$$")"
  mkdir -p "$TMP"
  export ARC_CLAIM_FIXTURES="$TMP" ARC_CLAIM_SETTLE=0 ARC_CLAIM_TTL=1800
  printf '5\n' > "$TMP/children-100"
  printf '1000\n' > "$TMP/nextid"

  # e2e <owner> <want-exit> <name> <command...> — the owner is an argument rather than an
  # assignment prefixing the call, because an assignment in front of a shell FUNCTION is not
  # reliably scoped to it, and the child `bash` needs it exported either way.
  e2e() {
    run=$((run + 1))
    local owner="$1" want="$2" name="$3" out status
    shift 3
    out="$(ARC_CLAIM_OWNER="$owner" ARC_CLAIM_NOW="$FAKE_NOW" bash "$SELF" "$@" 2>&1)"; status=$?
    if [ "$status" != "$want" ]; then
      bad "$name — wanted exit $want, got $status: $(printf '%s' "$out" | tr '
' ' ')"; return 1; fi
    ok "$name"
    return 0
  }

  # claimed_now — the read selection makes, at the fixed clock.
  claimed_now() { ARC_CLAIM_NOW="$FAKE_NOW" bash "$SELF" claimed 100; }

  FAKE_NOW=1000

  e2e alpha 0 "take an unclaimed issue"  take 5
  e2e alpha 0 "check: ours"              check 5

  # THE PRE-CHECK, which is the cheap half: a dispatcher arriving at an issue somebody already
  # holds is turned away by one read and posts nothing. The RACE — where the rival appears after
  # that read — is a separate case further down, and it is the one that exercises the read-back.
  e2e beta  1 "a second dispatcher is turned away by the pre-check" take 5

  # AND IT POSTED NOTHING. One comment on the issue, alpha's.
  run=$((run + 1))
  if [ "$(wc -l < "$TMP/comments-5.tsv" | tr -d ' ')" = 1 ] \
     && claimed_now | grep -q '^5 alpha$'; then
    ok "the pre-check left no comment behind — one, alpha's"
  else
    bad "the pre-check posted anyway: $(cut -f1 "$TMP/comments-5.tsv" | tr '\n' ' ')"
  fi

  # THE LAST COMMENT IS A COMMENT. A backend whose output is not newline-terminated dropped the
  # newest claim — the only one a race turns on — and reported the issue free. The fixture's
  # `sort` terminates its output, so no case here saw it until a live read did.
  run=$((run + 1))
  printf '6\t%s' "$(claim_body zeta 900 1800 | base64 | tr -d '\n')" > "$TMP/comments-6.tsv"
  if ARC_CLAIM_NOW=1000 bash "$SELF" check 6 2>&1 | grep -q 'held  by zeta'; then
    ok "an unterminated final line is still read as a claim"; else
    bad "the last comment was dropped: $(ARC_CLAIM_NOW=1000 bash "$SELF" check 6 2>&1)"; fi
  rm -f "$TMP/comments-6.tsv"

  # CASE — TWO DISPATCHERS RACING AT THE ONLY INTERLEAVING THAT MATTERS: the rival's claim lands
  # between our pre-check and our read-back, carrying a lower id. The pre-check cannot see it, so
  # this is the one case that exercises post → read back → find ourselves second → withdraw. It
  # is also the case that fails if the withdrawal stops deleting: without it two live claims
  # remain and `claimed` names the wrong holder.
  printf '900\t%s\n' "$(claim_body rival 990 1800 | base64 | tr -d '\n')" > "$TMP/inject"
  printf '7\n' >> "$TMP/children-100"
  export ARC_CLAIM_AFTER_POST="cat '$TMP/inject' >> '$TMP/comments-7.tsv'"
  e2e delta 1 "racing: the rival lands after our pre-check" take 7
  unset ARC_CLAIM_AFTER_POST
  run=$((run + 1))
  # THE COMMENT COUNT IS THE ASSERTION, not the verdict. Our claim carries the HIGHER id, so the
  # rival wins the verdict whether we withdrew or not — a withdrawal that deletes nothing passed
  # a verdict-only version of this case.
  if [ "$(ARC_CLAIM_NOW=$FAKE_NOW bash "$SELF" check 7 2>&1)" = "#7 held  by rival — comment 900, until $(iso 2790)" ] \
     && [ "$(cut -f1 "$TMP/comments-7.tsv" | tr -d '[:space:]')" = 900 ]; then
    ok "we withdrew our own comment and left the rival's"
  else
    bad "after withdrawing: $(ARC_CLAIM_NOW=$FAKE_NOW bash "$SELF" check 7 2>&1) / comments $(cut -f1 "$TMP/comments-7.tsv" | tr '\n' ' ')"
  fi
  rm -f "$TMP/comments-7.tsv"
  printf '5\n' > "$TMP/children-100"

  # CASE — SELECTION SKIPS A CLAIMED ISSUE. `claimed` is what next_issue subtracts.
  run=$((run + 1))
  if [ "$(claimed_now)" = "5 alpha" ]; then
    ok "claimed names the issue and its holder"; else
    bad "claimed printed \"$(claimed_now)\""; fi

  # The heartbeat pushes the expiry out.
  FAKE_NOW=2000
  e2e alpha 0 "refresh, held by us" refresh 5 alpha
  e2e beta  1 "refresh someone else's claim" refresh 5 beta

  # CASE — A CLAIM LEFT BY A KILLED RUN. The dispatcher stops refreshing; one TTL later the
  # issue is free, the next reader reaps the comment, and another dispatcher takes it.
  FAKE_NOW=$((2000 + 1801))
  run=$((run + 1))
  if [ -z "$(claimed_now)" ]; then
    ok "an unrefreshed claim stops being live after its TTL"; else
    bad "the expired claim still reads as live"; fi
  e2e gamma 0 "another dispatcher takes the expired issue" take 5
  run=$((run + 1))
  if [ "$(wc -l < "$TMP/comments-5.tsv" | tr -d ' ')" = 1 ]; then
    ok "the expired comment was reaped — one comment left"; else
    bad "expired claims are accumulating: $(wc -l < "$TMP/comments-5.tsv") comments"; fi

  # A FAILED READ IS NOT "FREE". `read_comments` runs on the left of a pipeline, where its own
  # `exit 2` kills only that subshell — so this reported an unclaimed issue on any rate limit,
  # which is #214's defect reachable through one transient error. Driven with a `gh` that fails.
  # THE STUB ANSWERS `gh repo view` AND FAILS `gh api`. A stub that fails everything exits at
  # `repo_nwo` instead, which is a different guard on a different line — the case would pass
  # with the comment read's own check deleted.
  mkdir -p "$TMP/bin"
  {
    echo '#!/usr/bin/env bash'
    echo 'case "$1" in'
    echo '  repo) echo Calyx-Engineering/arc ;;'
    echo '  *)    echo "HTTP 429: rate limited" >&2; exit 1 ;;'
    echo 'esac'
  } > "$TMP/bin/gh"
  chmod +x "$TMP/bin/gh"
  run=$((run + 1))
  out="$(ARC_CLAIM_FIXTURES= ARC_CLAIM_NOW="$FAKE_NOW" PATH="$TMP/bin:$PATH" \
         bash "$SELF" check 5 2>&1)"; status=$?
  if [ "$status" = 2 ] && ! printf '%s' "$out" | grep -q free; then
    ok "a failed read exits 2 and never says free"
  else
    bad "a failed read gave exit $status: $(printf '%s' "$out" | tr '\n' ' ')"
  fi

  # CASE — RELEASED ON EVERY EXIT PATH, the tool half: release removes ours and only ours.
  printf '%s\t%s\n' 999 "$(printf 'Unrelated review comment.' | base64 | tr -d '\n')" \
    >> "$TMP/comments-5.tsv"
  e2e gamma 0 "release our own claim" release 5 gamma
  run=$((run + 1))
  if [ -z "$(claimed_now)" ] \
     && grep -q '^999' "$TMP/comments-5.tsv"; then
    ok "released — and the ordinary comment survived"; else
    bad "release did not leave the issue as it found it: $(cat "$TMP/comments-5.tsv")"; fi
  e2e gamma 0 "releasing twice is not an error" release 5 gamma

  # AND ONLY OURS, WITH A SECOND DISPATCHER PRESENT. Every case above holds one claim at a time,
  # so "ours and only ours" was never tested against anybody else's: dropping `cmd_release`'s
  # owner filter passed the whole suite while one dispatcher's release destroyed another's live
  # claim.
  printf '500\t%s\n' "$(claim_body alpha 990 1800 | base64 | tr -d '\n')" > "$TMP/comments-8.tsv"
  printf '501\t%s\n' "$(claim_body beta  991 1800 | base64 | tr -d '\n')" >> "$TMP/comments-8.tsv"
  e2e beta 0 "release beta's claim while alpha's stands" release 8 beta
  run=$((run + 1))
  if [ "$(ARC_CLAIM_NOW=1000 bash "$SELF" check 8 2>&1)" = "#8 held  by alpha — comment 500, until $(iso 2790)" ]; then
    ok "release took only its own — alpha still holds it"; else
    bad "release crossed owners: $(ARC_CLAIM_NOW=1000 bash "$SELF" check 8 2>&1)"; fi

  # AN EXPIRED CLAIM OF OUR OWN IS NOT REFRESHABLE. `refresh` is both the heartbeat and the
  # adoption test in tools/arc-loop.sh, and both read its 0 as "you still hold this". Without
  # `cmd_refresh`'s liveness filter a lapsed dispatcher resurrects its own expired claim and,
  # holding the lower id, beats the legitimate holder that took the issue in the meantime.
  printf '502\t%s\n' "$(claim_body zeta 100 1800 | base64 | tr -d '\n')" > "$TMP/comments-9.tsv"
  e2e zeta 1 "an expired claim cannot be refreshed back to life" refresh 9 zeta
  run=$((run + 1))
  if [ "$(ARC_CLAIM_NOW=9000 bash "$SELF" check 9 2>&1)" = "#9 free" ]; then
    ok "the expired claim stayed expired"; else
    bad "refresh resurrected it: $(ARC_CLAIM_NOW=9000 bash "$SELF" check 9 2>&1)"; fi
  rm -f "$TMP/comments-8.tsv" "$TMP/comments-9.tsv"

  # Arguments.
  e2e none 2 "no command"        ""
  e2e none 2 "take with no issue" take
  e2e none 2 "release with no token" release 5

  unset ARC_CLAIM_FIXTURES ARC_CLAIM_SETTLE ARC_CLAIM_TTL
  rm -rf "$TMP"

  # ---- CASE — RELEASED ON EVERY EXIT PATH, the caller half ----------------------
  # The tool cannot release a claim the caller never drops. This is a structural check on
  # tools/arc-loop.sh, in the same spirit as tools/verify-linked-branch.sh's source_has: the
  # guarantee is one line of shell, it cannot be exercised without dispatching a real run, and
  # the first draft of that integration released on the happy path only.
  loop_has() {  # loop_has <want-count> <regex> <name>
    run=$((run + 1))
    local got
    got="$(grep -cE -- "$2" "$(dirname "$SELF")/arc-loop.sh" 2>/dev/null)"; got="${got:-0}"
    if [ "$got" -ge "$1" ]; then ok "arc-loop: $3"; else
      bad "arc-loop: $3 — expected at least $1 line(s) matching /$2/, found $got"; fi
  }
  loop_has 1 '^CLAIM="\$HERE/arc-claim\.sh"$'   "it calls this file, by path"
  loop_has 1 '"\$CLAIM" take '                   "take is wired"
  loop_has 1 '"\$CLAIM" release '                "release is wired"
  loop_has 1 '"\$CLAIM" refresh '                "refresh is wired"
  loop_has 1 '"\$CLAIM" claimed '                "selection reads the claimed set"
  loop_has 1 '^  read_claimed$'                  "selection re-reads it every pass"
  loop_has 1 '^trap release_claims EXIT$'           "the EXIT trap releases"
  # A SIGNAL HANDLER THAT RETURNS RESUMES THE SCRIPT. `trap release_claims INT` turned
  # Ctrl-C into "drop the claim on the running issue, then dispatch the next one". Each
  # signal trap has to exit, and 130 and 143 are the shell's own codes for the two signals.
  loop_has 1 "^trap 'release_claims; exit 130' INT$"  "the INT trap releases and exits"
  loop_has 1 "^trap 'release_claims; exit 143' TERM$" "the TERM trap releases and exits"
  loop_has 1 '^release_claims\(\) \{'             "release_claims exists"
  # EVERY EXIT PATH, and the two that are easy to leave out. run_batch drops its claims when the
  # run ends rather than leaving them to the trap, and --resume — the one path that skips
  # selection — takes a claim of its own. The first draft of this integration had neither.
  loop_has 1 'for n in "\$@"; do release_claim "\$n"; done' "run_batch releases when its run ends"
  loop_has 1 '^    crc=0; take_claim "\$n" \|\| crc=\$\?$'    "run_batch claims before working"
  loop_has 1 '^    crc=0; reclaim_claim "\$n" \|\| crc=\$\?$' "--resume claims before working"

  # A KILLED DISPATCHER'S TOKEN IS A BEARER CREDENTIAL, and `.arc-work/runs/` is shared by every
  # dispatcher started from this checkout. Only `--resume` may pick one up, and only after the
  # guard that establishes the run it belongs to is dead — so exactly one call site is correct,
  # and run_batch having one too would be the interlock bypassed rather than enforced.
  run=$((run + 1))
  if [ "$(grep -cE -- 'reclaim_claim "\$n"' "$(dirname "$SELF")/arc-loop.sh" 2>/dev/null)" = 1 ]; then
    ok "arc-loop: reclaim_claim has exactly one caller"
  else
    bad "arc-loop: reclaim_claim has more than one caller — only --resume may adopt a token"
  fi

  # AND run_batch'\''s OWN GUARDS COME FIRST. A claim taken before them is a claim taken inside
  # another dispatcher's run directory, released moments later by the `die` those guards raise.
  run=$((run + 1))
  local loop_src g1 g2 c1
  loop_src="$(dirname "$SELF")/arc-loop.sh"
  g1="$(grep -n '^  \[ -d "\$wt" \] && die' "$loop_src" | head -n1 | cut -d: -f1)"
  g2="$(grep -n '^  \[ -f "\$dir/pid" \] && alive' "$loop_src" | head -n1 | cut -d: -f1)"
  c1="$(grep -n '^  CLAIM_DIR="\$dir"$' "$loop_src" | head -n1 | cut -d: -f1)"
  if [ -n "$g1" ] && [ -n "$g2" ] && [ -n "$c1" ] && [ "$g1" -lt "$c1" ] && [ "$g2" -lt "$c1" ]; then
    ok "arc-loop: run_batch's worktree and liveness guards precede its first claim"
  else
    bad "arc-loop: guards at $g1/$g2 do not both precede the first claim at $c1"
  fi

  echo
  if [ "$failed" = 0 ]; then echo "$run cases, $passed passed, 0 failed"; return 0; fi
  echo "$run cases, $passed passed, $failed failed"
  return 1
}

# ---- arguments -------------------------------------------------------------------
num() { case "${1:-}" in ''|*[!0-9]*) return 1 ;; *) return 0 ;; esac; }

case "${1:-}" in
  take)     num "${2:-}" || { usage; exit 2; }; [ "$#" -eq 2 ] || { usage; exit 2; }; cmd_take "$2" ;;
  release)  num "${2:-}" || { usage; exit 2; }; [ "$#" -eq 3 ] || { usage; exit 2; }; cmd_release "$2" "$3" ;;
  refresh)  num "${2:-}" || { usage; exit 2; }; [ "$#" -eq 3 ] || { usage; exit 2; }; cmd_refresh "$2" "$3" ;;
  check)    num "${2:-}" || { usage; exit 2; }; [ "$#" -eq 2 ] || { usage; exit 2; }; cmd_check "$2" ;;
  claimed)  num "${2:-}" || { usage; exit 2; }; [ "$#" -eq 2 ] || { usage; exit 2; }; cmd_claimed "$2" ;;
  selftest) [ "$#" -eq 1 ] || { echo "selftest takes no arguments" >&2; usage; exit 2; }; selftest ;;
  -h|--help) usage; exit 0 ;;
  *)        usage; exit 2 ;;
esac
