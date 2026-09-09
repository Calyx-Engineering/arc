# Proposal — `hooks/TEMPLATE` carries the activation-log boilerplate

> **Not applied.** `hooks/TEMPLATE` is on CLAUDE.md's never-edited-autonomously list, beside
> `settings.json`, `tools/verify-hook.sh` and any `SessionStart` hook. It comes to the user as
> a proposal.

**Required by** [#166](https://github.com/Calyx-Engineering/arc/issues/166) — *"Every hook
appends one line before exit, success or failure."* Every registered hook now does. The
template is what makes the **next** one do it without anyone remembering.

---

## Why it is not applied

The template is the skeleton every future hook is copied from, so a mistake in it is a
mistake in every hook written after it — which is the same reasoning that excludes the gate
that checks hooks. The five registered hooks were changed and verified one at a time; the
template cannot be verified that way, because nothing runs it.

`tests/verify-activation-log.sh` asserts that every hook in `hooks/` other than `TEMPLATE`
sources the library, so a new hook copied from the template and registered fails the gate
rather than logging nothing in silence. `TEMPLATE` is excluded because nothing runs it — which
is exactly why the boilerplate has to be in it. That is the
backstop while this proposal is unapplied — it catches the omission, it just catches it later
than the template would.

---

## The change

Two blocks. The first goes immediately after the kill switch, before the fail-open wrapper.

```bash
# ---- the activation log ---------------------------------------------------------
# Sourced here, before anything can exit, so an entry is written whichever way this hook
# leaves — an early `exit 0` included. Nothing below needs to remember to log. m44.
. "$(dirname "$0")/lib/activation-log" 2>/dev/null
arc_log_event <event>
```

The second is one line inside `deny()` — and inside `report()`, in a hook that reports:

```bash
deny() {
  arc_log_outcome_default denied "the hook denied the call"
  printf '%s' "{\"hookSpecificOutput\"…
```

And one line in the header block, above the `camp-reports:` declaration it depends on:

```text
# The `checks:` line below is read by the activation log as well as by the report — a check
# named there and never marked is written to the entry as `not reached`.
```

**Except on a firing that reaches nothing.** Where no declared check ran and the outcome is
`ok`, the entry carries no `skipped:` line at all — neither the unreached names nor any
`arc_log_skip` reason, both of which restate the `outcome:` line there.
[#238](https://github.com/Calyx-Engineering/arc/issues/238); the rule is
[`templates/event-log.md`](../../templates/event-log.md)'s.

---

## What a hook then calls

Nothing is mandatory; an entry is written either way. The full contract is the library's own
header comment.

| | |
|---|---|
| `arc_log_event <event> [subject]` | What happened, and to what |
| `arc_log_pass <name>[=<value>]` | A declared check that ran and passed |
| `arc_log_fail <name>[=<value>]` | A declared check that ran and found something |
| `arc_log_skip <name> <why>` | A declared check that did not run, and why |
| `arc_log_outcome <word> <detail>` | `ok` · `denied` · `repaired` · `failed`, then detail |

---

## Verification the user should ask for

| Case | Expected |
|---|---|
| A hook copied from the changed template, with a case directory | `bash tests/verify-activation-log.sh <hook>` passes without the author writing a log line |
| The same hook with the sourcing line deleted | The gate fails, naming the hook |
| `bash tools/verify-hook.sh` on any existing hook | Unchanged — the template is not executed by it |

The first case is the one that matters: **the boilerplate has to produce a valid entry with
no further calls**, or the next hook's author has to know the library exists.

---

## Related

- [`hooks/lib/activation-log`](../../hooks/lib/activation-log) — the library this sources
- [`templates/event-log.md`](../../templates/event-log.md) — the entry format
- [m44](../product-architecture/mechanisms/m44-event-log.md) — the mechanism
- [`proposed-verify-hook-declaration-check.md`](proposed-verify-hook-declaration-check.md) — the
  same exclusion, the same shape of proposal
- [#166](https://github.com/Calyx-Engineering/arc/issues/166) — the issue requiring this
