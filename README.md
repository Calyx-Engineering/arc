# Arc

**A Claude Code plugin for AI-driven engineering delivery.** Arc is an engineering
development workflow, refined against real projects rather than theory. As a
plugin it ships agents, skills, hooks, and scripts — not a skill or two, but the whole
workflow - tested and documented. It inherits from both software and hardware practice and
unifies the best of each, with enough configurability to fit the workflow to your project.

Its core discipline is git and issues: every change traceable, every tangential thought
captured as an issue, so the engineer can stay on task. Most work
is a quick fix done rigorously. When work is bigger than that — spanning days, spread
across many issues — it becomes an **arc**: one cohesive unit of work with its own branch+sub-branches,
its own record, and its own close.

Knowledge capture serves two readers. **The engineer** gets AI-assisted reports and
scratchpad analysis in markdown, so the reasoning behind a decision survives the session it
was made in. **The AI** gets a tiered record — high-level context loaded at the start of
every session, so a fresh chat is working in minutes instead of being re-briefed, with deep
detail on demand and a durable wiki that outlives the arc or issue that produced it.

Arc exists to solve the inconsistencies in AI-driven development and extinguish the
friction between human and AI.

**Status: nothing is built.** This repo holds the architecture and mechanism specs. The
plugin skeleton does not exist yet.

---

## What Arc does

| Piece | What it covers |
|---|---|
| **Workspace guard** | Branch and worktree guard · issue linking · commit rhythm · configuration management |
| **Authoring** | Issue writing · write-back verification · engineering reports · chat replies |
| **Campaign** | Kickoff and scope gate · decomposition and checkpoints · arc-tree · verification planning |
| **Knowledge** | The K1–K4 ladder · context handoff · record routing · `arc-log` and `dev-log` upkeep · test obligation capture |
| **Delegation** | Agent roster · T0-Inline / T1-Squad / T2-Wave · worktree waves · human gate · the agent wiki |
| **Self-improvement** | Transcript mining · the self-improvement loop · session preservation · the plugin retrospective |

Twenty-six mechanisms. Twelve already run as working practice; the rest are specified but
unbuilt.

Full definition in [docs/product-architecture/README.md](docs/product-architecture/README.md).

---

## The plugin line

Arc is one of three plugins built from a single retrospective:

| Plugin | One line |
|---|---|
| **[Lodestar](https://github.com/Calyx-Engineering/lodestar)** | Know what the product must be |
| **Arc** | Get the work done, in order, with a record |
| **[Bench](https://github.com/Calyx-Engineering/bench)** | Analyse at real engineering depth, and drive the instruments |

**Arc holds the cross-plugin architecture** — how the three fit together, what each
owns, and the build order. It lives here rather than in Lodestar because the mechanisms
that maintain it, Arc's self-improvement piece, are Arc's.

Arc calls Bench when a task needs engineering depth, and exchanges data with Lodestar:
Lodestar says what must be proven, Arc reports what actually was.

---

## Where things are

| Path | What |
|---|---|
| [docs/product-architecture/](docs/product-architecture/) | Arc's product definition. Start with its `README.md` |
| [docs/product-architecture/mechanisms/](docs/product-architecture/mechanisms/) | Eleven mechanism specs |
| [docs/product-architecture/friction-log.md](docs/product-architecture/friction-log.md) | The evidence — eight frictions from four weeks of hardware work, with verbatim quotes |
| [docs/reference-timescope/](docs/reference-timescope/) | TimeScope's working files — source material for extraction, do not edit |
| [docs/reference-roadz/](docs/reference-roadz/) | ROADZ's `issue-writing` and `engineering-report` skills — same |
| [docs/04-arc-execution-and-roles.md](docs/04-arc-execution-and-roles.md) | The three-role workflow. **Mirrored with Lodestar — edit both copies** |
