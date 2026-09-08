# Handoff rationale — the hypothesis tested, and the re-score

**The hypothesis is confirmed for two of the five bad openings and rejected for three.** It is
the right diagnosis where it applies, and [#151](https://github.com/Calyx-Engineering/arc/issues/151)'s
opening 4 is precisely the mechanism it predicts — a correct handoff, a decision with no
constraint, and a session that re-derived the reason and reached the opposite answer. It is not
the whole story: two openings failed for reasons no amount of carried rationale touches, and one
failed with its rationale present, correct and volunteered.

**So carrying the constraint is necessary and not sufficient**, which is why #151 asks for a
trigger as a separate requirement. The fix ended up as **three** mechanisms, not two — the
constraint column, the reason an ordered-actions row gives for its position, and the trigger —
because opening 4's missing fact turned out to live in the ordered actions rather than in the
decisions table. Each covers different openings and none covers all of them.

The corpus and the criteria are [the baseline](handoff-baseline.md)'s. *Bad* means bad by
[#150](https://github.com/Calyx-Engineering/arc/issues/150)'s definition — either criterion
failed — which is five openings, not three.

## The hypothesis against each bad opening

> Rationale is stripped along with narrative. A fresh session holds a decision with none of its
> constraints and reverses it when circumstances look different.

| # | Failed | What the document did | Explained? |
|---|---|---|---|
| 1 | C2 | Nothing was carried. The writer's document went to a session scratchpad headed *"Not committed to ROADZ"*, and the reader found `=====HANDOFF=====` with nothing under it | **No** — a delivery failure. Nothing was stripped because nothing was written |
| 2 | C1, C2 | The document was **wrong**, not thin. It asserted *"not cloned here"* and *"Fill in rows 2–4"* when the clone existed and all five rows were open | **No** — and the binding worked. The session repeated both claims faithfully 4.2 seconds after reading them. Stale content, not missing rationale |
| 3 | C2 | *"Option 1 is the recommended fix: a 1:1 600 Ω line isolation transformer per channel"* — the choice asserted, with no *why Option 1* anywhere in the file | **Yes** |
| 4 | C1, C2 | *"Once filed, steps 0a–0b … unlock the #40 work"* — the order given, the reason absent. The session re-derived a reason from the dependency graph and inverted the order | **Yes — the predicted mechanism exactly, in a slot the hypothesis did not name.** Decision, no constraint, re-derived, opposite answer: that is the hypothesis step for step. What it got wrong is *where*. It points at *Load-bearing decisions*; this decision was an **order**, and lives in the ordered actions. The fact that would have settled it — the user was about to be physically at the bench — was never written down anywhere |
| 7 | C1 | The bound was in the document *and* quoted back correctly, unprompted, at `00:59:38`. A DC-ramp capacitance rig was designed four minutes later for a setup that measures inductance | **No** — rationale present, stated, and still the wrong work |

**Two confirm, three reject.** The three rejections are not near-misses; each fails for a cause
in a different layer — the document was never delivered (1), the document was false (2), the
document was read and correctly understood (7).

**Confirming the mechanism is not the same as confirming where it lives, and opening 4 separates
the two.** The hypothesis describes the failure exactly and then points at the wrong section: it
says *a decision with none of its constraints*, and the decisions table is the obvious home, but
opening 4's decision was a **sequence**. The constraint column engages nothing there. This is why
the fix below is three mechanisms rather than one — the diagnosis was right and its implied
remedy was incomplete.

## What that splits the fix into

| Opening | What engages it |
|---|---|
| 3 | **The constraint column.** *Load-bearing decisions* now asks what would have to change to re-open the decision, and the template says a row with an empty second column is a decision that will be re-opened |
| 4 | **The ordered-actions rule and the trigger — not the constraint column.** The missing fact was *why this order*, which belongs to a *Do these in order* row and not to the decisions table. `skills/handoff/SKILL.md` now requires a row to say why it sits where it does even when the order is not a hard dependency, and the trigger's second form fires on a re-ordering of accepted rows |
| 7 | **The approach-replacement trigger**, and specifically its condition row. The handoff said the step method was *not built, only needed if the coupler floor lands above the audio band*; the session promoted it without testing that condition. The constraint column would have changed nothing here — the constraint was already there and already read |
| 1, 2 | **Neither.** Outside what this issue can reach |

**Openings 1 and 2 are worth naming rather than absorbing.** #151 cannot fix them and does not
claim to.

- **1 is a delivery failure.** A handoff written to a scratchpad is not a handoff. Nothing in the
  read path detects a file that was never written to the place the next session looks.
- **2 is a staleness failure the seven checks do not catch.** They compare the handoff against
  the branch, the tree, the log, open PRs and the first action's issue. None of them reads a
  factual claim like *"not cloned here"*, so a handoff can assert something false about the world
  and pass every check. The checks bound the repository's state, not the document's assertions.

Both are recorded as spawned findings rather than fixed here.

## The re-score

**The enumeration re-runs and reproduces the corpus. The scores cannot be re-taken, and this is
a property of the corpus, not a shortcut.**

```sh
bash tools/handoff-openings.sh r--work-lantern-roadz-sound-system r--arc \
  --since 2026-08-24T09:40 --until 2026-09-06
```

Exit 0, the same eight writer→reader pairs, the same ages — `bfd1177f`, `be5aca1c`, `e349dc03`,
`6b72c941`, `9cefd799`, `c4fe2b5c`, `10774bf5`, `508d625d`. The corpus is stable, so a later
comparison has something fixed to compare against.

**The baseline set a bar this does not clear, and it should be quoted rather than skirted:**
*"A fix moves a row or it did not work."* No row moves here. The same document names why in its
next breath — re-running an opening against a changed format is #181 — but the two sentences sit
apart, and reading only the first would leave you expecting a moved score from this issue. There
is none, and there cannot be one from this corpus.

**C1 and C2 cannot move.** They score what a session *did*, and all eight sessions are finished
recordings of openings that read the old format. Re-reading them yields the baseline's numbers by
construction; a changed format cannot reach backwards into a transcript. Re-running an opening against the changed artifacts needs a live model.

**And no filed issue carries that work — including #181, which the baseline routes it to and this
document repeated.** [#181](https://github.com/Calyx-Engineering/arc/issues/181) builds *an eval
suite that gates skill firing*: a suite per shipping skill, `tool_used: Skill` graders, a
threshold in `verify-all.sh`. It would supply the **capability** — `claude plugin eval` can re-run
a case against a changed artifact, which is exactly what is missing — but none of its boxes
re-scores a handoff opening, and it is itself blocked on an account entitlement rather than on an
issue. The re-score is unrouted, and is recorded as a spawned finding rather than parked against
an issue that does not hold it.

So what follows is a **document-level counterfactual**, scored by reading the changed artifacts
against each bad opening's missing fact. It is weaker than the baseline in two specific ways, and
neither is repairable from this corpus:

| | |
|---|---|
| **It scores the artifact, not a session** | *Does a slot now exist that demands the fact that was missing* — not *would a session have filled it* |
| **It is self-assessed** | Scored by the run that made the change, against criteria that run also chose. The baseline's per-cell quotes were produced by eight independent read-only sub-agents; nothing here has that separation |

| # | The fact that was missing | Does the changed format demand it? |
|---|---|---|
| 1 | — | **No.** No handoff existed |
| 2 | — | **No.** The document's claims were false, and no slot makes a false claim true |
| 3 | *Why* Option 1 — the constraint that rules out Options 2 and 3 | **Yes.** The decision cannot be written without a second column, and the column asks for the fact it rests on |
| 4 | The user was about to be at the bench, so bench-blocking work goes first | **Yes, by two mechanisms, and neither is the constraint column** — that column is in *Load-bearing decisions* and this fact belongs to an ordered-actions row. The row must now give the reason for its position even when the order is a soft one, and the trigger's second form fires on a re-ordering of accepted rows |
| 7 | Nothing was missing | **Yes, by the other half.** The trigger's condition row sends the session back to *only needed if the coupler floor lands above the audio band* before it may start with the step method |

**Three of five bad openings now have a mechanism that engages; two do not.** Both exceptions
are named above and neither is a rationale problem.

## What would actually move the score

**A live re-run — #181.** Everything here is text about text. The gate
(`tools/verify-handoff-rationale.sh`, 9 live probes, 12 fixture cases) proves the rules are
present and that each probe can fail; it cannot prove a session follows them, and no gate in this
repository can — `tools/verify-all.sh --list` says so for every skill.

**The next real cold start is the first honest datum.** It reads the changed format with no
knowledge of this document, which is the separation the counterfactual above lacks.
