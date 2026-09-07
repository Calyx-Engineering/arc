# PR #192 — the boundary report, and the run instructions that produce it

**Issue:** none  ·  **PR:** [#192](https://github.com/Calyx-Engineering/arc/pull/192)

## Problem

Loop's boundary report took six rounds of correction from the user. Each round found something the previous one had not been looking for.

| Round | Found |
| --- | --- |
| 1 | 302 words against a stated 200 |
| 2 | Four unnumbered parts, missing spawned issues, surprises and unplanned work |
| 3 | Impossible to tell where the report started and ended |
| 4 | An unnumbered `###` in a document that numbers every heading |
| 5 | Prose with middle-dot separators where lists belonged |
| 6 | §6.1 named for *when* its units closed, stale counts, [#189](https://github.com/Calyx-Engineering/arc/issues/189) missing entirely |

**None of these were judgement calls.** Each was a rule the document already followed elsewhere, or a section the template should have required. The template was the defect; the report was the symptom.

## What changed

| File | |
| --- | --- |
| `docs/arc-log/arc-04-dogfood.md` | §6 counts read from the `subIssues` API. §6.1 renamed *The retrospective and the plan*. §6.2 rewritten: seven `####` sections, real lists and tables, a routing column, 199 words |
| `docs/arc-work/04-dogfood/run-instructions.md` | Restructured into two explicit paths, and the boundary sequence written down |
| `tools/arc-loop.sh` | Both prompts say which run kind they are and which sections apply |

## Decisions and trade-offs

| | |
| --- | --- |
| **The report's sections are `####` headings, not bold lead-ins** | A heading is citable, appears in the outline, and can be answered by number. `6.2.3` is a reference; **3 Unexpected** is not |
| **Section 2 carries a routing column** | Where an issue went — this workstream, another, out of the arc. Routing is the half a reader needs and the half most often left out |
| **Section 7 holds the diagram** | Loose after section 6 it read as a picture of what was *not* done, which is what the user saw |
| **The boundary is six ordered steps, not a report** | Post to the parent, drop the mode to manual, leave the parent open. Two of today's failures were the last two steps being absent |
| **One file, not two** | Splitting issue-run and report-run instructions would duplicate §7, and a report run needs §2's standard to judge a checklist by. Two copies of a rule is the defect [#138](https://github.com/Calyx-Engineering/arc/issues/138) was about |
| **The issue body is part of the record** | §2 step 6 now says *edit the issue body*, not just check the boxes. A checklist ticked in the run's head leaves the tracker describing work that did not happen |

## What a whole-file read found

Reading `run-instructions.md` end to end, rather than at the point of each edit, surfaced five things no individual correction had:

- §4 still said merging *"needs a route that does not exist"*. [#138](https://github.com/Calyx-Engineering/arc/issues/138) had landed
- §2 named `claude plugin eval --threshold` as a gate. It is unavailable — [#181](https://github.com/Calyx-Engineering/arc/issues/181)
- The template said *"the six sections"* above a seven-row table
- §7 was missing both of the day's failures: committing in manual, and closing a workstream parent
- The title said *executing one issue* for a file that also governs report runs

## Retrospective

**Six corrections, then one read, then five more findings.** The corrections were each valid and each narrow. The single cold read — the same pass 4 the document prescribes for a PR — found more than any of them, and would have found most of the six.

**The document prescribed a discipline it was not subject to.** `run-instructions.md` §2 requires reading whole files rather than diffs, and it was itself edited a dozen times without once being read whole.
