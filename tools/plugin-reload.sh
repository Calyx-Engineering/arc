#!/usr/bin/env bash
# Reload the locally-installed Arc plugin from this working tree.
#
# Installing copies the plugin into ~/.claude/plugins/cache/<marketplace>/<plugin>/<version>/,
# keyed by the version in .claude-plugin/plugin.json. A plain reinstall resolves the same
# version, reports "already installed", and serves the first cached snapshot — so local edits
# never load. `marketplace update` does not refresh it either.
#
# Uninstall does not delete the cache directory, but a reinstall overwrites it. That pair is
# the dev loop. Tested 2026-09-05 — see issue #132.
#
# A running session does NOT pick this up. Restart it after reloading.

set -euo pipefail

PLUGIN="${1:-arc@calyx-engineering}"

echo "Reloading ${PLUGIN} from the working tree..."
claude plugin uninstall "${PLUGIN}" --keep-data >/dev/null
claude plugin install   "${PLUGIN}" -y          >/dev/null
echo "Done. Restart any running Claude Code session to pick it up."
