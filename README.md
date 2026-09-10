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

**Status: under construction.** The architecture and mechanism specs are complete; the
plugin skeleton, the hook harness, and the branch guard are the first working parts.
[ROADMAP.md](ROADMAP.md) says what lands next.

---

## Installing

**Two routes, and both add a marketplace.** They differ only in where the marketplace comes from.
Full process — versioning, what a release consists of, what gates one — in
[`docs/release/release-process.md`](docs/release/release-process.md).

> **The repository is private.** Both routes use your existing git credentials. Run
> `gh auth setup-git` once so Claude Code can clone without prompting.

### Local — a clone on disk

**Documented first because it is the one you use while changing Arc.** Edit, reinstall, retry
— seconds instead of a release.

```bash
git clone https://github.com/Calyx-Engineering/arc.git
```

Then, in Claude Code:

```text
/plugin marketplace add /absolute/path/to/arc
/plugin install arc@calyx-engineering
```

The path is the repository root — the directory holding `.claude-plugin/`. After editing, run
`/plugin marketplace update` and reinstall to pick the change up.

### Marketplace — straight from GitHub

```text
/plugin marketplace add Calyx-Engineering/arc
/plugin install arc@calyx-engineering
```

`/plugin marketplace update` picks up a new version. **Claude Code only sees an update when
`version` in the manifest changes**, so a release that forgot to bump it installs the same thing.

### Either way

- If the install summary says `Run /reload-plugins to activate.`, run it.
- Skills arrive namespaced by the plugin — `arc:camp`, not `camp`.
- **Arc ships hooks that can deny a tool call.** Read the next section before you need it.

---

## Turning hooks off

Arc ships hooks that can deny a tool call. If one misbehaves, from any terminal in the
repository it is misbehaving in — PowerShell, cmd or bash, the same line in each:

```bash
bash tools/hooks-off.sh branch-guard 30
```

That hook goes inert immediately, and the command prints what it muted, where it wrote, when
the mute lapses, and how to end it early. `all` in place of a hook name mutes every one of
them; `status` reads back what is muted; `clear` restores.

| | |
|---|---|
| **It is a command, not a file** | It refuses a name that is not a hook and prints the ones that are. Placing a file by hand had four ways to go wrong and feedback on none |
| **Per hook** | Muting `branch-guard` to get past it leaves `mode-guard` guarding |
| **It expires** | Thirty minutes by default, eight hours at most. A forgotten mute heals itself |
| **This repository only** | The state lives in this repository's git directory, so no other repository on the machine is touched — and being inside `.git`, a muted repository cannot be committed |

Every hook opens with the line that consults it, and
[`tools/verify-hook.sh`](tools/verify-hook.sh) fails a hook that has lost it. The full
reasoning is in [m10](docs/product-architecture/mechanisms/m10-branch-guard.md#safe-hook-development).

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

Thirty-one mechanisms across twenty-four artifacts. Most already run as working practice
somewhere; the rest are specified but unbuilt.

Full definition in [docs/product-architecture/README.md](docs/product-architecture/README.md).

---

## The plugin line

Arc is one of three plugins built from a single retrospective:

| Plugin | One line |
|---|---|
| **[Lodestar](https://github.com/Calyx-Engineering/lodestar)** | Know what the product must be |
| **Arc** | Get the work done, in order, with a record |
| **[Bench](https://github.com/Calyx-Engineering/bench)** | Analyse at real engineering depth, and drive the instruments |

Arc calls Bench when a task needs engineering depth, and exchanges data with Lodestar:
Lodestar says what must be proven, Arc reports what actually was.

**The suite architecture lives in this repo** — how the three fit together, what each owns,
the build order, and mechanism numbering. It is here rather than in Lodestar because Arc's
self-improvement piece holds the mechanisms that regenerate it.
[docs/suite-architecture/](docs/suite-architecture/).

---

## Where things are

| Path | What |
|---|---|
| [docs/product-architecture/](docs/product-architecture/) | **What Arc is.** Start with its `README.md` |
| [docs/product-architecture/mechanisms/](docs/product-architecture/mechanisms/) | Mechanism specs |
| [docs/suite-architecture/](docs/suite-architecture/) | **What the three-plugin suite is.** Boundaries, build order, mechanism numbering. Mirrored files live here |
| [docs/retrospectives/2026-08-plugin-line/friction-transcript-log.md](docs/retrospectives/2026-08-plugin-line/friction-transcript-log.md) | The evidence — eight frictions from four weeks of hardware work, with verbatim quotes |
| [docs/reference-timescope/](docs/reference-timescope/) | TimeScope's working files — source material for extraction, do not edit |
| [docs/reference-roadz/](docs/reference-roadz/) | ROADZ's `issue-writing` and `engineering-report` skills — same |
| [hooks/](hooks/) | The hooks, and the `TEMPLATE` every new one starts from |
| [tools/verify-hook.sh](tools/verify-hook.sh) | The gate — run it before any hook is registered |
