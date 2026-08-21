#!/usr/bin/env bash
# Copy shipping skills and commands into .claude/ so they are live in this repo.
#
# Arc is not installed in its own repository, so nothing in skills/ or commands/ loads
# here. This copies them where Claude Code discovers them — skills with a do-not-edit
# banner, commands verbatim.
#
# TEMPORARY. Once Arc has a release, this repo installs the *released* plugin from
# the marketplace and these copies are deleted — the dev tree in skills/ is then
# exercised in other repos, never against itself. See CLAUDE.md, "Soak".
#
# Usage:  tools/sync-local-skills.sh [--check]
#         --check  exit 1 if any copy is stale, changing nothing

set -uo pipefail

cd "$(dirname "$0")/.." || exit 1

# What to copy is derived from the trees, never listed. A hardcoded list makes a new skill
# invisible: `skills/relief-valve` was written, synced, and reported "5 copied, 7 checked"
# while copying nothing, and --check exited 0 with no copy on disk (#68). Every skill ships,
# so every skill is copied — an exception list would be the same defect one line lower.
SKILLS=$(for d in skills/*/; do [ -f "$d/SKILL.md" ] && basename "$d"; done | sort)
COMMANDS=$(for f in commands/*.md; do [ -f "$f" ] && basename "$f" .md; done | sort)

# The line the sync writes into every copy. Also the marker the reverse check reads: a
# directory under .claude/skills/ carrying it is a copy, so a missing source means the
# source was deleted. Without it the directory is a repo-local skill and is left alone.
BANNER_MARK='**Copy — do not edit.**'

REGISTRY=docs/product-architecture/README.md

CHECK=0
[ "${1:-}" = "--check" ] && CHECK=1

stale=0
copied=0

for s in $SKILLS; do
  src="skills/$s/SKILL.md"
  dst=".claude/skills/$s/SKILL.md"

  if [ ! -f "$src" ]; then
    echo "missing source: $src" >&2
    stale=1
    continue
  fi

  banner="
> **Copy — do not edit.** The source is [\`skills/$s/SKILL.md\`](../../../skills/$s/SKILL.md),
> which is what the plugin ships. This copy exists only so the skill is live in this repo
> before Arc is installed here. **Edit the source, then re-run \`tools/sync-local-skills.sh\`.**
"

  # Rebuild what the copy should be: source with its outbound links re-based, then the
  # banner after its frontmatter.
  #
  # The copy sits one directory deeper than the source — `.claude/skills/x/` against
  # `skills/x/` — so every link that leaves the skills tree needs one more `../`. Sibling
  # links (`../other-skill/SKILL.md`) resolve in both trees and are left alone; only the
  # `../../` form, which means "repo root" from a source, is re-based. Without this a third
  # of the links in the live copies 404, and the check calls them current.
  #
  # Re-based before the banner is inserted, never after: the banner's own link is already
  # written at the copy's depth.
  expected=$(sed 's#](\.\./\.\./#](../../../#g' "$src" | awk -v b="$banner" '
    BEGIN { fm = 0 }
    { print }
    /^---$/ { fm++; if (fm == 2) print b }
  ')

  if [ -f "$dst" ] && [ "$expected" = "$(cat "$dst")" ]; then
    continue
  fi

  if [ "$CHECK" = "1" ]; then
    if [ -f "$dst" ]; then
      echo "stale: $dst" >&2
    else
      echo "no copy: $dst" >&2
    fi
    stale=1
    continue
  fi

  mkdir -p ".claude/skills/$s"
  printf '%s\n' "$expected" > "$dst"
  echo "synced: $s"
  copied=$((copied + 1))
done

for c in $COMMANDS; do
  src="commands/$c.md"
  dst=".claude/commands/$c.md"

  if [ ! -f "$src" ]; then
    echo "missing source: $src" >&2
    stale=1
    continue
  fi

  if [ -f "$dst" ] && [ "$(cat "$src")" = "$(cat "$dst")" ]; then
    continue
  fi

  if [ "$CHECK" = "1" ]; then
    if [ -f "$dst" ]; then
      echo "stale: $dst" >&2
    else
      echo "no copy: $dst" >&2
    fi
    stale=1
    continue
  fi

  mkdir -p .claude/commands
  cp "$src" "$dst"
  echo "synced: $c (command)"
  copied=$((copied + 1))
done

# The other direction: a copy whose source is gone. The forward pass cannot see it — it
# iterates the sources — so a deleted skill leaves its copy live in this repo forever.
for d in .claude/skills/*/; do
  [ -d "$d" ] || continue
  s=$(basename "$d")
  [ -f "skills/$s/SKILL.md" ] && continue

  if [ -f "$d/SKILL.md" ] && grep -qF "$BANNER_MARK" "$d/SKILL.md"; then
    echo "orphan copy — source deleted: skills/$s/SKILL.md" >&2
    stale=1
  else
    echo "repo-local skill, not a copy: $d"
  fi
done

for f in .claude/commands/*.md; do
  [ -f "$f" ] || continue
  c=$(basename "$f")
  [ -f "commands/$c" ] || echo "repo-local command, not a copy: $f"
done

# #48's last requirement, made mechanical: every shipping skill is reachable from the
# product definition by its shipping path, with a mechanism number against it. A skill the
# registry does not name is one nothing traces to.
for s in $SKILLS; do
  row=$(grep -F "| \`skills/$s\` |" "$REGISTRY" 2>/dev/null)
  if [ -z "$row" ]; then
    echo "not in the registry's artifact table: skills/$s" >&2
    stale=1
  elif ! printf '%s' "$row" | grep -qE 'm[0-9]{2}'; then
    echo "no mechanism number in the registry row: skills/$s" >&2
    stale=1
  fi
done

if [ "$CHECK" = "1" ]; then
  [ "$stale" = "1" ] && { echo "run tools/sync-local-skills.sh" >&2; exit 1; }
  echo "local copies are current"
  exit 0
fi

[ "$stale" = "1" ] && exit 1

echo "$copied copied, $(($(echo $SKILLS | wc -w) + $(echo $COMMANDS | wc -w))) checked"
exit 0
