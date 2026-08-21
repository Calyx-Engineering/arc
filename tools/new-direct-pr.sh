#!/usr/bin/env bash
# new-direct-pr.sh — open a direct PR with its number already in the branch name.
#
#   tools/new-direct-pr.sh <hint-slug> "<PR title>"
#   tools/new-direct-pr.sh --dry-run <hint-slug> "<PR title>"
#
# A direct PR is one with no issue behind it. Its branch still carries a number, because the
# branch name is often the only reference visible while the PR is being read — m46 §9. The
# number it carries is the PR's, and the PR does not exist yet.
#
# WHY A SCRIPT. m46 §9.1 predicts the number, then confirms it against the PR once opened, and
# the whole safety argument is that the window between the two is seconds wide. Done by hand it
# is not: branch, author a dev-log, commit, push, open the PR. That is minutes of typing with a
# real race running underneath it. This collapses the window to one command.
#
# The dev-log it commits is a STUB. It exists because a PR needs a commit to exist and m46 §6.1
# requires a dev-log of every merged unit — not because it is finished. Fill it in as the work
# proceeds; the PR is a draft until you mark it ready.
#
# REPORTS, NEVER GUESSES. If the predicted number and the real one differ, the script says so
# and tells you what to record. It does not retry — m46 §9.1: a miss is a race that already
# happened, and buying a tidier branch name costs a real number.

set -u

DRY=0
[ "${1:-}" = "--dry-run" ] && { DRY=1; shift; }

HINT="${1:-}"
TITLE="${2:-}"

usage() {
  cat >&2 <<'USAGE'
usage:
  tools/new-direct-pr.sh <hint-slug> "<PR title>"
  tools/new-direct-pr.sh --dry-run <hint-slug> "<PR title>"

  <hint-slug>   short, hyphenated. It is the tail of the branch name
  <PR title>    the real name. The arc prefix is added for you
USAGE
  exit 2
}

[ -n "$HINT" ] && [ -n "$TITLE" ] || usage
command -v gh >/dev/null 2>&1 || { echo "gh not on PATH" >&2; exit 2; }

# ---- the arc branch we are nesting under ----------------------------------------
# A direct PR belongs to whatever arc is checked out, the same as an issue branch does.
BASE="$(git rev-parse --abbrev-ref HEAD 2>/dev/null)"
case "$BASE" in
  arc/*-issue-*|arc/*-pr[0-9]*)
    echo "you are on a work branch (\`$BASE\`). Check out the arc branch first." >&2
    exit 2 ;;
  arc/*) ;;
  *)
    echo "\`$BASE\` is not an arc branch. This script nests a direct PR under one." >&2
    exit 2 ;;
esac

ARCNUM="$(printf '%s' "$BASE" | sed -n 's#^arc/\([0-9][0-9]*\).*#\1#p')"
[ -n "$ARCNUM" ] || { echo "cannot read an arc number from \`$BASE\`" >&2; exit 2; }

# ---- predict --------------------------------------------------------------------
# Issues and PRs share one counter, so the next number is one past whichever is higher.
# `--state all` matters: a closed issue still holds its number.
I="$(gh issue list --state all --limit 1 --json number --jq '.[0].number' 2>/dev/null)"
P="$(gh pr list --state all --limit 1 --json number --jq '.[0].number' 2>/dev/null)"
I="${I:-0}"; P="${P:-0}"
N=$(( (I > P ? I : P) + 1 ))

BRANCH="${BASE}-pr${N}-${HINT}"
SLUG="$(printf '%s' "$HINT" | tr -cd 'a-z0-9-')"
DEVLOG="docs/dev-log/pr-${N}-${SLUG}.md"

if [ "$DRY" -eq 1 ]; then
  printf 'predicted   %s\nbranch      %s\ndev-log     %s\ntitle       arc-%s: %s\n' \
    "$N" "$BRANCH" "$DEVLOG" "$ARCNUM" "$TITLE"
  exit 0
fi

git rev-parse --verify --quiet "$BRANCH" >/dev/null && {
  echo "branch \`$BRANCH\` already exists" >&2; exit 2; }

git checkout -q -b "$BRANCH" || exit 2

# ---- the stub -------------------------------------------------------------------
# Deliberately short. A long template invites filling it in now, which is the delay this
# script exists to remove. The headings match templates/dev-log.md so the real write is an
# edit rather than a rewrite.
mkdir -p docs/dev-log
cat > "$DEVLOG" <<STUB
# PR #${N} — ${TITLE}

> Decision log, not a spec. **Stub** — opened by \`tools/new-direct-pr.sh\` so the draft PR
> could claim its number. Written properly as the work proceeds, before the PR is marked ready.

**Issue:** none  ·  **PR:** [#${N}](https://github.com/Calyx-Engineering/arc/pull/${N})

## Problem

## Intent and north star

## Decisions & trade-offs

## Retrospective
STUB

git add "$DEVLOG"
git commit -q -m "docs: stub dev-log for PR #${N}

Opened by tools/new-direct-pr.sh so the draft PR can claim its number. The
content is written as the work proceeds." || exit 2

git push -q -u origin "$BRANCH" 2>/dev/null || { echo "push failed" >&2; exit 2; }

URL="$(gh pr create --draft --base "$BASE" --head "$BRANCH" \
  --title "arc-${ARCNUM}: ${TITLE}" \
  --body "**Draft.** Opened by \`tools/new-direct-pr.sh\` to claim PR number ${N} for branch \`${BRANCH}\`. Body written as the work proceeds." 2>&1 | tail -1)"

case "$URL" in https://*) ;; *) echo "PR create failed: $URL" >&2; exit 1 ;; esac

ACTUAL="$(printf '%s' "$URL" | grep -oE '[0-9]+$')"

# ---- confirm --------------------------------------------------------------------
echo
echo "  branch    $BRANCH"
echo "  dev-log   $DEVLOG"
echo "  PR        $URL"
echo

if [ "$ACTUAL" = "$N" ]; then
  echo "  PASS  predicted $N, got $ACTUAL — the branch names its own PR"
  exit 0
fi

# A miss is not retried. m46 §9.1: it is a race that already happened, and the branch name is a
# pointer — one that carries a correction beside it points fine.
cat <<MISS
  MISS  predicted $N, got $ACTUAL — someone filed inside the window

        Do not rename the branch. It closes the PR.
        Do not close and re-open. It burns a number for a tidier pointer.

        Record it in three places:
          1. the PR description, near the top —
             "Branch says pr${N}, this is PR #${ACTUAL}."
          2. $DEVLOG
          3. docs/arc-work/<arc-slug>/friction-log.md, if this repo keeps one
MISS
exit 1
