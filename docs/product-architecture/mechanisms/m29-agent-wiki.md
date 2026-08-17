# Mechanism — Agent Wiki

**Status:** partial — a published plugin exists to fork from; what forking means is not
decided.
**Home:** Arc — Delegation.
**Src:** ⚙️ inherited.
**Covers:** m29.

---

## What it is

**Exploration cost compounds downward.** Distilled operational knowledge every agent reads
before exploring, so the same repo facts are not re-derived every session.

Working in both repos surveyed during the retrospective — ROADZ has 14 pages, TimeScope 6.
It is the most consistently successful mechanism in either.

**Why it works, in the three-part rule's terms:** a wiki-first rule as trigger, six fixed
pages as template, a PR-time lint as enforcement. All three present, which is exactly what
the failing mechanisms lack.

### The rules that keep it healthy

| | |
|---|---|
| ~200-line budget per page | **Prune before appending** |
| A ≤20-word human blurb tops each page | So a human can route without reading |
| Seeded once by a scout sweep | Then updated after sweeps and at PR time |
| Linted at PR time | Index rows resolve, budgets hold |
| Wrong-turn diagnoses stay on record | They prevent repeat misdiagnoses |
| Provenance is git history | No separate activity log |

The update question is *"what would a future agent otherwise re-derive?"*

---

## The fork

A published plugin already implements this — [agent-wiki](https://github.com/omnilertlabs/agent-wiki)
— with `wiki-init`, `wiki-ingest`, `wiki-query`, `wiki-lint`, `wiki-compact` and
`wiki-migrate`.

**That makes m29 different from the rest of Delegation.** The others are files to copy
from a reference document. This one is a decision about an external dependency.

| Option | For | Against |
|---|---|---|
| **Depend on it** | No maintenance. Upstream improvements arrive free | Arc's behavior depends on someone else's release cadence |
| **Fork it** | Arc controls the page set and the lint rules | Divergence becomes permanent maintenance |
| **Reimplement** | Fits Arc's conventions exactly | Rebuilding something that works |

**Leaning fork**, which is what the original plan recorded — but the reasoning behind that
was never written down, and the published plugin has moved since.

---

## What is not decided

**Which pages Arc ships.** TimeScope's six are software-shaped: `arch`, `contracts`, `ops`,
`testing`, `gotchas`, plus the index. ROADZ grew fourteen, and they are hardware subjects —
`interface-board`, `speaker-power`, `rp2040-signals`. The page set may be per-repo rather
than fixed, which changes what the template is.

**The seam with K2.** The wiki is K2 by depth but permanent by lifetime, which is what
separates it from the rest of K2. The graduation path — arc-scoped analysis becomes a
durable repo fact — is specified in
[hardware-record-structure](m16-hardware-record-structure.md), but nothing enforces the sweep.

**Whether the lint is Arc's or the plugin's.** If Arc depends on the published plugin, the
lint arrives with it and Arc's PR-time enforcement has to call it rather than implement it.

---

## Related

- [agent-roster](m25-agent-roster.md) — the agents that read it
- [briefs-and-packets](m26-briefs-and-packets.md) — every brief points at the index
- [hardware-record-structure](m16-hardware-record-structure.md) — the graduation path into it
- [agent-wiki](https://github.com/omnilertlabs/agent-wiki) — the published plugin
