# CLAUDE.md

Instructions for Claude sessions working **on** this repo (building Arc). This file is
not part of what Arc ships — the plugin's own artifacts (`.claude-plugin/`, `skills/`,
hooks, commands, once they exist) are the product; this file governs how we work on it.

## Start here

Read [docs/product-architecture/README.md](docs/product-architecture/README.md) first,
every cold start. It is the authority on what Arc is made of — its six pieces, its
mechanisms, the artifacts that carry them, and the state each is in.

Then [docs/product-architecture/HANDOFF.md](docs/product-architecture/HANDOFF.md) for how
to work with David and what was already decided. Don't re-litigate anything marked decided
— flag it instead of assuming it is still open.

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
   New mechanisms take numbers from 38 up.
3. File an issue, so it is tracked as work rather than only described.

**Exception: when the capability is already a single skill, that skill is its own spec.**
`issue-writing`, `engineering-report` and `chat-response` link to their `SKILL.md`, not to
a `mechanisms/` file — a separate spec would paraphrase the skill and the two would drift.

Full routing table — including what is *not* a definition change — in the product
definition's "Capturing a gap" section.

## Vocabulary — three ladders, deliberately distinct

A bare number is never ambiguous. Never write "tier 2" alone.

| Ladder | Values | Measures |
|---|---|---|
| **Knowledge tiers** | K1–K4 | Depth of recorded knowledge |
| **Delegation tiers** | T0-Inline · T1-Squad · T2-Wave | How work is dispatched to agents |
| **Star authority ladder** | Agreed · Derived · Escalate | How much authority Star answers with (Lodestar's) |

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

`docs/04-arc-execution-and-roles.md` exists **identically** in
[lodestar](https://github.com/Calyx-Engineering/lodestar/blob/main/docs/04-arc-execution-and-roles.md)
and [arc](https://github.com/Calyx-Engineering/arc/blob/main/docs/04-arc-execution-and-roles.md).

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
