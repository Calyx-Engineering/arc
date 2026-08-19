# The `camp-reports:` declaration

> **The authority on the format.** Templates, artifacts and `tools/verify-hook.sh` point
> here rather than restating it, so there is one definition to change.

**An artifact that acts declares what it checks.** That one declaration drives both the
spoken report and the [event-log](../../templates/event-log.md) entry — an artifact does not
maintain two lists.

An artifact with no declaration produces no report and writes nothing to the log. **Silence
is the default**, so a missing declaration is invisible rather than noisy — which is why
`tools/verify-hook.sh` reports it.

---

## The rule

> **An artifact states what it checked for, not only what it found.**

```text
✗  milestone missing
✓  checked milestone — not set
```

One extra word keeps the machinery visible when checks pass. Only reporting failures makes a
silent artifact indistinguishable from a working one — the user cannot tell whether Arc
helped, was absent, or was wrong, and invisible tooling produces no improvement signal.

---

## The declaration

Three fields. `checks` is the list; the other two name when it speaks and what it is.

| Field | | |
|---|---|---|
| `camp-reports` | The event names this artifact reports on | `pr-open`, `branch-create`, `edit-denied` |
| `checks` | Every check it performs, hyphenated. **Including the ones that usually pass** | `milestone`, `arc-prefix`, `closing-keyword` |
| `skips` | Checks that are conditional, and the condition | `placeholder-scan (no body edit)` |

**`skips` is what makes a declared-but-unrun check visible.** Without it, an artifact that was
quiet because everything passed is indistinguishable from one that never ran.

### In a skill — YAML frontmatter

```yaml
---
name: issue-write
description: ...
camp-reports: [pr-open, pr-edit, issue-create, issue-edit]
checks: [base-branch, milestone, arc-prefix, closing-keyword, read-back]
skips:
  - placeholder-scan (only when a body was edited)
---
```

### In a hook — a comment block

Hooks are shell scripts, so the declaration is a comment. **Placed directly under the
one-line description**, before the kill switch.

```bash
#!/usr/bin/env bash
# branch-guard — PreToolUse hook (matcher: Edit|Write|NotebookEdit). Carries m10.
#
# camp-reports: edit-denied, edit-allowed
# checks: branch-is-coordination, path-is-source
# skips: worktree-identity (not built), base-freshness (not built)
```

---

## What it produces

### The spoken report

```text
**Camp here —** PR #33 opened.
  Checked: milestone, arc prefix, closing keywords — all set
  Declared but skipped: placeholder scan (no body edit)
```

| | |
|---|---|
| **The artifact speaks, in Camp's voice** | Camp does not narrate it. The prefix marks it as Arc's operation rather than the main thread's |
| **The skipped line is emitted unconditionally** | Suppressed only by a `skips` entry being absent, or by an agreement clause |
| **Reports default to `normal` verbosity** | The outcome only. `loud` adds the checked and skipped lines; `quiet` shows nothing |

Verbosity is read from `.claude/arc/camp/voice.md`. **It governs display, never retention.**

### The log entry

The same names, appended to `.claude/arc/log.md` regardless of verbosity. Format in
[`templates/event-log.md`](../../templates/event-log.md).

```text
2026-08-19T09:41Z  issue-write  pr-open  pr=51 issue=39
  checked: milestone · arc-prefix · closing-keyword — all set
  outcome: ok — Closes #39 bound
  skipped: placeholder-scan (no body edit)
```

| Declared, and… | Report | Log |
|---|---|---|
| ran, passed | On the checked line | On the checked line |
| ran, failed | On the checked line, and in the outcome | Both |
| did not run | On the skipped line | On the skipped line |
| not declared at all | Nothing | Nothing |

---

## Future artifacts inherit this

A convention living only in the artifacts that already have it is one the next artifact
silently omits.

| Carrier | |
|---|---|
| [`hooks/TEMPLATE`](../../hooks/TEMPLATE) | Carries a `camp-reports:` stub beside the kill switch and the fail-open wrapper |
| [`templates/SKILL.md`](../../templates/SKILL.md) | Carries the same stub in its frontmatter |
| `tools/verify-hook.sh` | **Reports** a hook with no declaration — never denies |

**The gate reports, it does not block.** A missing declaration makes an artifact invisible; it
does not make it wrong. Blocking on it would make the convention a cost at exactly the moment
someone is trying to fix something else.

---

## Related

- [`templates/event-log.md`](../../templates/event-log.md) — the entry format this produces
- [m43 §3.5](mechanisms/m43-camp-assistant.md) — obligation 4, which this implements
- [m44](mechanisms/m44-event-log.md) — the log, and why verbosity cannot reach it
