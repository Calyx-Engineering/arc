# Issue #258 — fix: the local operating agreement's links into m43 do not resolve

**Issue:** [#258](https://github.com/Calyx-Engineering/arc/issues/258)  ·  **PR:** TBD

## Problem

`.claude/arc/camp/operating-agreement.md` carries 9 links into m43. 8 did not resolve — the
seven `#3N-obligation-N-…` anchors and the relief-valve anchor all dated from before #42 renamed
the five obligations, and nothing caught the drift.

## Intent and north star

| | |
|---|---|
| **What this issue is really for** | The agreement is the user-approved document m43 tells him to read; a dead link in it is a broken promise to the reader, not cosmetic |
| **North star** | Every m43 link in the agreement resolves, and a gate fails if one goes stale again |
| **What makes it durable** | The gate computes each target's real heading slugs and compares, rather than hardcoding the nine correct strings — the next rename is caught the same way #42's was missed |
| **Out of scope** | Re-basing `templates/camp/operating-agreement.md`'s link *style* (absolute GitHub URLs) onto the local copy — the two forms exist for different reasons (§ verify-template-links.sh's own header) and this issue is about the anchors, not the style |

## Decisions & trade-offs

- **New gate, not an extension of `verify-template-links.sh`.** That script checks a template's
  links resolve at the directory it lands in — a path-existence question. This file already IS
  the landed copy; the defect was an anchor pointing at a heading slug that no longer exists,
  which is a different question (heading identity, not path depth). Bolting it onto the template
  checker would have conflated the two.
- **Slug computed, not hardcoded.** `slugify()` replicates GitHub's heading-anchor algorithm
  (lowercase; keep only letters/digits/spaces/hyphens; spaces → hyphens; hyphens never
  collapsed) so a future heading rename is caught structurally instead of requiring someone to
  update a table of known-good anchors by hand.
- **Windows `python` prints CRLF.** The gate's `slugify()` shells out to `python` (this repo's
  convention — see `tools/topic-numbering.sh`, `tools/report-grade.sh` — not `python3`, which on
  this machine resolves to the Microsoft Store stub). On Windows, `print()` writes `\r\n` even
  though the script only ever asked for `\n`, so every computed slug carried a trailing `\r` and
  matched nothing. Fixed by piping `slugify`'s output through `tr -d '\r'`.

## Rejected approaches

- Fixing only the two `Required` checklist rows and leaving the gate for later — rejected
  because the third row is a `Required` box, not a nice-to-have, and a gate is what stops this
  exact defect from recurring silently.

## Retrospective

Fixed all 9 anchors in `.claude/arc/camp/operating-agreement.md` against m43's current headings
(verified against `templates/camp/operating-agreement.md`'s already-correct absolute-URL forms,
which use the same anchors). Added `tests/verify-camp-agreement-links.sh` — extracts every
anchored link out of the agreement, resolves its target file, computes that file's heading slugs
the way GitHub does, and fails if the anchor matches none of them — wired into
`tests/verify-all.sh` (both the gate and its selftest). `bash tests/verify-all.sh` passes clean.
