# CLAUDE.md

Instructions for Claude sessions working **on** this repo (building Arc). This file is
not part of what Arc ships — the plugin's own artifacts (`.claude-plugin/`, `skills/`,
`hooks/`, `agents/`, `templates/`) are the product; this file governs how we work on it.

## Start here

Read [docs/product-architecture/README.md](docs/product-architecture/README.md) first,
every cold start. It is the authority on what Arc is made of — its six pieces, its
mechanisms, the artifacts that carry them, and the state each is in.

Then [ROADMAP.md](ROADMAP.md) for what is being built now and in what order.

**Execution mode is manual** — files change; nothing is committed, pushed or merged unless
asked. It changes only when `HANDOFF.md`'s *Execution mode* row says autonomous, and that row
is read, never remembered (`skills/autonomy-set`).

## Working with David

These matter more than any finding in the documents.

| | |
|---|---|
| **He reads slowly and deliberately** | Length costs him more than it costs most readers. The rules that follow from it are `chat-response`'s |
| **Edit in place, do not paste into chat** | Fixes go into the file; the diff is the review surface. Rewriting a whole file loses his in-progress review comments — edit, never rewrite |
| **Wording fixes go in immediately** | Discuss structural changes first, then apply; never stop to ask about word choice |
| **Verify before asserting** | Several documented beliefs have been disproved by direct test |
| **When he says you did something, check what you sent** | Do not reason about why he might have perceived it. Re-read the actual output first. Explaining a report away is how a real error gets excused instead of fixed |
| **Cite TimeScope by mechanism, never by name** | He does not remember its details. Say what it is and how it works in the same breath |
| **He is right about his own domain** | On EE substance, when he says an analysis is wrong, it is wrong. Do not re-litigate — ask what was missed |
| **Watch for saturation** | He will say when a context is degrading. He is a reliable judge of it; hand off rather than push through |

### Rejected, so they are not re-proposed

| Rejected | Why |
|---|---|
| Emoji for t-shirt sizes | No equivalent exists. Use the SVGs in `assets/` |
| Five-level priority scale | Three only — high, medium, low |
| Red as an effort colour | Reserved; orange/amber/blue instead |
| `concerns/` as a folder name | Reads wrong to a human, and it is agent-facing |
| Concern-first folder structure | Subject is the folder, concern is a facet |
| A single deep-context document | Saturates a session by itself — hence the K1–K4 ladder |

## What Arc is

One-line: a Claude Code plugin for AI-driven engineering delivery — six pieces covering the
workspace work happens in, the issues and reports it produces, the knowledge that survives
it, and the agents that execute it. Full pitch in [README.md](README.md).

**Arc holds the cross-plugin architecture** for the three-plugin line (Lodestar, Arc,
Bench). It lives here because the self-improvement piece — the mechanisms that regenerate
that architecture — is Arc's.

## Capturing a gap in the product

When Arc should do something and does not, **document the mechanism, never the artifact.**
Which file carries a capability is decided when it gets built, not when the gap is noticed.

**The routing table is the product definition's** — its *Capturing a gap* section, including
what is *not* a definition change. Three steps: a `partial` spec in
`docs/product-architecture/mechanisms/`, a ⚪ row in the mechanism table, an issue.

**Exception: when the capability is already a single skill, that skill is its own spec.**
m11, m18 and m38 link to their `SKILL.md` — a separate spec would paraphrase the skill and the
two would drift.

## Vocabulary — three ladders, deliberately distinct

A bare number is never ambiguous. Never write "tier 2" alone.

| Ladder | Values | Measures |
|---|---|---|
| **Mechanisms** | m09–m47 | Which capability. Not a ladder — an identifier, zero-padded to two digits |
| **Knowledge tiers** | K1–K4 | Depth of recorded knowledge |
| **Delegation tiers** | T0-Inline · T1-Squad · T2-Wave | How work is dispatched to agents |
| **Star authority ladder** | Agreed · Derived · Escalate | How much authority Star answers with (Lodestar's) |

**Never write a bare mechanism number.** `m17`, not "row 17" — issue numbers, mechanism
numbers and pass numbers all appear in the same sentences. Spec filenames carry the same
identifier: `mechanisms/m17-k1-upkeep.md`.

Concise usage is the bare token — "that belongs in K2", "doing T1 delegation now".
Descriptive pairs it with the name — "T1-Squad level delegation".

**Camp's five obligations are named, never numbered.** *The intent check · status and flow ·
decomposition · the nudge · the report.* They are not a ladder — the numbers m43 §3 once
carried were an insertion order, which is why *"obligation 0"* named the one that ranks
first. Cite the section (`m43 §3.1`); say the name.

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

Trunk-based. `main` stays deployable and coherent at every commit.

- **Everything happens on a branch.** No direct commits to `main`.
- **Arc branches** (`arc/NN-short-slug`) — a planned, multi-session push toward a
  numbered milestone. Merges to `main` only when that milestone is actually
  deployable or dogfoodable.
- **Work branches** — one unit of work off an arc branch. Two forms, both carrying a number.
- **Topic branches** — anything smaller or exploratory, and anything outside an arc.
  Short-lived, merge back quickly. No number, because there is no unit to name.
- No permanent `develop` branch. Revisit when Arc has external consumers, or when
  commits must leave this machine before they have been exercised.

**Work branch names, and the mechanics that go with them, are
[`skills/issue-write`](skills/issue-write/SKILL.md)'s** — the two forms, the mandatory number,
`tools/new-direct-pr.sh`, and why a branch is never renamed once its PR is open. Reasoning in
[m46 §9](docs/product-architecture/mechanisms/m46-work-navigation.md#9-branch-naming).

```text
arc/03-camp-issue-78-work-nav
arc/03-camp-pr115-transcript-staleness
```

## Soak — before a plugin change is pushed

A self-improvement or mechanism change must **run against real work** before it leaves
the machine. Committed is not the same as exercised.

- Changes made mid-stretch soak on the rest of that issue.
- Changes made at PR time soak on the **next** work stretch.
- The soak record lives in **this repo's** `arc-log`, appended by whichever repo
  exercised the change — never in the consuming repo, which loses cross-repo soaks.

**Unsoaked** = a commit here with no soak line from any repo.

## Local skill copies — the deletion condition has been met

**Arc is installed here** — `~/.claude/plugins/cache/calyx-engineering/arc/0.1.0/`, 13 skills.
`.claude/skills/` also holds 13. **Every skill is in this repository's context twice**, which is
the duplication defect [#138](https://github.com/Calyx-Engineering/arc/issues/138) is about, at
thirteen times the scale.

This arrangement existed because Claude Code discovered only `.claude/skills/` here. It now
discovers the plugin. **The stated condition for deleting the copies was *this repository having
installed the released plugin*, and it has** — [#142](https://github.com/Calyx-Engineering/arc/issues/142)
does the deletion.

Until it lands:

| | |
|---|---|
| **The source is `skills/`** | That is what the plugin ships. Edit there, never in the copy |
| **Re-copy after editing** | `tools/sync-local-skills.sh` |
| **Check before a PR** | `tools/verify-all.sh`. On its own, `tools/sync-local-skills.sh --check` exits 1 if a copy is stale, if a shipping skill has no copy, if a copy's source was deleted, or if a skill is missing from the product definition's artifact table |
| **A skill that is genuinely repo-local** | Lives in `.claude/skills/` with no banner. The check names it and passes |
| **After changing the sync** | `tools/verify-sync-parity.sh` — nine cases against throwaway fixture trees |

After #142, `skills/` becomes purely the dev tree, exercised through the installed plugin rather
than through a copy of itself. Testing a change with the version of itself being changed is the
trap that avoids, and it is the same reasoning as the soak rule above.

## Safe hook editing

Arc ships hooks. A bad hook registration fires on every tool call in every repo and can
break the session needed to fix it.

**The goal is that a mistake is survivable, not that mistakes are prevented by review
skill.** David is not a hook author and does not audit bash — he checks that you tested.

- Every hook starts with `[ -f "$HOME/.claude/HOOKS_OFF" ] && exit 0`. **Say this in chat
  before proposing any hook change** — a README line is a rule with no trigger.
- Hooks **fail open** — on unexpected failure, exit 0. Deny only the specific condition.
  Write from a skeleton that already carries the kill switch and the wrapper, so neither
  can be omitted.
- **Run `tools/verify-hook.sh` and paste the real output** before asking for approval.
  Pass case, deny case, malformed case.
- One hook per commit, verify output in the commit body, so `git revert` is surgical.
- **Never edited autonomously:** `settings.json` outside the plugin's hooks block, the
  verify script, the hook template, any `SessionStart` hook.

**The gate is a script, not a hook.** A hook validating hook changes can be broken by the
change it is validating, and `HOOKS_OFF` would disable it along with everything else. A
script works with hooks off and produces output you can see.

**`tools/verify-all.sh` runs every gate in one command** — nine of them, one exit code, the
failing one named. It **fails on a hook with no case
directory**, so the rule above is enforced rather than remembered. `--list` prints what it
runs and, as importantly, what it cannot: no hook fires in a live session here and no skill is
invoked, so a green run is not a claim about either.

Full reasoning in [m10](docs/product-architecture/mechanisms/m10-branch-guard.md).
