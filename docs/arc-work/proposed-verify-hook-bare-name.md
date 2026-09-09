# Proposal — `verify-hook.sh` accepts a bare hook name

> **Not applied.** `tools/verify-hook.sh` is on CLAUDE.md's never-edited-autonomously list,
> alongside `settings.json`, the hook template and any `SessionStart` hook. It comes to the
> user as a proposal.

**Raised by** [#264](https://github.com/Calyx-Engineering/arc/issues/264) — `bash tools/verify-hook.sh tracker-verify`
exits 2 while every case passes.

---

## The failure

```
$ bash tools/verify-hook.sh tracker-verify
usage: tools/verify-hook.sh <path-to-hook>
$ echo $?
2
```

No case runs. The script takes a **path**, and `tracker-verify` is not one:

```bash
HOOK="${1:-}"
if [ -z "$HOOK" ] || [ ! -f "$HOOK" ]; then
  echo "usage: tools/verify-hook.sh <path-to-hook>" >&2
  exit 2
fi
```

`hooks/tracker-verify` runs and passes — 78 passed, 0 failed, exit 0.

Exit 2 is the usage code, and the usage line is the only output. It reads as a hook failure to
anyone scanning the exit code, which is how [#210](https://github.com/Calyx-Engineering/arc/issues/210)
closed with a box unticked that the tree had already satisfied.

---

## The change

Resolve a bare name against `hooks/` before the usage check. `CASES_DIR` works off
`basename "$HOOK"`, so it is unaffected. `$HOOK` is used raw in six other places: the two
`bash "$HOOK"` runs, the two `grep`s, the header line, and the `camp-reports:` note. The first
four take a path either way; the last two print one.

```bash
HOOK="${1:-}"

# A bare hook name is what the tracker and the docs write. Resolve it to the file rather than
# printing usage — exit 2 with no cases run is indistinguishable from a hook that failed.
if [ -n "$HOOK" ] && [ ! -f "$HOOK" ] && [ -f "$(dirname "$0")/../hooks/$HOOK" ]; then
  HOOK="$(dirname "$0")/../hooks/$HOOK"
fi

if [ -z "$HOOK" ] || [ ! -f "$HOOK" ]; then
  echo "usage: tools/verify-hook.sh <hook-name-or-path>" >&2
  exit 2
fi
```

**It must not change any exit code that is already 0 or 1.** A path argument takes the same
branch it takes today — `[ -f "$HOOK" ]` short-circuits the new block — so only the
previously-fatal bare name moves.

**Three outputs change, all on paths a bare name reaches.** None is asserted on anywhere in
the repo — `path-to-hook` appears only in the script itself and in transcripts of this failure.

| | |
|---|---|
| **The usage string** | `<path-to-hook>` becomes `<hook-name-or-path>`. The old one now describes half of what is accepted |
| **The header line, and the `camp-reports:` note** | Both print `$HOOK`, so a bare-name run shows the resolved path: `verify-hook.sh — tools/../hooks/tracker-verify`. `$0`-derived, so the exact string follows how the script was invoked |
| **A bare name with no case directory** | `hooks.json` now reaches `no case directory: tools/hook-cases/hooks.json` instead of the usage line. Exit 2 either way |

---

## Verification the user should ask for

| Case | Expected |
|---|---|
| `tools/verify-hook.sh hooks/tracker-verify` | Unchanged — 78 passed, 0 failed, exit 0 |
| `tools/verify-hook.sh tracker-verify` | Same tally, exit 0. The header line names the resolved path |
| `tools/verify-hook.sh nosuchhook` | `usage: tools/verify-hook.sh <hook-name-or-path>`, exit 2 |
| `tools/verify-hook.sh` with no argument | Same, exit 2 |

The first case is the one that matters: **a path argument naming a file that exists must produce byte-identical output.** A path that does not exist reaches the usage line, whose wording changed.

---

## If it is declined

The alternative costs nothing and is already done: every citation that is an invocation writes
the path. The bare form survives only in records of this failure and in `m10`'s and `m31`'s
`verify-hook.sh <hook>` placeholder.

---

## Related

- [#264](https://github.com/Calyx-Engineering/arc/issues/264) — the issue
- [#210](https://github.com/Calyx-Engineering/arc/issues/210) — the box this stranded
- [m10](../product-architecture/mechanisms/m10-branch-guard.md) — why the gate is a script
