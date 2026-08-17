# Arc

**Get the work done, in order, with a record — and put the right agent on it.**

A Claude Code plugin for engineering delivery. Arc owns the unit of work an engineer
actually runs: kickoff to merge, with checkpoints, a record that survives the session,
and the agents that execute it.

**Status: nothing is built.** This repo holds the architecture and mechanism specs. The
plugin skeleton does not exist yet.

---

## What Arc does

| Group | What it covers |
|---|---|
| **Workflow** | Kickoff and scope gate · branch and worktree guard · issue writing · issue linking · write-back verification · commit rhythm |
| **Record** | The K1–K4 knowledge ladder · context handoff · record routing · `arc-log` and `dev-log` upkeep · engineering reports |
| **Planning** | Arc decomposition and checkpoints · arc-tree · configuration management · test obligation capture · verification campaigns |
| **Agents** | Agent roster · T0-Inline / T1-Squad / T2-Wave delegation · worktree waves · human gate · the agent wiki |
| **Self-improve** | Transcript mining · the self-improvement loop · session preservation · the plugin retrospective |

Twenty-six mechanisms. Eleven already run in TimeScope or ROADZ and need porting; the
rest are specified but unbuilt.

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
that maintain it, the Self-improve group, are Arc's.

Arc calls Bench when a task needs engineering depth, and exchanges data with Lodestar:
Lodestar says what must be proven, Arc reports what actually was.

---

## Where things are

| Path | What |
|---|---|
| [docs/product-architecture/](docs/product-architecture/) | The cross-plugin architecture. Start with `HANDOFF.md`, then `product-plan.md` |
| [docs/product-architecture/mechanisms/](docs/product-architecture/mechanisms/) | Eleven mechanism specs |
| [docs/product-architecture/friction-log.md](docs/product-architecture/friction-log.md) | The evidence — eight frictions from four weeks of hardware work, with verbatim quotes |
| [docs/reference-timescope/](docs/reference-timescope/) | TimeScope's working files — source material for extraction, do not edit |
| [docs/reference-roadz/](docs/reference-roadz/) | ROADZ's `issue-writing` and `engineering-report` skills — same |
| [docs/04-arc-execution-and-roles.md](docs/04-arc-execution-and-roles.md) | The three-role workflow. **Mirrored with Lodestar — edit both copies** |
