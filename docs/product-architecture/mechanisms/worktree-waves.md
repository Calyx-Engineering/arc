# Mechanism — Worktree Waves

**Status:** partial — proven in software; whether guided work ever uses it is open.
**Home:** Arc — Campaign.
**Src:** ⚙️ inherited.
**Covers:** row 27.

---

## What it is

**Parallel work without collisions.** A planner partitions issues into **disjoint-file
tracks**; one builder works each track in its own git worktree; sub-branch PRs merge into the
integration branch in a planned order.

**Disjointness is the go/no-go.** Overlapping files mean sequential work — there is no
partial version of this rule.

```text
develop → arc/<slug> → feature/issue-<N>-<slug> → feature/issue-<N><letter>
```

Track branches take a letter index next to the issue number in merge order — the
differentiator survives truncated branch lists, and git refs cannot nest under an existing
branch name, so a `<branch>/<track>` form is invalid anyway.

---

## Why it is Campaign, not Delegation

Partitioning is a **planning** decision at arc scale: which issues can run at once, and in
what order their merges land. Delegation then executes it by putting a builder on each track.

Delegation's scale is one task, handed to one worker. Waves are the arc deciding what the
tasks *are*.

---

## What is not decided

**Whether guided work uses waves at all.** Hardware work is mostly serial, and its issues
are discovered rather than planned — which makes partitioning something you cannot do up
front. The autonomy switch may simply turn this off.

**How disjointness is established for hardware.** In software it is a file-set intersection.
CAD files are large binaries with no meaningful diff, and two issues touching the same
schematic collide totally. The check may be trivial — same file means sequential — or the
concept may not transfer.

**Who partitions.** TimeScope uses a planner agent. If `agents/camp` holds arc shape, it may
be better placed, since it already knows what spawned what.

---

## Related

- [agent-roster](agent-roster.md) — T2-Wave is the dispatch tier this executes
- [arc-decomposition](arc-decomposition.md) — decides the chunks this partitions
- TimeScope `agent-process-foundation.md` §4 and §7 — the source
