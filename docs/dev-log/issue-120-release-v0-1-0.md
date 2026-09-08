# Issue #120 — release `v0.1.0`

> Dev-log, not a spec. Started at plan time, finalised as a retrospective at PR time.

**Issue:** [#120](https://github.com/Calyx-Engineering/arc/issues/120)  ·  **PR:** —

## Problem

**Arc has never been released**, so nothing it ships has ever run. Ship `v0.1.0` — the artifacts,
the documented process, and install instructions someone else can follow.

Gated by [#119](https://github.com/Calyx-Engineering/arc/issues/119), which found six findings, and
by [#122](https://github.com/Calyx-Engineering/arc/issues/122), the blocking one. **Both are
merged.**

## Intent and north star

### Pass 1 — from the issue body alone

| | |
|---|---|
| **What this is really for** | Not tagging a commit. **A release is the only thing that makes any of this executable** — no hook has fired and no skill has been invoked in three arcs, and the issue's own *What the release unblocks* table is the point rather than a footnote |
| **North star (pass 1)** | Someone who is not us installs Arc from a written instruction and it works — and the second release is cut by executing a document rather than by remembering this one |

### Pass 2 — after reading the plugin and marketplace references, `plugin.json`, and the repo's own state

**Three things changed. The first is a missing artifact, and without it neither install route works.**

| | |
|---|---|
| **There is no `.claude-plugin/marketplace.json`, and both routes need one** | A plugin is installed *from a marketplace*, and a marketplace is a `marketplace.json` listing plugins and their sources. The local route is `/plugin marketplace add <path>` — **also a marketplace**, just a local one. The issue's two routes are two *sources for the same file*, not two mechanisms. Verified against the reference, not assumed |
| **The default-branch flip is a live hazard for anyone installing today** | [m42](../product-architecture/mechanisms/m42-default-branch-flip.md) points this repo's default branch at `arc/03-camp`. A marketplace added by `owner/repo` shorthand clones the **default** branch — so an install right now gets the arc branch, not `main`. **Pinning `ref` in the plugin source is what makes the release reproducible** regardless of where the default happens to point |
| **`plugin.json` is already correct, and the review's pass 3 could not confirm it** | Only `name` is required; `skills/`, `commands/` and `hooks/hooks.json` are auto-discovered at the plugin root, which is exactly this layout. Checked against the reference this time — [#119](https://github.com/Calyx-Engineering/arc/issues/119) recorded the manifest as *unverifiable without an install*, and half of that is now closed by reading the schema rather than by installing |

**And one thing that does not change: the repository is private.** Installing works through the
user's existing git credentials, so the instructions must say that rather than reading as though
anyone can add the marketplace.

**North star.** `docs/release/release-process.md` is executed to cut the second release, the
README's two routes both work for someone who has never seen this repo, and **a release is pinned
to a tag** rather than to whatever branch the repo's default currently points at.

| | |
|---|---|
| **What makes it durable** | It survives the default-branch flip being in force or restored, because the source names a `ref`. It survives the next release, because the process document is written to be run rather than read. It survives this repo being private, because the instructions say what that requires |
| **Out of scope** | **Installing it here.** The issue says so, and `CLAUDE.md` ties deleting `.claude/skills/` to that install — so this issue must state the condition rather than act on it. Also out: the five remaining review findings, [#123](https://github.com/Calyx-Engineering/arc/issues/123)–[#126](https://github.com/Calyx-Engineering/arc/issues/126) |

### Intent check

**Agreed.** Step 25 / wave 6.5, the arc's last step, in the milestone, and every gate it named is
merged. **No new behaviour** — the constraint the issue sets, and `marketplace.json` is a
distribution artifact rather than a capability.

## The plan

| # | | |
|---|---|---|
| 1 | `.claude-plugin/marketplace.json` | One plugin, `source` pinned to the tag. The repo is both the marketplace and the plugin |
| 2 | `docs/release/release-process.md` | What a release consists of, what is checked, how the version is decided, what a consumer does. **Two mermaid diagrams** — clean review to installable release, and the two install routes side by side |
| 3 | `README.md` install section | **Local first**, because fix-and-reinstall is what makes a defect cheap. Both routes, and what the private repo requires |
| 4 | `CLAUDE.md` | The local-copy deletion condition stated explicitly — releasing is not installing |
| 5 | Cut and tag | `bash tools/verify-all.sh` first. **Outward-facing: retry once, then hand it over** |

## Retrospective

*Written at PR time.*
