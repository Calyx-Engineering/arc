# Issue #208 — the cold-start staleness checks are unreachable from skills/handoff

**Issue:** [#208](https://github.com/Calyx-Engineering/arc/issues/208)  ·  **PR:** [#220](https://github.com/Calyx-Engineering/arc/pull/220)

## Problem

m15 has two openings into one mechanism, and the checks lived in only one of them.
`commands/arc-next.md` carried the seven staleness checks; `skills/handoff` mentioned them
and did not carry them. So an opening that reached the skill — which is most of them, since
its `description:` lists twenty wordings — got the read path with no check against the tree
(`76e54966`), and an opening that reached the command got the checks without the skill's
write path and transcript rules (`e349dc03`, where the command fired and never invoked the
skill it delegates to).

## Intent and north star

| | |
|---|---|
| **What this issue is really for** | Deciding which artifact *owns* a rule when two can open the same mechanism. The owner is the one every opening passes through |
| **North star** | A cold start that loads `skills/handoff` and never touches `/arc-next` runs the staleness checks |
| **What makes it durable** | A gate that fails when the split reopens — including when the content drifts out of the read path, and including in the copy that actually fires here |
| **Out of scope** | The trigger. `/arc-next` firing without invoking the skill is #157's, and the constraint says so |

Pass 2, after reading what the issue links: unchanged in substance, but the ownership question
turned out to have four more instances than the issue names — see *Decisions*.

## Decisions & trade-offs

**The skill owns it, not the command, because the skill is downstream of both openings.**
`/arc-next` invokes `skills/handoff`; nothing invokes the command. A rule in the command is
reachable only by typing; a rule in the skill is reachable by typing *and* by wording. The
same argument decides every future case of this shape.

**The command was stripped rather than kept in sync.** Two copies of a rule drift — that is
m15's own argument for a document spine, applied to itself. The command now says explicitly
that it holds no rule of its own, so the next editor does not put one back.

**`### Then execute` moved too, though no box asked for it.** The two failure modes — no
handoff, no ordered actions — were in the same position as the checks: carried by the command
alone, and needed by every skill-only cold start. Leaving them behind would have fixed one
half of the same defect.

**The seven were added to the skill's `checks:` declaration.** A command has no such field, so
the obligation is new rather than moved. Without it `camp-reports.md`'s rule applies: not
declared, so nothing reported and nothing logged — seven checks running with no evidence they
ran.

**Four more artifacts made the same claim and were swept with it.** `templates/handoff.md`
(copied into every `HANDOFF.md`, so the wrong owner was being read *inside the document being
acted on*), `skills/autonomy-set`, and m40's prose, diagram node and delivery table. Fixing
the skill and leaving these would have left the repository disagreeing with itself about the
same fact this issue exists to settle.

**`.claude/commands/arc-next.md` is the copy that fires here**, and it was byte-identical to
the old plugin command. Syncing it is not tidying: the gate would have been green while the
running command still carried the checks. The gate now reads both files.

## Rejected approaches

**Leaving the checks in the command and having the skill link to them.** A link is not a
carrier — `76e54966` is a session that had the skill loaded and did not run the checks, with
the reference right there. That is the defect, not a milder form of it.

**Deleting `.claude/commands/arc-next.md` the way #142 deleted the `.claude/skills/` copies.**
Defensible, and larger than this issue: `verify-skill-registry.sh` states a repo-local command
is allowed and worth seeing. Synced instead.

**A gate that greps the whole file.** It passed for the wrong reason — the block could move
below the write path and every probe would still match. The probes now run on a slice bounded
by the read-path headings, and a separate assertion pins the heading order.

## Spawned

- **Issues:** none filed. Four findings routed in the issue's `Spawned` table — the command's
  missing fallback (#157), the six un-annotated `checks:` names, `autonomy-set`'s re-read rule
  resting on no mechanical check (m40), and the Done-when being proven as location rather than
  behaviour (#181).

## Retrospective

Built as scoped, and the review passes roughly doubled the file count: four required boxes,
eleven files. Pass 1 found the `checks:` declaration and three unswept artifacts; pass 2 found
the template link dead at its destination, the `skips:` format wrong, the gate passing for the
wrong reason, and the shadow copy; pass 3 found m40 half-swept and box 1's evidence already
stale by one assertion.

**What a future reader needs.** The gate proves *location*, not behaviour — no gate in this
repository invokes a skill, and both `tools/verify-all.sh --list` and the new script's own
header say so. Its three deny cases were run against fixtures under `HANDOFFCHK_ROOT`: block
drifted below the write path, shadow copy left stale, one check row deleted — exit 1 each.
