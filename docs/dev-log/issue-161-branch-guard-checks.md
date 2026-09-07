# Issue #161 — branch-guard gets its other two checks

**Issue:** [#161](https://github.com/Calyx-Engineering/arc/issues/161)  ·  **PR:** [#PR](https://github.com/Calyx-Engineering/arc/pull/PR)

## Problem

`hooks/branch-guard` shipped one of m10's three checks. Its own header said so — `skips: worktree-identity (not built), base-freshness (not built)` — and the two that were missing are the ones that catch the failure the issue names: a second unit landing on the first unit's branch, and edits made in a window opened for something else.

The arc's own loop makes both live. `tools/arc-loop.sh` puts each run in a worktree of its own while the orchestrator works in the main tree, and every run branch is cut from `arc/04-dogfood` while other runs merge into it.

## Intent and north star

The two missing checks, denying on conditions narrow enough to be right every time. m10's open questions were the design work: worktree identity had no session signal, and base freshness had no answer to noise.

## Decisions & trade-offs

### Worktree identity — same repository, different worktree

Nothing ties a Claude Code session to the worktree it was opened for, which is why m10 left this undesigned. It does not need one. The payload's `cwd` names the tree the session is in, so the condition is an **absolute** path resolving inside a *different worktree of the same repository* — `git rev-parse --show-toplevel` differs, `--git-common-dir` matches.

Same-repository is the whole restriction, and dropping it would have been a bad hook. `CLAUDE.md` requires `04-arc-execution-and-roles.md` to be edited in lodestar and arc in the same session, and agents edit `~/.claude/` constantly. Both are absolute paths outside the session's tree; neither is this hook's business. A relative path cannot land elsewhere at all, so it is not examined.

### Base freshness — said once per base commit

m10: *"Firing on every stale branch would be constant."* A guard nobody can work through gets switched off, so the deny is stamped under the worktree's own git dir, keyed on `<branch>-<base sha>`. The next merge into the base changes the sha and the guard speaks again; nothing else does.

**The stamp is written before the deny, and the deny only happens if the write succeeded.** A stamp that cannot be written means silence — the alternative is a branch nobody can edit, which is the dead session the fail-open rule exists to prevent.

The base comes from the branch name: `arc/04-dogfood-issue-161-slug` was cut from `arc/04-dogfood`. `origin/<base>` is preferred over the local ref, because what merged is a fact about the remote. A name with no prefix before the segment (`issue-42-slug`) names no base, and an absent ref ends the check.

### A second gate script, because verify-hook.sh may not be edited

`tools/verify-hook.sh` is hard-excluded from autonomous edits ([m10 §5](../product-architecture/mechanisms/m10-branch-guard.md)) — it validates hook changes, so a run making one does not change it. Its fixtures are three throwaway repos substituted into payloads by placeholder, and neither new check is expressible that way: the worktree check needs a *linked worktree*, the freshness check needs a base that has moved.

`tools/verify-workspace-guard.sh` carries those fixtures instead. It is registered in `verify-all.sh`, whose `KNOWN` cross-check would fail the run if it were not. The payload-expressible half — an edit in the session's own tree, one in a different repository, one outside any repository, a work branch with no base ref — stayed in `tools/hook-cases/branch-guard/`.

**Worth knowing:** `verify-hook.sh hooks/branch-guard` alone stays green if checks 2 and 3 are deleted. Its cases prove they do not misfire, not that they fire. The deny coverage is `verify-workspace-guard.sh`'s, and `verify-all.sh` runs both.

## What the review passes found

Pass 1 caught a lost backslash. The path normaliser was written as `tr '\\' '/'` and reached the file as `tr '\' '/'` — a single backslash, which GNU `tr` warns about and a stricter `tr` would read as an empty set. Windows path normalisation would have silently stopped working with every gate still green, because the deny cases the warning appears in are graded on the decision, not on stderr. It also caught the walk-up for a not-yet-existing directory resolving a dead drive to `.`, the hook's own cwd. The same escape was lost a second time in this very file's first draft, and the checklist audit caught it there.

Pass 2 caught the documentation half: m10 still said two checks were undesigned while the hook cited m10 as having decided them, and `docs/product-architecture/README.md` still had m10 at ⚪ (*"Not in Arc"*).

## Evidence

```text
bash tools/verify-hook.sh hooks/branch-guard   →  18 passed, 0 failed   (exit 0)
bash tools/verify-workspace-guard.sh           →  10 passed, 0 failed   (exit 0)
bash tools/verify-all.sh                       →  15 gates, all clean   (exit 0)
```

Baseline before the change: 14 gates, all clean; `branch-guard` 13 passed.

## Not done

**No soak.** The hook is registered, but the installed copy is only current after `tools/plugin-reload.sh`, so neither new check has fired in a live session. m10's row is 🔵, not ✅.

**Whether the guard denies or warns in a hardware repo** is still open — m10 says so. It denies, which is right for software.

## Also in this unit

| | |
|---|---|
| `docs/product-architecture/mechanisms/m10-branch-guard.md` | Status to built, the three-checks table's third column from precedent to what each was built as, and the two questions this unit answered moved out of *What is not decided* into *Decided in the build* |
| `docs/product-architecture/README.md` | m10's row ⚪ → 🔵. ⚪ reads *"Not in Arc"*, which a shipped hook contradicts |
| `docs/product-architecture/camp-reports.md` | Its worked example **is** `branch-guard`'s header, so it said both checks were not built. Synced — and the prose around it said the declaration sits directly under the one-line description, which no hook in this repo does. Reworded to what they all do: above the kill switch, last thing before the code |
| `CLAUDE.md` | *"runs all nine gates"* → *"runs every gate this repo has"*. It was nine; the run reports 15 |
