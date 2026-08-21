#!/usr/bin/env bash
# verify-sync-parity.sh — run tools/sync-local-skills.sh against throwaway fixture trees.
#
#   tools/verify-sync-parity.sh
#
# #48 asks for a parity check that can be trusted without reading it, and #68 is what
# happens when nobody tests one: the old check exited 0 while a shipping skill had no copy
# at all. A check with no test is the defect it exists to catch, one level up.
#
# Every case builds a complete miniature repo — skills/, commands/, .claude/, and a registry
# — under mktemp, and runs the real script against it through SYNC_ROOT. Nothing here
# touches this repository's own trees, so a failed run leaves no residue.

set -u

SCRIPT="$(cd "$(dirname "$0")" && pwd)/sync-local-skills.sh"
[ -f "$SCRIPT" ] || { echo "missing: $SCRIPT" >&2; exit 2; }

PASSED=0
FAILED=0

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

# ---- fixtures -------------------------------------------------------------------
# A tree with one shipping skill, one command, and a registry that names the skill. Cases
# mutate their own copy of it, never a shared one.
make_tree() {
  local root="$WORK/$1"
  mkdir -p "$root/skills/alpha" "$root/commands" "$root/.claude/skills" "$root/.claude/commands" "$root/docs/product-architecture"

  cat > "$root/skills/alpha/SKILL.md" <<'EOF'
---
name: alpha
description: A fixture skill.
---

# alpha

Links out of the tree: [tiers](../../docs/product-architecture/README.md).
Links to a sibling: [beta](../beta/SKILL.md).
EOF

  printf 'A fixture command.\n' > "$root/commands/go.md"
  printf '| `skills/alpha` | skill | m99 | Invoked, in a fixture | — |\n' > "$root/docs/product-architecture/README.md"
  printf '%s' "$root"
}

# Add a second shipping skill, registry row included, with no copy on disk.
add_uncopied_skill() {
  mkdir -p "$1/skills/beta"
  cat > "$1/skills/beta/SKILL.md" <<'EOF'
---
name: beta
description: A second fixture skill.
---

# beta
EOF
  printf '| `skills/beta` | skill | m98 | Invoked, in a fixture | — |\n' >> "$1/docs/product-architecture/README.md"
}

run() { SYNC_ROOT="$1" bash "$SCRIPT" ${2:-} 2>&1; }

# ---- the assertion ----------------------------------------------------------------
# Cases assert on exit status and on a substring of the output, because the output is what
# a human acts on. A check that exits 1 with an unreadable reason is not a check.
case_is() {
  local name="$1" want_status="$2" want_text="$3" got_status="$4" got="$5"
  if [ "$got_status" = "$want_status" ] && printf '%s' "$got" | grep -qF -- "$want_text"; then
    echo "  PASS  $name"
    PASSED=$((PASSED + 1))
  else
    echo "  FAIL  $name"
    echo "        wanted exit $want_status containing: $want_text"
    echo "        got exit $got_status:"
    printf '%s\n' "$got" | sed 's/^/        | /'
    FAILED=$((FAILED + 1))
  fi
}

echo "verify-sync-parity — $(basename "$SCRIPT")"
echo

# 1 — a synced tree reports current.
root=$(make_tree clean)
run "$root" >/dev/null
out=$(run "$root" --check); status=$?
case_is "clean tree passes --check" 0 "local copies are current" "$status" "$out"

# 2 — the #68 defect: a shipping skill with no copy. The old hardcoded list could not see
#     this at all, and exited 0.
root=$(make_tree nocopy)
run "$root" >/dev/null
add_uncopied_skill "$root"
out=$(run "$root" --check); status=$?
case_is "a skill with no copy fails --check" 1 "no copy: .claude/skills/beta/SKILL.md" "$status" "$out"

# 3 — a copy edited directly. The original reason the check exists.
root=$(make_tree stale)
run "$root" >/dev/null
printf '\nEdited in the copy, which ships nothing.\n' >> "$root/.claude/skills/alpha/SKILL.md"
out=$(run "$root" --check); status=$?
case_is "an edited copy fails --check" 1 "stale: .claude/skills/alpha/SKILL.md" "$status" "$out"

# 4 — the reverse direction: a copy whose source was deleted. It carries the banner, so it
#     is a copy and not a repo-local skill.
root=$(make_tree orphan)
run "$root" >/dev/null
rm -rf "$root/skills/alpha"
out=$(run "$root" --check); status=$?
case_is "an orphaned copy fails --check" 1 "orphan copy — source deleted" "$status" "$out"

# 5 — the same shape without the banner is a repo-local skill, and must not fail. This is
#     what replaces an exception list: the marker the sync itself writes.
root=$(make_tree local)
run "$root" >/dev/null
mkdir -p "$root/.claude/skills/homegrown"
printf -- '---\nname: homegrown\n---\n\nLives only in this repo.\n' > "$root/.claude/skills/homegrown/SKILL.md"
out=$(run "$root" --check); status=$?
case_is "a repo-local skill is reported, not failed" 0 "repo-local skill, not a copy" "$status" "$out"

# 6 — a shipping skill the product definition does not name.
root=$(make_tree unregistered)
mkdir -p "$root/skills/ghost"
printf -- '---\nname: ghost\n---\n\n# ghost\n' > "$root/skills/ghost/SKILL.md"
run "$root" >/dev/null
out=$(run "$root" --check); status=$?
case_is "a skill missing from the registry fails --check" 1 "not in the registry's artifact table: skills/ghost" "$status" "$out"

# 7 — links leaving the skills tree are re-based for the copy's extra directory; sibling
#     links are not. Both are read out of the written copy, not predicted.
root=$(make_tree links)
run "$root" >/dev/null
copy="$root/.claude/skills/alpha/SKILL.md"
out=$(grep -c -- '](../../../docs/product-architecture/README.md)' "$copy")
case_is "an outbound link gains one level" 0 "1" "$?" "$out"
out=$(grep -c -- '](../beta/SKILL.md)' "$copy")
case_is "a sibling link is left alone" 0 "1" "$?" "$out"

# 8 — a second sync writes nothing. A sync that churns files with no content change is noise
#     in the diff that is this repo's review surface.
root=$(make_tree idempotent)
run "$root" >/dev/null
out=$(run "$root"); status=$?
case_is "a repeat sync copies nothing" 0 "0 copied" "$status" "$out"

echo
echo "$PASSED passed, $FAILED failed"
[ "$FAILED" = "0" ] || exit 1
exit 0
