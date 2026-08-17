# Mechanism — Briefs Down, Packets Up

**Status:** partial — the pattern is proven; the packet formats Arc ships are not defined.
**Home:** Arc — Delegation.
**Src:** ⚙️ inherited.
**Covers:** row 26.

---

## What it is

**The orchestrator stays lean.** A subagent receives a small, self-contained brief and
returns a bounded packet — never its raw working context.

| Direction | Contains |
|---|---|
| **Brief, down** | Goal · done-criteria · the files in scope · constraints · "read the wiki index first" |
| **Packet, up** | Conclusions with `file:line` references, bounded length. Never transcripts or file dumps |

**The litmus test:** if the main thread is pasting raw tool output into its own analysis,
that work belonged in an agent.

**Continue an agent rather than respawning it** — context stays intact, no cold start.

---

## Why it is separate from the roster

The roster says *who* does the work. This says *what crosses the boundary*, and it is the
part that determines whether delegation actually saves context or merely moves it.

An agent that returns everything it read has cost more than it saved.

---

## What is not decided

**Packet formats per archetype.** TimeScope's are tuned to its agents — a scout's packet is
capped at 30 lines. Arc's roster may differ, and every archetype needs its own shape.

**Whether formats are enforced or conventional.** Today they are prose instructions in an
agent file. A returned packet that ignores its format fails silently — the same class of
defect the friction log's §3.7 names.

**Brief assembly.** Something has to build a self-contained brief without pulling the
context it is trying to avoid. That is judgment, and it sits in `skills/delegate`.

**How this composes with the wiki.** The brief says "read the wiki index first," which
assumes a healthy wiki. If it is stale the brief is worse than useless — it points the agent
at wrong facts confidently.

---

## Related

- [agent-roster](agent-roster.md) — who receives the briefs
- [agent-wiki](agent-wiki.md) — what every brief points at
- TimeScope `agent-process-foundation.md` §3 — the source
