# Issue #48 — verify every shipping skill matches its local copy before release

> Decision log, not a spec. Started at plan time, finalised as a retrospective at PR time.

**Issue:** [#48](https://github.com/Calyx-Engineering/arc/issues/48) · [#68](https://github.com/Calyx-Engineering/arc/issues/68)  ·  **PR:** —

## Problem

`.claude/skills/` holds copies of shipping skills so they are live in a repo where Arc is not
installed. `tools/sync-local-skills.sh --check` compares them — but only against a hardcoded
`SKILLS` list. A skill absent from that list is invisible to the check, so the check reports
success while a copy does not exist. That is happening in the tree right now:

```
$ ls skills/ | wc -l          # 11
$ ls .claude/skills/ | wc -l  # 11
$ bash tools/sync-local-skills.sh --check
local copies are current      # exit 0 — and skills/engineering-report has no copy
```

The two trees diverge in both directions and the check sees neither direction.

## Intent and north star

### Pass 1 — from the issue body alone

| | |
|---|---|
| **What this issue is really for** | The check exists and is not trustworthy. Making the two trees agree once is worthless; making the check say so without being edited first is the work |
| **North star (pass 1)** | `--check` passes clean on a clean tree with no manual sync, and every directory in either tree is accounted for |

### Pass 2 — after reading [#68](https://github.com/Calyx-Engineering/arc/issues/68), [#27](https://github.com/Calyx-Engineering/arc/issues/27), the script, both trees, and the product definition's registry

**Four things changed.**

| | |
|---|---|
| **The Windows defect is already fixed** | The issue's *Known defect* section is stale. Arc-log §10.3.1 records the cause and the fix — `.gitattributes` gained `*.md text eol=lf` plus a renormalize, during [#55](https://github.com/Calyx-Engineering/arc/issues/55). Verified by running it: `local copies are current`, exit 0, clean tree. Three of that section's four boxes are already true |
| **[#68](https://github.com/Calyx-Engineering/arc/issues/68) is the durable form of [#48](https://github.com/Calyx-Engineering/arc/issues/48)'s fourth box** | [#48](https://github.com/Calyx-Engineering/arc/issues/48) asks that `SKILLS` "covers the skills this arc added" — which re-breaks the moment the next skill lands. [#68](https://github.com/Calyx-Engineering/arc/issues/68) says derive the list instead. Same milestone, no step number in the execution order, and doing [#48](https://github.com/Calyx-Engineering/arc/issues/48) without it means doing it again |
| **The divergence is exactly two directories, one in each direction** | `skills/engineering-report` ships with no copy. `.claude/skills/plugin-retrospective` is a copy with no source |
| **`plugin-retrospective` is not repo-local, whatever [#48](https://github.com/Calyx-Engineering/arc/issues/48) says** | [#48](https://github.com/Calyx-Engineering/arc/issues/48) item 3 calls it "a repo-local skill by intent". The ROADMAP and the registry's artifact table both declare it at `skills/plugin-retrospective`; only m33's registry row and the file's actual location say otherwise. **Two of three declarations say it ships** — the tree is what is wrong, not the design |

**North star.** After this merges, `tools/sync-local-skills.sh --check` is a check you can
trust without reading the script: it derives what to compare from the trees themselves, so a
skill added or deleted tomorrow by someone who never read this issue is caught without editing
anything. Both directions are covered — a shipping skill with no copy, and a copy whose source
is gone. And every skill in `skills/` is reachable from the product definition by its shipping
path, with a mechanism number against it.

| | |
|---|---|
| **What makes it durable** | It survives the next skill being added without the script being touched. It survives a CRLF checkout. It survives a genuinely repo-local skill appearing in `.claude/skills/` later, without a second hardcoded list to maintain |
| **Out of scope** | Redesigning the copy arrangement — it is deleted at first release ([#68](https://github.com/Calyx-Engineering/arc/issues/68)'s own constraint). Reconciling `skills/engineering-report` against the frozen `docs/reference-roadz/` copy. Sweeping registry rows this issue does not touch — that is [#105](https://github.com/Calyx-Engineering/arc/issues/105)'s, per arc-log §6.1.3 |

### Intent check

**Derived.** [#48](https://github.com/Calyx-Engineering/arc/issues/48) is step 21 in the
execution order, so its membership is settled. [#68](https://github.com/Calyx-Engineering/arc/issues/68)
is in the same milestone with no step number; admitting it changes nothing in *Why this arc
exists*, and [#48](https://github.com/Calyx-Engineering/arc/issues/48)'s fourth required box
cannot be satisfied durably without it. Both are closed by this PR.

## Plan

| | |
|---|---|
| 1 | **Move `plugin-retrospective` into `skills/`** — `git mv`, so history follows. The registry's artifact table and the ROADMAP already name that path |
| 2 | **Derive both lists in the script** — `skills/*/SKILL.md` and `commands/*.md`. `SKILLS` and `COMMANDS` are deleted, not extended |
| 3 | **Add the reverse check** — a `.claude/skills/` directory with no source in `skills/`. It fails when the copy carries the do-not-edit banner (a copy whose source was deleted) and reports without failing when it does not (a repo-local skill by intent) |
| 4 | **Add the registry check** — every skill in `skills/` appears in the product definition's artifact table with at least one `m<NN>`. This is [#48](https://github.com/Calyx-Engineering/arc/issues/48)'s fifth box made mechanical instead of asserted |
| 5 | **Sync**, which copies `engineering-report` and `plugin-retrospective` for the first time |
| 6 | **Repoint two registry rows** at `skills/` — m18, which links the frozen `docs/reference-roadz/` copy, and m33, which links `.claude/skills/` |

**No exception list.** A second hardcoded list is the defect [#68](https://github.com/Calyx-Engineering/arc/issues/68)
names, reintroduced one line lower. The banner is the marker instead — the sync writes it, so
nothing has to be kept in step by hand.

## Decisions & trade-offs

| | |
|---|---|
| **The banner is the marker, so there is no exception list** | [#48](https://github.com/Calyx-Engineering/arc/issues/48) items 2 and 3 both allow "or declared deliberate", which reads as a second list to maintain — the exact thing [#68](https://github.com/Calyx-Engineering/arc/issues/68) is about. The sync already writes a do-not-edit banner into every copy, so a `.claude/skills/` directory *with* the banner and no source is a deleted skill (fail) and one *without* it is repo-local (report). Nothing to keep in step by hand |
| **`plugin-retrospective` moved, rather than m33's row being pointed at `.claude/`** | Two of three declarations already said `skills/` — the ROADMAP and the registry's artifact table. Only m33's Spec link and the file's location disagreed, so the tree was the outlier |
| **The registry check lives in the sync script** | It is not syncing, and the script now does two jobs. There is no other runner, [#48](https://github.com/Calyx-Engineering/arc/issues/48)'s fifth box is otherwise satisfied by assertion, and both checks answer one question: is this skill accounted for. Worth naming as a seam if `tools/` ever grows a general checker |
| **Link re-basing, which the north star did not ask for** | **Derived.** The copies sit one directory deeper than their sources, so 28 links across 11 of 12 copies resolved to `.claude/docs/` and 404'd — in the tree that actually loads. A check that calls those copies current is the same untrustworthiness as one that exits 0 with no copy on disk, so it is inside the star rather than beside it |
| **`SYNC_ROOT`, one line, so the script is testable** | The alternative is a test that creates and deletes fixture directories inside the real `skills/` and `.claude/skills/`. An interrupted run then leaves residue in the trees being checked |

## Rejected approaches

| | |
|---|---|
| **Adding the two missing names to `SKILLS`** | What [#48](https://github.com/Calyx-Engineering/arc/issues/48) item 4 literally asks. It closes today's gap and re-opens on the next skill — which is how this one opened |
| **An `EXCEPT` list for skills not worth copying locally** | The old comment's stance — "not every shipped skill, only the ones that shape how work is done here". A second hardcoded list, one line below the one being deleted |
| **Testing by mutating the real trees** | How the four cases were first run by hand. Fine interactively, wrong committed: an interrupted run leaves `skills/ghost/` behind in the tree the check is meant to police |
| **Adding `tools/verify-sync-parity.sh` to the registry's artifact table** | No `tools/` script is in it — not `verify-hook.sh`, not `verify-tracker-body.sh`. Adding one alone would be the inconsistency, and the table having no home for `tools/` is [#105](https://github.com/Calyx-Engineering/arc/issues/105)'s to resolve. Named, not swept, per arc-log §6.1.3 |

## Retrospective

**The check was wrong in more ways than the issue described.** [#48](https://github.com/Calyx-Engineering/arc/issues/48)
named one failure and carried a *Known defect* section for a second that had already been
fixed. Running the check first, before reading further, is what separated the two — and found
a third the issue does not mention at all.

| What the old check reported clean | |
|---|---|
| `skills/engineering-report` had no copy | The [#68](https://github.com/Calyx-Engineering/arc/issues/68) defect, live in the tree |
| 28 links across 11 of 12 copies resolved to `.claude/docs/` | Never noticed, because the copies are read by Claude Code and not by a human following links |
| `plugin-retrospective` sat where the ROADMAP and the registry both said it did not | Invisible in both directions — no source to compare, no list entry to miss |

**The `--check` that exits 0 while something is broken is the shape to watch for.** Three
different mechanisms produced it here, and the arc-log's wave 5 review records the same shape
twice more — a rule contradicted by its own example, a structural check passing on a wrong
artifact. The fix each time is a test that fails when the check is removed, which is what
`tools/verify-sync-parity.sh` is for: nine cases, and four deliberate mutations of the script
each failing exactly the case meant to catch them.
