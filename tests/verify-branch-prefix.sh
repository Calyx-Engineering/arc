#!/usr/bin/env bash
# verify-branch-prefix.sh — branch-guard reads the coordination prefix from the operating
# agreement, and falls back to `arc/` when it cannot.
#
#   tools/verify-branch-prefix.sh
#
# WHY A SEPARATE SCRIPT. The prefix is a per-repo setting, so every case here needs a
# repository holding an operating agreement that declares one — a fixture no case payload
# under tools/hook-cases/branch-guard/ can express. verify-hook.sh builds the fixtures for
# those, and it is hard-excluded from autonomous edits (CLAUDE.md, m10 §5): the script that
# validates hook changes is not changed by the run making one. Same precedent as
# verify-workspace-guard.sh, which carries the worktree and freshness fixtures.
#
# THE FAIL-OPEN CASE IS THE ONE THAT MATTERS, AND IT IS THE EMPTY VALUE. The declared value
# reaches a `case` pattern as `"$PREFIX"*`, where a quoted expansion is matched literally —
# so a clause reading `*` is inert, and the case below asserting that is a regression guard
# rather than the live hazard. An empty value is the live one: `""*` matches every branch,
# classifies the whole repository as coordination, and denies every source edit in it. That
# is the dead session the fail-open rule exists to prevent. #203.
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
repo() {  # $1 name, $2 branch
  mkdir -p "$FIXTURES/$1"
  g "$FIXTURES/$1" init -q
  g "$FIXTURES/$1" commit -q --allow-empty -m base
  g "$FIXTURES/$1" checkout -q -B "$2"
}

# The agreement lands where Arc installs it, relative to the repository root — which is what
# the hook reads. A body of one line is enough; the hook takes the first `**Branch prefix:**`
# it finds and nothing else.
agreement() {  # $1 name, $2 body
  mkdir -p "$FIXTURES/$1/.claude/arc/camp"
  printf '%s\n' "$2" > "$FIXTURES/$1/.claude/arc/camp/operating-agreement.md"
}

repo unset-default rev/b-integration
repo unset-arc     arc/09-x

repo declared-coord rev/b-integration
agreement declared-coord '**Branch prefix:** `rev/`'

repo declared-arc arc/09-x
agreement declared-arc '**Branch prefix:** `rev/`'

repo declared-work rev/b-issue-7-slug
agreement declared-work '**Branch prefix:** `rev/`'

repo no-clause arc/09-x
agreement no-clause '# an agreement that states no prefix'

repo glob-topic topic-thing
agreement glob-topic '**Branch prefix:** `*`'

repo glob-arc arc/09-x
agreement glob-arc '**Branch prefix:** `*`'

# The clause with its value deleted — the one input that could deny a whole repository.
repo empty-value topic-thing
agreement empty-value '**Branch prefix:**'

# Written without the code span the agreement uses. It is still a stated setting, and
# reading it as unset would be the silent misclassification #203 is about.
repo bare-value rev-b-integration
agreement bare-value '**Branch prefix:** rev-'

# The forms a user actually types into that section. Its own instruction is "check one per
# setting" and every neighbouring clause is a checkbox list, so a checkbox is the amendment
# a reader will reach for; an indented or bulleted line is what a list item looks like once
# it is nested. All of them state the setting, so all of them are read.
repo checkbox-form rev-b-integration
agreement checkbox-form '- [x] **Branch prefix:** `rev-`'

repo indented-form rev-b-integration
agreement indented-form '  **Branch prefix:** `rev-`'

repo colon-outside rev-b-integration
agreement colon-outside '**Branch prefix**: `rev-`'

# `none` is how a repository says it has no prefix. Taken literally it classifies nothing as
# coordination — the guard switched off across the whole repository, silently.
repo word-value arc/09-x
agreement word-value '**Branch prefix:** none'

# A separator on its own is not a prefix either.
repo lone-separator arc/09-x
agreement lone-separator '**Branch prefix:** `/`'

# ---- runner ---------------------------------------------------------------------
# One invocation of the hook. $1 expect, $2 description, $3 fixture, $4 file_path, rest: env.
run() {
  local expect="$1" desc="$2" cwd="$FIXTURES/$3" file="$4"; shift 4
  local payload out rc verdict
  payload="{\"tool_name\":\"Edit\",\"cwd\":\"$(p "$cwd")\",\"tool_input\":{\"file_path\":\"$file\"}}"
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

echo "verify-branch-prefix.sh — $HOOK"
echo

echo "unset — the shipped default"
run deny  "no agreement: \`arc/\` is still coordination" \
    unset-arc "src/index.ts"
run allow "no agreement: another repo's prefix is a topic branch, not coordination" \
    unset-default "src/index.ts"
run deny  "an agreement that states no prefix falls back to \`arc/\`" \
    no-clause "src/index.ts"
echo

echo "declared"
run deny  "the declared prefix marks a coordination branch" \
    declared-coord "src/index.ts"
run allow "the record stays writable on it" \
    declared-coord "README.md"
run allow "declaring a prefix replaces \`arc/\` rather than adding to it" \
    declared-arc "src/index.ts"
run allow "a work branch nested under the declared prefix" \
    declared-work "src/index.ts"
run deny  "a value written without the agreement's code span is still read" \
    bare-value "src/index.ts"
run deny  "written as a checkbox, the form the section's neighbours use" \
    checkbox-form "src/index.ts"
run deny  "written indented" \
    indented-form "src/index.ts"
run deny  "written with the colon outside the bold" \
    colon-outside "src/index.ts"
echo

echo "fail open"
run allow "the clause with no value must not classify every branch as coordination" \
    empty-value "src/index.ts"
run deny  "\`none\` is a word, not a prefix — the guard stays on" \
    word-value "src/index.ts"
run deny  "a lone separator is not a prefix either" \
    lone-separator "src/index.ts"
run allow "a glob as the value is discarded" \
    glob-topic "src/index.ts"
run deny  "and the fallback to \`arc/\` still applies" \
    glob-arc "src/index.ts"
echo

echo "kill switch"
KS_HOME="$FIXTURES/ks-home"
mkdir -p "$KS_HOME/.claude" && touch "$KS_HOME/.claude/HOOKS_OFF"
run allow "HOOKS_OFF suppresses the declared-prefix deny" \
    declared-coord "src/index.ts" "HOME=$KS_HOME"
echo

echo "$PASSED passed, $FAILED failed"
[ "$FAILED" -eq 0 ] || exit 1
