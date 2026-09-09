# Eval cases

Cases authored against real work. Six suites, each asking a different question, and each with
its own scorer:

| Suite | Question | Scored by |
|---|---|---|
| **`skill-firing/`** | Did the skill fire? — [#155](https://github.com/Calyx-Engineering/arc/issues/155) | `tools/skill-cases.sh`, `tools/skill-probe.sh` |
| **`response-length/`** | Was the reply within its budget — the one the user stated, or the one the repository's operating agreement holds? — [#158](https://github.com/Calyx-Engineering/arc/issues/158), [#174](https://github.com/Calyx-Engineering/arc/issues/174) | `tools/response-length.sh` |
| **`topic-numbering/`** | Could the user answer this multi-topic reply by number? — [#160](https://github.com/Calyx-Engineering/arc/issues/160) | `tools/topic-numbering.sh` |
| **`report-shape/`** | Does the report open with the conclusion, and does every claim say where it came from? — [#159](https://github.com/Calyx-Engineering/arc/issues/159), [#164](https://github.com/Calyx-Engineering/arc/issues/164) | `tools/report-grade.sh` |
| **`saturation/`** | Did the session propose handing off before the user said the context was full? — [#154](https://github.com/Calyx-Engineering/arc/issues/154) | `tools/saturation-cases.sh` |
| **`environment-blame/`** | Was one alternative tested on the session's own command path before the user's bench was named as the cause? — [#165](https://github.com/Calyx-Engineering/arc/issues/165) | `tools/environment-blame.sh` |

**The first three score a reply. The fourth scores a document. The last two score a session.**
`saturation/` asks which turn a proposal landed on, and the answer only exists across a whole
conversation: the defect is that the session had not said anything yet, so there is no prompt to
key a case to. It carries the user's turns in order, the turn he called the saturation on, and
the turn before which a proposal would have been nagging rather than noticing.

**A report is not a turn:** it is a file, edited over days, and the turn it was written on says
nothing about the shape it ended in.
So `report-shape/` keys its cases by document and line range rather than by session and turn, and
carries the excerpt it grades — which is why it is the only suite that still scores when its
corpus is absent. Its corpus is a repository, not a transcript directory.

**Its `excerpt.md` files do not lint, and must not be made to.** They are verbatim cuts from
larger documents, so they carry a trailing blank line the cut fell on, a heading inside a
blockquote, and an anchor pointing at a section below the cut. Editing any of that would break
both the verbatim claim and the drift check, which is the point of storing them at all.

**It is also the only suite scoring more than one question.** `report-shape/` has three columns —
the opening, provenance on a claim table, and whether a disagreement between two sources is
stated out loud — and **every column with anything in its denominator has to clear the
threshold.** A suite that passed on the average of three questions would let a repaired opening
report an unsourced table as progress. A case declares a document and a line range and never an
outcome; the scorer re-derives every column it can answer.

**Firing is not adherence.** #155 settled that a skill can fire and the rule still be broken,
and that the rule can hold on a turn the skill never fired. The second and third suites exist
because the first one cannot answer their question.

**The last five need no model to grade them.** Word count, label presence, heading class and
which turn a keyword landed on are arithmetic, so none waits on
[#181](https://github.com/Calyx-Engineering/arc/issues/181). Each carries a `selftest` on
fixtures, and it is the selftest — not the real cases — that is wired into
`tools/verify-all.sh`, because the corpus is on one machine.

**`saturation/` and `environment-blame/` carry the weakest arithmetic, and both say so.**
Whether a reply proposed handing off, and whether it tested an alternative before naming the
bench, are judgments answered here with keyword scans. Three things keep them honest: a pass
also requires the skill to have fired, the matching sentences are printed rather than
summarised, and `environment-blame/` resolves an unmatchable case to the failure rather than to
the pass — a false `HELD` hides the defect the suite exists to find.

**`environment-blame/` is the only suite with no probe, and the reason is the condition.** Its
case is hardware-in-the-loop: an instrument that answers and returns nothing while the user has
stated a measurement. Replaying those turns puts the session in front of no instrument, so it
never reaches the choice being scored. Replay is the whole measurement there, and it is a
baseline; scoring a change to `work-watch` check 8 needs a live session at a real bench.

Everything below is `skill-firing/`'s. `response-length/`, `topic-numbering/`, `saturation/` and
`environment-blame/` key their `turns/<n>.md` by source turn number; `report-shape/` keys its
`excerpt.md` by document and line range. All five are documented in their scorers' headers.

## Running them

| | |
|---|---|
| **Today** | `bash tools/skill-cases.sh` — scores every case against the transcript it was drawn from. Add `--strict` to fail when a case's transcript is not on this machine |
| **Reports** | `bash tools/report-grade.sh` — scores every `report-shape/` case, and checks each excerpt against its source document when the corpus is present. `--file <path>` grades one document and exits on its verdict |
| **Saturation** | `bash tools/saturation-cases.sh` — replays the case's session and reports which turn a handoff was proposed on, if any. `--probe` replays the turns live instead; it is 52 turns of billing, and it needs `tools/plugin-reload.sh` first, which rewrites the installed plugin every other session on the machine is using |
| **Environment blame** | `bash tools/environment-blame.sh` — replays the case's session and reports the first turn that handed the failure to the bench, with the sentence that did it and whatever was tested first. No `--probe`; see above |
| **To score a change** | `bash tools/skill-probe.sh` — re-runs each `prompt.md` against the **installed** plugin and records what fired. `--openings` restricts it to `source.opening: true`, `--runs N` repeats. Run `tools/plugin-reload.sh` first or it measures the version before your edit. **It bills per run**, which is why it is not in `tools/verify-all.sh` |

**`tools/plugin-reload.sh` refuses on a dirty tree.** It installs from the working tree rather
than from `HEAD`, so it exits 1 and names every uncommitted file the installed plugin would
read — anything outside `docs/`, `evals/` and the repository's loose `.md` files. Commit them,
or `tools/plugin-reload.sh --force` to install them as they stand. #211.
| **When `plugin eval` opens** | `claude plugin eval --eval-dir evals` — re-runs each `prompt.md` against the live plugin |

**`tools/skill-cases.sh` cannot see a description change.** It replays transcripts recorded
before the edit, so the same rows come back before and after. That is what `tools/skill-probe.sh`
is for, and the distinction matters: a trigger fix scored only by `skill-cases.sh` has no
evidence behind it at all.

**`claude plugin eval` is gated behind early access and cannot be run here.** `claude plugin eval
init --bare` returns `` `plugin eval` is currently in early access `` — and **exits 0 while doing
it**, so a gate wired to it reports PASS having run nothing.
[#181](https://github.com/Calyx-Engineering/arc/issues/181) tracks access.

`plugin.json` sets no `experimental.evals` key, because `evals/` is already the default eval
directory. There is nothing to configure until there is a second suite.

**Consequence for this suite:** `prompt.md` is verbatim and portable, but the `case.yaml` field
names below are this repository's, not a schema validated against `plugin eval`. Porting is a
rename, not a re-authoring.

## What a case is

```
skill-firing/<shape>/<slug>/
  case.yaml        shape, what should fire, and where the prompt came from
  prompt.md        the user's words, verbatim, from a session that happened
  graders/fired.md what counts as a pass
```

`case.yaml` records **no outcome.** `tools/skill-cases.sh` re-derives what fired from the
transcript named in `source:`. A recorded outcome that nothing re-checks is the tick-without-
evidence failure the arc exists to fix.

**The exit code is not the score.** It reports prompt drift, and with `--strict` an absent
transcript. A case that fails is a measurement, and the whole point of a baseline is that some
of them do.

| Field | |
|---|---|
| `shape` | `bare`, `wrapped` or `situation` — the three shapes in §2 of the decision |
| `expect` | Skills that should fire. `none` is a control: a prompt where firing is the wrong answer |
| `source.session` | The transcript's filename stem. `source.turn` is the human turn, counting **human turns only** |
| `source.opening` | `true` when the turn is within the first 3 prompt turns |
| `why` | Why this turn is in the suite, and anything a reader needs before counting its result. Free text, not scored |

## Why the prompts are not invented

**A prompt written to make a skill fire proves the wrong thing.** Every `prompt.md` here is a
turn the user actually typed, copied without editing — including the typos, the `<ide_opened_file>`
wrapper the IDE injects, and the second and third requests stacked into the same message. Those
are the properties under test.
