#!/usr/bin/env bash
# arc-loop.sh — run one workstream's issues, one fresh session each.
#
# Each iteration is a cold `claude -p`: it reads run-instructions.md and one
# issue body, does the work, opens a PR, and exits. This script holds nothing
# but the position in the queue, and the position lives in GitHub — which
# sub-issues are still open. Kill it and restart; it resumes where it was.
#
#   tools/arc-loop.sh 145              run the Fire workstream
#   tools/arc-loop.sh 145 --dry-run    print what it would dispatch, run nothing
#   tools/arc-loop.sh 145 --max 3      stop after three issues
#
# Scope of one invocation is ONE workstream. When its children are all closed
# the script dispatches a report run and exits; the next workstream is a
# second invocation, after a human has read that report.
#
# Exercised 2026-09-06 against the real milestone: selection and skipping on all
# five workstreams, and the three guards (no argument, an issue that is not a
# workstream, an issue that does not exist). NOT yet exercised: a real dispatch
# to `claude -p`, the report run at workstream completion, the all-blocked stop,
# the same-issue-twice guard, and a run exiting non-zero.
#
# Reasoning: docs/arc-log/arc-04-dogfood.md §3.1
set -euo pipefail

REPO="Calyx-Engineering/arc"
INSTRUCTIONS="docs/arc-work/04-dogfood/run-instructions.md"
DRY=0
MAX=0
PARENT="${1:-}"
shift || true
while [ $# -gt 0 ]; do
  case "$1" in
    --dry-run) DRY=1 ;;
    --max) shift; MAX="${1:-0}" ;;
    *) echo "unknown option: $1" >&2; exit 2 ;;
  esac
  shift
done

die() { echo "arc-loop: $*" >&2; exit 1; }

[ -n "$PARENT" ] || die "usage: tools/arc-loop.sh <workstream-parent-issue> [--dry-run] [--max N]"
[ -f "$INSTRUCTIONS" ] || die "missing $INSTRUCTIONS — run from the repository root"
command -v gh >/dev/null || die "gh not found"

# --- the parent must actually be a workstream -------------------------------
labels=$(gh issue view "$PARENT" -R "$REPO" --json labels --jq '[.labels[].name]|join(",")') \
  || die "cannot read issue #$PARENT"
case ",$labels," in
  *,workstream,*) ;;
  *) die "#$PARENT is not labelled 'workstream' — it is not an execution queue" ;;
esac

parent_title=$(gh issue view "$PARENT" -R "$REPO" --json title --jq .title)
echo "arc-loop: #$PARENT $parent_title"
[ "$DRY" = 1 ] && echo "arc-loop: dry run — nothing will be dispatched"

# --- queue reads --------------------------------------------------------------
open_children() {
  gh api graphql -f query="{repository(owner:\"${REPO%%/*}\",name:\"${REPO##*/}\"){
    issue(number:$PARENT){subIssues(first:50){nodes{number state}}}}}" \
    --jq '.data.repository.issue.subIssues.nodes[] | select(.state=="OPEN") | .number'
}

# an issue is eligible when every "Blocked by #NN" line names a closed issue
blocked() {
  local body blockers n st
  body=$(gh issue view "$1" -R "$REPO" --json body --jq .body)
  blockers=$(printf '%s\n' "$body" | grep -oiE '^Blocked by #[0-9]+' | grep -oE '[0-9]+' || true)
  for n in $blockers; do
    st=$(gh issue view "$n" -R "$REPO" --json state --jq .state 2>/dev/null || echo OPEN)
    [ "$st" = "OPEN" ] && { echo "$n"; return 0; }
  done
  return 1
}

next_issue() {
  local n b
  for n in $(open_children); do
    if b=$(blocked "$n"); then
      echo "  #$n blocked by #$b" >&2
    else
      echo "$n"; return 0
    fi
  done
  return 1
}

# --- dispatch -----------------------------------------------------------------
run_issue() {
  local n="$1" prompt
  prompt=$(cat "$INSTRUCTIONS"; echo; echo "---"; echo;
           echo "# The issue you are executing: #$n"; echo;
           gh issue view "$n" -R "$REPO" --json title,body --jq '"## " + .title + "\n\n" + .body')
  if [ "$DRY" = 1 ]; then
    echo "  would dispatch issue run for #$n ($(printf '%s' "$prompt" | wc -c) bytes)"
    return 0
  fi
  printf '%s' "$prompt" | claude -p
}

run_report() {
  local prompt
  prompt=$(cat "$INSTRUCTIONS"; echo; echo "---"; echo;
           cat <<EOF
# You are a report run

Do no work. Every issue under #$PARENT ($parent_title) is closed.

Read that workstream's merged PRs and their dev-logs, then write the boundary
report described in section 6 above. 200 words maximum. Post it as a comment on
#$PARENT and add it to the arc-log's status section. Name what did not get done.
EOF
  )
  if [ "$DRY" = 1 ]; then
    echo "  would dispatch report run for #$PARENT"
    return 0
  fi
  printf '%s' "$prompt" | claude -p
}

# --- the loop -------------------------------------------------------------------
count=0
last=""
while :; do
  if ! issue=$(next_issue); then
    if [ -n "$(open_children)" ]; then
      echo "arc-loop: every remaining issue is blocked — stopping"
      exit 1
    fi
    echo "arc-loop: workstream complete, dispatching report run"
    run_report
    echo "arc-loop: done. The next workstream is a separate invocation."
    exit 0
  fi

  # a run that does not close its issue would otherwise loop forever
  if [ "$issue" = "$last" ]; then
    echo "arc-loop: #$issue still open after its run — stopping rather than repeating" >&2
    exit 1
  fi

  count=$((count + 1))
  echo "arc-loop: [$count] issue run for #$issue"
  if ! run_issue "$issue"; then
    echo "arc-loop: the run for #$issue exited non-zero — stopping" >&2
    exit 1
  fi
  last="$issue"

  if [ "$MAX" != 0 ] && [ "$count" -ge "$MAX" ]; then
    echo "arc-loop: reached --max $MAX — stopping"
    exit 0
  fi

  # a dry run never closes anything; one pass is the whole demonstration
  [ "$DRY" = 1 ] && { echo "arc-loop: dry run stops after one selection"; exit 0; }
done
