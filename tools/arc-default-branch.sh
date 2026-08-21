#!/usr/bin/env bash
# arc-default-branch.sh — point the repository default branch at an arc, and restore it.
#
#   tools/arc-default-branch.sh check                     preconditions only, changes nothing
#   tools/arc-default-branch.sh flip    <arc-branch>      offer accepted: point default at the arc
#   tools/arc-default-branch.sh restore [trunk-branch]    arc closed: point it back
#   tools/arc-default-branch.sh status                    is the default where it should be?
#
# WHY. GitHub ignores a closing keyword unless the PR targets the repository's default
# branch. An arc runs issue branches into an arc branch, so every issue PR targets a
# non-default base by construction and links nothing. Pointing the default at the arc for
# its lifetime makes them bind natively — no hook, no marketplace action.
#
# This is a script and not a hook on purpose: flipping is a deliberate act tied to the arc
# lifecycle, not something that should fire on a tool call. Arc offers; the human accepts.
#
# PHRASING. Every line this script prints names what kind of thing an identifier is —
# "arc branch arc/03-camp", never a bare "arc/03-camp". A bare token makes the reader
# classify it before they can answer the question it sits in, and this script asks the
# user to make a decision. The qualifier is one or two words; if it needs more, the
# sentence is built wrong. m42 states the rule.
#
# Carries m42.

set -u

TRUNK_DEFAULT=main

die() { printf 'error: %s\n' "$1" >&2; exit 1; }

repo_slug() {
  gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null
}

current_default() {
  gh api "repos/$1" --jq .default_branch 2>/dev/null
}

# ---- preconditions --------------------------------------------------------------
# The guard does not ask the user to judge whether this is safe. It checks. Every one of
# these is queryable, and any failure — or any error — means no flip.

check_preconditions() {
  local slug="$1" arc="$2" trunk="$3" failed=0 n

  printf 'preconditions for repository %s\n\n' "$slug"

  # 1. Single collaborator. A second person cloning mid-arc lands on in-progress work
  #    instead of the trunk, which is the sharpest edge this mechanism has.
  n="$(gh api "repos/$slug/collaborators" --jq 'length' 2>/dev/null)"
  if [ "${n:-0}" = 1 ]; then
    printf '  PASS  single collaborator\n'
  else
    printf '  FAIL  %s collaborators — a clone mid-arc would give them the arc branch\n' "${n:-unknown}"
    failed=1
  fi

  # 2. No branch protection on the trunk. Rules keyed to "the default branch" follow the
  #    flip, which silently moves enforcement to the arc.
  if gh api "repos/$slug/branches/$trunk/protection" >/dev/null 2>&1; then
    printf '  FAIL  trunk branch %s is protected — rules keyed to the default branch would follow the flip\n' "$trunk"
    failed=1
  else
    printf '  PASS  no branch protection on trunk branch %s\n' "$trunk"
  fi

  # 3. No open PRs targeting the trunk from outside the arc. Their keywords would begin
  #    binding, or stop, while the default is moved.
  n="$(gh pr list --base "$trunk" --state open --json number --jq 'length' 2>/dev/null)"
  if [ "${n:-0}" = 0 ]; then
    printf '  PASS  no open PRs targeting trunk branch %s\n' "$trunk"
  else
    printf '  FAIL  %s open PR(s) target trunk branch %s — their linking would change under the flip\n' "$n" "$trunk"
    failed=1
  fi

  # 4. The arc branch exists on the remote. A missing branch cannot be made default.
  if [ -n "$arc" ]; then
    if git ls-remote --exit-code --heads origin "$arc" >/dev/null 2>&1; then
      printf '  PASS  arc branch %s exists on the remote\n' "$arc"
    else
      printf '  FAIL  arc branch %s is not pushed — a missing branch cannot be made default\n' "$arc"
      failed=1
    fi
  fi

  printf '\n'
  return $failed
}

# ---- the warning ----------------------------------------------------------------
# Not a documentation line. It is said at the moment the choice is made, every time.

print_warning() {
  cat <<'WARN'
Before accepting, two things that are not obvious:

  git clone gives a collaborator the arc branch, not the trunk.
  The single-collaborator check above is what makes this safe, and it is
  the first thing that stops being true as a project grows.

  Changing the default branch is NOT retroactive.
  It does not re-parse existing PRs. Any PR already open or merged stays
  unlinked forever — verified, and a body re-save does not rescue it.
  Change the default branch BEFORE the arc's first PR is opened.

WARN
}

# ---------------------------------------------------------------------------------

CMD="${1:-}"
SLUG="$(repo_slug)" || true
[ -n "${SLUG:-}" ] || die "not a GitHub repository, or gh is not authenticated"

case "$CMD" in
  check)
    ARC="${2:-$(git rev-parse --abbrev-ref HEAD 2>/dev/null)}"
    TRUNK="${3:-$TRUNK_DEFAULT}"
    if check_preconditions "$SLUG" "$ARC" "$TRUNK"; then
      printf 'All preconditions pass. The default branch can be pointed at arc branch %s.\n\n' "$ARC"
      print_warning
      exit 0
    else
      printf 'Preconditions failed — the default branch is unchanged.\n'
      printf 'The arc runs normally; issue PRs simply will not link, which is the\n'
      printf 'behaviour without this mechanism at all.\n'
      exit 1
    fi
    ;;

  flip)
    ARC="${2:-}"
    TRUNK="${3:-$TRUNK_DEFAULT}"
    [ -n "$ARC" ] || die "usage: arc-default-branch.sh flip <arc-branch> [trunk-branch]"

    check_preconditions "$SLUG" "$ARC" "$TRUNK" || die "preconditions failed — refusing to change the default branch"

    # Record where we came from, so restore does not depend on anyone remembering.
    printf '%s\n' "$TRUNK" > .git/arc-default-branch-trunk

    gh api -X PATCH "repos/$SLUG" -f default_branch="$ARC" --jq .default_branch \
      || die "the change failed — the default branch is unchanged"
    printf 'the default branch now points at arc branch %s\n' "$ARC"
    printf 'Point it back at the trunk with: tools/arc-default-branch.sh restore\n'
    ;;

  restore)
    TRUNK="${2:-}"
    if [ -z "$TRUNK" ] && [ -f .git/arc-default-branch-trunk ]; then
      TRUNK="$(cat .git/arc-default-branch-trunk)"
    fi
    TRUNK="${TRUNK:-$TRUNK_DEFAULT}"

    gh api -X PATCH "repos/$SLUG" -f default_branch="$TRUNK" --jq .default_branch \
      || die "the restore failed — the default branch still points at the arc branch"
    rm -f .git/arc-default-branch-trunk
    printf 'the default branch is restored to trunk branch %s\n' "$TRUNK"
    ;;

  status)
    TRUNK="${2:-$TRUNK_DEFAULT}"
    CUR="$(current_default "$SLUG")"
    if [ "$CUR" = "$TRUNK" ]; then
      printf 'the default branch is trunk branch %s — normal\n' "$CUR"
      exit 0
    fi
    # The failure this detects: a crashed or abandoned session leaves the default pointed
    # at a branch that may later be deleted, and nothing about that state is visible in
    # ordinary work. The failure is silent, so the detection cannot be.
    printf 'the default branch is %s, and the trunk branch is %s\n' "$CUR" "$TRUNK"
    if git ls-remote --exit-code --heads origin "$CUR" >/dev/null 2>&1; then
      printf 'That is correct only while the arc on branch %s is active.\n' "$CUR"
      printf 'If that arc has closed, run: tools/arc-default-branch.sh restore\n'
    else
      printf 'WARNING: branch %s no longer exists on the remote. Restore the default branch now.\n' "$CUR"
    fi
    exit 2
    ;;

  *)
    printf 'usage: arc-default-branch.sh check|flip <arc-branch>|restore [trunk-branch]|status\n' >&2
    exit 2
    ;;
esac
