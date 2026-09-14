# The skill-writing method, and what keeps it

**Decision, [#275](https://github.com/Calyx-Engineering/arc/issues/275), 2026-09-13.** Five
candidates run against one real skill — `skills/record-route/SKILL.md`, 213 body lines — and
against the whole tree wherever a candidate runs on it. Line counts measured on `skills/`, per
[#90](https://github.com/Calyx-Engineering/arc/issues/90)'s constraint.

> **No installed tool reviews a skill.** Both authoring tools are shaped to rewrite one, and the
> only candidate that read the body scored Arc's house style as defects. What Arc adopts is one
> instrument applied statically, one mechanical pre-pass that is free, and a named list of
> deviations — not a tool's verdict.

## 1 The choice

| | Tool | Why this one |
|---|---|---|
| **Reviews a skill** | superpowers `writing-skills`, its `anthropic-best-practices.md` checklist applied statically | The only candidate that reads the body at all. 17 findings on one skill, no model run |
| **Writes a skill** | `skill-creator` | The only candidate with intent capture, a description optimiser and an eval scaffold. It drafts into `templates/SKILL.md` |
| **Mechanical pre-pass, both paths** | `skill-creator`'s `scripts/quick_validate.py` | The only candidate that found a real defect — [#338](https://github.com/Calyx-Engineering/arc/issues/338). Free, and it exits non-zero |
| **Precondition, not a review** | `claude plugin validate skills --strict` | Exit 0 on all thirteen, including an 852-line skill and five whose frontmatter a conformant YAML parser rejects |
| **Unavailable** | `claude plugin eval` | `` `plugin eval` is currently in early access ``, exit 1 — [#181](https://github.com/Calyx-Engineering/arc/issues/181) |
| **Not a reviewer** | `/skill-doctor` | Built in, `supportsNonInteractive`. Its own description is *"Show which loaded skills are unused and costing context"* — a session usage report, not a reading of a skill |

**`writing-skills` is adopted as a checklist, not as its method.** Its spine is the Iron Law —
*"NO SKILL WITHOUT A FAILING TEST FIRST… This applies to NEW skills AND EDITS to existing
skills. Write skill before testing? Delete it. Start over."* Thirteen exercised skills cannot be
deleted and re-derived, and [#90](https://github.com/Calyx-Engineering/arc/issues/90) says so
twice — *Edit in place* and *No rule is lost*. What is adopted is the closing checklist, which
is a document; what is not adopted is the cycle that produces it.

**Neither tool has a notion of a deliberate deviation.** That is the gap §4 fills.

## 2 The trial

Both arms read the same target whole, and neither was permitted to edit.

| | `writing-skills` | `skill-creator` |
|---|---|---|
| **Findings on one skill** | **17** | **6** |
| **Cost of applying it** | Two markdown files, read and applied by hand | `quick_validate.py` only. Everything past frontmatter needs a model run or a human |
| **Reads the body** | **Yes** — word count, redundancy, reference depth, missing worked example, verification-step shape | **No.** `quick_validate.py` is 3.9 KB of frontmatter schema checking and reads nothing below the `---` |
| **What it cannot do without a run** | Its own mandated procedure: RED baseline, 5-rep micro-tests, pressure scenarios, Haiku/Sonnet/Opus | §Test Cases, all five steps of §Running and evaluating, §Description Optimization, §Blind comparison |
| **What it needs a human for** | Nothing, statically | §Capture Intent's four questions, §Interview and Research, the test-prompt sign-off, `feedback.json` — the loop terminates when *"the user says they're happy"* |
| **What the arm concluded about its shape** | A build gate to be walked before deployment, not a lens for judging wording already in place — the instrument says *"Create a todo for EACH checklist item below"* | The only path it offers for an existing skill is its own *"go straight to the eval/iterate part of the loop"*, which presupposes a rewrite |

**17 is not better than 6.** Several of the seventeen are Arc conventions, not defects — the
dated provenance line in `record-route` is `*Verify before asserting*` doing its job, and the
reconciliation section is the record of two vocabularies being merged. A checklist with no
notion of a deliberate deviation reports both as narrative storytelling. That is why the
reviewer's output is a proposal and never an edit.

**The one finding that was decisive was mechanical and free.** `quick_validate.py` exited 1 on
`record-route` with `Invalid YAML in frontmatter: mapping values are not allowed here`, which
`claude plugin validate skills --strict` passes. Confirmed independently against every skill with
`yaml.safe_load`: five of thirteen do not parse. That is
[#338](https://github.com/Calyx-Engineering/arc/issues/338).

### 2.1 The trap in the precondition

`claude plugin validate .` at the repo root prints **`✔ Validation passed`** having validated
`.claude-plugin/marketplace.json` and not one skill. The skills are only reached by naming the
directory:

```
$ claude plugin validate .                 # Validating marketplace manifest: …  ✔ passed
$ claude plugin validate skills --strict   # Validating components in: …/skills  ✔ passed
```

**The command is `claude plugin validate skills --strict`.** The first form is the one a session
reaches for, and it is the one that checks nothing.

### 2.2 The reviewer's 17 findings, routed

The worked example. Every finding the reviewing arm returned on `record-route`, grouped, with the
bucket §4 sends it to. **Seven of the seventeen are D** — the largest single class, and the number
that justifies §4.1 existing.

| Finding class | n | Bucket | Note |
|---|---|---|---|
| Description summarises the workflow; description over 500 characters | 2 | **D** | [#155](https://github.com/Calyx-Engineering/arc/issues/155) measured both into existence |
| Narrative storytelling — a named stub, a dated scope reading, a vocabulary reconciliation | 3 | **D** | `CLAUDE.md`'s *Verify before asserting*. The measurement is the rule's evidence |
| Name is not verb-first or a gerund | 1 | **D** | Installed under this name and resolved by it |
| Non-spec frontmatter keys | 1 | **C** | Already filed — [#338](https://github.com/Calyx-Engineering/arc/issues/338) |
| No `## Overview`, no *When to use* | 1 | **J** | Structure. A judgement about what this skill's reader needs |
| No *Common mistakes* section, no red-flags list | 1 | **J** | Same |
| Inconsistent placeholder — `issue-<N>` against `issue-<NN>` | 1 | **C** | One grep. `tests/verify-dev-log-name.sh` is next door |
| The dev-log naming rule stated three times | 1 | **C** | Redundancy across a file is countable |
| References climb two levels out of the skill directory | 1 | **C** | Path depth is decidable from the tree |
| `tools/new-direct-pr.sh` cited with no execution intent | 1 | **J** | Run it or read it — the skill has to say which |
| Verification step is prose with no command | 1 | **C** | A named command, or nothing to run |
| No worked example anywhere | 1 | **J** | What a good example is here is a judgement |
| No evaluations, no baseline, no micro-test | 1 | **E** | The Iron Law, which §1 does not adopt. Routes to the mechanism doc as a known hole |
| Body is 2,016 words | 1 | **D** | The word budget §3 rejects. The arm reported 2,150, which is the file — the same conflation §3 warns about |

**7 D, 5 C, 4 J, 1 E.** Four findings out of seventeen are judgement that belongs in the skill and
one is evidence; the other twelve either route out of it or were already decided. That is the shape
[#277](https://github.com/Calyx-Engineering/arc/issues/277)–[#281](https://github.com/Calyx-Engineering/arc/issues/281)
should expect — **a static reviewer's largest output class on an Arc skill is house style**, which
is why §4.1 is read before §1.

### 2.3 The writing arm's 6 findings

The other half of the comparison, so 17 against 6 is auditable rather than asserted. **Only the
first is reproducible without a model or a person** — which is the whole reason this arm is the
writer and not the reviewer.

| Finding | Bucket | Reproducible |
|---|---|---|
| Frontmatter is not parseable YAML — a `: ` inside an unquoted `description` | **C** | **Yes** — `python quick_validate.py skills/record-route`, exit 1 |
| Three frontmatter keys outside the spec's allowed set | **C** | **Yes** — same run |
| No `evals/evals.json`; the instrument treats test cases as part of the artifact | **E** | No |
| No `scripts/` despite prescribing a repeated mechanical procedure | **C** | No |
| `tools/new-direct-pr.sh` cited with no `compatibility` declaring the dependency | **J** | No |
| Description is not "pushy" in the instrument's sense | **D** | No — [#155](https://github.com/Calyx-Engineering/arc/issues/155) settled the wording by measurement |

**`quick_validate.py` reports at most one finding per run** — it returns on the first failure — so
the first two rows are one invocation each. The remaining four came from the arm reading the
instrument and the target, which is a model run; nothing in the tree derives them.

## 3 The length limit

**500 lines** of SKILL.md **body**, frontmatter excluded —
`anthropic-best-practices.md`'s *"Keep SKILL.md body under 500 lines for optimal performance"*
and its closing checklist's *"SKILL.md body is under 500 lines"*.

**The 180-line working limit is retired.** It was never in a live artifact — it survived only in
the dev-logs for [#42](https://github.com/Calyx-Engineering/arc/issues/42) and
[#73](https://github.com/Calyx-Engineering/arc/issues/73), where it records what was true when
they were written and stays. There is nothing to delete, so the retirement is this section plus
`tests/verify-skill-method.sh`, which fails if a live artifact ties a limit to 180 again.

**Every count here moves as the skills are edited, and one already did** — `issue-write` gained 30
lines mid-run from a merge into the base, so a reader who finds a number below stale should
re-measure rather than trust it. Two commands, and they answer different questions:

```sh
bash tools/verify-skill-length.sh   # the verdict: which skills are over, counting the FILE
awk 'f{n++} /^---$/{c++; if(c==2) f=1} END{print FILENAME, n}' skills/*/SKILL.md  # body lines, all 13
```

The §3 table is the second command's answer on 2026-09-13. The gate is the first, and it prints
only the skills it finds over — never the eleven it passes.

| | Body lines | |
|---|---|---|
| `issue-write` | **852** | over |
| `work-watch` | **600** | over |
| `chat-response` | 453 | |
| `engineering-report` | 422 | |
| `handoff` | 398 | |
| `spec-interview` | 370 | |
| `camp` | 336 | |
| `plugin-retrospective` | 228 | |
| `autonomy-set` | 227 | |
| `record-route` | 213 | |
| `arc-intent` | 183 | |
| `relief-valve` | 167 | |
| `decompose` | 161 | |
| **13 skills** | **4,610** | two over |

**Lines, not words.** `writing-skills`' own SKILL.md carries a second budget — *"Other skills:
<500 words"* — which puts **all thirteen** over, the smallest being `relief-valve` at 1,171
words. That is scope reduction, not compression.
Anthropic's number is lines; Arc takes Anthropic's number.

**Measured as body, not as file.** `skills/issue-write/SKILL.md` is 866 lines; its body is 852.
The 14-line difference is a description tuned for firing
([#155](https://github.com/Calyx-Engineering/arc/issues/155)), and a limit that counts it charges
a skill for being findable.

**The gate that shipped counts the file** — `tools/verify-skill-length.sh`
([#276](https://github.com/Calyx-Engineering/arc/issues/276)) reports 866 and 608. It is stricter
than the rule by the length of the description, and today's verdict is the same on either count,
so it names no skill wrongly yet. It misreports a skill between 500 body lines and 500 file
lines. Its header reasons about `awk` against `wc -l` and not about frontmatter, so the
divergence is unexamined rather than deliberate —
[#341](https://github.com/Calyx-Engineering/arc/issues/341).

## 4 The question every review answers

**For each skill: which of its rules would a hook, script or template carry more cheaply?** Four
buckets, and every rule lands in exactly one.

| | Bucket | Where it goes |
|---|---|---|
| **J** | **Judgement** — needs a reading of the situation | Stays in the skill |
| **E** | **Evidence** — why the rule exists, what disproved the alternative | Moves to the mechanism doc, cited from the skill in one clause |
| **C** | **Checkable** — decidable from the tree, the payload or a `gh` read | Moves to a hook, script or template. The skill keeps one line naming the carrier |
| **D** | **Deviation** — the reviewer flagged it and Arc keeps it anyway | Recorded once here, in §4.1. Never re-litigated per skill |

**The input is already written.** Ten of thirteen skills declare a `checks:` list in
frontmatter — 67 entries. That list is the review's starting set for bucket **C**, not something
to re-derive by reading 4,610 lines. Three skills declare none: `chat-response`,
`plugin-retrospective`, `spec-interview`.

**The output shape is fixed**, so five review issues produce one comparable table: one row per
`checks:` entry, with its bucket, its carrier, and `none` where there is no carrier. A review
that returns prose cannot be read across skills.

### 4.1 Deviations Arc keeps

Findings from the trial that are house style, so no review re-opens them.

| Flagged as | Kept because |
|---|---|
| Narrative storytelling — a dated incident, a named failure | `CLAUDE.md`'s *Verify before asserting*. The date and the measurement are what make a rule checkable against reality rather than remembered |
| A description that summarises the workflow | [#155](https://github.com/Calyx-Engineering/arc/issues/155) measured firing on thirteen real turns. The trigger clause holds the user's words because that is what fired |
| A description over 500 characters | Same. The alternative was measured and did not fire |
| Non-spec frontmatter keys | `checks:`, `skips:` and `camp-reports:` are read by anything that declares what it checks. **Their spelling is not a deviation** — [#338](https://github.com/Calyx-Engineering/arc/issues/338) settles whether they move under `metadata:` |
| A name that is not a gerund | Thirteen skills are installed under these names and `hooks/` resolve them by name. A rename is a breaking change with no measured payoff |

### 4.2 Where a carrier already exists

Scoping-level triage: which hooks and scripts name each skill today. **The reviews confirm or
correct this; it is a starting point, not a verdict.** `verify-all.sh` and `plugin-reload.sh` are
excluded — they name most artifacts and carry no rule.

| Skill | Hooks | Scripts | First question for its review |
|---|---|---|---|
| `camp` | **7** | 19 | The most-carried skill in the tree. What is left in it that is not judgement? |
| `handoff` | **3** | 23 | 14 `checks:` and 13 `skips:`. Is the skip table itself a script's job? |
| `issue-write` | **2** | 4 | 852 body lines against `tracker-verify`, which already enforces much of it — which of its 11 `checks:` are duplicated? |
| `chat-response` | — | 7 | No `checks:` declared, and `response-length.py` already scores it. What rule does the skill hold that the scorer does not? |
| `work-watch` | — | 3 | 600 body lines, 8 `checks:`, no hook. Eight watches in one file — is that one skill? |
| `engineering-report` | — | 3 | `verify-report-budget.sh` and `report-grade.py` exist. Which of its 3 `checks:` is not already scored? |
| `decompose` | — | 2 | 8 `checks:` in 161 lines. The smallest skill — is anything checkable left in it? |
| `autonomy-set` | — | 1 | `mode-guard` enforces the mode and the skill sets it. Is that boundary clean, or duplicated? |
| `relief-valve` | — | 1 | 5 `checks:`, every one a counter over the transcript. **All five look like bucket C** |
| `record-route` | — | — | `verify-dev-log-name.sh` checks its `dev-log-exists` rule without naming it. Is the link missing, or the check? |
| `arc-intent` | — | — | 4 `checks:` and nothing carrying any of them |
| `spec-interview` | — | — | 370 lines, no `checks:`, no carrier. Is it all judgement, or has nothing been named? |
| `plugin-retrospective` | — | — | No `checks:`, no carrier. `agents/transcript-miner` names this skill's step 1 and the skill does not name the agent — **an agent is a carrier the four buckets do not name, and this edge is written from one end only** |

**Four skills have no carrier at all** — `record-route`, `arc-intent`, `spec-interview`,
`plugin-retrospective`. Two of them, `spec-interview` and `plugin-retrospective`, also declare no
`checks:`: nothing was ever named, so nothing could have been moved. The other two named four
rules each and no artifact took them, which is the more interesting half.

## 5 The keeper

**`hooks/skill-guard`** — fires on any write to `skills/*/SKILL.md`, reports, never blocks. Named
here; built by [#282](https://github.com/Calyx-Engineering/arc/issues/282).

| It reports | Source |
|---|---|
| Line count against **500 lines** | `tools/verify-skill-length.sh` — [#276](https://github.com/Calyx-Engineering/arc/issues/276). It counts the file today; the limit is the body, so the hook reports whichever the script reports until [#341](https://github.com/Calyx-Engineering/arc/issues/341) lands |
| Frontmatter that does not parse, or carries an unexpected key | `quick_validate.py`, per §1 — [#338](https://github.com/Calyx-Engineering/arc/issues/338) |
| The review tool, by name and command | §1. A rule in prose has no trigger |

**A hook, because the trigger is the write.** Two of the three below hold the decision today; the
hook is the third and lands with [#282](https://github.com/Calyx-Engineering/arc/issues/282).
The limit was written down and read by nothing, and
eleven of thirteen skills sat over the old number for weeks. Three artifacts hold it now, and
each has a trigger:

| | Fires | Covers |
|---|---|---|
| `hooks/skill-guard` | on the write | the skill being changed, in the session changing it |
| `tools/verify-skill-length.sh` | in `verify-all.sh` | the whole tree, at PR time |
| `tests/verify-skill-method.sh` | in `verify-all.sh` | that this decision is still recorded, and that 180 has not come back |

**`/skill-doctor` is the fourth, and it is a human's.** It answers which loaded skills are
costing context and going unused — the question this arc will ask once the reviews have cut the
tree down. It is not wired to anything, on purpose: it reads one session, and a session is not
the repository.
