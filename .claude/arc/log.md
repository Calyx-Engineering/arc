# Event log — arc/04-dogfood

> **Append-only.** Every Arc artifact firing, recorded regardless of verbosity. Newest at the
> bottom. **Never edit or reorder an existing entry** — a correction is a new entry.
>
> Format and rules: [`templates/event-log.md`](../../templates/event-log.md) ·
> Spec: [m44](../../docs/product-architecture/mechanisms/m44-event-log.md)

**Arc:** `arc/04-dogfood` · **Rotated:** 2026-09-09 · **Previous:** [arc-03-camp.log.md](../../docs/arc-log/events/arc-03-camp.log.md)

---

2026-09-09T14:45Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-boxes (not reached) · spawn-parent (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-09T14:45Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-09T14:45Z  session-index  session-indexed  tool=Bash
  checked: — none reached
  outcome: ok — already indexed this session
  skipped: index-entry (this session was already indexed) · orphan-sweep (this session was already indexed)
2026-09-09T14:45Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-09T14:45Z  mode-guard  mode-check
  checked: gating-command=no · gating-script=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-09T14:45Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-boxes (not reached) · spawn-parent (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-09T14:45Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-09T14:45Z  mode-guard  mode-check
  checked: gating-command=no · gating-script=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-09T14:45Z  session-index  session-indexed  tool=Bash
  checked: — none reached
  outcome: ok — already indexed this session
  skipped: index-entry (this session was already indexed) · orphan-sweep (this session was already indexed)
2026-09-09T14:45Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-09T14:45Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-boxes (not reached) · spawn-parent (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-09T14:45Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-09T14:45Z  mode-guard  mode-check
  checked: gating-command=no · gating-script=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-09T14:45Z  session-index  session-indexed  tool=Bash
  checked: — none reached
  outcome: ok — already indexed this session
  skipped: index-entry (this session was already indexed) · orphan-sweep (this session was already indexed)
2026-09-09T14:45Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-09T14:45Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-boxes (not reached) · spawn-parent (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-09T14:45Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-09T14:46Z  mode-guard  mode-check
  checked: gating-command=no · gating-script=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-09T14:46Z  session-index  session-indexed  tool=Bash
  checked: — none reached
  outcome: ok — already indexed this session
  skipped: index-entry (this session was already indexed) · orphan-sweep (this session was already indexed)
2026-09-09T14:46Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-09T14:46Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-09T14:46Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-boxes (not reached) · spawn-parent (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-09T14:46Z  session-index  session-indexed  tool=Bash
  checked: — none reached
  outcome: ok — already indexed this session
  skipped: index-entry (this session was already indexed) · orphan-sweep (this session was already indexed)
2026-09-09T14:46Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-09T14:46Z  mode-guard  mode-check
  checked: gating-command=no · gating-script=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-09T14:46Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-09T14:46Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-boxes (not reached) · spawn-parent (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-09T14:46Z  mode-guard  mode-check
  checked: gating-command=no · gating-script=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-09T14:46Z  session-index  session-indexed  tool=Bash
  checked: — none reached
  outcome: ok — already indexed this session
  skipped: index-entry (this session was already indexed) · orphan-sweep (this session was already indexed)
2026-09-09T14:46Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-09T14:46Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-boxes (not reached) · spawn-parent (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-09T14:46Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-09T14:46Z  session-index  session-indexed  tool=Bash
  checked: — none reached
  outcome: ok — already indexed this session
  skipped: index-entry (this session was already indexed) · orphan-sweep (this session was already indexed)
2026-09-09T14:46Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-09T14:46Z  mode-guard  mode-check
  checked: gating-command=no · gating-script=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-09T14:46Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-09T14:46Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-boxes (not reached) · spawn-parent (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-09T14:47Z  mode-guard  mode-check
  checked: gating-command=no · gating-script=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-09T14:47Z  session-index  session-indexed  tool=Bash
  checked: — none reached
  outcome: ok — already indexed this session
  skipped: index-entry (this session was already indexed) · orphan-sweep (this session was already indexed)
2026-09-09T14:47Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-09T14:47Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-boxes (not reached) · spawn-parent (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-09T14:47Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-09T14:47Z  mode-guard  mode-check
  checked: gating-command=no · gating-script=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-09T14:47Z  session-index  session-indexed  tool=Bash
  checked: — none reached
  outcome: ok — already indexed this session
  skipped: index-entry (this session was already indexed) · orphan-sweep (this session was already indexed)
2026-09-09T14:47Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-09T14:47Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-boxes (not reached) · spawn-parent (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-09T14:47Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-09T14:47Z  session-index  session-indexed  tool=Bash
  checked: — none reached
  outcome: ok — already indexed this session
  skipped: index-entry (this session was already indexed) · orphan-sweep (this session was already indexed)
2026-09-09T14:47Z  mode-guard  mode-check
  checked: gating-command=no · gating-script=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-09T14:47Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-09T14:47Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-boxes (not reached) · spawn-parent (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-09T14:47Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-09T14:47Z  mode-guard  mode-check
  checked: gating-command=no · gating-script=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-09T14:47Z  session-index  session-indexed  tool=Bash
  checked: — none reached
  outcome: ok — already indexed this session
  skipped: index-entry (this session was already indexed) · orphan-sweep (this session was already indexed)
2026-09-09T14:47Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-09T14:47Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-boxes (not reached) · spawn-parent (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-09T14:47Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-09T14:47Z  mode-guard  mode-check
  checked: gating-command=no · gating-script=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-09T14:47Z  session-index  session-indexed  tool=Bash
  checked: — none reached
  outcome: ok — already indexed this session
  skipped: index-entry (this session was already indexed) · orphan-sweep (this session was already indexed)
2026-09-09T14:47Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-09T14:48Z  mode-guard  mode-check
  checked: gating-command=no · gating-script=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-09T14:48Z  session-index  session-indexed  tool=Bash
  checked: — none reached
  outcome: ok — already indexed this session
  skipped: index-entry (this session was already indexed) · orphan-sweep (this session was already indexed)
2026-09-09T14:48Z  mode-guard  mode-check
  checked: gating-command=no · gating-script=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-09T14:48Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-09T14:48Z  session-index  session-indexed  tool=Bash
  checked: — none reached
  outcome: ok — already indexed this session
  skipped: index-entry (this session was already indexed) · orphan-sweep (this session was already indexed)
2026-09-09T14:48Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-09T14:48Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-boxes (not reached) · spawn-parent (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-09T14:48Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-09T14:48Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-boxes (not reached) · spawn-parent (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-09T14:48Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-09T14:48Z  mode-guard  mode-check
  checked: gating-command=no · gating-script=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-09T14:48Z  session-index  session-indexed  tool=Bash
  checked: — none reached
  outcome: ok — already indexed this session
  skipped: index-entry (this session was already indexed) · orphan-sweep (this session was already indexed)
2026-09-09T14:48Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-09T14:48Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-09T14:48Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-boxes (not reached) · spawn-parent (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-09T14:48Z  mode-guard  mode-check
  checked: gating-command=no · gating-script=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-09T14:48Z  session-index  session-indexed  tool=Bash
  checked: — none reached
  outcome: ok — already indexed this session
  skipped: index-entry (this session was already indexed) · orphan-sweep (this session was already indexed)
2026-09-09T14:48Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-09T14:48Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-boxes (not reached) · spawn-parent (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-09T14:48Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-09T14:48Z  mode-guard  mode-check
  checked: gating-command=no · gating-script=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-09T14:48Z  session-index  session-indexed  tool=Bash
  checked: — none reached
  outcome: ok — already indexed this session
  skipped: index-entry (this session was already indexed) · orphan-sweep (this session was already indexed)
2026-09-09T14:48Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-09T14:48Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-boxes (not reached) · spawn-parent (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-09T14:48Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-09T14:48Z  mode-guard  mode-check
  checked: gating-command=no · gating-script=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-09T14:48Z  session-index  session-indexed  tool=Bash
  checked: — none reached
  outcome: ok — already indexed this session
  skipped: index-entry (this session was already indexed) · orphan-sweep (this session was already indexed)
2026-09-09T14:48Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-09T14:48Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-boxes (not reached) · spawn-parent (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-09T14:48Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-09T14:49Z  mode-guard  mode-check
  checked: gating-command=no · gating-script=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-09T14:49Z  session-index  session-indexed  tool=Bash
  checked: — none reached
  outcome: ok — already indexed this session
  skipped: index-entry (this session was already indexed) · orphan-sweep (this session was already indexed)
2026-09-09T14:49Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-09T14:49Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-boxes (not reached) · spawn-parent (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-09T14:49Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-09T14:49Z  mode-guard  mode-check
  checked: gating-command=no · gating-script=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-09T14:49Z  session-index  session-indexed  tool=Bash
  checked: — none reached
  outcome: ok — already indexed this session
  skipped: index-entry (this session was already indexed) · orphan-sweep (this session was already indexed)
2026-09-09T14:49Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-09T14:49Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-09T14:49Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-boxes (not reached) · spawn-parent (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-09T14:49Z  mode-guard  mode-check
  checked: gating-command=no · gating-script=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-09T14:49Z  session-index  session-indexed  tool=Bash
  checked: — none reached
  outcome: ok — already indexed this session
  skipped: index-entry (this session was already indexed) · orphan-sweep (this session was already indexed)
2026-09-09T14:49Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-09T14:49Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-boxes (not reached) · spawn-parent (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-09T14:49Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-09T14:49Z  mode-guard  mode-check
  checked: gating-command=no · gating-script=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-09T14:49Z  session-index  session-indexed  tool=Bash
  checked: — none reached
  outcome: ok — already indexed this session
  skipped: index-entry (this session was already indexed) · orphan-sweep (this session was already indexed)
2026-09-09T14:49Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-09T14:49Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-09T14:49Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-boxes (not reached) · spawn-parent (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-09T14:49Z  session-index  session-indexed  tool=Edit
  checked: — none reached
  outcome: ok — already indexed this session
  skipped: index-entry (this session was already indexed) · orphan-sweep (this session was already indexed)
2026-09-09T14:49Z  camp-session-start  session-start
  checked: — none reached
  outcome: ok — already checked this session
  skipped: arc-active (no arc registry exists yet) · branch-is-work (already checked this session) · issue-in-branch-name (already checked this session)
2026-09-09T14:49Z  handoff-archive  handoff-archived  tool=Edit
  checked: handoff-snapshot=nothing-to-copy · user-authored-file-archived=nothing-to-copy — all ok
  outcome: ok — nothing needed a copy
2026-09-09T14:49Z  branch-guard  edit-checked  branch=arc/04-dogfood-issue-238-log-volume prefix=arc/
  checked: branch-kind=work · worktree-identity=own · base-freshness=current — all ok
  outcome: ok — nothing to report
  skipped: path-is-source (the branch is not a coordination branch)
2026-09-09T14:49Z  session-index  session-indexed  tool=Bash
  checked: — none reached
  outcome: ok — already indexed this session
  skipped: index-entry (this session was already indexed) · orphan-sweep (this session was already indexed)
2026-09-09T14:50Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-09T14:50Z  mode-guard  mode-check
  checked: gating-command=no · gating-script=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-09T14:50Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-09T14:50Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-boxes (not reached) · spawn-parent (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-09T14:50Z  mode-guard  mode-check
  checked: gating-command=no · gating-script=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-09T14:50Z  session-index  session-indexed  tool=Bash
  checked: — none reached
  outcome: ok — already indexed this session
  skipped: index-entry (this session was already indexed) · orphan-sweep (this session was already indexed)
2026-09-09T14:50Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-09T14:50Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-boxes (not reached) · spawn-parent (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-09T14:50Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-09T14:50Z  mode-guard  mode-check
  checked: gating-command=no · gating-script=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-09T14:50Z  session-index  session-indexed  tool=Bash
  checked: — none reached
  outcome: ok — already indexed this session
  skipped: index-entry (this session was already indexed) · orphan-sweep (this session was already indexed)
2026-09-09T14:50Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-09T14:50Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-boxes (not reached) · spawn-parent (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-09T14:50Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-09T14:50Z  session-index  session-indexed  tool=Bash
  checked: — none reached
  outcome: ok — already indexed this session
  skipped: index-entry (this session was already indexed) · orphan-sweep (this session was already indexed)
2026-09-09T14:50Z  mode-guard  mode-check
  checked: gating-command=no · gating-script=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-09T14:50Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-09T14:51Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-boxes (not reached) · spawn-parent (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-09T14:51Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-09T14:51Z  mode-guard  mode-check
  checked: gating-command=no · gating-script=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-09T14:51Z  session-index  session-indexed  tool=Bash
  checked: — none reached
  outcome: ok — already indexed this session
  skipped: index-entry (this session was already indexed) · orphan-sweep (this session was already indexed)
2026-09-09T14:51Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-09T14:51Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-09T14:51Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-boxes (not reached) · spawn-parent (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-09T14:52Z  session-index  session-indexed  tool=Write
  checked: — none reached
  outcome: ok — already indexed this session
  skipped: index-entry (this session was already indexed) · orphan-sweep (this session was already indexed)
2026-09-09T14:52Z  camp-session-start  session-start
  checked: — none reached
  outcome: ok — already checked this session
  skipped: arc-active (no arc registry exists yet) · branch-is-work (already checked this session) · issue-in-branch-name (already checked this session)
2026-09-09T14:52Z  handoff-archive  handoff-archived  tool=Write
  checked: handoff-snapshot=nothing-to-copy · user-authored-file-archived=nothing-to-copy — all ok
  outcome: ok — nothing needed a copy
2026-09-09T14:52Z  branch-guard  edit-checked  branch=arc/04-dogfood-issue-238-log-volume prefix=arc/
  checked: branch-kind=work · worktree-identity=own · base-freshness=current — all ok
  outcome: ok — nothing to report
  skipped: path-is-source (the branch is not a coordination branch)
2026-09-09T14:52Z  session-index  session-indexed  tool=Write
  checked: — none reached
  outcome: ok — already indexed this session
  skipped: index-entry (this session was already indexed) · orphan-sweep (this session was already indexed)
2026-09-09T14:52Z  camp-session-start  session-start
  checked: — none reached
  outcome: ok — already checked this session
  skipped: arc-active (no arc registry exists yet) · branch-is-work (already checked this session) · issue-in-branch-name (already checked this session)
2026-09-09T14:52Z  handoff-archive  handoff-archived  tool=Write
  checked: handoff-snapshot=nothing-to-copy · user-authored-file-archived=nothing-to-copy — all ok
  outcome: ok — nothing needed a copy
2026-09-09T14:52Z  branch-guard  edit-checked  branch=arc/04-dogfood-issue-238-log-volume prefix=arc/
  checked: branch-kind=work · worktree-identity=own · base-freshness=current — all ok
  outcome: ok — nothing to report
  skipped: path-is-source (the branch is not a coordination branch)
2026-09-09T14:53Z  mode-guard  mode-check
  checked: gating-command=no · gating-script=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-09T14:53Z  session-index  session-indexed  tool=Bash
  checked: — none reached
  outcome: ok — already indexed this session
  skipped: index-entry (this session was already indexed) · orphan-sweep (this session was already indexed)
2026-09-09T14:53Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-09T14:53Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-boxes (not reached) · spawn-parent (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-09T14:53Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-09T14:53Z  mode-guard  mode-check
  checked: gating-command=no · gating-script=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-09T14:53Z  session-index  session-indexed  tool=Bash
  checked: — none reached
  outcome: ok — already indexed this session
  skipped: index-entry (this session was already indexed) · orphan-sweep (this session was already indexed)
2026-09-09T14:53Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-09T14:53Z  mode-guard  mode-check
  checked: gating-command=no · gating-script=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-09T14:53Z  session-index  session-indexed  tool=Bash
  checked: — none reached
  outcome: ok — already indexed this session
  skipped: index-entry (this session was already indexed) · orphan-sweep (this session was already indexed)
2026-09-09T14:53Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-09T14:53Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-09T14:53Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-boxes (not reached) · spawn-parent (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-09T14:53Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-boxes (not reached) · spawn-parent (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-09T14:53Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-09T14:53Z  mode-guard  mode-check
  checked: gating-command=no · gating-script=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-09T14:53Z  session-index  session-indexed  tool=Bash
  checked: — none reached
  outcome: ok — already indexed this session
  skipped: index-entry (this session was already indexed) · orphan-sweep (this session was already indexed)
2026-09-09T14:53Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-09T14:53Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-09T14:53Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-boxes (not reached) · spawn-parent (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-09T14:53Z  mode-guard  mode-check
  checked: gating-command=no · gating-script=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-09T14:53Z  session-index  session-indexed  tool=Bash
  checked: — none reached
  outcome: ok — already indexed this session
  skipped: index-entry (this session was already indexed) · orphan-sweep (this session was already indexed)
2026-09-09T14:54Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-09T14:54Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-09T14:54Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-boxes (not reached) · spawn-parent (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-09T14:54Z  mode-guard  mode-check
  checked: gating-command=no · gating-script=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-09T14:54Z  session-index  session-indexed  tool=Bash
  checked: — none reached
  outcome: ok — already indexed this session
  skipped: index-entry (this session was already indexed) · orphan-sweep (this session was already indexed)
2026-09-09T14:54Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-09T14:54Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-09T14:54Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-boxes (not reached) · spawn-parent (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-09T14:54Z  mode-guard  mode-check
  checked: gating-command=no · gating-script=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-09T14:54Z  session-index  session-indexed  tool=Bash
  checked: — none reached
  outcome: ok — already indexed this session
  skipped: index-entry (this session was already indexed) · orphan-sweep (this session was already indexed)
2026-09-09T14:54Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-09T14:54Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-09T14:54Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-boxes (not reached) · spawn-parent (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-09T14:54Z  mode-guard  mode-check
  checked: gating-command=no · gating-script=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-09T14:54Z  session-index  session-indexed  tool=Bash
  checked: — none reached
  outcome: ok — already indexed this session
  skipped: index-entry (this session was already indexed) · orphan-sweep (this session was already indexed)
2026-09-09T14:54Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-09T14:54Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-boxes (not reached) · spawn-parent (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-09T14:54Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-09T14:55Z  mode-guard  mode-check
  checked: gating-command=no · gating-script=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-09T14:55Z  session-index  session-indexed  tool=Bash
  checked: — none reached
  outcome: ok — already indexed this session
  skipped: index-entry (this session was already indexed) · orphan-sweep (this session was already indexed)
2026-09-09T14:55Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-09T14:55Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-boxes (not reached) · spawn-parent (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-09T14:55Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-09T14:55Z  mode-guard  mode-check
  checked: gating-command=no · gating-script=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-09T14:55Z  session-index  session-indexed  tool=Bash
  checked: — none reached
  outcome: ok — already indexed this session
  skipped: index-entry (this session was already indexed) · orphan-sweep (this session was already indexed)
2026-09-09T14:55Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-09T14:55Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-09T14:55Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-boxes (not reached) · spawn-parent (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-09T14:55Z  mode-guard  mode-check
  checked: gating-command=no · gating-script=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-09T14:55Z  session-index  session-indexed  tool=Bash
  checked: — none reached
  outcome: ok — already indexed this session
  skipped: index-entry (this session was already indexed) · orphan-sweep (this session was already indexed)
2026-09-09T14:55Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-09T14:56Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-boxes (not reached) · spawn-parent (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-09T14:56Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-09T14:56Z  mode-guard  mode-check
  checked: gating-command=no · gating-script=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-09T14:56Z  session-index  session-indexed  tool=Bash
  checked: — none reached
  outcome: ok — already indexed this session
  skipped: index-entry (this session was already indexed) · orphan-sweep (this session was already indexed)
2026-09-09T14:56Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-09T14:56Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-boxes (not reached) · spawn-parent (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-09T14:56Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-09T14:57Z  mode-guard  mode-check
  checked: gating-command=no · gating-script=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-09T14:57Z  session-index  session-indexed  tool=Bash
  checked: — none reached
  outcome: ok — already indexed this session
  skipped: index-entry (this session was already indexed) · orphan-sweep (this session was already indexed)
2026-09-09T14:57Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-09T14:57Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-09T14:57Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-boxes (not reached) · spawn-parent (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-09T14:57Z  mode-guard  mode-check
  checked: gating-command=no · gating-script=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-09T14:57Z  session-index  session-indexed  tool=Bash
  checked: — none reached
  outcome: ok — already indexed this session
  skipped: index-entry (this session was already indexed) · orphan-sweep (this session was already indexed)
2026-09-09T14:57Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-09T14:57Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-boxes (not reached) · spawn-parent (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-09T14:57Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-09T14:57Z  session-index  session-indexed  tool=Bash
  checked: — none reached
  outcome: ok — already indexed this session
  skipped: index-entry (this session was already indexed) · orphan-sweep (this session was already indexed)
2026-09-09T14:57Z  mode-guard  mode-check
  checked: gating-command=no · gating-script=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-09T14:57Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-09T14:57Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-boxes (not reached) · spawn-parent (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-09T14:57Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-09T14:58Z  session-index  session-indexed  tool=Bash
  checked: — none reached
  outcome: ok — already indexed this session
  skipped: index-entry (this session was already indexed) · orphan-sweep (this session was already indexed)
2026-09-09T14:58Z  mode-guard  mode-check
  checked: gating-command=no · gating-script=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-09T14:58Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-09T14:58Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-09T14:58Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-boxes (not reached) · spawn-parent (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-09T14:58Z  session-index  session-indexed  tool=Bash
  checked: — none reached
  outcome: ok — already indexed this session
  skipped: index-entry (this session was already indexed) · orphan-sweep (this session was already indexed)
2026-09-09T14:58Z  mode-guard  mode-check
  checked: gating-command=no · gating-script=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-09T14:58Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-09T14:58Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-boxes (not reached) · spawn-parent (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-09T14:58Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-09T14:58Z  mode-guard  mode-check
  checked: gating-command=no · gating-script=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-09T14:58Z  session-index  session-indexed  tool=Bash
  checked: — none reached
  outcome: ok — already indexed this session
  skipped: index-entry (this session was already indexed) · orphan-sweep (this session was already indexed)
2026-09-09T14:58Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-09T14:58Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-boxes (not reached) · spawn-parent (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-09T14:58Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-09T14:59Z  mode-guard  mode-check
  checked: gating-command=no · gating-script=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-09T14:59Z  session-index  session-indexed  tool=Bash
  checked: — none reached
  outcome: ok — already indexed this session
  skipped: index-entry (this session was already indexed) · orphan-sweep (this session was already indexed)
2026-09-09T14:59Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-09T14:59Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-boxes (not reached) · spawn-parent (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-09T14:59Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-09T14:59Z  mode-guard  mode-check
  checked: gating-command=no · gating-script=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-09T14:59Z  session-index  session-indexed  tool=Bash
  checked: — none reached
  outcome: ok — already indexed this session
  skipped: index-entry (this session was already indexed) · orphan-sweep (this session was already indexed)
2026-09-09T14:59Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-09T14:59Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-09T14:59Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-boxes (not reached) · spawn-parent (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-09T14:59Z  session-index  session-indexed  tool=Bash
  checked: — none reached
  outcome: ok — already indexed this session
  skipped: index-entry (this session was already indexed) · orphan-sweep (this session was already indexed)
2026-09-09T14:59Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-09T14:59Z  mode-guard  mode-check
  checked: gating-command=no · gating-script=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-09T15:01Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-boxes (not reached) · spawn-parent (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-09T15:01Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-09T15:01Z  mode-guard  mode-check
  checked: gating-command=no · gating-script=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-09T15:01Z  session-index  session-indexed  tool=Bash
  checked: — none reached
  outcome: ok — already indexed this session
  skipped: index-entry (this session was already indexed) · orphan-sweep (this session was already indexed)
2026-09-09T15:01Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-09T15:01Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-09T15:01Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-boxes (not reached) · spawn-parent (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-09T15:01Z  mode-guard  mode-check
  checked: gating-command=no · gating-script=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-09T15:01Z  session-index  session-indexed  tool=Bash
  checked: — none reached
  outcome: ok — already indexed this session
  skipped: index-entry (this session was already indexed) · orphan-sweep (this session was already indexed)
2026-09-09T15:01Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-09T15:01Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-boxes (not reached) · spawn-parent (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-09T15:01Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-09T15:02Z  mode-guard  mode-check
  checked: gating-command=no · gating-script=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-09T15:02Z  session-index  session-indexed  tool=Bash
  checked: — none reached
  outcome: ok — already indexed this session
  skipped: index-entry (this session was already indexed) · orphan-sweep (this session was already indexed)
2026-09-09T15:02Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-09T15:02Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-boxes (not reached) · spawn-parent (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-09T15:02Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-09T15:02Z  mode-guard  mode-check
  checked: gating-command=no · gating-script=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-09T15:02Z  session-index  session-indexed  tool=Bash
  checked: — none reached
  outcome: ok — already indexed this session
  skipped: index-entry (this session was already indexed) · orphan-sweep (this session was already indexed)
2026-09-09T15:02Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-09T15:02Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-boxes (not reached) · spawn-parent (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-09T15:02Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-09T15:03Z  mode-guard  mode-check
  checked: gating-command=no · gating-script=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-09T15:03Z  session-index  session-indexed  tool=Bash
  checked: — none reached
  outcome: ok — already indexed this session
  skipped: index-entry (this session was already indexed) · orphan-sweep (this session was already indexed)
2026-09-09T15:03Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-09T15:03Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-boxes (not reached) · spawn-parent (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-09T15:03Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-09T15:03Z  mode-guard  mode-check
  checked: gating-command=no · gating-script=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-09T15:03Z  session-index  session-indexed  tool=Bash
  checked: — none reached
  outcome: ok — already indexed this session
  skipped: index-entry (this session was already indexed) · orphan-sweep (this session was already indexed)
2026-09-09T15:03Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-09T15:03Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-boxes (not reached) · spawn-parent (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-09T15:03Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-09T15:04Z  mode-guard  mode-check
  checked: gating-command=no · gating-script=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-09T15:04Z  session-index  session-indexed  tool=Bash
  checked: — none reached
  outcome: ok — already indexed this session
  skipped: index-entry (this session was already indexed) · orphan-sweep (this session was already indexed)
2026-09-09T15:04Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-09T15:04Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-boxes (not reached) · spawn-parent (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-09T15:04Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-09T15:04Z  mode-guard  mode-check
  checked: gating-command=no · gating-script=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-09T15:04Z  session-index  session-indexed  tool=Bash
  checked: — none reached
  outcome: ok — already indexed this session
  skipped: index-entry (this session was already indexed) · orphan-sweep (this session was already indexed)
2026-09-09T15:04Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-09T15:04Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-boxes (not reached) · spawn-parent (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-09T15:04Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-09T15:04Z  mode-guard  mode-check
  checked: gating-command=no · gating-script=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-09T15:04Z  session-index  session-indexed  tool=Bash
  checked: — none reached
  outcome: ok — already indexed this session
  skipped: index-entry (this session was already indexed) · orphan-sweep (this session was already indexed)
2026-09-09T15:04Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-09T15:04Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-09T15:04Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-boxes (not reached) · spawn-parent (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-09T15:07Z  mode-guard  mode-check
  checked: gating-command=no · gating-script=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-09T15:07Z  session-index  session-indexed  tool=Bash
  checked: — none reached
  outcome: ok — already indexed this session
  skipped: index-entry (this session was already indexed) · orphan-sweep (this session was already indexed)
2026-09-09T15:07Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-09T15:07Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-boxes (not reached) · spawn-parent (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-09T15:07Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-09T15:07Z  mode-guard  mode-check
  checked: gating-command=no · gating-script=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-09T15:07Z  session-index  session-indexed  tool=Bash
  checked: — none reached
  outcome: ok — already indexed this session
  skipped: index-entry (this session was already indexed) · orphan-sweep (this session was already indexed)
2026-09-09T15:07Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-09T15:07Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-boxes (not reached) · spawn-parent (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-09T15:07Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-09T15:07Z  mode-guard  mode-check
  checked: gating-command=no · gating-script=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-09T15:07Z  session-index  session-indexed  tool=Bash
  checked: — none reached
  outcome: ok — already indexed this session
  skipped: index-entry (this session was already indexed) · orphan-sweep (this session was already indexed)
2026-09-09T15:07Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-09T15:07Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-09T15:07Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-boxes (not reached) · spawn-parent (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-09T15:07Z  session-index  session-indexed  tool=Bash
  checked: — none reached
  outcome: ok — already indexed this session
  skipped: index-entry (this session was already indexed) · orphan-sweep (this session was already indexed)
2026-09-09T15:07Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-09T15:07Z  mode-guard  mode-check
  checked: gating-command=yes · mode-row=autonomous — all ok
  outcome: ok — autonomous — the command is allowed
  skipped: gating-script (the command names a gating command outright)
2026-09-09T15:07Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-boxes (not reached) · spawn-parent (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-09T15:07Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-09T15:08Z  mode-guard  mode-check
  checked: gating-command=no · gating-script=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-09T15:08Z  session-index  session-indexed  tool=Bash
  checked: — none reached
  outcome: ok — already indexed this session
  skipped: index-entry (this session was already indexed) · orphan-sweep (this session was already indexed)
2026-09-09T15:08Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-09T15:08Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-09T15:08Z  tracker-verify  issue-close
  checked: — none reached
  outcome: ok — nothing to report
  skipped: close-link (the command names no issue number) · placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · issue-boxes (not reached) · spawn-parent (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-09T15:08Z  session-index  session-indexed  tool=Bash
  checked: — none reached
  outcome: ok — already indexed this session
  skipped: index-entry (this session was already indexed) · orphan-sweep (this session was already indexed)
2026-09-09T15:08Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-09T15:08Z  mode-guard  mode-check
  checked: gating-command=yes · mode-row=autonomous — all ok
  outcome: ok — autonomous — the command is allowed
  skipped: gating-script (the command names a gating command outright)
2026-09-09T15:08Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-09T15:08Z  tracker-verify  issue-close
  checked: — none reached
  outcome: ok — nothing to report
  skipped: close-link (the command names no issue number) · placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · issue-boxes (not reached) · spawn-parent (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-09T15:08Z  session-index  session-indexed  tool=Bash
  checked: — none reached
  outcome: ok — already indexed this session
  skipped: index-entry (this session was already indexed) · orphan-sweep (this session was already indexed)
2026-09-09T15:08Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-09T15:08Z  mode-guard  mode-check
  checked: gating-command=yes · mode-row=autonomous — all ok
  outcome: ok — autonomous — the command is allowed
  skipped: gating-script (the command names a gating command outright)
2026-09-09T15:09Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-boxes (not reached) · spawn-parent (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-09T15:09Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-09T15:09Z  session-index  session-indexed  tool=Bash
  checked: — none reached
  outcome: ok — already indexed this session
  skipped: index-entry (this session was already indexed) · orphan-sweep (this session was already indexed)
2026-09-09T15:09Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-09T15:09Z  mode-guard  mode-check
  checked: gating-command=yes · mode-row=autonomous — all ok
  outcome: ok — autonomous — the command is allowed
  skipped: gating-script (the command names a gating command outright)
2026-09-09T15:09Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-boxes (not reached) · spawn-parent (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-09T15:09Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-09T15:09Z  mode-guard  mode-check
  checked: gating-command=no · gating-script=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-09T15:09Z  session-index  session-indexed  tool=Bash
  checked: — none reached
  outcome: ok — already indexed this session
  skipped: index-entry (this session was already indexed) · orphan-sweep (this session was already indexed)
2026-09-09T15:09Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-09T15:09Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-boxes (not reached) · spawn-parent (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-09T15:09Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-09T15:09Z  session-index  session-indexed  tool=Bash
  checked: — none reached
  outcome: ok — already indexed this session
  skipped: index-entry (this session was already indexed) · orphan-sweep (this session was already indexed)
2026-09-09T15:09Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-09T15:09Z  mode-guard  mode-check
  checked: gating-command=yes · mode-row=autonomous — all ok
  outcome: ok — autonomous — the command is allowed
  skipped: gating-script (the command names a gating command outright)
2026-09-09T15:09Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-boxes (not reached) · spawn-parent (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-09T15:09Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-09T15:10Z  session-index  session-indexed  tool=Bash
  checked: — none reached
  outcome: ok — already indexed this session
  skipped: index-entry (this session was already indexed) · orphan-sweep (this session was already indexed)
2026-09-09T15:10Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-09T15:10Z  mode-guard  mode-check
  checked: gating-command=yes · mode-row=autonomous — all ok
  outcome: ok — autonomous — the command is allowed
  skipped: gating-script (the command names a gating command outright)
2026-09-09T15:10Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-09T15:10Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-boxes (not reached) · spawn-parent (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-09T15:10Z  mode-guard  mode-check
  checked: gating-command=no · gating-script=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-09T15:10Z  session-index  session-indexed  tool=Bash
  checked: — none reached
  outcome: ok — already indexed this session
  skipped: index-entry (this session was already indexed) · orphan-sweep (this session was already indexed)
2026-09-09T15:10Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-09T15:10Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-boxes (not reached) · spawn-parent (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-09T15:10Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-09T15:10Z  mode-guard  mode-check
  checked: gating-command=no · gating-script=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-09T15:10Z  session-index  session-indexed  tool=Bash
  checked: — none reached
  outcome: ok — already indexed this session
  skipped: index-entry (this session was already indexed) · orphan-sweep (this session was already indexed)
2026-09-09T15:10Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-09T15:11Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-boxes (not reached) · spawn-parent (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-09T15:11Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-09T15:11Z  session-index  session-indexed  tool=Bash
  checked: — none reached
  outcome: ok — already indexed this session
  skipped: index-entry (this session was already indexed) · orphan-sweep (this session was already indexed)
2026-09-09T15:11Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-09T15:11Z  mode-guard  mode-check
  checked: gating-command=no · gating-script=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-09T15:11Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-boxes (not reached) · spawn-parent (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-09T15:11Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-09T15:11Z  mode-guard  mode-check
  checked: gating-command=no · gating-script=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-09T15:11Z  session-index  session-indexed  tool=Bash
  checked: — none reached
  outcome: ok — already indexed this session
  skipped: index-entry (this session was already indexed) · orphan-sweep (this session was already indexed)
2026-09-09T15:11Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-09T15:11Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-09T15:11Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-boxes (not reached) · spawn-parent (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-09T15:11Z  mode-guard  mode-check
  checked: gating-command=no · gating-script=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-09T15:11Z  session-index  session-indexed  tool=Bash
  checked: — none reached
  outcome: ok — already indexed this session
  skipped: index-entry (this session was already indexed) · orphan-sweep (this session was already indexed)
2026-09-09T15:11Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-09T15:11Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-boxes (not reached) · spawn-parent (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-09T15:11Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-09T15:12Z  session-index  session-indexed  tool=Bash
  checked: — none reached
  outcome: ok — already indexed this session
  skipped: index-entry (this session was already indexed) · orphan-sweep (this session was already indexed)
2026-09-09T15:12Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-09T15:12Z  mode-guard  mode-check
  checked: gating-command=no · gating-script=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-09T15:12Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-boxes (not reached) · spawn-parent (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-09T15:12Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-09T15:12Z  mode-guard  mode-check
  checked: gating-command=no · gating-script=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-09T15:12Z  session-index  session-indexed  tool=Bash
  checked: — none reached
  outcome: ok — already indexed this session
  skipped: index-entry (this session was already indexed) · orphan-sweep (this session was already indexed)
2026-09-09T15:12Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-09T15:12Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-boxes (not reached) · spawn-parent (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-09T15:12Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-09T15:12Z  mode-guard  mode-check
  checked: gating-command=no · gating-script=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-09T15:12Z  session-index  session-indexed  tool=Bash
  checked: — none reached
  outcome: ok — already indexed this session
  skipped: index-entry (this session was already indexed) · orphan-sweep (this session was already indexed)
2026-09-09T15:12Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-09T15:12Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-boxes (not reached) · spawn-parent (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-09T15:12Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-09T15:13Z  session-index  session-indexed  tool=Edit
  checked: — none reached
  outcome: ok — already indexed this session
  skipped: index-entry (this session was already indexed) · orphan-sweep (this session was already indexed)
2026-09-09T15:13Z  camp-session-start  session-start
  checked: — none reached
  outcome: ok — already checked this session
  skipped: arc-active (no arc registry exists yet) · branch-is-work (already checked this session) · issue-in-branch-name (already checked this session)
2026-09-09T15:13Z  handoff-archive  handoff-archived  tool=Edit
  checked: handoff-snapshot=nothing-to-copy · user-authored-file-archived=nothing-to-copy — all ok
  outcome: ok — nothing needed a copy
2026-09-09T15:13Z  branch-guard  edit-checked  branch=arc/04-dogfood-issue-238-log-volume prefix=arc/
  checked: branch-kind=work · worktree-identity=own · base-freshness=current — all ok
  outcome: ok — nothing to report
  skipped: path-is-source (the branch is not a coordination branch)
2026-09-09T15:13Z  session-index  session-indexed  tool=Edit
  checked: — none reached
  outcome: ok — already indexed this session
  skipped: index-entry (this session was already indexed) · orphan-sweep (this session was already indexed)
2026-09-09T15:13Z  camp-session-start  session-start
  checked: — none reached
  outcome: ok — already checked this session
  skipped: arc-active (no arc registry exists yet) · branch-is-work (already checked this session) · issue-in-branch-name (already checked this session)
2026-09-09T15:13Z  handoff-archive  handoff-archived  tool=Edit
  checked: handoff-snapshot=nothing-to-copy · user-authored-file-archived=nothing-to-copy — all ok
  outcome: ok — nothing needed a copy
2026-09-09T15:13Z  branch-guard  edit-checked  branch=arc/04-dogfood-issue-238-log-volume prefix=arc/
  checked: branch-kind=work · worktree-identity=own · base-freshness=current — all ok
  outcome: ok — nothing to report
  skipped: path-is-source (the branch is not a coordination branch)
2026-09-09T15:13Z  session-index  session-indexed  tool=Edit
  checked: — none reached
  outcome: ok — already indexed this session
  skipped: index-entry (this session was already indexed) · orphan-sweep (this session was already indexed)
2026-09-09T15:13Z  camp-session-start  session-start
  checked: — none reached
  outcome: ok — already checked this session
  skipped: arc-active (no arc registry exists yet) · branch-is-work (already checked this session) · issue-in-branch-name (already checked this session)
2026-09-09T15:13Z  handoff-archive  handoff-archived  tool=Edit
  checked: handoff-snapshot=nothing-to-copy · user-authored-file-archived=nothing-to-copy — all ok
  outcome: ok — nothing needed a copy
2026-09-09T15:13Z  branch-guard  edit-checked  branch=arc/04-dogfood-issue-238-log-volume prefix=arc/
  checked: branch-kind=work · worktree-identity=own · base-freshness=current — all ok
  outcome: ok — nothing to report
  skipped: path-is-source (the branch is not a coordination branch)
2026-09-09T15:13Z  session-index  session-indexed  tool=Bash
  checked: — none reached
  outcome: ok — already indexed this session
  skipped: index-entry (this session was already indexed) · orphan-sweep (this session was already indexed)
2026-09-09T15:13Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-09T15:13Z  mode-guard  mode-check
  checked: gating-command=no · gating-script=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-09T15:13Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-09T15:13Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-boxes (not reached) · spawn-parent (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-09T15:14Z  session-index  session-indexed  tool=Bash
  checked: — none reached
  outcome: ok — already indexed this session
  skipped: index-entry (this session was already indexed) · orphan-sweep (this session was already indexed)
2026-09-09T15:14Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-09T15:14Z  mode-guard  mode-check
  checked: gating-command=no · gating-script=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-09T15:14Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-09T15:14Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-boxes (not reached) · spawn-parent (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-09T15:14Z  session-index  session-indexed  tool=Bash
  checked: — none reached
  outcome: ok — already indexed this session
  skipped: index-entry (this session was already indexed) · orphan-sweep (this session was already indexed)
2026-09-09T15:14Z  mode-guard  mode-check
  checked: gating-command=no · gating-script=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-09T15:14Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-09T15:14Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-boxes (not reached) · spawn-parent (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-09T15:14Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-09T15:14Z  mode-guard  mode-check
  checked: gating-command=no · gating-script=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-09T15:14Z  session-index  session-indexed  tool=Bash
  checked: — none reached
  outcome: ok — already indexed this session
  skipped: index-entry (this session was already indexed) · orphan-sweep (this session was already indexed)
2026-09-09T15:14Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-09T15:14Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-boxes (not reached) · spawn-parent (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-09T15:14Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-09T15:15Z  mode-guard  mode-check
  checked: gating-command=no · gating-script=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-09T15:15Z  session-index  session-indexed  tool=Bash
  checked: — none reached
  outcome: ok — already indexed this session
  skipped: index-entry (this session was already indexed) · orphan-sweep (this session was already indexed)
2026-09-09T15:15Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-09T15:15Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-boxes (not reached) · spawn-parent (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-09T15:15Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-09T15:15Z  session-index  session-indexed  tool=Bash
  checked: — none reached
  outcome: ok — already indexed this session
  skipped: index-entry (this session was already indexed) · orphan-sweep (this session was already indexed)
2026-09-09T15:15Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-09T15:15Z  mode-guard  mode-check
  checked: gating-command=yes · mode-row=autonomous — all ok
  outcome: ok — autonomous — the command is allowed
  skipped: gating-script (the command names a gating command outright)
2026-09-09T15:15Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-boxes (not reached) · spawn-parent (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-09T15:15Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-09T15:15Z  mode-guard  mode-check
  checked: gating-command=no · gating-script=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-09T15:15Z  session-index  session-indexed  tool=Bash
  checked: — none reached
  outcome: ok — already indexed this session
  skipped: index-entry (this session was already indexed) · orphan-sweep (this session was already indexed)
2026-09-09T15:15Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-09T15:15Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-09T15:15Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-boxes (not reached) · spawn-parent (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-09T15:15Z  mode-guard  mode-check
  checked: gating-command=no · gating-script=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-09T15:15Z  session-index  session-indexed  tool=Bash
  checked: — none reached
  outcome: ok — already indexed this session
  skipped: index-entry (this session was already indexed) · orphan-sweep (this session was already indexed)
2026-09-09T15:15Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-09T15:15Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-09T15:15Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-boxes (not reached) · spawn-parent (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-09T15:15Z  session-index  session-indexed  tool=Bash
  checked: — none reached
  outcome: ok — already indexed this session
  skipped: index-entry (this session was already indexed) · orphan-sweep (this session was already indexed)
2026-09-09T15:15Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-09T15:15Z  mode-guard  mode-check
  checked: gating-command=no · gating-script=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-09T15:16Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-boxes (not reached) · spawn-parent (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-09T15:16Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-09T15:16Z  session-index  session-indexed  tool=Bash
  checked: — none reached
  outcome: ok — already indexed this session
  skipped: index-entry (this session was already indexed) · orphan-sweep (this session was already indexed)
2026-09-09T15:16Z  mode-guard  mode-check
  checked: gating-command=no · gating-script=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-09T15:16Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-09T15:16Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-boxes (not reached) · spawn-parent (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-09T15:16Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-09T15:16Z  mode-guard  mode-check
  checked: gating-command=no · gating-script=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-09T15:16Z  session-index  session-indexed  tool=Bash
  checked: — none reached
  outcome: ok — already indexed this session
  skipped: index-entry (this session was already indexed) · orphan-sweep (this session was already indexed)
2026-09-09T15:16Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-09T15:17Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-boxes (not reached) · spawn-parent (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-09T15:17Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-09T15:17Z  mode-guard  mode-check
  checked: gating-command=no · gating-script=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-09T15:17Z  session-index  session-indexed  tool=Bash
  checked: — none reached
  outcome: ok — already indexed this session
  skipped: index-entry (this session was already indexed) · orphan-sweep (this session was already indexed)
2026-09-09T15:17Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-09T15:17Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-boxes (not reached) · spawn-parent (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-09T15:17Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-09T15:17Z  mode-guard  mode-check
  checked: gating-command=no · gating-script=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-09T15:17Z  session-index  session-indexed  tool=Bash
  checked: — none reached
  outcome: ok — already indexed this session
  skipped: index-entry (this session was already indexed) · orphan-sweep (this session was already indexed)
2026-09-09T15:17Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-09T15:17Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-boxes (not reached) · spawn-parent (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-09T15:17Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-09T15:17Z  mode-guard  mode-check
  checked: gating-command=no · gating-script=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-09T15:17Z  session-index  session-indexed  tool=Bash
  checked: — none reached
  outcome: ok — already indexed this session
  skipped: index-entry (this session was already indexed) · orphan-sweep (this session was already indexed)
2026-09-09T15:17Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-09T15:17Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-boxes (not reached) · spawn-parent (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-09T15:17Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-09T15:18Z  session-index  session-indexed  tool=Bash
  checked: — none reached
  outcome: ok — already indexed this session
  skipped: index-entry (this session was already indexed) · orphan-sweep (this session was already indexed)
2026-09-09T15:18Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-09T15:18Z  mode-guard  mode-check
  checked: gating-command=yes · mode-row=autonomous — all ok
  outcome: ok — autonomous — the command is allowed
  skipped: gating-script (the command names a gating command outright)
2026-09-09T15:19Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-boxes (not reached) · spawn-parent (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-09T15:19Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-09T15:19Z  mode-guard  mode-check
  checked: gating-command=no · gating-script=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-09T15:19Z  session-index  session-indexed  tool=Bash
  checked: — none reached
  outcome: ok — already indexed this session
  skipped: index-entry (this session was already indexed) · orphan-sweep (this session was already indexed)
2026-09-09T15:19Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-09T15:19Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-boxes (not reached) · spawn-parent (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-09T15:19Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-09T15:20Z  session-index  session-indexed  tool=Bash
  checked: — none reached
  outcome: ok — already indexed this session
  skipped: index-entry (this session was already indexed) · orphan-sweep (this session was already indexed)
2026-09-09T15:20Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-09T15:20Z  mode-guard  mode-check
  checked: gating-command=yes · mode-row=autonomous — all ok
  outcome: ok — autonomous — the command is allowed
  skipped: gating-script (the command names a gating command outright)
2026-09-09T15:20Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-09T15:20Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-boxes (not reached) · spawn-parent (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-09T15:20Z  mode-guard  mode-check
  checked: gating-command=no · gating-script=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-09T15:20Z  session-index  session-indexed  tool=Bash
  checked: — none reached
  outcome: ok — already indexed this session
  skipped: index-entry (this session was already indexed) · orphan-sweep (this session was already indexed)
2026-09-09T15:20Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-09T15:20Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-09T15:20Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-boxes (not reached) · spawn-parent (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-09T15:20Z  mode-guard  mode-check
  checked: gating-command=no · gating-script=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-09T15:20Z  session-index  session-indexed  tool=Bash
  checked: — none reached
  outcome: ok — already indexed this session
  skipped: index-entry (this session was already indexed) · orphan-sweep (this session was already indexed)
2026-09-09T15:20Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-09T15:20Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-boxes (not reached) · spawn-parent (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-09T15:20Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-09T15:21Z  mode-guard  mode-check
  checked: gating-command=no · gating-script=no — all ok
  outcome: ok — not a command the mode governs
  skipped: mode-row (the command is not one the mode governs)
2026-09-09T15:21Z  session-index  session-indexed  tool=Bash
  checked: — none reached
  outcome: ok — already indexed this session
  skipped: index-entry (this session was already indexed) · orphan-sweep (this session was already indexed)
2026-09-09T15:21Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-09T15:21Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-boxes (not reached) · spawn-parent (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-09T15:21Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-09T15:22Z  session-index  session-indexed  tool=Bash
  checked: — none reached
  outcome: ok — already indexed this session
  skipped: index-entry (this session was already indexed) · orphan-sweep (this session was already indexed)
2026-09-09T15:22Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-09T15:22Z  mode-guard  mode-check
  checked: gating-command=yes · mode-row=autonomous — all ok
  outcome: ok — autonomous — the command is allowed
  skipped: gating-script (the command names a gating command outright)
2026-09-09T15:22Z  tracker-verify  tracker-write
  checked: — none reached
  outcome: ok — not a tracker write
  skipped: placeholder-scan (not reached) · date-sanity (not reached) · milestone (not reached) · arc-prefix (not reached) · closing-keyword (not reached) · arc-merge-keyword (not reached) · close-link (not reached) · issue-boxes (not reached) · spawn-parent (not reached) · issue-title-length (not reached) · issue-title-list (not reached) · issue-title-clause (not reached) · issue-title-scope (not reached) · issue-scope-type (not reached) · pr-base (not reached)
2026-09-09T15:22Z  camp-branch-check  branch-create
  checked: — none reached
  outcome: ok — the command creates no branch
  skipped: base-is-arc (not built) · declared-convention-read (the command creates no branch) · issue-or-pr-number-present (the command creates no branch)
2026-09-09T15:22Z  session-index  session-indexed  tool=Bash
  checked: — none reached
  outcome: ok — already indexed this session
  skipped: index-entry (this session was already indexed) · orphan-sweep (this session was already indexed)
2026-09-09T15:22Z  handoff-archive  handoff-archived  tool=Bash
  checked: — none reached
  outcome: ok — the snapshot was already taken this session
  skipped: handoff-snapshot (already taken this session) · user-authored-file-archived (the call names no file)
2026-09-09T15:22Z  mode-guard  mode-check
  checked: gating-command=yes · mode-row=autonomous — all ok
  outcome: ok — autonomous — the command is allowed
  skipped: gating-script (the command names a gating command outright)
