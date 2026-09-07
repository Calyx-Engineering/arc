# Eval cases

Cases authored against real work. Four suites, each asking a different question, and each with
its own scorer:

| Suite | Question | Scored by |
|---|---|---|
| **`skill-firing/`** | Did the skill fire? — [#155](https://github.com/Calyx-Engineering/arc/issues/155) | `tools/skill-cases.sh`, `tools/skill-probe.sh` |
| **`response-length/`** | Was the reply within the budget the user stated? — [#158](https://github.com/Calyx-Engineering/arc/issues/158) | `tools/response-length.sh` |
| **`topic-numbering/`** | Could the user answer this multi-topic reply by number? — [#160](https://github.com/Calyx-Engineering/arc/issues/160) | `tools/topic-numbering.sh` |
| **`report-shape/`** | Does the report open with the conclusion? — [#159](https://github.com/Calyx-Engineering/arc/issues/159) | `tools/report-grade.sh` |

**The first three score a reply. The fourth scores a document.** A report is not a turn: it is a
file, edited over days, and the turn it was written on says nothing about the shape it ended in.
So `report-shape/` keys its cases by document and line range rather than by session and turn, and
carries the excerpt it grades — which is why it is the only suite that still scores when its
corpus is absent. Its corpus is a repository, not a transcript directory.

**Firing is not adherence.** #155 settled that a skill can fire and the rule still be broken,
and that the rule can hold on a turn the skill never fired. The second and third suites exist
because the first one cannot answer their question.

**The last three need no model to grade them.** Word count, label presence and heading class are
arithmetic, so none waits on [#181](https://github.com/Calyx-Engineering/arc/issues/181). Each
carries a `selftest` on fixtures, and it is the selftest — not the real cases — that is wired
into `tools/verify-all.sh`, because the corpus is on one machine.

Everything below is `skill-firing/`'s. `response-length/` and `topic-numbering/` key their
`turns/<n>.md` by source turn number; `report-shape/` keys its `excerpt.md` by document and line
range. All three are documented in their scorers' headers.

## Running them

| | |
|---|---|
| **Today** | `bash tools/skill-cases.sh` — scores every case against the transcript it was drawn from. Add `--strict` to fail when a case's transcript is not on this machine |
| **Reports** | `bash tools/report-grade.sh` — scores every `report-shape/` case, and checks each excerpt against its source document when the corpus is present. `--file <path>` grades one document and exits on its verdict |
| **To score a change** | `bash tools/skill-probe.sh` — re-runs each `prompt.md` against the **installed** plugin and records what fired. `--openings` restricts it to `source.opening: true`, `--runs N` repeats. Run `tools/plugin-reload.sh` first or it measures the version before your edit. **It bills per run**, which is why it is not in `tools/verify-all.sh` |
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
