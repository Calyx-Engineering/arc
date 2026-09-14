# Issue #259 — a topic-numbering case that separates before from after

**Issue:** [#259](https://github.com/Calyx-Engineering/arc/issues/259)  ·  **Parent:** [#145](https://github.com/Calyx-Engineering/arc/issues/145) — Fire  ·  **Closes out:** [#160](https://github.com/Calyx-Engineering/arc/issues/160)

## The result, first

**The case was built, it fails, and it fails on both sides.** Two matched probe pairs, and the
current skill did not clear the threshold on either. So the issue's first requirement — a case
that scores below threshold on the pre-#160 skill **and at or above it on the current one** —
is **not met**, and the half that is missing is the second one.

| | Every topic labelled | Cost |
|---|---|---|
| **Replay — what actually happened, 2026-08-17** | **0/3 · 0.00** · 11 topics, none labelled, 8 of them bare-numbered | free |
| **Pair 1** · before → after | 0/0 · n/a → **1/2 · 0.50** | $3.19 → $2.73 |
| **Pair 2** · before → after | 0/1 · 0.00 → **0/1 · 0.00** | $2.13 → $3.29 |

**Three of the four probe replies to turn 1 answered with bare numbers — including both runs
that had "Never a bare number" in front of them.** That is the finding. It is not the finding
the issue expected, and it is worth more than the one it expected.

## The case, and why it exists

[`evals/topic-numbering/arc-kickoff-numbered-steps`](../../evals/topic-numbering/arc-kickoff-numbered-steps) —
session `0c28d2ed`, turns 1 to 3. The same conversation `camp-thoughts-multi-topic` takes turns
130 to 132 from, at the other end of it.

The user's opening turn numbers five steps and closes: *"Please clearly number or identify your
responses to me."* The reply numbered them — `## 2. What repo trying to do`, `## 3. What to
change`, `## 4. Documentation refinement`, `## 5. Next`. **The numbers are the user's own step
numbers, not topic labels.** The user asked for numbering, got numbering, and still could not
answer by number: in this repository `2`, `3`, `4` and `5` are also issue numbers, mechanism
numbers and pass numbers. The reply's own text, four paragraphs later, recommends *"drop bare
numbers from prose."*

Turn 2 repeats the shape on four sections after reading the whole repository. Turn 3 drops
numbering altogether for three descriptive headings. **0 of 3.**

### Why this case has headroom where `camp-thoughts-multi-topic` has none

#160 measured 1.00 with its rule and 1.00 without, and diagnosed the cause: *"the recorded
defect is at turn 130 of a 391-turn session, the probe replays three turns cold, and a cold
model organises a long list of the user's thoughts into a labelled block on its own."*

**This case keys to turn 1. Replayed cold, turn 1 is turn 1** — the probe reproduces the
condition the defect was recorded under rather than an approximation of it. That was the design
argument, and it held: the case fails under the probe, repeatedly, where the other case cannot.

**What it puts pressure on is the one sentence #160 added that names a shape:** *"Never a bare
number."* A model handed a numbered list of steps mirrors the numbering.

## How the two sides were built

**Not `b85b659^`.** That commit is three commits back, and reverting to it would also revert
[#174](https://github.com/Calyx-Engineering/arc/issues/174)'s operating-agreement clause and
[#213](https://github.com/Calyx-Engineering/arc/issues/213)'s thin-floor wording — both in the
same `description:` field, both about length. A pair differing in three changes cannot attribute
a result to one of them.

**The control is HEAD's `skills/chat-response/SKILL.md` with exactly #160's two additions
removed**, and nothing else touched:

| Removed | |
|---|---|
| The `description:` sentences | *"LABEL EVERY TOPIC IN A MULTI-TOPIC REPLY … Never a bare number."* |
| The body section | *"It applies to the whole reply, not only to a block"*, through its `Scored by` line |

`diff` between the two files is 24 lines, in two hunks, and both removals were asserted present
before and absent after. **sha256** `a326c503b5f00b56` (after) against `f28514b7d5e5939d`
(before); **24630 bytes against 23116** on disk.

**Staged into the installed plugin by hand**, as #160 recorded having to: the marketplace is a
`directory` source at the main tree, so `tools/plugin-reload.sh` from a worktree installs the
main tree's content. The cache file was backed up, each side copied in, and the restore
**byte-compared** on every exit path — reported `restore: cache byte-identical to backup` on all
four runs. The cache is shared with every other session on this machine, so the staged window
was one probe long.

**The installed copy was three commits stale**, missing #174 and #213 — so the "after" side had
to be staged too. A probe that had simply used the installed plugin would have measured the
7 September version and called it current.

## Measured

Four runs, `RL_PROBE_BUDGET=1.00` throughout, one case, three turns, one session each, cwd
`R:/arc-wt/259`. Raw replies kept via `TN_PROBE_OUT` and re-scored free after the instrument was
corrected — the argument that put `TN_PROBE_OUT` in #160, earning itself a second time.

| Run | Side | t1 | t2 | t3 | Scored | Fired |
|---|---|---|---|---|---|---|
| 1 | before | `BOLDONLY` 4/5 — `S1`–`S4` labelled, one unlabelled preamble | `CUT` | `BOLDONLY` 3/5 — `N1`–`N3` | **0/0 · n/a** | t1 |
| 2 | after | `UNNUMBERED` 0/6, **6 bare** — `0 —` … `5 —` | `CUT` | `NUMBERED` 5/5 — `D0`–`D4` | **1/2 · 0.50** | t1 |
| 3 | before | `UNNUMBERED` 0/6, **6 bare** — `0.` … `5.` | `CUT` | `NOTOPICS` 0/5 | **0/1 · 0.00** | no turn |
| 4 | after | `UNNUMBERED` 0/5, **4 bare** — `1.` … `4.` | `CUT` | `CUT` | **0/1 · 0.00** | t1 |

Each pair re-scored with
`bash tools/topic-numbering.sh --compare <before>.json <after>.json --case arc-kickoff-numbered-steps`.
**Pair 1**, verbatim:

```text
the case compared                before         after
every topic labelled             0/0  n/a       1/2  0.50
not scored                       3              1
threshold                        0.67
  arc-kickoff-numbered-steps     n/a    the before side had no scorable turn
separates                        NO   no case had headroom, so neither side can show the rule working — the reason is beside each case above
verdict                          FAIL
```

**Pair 2**, same command against the other two JSONs:

```text
every topic labelled             0/1  0.00      0/1  0.00
  arc-kickoff-numbered-steps     NO     had headroom and did not cross the threshold
separates                        NO   arc-kickoff-numbered-steps had headroom and did not cross the threshold
verdict                          FAIL
```

### What the numbers say, and what they do not

**They say the case discriminates the defect.** Unlike `camp-thoughts-multi-topic`, it fails —
loudly, with the bare-number count printed beside the verdict — under a live probe, on three of
four runs.

**They say the rule did not hold on the shape it names.** Both runs with *"Never a bare number"*
in the description answered turn 1 with bare numbers. Run 3, without it, did the same. The one
run that labelled turn 1 (`S1`–`S4`) was a **before** run.

**They do not say #160's change is wrong, and n = 2 per side cannot.** Run 2's turn 3 produced
`D0`–`D4`, a fully labelled five-topic reply, on the after side; run 3's turn 3 produced nothing
labelled on the before side. Two pairs is enough to see that the case has headroom and that the
after side did not use it. It is not enough to rank two descriptions — the same limit #160
recorded, for the same reason.

**Turn 2 was `CUT` in 4 of 4 runs** after spending roughly half each run's budget. It asks for
every document in the repository, and the repository is much larger than it was on 2026-08-17.
It earns its place in the replay baseline and contributes nothing to any probe.

## The instrument could not score its own defect, and that had to be fixed first

The first control run came back `0/0 · n/a` — **no measurement at all**. The reason was in the
scorer, not the case.

#160 split the bold lead-in form three ways, because an unlabelled bold lead-in is ambiguous
between a dropped topic and ordinary emphasis: none labelled → `NOTOPICS`, all → `NUMBERED`,
some → `BOLDONLY`, and the last two unscored. Sound reasoning, and it has one hole:

> **`**2 — What this repo is trying to do.**` is not ambiguous.** Prose does not open a
> paragraph with a number and a separator. That is an enumeration.

So a probe reply enumerated `0 —` through `5 —` with **not one label on it** was scoring
`NOTOPICS` — the defect this instrument exists to catch, counted as having no topics at all.

**The rule now:** a bold reply has to evidence its sections, and there are two ways it can —
every lead-in labelled, or **two or more unlabelled lead-ins numbered** (two, because one is a
figure in a sentence). Evidenced, it is graded exactly as the heading form is, `PARTIAL`
included. Unevidenced, nothing is invented: `NOTOPICS` with no labels, `BOLDONLY` for the partly
labelled middle.

**This reaches `PARTIAL` in the bold form, which #160 recorded as unreachable there.** It is
reachable on the same evidence: `**D1 — x**`, `**2 — y**`, `**3 — z**` is *labels the first few,
then stops* with proof that the rest are sections.

**The bar is two and it is not `min_topics`.** `min_topics` asks how many topics make a reply
multi-topic; this asks whether the lead-ins are sections. Reading one for the other would raise
the evidence bar on a case that set `min_topics: 3`. That gate is now applied to the bold path
and the heading path alike, so the same reply cannot be `SINGLE` as headings and a fail as
lead-ins.

## `--compare`, and the two ways it was nearly wrong

`tools/topic-numbering.sh --compare BEFORE.json AFTER.json` scores two kept runs side by side
and answers the question a lone rate cannot. It bills nothing, and it needs no corpus.

**Review pass 1 found the verdict pooled across cases.** With `camp-thoughts-multi-topic` in the
suite at 1.00/1.00, a pooled before of 0.50 and a pooled after of 0.80 would print `separates
YES` while the case the issue is about went 0.00 → 0.50 and never cleared the threshold. The
floor would have lent its passes away. Separation is now decided **per case**.

**Review pass 2 found the fix had over-corrected.** Requiring *every* case to separate made
`verdict PASS` unreachable for any suite keeping a regression floor — 1.00 is not below the
threshold, so the floor sat permanently in a list headed *still stuck*, which also mislabels a
saturated case as a failure. The verdict is now three-valued, and **the reason travels with it**:

| | |
|---|---|
| `YES` | Below the threshold before, at or above it after |
| `NO` | **Had headroom** and did not cross. A result about the change |
| `n/a` | No headroom — and which kind is stated: a side had no scorable turn, or the before side already passed |

The two are different findings and collapsing them loses the one that matters. Pair 1 reads
`n/a  the before side had no scorable turn`; pair 2 reads `NO  had headroom and did not cross
the threshold`. An earlier draft printed the same sentence for both.

`--case` narrows **what is scored, never what is checked** — the drift check and `--strict` run
over every case regardless, or the verbatim guarantee becomes opt-in.

## Two bugs found on the way, both fixed here

| | |
|---|---|
**Two guards were broken, not three.** `TN_PROBE_OUT`'s in `topic-numbering.sh` and
`RL_PROBE_OUT`'s in `tools/response-length.sh` — **that is why a topic-numbering change edits
the response-length tool**, and it is the only line it touches. The third guard, the
`--compare` operand check, is added by this issue and was written correctly from the first
line; it was never broken and never fixed.

| | |
|---|---|
| **Probe JSON was read in the platform encoding** | `json.load(open(path))`. A probe JSON holds the model's own prose, so it holds em dashes, and on Windows the guard called a perfectly good billed run *"not probe JSON"* and refused. It refused this issue's first `--compare` |
| **The guards accepted any JSON scalar** | `123` parsed, then died inside the scorer with an `AttributeError` that reads as a bug in the tool rather than as the wrong file. All three require an object now |

**Only the `--compare` guard has a test.** `a probe JSON holding non-ASCII prose is readable` is
in `topic-numbering.sh`'s selftest; the two `*_PROBE_OUT` guards are on the billed `--probe`
path, which no selftest reaches. The fix is one line and identical in all three, and that is
recorded here rather than left to look tested.

**`tools/saturation-cases.sh:249` still carries the same broken guard** and is deliberately left
alone — it is a third tool, outside this unit. `Findings` below routes it.

## Evidence

| | |
|---|---|
| `bash tests/verify-all.sh` | **60 gates, all clean, exit 0** on the final tree. 58 when this branch was cut; merging `arc/04-dogfood` brought [#260](https://github.com/Calyx-Engineering/arc/issues/260)'s two in |
| `bash tools/topic-numbering.sh selftest` | **57 passed, 0 failed, exit 0** — up from 35 |
| `bash tools/topic-numbering.sh` | Both cases, **0/6 · 0.00**, no turn drift, exit 0 |
| Billed | **$11.33** across four probe runs — $3.186 + $2.726 + $2.125 + $3.291, as the runner reported each session's total. The table above rounds each to the cent and those round-then-sum to $11.34; the figure here is the sum, not the sum of the roundings. The kept JSONs carry the replies, not the cost, so this is from the run output and is not re-derivable from the tree |

The selftest grew by 22 cases: the three new bold outcomes, the enumeration evidence bar, the
per-case separation verdict against a pooled fixture built to cross the threshold when pooled,
the three `n/a` reasons, `--case` narrowing scoring but not drift, a kept pair re-scoring with
its transcript absent, `--strict` still failing on that, and both operand guards.

## Not done

**Requirement 1 is half met, and the tick is withheld.** A case that scores below threshold on
the pre-#160 skill: **yes** — replay 0/3 · 0.00, and probe 0/1 · 0.00 on the before side of pair
2. At or above it on the current skill: **no** — 0.50 and 0.00, both below 0.67.

The case is not the thing that failed. It fails the current skill because the current skill
produces bare-numbered replies to this turn.

## Limits

| | |
|---|---|
| **n = 2 per side** | Enough to see the case has headroom and that the after side did not use it. Not enough to rank two descriptions |
| **The probe reads the repository it runs in** | It can read the arc-log, the run instructions and this issue — **the documents that state the rule under test.** Run 2's reply names #259 and its own worktree. A control that can read the rule is not a clean control, and this applies to every `--probe` case in this suite, #160's included. It is a better explanation of that issue's 1.00/1.00 than the cold-replay one it recorded |
| **`CLAUDE.md` carries the bare-number rule too** | Present in both sides, and present at session time in 2026-08-17's `CLAUDE.md`. Not an anachronism — the recorded defect happened with the rule in `CLAUDE.md`, which is part of why #160 put it in the skill's `description:` |
| **Turn 2 cannot complete** | `CUT` in 4 of 4 at a $1.00 per-turn cap, after roughly half the run's budget |
| **`camp-thoughts-multi-topic`'s 1.00/1.00 predates this scorer** | It is the number the whole argument rests on and it is cited in five places, and it was measured by #160's instrument, before the bold-form rule and the `min_topics` gate changed here. Those runs were **not** re-taken — they are billed, and re-taking them is not this unit. That case's **replay** is unchanged at 0/3, so there is no observed regression; the probe figure is simply unverified under the new instrument |
| **The corpus is local** | `~/.claude/projects` on one machine. `--compare` no longer needs it; replay still does |
| **`turns/3.md` has trailing whitespace on two lines, and it must keep it** | The file is a verbatim cut of a recorded turn and the drift check compares it byte for byte. `git diff --check` flags it; stripping it breaks the replay |

## Findings

| Finding | Where it routes |
|---|---|
| **The current skill does not hold "Never a bare number" on a mirrored list.** 3 of 4 probe replies to turn 1 answered with bare numbers, including both runs carrying the rule. The recorded 2026-08-17 reply did the same. This is the shape the rule names, and it is the shape it does not bind on | **Needs an issue.** It is a defect in `skills/chat-response`, not in this case, and fixing it is not this unit |
| **A probe cannot be a control in the repository that documents the rule.** The probe has `Read`/`Grep`/`Glob` on the worktree, so both sides can read the arc-log, the run instructions and the issue. Every `--probe` number in this suite was taken this way | **Needs an issue.** Same surface as [#211](https://github.com/Calyx-Engineering/arc/issues/211) and as #160's staging finding — the probe needs a cwd that is not the repository under test |
| **`tools/saturation-cases.sh` carries the same platform-encoding JSON guard** that was fixed here in `topic-numbering.sh` and `response-length.sh`. One line, same crash path | **Needs an issue.** Out of this unit; the fix is known and identical |
| **`--probe` of this case spends ~55% of its budget on a turn that cannot complete.** Turn 2 asks for every document in a repository that has grown since the session | A limit on this case, recorded in `case.yaml` and above. Not filed |
