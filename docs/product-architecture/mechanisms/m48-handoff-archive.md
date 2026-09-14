# Mechanism — Handoff / User-Authored-File Archive

**Status:** built — ships as `hooks/handoff-archive` ([#152](https://github.com/Calyx-Engineering/arc/issues/152)). The Bash shell-overwrite forms (`>`, `mv`, `rm`, `cp`) were added in [#351](https://github.com/Calyx-Engineering/arc/issues/351); a compound command (a pipeline, `sed -i`, a glued operator) is still uncovered and named as such in the hook's own comments.
**Home:** Arc — Workspace guard.
**Src:** 🔥 observed.
**Covers:** m48.

---

## The friction

`HANDOFF.md` is gitignored — nothing behind it but whatever the session was holding when it
last rewrote the file. A session that rewrites it destroys the prior state with no copy
anywhere, the same shape as replacing a diagram someone spent hours on instead of archiving it
first.

Extending the same rule from the handoff to any user-authored file is what generalises the
fix: a file git can restore needs no copy — git *is* the copy — but an untracked or ignored
file has nothing behind it, so overwriting it is destruction.

## Two moments, not one check

| | |
|---|---|
| **1. The handoff, at the session's first tool call of any kind** | Not the handoff's own write. A session that crashes never reaches write time, so a copy taken then is a copy taken too late. Keyed to the session id, so it fires once |
| **2. Any other user-authored file, as it is about to be replaced** | Nothing can know in advance which file that will be, so the check runs on every `Edit`, `Write` and `NotebookEdit` call, and — since [#351](https://github.com/Calyx-Engineering/arc/issues/351) — on the four Bash forms below |

Both moments defer to git: `git ls-files --error-unmatch` decides whether a target is tracked,
and a tracked file is never archived.

## Why it is also on the Bash matcher

`cat > HANDOFF.md`, `mv`, `rm` and `cp` destroy a file without ever reaching `Edit` or `Write`.
Registered only on the edit tools, the hook missed every one of them. Bash gets moment 1
unconditionally — the snapshot fires on any tool call, which is what makes the cold-start
property hold whatever tool a session reaches for.

Moment 2 on Bash is a **word split of the command, not a shell parse** — `bash_overwrite_target()`
recognises four plain, single-command forms:

| Form | Target |
|---|---|
| A bare `>` or `1>` (never `>>`, `2>`, `&>`) | The word immediately after it |
| `mv` / `cp` | The last non-flag word — the destination, the side that loses content |
| `rm` | The first non-flag word |

`--` end-of-options is honoured for all three — `rm -- -confidential.txt` and
`mv -- foo -bar` are the standard idiom for a dash-named path, and a scan that treats the word
after `--` as a flag misses the `rm` target entirely or archives the wrong side of the `mv`.

**Named, not handled:** a pipeline, `&&`, a subshell, `sed -i`, a glued operator (`cat>file`),
and a quoted path with a space in it. A wrong guess there would copy the wrong file while
reporting success, which the hook never does — it fails open, archiving what it can name and
denying nothing.

Two more gaps the hook names in its own comments rather than fixes: the per-session markers it
leaves under `.git/` are never pruned, so a long-lived clone accumulates one per session
forever; and its Windows path-unescaping branch (`\\` → `/`) is exercised by no fixture, since
every fixture path comes from `mktemp` and every path git reports on this machine already uses
forward slashes — the branch that matters on Windows is the one no case runs.

## Silent on Bash, by design

`permissionDecision: "allow"` approves the call, not merely annotates it. That is a defensible
trade on the edit tools, where the decision is about a file the hook has just copied. It is not
defensible on Bash: the first Bash call of a session would be auto-approved as a side effect of
taking the snapshot, and that call can be anything. So Bash gets the copy and no output — an
empty stdout leaves the permission system exactly as it found it.

## What #351 fixed along the way

Review found two defects in the Bash parsing before it merged, neither a documented gap:

- **`field()` truncated a quoted `command` value at the first quote, escaped or not.** Written
  for values like `file_path` that never carry one, it silently dropped everything after the
  quote in `echo "note" > file` — the redirect was never seen and the file was destroyed with
  no copy. Fixed by walking the string and unescaping `\"`/`\\` rather than cutting at the
  first `"`.
- **A word after `--` was still read as a flag**, missing an `rm` target outright and archiving
  the source instead of the destination on `mv -- foo -bar`.

Both are permanent regression cases in `tests/verify-handoff-archive.sh`.

---

## Related

- [#152](https://github.com/Calyx-Engineering/arc/issues/152) — the original hook
- [#351](https://github.com/Calyx-Engineering/arc/issues/351) — the Bash shell-overwrite forms
- [session-preservation](m32-session-preservation.md) — the sibling recovery mechanism, for transcripts rather than working-tree files
