# Issue #283 — README says what you type; the rest leave the menu

**Issue:** [#283](https://github.com/Calyx-Engineering/arc/issues/283)

## Problem

The `/` menu lists sixteen entries. Three are meant to be typed — `/arc-next`, `/arc-run`,
`/camp`. The other thirteen are shipping skills that fire on wording, but every one of them
also sits in the menu by default, because a skill that says nothing about `user-invocable`
inherits `true`. README.md said nothing about the split, so a reader saw sixteen typeable
entries.

## What changed

| | |
|---|---|
| **`README.md`** | New **Using Arc** section, right before **What Arc does**: a three-row table for the typed commands, a line stating skills fire on their own, and a thirteen-row FYI table — one line per skill, what it does when it fires |
| **`skills/*/SKILL.md`** | All 13 now carry an explicit `user-invocable` key. `false` on the ten that only fire on wording (`arc-intent`, `autonomy-set`, `chat-response`, `decompose`, `engineering-report`, `issue-write`, `record-route`, `relief-valve`, `spec-interview`, `work-watch`). `true` on the three a person also addresses by name (`camp`, `handoff`, `plugin-retrospective`) |
| **`tests/verify-skill-registry.sh`** | New check: every shipping skill must either declare `user-invocable` (either value) or ship its own `commands/<name>.md`. A skill with neither is a slash entry nobody decided on — the state all thirteen were in before this issue |

## Source and field name

`https://code.claude.com/docs/en/skills.md` names two frontmatter fields:
`disable-model-invocation` (stops Claude firing it automatically) and `user-invocable`
(hides it from the `/` menu). This issue is the second one — the skill still fires on
wording; only its slash-menu entry disappears.

## Decisions

| | |
|---|---|
| **The flag's presence is what's checked, not its value** | `camp`, `handoff` and `plugin-retrospective` have no dedicated `commands/<name>.md` (only `camp` does, coincidentally), so leaving them at the frontmatter default would make them indistinguishable from a skill nobody decided about. Writing `user-invocable: true` on all three makes "kept, on purpose" and "never considered" different states in the tree, and lets the registry check tell them apart mechanically |
| **The check lives in `tests/verify-skill-registry.sh`, not a new `tools/verify-skill-registry.sh`** | The issue names `tools/`, but the registry-row and command-shadow checks it extends already live in `tests/`. Splitting the same registry check across two files by name would be worse than the issue's own path being slightly off |
| **`case_is` and `case_row`'s fixtures were both given an explicit `user-invocable: true`** | Pass 2 found `case_row`'s two pre-existing fixtures (`registry-row-missing`, `registry-row-no-mech`) tripping the new check silently — right verdict today, but no longer an isolated test of the check they exist for. Fixed to match `case_is`, which had already been given the same fix |

## Review passes

Three sub-agent passes against the issue and the whole of every changed file:

- **Pass 1** — all four Required boxes satisfied; no defect found.
- **Pass 2** — found the `case_row` isolation gap above (latent, not a wrong verdict) and confirmed it independently by hand-building the fixture. Fixed; selftest re-run 12/12.
- **Pass 3** — re-audited all four boxes fresh against the tree, re-ran both `verify-skill-registry.sh` invocations, exit 0 both.

## Evidence

```
bash tests/verify-skill-registry.sh            # 5 passed, 0 failed
bash tests/verify-skill-registry.sh selftest   # 12 passed, 0 failed
bash tests/verify-all.sh                       # 73 gates, all clean
```

## Not done

Nothing named in Required was left undone.
