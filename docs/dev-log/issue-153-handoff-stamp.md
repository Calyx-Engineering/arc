# Issue #153 — the handoff header carries no time of day

**Issue:** https://github.com/Calyx-Engineering/arc/issues/153  ·  **PR:** _filled in when the batch PR opens_

## Problem

The handoff header carried a date and no time. A cold start cannot tell an hour-old handoff from
a week-old one, and treats both as current.

## Intent and north star

| | |
|---|---|
| **What this issue is really for** | Making the read path's first staleness check able to answer the question it asks. It reads the title stamp; a stamp with no time, or one that never moves, gives it nothing to work with |
| **North star** | A case asserts the stamp changed after a rewrite |
| **What makes it durable** | The rewrite check is executable rather than textual, and runs the real hook. A grep over a skill can only show a rule is written down |
| **Out of scope** | **Judging this repository's own `HANDOFF.md`** — excluded because a loop run's handoff is written by `tools/arc-loop.sh` to carry an execution mode and says of itself it is not a session handoff; asserting a session handoff's format against it would fail every loop run for a file that is not the thing being checked. **Auto-stamping the file from a hook** — deferred, not rejected: it would make the stamp true by construction, but it also means a hook rewriting a user-authored file, which is the failure #152 was filed about |

## Decisions & trade-offs

**Half of requirement 1 already existed.** `templates/handoff.md` carried
`# Handoff — <YYYY-MM-DD HH:MM>` and `skills/handoff/SKILL.md` said so once, at line 333, in the
*Template* section. What was missing was requirement 2 in its entirety, and the placement: a rule
about what every write does has to be in the write path, or a session writing the handoff never
reads it. So the substantive change is small and deliberately so — the issue's defect was the
absent re-stamp rule, not the header format.

**Stated mechanically, because the vague form is what was already there and did not bind.** *If
the body changed and the stamp did not, the stamp is wrong* can be applied without judgement, and
it is the same predicate the gate implements.

**The check is possible only because #152 landed first.** Comparing "the stamp before" with "the
stamp now" needs the before, and `hooks/handoff-archive` is what leaves it on disk. Case 7 fires
the real hook, rewrites the handoff without moving the stamp, and asserts the gate catches it —
which is #153's *done when*, executed rather than asserted. The dependency is deliberate and
recorded here because it is not obvious from either issue alone.

**An identical file is not a rewrite.** Without that branch the gate would demand a new stamp for
a write that changed nothing, and every no-op save would become a finding — the kind of false
positive that gets a gate switched off.

## Rejected approaches

**A hook that re-stamps the title automatically.** It would make the property true by
construction and remove the need for the rule. Rejected for now: it is a hook rewriting a
user-authored file, which is precisely what #152 exists to guard against, and the interaction
between the two deserves its own decision rather than being taken as a side effect of this issue.

## Retrospective

Built: the re-stamp rule in `skills/handoff/SKILL.md`'s write path, and
`tools/verify-handoff-stamp.sh` — 4 live probes, 13 fixture cases, wired into `verify-all.sh` as
two gates. The live rewrite probe reports `SKIP` with its reason where no archived prior handoff
exists, rather than passing silently.

**What changed from the plan:** nothing structural. The issue reads as a two-line header fix and
the actual work was placement plus an executable predicate; the header half was already done.

**What a future reader needs to know:** the live gate does not judge `HANDOFF.md` in this
repository, on purpose — see *Out of scope*. The rewrite property is checked wherever an archived
prior copy exists, which in practice means any repository where `hooks/handoff-archive` has run.
