# Issue #132 — local edits never reach the installed plugin

> Dev-log, not a spec.

**Issue:** [#132](https://github.com/Calyx-Engineering/arc/issues/132)  ·  **PR:** [#137](https://github.com/Calyx-Engineering/arc/pull/137)

## Problem

Installing copies the plugin into `~/.claude/plugins/cache/<marketplace>/<plugin>/<version>/`,
keyed by the version in `plugin.json`. A reinstall after editing the tree resolved the same
version and re-served the first snapshot, so local edits never loaded — silently. `README.md`
documented the local route as *"edit, reinstall, retry — seconds instead of a release."*

## Intent and north star

| | |
|---|---|
| **What this issue is really for** | A working edit-and-see-it loop, so a plugin fix can be exercised in the repository that hit the friction |
| **North star** | An edit to a skill in this tree is loaded by the next session, by one command, with no version bump |
| **What makes it durable** | The command is a script with the reasoning in it. An incantation in a chat window is lost at session end |
| **Out of scope** | Making a running session pick up a reload. It does not, and the script says so |

## Decisions & trade-offs

**The issue's own first requirement was to test before fixing.** That was right — the fix
turned out to be neither of the two shapes the issue proposed.

| Test | Result |
|---|---|
| Plain reinstall after editing the tree | No-op. *"already installed"*, cache untouched |
| `claude plugin marketplace update calyx-engineering` | Succeeds, does not refresh the plugin cache |
| Does `uninstall` clear the cache entry? | **No.** The versioned directory survives intact |
| **uninstall + reinstall** | **Refreshes.** The reinstall overwrites the cached version in place |

Method: append a marker to `skills/handoff/SKILL.md`, run each candidate, `grep` the installed
copy for the marker. Marker reverted and the cache restored afterwards.

**So Shape B works and its stated dependency was false.** The issue said *"Shape B depends
entirely on uninstall clearing the cache. If it does not, there is no dev loop."* Uninstall does
not clear it, and the loop works regardless.

Consequences: no manifest change, `plugin.json` keeps `0.1.0`, and `release-process.md` §3's
*bump both manifests* stays correct.

## Rejected approaches

| | |
|---|---|
| **Shape A — strip `version` from the manifests** | Unnecessary once Shape B was shown to work. It would also have made `release-process.md` §3 wrong and left `main`'s manifest matching no tag |
| **Bumping the patch number per iteration** | Already rejected in the issue. A version bumped fifteen times in an afternoon is a reload button wearing a version's clothes |

## Retrospective

`tools/plugin-reload.sh` wraps the two commands and carries the reasoning, the test date and the
restart caveat in its header comment.

**One limit, tested and not solved:** a *running* session does not pick up a refreshed cache.
The script says to restart. Whether a restart is genuinely required, or only a session that has
already loaded the skill, was not isolated.

This unblocked the rest of arc 04 — every fix in the Dogfood milestone has to be exercised in the
repository that produced the friction, and that repository is served only by the installed plugin.
