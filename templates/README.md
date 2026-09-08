# Templates — and the one rule that is not obvious

Each file here is **copied somewhere else before anyone reads it.** That makes a template the
only artifact whose links must be correct somewhere it is not, and it is why eighteen of them
shipped broken: every review read them here, where they were fine.

`tools/verify-template-links.sh` is the gate. It runs inside `tools/verify-all.sh`.

---

## Where each template lands

| Template | Copied into |
|---|---|
| `arc-log.md` | `docs/arc-log/arc-<slug>.md` |
| `dev-log.md` | `docs/dev-log/issue-<NN>-<slug>.md`, or `pr-<NN>-<slug>.md` |
| `handoff.md` | `HANDOFF.md`, at the repo root |
| `event-log.md` | `.claude/arc/log.md` |
| `issue.md` · `pr.md` | a body file the agent writes, then `gh issue create --body-file` |
| `SKILL.md` | `skills/<name>/SKILL.md` |
| `camp/operating-agreement.md` · `camp/voice.md` · `camp/notes.md` | `.claude/arc/camp/` |

**This table and the gate's `MAP` are the same fact.** A new template needs a row in both, and
the gate fails on a template it has no row for rather than skipping it.

---

## A link takes one of two forms, and the target decides which

> **Ask what the link points at, not how deep it is.**

| The target is | The link is | Because |
|---|---|---|
| **A plugin document** — a spec, a skill, a reference under `docs/` | An **absolute URL** to this repository | A consuming repo does not have `docs/product-architecture/` **at any depth.** The template is copied *out* of the plugin, so no relative path can reach back in |
| **Something in the consuming repo** — its own arc-log, dev-log, scratch | **Relative, resolved from the destination** | It is a real path in the repo the template now lives in |

**The two are not both depth problems, and that is the whole trap.** Re-basing a plugin link to
the correct depth produces a path that looks right and resolves to nothing — which is worse than
the original, because a plausible path stops anyone looking again.

```text
✓  [m43](https://github.com/Calyx-Engineering/arc/blob/main/docs/product-architecture/mechanisms/m43-camp-assistant.md)
✗  [m43](../../docs/product-architecture/mechanisms/m43-camp-assistant.md)      from .claude/arc/camp/ this is .claude/docs/…
✗  [m43](../../../docs/product-architecture/mechanisms/m43-camp-assistant.md)   correct depth, and the directory still does not exist

✓  [arc-log](../../docs/arc-log/)      from .claude/arc/ — the consuming repo's own
```

`arc-log.md` and `dev-log.md` were correct before the gate existed. **They are the worked
examples**: both land under `docs/`, and everything they point at is the consuming repo's.

---

## Related

- [`tools/verify-template-links.sh`](../tools/verify-template-links.sh) — the gate, and the destination map
- [`docs/release/pre-release-review.md`](../docs/release/pre-release-review.md) — pass 2, which is where this was found
- [m43](../docs/product-architecture/mechanisms/m43-camp-assistant.md) — `camp/`'s three documents and why a user reads them
