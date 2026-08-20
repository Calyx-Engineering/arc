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

# Skills worth having live locally. Not every shipped skill — only the ones that
# shape how work is done in this repo.
SKILLS="chat-response spec-interview issue-write work-watch record-route handoff camp relief-valve decompose arc-intent"

# Commands have the same problem for the same reason: `commands/` is discovered through
# ${CLAUDE_PLUGIN_ROOT}, which resolves only for an installed plugin, and Claude Code
# discovers `.claude/commands/`. Copied verbatim — a command is short enough that a banner
# would be a third of the file, and `description:` is the first thing a reader sees.
COMMANDS="camp arc-next"

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

  # Rebuild what the copy should be: source with the banner after its frontmatter.
  expected=$(awk -v b="$banner" '
    BEGIN { fm = 0 }
    { print }
    /^---$/ { fm++; if (fm == 2) print b }
  ' "$src")

  if [ -f "$dst" ] && [ "$expected" = "$(cat "$dst")" ]; then
    continue
  fi

  if [ "$CHECK" = "1" ]; then
    echo "stale: $dst" >&2
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
    echo "stale: $dst" >&2
    stale=1
    continue
  fi

  mkdir -p .claude/commands
  cp "$src" "$dst"
  echo "synced: $c (command)"
  copied=$((copied + 1))
done

if [ "$CHECK" = "1" ]; then
  [ "$stale" = "1" ] && { echo "run tools/sync-local-skills.sh" >&2; exit 1; }
  echo "local copies are current"
  exit 0
fi

echo "$copied copied, $(($(echo $SKILLS | wc -w) + $(echo $COMMANDS | wc -w))) checked"
exit 0
