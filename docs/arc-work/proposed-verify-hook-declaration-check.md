# Proposal — `verify-hook.sh` reports a missing `camp-reports:` declaration

> **Not applied.** `tools/verify-hook.sh` is on CLAUDE.md's never-edited-autonomously list,
> alongside `settings.json`, the hook template and any `SessionStart` hook. It comes to the
> user as a proposal.

**Required by** [#45](https://github.com/Calyx-Engineering/arc/issues/45) — *"`tools/verify-hook.sh`
reports a hook with no declaration — **reports, never denies**, so it is a prompt rather than a
gate."*

---

## Why it is not applied

`verify-hook.sh` is the gate that runs before any hook is registered. A session that edits the
gate as part of ordinary work is the failure the exclusion exists to prevent — the same
reasoning that makes the gate a script rather than a hook.

Everything else in #45 is applied. This is the one item held back, and it is the reason the
issue's checklist cannot be fully ticked by an autonomous session.

---

## The change

One block, added after the per-case loop and before the summary. It reads the hook file
directly and never touches the pass/deny/malformed cases.

```bash
# ---- declaration check ----------------------------------------------------------
# Reports, never fails. A hook with no `camp-reports:` header still works — it is simply
# invisible when it fires, which is a gap worth naming at exactly the moment someone is
# already looking at the hook. Making it a failure would turn the convention into a cost
# paid while trying to fix something else.
if ! grep -q '^# camp-reports:' "$HOOK"; then
  echo
  echo "note: $HOOK has no \`camp-reports:\` declaration."
  echo "      It will not report when it fires and will write nothing to the event log."
  echo "      Format: docs/product-architecture/camp-reports.md"
fi
```

**It must not touch `PASSED`, `FAILED`, or the exit code.**

---

## Verification the user should ask for

| Case | Expected |
|---|---|
| `tools/verify-hook.sh hooks/branch-guard` | No note. It has a declaration |
| `tools/verify-hook.sh hooks/tracker-verify` | No note. It has a declaration |
| A hook copied from `hooks/TEMPLATE` with the stub deleted | The note appears, and the exit code is unchanged from the same run before this change |

The third case is the one that matters: **the note must not change the exit code.** Run the
same hook before and after and compare `echo $?`.

---

## Related

- [`camp-reports.md`](../product-architecture/camp-reports.md) — the format
- [m10](../product-architecture/mechanisms/m10-branch-guard.md) — why the gate is a script
- [#45](https://github.com/Calyx-Engineering/arc/issues/45) — the issue requiring this
