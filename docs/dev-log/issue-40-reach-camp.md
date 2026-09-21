# Issue #40 — Reaching Camp

> Dev-log, not a spec. Started at plan time, finalised as a retrospective at PR time.

**Issue:** [#40](https://github.com/Calyx-Engineering/arc/issues/40)  ·  **PR:** [#53](https://github.com/Calyx-Engineering/arc/pull/53)

## Problem

[#39](https://github.com/Calyx-Engineering/arc/issues/39) created Camp's three documents and
nothing reads them. Camp needs an entry point that loads the agreement and answers in the
configured voice.

## Decisions & trade-offs

| | |
|---|---|
| **A skill plus a thin command, not two implementations** | `commands/camp.md` invokes `skills/camp`. Both entry points reach the same instructions, which is the acceptance criterion — duplicating the persona in the command would let the two drift |
| **The skill loads its own configuration and says so first** | The load table is the first section after the definition. A skill that answers before reading the agreement is the improvisation the agreement exists to prevent, and ordering the instruction first is the only enforcement available |
| **A per-question routing table for the record** | *"Where the arc stands"* reads the arc-log's status table; *"why was this decided"* reads the load-bearing decisions then the dev-log. Without it, Camp reads whatever is nearest and answers from memory |
| **The obligations table names the issue that builds each** | Camp is the entry point; the five obligations are separate issues. The table makes an unbuilt obligation visible rather than letting Camp imply it operates |
| **Missing `.claude/arc/camp/` is stated, not worked around** | Camp offers to install from `templates/camp/` rather than answering from the skill file alone |

## The registry said agent; the spec says skill

The product definition listed `agents/camp` — an **agent**, carrying m21 — and
[m21](../product-architecture/mechanisms/m21-arc-tree.md) named the form unresolved with three
candidates. [m43 §4](../product-architecture/mechanisms/m43-camp-assistant.md) settled it: Camp
is documents, skills and hooks. An agent would read the conversation continuously, which is the
one cost Arc cannot carry; only the relief valve needed it, and that half degrades to a skill.

**This is a stale-document fix, not a scope change.** Four files carried the unresolved form:

| File | Change |
|---|---|
| `docs/product-architecture/README.md` | `agents/camp` row replaced by three — the skill, the command, and `.claude/arc/camp/`. The *"unresolved"* paragraph now states the decision and its reason |
| `mechanisms/m21-arc-tree.md` | Status header, the candidate-forms table, and the conclusion |
| `ROADMAP.md` | Artifact name, build-order line, and the gap row — which no longer describes a gap |
| `mechanisms/m27-worktree-waves.md` | Left alone — its reference is conditional (*"if `agents/camp` holds arc shape"*) and belongs to the delegation arc |

**m21 stays ⚪ in the mechanism table.** Its artifact is settled and its entry point exists, but
nothing renders the spawn tree yet.

## Rejected approaches

| Rejected | Why |
|---|---|
| An agent, per the registry | m43 §4 — continuous conversation reading is the one form Arc cannot afford |
| Restating the register and length rules in the skill instead of pointing at `voice.md` | Changing the register must be a diff to `voice.md` with no code change. Restating them makes the skill a second authority |
| Building any obligation here | Each is its own issue. This is the entry point and the persona |

## Retrospective

Two new artifacts — `skills/camp/SKILL.md` and `commands/camp.md` — plus the registry
correction across three documents. `tools/sync-local-skills.sh` gained `camp`, so it is live in
this repo.

**What was verified:** both entry points reach the same skill; the answering path carries no
prefix; all three documents are loaded; the register is read from `voice.md` rather than
hardcoded; the *name-the-clause* test is present. Relative links resolve. `--check` passes.

**What could not be verified:** that any of it behaves. Nothing in this repo executes a skill —
the arc-log names this as the arc's first-listed uncertainty. Whether Camp actually answers in
three or four lines, actually refuses to act without a clause, and actually reads the agreement
before answering is unknown until it runs somewhere Arc is installed.

**One thing a future reader needs:** the acceptance criterion *"changing the register in
`voice.md` changes how the next answer reads, with no code change"* is the one that proves the
configuration-not-code design. It is untestable here for the same reason, and is the first thing
to check on first real use.
