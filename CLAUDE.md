# CLAUDE.md

Instructions for Claude sessions working **on** this repo (building Arc). This file is
not part of what Arc ships — the plugin's own artifacts (`.claude-plugin/`, `skills/`,
hooks, commands, once they exist) are the product; this file governs how we work on it.

## Start here

Read [docs/product-architecture/README.md](docs/product-architecture/README.md) first,
every cold start. It is the authority on what Arc is made of — its six pieces, its
mechanisms, the artifacts that carry them, and the state each is in.

Then [ROADMAP.md](ROADMAP.md) for what is being built now and in what order.

## Working with David

These matter more than any finding in the documents.

| | |
|---|---|
| **Short chat responses** | He reads slowly and deliberately. Lead with the answer; he pulls for detail. See `.claude/skills/chat-response/` |
| **Never commit unasked** | He reviews by diff in VS Code's source-control graph. An unrequested commit destroys that surface |
| **Edit in place, do not paste into chat** | Fixes go into the file; the diff is the review surface. Rewriting a whole file loses his in-progress review comments — edit, never rewrite |
| **No development narrative** | Never "an earlier draft said…" or "you corrected me…". State the current conclusion. Applies to documents *and* chat |
| **Wording fixes go in immediately** | Discuss structural changes first, then apply; never stop to ask about word choice |
| **Verify before asserting** | Several documented beliefs have been disproved by direct test |
| **Cite TimeScope by mechanism, never by name** | He does not remember its details. Say what it is and how it works in the same breath |
| **He is right about his own domain** | On EE substance, when he says an analysis is wrong, it is wrong. Do not re-litigate — ask what was missed |
| **Watch for saturation** | He will say when a context is degrading. He is a reliable judge of it; hand off rather than push through |
| **Number discussion topics** | A reply covering several topics labels each D1, D2… so he can answer by number instead of restating |
| **Do not dig without an exit** | Escalating questions with no relief valve is the friction m41 exists for. Offer to back out to the critical point |

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

1. Write a mechanism spec in `docs/product-architecture/mechanisms/` — the friction, a
   verbatim quote if there is one, what should have happened, and the trigger. Mark it
   `partial` and name what is undesigned. Thin is correct at capture time.
2. Add the row to the product definition's mechanism table with ⚪ status and a spec link.
   New mechanisms take the next free identifier from the suite registry.
3. File an issue, so it is tracked as work rather than only described.

**Exception: when the capability is already a single skill, that skill is its own spec.**
m11, m18 and m38 link to their `SKILL.md`, not to
a `mechanisms/` file — a separate spec would paraphrase the skill and the two would drift.

Full routing table — including what is *not* a definition change — in the product
definition's "Capturing a gap" section.

## Vocabulary — three ladders, deliberately distinct

A bare number is never ambiguous. Never write "tier 2" alone.

| Ladder | Values | Measures |
|---|---|---|
| **Mechanisms** | m09–m41 | Which capability. Not a ladder — an identifier, zero-padded to two digits |
| **Knowledge tiers** | K1–K4 | Depth of recorded knowledge |
| **Delegation tiers** | T0-Inline · T1-Squad · T2-Wave | How work is dispatched to agents |
| **Star authority ladder** | Agreed · Derived · Escalate | How much authority Star answers with (Lodestar's) |

**Never write a bare mechanism number.** `m17`, not "row 17" — issue numbers, mechanism
numbers and pass numbers all appear in the same sentences. Spec filenames carry the same
identifier: `mechanisms/m17-k1-upkeep.md`.

Concise usage is the bare token — "that belongs in K2", "doing T1 delegation now".
Descriptive pairs it with the name — "T1-Squad level delegation".

## Repo conventions

- **Docs, not code, for now.** Nothing functional exists yet. Don't assume runtime
  behavior described in `docs/` is built — check before citing it as current.
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
- **Topic branches** — anything smaller or exploratory. Short-lived, merge back quickly.
- No permanent `develop` branch. Revisit when Arc has external consumers, or when
  commits must leave this machine before they have been exercised.

## Soak — before a plugin change is pushed

A self-improvement or mechanism change must **run against real work** before it leaves
the machine. Committed is not the same as exercised.

- Changes made mid-stretch soak on the rest of that issue.
- Changes made at PR time soak on the **next** work stretch.
- The soak record lives in **this repo's** `arc-log`, appended by whichever repo
  exercised the change — never in the consuming repo, which loses cross-repo soaks.

**Unsoaked** = a commit here with no soak line from any repo.

## Safe hook editing

Arc ships hooks. A bad hook registration fires on every tool call in every repo and can
break the session needed to fix it.

- Every hook starts with `[ -f "$HOME/.claude/HOOKS_OFF" ] && exit 0`. **Say this in
  chat before proposing any hook change.**
- Hooks **fail open** — on unexpected failure, exit 0. Deny only the specific condition.
- **Run `tools/verify-hook.sh` and paste the real output** before asking for approval.
- One hook per commit, verify output in the commit body.
- **Never edited autonomously:** `settings.json` outside the plugin's hooks block, the
  verify script, the hook template, any `SessionStart` hook.
