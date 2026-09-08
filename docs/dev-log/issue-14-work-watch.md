# Issue #14 — the work watcher, and engineering reports

> Dev-log, not a spec.

**Issue:** [#14](https://github.com/Calyx-Engineering/arc/issues/14)  ·  **PR:** [#24](https://github.com/Calyx-Engineering/arc/pull/24)

## Problem

Three mechanisms watch work as it proceeds and nudge: commit timing (m14), test obligations
created at design time and forgotten by the time hardware arrives (m23), and questioning
that has gone deeper than the decision needs (m41). One sweep, not three always-on checks
competing for the same attention.

## Decisions & trade-offs

**One skill, three checks, one threshold.** The three share the same failure mode —
over-firing recreates the annoyance in a new form — so they share the moment they fire and
the judgment about whether anything has changed since the last sweep.

**m41's trigger ships as judgment, and the skill says so.** Four mechanical triggers were
named in the spec and each fails: turn count fires during legitimate long analysis;
"questions without a decision landing" needs a definition of *landed*; model judgment is not
mechanically checkable; user-invoked puts the load back on the person the mechanism protects.
Shipping judgment with the limitation stated is better than shipping a rule that fires wrong
— but a judgment check can silently stop working, so the skill names the evidence that it
did: a session ending with the user frustrated at depth.

**`files.autoSave` ships as a file, not as advice.** The spec recommends it as setup. A
recommendation in a skill is a rule with no trigger — the exact failure this product exists
to fix — so `.vscode/settings.json` is committed.

**`engineering-report` gains a K-tier framing on the way across.** ROADZ's version says "one
directory per report topic"; the tier ladder says the unit is a *capability*, and that a
report is rare. Stating it at the top is the one substantive addition to an otherwise
faithful port.

## Rejected approaches

**A hook for the capture-point check.** "Semi-mature" is not mechanically detectable, which
is why the spec calls for judgment. A hook would fire constantly or miss the interesting
cases. The mechanical half — files saved, identity correct, nothing dropped from the
staging area — could be hooked later, but it is pre-commit, and nothing commits unasked.

**Three separate skills.** They read as three independent obligations, which is how you get
three checks competing for attention and all three being ignored.

## Spawned

Nothing filed.

## Retrospective

Shipped `skills/work-watch`, `skills/engineering-report`, and `.vscode/settings.json`.

**Two `.gitignore` bugs in two issues.** #13 found a bare `HANDOFF.md` matching at any depth.
This one found that `!.vscode/settings.json` does nothing while `.vscode/` is excluded — git
does not descend into an excluded directory, so a negation inside one can never match. Fixed
by excluding `.vscode/*` instead. Both were caught by checking rather than assuming, with
`git check-ignore -v`.

**The relief valve is the mechanism this arc most needed and least got to test.** Pass 1 ran
without a depth problem, because the roadmap and the issue bodies had already made the
decisions. That is not evidence the check works — it is evidence that good planning removes
the occasions for it.
