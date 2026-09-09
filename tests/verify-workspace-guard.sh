#!/usr/bin/env bash
# verify-workspace-guard.sh — branch-guard's worktree and base-freshness checks, against
# fixtures that tools/verify-hook.sh cannot build.
#
#   tests/verify-workspace-guard.sh
#
# WHY A SECOND SCRIPT. verify-hook.sh is the gate for every hook, and its fixtures are three
# throwaway repos substituted into case payloads by placeholder. Two of branch-guard's three
# checks need more than that: the worktree check needs a *linked worktree of the same
# repository*, and the freshness check needs a base branch that has moved since the work
# branch was cut. Neither is expressible as a payload. verify-hook.sh is also hard-excluded
# from autonomous edits (CLAUDE.md, m10 §5) — it validates hook changes, so it is not
# changed by the run making one. This script carries the fixtures instead; the case files
# under tools/hook-cases/branch-guard/ still carry everything a payload can say.
#
# REPORTS, NEVER BLOCKS. Exit 1 marks findings. Nothing here denies a tool call.

set -u

cd "$(dirname "$0")/.." || exit 1
HOOK="hooks/branch-guard"
[ -f "$HOOK" ] || { echo "no $HOOK" >&2; exit 2; }

PASSED=0
FAILED=0

FIXTURES="$(mktemp -d)"
trap 'rm -rf "$FIXTURES"' EXIT

g() { git -C "$1" -c user.email=v@x -c user.name=v "${@:2}"; }

# Portable path form — the payload holds a JSON string, so backslashes would need escaping.
p() { printf '%s' "$1" | sed 's|\\|/|g'; }

# ---- fixtures -------------------------------------------------------------------
# `home` is the repository a run works in: an arc branch with a work branch cut from it,
# and a second worktree checked out elsewhere. `other` is an unrelated repository — the
# mirrored-file case, which must stay allowed.
mkdir -p "$FIXTURES/home"
g "$FIXTURES/home" init -q
g "$FIXTURES/home" commit -q --allow-empty -m base
g "$FIXTURES/home" checkout -q -B arc/09-x
g "$FIXTURES/home" checkout -q -B arc/09-x-issue-7-slug
g "$FIXTURES/home" worktree add -q "$FIXTURES/home-wt2" -b arc/09-x-issue-8-other

mkdir -p "$FIXTURES/other"
g "$FIXTURES/other" init -q
g "$FIXTURES/other" commit -q --allow-empty -m base
g "$FIXTURES/other" checkout -q -B arc/09-x-issue-7-slug

# `stale` is cut from a base that then moved. `fresh` is cut from one that did not.
for name in stale fresh; do
  mkdir -p "$FIXTURES/$name"
  g "$FIXTURES/$name" init -q
  g "$FIXTURES/$name" commit -q --allow-empty -m base
  g "$FIXTURES/$name" checkout -q -B arc/09-x
  g "$FIXTURES/$name" checkout -q -B arc/09-x-issue-7-slug
done
g "$FIXTURES/stale" checkout -q arc/09-x
g "$FIXTURES/stale" commit -q --allow-empty -m "work that merged after the branch was cut"
g "$FIXTURES/stale" checkout -q arc/09-x-issue-7-slug

# `nobase` has a work-branch name whose base ref does not exist — the guard must stay quiet.
mkdir -p "$FIXTURES/nobase"
g "$FIXTURES/nobase" init -q
g "$FIXTURES/nobase" commit -q --allow-empty -m base
g "$FIXTURES/nobase" checkout -q -B arc/09-x-issue-7-slug

# ---- runner ---------------------------------------------------------------------
# One invocation of the hook. $1 expect, $2 description, $3 cwd, $4 file_path, rest: env.
run() {
  local expect="$1" desc="$2" cwd="$3" file="$4"; shift 4
  local payload out rc verdict
  payload="{\"tool_name\":\"Edit\",\"cwd\":\"$(p "$cwd")\",\"tool_input\":{\"file_path\":\"$(p "$file")\"}}"
  out="$(printf '%s' "$payload" | env "$@" bash "$HOOK" 2>&1)"
  rc=$?
  if printf '%s' "$out" | grep -q '"permissionDecision" *: *"deny"'; then
    verdict=deny
  elif [ "$rc" -ne 0 ]; then
    verdict="CRASH (exit $rc)"
  else
    verdict=allow
  fi
  if [ "$verdict" = "$expect" ]; then
    printf '  PASS  %-6s  %s\n' "$verdict" "$desc"
    PASSED=$((PASSED + 1))
  else
    printf '  FAIL  %-6s  %s\n' "$verdict" "$desc"
    printf '        expected %s\n' "$expect"
    [ -n "$out" ] && printf '        output: %s\n' "$(printf '%s' "$out" | head -c 300)"
    FAILED=$((FAILED + 1))
  fi
}

echo "verify-workspace-guard.sh — $HOOK"
echo

echo "worktree identity"
run deny  "edit lands in another worktree of the same repository" \
    "$FIXTURES/home" "$FIXTURES/home-wt2/src/index.ts"
run allow "edit lands in the session's own worktree" \
    "$FIXTURES/home" "$FIXTURES/home/src/index.ts"
run allow "a new file in a directory that does not exist yet" \
    "$FIXTURES/home" "$FIXTURES/home/src/new/deep/index.ts"
run allow "edit lands in an unrelated repository — the mirrored-file case" \
    "$FIXTURES/home" "$FIXTURES/other/src/index.ts"
run allow "edit lands outside any repository" \
    "$FIXTURES/home" "$FIXTURES/loose.ts"
echo

echo "base freshness"
run deny  "base moved after the branch was cut — said once" \
    "$FIXTURES/stale" "$FIXTURES/stale/src/index.ts"
run allow "the same stale base does not interrupt twice" \
    "$FIXTURES/stale" "$FIXTURES/stale/src/index.ts"
run allow "base has not moved" \
    "$FIXTURES/fresh" "$FIXTURES/fresh/src/index.ts"
run allow "the base ref does not exist — nothing to compare" \
    "$FIXTURES/nobase" "$FIXTURES/nobase/src/index.ts"
echo

echo "kill switch"
KS_HOME="$FIXTURES/ks-home"
mkdir -p "$KS_HOME/.claude" && touch "$KS_HOME/.claude/HOOKS_OFF"
run allow "HOOKS_OFF suppresses the worktree deny" \
    "$FIXTURES/home" "$FIXTURES/home-wt2/src/index.ts" "HOME=$KS_HOME"
echo

echo "$PASSED passed, $FAILED failed"
[ "$FAILED" -eq 0 ] || exit 1
