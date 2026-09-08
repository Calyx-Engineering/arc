# Issue #151 — a north star is read at cold start and does not bind

**Issue:** [#151](https://github.com/Calyx-Engineering/arc/issues/151)  ·  **PR:** [#237](https://github.com/Calyx-Engineering/arc/pull/237)

## Problem

A populated, correct, freshly-read handoff does not bind. The session reports status correctly
and then does the wrong work, sometimes reaching the opposite conclusion to what the document
says. [#150](https://github.com/Calyx-Engineering/arc/issues/150)'s baseline scored 5/8 on *first
action correct* and 4/8 on *states why, unprompted*.

## Intent and north star

| | |
|---|---|
| **What this issue is really for** | Making a decision survive a context boundary. The handoff already carried decisions; what died with the session was the fact each decision rested on |
| **North star** | On the same 8 openings the first action is correct and the session states why the approach was chosen, unprompted |
| **What makes it durable** | A gate that fails if either artifact drifts back. The two rules that stripped the rationale were *written down* — this was a rule being followed, not an omission, so a sweep with no gate would be re-written by the next person reading the old prose |
| **Out of scope** | **A live re-run of the 8 openings** — deferred to [#181](https://github.com/Calyx-Engineering/arc/issues/181), because scoring a changed format against a closed corpus of finished transcripts is not possible: the sessions recorded there read the old format and cannot read another. **Any format change beyond the two columns and one section named below** — the issue's own constraint, because every previous attempt restyled the document and none produced a score |

## Decisions & trade-offs

**The defect was a rule, not an omission.** `templates/handoff.md` said *"**What** was decided,
not why — the why is in the dev-log"* and `skills/handoff/SKILL.md` routed *"Why a decision was
made"* to the dev-log. Both were being obeyed. That is why the fix is a change to the rules plus
a gate, and not a sweep of existing handoffs.

**The discriminator is a form, not an exhortation.** "Include the why" is what every previous
attempt said, and it cannot separate the disposable from the load-bearing — which is the
hypothesis' own claim. What separates them: a load-bearing reason can be written as a fact that
would have to **change** for the decision to change. *"We tried X, then Y"* names no such fact.
So the column is headed *What would have to change to re-open it*, and the gate looks for that
form rather than for the word "why".

**Two columns, not three.** The old second column held *the constraint it imposes* — the
downstream consequence. #151 asks for the constraint *behind* the decision, which is the upstream
cause and a different thing. Adding a third column would have kept both and restyled the table;
the imposed constraint, where it is a live trap, is already *Do not*'s. So the second column was
repurposed rather than joined.

**The trigger is separate from the column because the evidence says they fix different
openings.** Baseline opening 7 stated its rationale correctly and unprompted and still built the
wrong rig — the constraint column changes nothing there. What was missed was a condition attached
to an alternative (*only needed if the coupler floor lands above the audio band*). So the trigger
tests the condition rather than asking for an announcement, and the gate has a probe that fails a
trigger which only announces.

**The trigger has two forms, because the first draft only had one and it excluded the opening it
claimed to cover.** As written it fired on *the same ordered action, done another way*. Opening 4
was not that — it was a re-ordering of two different rows, so by its own scope sentence the
trigger would not have fired on the case cited for it. Re-ordering accepted rows is replacing the
approach to all of them at once, and it is the form least likely to be noticed because every row
still gets done. Both forms are now named.

**The reason for an order needed a home, and it was not the decisions table.** Opening 4's
missing fact was *why this order*, which belongs to a *Do these in order* row — the constraint
column is in *Load-bearing decisions* and would not have held it. The ordered-actions rule
already required a row to name a hard dependency; it now also requires the reason for a soft
position, which is the kind that looks omissible and is exactly what was missing.

## Rejected approaches

**Adding a *What was ruled out* section to the template.** `skills/handoff/SKILL.md` lists it in
*What it holds* and the template omits it — a real divergence. Rejected here as out of the
issue's *no restyle* constraint: it is a new section, its absence caused none of the five bad
openings, and adding it would have made the diff a format change with no score behind it.

**Scoring C1/C2 against the changed format.** Rejected as not possible rather than not worth
doing — see *Out of scope*.

## Spawned

- **Arc work:** [the hypothesis tested, and the re-score](../arc-work/04-dogfood/handoff-rationale.md)
- **Findings, not filed** — two of the five bad openings are outside anything #151 can reach, and
  both are recorded in the issue's *Spawned* table rather than absorbed:
  - Opening 1 — a handoff written to a session scratchpad is not detectable. Nothing in the read
    path notices a file that was never written where the next session looks.
  - Opening 2 — the seven staleness checks bound the *repository's* state (branch, tree, log,
    PRs, first issue). None reads a factual assertion, so a handoff can claim *"not cloned here"*
    about a clone that exists and pass every check.

## Retrospective

Built: the constraint column in `templates/handoff.md`; the routing-row correction, the
approach-replacement trigger and the soft-ordering rule in `skills/handoff/SKILL.md`; the
*Why here* column in the handoff template's ordered actions; the reason requirement in
`templates/dev-log.md`; and `tools/verify-handoff-rationale.sh` — 9 live probes, 12 fixture
cases, wired into `verify-all.sh` as two gates.

**What changed from the plan: the hypothesis did not survive intact.** It was filed as the
explanation and holds for two of five bad openings. Three fail in other layers — no document,
a false document, and a document that was read and correctly understood. The fix was split along
that line rather than stretched to cover it, and the two openings it cannot reach are named in
the issue instead of being quietly folded in.

**What a future reader needs to know:** the gate proves the rules are present and that each probe
can fail. It cannot prove a session follows them, and no gate here can — `verify-all.sh --list`
says so for every skill. The first honest datum is the next real cold start.
