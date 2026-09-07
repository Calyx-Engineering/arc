# Eval cases

Cases for `claude plugin eval`, authored against real sessions. The suite that exists today is
**`skill-firing/`** — [#155](https://github.com/Calyx-Engineering/arc/issues/155)'s question of
why a skill does not fire.

## Running them

| | |
|---|---|
| **Today** | `bash tools/skill-cases.sh` — scores every case against the transcript it was drawn from. Add `--strict` to fail when a case's transcript is not on this machine |
| **When `plugin eval` opens** | `claude plugin eval --eval-dir evals` — re-runs each `prompt.md` against the live plugin |

**`claude plugin eval` is gated behind early access and cannot be run here.** `claude plugin eval
init --bare` returns `` `plugin eval` is currently in early access `` — and **exits 0 while doing
it**, so a gate wired to it reports PASS having run nothing.
[#181](https://github.com/Calyx-Engineering/arc/issues/181) tracks access.

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
