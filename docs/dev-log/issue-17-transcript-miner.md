# Issue #17 — extract user corrections from past transcripts into mechanism candidates

> Dev-log, not a spec.

**Issue:** [#17](https://github.com/Calyx-Engineering/arc/issues/17)  ·  **PR:** [#139](https://github.com/Calyx-Engineering/arc/pull/139)

## Problem

A user's corrections are labeled data about where the tooling is wrong, and they sit unread on
disk. Nothing reads them, so the same friction recurs until it gets loud enough that someone
writes a skill by hand. `skills/plugin-retrospective` step 1 had no agent behind it.

## Intent and north star

| | |
|---|---|
| **What this issue is really for** | Turning three weeks of transcripts into ranked, quoted evidence without any of it entering the orchestrator's context |
| **North star** | A brief goes down, a bounded ranked packet comes up. Every cluster carries a verbatim quote and a locator that gets back to the moment |
| **What makes it durable** | It proposes and never writes. Diagnosis stays with the human, so a wrong cluster costs a paragraph rather than a mechanism |
| **Out of scope** | The knowledge filter. m30 stays `partial` — the friction filter is validated, the knowledge one is undesigned |

## Decisions & trade-offs

**Built friction-mode only, per m30's split.** The knowledge filter's open question — whether the
two filters can share extraction at all — is untouched.

**Exercised before it was registered.** The agent ran against 68 MB of the client repo's transcripts with its
brief passed inline, and returned 13 clusters. Three defects surfaced from that run and are fixed
here rather than being discovered later:

| Defect | Fix |
|---|---|
| Only the raw `~/.claude/projects/` store was read | Curated saves are read first, and their filenames — `<date>-<arc>-<issue>-<topic>.jsonl` — become the citation. `skills/handoff` already requires a repository to carry a *transcripts* note; the agent now reads it |
| Intensity was invisible to the filter | A second pass matches caps runs, profanity, repeated punctuation and exasperation tokens, ranked **above** phrasing hits when choosing a quote. The corpus's strongest signals matched pass A only by accident |
| Quotes could not be gone back to | Every quote carries source file and timestamp to the minute, plus one line of surrounding context per cluster. The friction log's own rule: a date alone lands the reader in a whole day's work |

**The proposed-mechanism column was almost dropped, and that was wrong.** The first draft forbade
the agent from naming a mechanism, reasoning from `plugin-retrospective` that diagnosis belongs to
the interview. m30's packet format carries `Proposed mechanism` and `Effort` columns and states
*"Both propose; the human decides."* The spec wins. The agent now proposes, marks it a proposal, and
writes `unclear — needs the interview` rather than guessing — which keeps the anchoring risk the
first draft was worried about without dropping the column.

**Model: opus, one agent.** m30 suggests mid for extraction and top for clustering, possibly two
agents. Deferred — clustering is the judgement, and splitting adds a handoff before there is
evidence the cost matters.

**No manifest registration.** Plugin components are auto-discovered; `plugin.json` lists none of
the 13 shipping skills either.

## Rejected approaches

| | |
|---|---|
| **A skill instead of an agent** | It would pull megabytes into the orchestrator's context — the exact failure the design exists to prevent |
| **Keeping it repo-local in `.claude/agents/`** | The corrections that matter happen in the consuming repository, not here. An agent installed only in Arc can never read them |

## Not delivered

**#17 asked the agent to read the session index rather than glob blind. It globs.**
`hooks/session-index` (m32) does not exist — that is [#16](https://github.com/Calyx-Engineering/arc/issues/16),
also in this milestone. The agent prefers curated saves and says which source it used, but a glob
still cannot distinguish a live worktree directory from an orphaned one, which is the case the index
exists for. **This requirement closes when #16 ships, not here.**

## Retrospective

Registered as a shipping agent. m30 remains `partial`.

**One deviation recorded:** the reference run stepped past m30's user-turns-only default, counting
`Skill` tool-use blocks to establish whether skills fired. That is m30's undecided question and the
run resolved it narrowly — counts and timestamps only, never assistant prose. Left undecided in the
spec; the agent flags when it bites.

This unblocks [#138](https://github.com/Calyx-Engineering/arc/issues/138), whose fix exists only in
The client repo's transcripts.
