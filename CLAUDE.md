# CLAUDE.md

Instructions for Claude sessions working **on** this repo (building Arc). This file is
not part of what Arc ships — the plugin's own artifacts (`.claude-plugin/`, `skills/`,
hooks, commands, once they exist) are the product; this file governs how we work on it.

## Start here

Read `docs/product-architecture/HANDOFF.md` first, every cold start — once the
architecture lands here. Until then it is in
[lodestar](https://github.com/Calyx-Engineering/lodestar/tree/main/docs/product-architecture).

Don't re-litigate anything marked decided — flag it to David instead of assuming it is
still open.

## What Arc is

One-line: a Claude Code plugin for engineering delivery — the unit of work from kickoff
to merge, the record that survives it, and the agents that execute it. Full pitch in
[README.md](README.md).

**Arc holds the cross-plugin architecture** for the three-plugin line (Lodestar, Arc,
Bench). It lives here because the Self-improve group — the mechanisms that regenerate
that architecture — are Arc's.

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
