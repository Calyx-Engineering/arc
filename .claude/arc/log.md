# Event log — arc/03-camp

> **Append-only.** Every Arc artifact firing, recorded regardless of verbosity. Newest at the
> bottom. **Never edit or reorder an existing entry** — a correction is a new entry.
>
> Format and rules: [`templates/event-log.md`](../../templates/event-log.md) ·
> Spec: [m44](../../docs/product-architecture/mechanisms/m44-event-log.md)

**Arc:** `arc/03-camp` · **Rotated:** 2026-08-19 · **Previous:** none — this is the first

---

2026-08-19T09:14Z  issue-write  pr-open  pr=50
  checked: base-branch=arc/03-camp · milestone=Arc 03 · arc-prefix · closing-keyword — all set
  outcome: ok — Closes #27 bound
2026-08-19T09:41Z  issue-write  pr-open  pr=51 issue=39
  checked: base-branch=arc/03-camp · milestone=Arc 03 · arc-prefix · closing-keyword · placeholder-scan — all set
  outcome: ok — Closes #39 bound
2026-08-19T09:52Z  issue-write  pr-merge  pr=51 issue=39
  checked: closing-keyword-bound · branch-deleted
  outcome: ok
2026-09-08T12:37Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T12:37Z  handoff-archive  handoff-archived  tool=Bash
  checked: handoff-snapshot=archived — all ok
  outcome: repaired — took a copy before the overwrite
  skipped: user-authored-file-archived (the call names no file)
2026-09-08T12:37Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T12:37Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T12:37Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T12:37Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T12:37Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T12:37Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the argument is a flag, not a name
  skipped: base-is-arc (not built) · declared-convention-read (the argument is a flag, not a name) · issue-or-pr-number-present (the argument is a flag, not a name)
2026-09-08T12:37Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T12:37Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T12:37Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T12:37Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T12:37Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T12:37Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T12:37Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T12:37Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T12:37Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T12:37Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T12:37Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T12:37Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T12:37Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T12:37Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T12:37Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T12:37Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T12:37Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T12:37Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T12:37Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T12:37Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T12:37Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T12:37Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T12:38Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T12:38Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T12:38Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T12:38Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T12:38Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T12:38Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T12:38Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T12:38Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T12:38Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T12:38Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T12:38Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T12:38Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T12:38Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T12:38Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T12:38Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T12:38Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T12:38Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T12:38Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T12:38Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T12:38Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T12:38Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T12:38Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T12:38Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T12:38Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T12:38Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T12:38Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T12:38Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T12:38Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T12:38Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T12:38Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T12:38Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T12:38Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T12:38Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T12:38Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T12:38Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T12:38Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T12:38Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T12:38Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T12:38Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T12:38Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T12:38Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T12:38Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T12:38Z  tracker-verify  tracker-write
2026-09-08T12:38Z  camp-branch-check  branch-create
  checked: — none reached
  checked: — none reached
  outcome: ok — the command creates no branch
  outcome: ok — not a tracker write
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T12:38Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T12:38Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T12:38Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T12:38Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T12:38Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T12:38Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T12:38Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T12:38Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T12:38Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T12:38Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T12:39Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T12:39Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T12:39Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T12:39Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T12:39Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T12:39Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T12:39Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T12:39Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T12:39Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T12:39Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T12:39Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T12:39Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T12:39Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T12:39Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T12:39Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T12:39Z  tracker-verify  issue-write
  checked: — none reached
  outcome: ok — nothing to report
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T12:39Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T12:39Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T12:39Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T12:39Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T12:39Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T12:39Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T12:39Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T12:39Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T12:39Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T12:39Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T12:39Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T12:39Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T12:39Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T12:39Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T12:39Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T12:39Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the argument is a flag, not a name
  skipped: base-is-arc (not built) · declared-convention-read (the argument is a flag, not a name) · issue-or-pr-number-present (the argument is a flag, not a name)
2026-09-08T12:40Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T12:40Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T12:40Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T12:40Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T12:40Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T12:40Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T12:41Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T12:41Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T12:42Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T12:42Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T12:44Z  camp-session-start  session-start  branch=arc/04-dogfood-issue-199-box-disposition
  checked: branch-is-work · issue-in-branch-name — all ok
  outcome: ok — the branch is a work branch and names its issue
  skipped: arc-active (no arc registry exists yet)
2026-09-08T12:44Z  branch-guard  edit-checked  branch=arc/04-dogfood-issue-199-box-disposition
  checked: branch-kind=work · worktree-identity=own · base-freshness=current — all ok
  outcome: ok — nothing to report
  skipped: path-is-source (the branch is not a coordination branch)
2026-09-08T12:44Z  handoff-archive  handoff-archived  tool=Write
  checked: handoff-snapshot=nothing-to-copy · user-authored-file-archived=nothing-to-copy — all ok
  outcome: ok — nothing needed a copy
2026-09-08T12:44Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T12:44Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T12:44Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T12:44Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T12:45Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T12:45Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T12:45Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T12:45Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T12:45Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T12:45Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T12:45Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T12:45Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T12:45Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T12:45Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T12:45Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T12:45Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T12:45Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T12:45Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T12:45Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T12:45Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T12:45Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T12:45Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T12:45Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T12:45Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T12:45Z  camp-session-start  session-start
  checked: — none reached
  outcome: ok — already checked this session
  skipped: arc-active (no arc registry exists yet) · branch-is-work (already checked this session) · issue-in-branch-name (already checked this session)
2026-09-08T12:45Z  handoff-archive  handoff-archived  tool=Edit
  checked: handoff-snapshot=nothing-to-copy · user-authored-file-archived=nothing-to-copy — all ok
  outcome: ok — nothing needed a copy
2026-09-08T12:45Z  branch-guard  edit-checked  branch=arc/04-dogfood-issue-199-box-disposition
  checked: branch-kind=work · worktree-identity=own · base-freshness=current — all ok
  outcome: ok — nothing to report
  skipped: path-is-source (the branch is not a coordination branch)
2026-09-08T12:45Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T12:45Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T12:46Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T12:46Z  tracker-verify  issue-write
  checked: — none reached
  outcome: ok — nothing to report
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T12:46Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T12:46Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T12:46Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T12:46Z  tracker-verify  issue-write
  checked: — none reached
  outcome: ok — nothing to report
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T12:46Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T12:46Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T12:46Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T12:46Z  tracker-verify  issue-write
  checked: — none reached
  outcome: ok — nothing to report
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T12:46Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T12:46Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T12:46Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T12:46Z  tracker-verify  issue-write
  checked: — none reached
  outcome: ok — nothing to report
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T12:46Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T12:46Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T12:46Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T12:46Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T12:47Z  camp-session-start  session-start
  checked: — none reached
  outcome: ok — already checked this session
  skipped: arc-active (no arc registry exists yet) · branch-is-work (already checked this session) · issue-in-branch-name (already checked this session)
2026-09-08T12:47Z  handoff-archive  handoff-archived  tool=Edit
  checked: handoff-snapshot=nothing-to-copy · user-authored-file-archived=nothing-to-copy — all ok
  outcome: ok — nothing needed a copy
2026-09-08T12:47Z  branch-guard  edit-checked  branch=arc/04-dogfood-issue-199-box-disposition
  checked: branch-kind=work · worktree-identity=own · base-freshness=current — all ok
  outcome: ok — nothing to report
  skipped: path-is-source (the branch is not a coordination branch)
2026-09-08T12:47Z  camp-session-start  session-start
  checked: — none reached
  outcome: ok — already checked this session
  skipped: arc-active (no arc registry exists yet) · branch-is-work (already checked this session) · issue-in-branch-name (already checked this session)
2026-09-08T12:47Z  handoff-archive  handoff-archived  tool=Edit
  checked: handoff-snapshot=nothing-to-copy · user-authored-file-archived=nothing-to-copy — all ok
  outcome: ok — nothing needed a copy
2026-09-08T12:47Z  branch-guard  edit-checked  branch=arc/04-dogfood-issue-199-box-disposition
  checked: branch-kind=work · worktree-identity=own · base-freshness=current — all ok
  outcome: ok — nothing to report
  skipped: path-is-source (the branch is not a coordination branch)
2026-09-08T12:47Z  camp-session-start  session-start
  checked: — none reached
  outcome: ok — already checked this session
  skipped: arc-active (no arc registry exists yet) · branch-is-work (already checked this session) · issue-in-branch-name (already checked this session)
2026-09-08T12:47Z  handoff-archive  handoff-archived  tool=Edit
  checked: handoff-snapshot=nothing-to-copy · user-authored-file-archived=nothing-to-copy — all ok
  outcome: ok — nothing needed a copy
2026-09-08T12:47Z  branch-guard  edit-checked  branch=arc/04-dogfood-issue-199-box-disposition
  checked: branch-kind=work · worktree-identity=own · base-freshness=current — all ok
  outcome: ok — nothing to report
  skipped: path-is-source (the branch is not a coordination branch)
2026-09-08T12:47Z  camp-session-start  session-start
  checked: — none reached
  outcome: ok — already checked this session
  skipped: arc-active (no arc registry exists yet) · branch-is-work (already checked this session) · issue-in-branch-name (already checked this session)
2026-09-08T12:47Z  handoff-archive  handoff-archived  tool=Edit
  checked: handoff-snapshot=nothing-to-copy · user-authored-file-archived=nothing-to-copy — all ok
  outcome: ok — nothing needed a copy
2026-09-08T12:47Z  branch-guard  edit-checked  branch=arc/04-dogfood-issue-199-box-disposition
  checked: branch-kind=work · worktree-identity=own · base-freshness=current — all ok
  outcome: ok — nothing to report
  skipped: path-is-source (the branch is not a coordination branch)
2026-09-08T12:47Z  camp-session-start  session-start
  checked: — none reached
  outcome: ok — already checked this session
  skipped: arc-active (no arc registry exists yet) · branch-is-work (already checked this session) · issue-in-branch-name (already checked this session)
2026-09-08T12:47Z  handoff-archive  handoff-archived  tool=Edit
  checked: handoff-snapshot=nothing-to-copy · user-authored-file-archived=nothing-to-copy — all ok
  outcome: ok — nothing needed a copy
2026-09-08T12:47Z  branch-guard  edit-checked  branch=arc/04-dogfood-issue-199-box-disposition
  checked: branch-kind=work · worktree-identity=own · base-freshness=current — all ok
  outcome: ok — nothing to report
  skipped: path-is-source (the branch is not a coordination branch)
2026-09-08T12:47Z  camp-session-start  session-start
  checked: — none reached
  outcome: ok — already checked this session
  skipped: arc-active (no arc registry exists yet) · branch-is-work (already checked this session) · issue-in-branch-name (already checked this session)
2026-09-08T12:47Z  handoff-archive  handoff-archived  tool=Edit
  checked: handoff-snapshot=nothing-to-copy · user-authored-file-archived=nothing-to-copy — all ok
  outcome: ok — nothing needed a copy
2026-09-08T12:47Z  branch-guard  edit-checked  branch=arc/04-dogfood-issue-199-box-disposition
  checked: branch-kind=work · worktree-identity=own · base-freshness=current — all ok
  outcome: ok — nothing to report
  skipped: path-is-source (the branch is not a coordination branch)
2026-09-08T12:48Z  camp-session-start  session-start
  checked: — none reached
  outcome: ok — already checked this session
  skipped: arc-active (no arc registry exists yet) · branch-is-work (already checked this session) · issue-in-branch-name (already checked this session)
2026-09-08T12:48Z  handoff-archive  handoff-archived  tool=Edit
  checked: handoff-snapshot=nothing-to-copy · user-authored-file-archived=nothing-to-copy — all ok
  outcome: ok — nothing needed a copy
2026-09-08T12:48Z  branch-guard  edit-checked  branch=arc/04-dogfood-issue-199-box-disposition
  checked: branch-kind=work · worktree-identity=own · base-freshness=current — all ok
  outcome: ok — nothing to report
  skipped: path-is-source (the branch is not a coordination branch)
2026-09-08T12:48Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T12:48Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T12:48Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T12:48Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T12:48Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T12:48Z  mode-guard  mode-check
  checked: gating-command=yes · mode-row=autonomous — all ok
  outcome: ok — autonomous — the command is allowed
2026-09-08T12:48Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T12:48Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T12:48Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T12:48Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T12:48Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T12:48Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T12:48Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T12:48Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T12:49Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T12:49Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T12:49Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T12:49Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T12:50Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T12:50Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T12:50Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T12:50Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T12:50Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T12:50Z  tracker-verify  issue-write
  checked: — none reached
  outcome: ok — nothing to report
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T12:50Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T12:50Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T12:50Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T12:50Z  tracker-verify  issue-write
  checked: — none reached
  outcome: ok — nothing to report
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T12:50Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T12:50Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T12:50Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T12:50Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T12:51Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T12:51Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T12:51Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T12:51Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T12:51Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T12:51Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T12:51Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T12:51Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T12:51Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T12:51Z  mode-guard  mode-check
  checked: gating-command=yes · mode-row=autonomous — all ok
  outcome: ok — autonomous — the command is allowed
2026-09-08T12:51Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T12:51Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T12:51Z  camp-session-start  session-start
  checked: — none reached
  outcome: ok — already checked this session
  skipped: arc-active (no arc registry exists yet) · branch-is-work (already checked this session) · issue-in-branch-name (already checked this session)
2026-09-08T12:51Z  handoff-archive  handoff-archived  tool=Edit
  checked: handoff-snapshot=nothing-to-copy · user-authored-file-archived=nothing-to-copy — all ok
  outcome: ok — nothing needed a copy
2026-09-08T12:51Z  branch-guard  edit-checked  branch=arc/04-dogfood-issue-199-box-disposition
  checked: branch-kind=work · worktree-identity=own · base-freshness=current — all ok
  outcome: ok — nothing to report
  skipped: path-is-source (the branch is not a coordination branch)
2026-09-08T12:51Z  camp-session-start  session-start
  checked: — none reached
  outcome: ok — already checked this session
  skipped: arc-active (no arc registry exists yet) · branch-is-work (already checked this session) · issue-in-branch-name (already checked this session)
2026-09-08T12:51Z  handoff-archive  handoff-archived  tool=Edit
  checked: handoff-snapshot=nothing-to-copy · user-authored-file-archived=nothing-to-copy — all ok
  outcome: ok — nothing needed a copy
2026-09-08T12:51Z  branch-guard  edit-checked  branch=arc/04-dogfood-issue-199-box-disposition
  checked: branch-kind=work · worktree-identity=own · base-freshness=current — all ok
  outcome: ok — nothing to report
  skipped: path-is-source (the branch is not a coordination branch)
2026-09-08T12:51Z  camp-session-start  session-start
  checked: — none reached
  outcome: ok — already checked this session
  skipped: arc-active (no arc registry exists yet) · branch-is-work (already checked this session) · issue-in-branch-name (already checked this session)
2026-09-08T12:51Z  handoff-archive  handoff-archived  tool=Edit
  checked: handoff-snapshot=nothing-to-copy · user-authored-file-archived=nothing-to-copy — all ok
  outcome: ok — nothing needed a copy
2026-09-08T12:51Z  branch-guard  edit-checked  branch=arc/04-dogfood-issue-199-box-disposition
  checked: branch-kind=work · worktree-identity=own · base-freshness=current — all ok
  outcome: ok — nothing to report
  skipped: path-is-source (the branch is not a coordination branch)
2026-09-08T12:51Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T12:51Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T12:53Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T12:53Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T12:53Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T12:53Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T12:53Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T12:53Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T12:53Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T12:53Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T13:02Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T13:02Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T13:02Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T13:02Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T13:02Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T13:02Z  tracker-verify  issue-write
  checked: — none reached
  outcome: ok — nothing to report
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T13:02Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T13:02Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T13:02Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T13:02Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T13:03Z  camp-session-start  session-start
  checked: — none reached
  outcome: ok — already checked this session
  skipped: arc-active (no arc registry exists yet) · branch-is-work (already checked this session) · issue-in-branch-name (already checked this session)
2026-09-08T13:03Z  handoff-archive  handoff-archived  tool=Write
  checked: handoff-snapshot=nothing-to-copy · user-authored-file-archived=nothing-to-copy — all ok
  outcome: ok — nothing needed a copy
2026-09-08T13:03Z  branch-guard  edit-checked  branch=arc/04-dogfood-issue-199-box-disposition
  checked: branch-kind=work · worktree-identity=own · base-freshness=current — all ok
  outcome: ok — nothing to report
  skipped: path-is-source (the branch is not a coordination branch)
2026-09-08T13:03Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T13:03Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T13:03Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T13:03Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T13:03Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T13:03Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T13:03Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T13:03Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T13:03Z  camp-session-start  session-start
  checked: — none reached
  outcome: ok — already checked this session
  skipped: arc-active (no arc registry exists yet) · branch-is-work (already checked this session) · issue-in-branch-name (already checked this session)
2026-09-08T13:03Z  handoff-archive  handoff-archived  tool=Edit
  checked: handoff-snapshot=nothing-to-copy · user-authored-file-archived=nothing-to-copy — all ok
  outcome: ok — nothing needed a copy
2026-09-08T13:03Z  branch-guard  edit-checked  branch=arc/04-dogfood-issue-199-box-disposition
  checked: branch-kind=work · worktree-identity=own · base-freshness=current — all ok
  outcome: ok — nothing to report
  skipped: path-is-source (the branch is not a coordination branch)
2026-09-08T13:04Z  camp-session-start  session-start
  checked: — none reached
  outcome: ok — already checked this session
  skipped: arc-active (no arc registry exists yet) · branch-is-work (already checked this session) · issue-in-branch-name (already checked this session)
2026-09-08T13:04Z  handoff-archive  handoff-archived  tool=Edit
  checked: handoff-snapshot=nothing-to-copy · user-authored-file-archived=nothing-to-copy — all ok
  outcome: ok — nothing needed a copy
2026-09-08T13:04Z  branch-guard  edit-checked  branch=arc/04-dogfood-issue-199-box-disposition
  checked: branch-kind=work · worktree-identity=own · base-freshness=current — all ok
  outcome: ok — nothing to report
  skipped: path-is-source (the branch is not a coordination branch)
2026-09-08T13:04Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T13:04Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T13:04Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T13:04Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T13:04Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T13:04Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T13:04Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T13:04Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T13:04Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T13:04Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T13:04Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T13:04Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T13:04Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T13:04Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T13:04Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T13:04Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T13:04Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T13:04Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T13:05Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T13:05Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T13:05Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T13:05Z  mode-guard  mode-check
  checked: gating-command=yes · mode-row=autonomous — all ok
  outcome: ok — autonomous — the command is allowed
2026-09-08T13:05Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T13:05Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T13:06Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T13:06Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T13:06Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T13:06Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T13:07Z  camp-session-start  session-start
  checked: — none reached
  outcome: ok — already checked this session
  skipped: arc-active (no arc registry exists yet) · branch-is-work (already checked this session) · issue-in-branch-name (already checked this session)
2026-09-08T13:07Z  handoff-archive  handoff-archived  tool=Edit
  checked: handoff-snapshot=nothing-to-copy · user-authored-file-archived=nothing-to-copy — all ok
  outcome: ok — nothing needed a copy
2026-09-08T13:07Z  branch-guard  edit-checked  branch=arc/04-dogfood-issue-199-box-disposition
  checked: branch-kind=work · worktree-identity=own · base-freshness=current — all ok
  outcome: ok — nothing to report
  skipped: path-is-source (the branch is not a coordination branch)
2026-09-08T13:07Z  camp-session-start  session-start
  checked: — none reached
  outcome: ok — already checked this session
  skipped: arc-active (no arc registry exists yet) · branch-is-work (already checked this session) · issue-in-branch-name (already checked this session)
2026-09-08T13:07Z  handoff-archive  handoff-archived  tool=Edit
  checked: handoff-snapshot=nothing-to-copy · user-authored-file-archived=nothing-to-copy — all ok
  outcome: ok — nothing needed a copy
2026-09-08T13:07Z  branch-guard  edit-checked  branch=arc/04-dogfood-issue-199-box-disposition
  checked: branch-kind=work · worktree-identity=own · base-freshness=current — all ok
  outcome: ok — nothing to report
  skipped: path-is-source (the branch is not a coordination branch)
2026-09-08T13:07Z  camp-session-start  session-start
  checked: — none reached
  outcome: ok — already checked this session
  skipped: arc-active (no arc registry exists yet) · branch-is-work (already checked this session) · issue-in-branch-name (already checked this session)
2026-09-08T13:07Z  handoff-archive  handoff-archived  tool=Edit
  checked: handoff-snapshot=nothing-to-copy · user-authored-file-archived=nothing-to-copy — all ok
  outcome: ok — nothing needed a copy
2026-09-08T13:07Z  branch-guard  edit-checked  branch=arc/04-dogfood-issue-199-box-disposition
  checked: branch-kind=work · worktree-identity=own · base-freshness=current — all ok
  outcome: ok — nothing to report
  skipped: path-is-source (the branch is not a coordination branch)
2026-09-08T13:07Z  camp-session-start  session-start
  checked: — none reached
  outcome: ok — already checked this session
  skipped: arc-active (no arc registry exists yet) · branch-is-work (already checked this session) · issue-in-branch-name (already checked this session)
2026-09-08T13:07Z  handoff-archive  handoff-archived  tool=Edit
  checked: handoff-snapshot=nothing-to-copy · user-authored-file-archived=nothing-to-copy — all ok
  outcome: ok — nothing needed a copy
2026-09-08T13:07Z  branch-guard  edit-checked  branch=arc/04-dogfood-issue-199-box-disposition
  checked: branch-kind=work · worktree-identity=own · base-freshness=current — all ok
  outcome: ok — nothing to report
  skipped: path-is-source (the branch is not a coordination branch)
2026-09-08T13:07Z  camp-session-start  session-start
  checked: — none reached
  outcome: ok — already checked this session
  skipped: arc-active (no arc registry exists yet) · branch-is-work (already checked this session) · issue-in-branch-name (already checked this session)
2026-09-08T13:07Z  handoff-archive  handoff-archived  tool=Edit
  checked: handoff-snapshot=nothing-to-copy · user-authored-file-archived=nothing-to-copy — all ok
  outcome: ok — nothing needed a copy
2026-09-08T13:07Z  branch-guard  edit-checked  branch=arc/04-dogfood-issue-199-box-disposition
  checked: branch-kind=work · worktree-identity=own · base-freshness=current — all ok
  outcome: ok — nothing to report
  skipped: path-is-source (the branch is not a coordination branch)
2026-09-08T13:08Z  camp-session-start  session-start
  checked: — none reached
  outcome: ok — already checked this session
  skipped: arc-active (no arc registry exists yet) · branch-is-work (already checked this session) · issue-in-branch-name (already checked this session)
2026-09-08T13:08Z  handoff-archive  handoff-archived  tool=Edit
  checked: handoff-snapshot=nothing-to-copy · user-authored-file-archived=nothing-to-copy — all ok
  outcome: ok — nothing needed a copy
2026-09-08T13:08Z  branch-guard  edit-checked  branch=arc/04-dogfood-issue-199-box-disposition
  checked: branch-kind=work · worktree-identity=own · base-freshness=current — all ok
  outcome: ok — nothing to report
  skipped: path-is-source (the branch is not a coordination branch)
2026-09-08T13:08Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T13:08Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T13:08Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T13:08Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T13:08Z  camp-session-start  session-start
  checked: — none reached
  outcome: ok — already checked this session
  skipped: arc-active (no arc registry exists yet) · branch-is-work (already checked this session) · issue-in-branch-name (already checked this session)
2026-09-08T13:08Z  handoff-archive  handoff-archived  tool=Edit
  checked: handoff-snapshot=nothing-to-copy · user-authored-file-archived=nothing-to-copy — all ok
  outcome: ok — nothing needed a copy
2026-09-08T13:08Z  branch-guard  edit-checked  branch=arc/04-dogfood-issue-199-box-disposition
  checked: branch-kind=work · worktree-identity=own · base-freshness=current — all ok
  outcome: ok — nothing to report
  skipped: path-is-source (the branch is not a coordination branch)
2026-09-08T13:08Z  camp-session-start  session-start
  checked: — none reached
  outcome: ok — already checked this session
  skipped: arc-active (no arc registry exists yet) · branch-is-work (already checked this session) · issue-in-branch-name (already checked this session)
2026-09-08T13:08Z  handoff-archive  handoff-archived  tool=Edit
  checked: handoff-snapshot=nothing-to-copy · user-authored-file-archived=nothing-to-copy — all ok
  outcome: ok — nothing needed a copy
2026-09-08T13:08Z  branch-guard  edit-checked  branch=arc/04-dogfood-issue-199-box-disposition
  checked: branch-kind=work · worktree-identity=own · base-freshness=current — all ok
  outcome: ok — nothing to report
  skipped: path-is-source (the branch is not a coordination branch)
2026-09-08T13:08Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T13:08Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T13:08Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T13:08Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T13:08Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T13:08Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T13:08Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T13:08Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T13:08Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T13:08Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T13:08Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T13:08Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T13:08Z  camp-session-start  session-start
  checked: — none reached
  outcome: ok — already checked this session
  skipped: arc-active (no arc registry exists yet) · branch-is-work (already checked this session) · issue-in-branch-name (already checked this session)
2026-09-08T13:08Z  handoff-archive  handoff-archived  tool=Edit
  checked: handoff-snapshot=nothing-to-copy · user-authored-file-archived=nothing-to-copy — all ok
  outcome: ok — nothing needed a copy
2026-09-08T13:08Z  branch-guard  edit-checked  branch=arc/04-dogfood-issue-199-box-disposition
  checked: branch-kind=work · worktree-identity=own · base-freshness=current — all ok
  outcome: ok — nothing to report
  skipped: path-is-source (the branch is not a coordination branch)
2026-09-08T13:09Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T13:09Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T13:09Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T13:09Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T13:10Z  camp-session-start  session-start
  checked: — none reached
  outcome: ok — already checked this session
  skipped: arc-active (no arc registry exists yet) · branch-is-work (already checked this session) · issue-in-branch-name (already checked this session)
2026-09-08T13:10Z  handoff-archive  handoff-archived  tool=Edit
  checked: handoff-snapshot=nothing-to-copy · user-authored-file-archived=nothing-to-copy — all ok
  outcome: ok — nothing needed a copy
2026-09-08T13:10Z  branch-guard  edit-checked  branch=arc/04-dogfood-issue-199-box-disposition
  checked: branch-kind=work · worktree-identity=own · base-freshness=current — all ok
  outcome: ok — nothing to report
  skipped: path-is-source (the branch is not a coordination branch)
2026-09-08T13:10Z  camp-session-start  session-start
  checked: — none reached
  outcome: ok — already checked this session
  skipped: arc-active (no arc registry exists yet) · branch-is-work (already checked this session) · issue-in-branch-name (already checked this session)
2026-09-08T13:10Z  handoff-archive  handoff-archived  tool=Edit
  checked: handoff-snapshot=nothing-to-copy · user-authored-file-archived=nothing-to-copy — all ok
  outcome: ok — nothing needed a copy
2026-09-08T13:10Z  branch-guard  edit-checked  branch=arc/04-dogfood-issue-199-box-disposition
  checked: branch-kind=work · worktree-identity=own · base-freshness=current — all ok
  outcome: ok — nothing to report
  skipped: path-is-source (the branch is not a coordination branch)
2026-09-08T13:10Z  camp-session-start  session-start
  checked: — none reached
  outcome: ok — already checked this session
  skipped: arc-active (no arc registry exists yet) · branch-is-work (already checked this session) · issue-in-branch-name (already checked this session)
2026-09-08T13:10Z  handoff-archive  handoff-archived  tool=Edit
  checked: handoff-snapshot=nothing-to-copy · user-authored-file-archived=nothing-to-copy — all ok
  outcome: ok — nothing needed a copy
2026-09-08T13:10Z  branch-guard  edit-checked  branch=arc/04-dogfood-issue-199-box-disposition
  checked: branch-kind=work · worktree-identity=own · base-freshness=current — all ok
  outcome: ok — nothing to report
  skipped: path-is-source (the branch is not a coordination branch)
2026-09-08T13:10Z  camp-session-start  session-start
  checked: — none reached
  outcome: ok — already checked this session
  skipped: arc-active (no arc registry exists yet) · branch-is-work (already checked this session) · issue-in-branch-name (already checked this session)
2026-09-08T13:10Z  handoff-archive  handoff-archived  tool=Edit
  checked: handoff-snapshot=nothing-to-copy · user-authored-file-archived=nothing-to-copy — all ok
  outcome: ok — nothing needed a copy
2026-09-08T13:10Z  branch-guard  edit-checked  branch=arc/04-dogfood-issue-199-box-disposition
  checked: branch-kind=work · worktree-identity=own · base-freshness=current — all ok
  outcome: ok — nothing to report
  skipped: path-is-source (the branch is not a coordination branch)
2026-09-08T13:10Z  camp-session-start  session-start
  checked: — none reached
  outcome: ok — already checked this session
  skipped: arc-active (no arc registry exists yet) · branch-is-work (already checked this session) · issue-in-branch-name (already checked this session)
2026-09-08T13:10Z  handoff-archive  handoff-archived  tool=Edit
  checked: handoff-snapshot=nothing-to-copy · user-authored-file-archived=nothing-to-copy — all ok
  outcome: ok — nothing needed a copy
2026-09-08T13:10Z  branch-guard  edit-checked  branch=arc/04-dogfood-issue-199-box-disposition
  checked: branch-kind=work · worktree-identity=own · base-freshness=current — all ok
  outcome: ok — nothing to report
  skipped: path-is-source (the branch is not a coordination branch)
2026-09-08T13:10Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T13:10Z  mode-guard  mode-check
  checked: gating-command=yes · mode-row=autonomous — all ok
  outcome: ok — autonomous — the command is allowed
2026-09-08T13:10Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T13:10Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T13:10Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T13:10Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T13:11Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T13:11Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T13:12Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T13:12Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T13:12Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T13:12Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T13:12Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T13:12Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T13:12Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T13:12Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T13:12Z  camp-session-start  session-start
  checked: — none reached
  outcome: ok — already checked this session
  skipped: arc-active (no arc registry exists yet) · branch-is-work (already checked this session) · issue-in-branch-name (already checked this session)
2026-09-08T13:12Z  handoff-archive  handoff-archived  tool=Edit
  checked: handoff-snapshot=nothing-to-copy · user-authored-file-archived=nothing-to-copy — all ok
  outcome: ok — nothing needed a copy
2026-09-08T13:12Z  branch-guard  edit-checked  branch=arc/04-dogfood-issue-199-box-disposition
  checked: branch-kind=work · worktree-identity=own · base-freshness=current — all ok
  outcome: ok — nothing to report
  skipped: path-is-source (the branch is not a coordination branch)
2026-09-08T13:12Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T13:12Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T13:14Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T13:14Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T13:14Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T13:14Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T13:15Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T13:15Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T13:15Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T13:15Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T13:15Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T13:15Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T13:15Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T13:15Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T13:16Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T13:16Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T13:16Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T13:16Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T13:16Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T13:16Z  tracker-verify  issue-write
  checked: — none reached
  outcome: ok — nothing to report
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T13:16Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T13:16Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T13:16Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T13:16Z  tracker-verify  issue-write
  checked: — none reached
  outcome: ok — nothing to report
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T13:16Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T13:16Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T13:16Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T13:16Z  tracker-verify  issue-write
  checked: — none reached
  outcome: ok — nothing to report
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T13:16Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T13:16Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T13:16Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T13:16Z  tracker-verify  issue-write
  checked: — none reached
  outcome: ok — nothing to report
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T13:16Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T13:16Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T13:16Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T13:16Z  tracker-verify  issue-write
  checked: — none reached
  outcome: ok — nothing to report
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T13:16Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T13:16Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T13:16Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T13:16Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T13:16Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T13:16Z  mode-guard  mode-check
  checked: gating-command=yes · mode-row=autonomous — all ok
  outcome: ok — autonomous — the command is allowed
2026-09-08T13:17Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T13:17Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T13:17Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T13:17Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T13:17Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T13:17Z  tracker-verify  issue-write
  checked: — none reached
  outcome: ok — nothing to report
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T13:17Z  camp-session-start  session-start
  checked: — none reached
  outcome: ok — already checked this session
  skipped: arc-active (no arc registry exists yet) · branch-is-work (already checked this session) · issue-in-branch-name (already checked this session)
2026-09-08T13:17Z  handoff-archive  handoff-archived  tool=Write
  checked: handoff-snapshot=nothing-to-copy · user-authored-file-archived=nothing-to-copy — all ok
  outcome: ok — nothing needed a copy
2026-09-08T13:17Z  branch-guard  edit-checked  branch=arc/04-dogfood-issue-199-box-disposition
  checked: branch-kind=work · worktree-identity=own · base-freshness=current — all ok
  outcome: ok — nothing to report
  skipped: path-is-source (the branch is not a coordination branch)
2026-09-08T13:17Z  camp-session-start  session-start
  checked: — none reached
  outcome: ok — already checked this session
  skipped: arc-active (no arc registry exists yet) · branch-is-work (already checked this session) · issue-in-branch-name (already checked this session)
2026-09-08T13:17Z  handoff-archive  handoff-archived  tool=Edit
  checked: handoff-snapshot=nothing-to-copy · user-authored-file-archived=nothing-to-copy — all ok
  outcome: ok — nothing needed a copy
2026-09-08T13:17Z  branch-guard  edit-checked  branch=arc/04-dogfood-issue-199-box-disposition
  checked: branch-kind=work · worktree-identity=own · base-freshness=current — all ok
  outcome: ok — nothing to report
  skipped: path-is-source (the branch is not a coordination branch)
2026-09-08T13:17Z  camp-session-start  session-start
  checked: — none reached
  outcome: ok — already checked this session
  skipped: arc-active (no arc registry exists yet) · branch-is-work (already checked this session) · issue-in-branch-name (already checked this session)
2026-09-08T13:17Z  handoff-archive  handoff-archived  tool=Edit
  checked: handoff-snapshot=nothing-to-copy · user-authored-file-archived=nothing-to-copy — all ok
  outcome: ok — nothing needed a copy
2026-09-08T13:17Z  branch-guard  edit-checked  branch=arc/04-dogfood-issue-199-box-disposition
  checked: branch-kind=work · worktree-identity=own · base-freshness=current — all ok
  outcome: ok — nothing to report
  skipped: path-is-source (the branch is not a coordination branch)
2026-09-08T13:18Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T13:18Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T13:24Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T13:24Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T13:24Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T13:24Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T13:24Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T13:24Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T13:25Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T13:25Z  mode-guard  mode-check
  checked: gating-command=yes · mode-row=autonomous — all ok
  outcome: ok — autonomous — the command is allowed
2026-09-08T13:25Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T13:25Z  tracker-verify  issue-write
  checked: — none reached
  outcome: ok — nothing to report
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T13:25Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T13:25Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T13:25Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T13:25Z  tracker-verify  issue-write
  checked: — none reached
  outcome: ok — nothing to report
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T13:25Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T13:25Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T13:25Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T13:25Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T13:27Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T13:27Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T13:27Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T13:27Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T13:27Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T13:27Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T13:27Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T13:27Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T13:27Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T13:27Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T13:27Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T13:27Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T13:27Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T13:27Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T13:27Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T13:27Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T13:29Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T13:29Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T13:29Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T13:29Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T13:29Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T13:29Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T13:29Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T13:29Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T13:29Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T13:29Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T13:29Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T13:29Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T13:29Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T13:29Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T13:29Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T13:29Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T13:29Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T13:29Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T13:29Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T13:29Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T13:29Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T13:29Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T13:29Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T13:29Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T13:30Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T13:30Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T13:30Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T13:30Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T13:30Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T13:30Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T13:30Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T13:30Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T13:30Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T13:30Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T13:30Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T13:30Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T13:30Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T13:30Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T13:30Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T13:30Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T13:30Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T13:30Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T13:30Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T13:30Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T13:30Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T13:30Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T13:30Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T13:30Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T13:30Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T13:30Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T13:30Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T13:30Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T13:30Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T13:30Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T13:30Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T13:30Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T13:30Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T13:30Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T13:30Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T13:30Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T13:30Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T13:30Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T13:30Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T13:30Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T13:30Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T13:30Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T13:30Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T13:30Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T13:31Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T13:31Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T13:31Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T13:31Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T13:31Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T13:31Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T13:31Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T13:31Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T13:32Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T13:32Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T13:32Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T13:32Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T13:32Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T13:32Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T13:32Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T13:32Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T13:32Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T13:32Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T13:33Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T13:33Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T13:33Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T13:33Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T13:33Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T13:33Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T13:33Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T13:33Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T13:34Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T13:34Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T13:34Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T13:34Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T13:34Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T13:34Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T13:34Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T13:34Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T13:35Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T13:35Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T13:35Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T13:35Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T13:35Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T13:35Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T13:35Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T13:35Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T13:35Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T13:35Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T13:35Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T13:35Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T13:37Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T13:37Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T13:37Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T13:37Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T13:37Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T13:37Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T13:37Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T13:37Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T13:38Z  camp-session-start  session-start
  checked: — none reached
  outcome: ok — already checked this session
  skipped: arc-active (no arc registry exists yet) · branch-is-work (already checked this session) · issue-in-branch-name (already checked this session)
2026-09-08T13:38Z  handoff-archive  handoff-archived  tool=Edit
  checked: handoff-snapshot=nothing-to-copy · user-authored-file-archived=nothing-to-copy — all ok
  outcome: ok — nothing needed a copy
2026-09-08T13:38Z  branch-guard  edit-checked  branch=arc/04-dogfood-issue-199-box-disposition
  checked: branch-kind=work · worktree-identity=own · base-freshness=current — all ok
  outcome: ok — nothing to report
  skipped: path-is-source (the branch is not a coordination branch)
2026-09-08T13:39Z  camp-session-start  session-start
  checked: — none reached
  outcome: ok — already checked this session
  skipped: arc-active (no arc registry exists yet) · branch-is-work (already checked this session) · issue-in-branch-name (already checked this session)
2026-09-08T13:39Z  handoff-archive  handoff-archived  tool=Edit
  checked: handoff-snapshot=nothing-to-copy · user-authored-file-archived=nothing-to-copy — all ok
  outcome: ok — nothing needed a copy
2026-09-08T13:39Z  branch-guard  edit-checked  branch=arc/04-dogfood-issue-199-box-disposition
  checked: branch-kind=work · worktree-identity=own · base-freshness=current — all ok
  outcome: ok — nothing to report
  skipped: path-is-source (the branch is not a coordination branch)
2026-09-08T13:39Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T13:39Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T13:39Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T13:39Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T13:39Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T13:39Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T13:39Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T13:39Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T13:39Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T13:39Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T13:39Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T13:39Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T13:39Z  camp-session-start  session-start
  checked: — none reached
  outcome: ok — already checked this session
  skipped: arc-active (no arc registry exists yet) · branch-is-work (already checked this session) · issue-in-branch-name (already checked this session)
2026-09-08T13:39Z  handoff-archive  handoff-archived  tool=Edit
  checked: handoff-snapshot=nothing-to-copy · user-authored-file-archived=nothing-to-copy — all ok
  outcome: ok — nothing needed a copy
2026-09-08T13:39Z  branch-guard  edit-checked  branch=arc/04-dogfood-issue-199-box-disposition
  checked: branch-kind=work · worktree-identity=own · base-freshness=current — all ok
  outcome: ok — nothing to report
  skipped: path-is-source (the branch is not a coordination branch)
2026-09-08T13:39Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T13:39Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T13:40Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T13:40Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T13:40Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T13:40Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T13:40Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T13:40Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T13:40Z  camp-session-start  session-start
  checked: — none reached
  outcome: ok — already checked this session
  skipped: arc-active (no arc registry exists yet) · branch-is-work (already checked this session) · issue-in-branch-name (already checked this session)
2026-09-08T13:40Z  handoff-archive  handoff-archived  tool=Edit
  checked: handoff-snapshot=nothing-to-copy · user-authored-file-archived=nothing-to-copy — all ok
  outcome: ok — nothing needed a copy
2026-09-08T13:40Z  branch-guard  edit-checked  branch=arc/04-dogfood-issue-199-box-disposition
  checked: branch-kind=work · worktree-identity=own · base-freshness=current — all ok
  outcome: ok — nothing to report
  skipped: path-is-source (the branch is not a coordination branch)
2026-09-08T13:40Z  camp-session-start  session-start
  checked: — none reached
  outcome: ok — already checked this session
  skipped: arc-active (no arc registry exists yet) · branch-is-work (already checked this session) · issue-in-branch-name (already checked this session)
2026-09-08T13:40Z  handoff-archive  handoff-archived  tool=Edit
  checked: handoff-snapshot=nothing-to-copy · user-authored-file-archived=nothing-to-copy — all ok
  outcome: ok — nothing needed a copy
2026-09-08T13:40Z  branch-guard  edit-checked  branch=arc/04-dogfood-issue-199-box-disposition
  checked: branch-kind=work · worktree-identity=own · base-freshness=current — all ok
  outcome: ok — nothing to report
  skipped: path-is-source (the branch is not a coordination branch)
2026-09-08T13:40Z  camp-session-start  session-start
  checked: — none reached
  outcome: ok — already checked this session
  skipped: arc-active (no arc registry exists yet) · branch-is-work (already checked this session) · issue-in-branch-name (already checked this session)
2026-09-08T13:40Z  handoff-archive  handoff-archived  tool=Edit
  checked: handoff-snapshot=nothing-to-copy · user-authored-file-archived=nothing-to-copy — all ok
  outcome: ok — nothing needed a copy
2026-09-08T13:40Z  branch-guard  edit-checked  branch=arc/04-dogfood-issue-199-box-disposition
  checked: branch-kind=work · worktree-identity=own · base-freshness=current — all ok
  outcome: ok — nothing to report
  skipped: path-is-source (the branch is not a coordination branch)
2026-09-08T13:40Z  camp-session-start  session-start
  checked: — none reached
  outcome: ok — already checked this session
  skipped: arc-active (no arc registry exists yet) · branch-is-work (already checked this session) · issue-in-branch-name (already checked this session)
2026-09-08T13:40Z  handoff-archive  handoff-archived  tool=Edit
  checked: handoff-snapshot=nothing-to-copy · user-authored-file-archived=nothing-to-copy — all ok
  outcome: ok — nothing needed a copy
2026-09-08T13:40Z  branch-guard  edit-checked  branch=arc/04-dogfood-issue-199-box-disposition
  checked: branch-kind=work · worktree-identity=own · base-freshness=current — all ok
  outcome: ok — nothing to report
  skipped: path-is-source (the branch is not a coordination branch)
2026-09-08T13:40Z  camp-session-start  session-start
  checked: — none reached
  outcome: ok — already checked this session
  skipped: arc-active (no arc registry exists yet) · branch-is-work (already checked this session) · issue-in-branch-name (already checked this session)
2026-09-08T13:40Z  handoff-archive  handoff-archived  tool=Edit
  checked: handoff-snapshot=nothing-to-copy · user-authored-file-archived=nothing-to-copy — all ok
  outcome: ok — nothing needed a copy
2026-09-08T13:40Z  branch-guard  edit-checked  branch=arc/04-dogfood-issue-199-box-disposition
  checked: branch-kind=work · worktree-identity=own · base-freshness=current — all ok
  outcome: ok — nothing to report
  skipped: path-is-source (the branch is not a coordination branch)
2026-09-08T13:41Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T13:41Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T13:41Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T13:41Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T13:41Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T13:41Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T13:41Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T13:41Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T13:41Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T13:41Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T13:41Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T13:41Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T13:41Z  camp-session-start  session-start
  checked: — none reached
  outcome: ok — already checked this session
  skipped: arc-active (no arc registry exists yet) · branch-is-work (already checked this session) · issue-in-branch-name (already checked this session)
2026-09-08T13:41Z  handoff-archive  handoff-archived  tool=Edit
  checked: handoff-snapshot=nothing-to-copy · user-authored-file-archived=nothing-to-copy — all ok
  outcome: ok — nothing needed a copy
2026-09-08T13:41Z  branch-guard  edit-checked  branch=arc/04-dogfood-issue-199-box-disposition
  checked: branch-kind=work · worktree-identity=own · base-freshness=current — all ok
  outcome: ok — nothing to report
  skipped: path-is-source (the branch is not a coordination branch)
2026-09-08T13:41Z  camp-session-start  session-start
  checked: — none reached
  outcome: ok — already checked this session
  skipped: arc-active (no arc registry exists yet) · branch-is-work (already checked this session) · issue-in-branch-name (already checked this session)
2026-09-08T13:41Z  handoff-archive  handoff-archived  tool=Edit
  checked: handoff-snapshot=nothing-to-copy · user-authored-file-archived=nothing-to-copy — all ok
  outcome: ok — nothing needed a copy
2026-09-08T13:41Z  branch-guard  edit-checked  branch=arc/04-dogfood-issue-199-box-disposition
  checked: branch-kind=work · worktree-identity=own · base-freshness=current — all ok
  outcome: ok — nothing to report
  skipped: path-is-source (the branch is not a coordination branch)
2026-09-08T13:41Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T13:41Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T13:41Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T13:41Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T13:41Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T13:41Z  mode-guard  mode-check
  checked: gating-command=yes · mode-row=autonomous — all ok
  outcome: ok — autonomous — the command is allowed
2026-09-08T13:41Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T13:41Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T13:42Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T13:42Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T13:42Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T13:42Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T13:42Z  camp-session-start  session-start
  checked: — none reached
  outcome: ok — already checked this session
  skipped: arc-active (no arc registry exists yet) · branch-is-work (already checked this session) · issue-in-branch-name (already checked this session)
2026-09-08T13:42Z  handoff-archive  handoff-archived  tool=Edit
  checked: handoff-snapshot=nothing-to-copy · user-authored-file-archived=nothing-to-copy — all ok
  outcome: ok — nothing needed a copy
2026-09-08T13:42Z  branch-guard  edit-checked  branch=arc/04-dogfood-issue-199-box-disposition
  checked: branch-kind=work · worktree-identity=own · base-freshness=current — all ok
  outcome: ok — nothing to report
  skipped: path-is-source (the branch is not a coordination branch)
2026-09-08T13:42Z  camp-session-start  session-start
  checked: — none reached
  outcome: ok — already checked this session
  skipped: arc-active (no arc registry exists yet) · branch-is-work (already checked this session) · issue-in-branch-name (already checked this session)
2026-09-08T13:42Z  handoff-archive  handoff-archived  tool=Edit
  checked: handoff-snapshot=nothing-to-copy · user-authored-file-archived=nothing-to-copy — all ok
  outcome: ok — nothing needed a copy
2026-09-08T13:42Z  branch-guard  edit-checked  branch=arc/04-dogfood-issue-199-box-disposition
  checked: branch-kind=work · worktree-identity=own · base-freshness=current — all ok
  outcome: ok — nothing to report
  skipped: path-is-source (the branch is not a coordination branch)
2026-09-08T13:42Z  camp-session-start  session-start
  checked: — none reached
  outcome: ok — already checked this session
  skipped: arc-active (no arc registry exists yet) · branch-is-work (already checked this session) · issue-in-branch-name (already checked this session)
2026-09-08T13:42Z  handoff-archive  handoff-archived  tool=Edit
  checked: handoff-snapshot=nothing-to-copy · user-authored-file-archived=nothing-to-copy — all ok
  outcome: ok — nothing needed a copy
2026-09-08T13:42Z  branch-guard  edit-checked  branch=arc/04-dogfood-issue-199-box-disposition
  checked: branch-kind=work · worktree-identity=own · base-freshness=current — all ok
  outcome: ok — nothing to report
  skipped: path-is-source (the branch is not a coordination branch)
2026-09-08T13:42Z  camp-session-start  session-start
  checked: — none reached
  outcome: ok — already checked this session
  skipped: arc-active (no arc registry exists yet) · branch-is-work (already checked this session) · issue-in-branch-name (already checked this session)
2026-09-08T13:42Z  handoff-archive  handoff-archived  tool=Edit
  checked: handoff-snapshot=nothing-to-copy · user-authored-file-archived=nothing-to-copy — all ok
  outcome: ok — nothing needed a copy
2026-09-08T13:42Z  branch-guard  edit-checked  branch=arc/04-dogfood-issue-199-box-disposition
  checked: branch-kind=work · worktree-identity=own · base-freshness=current — all ok
  outcome: ok — nothing to report
  skipped: path-is-source (the branch is not a coordination branch)
2026-09-08T13:42Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T13:42Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T13:42Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T13:42Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T13:42Z  camp-session-start  session-start
  checked: — none reached
  outcome: ok — already checked this session
  skipped: arc-active (no arc registry exists yet) · branch-is-work (already checked this session) · issue-in-branch-name (already checked this session)
2026-09-08T13:42Z  handoff-archive  handoff-archived  tool=Edit
  checked: handoff-snapshot=nothing-to-copy · user-authored-file-archived=nothing-to-copy — all ok
  outcome: ok — nothing needed a copy
2026-09-08T13:42Z  branch-guard  edit-checked  branch=arc/04-dogfood-issue-199-box-disposition
  checked: branch-kind=work · worktree-identity=own · base-freshness=current — all ok
  outcome: ok — nothing to report
  skipped: path-is-source (the branch is not a coordination branch)
2026-09-08T13:42Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T13:42Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T13:43Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T13:43Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T13:44Z  camp-session-start  session-start
  checked: — none reached
  outcome: ok — already checked this session
  skipped: arc-active (no arc registry exists yet) · branch-is-work (already checked this session) · issue-in-branch-name (already checked this session)
2026-09-08T13:44Z  handoff-archive  handoff-archived  tool=Edit
  checked: handoff-snapshot=nothing-to-copy · user-authored-file-archived=nothing-to-copy — all ok
  outcome: ok — nothing needed a copy
2026-09-08T13:44Z  branch-guard  edit-checked  branch=arc/04-dogfood-issue-199-box-disposition
  checked: branch-kind=work · worktree-identity=own · base-freshness=current — all ok
  outcome: ok — nothing to report
  skipped: path-is-source (the branch is not a coordination branch)
2026-09-08T13:44Z  camp-session-start  session-start
  checked: — none reached
  outcome: ok — already checked this session
  skipped: arc-active (no arc registry exists yet) · branch-is-work (already checked this session) · issue-in-branch-name (already checked this session)
2026-09-08T13:44Z  handoff-archive  handoff-archived  tool=Edit
  checked: handoff-snapshot=nothing-to-copy · user-authored-file-archived=nothing-to-copy — all ok
  outcome: ok — nothing needed a copy
2026-09-08T13:44Z  branch-guard  edit-checked  branch=arc/04-dogfood-issue-199-box-disposition
  checked: branch-kind=work · worktree-identity=own · base-freshness=current — all ok
  outcome: ok — nothing to report
  skipped: path-is-source (the branch is not a coordination branch)
2026-09-08T13:44Z  camp-session-start  session-start
  checked: — none reached
  outcome: ok — already checked this session
  skipped: arc-active (no arc registry exists yet) · branch-is-work (already checked this session) · issue-in-branch-name (already checked this session)
2026-09-08T13:44Z  handoff-archive  handoff-archived  tool=Edit
  checked: handoff-snapshot=nothing-to-copy · user-authored-file-archived=nothing-to-copy — all ok
  outcome: ok — nothing needed a copy
2026-09-08T13:44Z  branch-guard  edit-checked  branch=arc/04-dogfood-issue-199-box-disposition
  checked: branch-kind=work · worktree-identity=own · base-freshness=current — all ok
  outcome: ok — nothing to report
  skipped: path-is-source (the branch is not a coordination branch)
2026-09-08T13:44Z  camp-session-start  session-start
  checked: — none reached
  outcome: ok — already checked this session
  skipped: arc-active (no arc registry exists yet) · branch-is-work (already checked this session) · issue-in-branch-name (already checked this session)
2026-09-08T13:44Z  handoff-archive  handoff-archived  tool=Edit
  checked: handoff-snapshot=nothing-to-copy · user-authored-file-archived=nothing-to-copy — all ok
  outcome: ok — nothing needed a copy
2026-09-08T13:44Z  branch-guard  edit-checked  branch=arc/04-dogfood-issue-199-box-disposition
  checked: branch-kind=work · worktree-identity=own · base-freshness=current — all ok
  outcome: ok — nothing to report
  skipped: path-is-source (the branch is not a coordination branch)
2026-09-08T13:44Z  camp-session-start  session-start
  checked: — none reached
  outcome: ok — already checked this session
  skipped: arc-active (no arc registry exists yet) · branch-is-work (already checked this session) · issue-in-branch-name (already checked this session)
2026-09-08T13:44Z  handoff-archive  handoff-archived  tool=Edit
  checked: handoff-snapshot=nothing-to-copy · user-authored-file-archived=nothing-to-copy — all ok
  outcome: ok — nothing needed a copy
2026-09-08T13:44Z  branch-guard  edit-checked  branch=arc/04-dogfood-issue-199-box-disposition
  checked: branch-kind=work · worktree-identity=own · base-freshness=current — all ok
  outcome: ok — nothing to report
  skipped: path-is-source (the branch is not a coordination branch)
2026-09-08T13:44Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T13:44Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T13:50Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T13:50Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T13:53Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T13:53Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T13:53Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T13:53Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T13:53Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T13:53Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T13:53Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T13:53Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T13:53Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T13:53Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T13:53Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T13:53Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T13:53Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T13:53Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T13:53Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T13:53Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T13:54Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T13:54Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T13:54Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T13:54Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T13:54Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T13:54Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T13:54Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T13:54Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T13:54Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T13:54Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T13:54Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T13:54Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T13:54Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T13:54Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T13:54Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T13:54Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T13:54Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T13:54Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T13:54Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T13:54Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T13:54Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T13:54Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T13:54Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T13:54Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T13:54Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T13:54Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T13:54Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T13:54Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T13:54Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T13:54Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T13:54Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T13:54Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T13:55Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T13:55Z  mode-guard  mode-check
  checked: gating-command=yes · mode-row=autonomous — all ok
  outcome: ok — autonomous — the command is allowed
2026-09-08T13:55Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T13:55Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T13:55Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T13:55Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T13:55Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T13:55Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T13:56Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T13:56Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T13:56Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T13:56Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T13:56Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T13:56Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T13:56Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T13:56Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T13:57Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T13:57Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T13:57Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T13:57Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T13:57Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T13:57Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T13:57Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T13:57Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T13:58Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T13:58Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T13:58Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T13:58Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T13:58Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T13:58Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T13:58Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T13:58Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T13:58Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T13:58Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T13:58Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T13:58Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T14:01Z  camp-session-start  session-start
  checked: — none reached
  outcome: ok — already checked this session
  skipped: arc-active (no arc registry exists yet) · branch-is-work (already checked this session) · issue-in-branch-name (already checked this session)
2026-09-08T14:01Z  handoff-archive  handoff-archived  tool=Edit
  checked: handoff-snapshot=nothing-to-copy · user-authored-file-archived=nothing-to-copy — all ok
  outcome: ok — nothing needed a copy
2026-09-08T14:01Z  branch-guard  edit-checked  branch=arc/04-dogfood-issue-199-box-disposition
  checked: branch-kind=work · worktree-identity=own · base-freshness=current — all ok
  outcome: ok — nothing to report
  skipped: path-is-source (the branch is not a coordination branch)
2026-09-08T14:01Z  camp-session-start  session-start
  checked: — none reached
  outcome: ok — already checked this session
  skipped: arc-active (no arc registry exists yet) · branch-is-work (already checked this session) · issue-in-branch-name (already checked this session)
2026-09-08T14:01Z  handoff-archive  handoff-archived  tool=Edit
  checked: handoff-snapshot=nothing-to-copy · user-authored-file-archived=nothing-to-copy — all ok
  outcome: ok — nothing needed a copy
2026-09-08T14:01Z  branch-guard  edit-checked  branch=arc/04-dogfood-issue-199-box-disposition
  checked: branch-kind=work · worktree-identity=own · base-freshness=current — all ok
  outcome: ok — nothing to report
  skipped: path-is-source (the branch is not a coordination branch)
2026-09-08T14:01Z  camp-session-start  session-start
  checked: — none reached
  outcome: ok — already checked this session
  skipped: arc-active (no arc registry exists yet) · branch-is-work (already checked this session) · issue-in-branch-name (already checked this session)
2026-09-08T14:01Z  handoff-archive  handoff-archived  tool=Edit
  checked: handoff-snapshot=nothing-to-copy · user-authored-file-archived=nothing-to-copy — all ok
  outcome: ok — nothing needed a copy
2026-09-08T14:01Z  branch-guard  edit-checked  branch=arc/04-dogfood-issue-199-box-disposition
  checked: branch-kind=work · worktree-identity=own · base-freshness=current — all ok
  outcome: ok — nothing to report
  skipped: path-is-source (the branch is not a coordination branch)
2026-09-08T14:01Z  camp-session-start  session-start
  checked: — none reached
  outcome: ok — already checked this session
  skipped: arc-active (no arc registry exists yet) · branch-is-work (already checked this session) · issue-in-branch-name (already checked this session)
2026-09-08T14:01Z  handoff-archive  handoff-archived  tool=Edit
  checked: handoff-snapshot=nothing-to-copy · user-authored-file-archived=nothing-to-copy — all ok
  outcome: ok — nothing needed a copy
2026-09-08T14:01Z  branch-guard  edit-checked  branch=arc/04-dogfood-issue-199-box-disposition
  checked: branch-kind=work · worktree-identity=own · base-freshness=current — all ok
  outcome: ok — nothing to report
  skipped: path-is-source (the branch is not a coordination branch)
2026-09-08T14:02Z  camp-session-start  session-start
  checked: — none reached
  outcome: ok — already checked this session
  skipped: arc-active (no arc registry exists yet) · branch-is-work (already checked this session) · issue-in-branch-name (already checked this session)
2026-09-08T14:02Z  handoff-archive  handoff-archived  tool=Edit
  checked: handoff-snapshot=nothing-to-copy · user-authored-file-archived=nothing-to-copy — all ok
  outcome: ok — nothing needed a copy
2026-09-08T14:02Z  branch-guard  edit-checked  branch=arc/04-dogfood-issue-199-box-disposition
  checked: branch-kind=work · worktree-identity=own · base-freshness=current — all ok
  outcome: ok — nothing to report
  skipped: path-is-source (the branch is not a coordination branch)
2026-09-08T14:02Z  camp-session-start  session-start
  checked: — none reached
  outcome: ok — already checked this session
  skipped: arc-active (no arc registry exists yet) · branch-is-work (already checked this session) · issue-in-branch-name (already checked this session)
2026-09-08T14:02Z  handoff-archive  handoff-archived  tool=Edit
  checked: handoff-snapshot=nothing-to-copy · user-authored-file-archived=nothing-to-copy — all ok
  outcome: ok — nothing needed a copy
2026-09-08T14:02Z  branch-guard  edit-checked  branch=arc/04-dogfood-issue-199-box-disposition
  checked: branch-kind=work · worktree-identity=own · base-freshness=current — all ok
  outcome: ok — nothing to report
  skipped: path-is-source (the branch is not a coordination branch)
2026-09-08T14:02Z  camp-session-start  session-start
  checked: — none reached
  outcome: ok — already checked this session
  skipped: arc-active (no arc registry exists yet) · branch-is-work (already checked this session) · issue-in-branch-name (already checked this session)
2026-09-08T14:02Z  handoff-archive  handoff-archived  tool=Edit
  checked: handoff-snapshot=nothing-to-copy · user-authored-file-archived=nothing-to-copy — all ok
  outcome: ok — nothing needed a copy
2026-09-08T14:02Z  branch-guard  edit-checked  branch=arc/04-dogfood-issue-199-box-disposition
  checked: branch-kind=work · worktree-identity=own · base-freshness=current — all ok
  outcome: ok — nothing to report
  skipped: path-is-source (the branch is not a coordination branch)
2026-09-08T14:02Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T14:02Z  mode-guard  mode-check
  checked: gating-command=yes · mode-row=autonomous — all ok
  outcome: ok — autonomous — the command is allowed
2026-09-08T14:02Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T14:02Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T14:02Z  camp-session-start  session-start
  checked: — none reached
  outcome: ok — already checked this session
  skipped: arc-active (no arc registry exists yet) · branch-is-work (already checked this session) · issue-in-branch-name (already checked this session)
2026-09-08T14:02Z  handoff-archive  handoff-archived  tool=Edit
  checked: handoff-snapshot=nothing-to-copy · user-authored-file-archived=nothing-to-copy — all ok
  outcome: ok — nothing needed a copy
2026-09-08T14:02Z  branch-guard  edit-checked  branch=arc/04-dogfood-issue-199-box-disposition
  checked: branch-kind=work · worktree-identity=own · base-freshness=current — all ok
  outcome: ok — nothing to report
  skipped: path-is-source (the branch is not a coordination branch)
2026-09-08T14:02Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T14:02Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T14:03Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T14:03Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T14:03Z  camp-session-start  session-start
  checked: — none reached
  outcome: ok — already checked this session
  skipped: arc-active (no arc registry exists yet) · branch-is-work (already checked this session) · issue-in-branch-name (already checked this session)
2026-09-08T14:03Z  handoff-archive  handoff-archived  tool=Edit
  checked: handoff-snapshot=nothing-to-copy · user-authored-file-archived=nothing-to-copy — all ok
  outcome: ok — nothing needed a copy
2026-09-08T14:03Z  branch-guard  edit-checked  branch=arc/04-dogfood-issue-199-box-disposition
  checked: branch-kind=work · worktree-identity=own · base-freshness=current — all ok
  outcome: ok — nothing to report
  skipped: path-is-source (the branch is not a coordination branch)
2026-09-08T14:03Z  camp-session-start  session-start
  checked: — none reached
  outcome: ok — already checked this session
  skipped: arc-active (no arc registry exists yet) · branch-is-work (already checked this session) · issue-in-branch-name (already checked this session)
2026-09-08T14:03Z  handoff-archive  handoff-archived  tool=Edit
  checked: handoff-snapshot=nothing-to-copy · user-authored-file-archived=nothing-to-copy — all ok
  outcome: ok — nothing needed a copy
2026-09-08T14:03Z  branch-guard  edit-checked  branch=arc/04-dogfood-issue-199-box-disposition
  checked: branch-kind=work · worktree-identity=own · base-freshness=current — all ok
  outcome: ok — nothing to report
  skipped: path-is-source (the branch is not a coordination branch)
2026-09-08T14:03Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T14:03Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T14:03Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T14:03Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T14:03Z  camp-session-start  session-start
  checked: — none reached
  outcome: ok — already checked this session
  skipped: arc-active (no arc registry exists yet) · branch-is-work (already checked this session) · issue-in-branch-name (already checked this session)
2026-09-08T14:03Z  handoff-archive  handoff-archived  tool=Edit
  checked: handoff-snapshot=nothing-to-copy · user-authored-file-archived=nothing-to-copy — all ok
  outcome: ok — nothing needed a copy
2026-09-08T14:03Z  branch-guard  edit-checked  branch=arc/04-dogfood-issue-199-box-disposition
  checked: branch-kind=work · worktree-identity=own · base-freshness=current — all ok
  outcome: ok — nothing to report
  skipped: path-is-source (the branch is not a coordination branch)
2026-09-08T14:03Z  camp-session-start  session-start
  checked: — none reached
  outcome: ok — already checked this session
  skipped: arc-active (no arc registry exists yet) · branch-is-work (already checked this session) · issue-in-branch-name (already checked this session)
2026-09-08T14:03Z  handoff-archive  handoff-archived  tool=Edit
  checked: handoff-snapshot=nothing-to-copy · user-authored-file-archived=nothing-to-copy — all ok
  outcome: ok — nothing needed a copy
2026-09-08T14:03Z  branch-guard  edit-checked  branch=arc/04-dogfood-issue-199-box-disposition
  checked: branch-kind=work · worktree-identity=own · base-freshness=current — all ok
  outcome: ok — nothing to report
  skipped: path-is-source (the branch is not a coordination branch)
2026-09-08T14:03Z  camp-session-start  session-start
  checked: — none reached
  outcome: ok — already checked this session
  skipped: arc-active (no arc registry exists yet) · branch-is-work (already checked this session) · issue-in-branch-name (already checked this session)
2026-09-08T14:03Z  handoff-archive  handoff-archived  tool=Edit
  checked: handoff-snapshot=nothing-to-copy · user-authored-file-archived=nothing-to-copy — all ok
  outcome: ok — nothing needed a copy
2026-09-08T14:03Z  branch-guard  edit-checked  branch=arc/04-dogfood-issue-199-box-disposition
  checked: branch-kind=work · worktree-identity=own · base-freshness=current — all ok
  outcome: ok — nothing to report
  skipped: path-is-source (the branch is not a coordination branch)
2026-09-08T14:04Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T14:04Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T14:04Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T14:04Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T14:04Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T14:04Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T14:04Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T14:04Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T14:04Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T14:04Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T14:06Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T14:06Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T14:06Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T14:06Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T14:06Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T14:06Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T14:06Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T14:06Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T14:06Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T14:06Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T14:07Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T14:07Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T14:13Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T14:13Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T14:14Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T14:14Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T14:14Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T14:14Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T14:14Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T14:14Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T14:14Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T14:14Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T14:14Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T14:14Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T14:14Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T14:14Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T14:14Z  mode-guard  mode-check
  checked: gating-command=no — all ok
2026-09-08T14:14Z  mode-guard  mode-check
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T14:14Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T14:14Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T14:14Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T14:14Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T14:14Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T14:14Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T14:14Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T14:14Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T14:15Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T14:15Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T14:15Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T14:15Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T14:15Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T14:15Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T14:15Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T14:15Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T14:15Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T14:15Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T15:50Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T15:50Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T15:50Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T15:50Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T15:50Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T15:50Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T15:50Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T15:50Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T15:50Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T15:50Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T15:50Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T15:50Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T15:50Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T15:50Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T15:50Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T15:50Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T15:50Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T15:50Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T15:50Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T15:50Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T15:50Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T15:50Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T15:50Z  handoff-archive  handoff-archived  tool=Bash
2026-09-08T15:50Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T15:50Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T15:50Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T15:50Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T15:50Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T15:51Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T15:51Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T15:51Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T15:51Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T15:51Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T15:51Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T15:51Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T15:51Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T15:51Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T15:51Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T15:51Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T15:51Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T15:51Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T15:51Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T15:51Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T15:51Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T15:51Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T15:51Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T15:51Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T15:51Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T15:51Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T15:51Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T15:51Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T15:51Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T15:51Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T15:51Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T15:51Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T15:51Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T15:51Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T15:51Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T15:51Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T15:51Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T15:51Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T15:51Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T15:52Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T15:52Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T15:52Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T15:52Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T15:52Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T15:52Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T15:52Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T15:52Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T15:52Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T15:52Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T15:52Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T15:52Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T15:52Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T15:52Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T15:52Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T15:52Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T15:52Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T15:52Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T15:53Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T15:53Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T15:55Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T15:55Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T15:55Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T15:55Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T15:55Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T15:55Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T15:55Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T15:55Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T15:55Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T15:55Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T15:56Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T15:56Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T15:56Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T15:56Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T15:56Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T15:56Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T15:56Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T15:56Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T15:56Z  camp-session-start  session-start
  checked: — none reached
  outcome: ok — already checked this session
  skipped: arc-active (no arc registry exists yet) · branch-is-work (already checked this session) · issue-in-branch-name (already checked this session)
2026-09-08T15:56Z  handoff-archive  handoff-archived  tool=Edit
  checked: handoff-snapshot=nothing-to-copy · user-authored-file-archived=nothing-to-copy — all ok
  outcome: ok — nothing needed a copy
2026-09-08T15:56Z  branch-guard  edit-checked  branch=arc/04-dogfood-issue-199-box-disposition
  checked: branch-kind=work · worktree-identity=own · base-freshness=behind-6 — base-freshness found something
  outcome: denied — the base is 6 commit(s) ahead of this branch
  skipped: path-is-source (the branch is not a coordination branch)
2026-09-08T15:56Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T15:56Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T15:56Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T15:56Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T15:57Z  camp-session-start  session-start
  checked: — none reached
  outcome: ok — already checked this session
  skipped: arc-active (no arc registry exists yet) · branch-is-work (already checked this session) · issue-in-branch-name (already checked this session)
2026-09-08T15:57Z  handoff-archive  handoff-archived  tool=Edit
  checked: handoff-snapshot=nothing-to-copy · user-authored-file-archived=nothing-to-copy — all ok
  outcome: ok — nothing needed a copy
2026-09-08T15:57Z  branch-guard  edit-checked  branch=arc/04-dogfood-issue-199-box-disposition
  checked: branch-kind=work · worktree-identity=own — all ok
  outcome: ok — nothing to report
  skipped: path-is-source (the branch is not a coordination branch) · base-freshness (this base commit was already reported)
2026-09-08T15:57Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T15:57Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T15:58Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T15:58Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T15:58Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T15:58Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T15:58Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T15:58Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T15:59Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T15:59Z  mode-guard  mode-check
  checked: gating-command=yes · mode-row=autonomous — all ok
  outcome: ok — autonomous — the command is allowed
2026-09-08T15:59Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T15:59Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T15:59Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T15:59Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T15:59Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T15:59Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T15:59Z  mode-guard  mode-check
  checked: gating-command=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-08T15:59Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T15:59Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-08T15:59Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-08T15:59Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-08T15:59Z  mode-guard  mode-check
  checked: gating-command=yes · mode-row=autonomous — all ok
  outcome: ok — autonomous — the command is allowed
