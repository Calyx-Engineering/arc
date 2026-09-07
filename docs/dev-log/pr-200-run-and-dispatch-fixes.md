# PR #200 — the run labels and ticks; the loop dispatches with permissions

**Issue:** none  ·  **PR:** [#200](https://github.com/Calyx-Engineering/arc/pull/200)

## Problem

The first real dispatch through `tools/arc-loop.sh` — [#155](https://github.com/Calyx-Engineering/arc/issues/155) under [#145](https://github.com/Calyx-Engineering/arc/issues/145), `--max 1`, 2026-09-07 — produced a complete six-section analysis and could save none of it. Nothing committed, no branch, no PR, the issue still open.

Four defects, found in the order they blocked the work.

| | |
|---|---|
| **The dispatch had no permission mode** | `claude -p` with no `--permission-mode`. A `-p` session cannot prompt, so every request outside `.claude/settings.json` auto-denied. That allowlist is six entries — `gh pr create\|merge\|edit`, `gh issue create\|edit`, `git push` — all the write path, none of the tools that produce anything to push. The run was authorised to merge a PR it had no permission to write |
| **`camp-session-start` denied while documenting that it does not** | Registered `PreToolUse`; `report()` exited 2. On `PreToolUse`, exit 2 is the deny signal. Its header said *"This hook never denies at all"* and *"the edit still runs"* — both false. It ate the first Edit of every session |
| **`branch-guard` did not know the direct-PR branch form** | Work branches matched `arc/*-issue-*` only. `arc/04-dogfood-pr200-slug` fell through to `arc/*)` and was classified coordination-only |
| **`camp-session-start` carried the same gap, separately** | Its own classification told a direct-PR branch to create `arc/04-dogfood-pr200-slug-issue-<N>-<slug>` |

The run's progress was also invisible while it ran. `run-instructions.md` wrote the checklist back in one batch at step 6 of 9, so an unattended run showed nothing in the tracker until nearly finished, and nothing at all if it stopped before then.

## Intent and north star

Make `/arc-run` able to complete an issue. Everything here is a blocker on that path or a direct consequence of one — no adjacent cleanup.

## Decisions & trade-offs

### Two switches are both called "mode"

The confusion is the root cause, so the fix names it in the file. `HANDOFF.md`'s Execution mode row governs commit, push, PR and merge through `hooks/mode-guard`. Claude Code's `--permission-mode` governs whether a run may call `Write`, `Edit` or `Bash` at all. `arc-loop.sh` set the first and not the second.

`PERMISSION_MODE` defaults to `auto`, overridable with `ARC_LOOP_PERMISSION_MODE` for a narrower grant while testing. The dry run prints it, so what would be dispatched is visible without dispatching.

### The segment, not the prefix

`branch-guard` and `camp-session-start` both now key on a numbered `-issue-` or `-pr` segment rather than on `arc/`. The prefix belongs to the operating agreement — a repo naming its own must still have its work branches recognised. The `arc/*)` coordination case still hardcodes it; that half is [#203](https://github.com/Calyx-Engineering/arc/issues/203).

Both bare forms (`issue-42-slug`, `pr200-slug`) are listed because a repo with no prefix has nothing before the hyphen. Those would have fallen through to the topic-branch case and still been allowed, so it is classification rather than permission — but a guard should not depend on its own catch-all staying permissive forever.

### A deliberate tightening, recorded because it is a behaviour change

`arc/<nn>-<slug>-issue-<non-numeric>` was allowed before and is denied now: `*-issue-[0-9]*` requires the number. An issue branch without its issue number is malformed, and the deny message names the correct form — but this narrows what the guard permits, and no existing branch was checked against it beyond this repo's.

### Ticking as the work proceeds, and what pass 3 becomes

Step 2 now ticks each box as it is satisfied. Pass 3 was the pass that ticked them; it becomes the pass that audits them against the tree and unticks any tick without evidence. Two rules that both said *tick the boxes* would have meant neither being done properly.

Each tick is one `gh issue edit --body`, so exposure to [#87](https://github.com/Calyx-Engineering/arc/issues/87) — a failed edit silently restores the original — goes from one per issue to one per box. Step 2 requires a read-back after every write. That narrows what #87 can cost; it does not fix it.

### The label removal rides both exits

`Done` and `Blocked`. A run that stops still stops, and a label left behind says work is underway when nothing is. `#0969DA`, not `#1D76DB` — `issue-discipline` already owns that one and the two would be indistinguishable in the list.

## Verification

| | |
|---|---|
| `tools/verify-hook.sh hooks/branch-guard` | 13 passed, 0 failed |
| `tools/arc-loop.sh 145 --dry-run` | Selects #155, prints `--permission-mode auto` |
| `hooks/camp-session-start`, by hand | Exit 0, valid JSON, `permissionDecision: allow`, message intact. Silent on both work-branch forms |

**Not verified.** The `--permission-mode` flag itself — it needs a real `--max 1` run. `tools/verify-hook.sh` covers no `-pr` branch, and cannot until it grows a `__FIXTURE_PR__`; its `report` verdict is `rc == 2` and nothing else, so it fails a `PreToolUse` hook that speaks up correctly. Both are changes to that file, which is on `CLAUDE.md`'s never-edited-autonomously list.

## Retrospective

**`--max 1` is what made this cheap.** The blocker was identical for all thirteen children of #145. One dispatch found it.

**Three guards refused the fix, and two of them were right.** `branch-guard` denied editing itself on the branch opened to edit it. The permission classifier denied both a Bash write to a hook and `touch ~/.claude/HOOKS_OFF`. The first is the bug being fixed here; the other two are the boundary holding.

**The kill switch failed at the moment it existed for.** Needed, attempted, landed at `r:\arc\HOOKS_OFF.txt` — wrong directory, wrong name, no effect. An extensionless file in a hidden folder, created with a verb PowerShell does not have, on a platform where Explorer appends `.txt`. [#202](https://github.com/Calyx-Engineering/arc/issues/202).

**Duplicated classification drifted.** Two hooks carried the same branch logic and the same gap. Fixing one would have left the other, and the second was found only because the first hook's own output was read after the fix.

## Spawned

| | |
|---|---|
| [#201](https://github.com/Calyx-Engineering/arc/issues/201) | `mode-guard` matches command strings, so anything committing from inside a script passes through Manual |
| [#202](https://github.com/Calyx-Engineering/arc/issues/202) | Replace the kill switch with a command |
| [#203](https://github.com/Calyx-Engineering/arc/issues/203) | `branch-guard` still hardcodes the `arc/` prefix |
