# CLAUDE.md

Instructions for Claude sessions working **on** this repo (building Arc). This file is
not part of what Arc ships — the plugin's own artifacts (`.claude-plugin/`, `skills/`,
`hooks/`, `agents/`, `templates/`) are the product; this file governs how we work on it.

## Start here

Read [docs/product-architecture/README.md](docs/product-architecture/README.md) first,
every cold start. It is the authority on what Arc is made of — its six pieces, its
mechanisms, the artifacts that carry them, and the state each is in.

**Not `ROADMAP.md`** — last updated 2026-08-21, and it does not know arc 04 exists.
[#175](https://github.com/Calyx-Engineering/arc/issues/175) decides whether it is maintained or retired.

**Execution mode is manual** — files change; nothing is committed, pushed or merged unless
asked. It changes only when `HANDOFF.md`'s *Execution mode* row says autonomous, and that row
is read, never remembered — `hooks/mode-guard` reads it before every commit, push, PR and merge,
and denies in manual. **You may set that row to manual and never to autonomous**
(`skills/autonomy-set`).

## Working with David

These matter more than any finding in the documents.

**How long a reply may be is not here.** It is [the operating agreement](.claude/arc/camp/operating-agreement.md)'s
section 1, *Response verbosity*, so that it travels to every repository Arc is installed in.

| | |
|---|---|
| **Edit in place, never rewrite a file** | The diff is his review surface. A rewrite loses his in-progress comments |
| **Wording fixes go in immediately** | Structural changes are discussed first. Never stop to ask about word choice |
| **Verify before asserting** | Several documented beliefs have been disproved by direct test |
| **When he says you did something, re-read what you sent** | Do not reason about why he might have perceived it |
| **Cite TimeScope by mechanism, never by name** | He does not remember its details. Say what it is and how it works in the same breath |
| **He is right about his own domain** | On EE substance, when he says an analysis is wrong it is wrong. Ask what was missed |
| **Watch for saturation** | He is a reliable judge of a degrading context. Hand off rather than push through |

### Rejected, so they are not re-proposed

| Rejected | Why |
|---|---|
| Emoji for t-shirt sizes | No equivalent exists. Use the SVGs in `assets/` |
| Five-level priority scale | Three only — high, medium, low |
| Red as an effort colour | Reserved; orange/amber/blue instead |

## What Arc is

A Claude Code plugin for AI-driven engineering delivery. Full pitch in [README.md](README.md);
what it is made of, in [the product definition](docs/product-architecture/README.md).

**Arc holds the cross-plugin architecture** for the three-plugin line — Lodestar, Arc, Bench —
because the mechanisms that regenerate that architecture are Arc's.

## Capturing a gap in the product

When Arc should do something and does not, **document the mechanism, never the artifact.**
Which file carries a capability is decided when it gets built, not when the gap is noticed.

**The routing table is [the product definition](docs/product-architecture/README.md)'s** —
including what is *not* a definition change. **Exception: a capability that is already a single
skill uses that skill as its spec** — m11, m18 and m38 do.

## Vocabulary

**Never write a bare number.** `m17`, not "row 17"; `K2`, not "tier 2". Issue numbers, mechanism
numbers and pass numbers appear in the same sentences. The three ladders — mechanisms m09–m47,
knowledge tiers K1–K4, delegation tiers T0-Inline · T1-Squad · T2-Wave — are defined in
[the product definition](docs/product-architecture/README.md).

**Camp's five obligations are named, never numbered.** *The intent check · status and flow ·
decomposition · the nudge · the report.* Cite the section (`m43 §3.1`); say the name.

## Repo conventions

- **Documented is not built.** Skills, hooks, templates and tools exist and `v0.1.0` is
  released, but most of the mechanism table is still ⚪. Don't assume runtime behaviour
  described in `docs/` is built — check before citing it as current.
- **Markdown:** `.markdownlint.json` governs — long lines OK (MD013 off), inline HTML OK
  (MD033 off), duplicate headings OK across sibling sections only (MD024 siblings_only).
- **Diagrams:** prefer Mermaid over prose when a flow or relationship is easier shown
  than described (David's preference).

## Mirrored files — edit both copies

`04-arc-execution-and-roles.md` exists **identically** in
[lodestar](https://github.com/Calyx-Engineering/lodestar/blob/main/docs/04-arc-execution-and-roles.md)
and [arc](https://github.com/Calyx-Engineering/arc/blob/main/docs/suite-architecture/04-arc-execution-and-roles.md).

Mirrored files live in `docs/suite-architecture/` — a document that must exist in two repos
is about the boundary between them, which is that folder's subject.

**A change to one must be made to the other in the same session.** The design defines
Star and the arc-spine in relation to each other; each repo needs the whole picture.
Split it only when the design converges.

## Branching

Trunk-based. `main` stays deployable and coherent at every commit. **Everything happens on a
branch.**

| | |
|---|---|
| **Arc branches** — `arc/NN-short-slug` | A planned, multi-session push toward a numbered milestone. Merges to `main` only when that milestone is deployable or dogfoodable |
| **Work branches** | One unit of work off an arc branch. `arc/03-camp-issue-78-work-nav`, `arc/03-camp-pr115-transcript-staleness` |
| **Topic branches** | Smaller or exploratory, or outside an arc. Short-lived, no number |

No permanent `develop` branch. Revisit when Arc has external consumers.

**The naming rules and their mechanics are [`skills/issue-write`](skills/issue-write/SKILL.md)'s**
— the two forms, the mandatory number, `tools/new-direct-pr.sh`, and why a branch is never renamed
once its PR is open.

## Soak — before a plugin change is pushed

A self-improvement or mechanism change must **run against real work** before it leaves
the machine. Committed is not the same as exercised.

- Changes made mid-stretch soak on the rest of that issue.
- Changes made at PR time soak on the **next** work stretch.
- The soak record lives in **this repo's** `arc-log`, appended by whichever repo
  exercised the change — never in the consuming repo, which loses cross-repo soaks.

**Unsoaked** = a commit here with no soak line from any repo.

## Safe hook editing

A bad hook fires on every tool call in every repo and can break the session needed to fix it.
**The goal is that a mistake is survivable.** David does not audit bash — he checks that you
tested.

| | |
|---|---|
| **Say the kill switch in chat before proposing any hook change** | `bash tools/hooks-off.sh <hook> 30` — per hook, this repository only, expiring. A README line is a rule with no trigger |
| **Paste real `tools/verify-hook.sh` output before asking for approval** | Pass case, deny case, malformed case |
| **One hook per commit** | Verify output in the commit body, so `git revert` is surgical |
| **Never edited autonomously** | `settings.json` outside the plugin's hooks block, the verify script, the hook template, any `SessionStart` hook |

Hooks **fail open** — on unexpected failure, exit 0; deny only the specific condition. Write from
the skeleton so the kill switch cannot be omitted.

**`tests/verify-all.sh` runs every gate this repo has.** `--list` prints what it cannot cover:
no hook fires in a live session here and no skill is invoked, so a green run is not a claim
about either.

Full reasoning in [m10](docs/product-architecture/mechanisms/m10-branch-guard.md).
