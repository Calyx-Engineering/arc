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

## Rejected approaches

## Retrospective
