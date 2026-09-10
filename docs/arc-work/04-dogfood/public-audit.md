# Public audit — what a copy of this repository exposes

**Swept:** 2026-09-10 · **Instrument:** [`tools/audit-public.sh`](../../../tools/audit-public.sh) ·
**1,717 hits**, of which 1,139 are this repository's own tracker links and 578 need a decision.

**Nothing is changed by this document.** It is an inventory with a proposed disposition per hit.
A second run applies the list once the `ask` rows are settled.

---

## 1 The decisions

**Seven.** D1 to D6 answer a box in [#134](https://github.com/Calyx-Engineering/arc/issues/134)'s
`Required`; **D7 is the caveat on all six** and has no box of its own. D4 is yours to settle.

| | Decision | Recommendation |
| :--- | :--- | :--- |
| **D1** | What `docs/` ships | §1.1 — fourteen rows: nine ship (seven after anonymising), four move, one `ask` |
| **D2** | `docs/retrospectives/` | Ships. Anonymise the names inside it; three profanity quotes are `ask` |
| **D3** | `docs/reference-roadz/` | **Move.** A directory named for a client, holding its verbatim material |
| **D4** | The licence | **Add a `LICENSE` file — proprietary, all rights reserved, Calyx Engineering.** Keep `UNLICENSED` in both manifests. §1.2 |
| **D5** | The install route without a local directory marketplace | **Already documented and already works** — the GitHub marketplace route. §1.3 |
| **D6** | Whether transcript, log and friction-log content ships | **It does.** 124 files in `evals/`, and five more elsewhere. §1.4 |
| **D7** | The sweep's blind spots | Described work carries no token, and three classes are literal lists. §1.5 |

### 1.1 What `docs/` ships

**Fourteen rows. Eleven are directories; three are single files that their directory's row does
not cover.**

| Directory or file | Disposition | Why |
| :--- | :--- | :--- |
| [`docs/product-architecture/`](../../product-architecture/) | ship, after `anonymise` | The mechanism specs are the product's reasoning. Each keeps its finding and loses the client name that produced it |
| [`docs/product-architecture/archive/`](../../product-architecture/archive/) | **move** | 35 hits — the densest client reference outside `reference-roadz`, and a frozen record with no consumer value |
| [`docs/suite-architecture/`](../../suite-architecture/) | ship, after `anonymise` | Three rows on two lines — the plugin line's own name, and one client wiki page named in the persona |
| [`docs/dev-log/`](../../dev-log/) | ship, after `anonymise` | Arc's own per-unit record. A consumer reads it to learn why a mechanism is shaped as it is |
| [`docs/arc-log/`](../../arc-log/) | ship, after `anonymise` | Same |
| [`docs/arc-log/events/`](../../arc-log/events/) | **ship as is** | 63,231 lines of machine telemetry. Zero hits in every class except one link in its own header |
| [`docs/arc-work/`](../) | ship, after `anonymise` | Per-arc working notes. Three exceptions below |
| `docs/arc-work/03-camp/friction-log.md` | **move** | Friction-log content — the thing D6's box asks be absent |
| `docs/arc-work/04-dogfood/handoff-baseline.md` | **ask** | Verbatim transcript turns with wall-clock timestamps, quoted at length |
| `docs/arc-work/04-dogfood/public-audit.md` | **move** | This document. §2.1 |
| [`docs/reference-roadz/`](../../reference-roadz/) | **move** | D3 |
| [`docs/reference-timescope/`](../../reference-timescope/) | ship, after `anonymise` | The user's own system — out of scope per the issue. Its one row is the machine path it was copied from, which is not TimeScope's |
| [`docs/retrospectives/`](../../retrospectives/) | ship, after `anonymise` | D2 |
| [`docs/release/`](../../release/) | ship | Two rows, both the install command naming the publisher |

### 1.2 The licence

`UNLICENSED` sits in [`.claude-plugin/plugin.json`](../../../.claude-plugin/plugin.json) and
[`.claude-plugin/marketplace.json`](../../../.claude-plugin/marketplace.json). There is **no
`LICENSE` file**.

**The risk a licence answers here is not redistribution.** It is that installing Arc on a machine
owned by another employer, and improving it there, invites a work-for-hire claim over the
improvements. A file at the repository root naming the copyright holder and the date is what
answers that, and it costs one file.

| | |
| :--- | :--- |
| **Recommended** | `LICENSE` — proprietary, all rights reserved, `Copyright © 2026 Calyx Engineering`. Manifests keep `UNLICENSED`, which is the correct manifest value for exactly this |
| **Not recommended now** | MIT or Apache-2.0. Both are grants to the world, and the stated bar is *usable at another employer*, not a public product launch. Either remains available later; neither is reversible for a version already published |

**This is D4 and it is yours to settle.** Nothing else in the audit depends on it.

### 1.3 The install route

[`README.md`](../../../README.md) already documents two routes, and the second is the answer:

```text
/plugin marketplace add Calyx-Engineering/arc
/plugin install arc@calyx-engineering
```

**It needs no local directory.** It needs the repository reachable from that machine and
`gh auth setup-git` run once, both of which the README already states. Nothing to build.

**What is untested** is whether a work machine permits a personal GitHub credential at all. If it
does not, the remaining route is a public repository — which is D4's question, not this one.

### 1.4 Transcript, log and friction-log content — it ships

| What | Count | Where |
| :--- | :--- | :--- |
| Verbatim conversation turns | 97 files | `evals/*/*/turns/*.md` |
| Verbatim user prompts | 18 files | `evals/*/*/prompt.md` |
| Verbatim client report excerpts | 6 files | `evals/report-shape/*/excerpt.md` |
| Model replies | 3 files | `evals/response-length/*/replies/*` |
| Friction logs | 2 files | `docs/retrospectives/2026-08-plugin-line/friction-transcript-log.md` · `docs/arc-work/03-camp/friction-log.md` |
| Quoted turns with timestamps | 2 files | `docs/arc-work/04-dogfood/handoff-baseline.md` · `docs/retrospectives/2026-09-dogfood/README.md` |
| A transcript index keyed to machine paths | 1 file | `.claude/arc/sessions.md` |
| The committed event log | 1 file | `docs/arc-log/events/arc-03-camp.log.md` — **clean**, machine telemetry only |

**The eval corpus is the problem, and it is also the instruments.**
[`tools/report-grade.sh`](../../../tools/report-grade.sh),
[`tools/response-length.sh`](../../../tools/response-length.sh),
[`tools/saturation-cases.sh`](../../../tools/saturation-cases.sh) and
[`tools/environment-blame.sh`](../../../tools/environment-blame.sh) score against it. Deleting it
removes four measurements; the sweep's default of `anonymise` cannot be applied to a pinout
discussion without destroying what it measures.

**So the three client-content suites move rather than anonymise** — `report-shape`, `saturation`,
`environment-blame`, 61 hits — into a corpus directory outside the published repository.
`report-grade.sh` already reads `REPORT_CORPUS_DIR`; the other three need the same. The
`skill-firing` and `response-length` prompts stay and get `anonymise`, because their client
content is a directory slug and one name.

### 1.5 What the sweep cannot see

**Two blind spots, and the second is the larger.**

| | |
| :--- | :--- |
| **Described work carries no token** | `docs/arc-work/04-dogfood/handoff-rationale.md:31` says *"A DC-ramp capacitance rig was designed four minutes later for a setup that measures inductance"* — a real bench session at a real client, and nothing in it is a name |
| **Three classes are literal lists, so each is as complete as its last editor** | `person` is two names, `employer` is one, `client-hw` is a fixed part list. Review pass 1 found `heliman` — a second GitHub identity, reported only as `calyx-name` and taking `ship` — and the hyphenated `interface-pcba`, which carries the board name on 53 lines, 39 of them invisible to the space-only pattern. Both are in the table now. **They were found by reading, and the next one will be too** |

**Treat the 578 rows as a floor, not a total.** A file whose disposition is `move` is safe either
way; a file dispositioned `ship` or `anonymise` still wants one human read before publication.

---

## 2 The disposition rules

**Four dispositions, and `delete` is not one of them** — the issue's default is `anonymise`, and
nothing is deleted where anonymising keeps the evidence.

| | Means |
| :--- | :--- |
| `ship` | Fine as is |
| `anonymise` | Replaced with a neutral stand-in — *a client*, *the client repo*, *project A* — keeping the sentence's meaning |
| `move` | To a place that does not ship |
| `ask` | The user decides |

**Every row's disposition comes from the first rule it matches**, so a rule id in the table below
is the whole reason a row reads as it does.

| Rule | Path | Class | Disposition | Why |
| :--- | :--- | :--- | :--- | :--- |
| **R1** | `docs/reference-roadz/` | any | `move` | A directory named for a client, holding its verbatim material |
| **R2** | `docs/product-architecture/archive/` | any | `move` | A frozen record, and the densest client reference left |
| **R3** | `.claude/arc/sessions.md` | any | `move` | Machine-local session state. The live event log is already gitignored for this reason |
| **R4** | `docs/arc-work/03-camp/friction-log.md` | any | `move` | Friction-log content |
| **R5** | `evals/{report-shape,saturation,environment-blame}/` | any | `move` | Real client reports and pinouts. §1.4 |
| **R6** | `docs/arc-work/04-dogfood/handoff-baseline.md` | any | `ask` | Verbatim transcript turns with timestamps — whether excerpting counts as shipping them is yours |
| **R7** | `docs/retrospectives/` | `profanity` | `ask` | The quote is the evidence, and masking a quote changes it |
| **R8** | `docs/retrospectives/` | any | `anonymise` | The issue's own out-of-scope row: the content is processed and fine, the names are not |
| **R9** | `agents/transcript-miner.md` | `profanity` | `ship` | A detector vocabulary. The word is a search term, not speech |
| **R10** | any | `calyx-url` | `ship` | 1,139 links to this repository's own tracker. Decided once, here, and not enumerated. **No row cites it** — the bulk class is never listed, so the rule stands alone |
| **R11** | any | `calyx-name` | `ship` | The publisher's identity. `arc@calyx-engineering` is the install command |
| **R12** | `tools/hook-cases/`, `tests/`, `hooks/`, `tools/handoff-openings.sh`, `skills/issue-write/` | `local-path` | `ship` | The literal path form is what the case tests or the example warns about |
| **R13** | any | `local-path` | `anonymise` | |
| **R14** | any | `profanity` | `anonymise` | Masked, not cut |
| **R15** | any | `person` | `anonymise` | |
| **R16** | any | `employer` | `anonymise` | |
| **R17** | any | `lantern`, `roadz`, `client-hw` | `anonymise` | The finding survives a neutral stand-in — the issue's own constraint |
| **R18** | any | any | `ask` | The fallback. **It matched nothing**, which is the check that the rules above are complete |

### 2.1 The three files the sweep cannot report on

**Each holds the terms in order to do its job, so each excludes itself — and each is exposure
anyway.** An exclusion is a limit on the instrument, never a decision that a file is safe. These
three get their disposition here, by hand, because nothing will ever give them a row.

| File | What it holds | Disposition |
| :--- | :--- | :--- |
| [`tools/audit-public.sh`](../../../tools/audit-public.sh) | The class table is a **dictionary of a real client's parts** — `whelen`, `rut241`, `lcphoto`, `rp2040`, `interface-pcba` — plus `R:\work_lantern\roadz-sound-system` in two comments and the selftest fixtures | **anonymise.** Move the term list to an untracked patterns file the script reads, so the instrument ships and the dictionary does not. The fixtures take neutral stand-ins |
| [`tests/verify-public-audit.sh`](../../../tests/verify-public-audit.sh) | Six mentions: **one** comment naming the real filename that broke its parser, and five inside the fixture document its selftest builds | **anonymise**, and two different fixes. The comment's point is the *shape* — a path with spaces, a row quoting a table — not the client. The fixture rows just need neutral stand-ins |
| **This document** | Quotes every hit verbatim: 113 lines holding `lantern`, 344 holding `roadz`, 15 holding `chad`, plus the machine paths, the part numbers and the profanity | **move.** It is the list of what to fix. Once the second run has applied it, it is history, and it belongs wherever the moved material goes |

**`docs/arc-work/` at §1.1 says *ship, after anonymise*, and this file is one of its three
exceptions.** Without this section it would ship as the densest single concentration of client names in
the repository.

### 2.2 Regenerating this

```bash
bash tools/audit-public.sh              # the hit list
bash tools/audit-public.sh --summary    # counts by class, then by file
bash tools/audit-public.sh --all        # the 1,139 tracker links too
bash tools/audit-public.sh --markdown   # §4's table, disposition column empty
```

**`--markdown` leaves the disposition column empty on purpose.** The instrument reports what is
there; which hit ships is a decision, and a regeneration that filled the column would silently
overwrite one. [`tests/verify-public-audit.sh`](../../../tests/verify-public-audit.sh) checks this
document against **itself** — the header claim, the rules, the summary and the rows, four views of
one dataset — and says when they have drifted apart. **Nothing checks it against the tree.** That
is the sweep, and it is a pre-publication step because it takes seventy seconds and its answer
moves with every commit.

---

## 3 Summary by file

| File | Hits | Dispositions |
| :--- | ---: | :--- |
| `docs/product-architecture/archive/responsibility-decomposition.md` | 23 | move 23 |
| `.claude/arc/sessions.md` | 21 | move 21 |
| `tools/miner-scope.sh` | 21 | anonymise 21 |
| `docs/arc-work/04-dogfood/handoff-baseline.md` | 18 | ask 18 |
| `docs/dev-log/issue-134-public-audit.md` | 17 | ship 4 · anonymise 13 |
| `docs/reference-roadz/ROADZ Interface PCBA Revision Workflow.md` | 17 | move 17 |
| `docs/retrospectives/2026-08-plugin-line/friction-transcript-log.md` | 17 | anonymise 16 · ask 1 |
| `docs/product-architecture/mechanisms/m12-issue-linking.md` | 16 | anonymise 16 |
| `docs/retrospectives/2026-09-dogfood/README.md` | 16 | anonymise 14 · ask 2 |
| `evals/report-shape/pin-allocation-ledger/excerpt.md` | 16 | move 16 |
| `docs/product-architecture/mechanisms/m16-hardware-record-structure.md` | 14 | anonymise 14 |
| `docs/dev-log/issue-162-branch-convention.md` | 12 | anonymise 12 |
| `docs/dev-log/issue-211-plugin-reload-dirty-tree.md` | 11 | ship 8 · anonymise 3 |
| `evals/report-shape/cellular-recommendation-first/excerpt.md` | 10 | move 10 |
| `tools/report-grade.sh` | 9 | anonymise 9 |
| `docs/arc-log/arc-04-dogfood.md` | 8 | anonymise 8 |
| `evals/report-shape/light-dimming-findings-first/excerpt.md` | 8 | move 8 |
| `docs/dev-log/issue-138-merge-route.md` | 7 | anonymise 7 |
| `docs/dev-log/issue-160-topic-numbering.md` | 7 | ship 3 · anonymise 4 |
| `docs/product-architecture/archive/what-the-tools-do.md` | 7 | move 7 |
| `docs/product-architecture/mechanisms/m09-kickoff-scope-gate.md` | 7 | anonymise 7 |
| `docs/product-architecture/mechanisms/m23-test-obligation-capture.md` | 7 | anonymise 7 |
| `docs/product-architecture/mechanisms/m31-self-improvement-loop.md` | 7 | ship 2 · anonymise 5 |
| `docs/product-architecture/mechanisms/m32-session-preservation.md` | 7 | anonymise 7 |
| `evals/report-shape/poe-pse-question-first/excerpt.md` | 7 | move 7 |
| `docs/dev-log/issue-16-session-index.md` | 6 | anonymise 6 |
| `docs/dev-log/issue-164-claim-provenance.md` | 6 | anonymise 6 |
| `docs/reference-roadz/README.md` | 6 | move 6 |
| `docs/arc-work/04-dogfood/skill-firing-baseline.md` | 5 | anonymise 5 |
| `docs/dev-log/issue-252-probe-handoff.md` | 5 | ship 2 · anonymise 3 |
| `hooks/camp-branch-check` | 5 | ship 1 · anonymise 4 |
| `tests/verify-session-index.sh` | 5 | ship 4 · anonymise 1 |
| `.claude-plugin/marketplace.json` | 4 | ship 4 |
| `docs/dev-log/issue-253-live-cold-start.md` | 4 | anonymise 4 |
| `docs/product-architecture/mechanisms/m13-issue-write-back.md` | 4 | anonymise 4 |
| `docs/product-architecture/mechanisms/m15-handoff-spine.md` | 4 | anonymise 4 |
| `docs/product-architecture/mechanisms/m22-configuration-management.md` | 4 | anonymise 4 |
| `docs/product-architecture/mechanisms/m28-human-gate.md` | 4 | anonymise 4 |
| `docs/product-architecture/mechanisms/m30-transcript-mining.md` | 4 | anonymise 4 |
| `evals/saturation/issue-39-pinout-context-full/turns/2.md` | 4 | move 4 |
| `evals/skill-firing/situation/copy-transcript-opening/prompt.md` | 4 | anonymise 4 |
| `hooks/session-index` | 4 | ship 2 · anonymise 2 |
| `tools/hook-cases/camp-branch-check/pass/roadz-issue-slug-digits.json` | 4 | anonymise 4 |
| `tools/plugin-reload.sh` | 4 | ship 3 · anonymise 1 |
| `README.md` | 3 | ship 2 · anonymise 1 |
| `agents/transcript-miner.md` | 3 | ship 1 · anonymise 2 |
| `docs/arc-work/04-dogfood/handoff-rationale.md` | 3 | anonymise 3 |
| `docs/arc-work/04-dogfood/issue-plan.md` | 3 | anonymise 3 |
| `docs/dev-log/issue-141-miner-scope.md` | 3 | anonymise 3 |
| `docs/dev-log/issue-158-length-budget.md` | 3 | ship 1 · anonymise 2 |
| `docs/dev-log/issue-266-provenance-vocabulary.md` | 3 | anonymise 3 |
| `docs/dev-log/issue-32-size-the-title.md` | 3 | anonymise 3 |
| `docs/product-architecture/archive/HANDOFF.md` | 3 | move 3 |
| `docs/product-architecture/mechanisms/m14-commit-rhythm.md` | 3 | ship 1 · anonymise 2 |
| `docs/product-architecture/mechanisms/m29-agent-wiki.md` | 3 | anonymise 3 |
| `docs/product-architecture/mechanisms/m40-autonomy-switch.md` | 3 | anonymise 3 |
| `evals/environment-blame/issue-68-gain-sweep-bench-blame/turns/39.md` | 3 | move 3 |
| `evals/saturation/issue-39-pinout-context-full/turns/1.md` | 3 | move 3 |
| `evals/saturation/issue-39-pinout-context-full/turns/3.md` | 3 | move 3 |
| `evals/skill-firing/situation/log-this-in-friction-log/prompt.md` | 3 | anonymise 3 |
| `evals/skill-firing/wrapped/handoff-then-order-60-words/prompt.md` | 3 | anonymise 3 |
| `evals/skill-firing/wrapped/handoff-updated-elsewhere/prompt.md` | 3 | anonymise 3 |
| `tools/handoff-openings.sh` | 3 | ship 3 |
| `tools/hook-cases/camp-branch-check/fixtures/roadz/CLAUDE.md` | 3 | anonymise 3 |
| `tools/hook-cases/camp-branch-check/pass/declared-integration-branch.json` | 3 | anonymise 3 |
| `tools/hook-cases/camp-branch-check/pass/roadz-issue-hyphen.json` | 3 | anonymise 3 |
| `tools/hook-cases/camp-branch-check/pass/roadz-issue-underscore.json` | 3 | anonymise 3 |
| `tools/hook-cases/camp-branch-check/pass/roadz-pr-branch.json` | 3 | anonymise 3 |
| `tools/hook-cases/camp-branch-check/pass/roadz-pr-sweep.json` | 3 | anonymise 3 |
| `tools/hook-cases/camp-branch-check/report/roadz-no-number.json` | 3 | anonymise 3 |
| `docs/arc-work/02-foundation/closing-keywords-and-base-branch.md` | 2 | anonymise 2 |
| `docs/dev-log/issue-140-read-back.md` | 2 | anonymise 2 |
| `docs/dev-log/issue-17-transcript-miner.md` | 2 | anonymise 2 |
| `docs/dev-log/issue-48-skill-parity.md` | 2 | anonymise 2 |
| `docs/product-architecture/archive/product-plan.md` | 2 | move 2 |
| `docs/product-architecture/mechanisms/m10-branch-guard.md` | 2 | anonymise 2 |
| `docs/product-architecture/mechanisms/m17-k1-upkeep.md` | 2 | anonymise 2 |
| `docs/product-architecture/mechanisms/m21-arc-tree.md` | 2 | anonymise 2 |
| `docs/product-architecture/mechanisms/m41-relief-valve.md` | 2 | anonymise 2 |
| `docs/release/release-process.md` | 2 | ship 2 |
| `docs/suite-architecture/domain-engineer-persona.md` | 2 | anonymise 2 |
| `evals/report-shape/pin-allocation-ledger/case.yaml` | 2 | move 2 |
| `evals/saturation/issue-39-pinout-context-full/turns/11.md` | 2 | move 2 |
| `evals/saturation/issue-39-pinout-context-full/turns/31.md` | 2 | move 2 |
| `evals/saturation/issue-39-pinout-context-full/turns/49.md` | 2 | move 2 |
| `evals/skill-firing/wrapped/handoff-then-do-these-in-order/prompt.md` | 2 | anonymise 2 |
| `skills/issue-write/SKILL.md` | 2 | ship 1 · anonymise 1 |
| `skills/plugin-retrospective/SKILL.md` | 2 | ship 2 |
| `skills/record-route/SKILL.md` | 2 | anonymise 2 |
| `templates/session-index.md` | 2 | anonymise 2 |
| `tools/probe-handoff-checks.sh` | 2 | ship 1 · anonymise 1 |
| `.claude-plugin/plugin.json` | 1 | ship 1 |
| `ROADMAP.md` | 1 | anonymise 1 |
| `docs/arc-log/arc-03-camp.md` | 1 | anonymise 1 |
| `docs/arc-work/03-camp/friction-log.md` | 1 | move 1 |
| `docs/dev-log/issue-132-plugin-reload.md` | 1 | ship 1 |
| `docs/dev-log/issue-135-related-table.md` | 1 | anonymise 1 |
| `docs/dev-log/issue-136-manual-linking.md` | 1 | anonymise 1 |
| `docs/dev-log/issue-14-work-watch.md` | 1 | anonymise 1 |
| `docs/dev-log/issue-142-skill-copies.md` | 1 | anonymise 1 |
| `docs/dev-log/issue-149-skill-firing.md` | 1 | anonymise 1 |
| `docs/dev-log/issue-152-archive-before-overwrite.md` | 1 | anonymise 1 |
| `docs/dev-log/issue-159-report-conclusion-first.md` | 1 | anonymise 1 |
| `docs/dev-log/issue-166-activation-log.md` | 1 | anonymise 1 |
| `docs/dev-log/issue-206-linked-branch-readback.md` | 1 | anonymise 1 |
| `docs/dev-log/issue-210-tracker-verify-trunk.md` | 1 | anonymise 1 |
| `docs/dev-log/issue-239-log-rotation.md` | 1 | anonymise 1 |
| `docs/dev-log/issue-259-numbering-headroom.md` | 1 | anonymise 1 |
| `docs/dev-log/issue-271-related-table.md` | 1 | anonymise 1 |
| `docs/dev-log/issue-272-no-repo-path.md` | 1 | anonymise 1 |
| `docs/dev-log/issue-85-issue-template.md` | 1 | anonymise 1 |
| `docs/dev-log/issue-87-guarded-write-back.md` | 1 | anonymise 1 |
| `docs/dev-log/pr-115-transcript-staleness.md` | 1 | anonymise 1 |
| `docs/dev-log/pr-200-run-and-dispatch-fixes.md` | 1 | anonymise 1 |
| `docs/product-architecture/README.md` | 1 | ship 1 |
| `docs/product-architecture/mechanisms/m20-arc-decomposition.md` | 1 | anonymise 1 |
| `docs/reference-roadz/issue-writing/references/github.md` | 1 | move 1 |
| `docs/reference-timescope/README.md` | 1 | anonymise 1 |
| `docs/suite-architecture/README.md` | 1 | ship 1 |
| `evals/environment-blame/issue-68-gain-sweep-bench-blame/turns/34.md` | 1 | move 1 |
| `evals/report-shape/cellular-recommendation-first/case.yaml` | 1 | move 1 |
| `evals/report-shape/cellular-recommendation-first/graders/provenance.md` | 1 | move 1 |
| `evals/report-shape/light-dimming-findings-first/case.yaml` | 1 | move 1 |
| `evals/report-shape/light-dimming-findings-first/graders/provenance.md` | 1 | move 1 |
| `evals/report-shape/pin-allocation-ledger/graders/provenance.md` | 1 | move 1 |
| `evals/report-shape/poe-class-conflict/case.yaml` | 1 | move 1 |
| `evals/report-shape/poe-class-conflict/graders/provenance.md` | 1 | move 1 |
| `evals/report-shape/poe-device-under-test/case.yaml` | 1 | move 1 |
| `evals/report-shape/poe-device-under-test/graders/provenance.md` | 1 | move 1 |
| `evals/report-shape/poe-pse-question-first/case.yaml` | 1 | move 1 |
| `evals/response-length/too-many-words-20-words/turns/12.md` | 1 | anonymise 1 |
| `evals/response-length/too-many-words-20-words/turns/19.md` | 1 | anonymise 1 |
| `evals/response-length/verbose-again-60-words/turns/73.md` | 1 | anonymise 1 |
| `evals/saturation/issue-39-pinout-context-full/turns/10.md` | 1 | move 1 |
| `evals/saturation/issue-39-pinout-context-full/turns/16.md` | 1 | move 1 |
| `evals/saturation/issue-39-pinout-context-full/turns/20.md` | 1 | move 1 |
| `evals/saturation/issue-39-pinout-context-full/turns/33.md` | 1 | move 1 |
| `evals/saturation/issue-39-pinout-context-full/turns/38.md` | 1 | move 1 |
| `evals/saturation/issue-39-pinout-context-full/turns/47.md` | 1 | move 1 |
| `evals/saturation/issue-39-pinout-context-full/turns/5.md` | 1 | move 1 |
| `evals/saturation/issue-39-pinout-context-full/turns/51.md` | 1 | move 1 |
| `evals/saturation/issue-39-pinout-context-full/turns/9.md` | 1 | move 1 |
| `evals/skill-firing/situation/push-work-ahead-of-40/prompt.md` | 1 | anonymise 1 |
| `evals/skill-firing/wrapped/handoff-if-it-exists-cold-review/prompt.md` | 1 | anonymise 1 |
| `hooks/handoff-archive` | 1 | ship 1 |
| `skills/autonomy-set/SKILL.md` | 1 | anonymise 1 |
| `skills/issue-write/references/github.md` | 1 | ship 1 |
| `skills/relief-valve/SKILL.md` | 1 | anonymise 1 |
| `tests/verify-autonomy.sh` | 1 | anonymise 1 |
| `tools/arc-loop.sh` | 1 | anonymise 1 |
| `tools/hook-cases/branch-guard/deny/main-windows-path.json` | 1 | ship 1 |
| `tools/hook-cases/mode-guard/deny/manual-commit-chained.json` | 1 | ship 1 |
| `tools/report-grade.py` | 1 | anonymise 1 |

**The 1,139 `calyx-url` hits are not in this table.** They are R10, decided collectively, and
listing them would put `docs/arc-log/arc-03-camp.md` at the top of a table whose subject is client
exposure.

---

## 4 Every hit

**578 rows, one per hit** — a line exposing three separate things gets three rows, because each is
a separate decision. Text is clipped to 160 characters; the file and line are the authority.

**Tick a row to accept its disposition; change the word to override it.** The `ask` rows are §5.

| Class | Location | Text | Disposition |
| :--- | :--- | :--- | :--- |
| `calyx-name` | `.claude-plugin/marketplace.json:2` | "name": "calyx-engineering", | **ship** R11 |
| `calyx-name` | `.claude-plugin/marketplace.json:4` | "name": "Calyx Engineering", | **ship** R11 |
| `calyx-name` | `.claude-plugin/marketplace.json:7` | "description": "Calyx Engineering's plugin line.", | **ship** R11 |
| `calyx-name` | `.claude-plugin/marketplace.json:15` | "name": "Calyx Engineering" | **ship** R11 |
| `calyx-name` | `.claude-plugin/plugin.json:6` | "name": "Calyx Engineering" | **ship** R11 |
| `calyx-name` | `docs/dev-log/issue-132-plugin-reload.md:31` | \| claude plugin marketplace update calyx-engineering \| Succeeds, does not refresh the plugin cache \| | **ship** R11 |
| `calyx-name` | `docs/dev-log/issue-134-public-audit.md:27` | \| **One line can produce several rows** \| R:\work_lantern\roadz-sound-system is a machine path *and* a client name *and* a product name. Three separate decisi | **ship** R11 |
| `calyx-name` | `docs/dev-log/issue-134-public-audit.md:28` | \| **calyx-url is counted, not listed** \| 1,139 links to this repository's own tracker. Enumerating them would bury the 573 rows that need a human, and the dec | **ship** R11 |
| `calyx-name` | `docs/dev-log/issue-134-public-audit.md:37` | \| Enumerating the calyx-url class in the audit \| 1,139 identical rows. docs/arc-log/arc-03-camp.md would top a table whose subject is client exposure \| | **ship** R11 |
| `calyx-name` | `docs/dev-log/issue-134-public-audit.md:75` | \| **heliman, a second GitHub identity**, was reported only as calyx-name and took ship — it would have survived publication \| Added to person \| | **ship** R11 |
| `calyx-name` | `docs/dev-log/issue-158-length-budget.md:123` | The calyx-engineering marketplace is registered as {"source": "directory", "path": "R:\arc"} | **ship** R11 |
| `calyx-name` | `docs/dev-log/issue-160-topic-numbering.md:146` | tools/plugin-reload.sh reinstalls from the marketplace, and the calyx-engineering | **ship** R11 |
| `calyx-name` | `docs/dev-log/issue-160-topic-numbering.md:153` | ~/.claude/plugins/cache/calyx-engineering/arc/0.1.0/, the probe run, and the file restored | **ship** R11 |
| `calyx-name` | `docs/dev-log/issue-160-topic-numbering.md:195` | \| **A probe cannot see a worktree's edit.** The calyx-engineering marketplace is a directory source at R:\arc — the main tree — so tools/plugin-reload.sh r | **ship** R11 |
| `calyx-name` | `docs/dev-log/issue-211-plugin-reload-dirty-tree.md:29` | renamed to arc-scratch@calyx-scratch, registered as a second directory-source marketplace, and | **ship** R11 |
| `calyx-name` | `docs/dev-log/issue-211-plugin-reload-dirty-tree.md:45` | # rename .claude-plugin/{plugin,marketplace}.json to arc-scratch@calyx-scratch, commit | **ship** R11 |
| `calyx-name` | `docs/dev-log/issue-211-plugin-reload-dirty-tree.md:47` | claude plugin install arc-scratch@calyx-scratch -y | **ship** R11 |
| `calyx-name` | `docs/dev-log/issue-211-plugin-reload-dirty-tree.md:51` | claude plugin uninstall arc-scratch@calyx-scratch --keep-data && \ | **ship** R11 |
| `calyx-name` | `docs/dev-log/issue-211-plugin-reload-dirty-tree.md:52` | claude plugin install arc-scratch@calyx-scratch -y | **ship** R11 |
| `calyx-name` | `docs/dev-log/issue-211-plugin-reload-dirty-tree.md:55` | claude plugin uninstall arc-scratch@calyx-scratch --keep-data | **ship** R11 |
| `calyx-name` | `docs/dev-log/issue-211-plugin-reload-dirty-tree.md:56` | claude plugin marketplace remove calyx-scratch | **ship** R11 |
| `calyx-name` | `docs/dev-log/issue-211-plugin-reload-dirty-tree.md:69` | **It checks the marketplace's installLocation, not $PWD.** calyx-engineering is a directory | **ship** R11 |
| `calyx-name` | `docs/dev-log/issue-252-probe-handoff.md:119` | plugins serving a handoff skill at once: arc@calyx-engineering from R:\arc, and | **ship** R11 |
| `calyx-name` | `docs/dev-log/issue-252-probe-handoff.md:120` | arc-scratch@calyx-scratch from another live run's scratch marketplace. A bare handoff cannot | **ship** R11 |
| `calyx-name` | `docs/product-architecture/mechanisms/m14-commit-rhythm.md:108` | \| **Verify the commit identity** \| *"we are supposed to be on my davidcalyx ID … it makes no sense to be committing as davidcalyx and commenting as heliman" | **ship** R11 |
| `calyx-name` | `docs/product-architecture/mechanisms/m31-self-improvement-loop.md:209` | davidcalyx | **ship** R11 |
| `calyx-name` | `docs/product-architecture/mechanisms/m31-self-improvement-loop.md:211` | david@calyxengineering.com | **ship** R11 |
| `calyx-name` | `docs/product-architecture/README.md:12` | what gets built next — [ROADMAP.md](../../ROADMAP.md) · how the Calyx plugins fit together | **ship** R11 |
| `calyx-name` | `docs/release/release-process.md:121` | L2 --> L3["<code>/plugin install arc@calyx-engineering</code>"] | **ship** R11 |
| `calyx-name` | `docs/release/release-process.md:126` | M1["<code>/plugin marketplace add </code>"] --> M2["<code>/plugin install arc@calyx-engineering</code>"] | **ship** R11 |
| `calyx-name` | `docs/suite-architecture/README.md:1` | # The Calyx plugin suite | **ship** R11 |
| `calyx-name` | `README.md:52` | /plugin install arc@calyx-engineering | **ship** R11 |
| `calyx-name` | `README.md:62` | /plugin install arc@calyx-engineering | **ship** R11 |
| `calyx-name` | `skills/plugin-retrospective/SKILL.md:3` | description: Use when returning to a Calyx plugin repo after a stretch of real work elsewhere, to mine that work's transcripts for friction and turn it into con | **ship** R11 |
| `calyx-name` | `skills/plugin-retrospective/SKILL.md:9` | sprint. **This one is narrow on purpose:** it improves the Calyx plugin line by mining | **ship** R11 |
| `calyx-name` | `tools/plugin-reload.sh:4` | # tools/plugin-reload.sh reload arc@calyx-engineering | **ship** R11 |
| `calyx-name` | `tools/plugin-reload.sh:50` | # ~/.claude/plugins/known_marketplaces.json — not the current directory. calyx-engineering is | **ship** R11 |
| `calyx-name` | `tools/plugin-reload.sh:257` | [ -n "$plugin" ] \|\| plugin="arc@calyx-engineering" | **ship** R11 |
| `calyx-name` | `tools/probe-handoff-checks.sh:210` | {"plugins":{"arc@calyx-engineering":[{"installPath":"/one"}],"arc@other":[{"installPath":"/two"}]}} | **ship** R11 |
| `client-hw` | `docs/arc-log/arc-04-dogfood.md:577` | - [friction-log.md](https://github.com/Lantern-Systems/roadz-sound-system/blob/main/docs/arc-work/interface-pcba-rev-b/friction-log.md) — ROADZ's hand-written | **anonymise** R17 |
| `client-hw` | `docs/arc-log/arc-04-dogfood.md:639` | \| The twelve-term provenance vocabulary, instrument, and the guarded aliases ([#266](https://github.com/Calyx-Engineering/arc/issues/266)) \| **Its own unit**, | **anonymise** R17 |
| `client-hw` | `docs/arc-work/04-dogfood/handoff-baseline.md:225` | - **C1** — 20:22:14.139Z: *"1. Clone roadz_pb_firmware, grep board-command for GP20/GP7/GP8 usage. 2. Fill §3.1 rows 2–4 with firmware evidence — no infe | **ask** R6 |
| `client-hw` | `docs/arc-work/04-dogfood/handoff-baseline.md:226` | - **User next** — 20:25:29.904Z: *"1. clone lives here: R:\work_lantern\roadz_pb_firmware / you will want to pull the latest from origin. / 2. also, previous  | **ask** R6 |
| `client-hw` | `docs/arc-work/04-dogfood/handoff-baseline.md:227` | - **The handoff's own lines**, 20:22:09.967Z: *"https://github.com/Lantern-Systems/roadz_pb_firmware — **not cloned here**"* and *"Fill in rows 2–4 with wha | **ask** R6 |
| `client-hw` | `docs/arc-work/04-dogfood/handoff-baseline.md:235` | - **C2** — status, 17:46:10.322Z: *"**Step 2 — branch refreshed.** interface-pcba/rev_b-issue-1-dimmer-flasher was 37 behind / **0 ahead**, so it fast-forwa | **ask** R6 |
| `client-hw` | `docs/arc-work/04-dogfood/handoff-baseline.md:253` | - **C1** — 13:17:46.225Z: *"**Where we are: #40 has zero measurements of its own.** Branch interface-pcba/rev-b-issue-40-bridged-mode carries two commits, bot | **ask** R6 |
| `client-hw` | `docs/dev-log/issue-134-public-audit.md:74` | \| **client-hw matched interface pcba with a space.** The repository writes it interface-pcba/rev_b — the branch, the wiki page, the milestone. 53 lines carry | **anonymise** R17 |
| `client-hw` | `docs/dev-log/issue-134-public-audit.md:97` | lantern, roadz, heliman, interface-pcba, rp2040 and three bench slugs. Staging it before | **anonymise** R17 |
| `client-hw` | `docs/dev-log/issue-162-branch-convention.md:39` | \| **A name the section spells out in full is exempt** \| ROADZ declares interface-pcba/rev_b as its integration branch two lines above the work-branch form. It | **anonymise** R17 |
| `client-hw` | `docs/dev-log/issue-162-branch-convention.md:53` | The real ROADZ names, all previously reported and all now passing: interface-pcba/rev_b-issue-1-dimmer-flasher, interface-pcba/rev-b-issue-15-audio-out-isolatio | **anonymise** R17 |
| `client-hw` | `docs/dev-log/issue-162-branch-convention.md:62` | \| **CMD kept the payload's closing braces** \| s/"$// strips a quote only at end of line, so a …"}}-terminated payload put interface-pcba/rev-b-pr70-inductan | **anonymise** R17 |
| `client-hw` | `docs/dev-log/issue-164-claim-provenance.md:23` | \| evals/report-shape/ \| Three more cases: pin-allocation-ledger (the exemplar), poe-device-under-test (uniform-source, reported not scored), poe-class-conflic | **anonymise** R17 |
| `client-hw` | `docs/dev-log/issue-164-claim-provenance.md:43` | of this exact defect: rp2040-pin-allocation.md grew a Provenance column after the photograph | **anonymise** R17 |
| `client-hw` | `docs/dev-log/issue-164-claim-provenance.md:66` | rp2040-pin-allocation.md — written by the user, in response to this exact defect — uses | **anonymise** R17 |
| `client-hw` | `docs/dev-log/issue-164-claim-provenance.md:146` | the one place it is written down is pr-68-gain-sweep-tool.md, which was cut as a candidate | **anonymise** R17 |
| `client-hw` | `docs/dev-log/issue-164-claim-provenance.md:159` | \| **The vocabulary in the field does not match the one specified.** rp2040-pin-allocation.md — the user's own repair of this defect — uses schematic · dat | **anonymise** R17 |
| `client-hw` | `docs/dev-log/issue-164-claim-provenance.md:170` | \| **The vocabulary has no term for an instrument reading that is not a measurement.** measured collapses *a number the bench produced* and *a number a fooled i | **anonymise** R17 |
| `client-hw` | `docs/dev-log/issue-266-provenance-vocabulary.md:13` | \| **Two vocabularies were live** \| The seven #164 specified, and the eight rp2040-pin-allocation.md had carried since the user repaired this defect by hand. F | **anonymise** R17 |
| `client-hw` | `docs/dev-log/issue-266-provenance-vocabulary.md:88` | pin-allocation-ledger scores ROWS off its Provenance header, so the adopted-term matching | **anonymise** R17 |
| `client-hw` | `docs/dev-log/issue-266-provenance-vocabulary.md:97` | \| **The 2026-08-28 document still cannot be an eval case.** instrument makes it a two-source region, which was the blocker #164 recorded — but pr-68-gain-swe | **anonymise** R17 |
| `client-hw` | `docs/product-architecture/archive/responsibility-decomposition.md:132` | \| **State today** \| tools/sch_netlist.py, amp-load-test, altium parsing. **Decision: own plugin (EE toolbox)** \| | **move** R2 |
| `client-hw` | `docs/product-architecture/archive/responsibility-decomposition.md:193` | Any future Altium 365 / PLM integration is an R9 integration. | **move** R2 |
| `client-hw` | `docs/product-architecture/archive/responsibility-decomposition.md:703` | \| 3 \| Branch model beyond rev B; dev/main; lifecycle states; PLM/Altium 365 — **now understood as an R9 question** \| No — later \| | **move** R2 |
| `client-hw` | `docs/product-architecture/mechanisms/m09-kickoff-scope-gate.md:18` | [Interface PCBA revision workflow](../../reference-roadz/ROADZ%20Interface%20PCBA%20Revision%20Workflow.md) | **anonymise** R17 |
| `client-hw` | `docs/product-architecture/mechanisms/m09-kickoff-scope-gate.md:37` | \| Create the milestone \| Interface PCBA — Rev X \| | **anonymise** R17 |
| `client-hw` | `docs/product-architecture/mechanisms/m09-kickoff-scope-gate.md:73` | - [ROADZ Interface PCBA revision workflow](../../reference-roadz/ROADZ%20Interface%20PCBA%20Revision%20Workflow.md) — the guided flow, steps 1–3 | **anonymise** R17 |
| `client-hw` | `docs/product-architecture/mechanisms/m10-branch-guard.md:16` | > off the parent branch of interface-pcba/rev_b This just completely messed everything | **anonymise** R17 |
| `client-hw` | `docs/product-architecture/mechanisms/m12-issue-linking.md:65` | interface-pcba/rev_b (not main): | **anonymise** R17 |
| `client-hw` | `docs/product-architecture/mechanisms/m12-issue-linking.md:69` | \| **#55** \| interface-pcba/rev_b \| **Linked to #54** \| *After* the default switch \| | **anonymise** R17 |
| `client-hw` | `docs/product-architecture/mechanisms/m12-issue-linking.md:70` | \| **#48** \| interface-pcba/rev_b \| **Empty** \| *Before* the default switch \| | **anonymise** R17 |
| `client-hw` | `docs/product-architecture/mechanisms/m12-issue-linking.md:121` | name: "interface-pcba/rev_b-issue-54-..." | **anonymise** R17 |
| `client-hw` | `docs/product-architecture/mechanisms/m16-hardware-record-structure.md:183` | │ ├── bom-analysis.md · spans the whole revision | **anonymise** R17 |
| `client-hw` | `docs/product-architecture/mechanisms/m16-hardware-record-structure.md:217` | \| Arc-level work \| arc-work/interface-pcba-rev-b/bom-analysis.md \| | **anonymise** R17 |
| `client-hw` | `docs/product-architecture/mechanisms/m16-hardware-record-structure.md:266` | \| Cellular module \| [emi-coexistence](../../docs/arc-work/interface-pcba-rev-b/emi-coexistence.md) \| | **anonymise** R17 |
| `client-hw` | `docs/product-architecture/mechanisms/m16-hardware-record-structure.md:344` | - **Arc work:** [BOM analysis](../arc-work/interface-pcba-rev-b/bom-analysis.md) | **anonymise** R17 |
| `client-hw` | `docs/product-architecture/mechanisms/m16-hardware-record-structure.md:400` | the one a future agent trusts. ROADZ .claude/wiki/speaker-power.md is a good example | **anonymise** R17 |
| `client-hw` | `docs/product-architecture/mechanisms/m22-configuration-management.md:56` | \| Multi-user and PLM \| Altium 365 and Atlassian change the answer \| | **anonymise** R17 |
| `client-hw` | `docs/product-architecture/mechanisms/m23-test-obligation-capture.md:43` | > issue in that milestone and then add checking out this LCPHOTO functionality"* | **anonymise** R17 |
| `client-hw` | `docs/product-architecture/mechanisms/m23-test-obligation-capture.md:90` | \| Cross-repo test items \| ROADZ firmware tests belong to roadz_pb_firmware, the design issue does not \| | **anonymise** R17 |
| `client-hw` | `docs/product-architecture/mechanisms/m28-human-gate.md:56` | step 5 describes it as practice: request review, review the branch in Altium, feedback via | **anonymise** R17 |
| `client-hw` | `docs/product-architecture/mechanisms/m28-human-gate.md:71` | was already verified. For a CAD review the reviewer opens Altium and forms their own view, | **anonymise** R17 |
| `client-hw` | `docs/product-architecture/mechanisms/m29-agent-wiki.md:62` | interface-board, speaker-power, rp2040-signals. The page set may be per-repo rather | **anonymise** R17 |
| `client-hw` | `docs/product-architecture/mechanisms/m32-session-preservation.md:85` | \| Branch \| interface-pcba/rev_b-issue-44-... \| | **anonymise** R17 |
| `client-hw` | `docs/product-architecture/mechanisms/m32-session-preservation.md:87` | \| Arc \| interface-pcba/rev_b \| | **anonymise** R17 |
| `client-hw` | `docs/product-architecture/mechanisms/m32-session-preservation.md:131` | \| A worktree (issue-1-dimmer-flasher) \| Its own slug \| Yes \| | **anonymise** R17 |
| `client-hw` | `docs/reference-roadz/ROADZ Interface PCBA Revision Workflow.md:1` | # ROADZ Interface PCBA Revision Workflow | **move** R1 |
| `client-hw` | `docs/reference-roadz/ROADZ Interface PCBA Revision Workflow.md:4` | This document outlines a recommended workflow for planning, executing, reviewing, and releasing revisions of the **Interface PCBA** within the ROADZ Speaker Sys | **move** R1 |
| `client-hw` | `docs/reference-roadz/ROADZ Interface PCBA Revision Workflow.md:24` | • Label 'Interface PCBA' | **move** R1 |
| `client-hw` | `docs/reference-roadz/ROADZ Interface PCBA Revision Workflow.md:27` | • Create Milestone 'Interface PCBA - Rev X' | **move** R1 |
| `client-hw` | `docs/reference-roadz/ROADZ Interface PCBA Revision Workflow.md:32` | 'interface-pcba/rev_X'"] | **move** R1 |
| `client-hw` | `docs/reference-roadz/ROADZ Interface PCBA Revision Workflow.md:46` | • Review branch in Altium | **move** R1 |
| `client-hw` | `docs/reference-roadz/ROADZ Interface PCBA Revision Workflow.md:96` | - Interface PCBA | **move** R1 |
| `client-hw` | `docs/reference-roadz/ROADZ Interface PCBA Revision Workflow.md:130` | interface-pcba/rev_X | **move** R1 |
| `client-hw` | `docs/reference-roadz/ROADZ Interface PCBA Revision Workflow.md:166` | - Chad reviews the branch directly in Altium (schematic + PCB). | **move** R1 |
| `client-hw` | `docs/reference-roadz/ROADZ Interface PCBA Revision Workflow.md:181` | /hardware/manufacturing/interface-pcba/rev_X/ | **move** R1 |
| `client-hw` | `docs/reference-roadz/ROADZ Interface PCBA Revision Workflow.md:205` | - Add quote + order confirmation to the revision branch under /hardware/manufacturing_history/interface-pcba/. | **move** R1 |
| `client-hw` | `docs/reference-roadz/ROADZ Interface PCBA Revision Workflow.md:216` | interface-pcba/rev_X → main | **move** R1 |
| `client-hw` | `docs/reference-roadz/ROADZ Interface PCBA Revision Workflow.md:241` | This workflow provides a predictable, traceable, and collaborative process for Interface PCBA revisions. It ensures that design changes, manufacturing outputs,  | **move** R1 |
| `client-hw` | `docs/retrospectives/2026-08-plugin-line/friction-transcript-log.md:41` | > working off the parent branch of interface-pcba/rev_b This just completely messed | **anonymise** R8 |
| `client-hw` | `docs/retrospectives/2026-08-plugin-line/friction-transcript-log.md:396` | Two merged PRs, both based on interface-pcba/rev_b: | **anonymise** R8 |
| `client-hw` | `docs/retrospectives/2026-08-plugin-line/friction-transcript-log.md:400` | \| #55 \| interface-pcba/rev_b \| **Linked to #54** \| After the default switch \| | **anonymise** R8 |
| `client-hw` | `docs/retrospectives/2026-08-plugin-line/friction-transcript-log.md:401` | \| #48 \| interface-pcba/rev_b \| **Empty** \| Before the default switch \| | **anonymise** R8 |
| `client-hw` | `docs/retrospectives/2026-08-plugin-line/friction-transcript-log.md:507` | \| **Multi-user and PLM** \| A second engineer; Dedrone with Altium 365 and Atlassian \| | **anonymise** R8 |
| `client-hw` | `docs/retrospectives/2026-09-dogfood/README.md:28` | standards (RP2040, CISPR, HIZ), which is the correct trade. | **anonymise** R8 |
| `client-hw` | `docs/retrospectives/2026-09-dogfood/README.md:118` | - *"hmmm, you walked in the opposite direct ion i asked. / the documentation was pretty good before, now its all gone! and the one thing you kept is what i aske | **anonymise** R8 |
| `client-hw` | `docs/retrospectives/2026-09-dogfood/README.md:125` | - *"yaml sweep values - there is too much in there. it looks like you're running real calculations and examples that are centered around an anxiety of overdrivi | **anonymise** R8 |
| `client-hw` | `docs/retrospectives/2026-09-dogfood/README.md:132` | - *"MOTHER FUCKER!!!! / LOAD ALL YOUR FUCKING SKILLS!!!! / you mis-labeled the branch so you're not using your issure writing skill or SOMETHING!"* — 2026-08- | **anonymise** R8 |
| `client-hw` | `docs/retrospectives/2026-09-dogfood/README.md:153` | - *"the physical setup - i verified that a 100mV input generates a 4V output. if you're not getting anything then its an error on your side. / you might have br | **anonymise** R8 |
| `client-hw` | `docs/retrospectives/2026-09-dogfood/README.md:160` | - *"tangent - you haven't listened on conciseness - log that in friction log. this is bullshit and i'm angry now."* — 2026-08-28-...-pr68-gain-sweep-tool.json | **anonymise** R8 |
| `client-hw` | `docs/retrospectives/2026-09-dogfood/README.md:186` | - *"i cant check you on this we are in the wrong branch right now ... next step - get me back into the right 68 branch"* — 2026-08-28-...-pr68-gain-sweep-tool | **anonymise** R8 |
| `client-hw` | `docs/retrospectives/2026-09-dogfood/README.md:206` | - *"your table - (NOTE you stopped numbering items so i can't respond accurately to you)"* — 2026-08-28-...-pr68-gain-sweep-tool.jsonl · 08-28 10:08 | **anonymise** R8 |
| `client-hw` | `docs/suite-architecture/domain-engineer-persona.md:224` | - ROADZ .claude/wiki/speaker-power.md — an existing example of captured device physics | **anonymise** R17 |
| `client-hw` | `evals/report-shape/cellular-recommendation-first/excerpt.md:5` | **Scope:** Replace the Teltonika RUT241 (~$200) with an end-device-certified modem mounted on Interface PCBA rev B. Host processor is a standard **Raspberry Pi  | **move** R5 |
| `client-hw` | `evals/report-shape/cellular-recommendation-first/excerpt.md:11` | Lay down **one 20-pin, 2 mm-pitch Skywire land pattern** on rev B and populate Cat-4 or Cat-M as a BOM option. Both parts are **end-device certified**, so FCC a | **move** R5 |
| `client-hw` | `evals/report-shape/cellular-recommendation-first/excerpt.md:14` | > **Module:** NL-SW-LTE-TC4NAG-B — $120 · [Airgain product page](https://airgain.com/products/4g-lte-cat-4-na/) · [DigiKey](https://www.digikey.com/en/produ | **move** R5 |
| `client-hw` | `evals/report-shape/cellular-recommendation-first/excerpt.md:15` | > **Antenna:** YEMN302Q1A — $59.90 · [Quectel product page](https://www.quectel.com/product/yemn302q1a-lte-gnss-screw-mount-combo-antenna/) · [DigiKey](http | **move** R5 |
| `client-hw` | `evals/report-shape/cellular-recommendation-first/excerpt.md:16` | > Integration docs live on the manufacturer pages, not DigiKey — see §7.3 for the full list. | **move** R5 |
| `client-hw` | `evals/report-shape/cellular-recommendation-first/excerpt.md:17` | > **Saves ~$50/unit** vs the RUT241, at **$0** FCC and carrier certification cost. | **move** R5 |
| `client-hw` | `evals/report-shape/cellular-recommendation-first/excerpt.md:22` | \| Module \| RUT241 $200 \| **NL-SW-LTE-TC4NAG-B $120** \| NL-SW-LTE-QBG95-D $77 \| | **move** R5 |
| `client-hw` | `evals/report-shape/cellular-recommendation-first/excerpt.md:23` | \| Antenna \| Bingfu $30 \| **YEMN302Q1A $59.90** \| SWA2100 $50.58 \| | **move** R5 |
| `client-hw` | `evals/report-shape/cellular-recommendation-first/graders/provenance.md:4` | [../../pin-allocation-ledger/graders/provenance.md](../../pin-allocation-ledger/graders/provenance.md). | **move** R5 |
| `client-hw` | `evals/report-shape/light-dimming-findings-first/excerpt.md:13` | **PWM on the light's supply dims the Pioneer NP6BB directly.** The light heads, their | **move** R5 |
| `client-hw` | `evals/report-shape/light-dimming-findings-first/excerpt.md:14` | connectors and their harness are unchanged, and no RP2040 pins are added. What rev B adds | **move** R5 |
| `client-hw` | `evals/report-shape/light-dimming-findings-first/excerpt.md:23` | \| **Replacement** \| One [TPS1200-Q1](https://www.digikey.com/en/products/detail/texas-instruments/TPS12000QDGXRQ1/25881327) driving one [TPH1R306P1](https://w | **move** R5 |
| `client-hw` | `evals/report-shape/light-dimming-findings-first/excerpt.md:24` | \| **Channel protection** \| **One PTC per channel** — [2920L500/16MR](https://www.digikey.com/en/products/detail/littelfuse-inc/2920L500-16MR/3997238), 5 A h | **move** R5 |
| `client-hw` | `evals/report-shape/light-dimming-findings-first/excerpt.md:27` | \| **Night trigger** \| Whelen LCPHOTO, fixed 50 lux, read through the board's existing optocoupler \| [analysis-night-detect.md](analysis-night-detect.md) \| | **move** R5 |
| `client-hw` | `evals/report-shape/light-dimming-findings-first/excerpt.md:34` | **Certification does not constrain this.** The NP6BB is a scene light with no SAE Class 1 | **move** R5 |
| `client-hw` | `evals/report-shape/light-dimming-findings-first/graders/provenance.md:4` | [../../pin-allocation-ledger/graders/provenance.md](../../pin-allocation-ledger/graders/provenance.md). | **move** R5 |
| `client-hw` | `evals/report-shape/pin-allocation-ledger/case.yaml:2` | document: docs/arc-work/interface-pcba-rev-b/rp2040-pin-allocation.md | **move** R5 |
| `client-hw` | `evals/report-shape/pin-allocation-ledger/excerpt.md:6` | \| 14 \| claimed \| report — PR [#48](https://github.com/Lantern-Systems/roadz-sound-system/pull/48) \| LGHTS_nFAULT \| nDUSK_DETECT \| Light fault in, replac | **move** R5 |
| `client-hw` | `evals/report-shape/pin-allocation-ledger/excerpt.md:11` | \| 22 \| claimed \| thread — [#24](https://github.com/Lantern-Systems/roadz-sound-system/issues/24) \| 3V3_D2_EN \| IGNTN_OUT \| Ignition-derived enable out o | **move** R5 |
| `client-hw` | `evals/report-shape/pin-allocation-ledger/graders/provenance.md:44` | source and graded ONESIDED: unscored, and invisible. pr-68-gain-sweep-tool.md is the only | **move** R5 |
| `client-hw` | `evals/report-shape/poe-class-conflict/graders/provenance.md:4` | [../../pin-allocation-ledger/graders/provenance.md](../../pin-allocation-ledger/graders/provenance.md). | **move** R5 |
| `client-hw` | `evals/report-shape/poe-device-under-test/graders/provenance.md:4` | [../../pin-allocation-ledger/graders/provenance.md](../../pin-allocation-ledger/graders/provenance.md). | **move** R5 |
| `client-hw` | `evals/report-shape/poe-pse-question-first/excerpt.md:2` | title: "On-Board PoE PSE for the Interface PCBA" | **move** R5 |
| `client-hw` | `evals/report-shape/poe-pse-question-first/excerpt.md:3` | subtitle: "Issue #44 · Interface PCBA rev B · investigation" | **move** R5 |
| `client-hw` | `evals/report-shape/poe-pse-question-first/excerpt.md:19` | RAD mode adds an internal PoE switch feeding the RAD, the RAS RPi, and the cab tablet. The | **move** R5 |
| `client-hw` | `evals/report-shape/poe-pse-question-first/excerpt.md:25` | on the Interface PCBA. | **move** R5 |
| `client-hw` | `evals/saturation/issue-39-pinout-context-full/turns/1.md:3` | Branch is interface-pcba/rev_b-issue-39-unify-rp2040-pinout. | **move** R5 |
| `client-hw` | `evals/saturation/issue-39-pinout-context-full/turns/1.md:4` | Next is checking roadz_pb_firmware for GP20/GP7/GP8/GP18 overlap, then §3.1 of the pin allocation study. | **move** R5 |
| `client-hw` | `evals/saturation/issue-39-pinout-context-full/turns/10.md:1` | so i guess a bit of extra flavor - there should just be one new signal out of rp2040 for this hk mechanism - hard-kill from rp2040. and no new signals in. | **move** R5 |
| `client-hw` | `evals/saturation/issue-39-pinout-context-full/turns/11.md:3` | kill sources - RP2040, Power button on pendant, raspberry pi | **move** R5 |
| `client-hw` | `evals/saturation/issue-39-pinout-context-full/turns/11.md:6` | so, what would the RP2040 need a "youre being killed" signal for? what benefit does it bring? does it come before the actual power cutoff? | **move** R5 |
| `client-hw` | `evals/saturation/issue-39-pinout-context-full/turns/16.md:5` | 3. RP2040 can power down the Pi - look at the power tree... nLP will take it down. document into #35 | **move** R5 |
| `client-hw` | `evals/saturation/issue-39-pinout-context-full/turns/2.md:1` | 1. clone lives here: R:\work_lantern\roadz_pb_firmware | **move** R5 |
| `client-hw` | `evals/saturation/issue-39-pinout-context-full/turns/20.md:4` | also - in our closeout checklist for the milestone please ensure that re-updating the rp2040 pinout md is in there. | **move** R5 |
| `client-hw` | `evals/saturation/issue-39-pinout-context-full/turns/3.md:7` | GP13 - can you confirm - from RP2040 documentation if GP13 can do PWM - or if the RP2040 has a PWM module that can do 1.3kHz? | **move** R5 |
| `client-hw` | `evals/saturation/issue-39-pinout-context-full/turns/3.md:18` | Add to the misc items issue - check box - pull up/pull-down resistors should be added to RP2040 to ensure states during re-flash | **move** R5 |
| `client-hw` | `evals/saturation/issue-39-pinout-context-full/turns/38.md:1` | i guess another note - you pointed out that RtcWakeUp is intended to wake the system. in the process flow it actually, always as far as i know, leads to the rp2 | **move** R5 |
| `client-hw` | `evals/saturation/issue-39-pinout-context-full/turns/47.md:1` | what issue confirmed that we use LCPHOTO to detect light? i'm not seeing the internal diagram updated with the additional box/board connectors needed to input t | **move** R5 |
| `client-hw` | `evals/saturation/issue-39-pinout-context-full/turns/49.md:1` | perfect suggestion. that provenance might actually be part of the status column in the ledger arc-work\interface-pcba-rev-b\rp2040-pin-allocation.md. | **move** R5 |
| `client-hw` | `evals/saturation/issue-39-pinout-context-full/turns/49.md:2` | it speaks to the workflow for discovery. actually maybe it should have just been its own column. but it feeds into the decision making process. it shouldn't bel | **move** R5 |
| `client-hw` | `evals/saturation/issue-39-pinout-context-full/turns/9.md:4` | - hard-kill from rp2040 | **move** R5 |
| `client-hw` | `evals/skill-firing/wrapped/handoff-then-do-these-in-order/prompt.md:2` | Branch is interface-pcba/rev_b — step 2 moves to #1's branch after refreshing it. | **anonymise** R17 |
| `client-hw` | `evals/skill-firing/wrapped/handoff-then-do-these-in-order/prompt.md:3` | Next is the audio isolator parts check, then the LCPHOTO block-diagram fix on #1. | **anonymise** R17 |
| `client-hw` | `evals/skill-firing/wrapped/handoff-then-order-60-words/prompt.md:3` | Branch is interface-pcba/rev_b-issue-39-unify-rp2040-pinout. | **anonymise** R17 |
| `client-hw` | `evals/skill-firing/wrapped/handoff-then-order-60-words/prompt.md:4` | Next is checking roadz_pb_firmware for GP20/GP7/GP8/GP18 overlap, then §3.1 of the pin allocation study. | **anonymise** R17 |
| `client-hw` | `hooks/camp-branch-check:168` | # interface-pcba/rev_b is its integration branch, declared two lines above the work-branch | **anonymise** R17 |
| `client-hw` | `skills/record-route/SKILL.md:134` | rp2040-pin-allocation.md had carried since the user repaired this defect by hand. **Two | **anonymise** R17 |
| `client-hw` | `tools/hook-cases/camp-branch-check/fixtures/roadz/CLAUDE.md:15` | interface-pcba/rev_b is the integration branch for the Interface PCBA rev B milestone. All | **anonymise** R17 |
| `client-hw` | `tools/hook-cases/camp-branch-check/pass/declared-integration-branch.json:2` | {"cwd":"tools/hook-cases/camp-branch-check/fixtures/roadz","tool_name":"Bash","tool_input":{"command":"git checkout -b interface-pcba/rev_b"}} | **anonymise** R17 |
| `client-hw` | `tools/hook-cases/camp-branch-check/pass/roadz-issue-hyphen.json:2` | {"cwd":"tools/hook-cases/camp-branch-check/fixtures/roadz","tool_name":"Bash","tool_input":{"command":"git switch -c interface-pcba/rev-b-issue-15-audio-out-iso | **anonymise** R17 |
| `client-hw` | `tools/hook-cases/camp-branch-check/pass/roadz-issue-slug-digits.json:1` | # ROADZ, real: the slug carries digits (rp2040) — the number comes from the identifier, not the slug | **anonymise** R17 |
| `client-hw` | `tools/hook-cases/camp-branch-check/pass/roadz-issue-slug-digits.json:2` | {"cwd":"tools/hook-cases/camp-branch-check/fixtures/roadz","tool_name":"Bash","tool_input":{"command":"git checkout -b interface-pcba/rev_b-issue-39-unify-rp204 | **anonymise** R17 |
| `client-hw` | `tools/hook-cases/camp-branch-check/pass/roadz-issue-underscore.json:2` | {"cwd":"tools/hook-cases/camp-branch-check/fixtures/roadz","tool_name":"Bash","tool_input":{"command":"git checkout -b interface-pcba/rev_b-issue-1-dimmer-flash | **anonymise** R17 |
| `client-hw` | `tools/hook-cases/camp-branch-check/pass/roadz-pr-branch.json:2` | {"cwd":"tools/hook-cases/camp-branch-check/fixtures/roadz","tool_name":"Bash","tool_input":{"command":"git checkout -b interface-pcba/rev-b-pr58-arc-setup"}} | **anonymise** R17 |
| `client-hw` | `tools/hook-cases/camp-branch-check/pass/roadz-pr-sweep.json:2` | {"cwd":"tools/hook-cases/camp-branch-check/fixtures/roadz","tool_name":"Bash","tool_input":{"command":"git branch interface-pcba/rev-b-pr70-inductance-sweep"}} | **anonymise** R17 |
| `client-hw` | `tools/hook-cases/camp-branch-check/report/roadz-no-number.json:2` | {"cwd":"tools/hook-cases/camp-branch-check/fixtures/roadz","tool_name":"Bash","tool_input":{"command":"git checkout -b interface-pcba/rev-b-dimmer-flasher"}} | **anonymise** R17 |
| `client-hw` | `tools/miner-scope.sh:40` | mkdir -p "$T/r--work-lantern-roadz-sound-system" "$T/R--work-lantern-roadz-sound-system--claude-worktrees-interface-pcba-rev-b-issue-1" "$T/R--work-lantern-road | **anonymise** R17 |
| `client-hw` | `tools/report-grade.py:274` | # specified, and the eight rp2040-pin-allocation.md had been carrying since the user repaired | **anonymise** R17 |
| `client-hw` | `tools/report-grade.sh:127` | printf '# A title\n\n**Status:** selected\n**Scope:** replace the RUT241 on rev B\n\n## 1. Recommendation\n\nLay down one land pattern.\n' \ | **anonymise** R17 |
| `client-hw` | `tools/report-grade.sh:146` | # #164's: evals/report-shape/pin-allocation-ledger and poe-device-under-test. | **anonymise** R17 |
| `client-hw` | `tools/report-grade.sh:203` | # pr-68-gain-sweep-tool.md, which cannot be a case because it states no disagreement across | **anonymise** R17 |
| `client-hw` | `tools/report-grade.sh:233` | # vocabulary, so there was nothing for the conflict column to see. pr-68-gain-sweep-tool.md | **anonymise** R17 |
| `client-hw` | `tools/report-grade.sh:248` | printf 'Firmware still calls this pin lights_fault. However the schematic renames it nDUSK_DETECT.\n' \ | **anonymise** R17 |
| `employer` | `docs/arc-work/04-dogfood/issue-plan.md:241` | \| Upkeep-5 \| [#134](https://github.com/Calyx-Engineering/arc/issues/134) review what ships before making Arc public \| **At arc close.** Blocks use at Dedrone | **anonymise** R16 |
| `employer` | `docs/product-architecture/mechanisms/m12-issue-linking.md:353` | four ❌ above it apply. The rows above matter for Dedrone — Atlassian, not GitHub — where the | **anonymise** R16 |
| `employer` | `docs/product-architecture/mechanisms/m31-self-improvement-loop.md:203` | \| **Identity** \| git identity is on the allowlist \| Anyone else — including the user's Dedrone identity \| | **anonymise** R16 |
| `employer` | `docs/retrospectives/2026-08-plugin-line/friction-transcript-log.md:507` | \| **Multi-user and PLM** \| A second engineer; Dedrone with Altium 365 and Atlassian \| | **anonymise** R8 |
| `lantern` | `agents/transcript-miner.md:36` | \| **Curated saves** \| A repository saves transcripts under a named folder — R:rc-transcripts, R:\work_lantern\_transcripts. Files are named <date>-<arc>-<i | **anonymise** R17 |
| `lantern` | `docs/arc-log/arc-04-dogfood.md:577` | - [friction-log.md](https://github.com/Lantern-Systems/roadz-sound-system/blob/main/docs/arc-work/interface-pcba-rev-b/friction-log.md) — ROADZ's hand-written | **anonymise** R17 |
| `lantern` | `docs/arc-work/04-dogfood/handoff-baseline.md:18` | bash tools/handoff-openings.sh r--work-lantern-roadz-sound-system r--arc \ | **ask** R6 |
| `lantern` | `docs/arc-work/04-dogfood/handoff-baseline.md:226` | - **User next** — 20:25:29.904Z: *"1. clone lives here: R:\work_lantern\roadz_pb_firmware / you will want to pull the latest from origin. / 2. also, previous  | **ask** R6 |
| `lantern` | `docs/arc-work/04-dogfood/handoff-baseline.md:227` | - **The handoff's own lines**, 20:22:09.967Z: *"https://github.com/Lantern-Systems/roadz_pb_firmware — **not cloned here**"* and *"Fill in rows 2–4 with wha | **ask** R6 |
| `lantern` | `docs/arc-work/04-dogfood/handoff-rationale.md:71` | bash tools/handoff-openings.sh r--work-lantern-roadz-sound-system r--arc \ | **anonymise** R17 |
| `lantern` | `docs/arc-work/04-dogfood/skill-firing-baseline.md:13` | bash tools/skill-firing.sh r--work-lantern-roadz-sound-system r--arc --since 2026-08-24T09:40 | **anonymise** R17 |
| `lantern` | `docs/arc-work/04-dogfood/skill-firing-baseline.md:66` | bash tools/skill-firing.sh r--work-lantern-roadz-sound-system r--arc --since 2026-08-24T09:40 | **anonymise** R17 |
| `lantern` | `docs/dev-log/issue-134-public-audit.md:27` | \| **One line can produce several rows** \| R:\work_lantern\roadz-sound-system is a machine path *and* a client name *and* a product name. Three separate decisi | **anonymise** R17 |
| `lantern` | `docs/dev-log/issue-134-public-audit.md:73` | \| **The three excluded files ship and had no disposition.** tools/audit-public.sh's class table is a dictionary of the client's parts; the audit quotes every h | **anonymise** R17 |
| `lantern` | `docs/dev-log/issue-134-public-audit.md:97` | lantern, roadz, heliman, interface-pcba, rp2040 and three bench slugs. Staging it before | **anonymise** R17 |
| `lantern` | `docs/dev-log/issue-138-merge-route.md:22` | ROADZ was fixed on install day, [44dbb06](https://github.com/Lantern-Systems/roadz-sound-system/commit/44dbb06): *"Two copies of the same rule drift, and the co | **anonymise** R17 |
| `lantern` | `docs/dev-log/issue-141-miner-scope.md:7` | agents/transcript-miner said *"glob across every matching raw directory, never one"*, because worktrees get their own slug and a deleted worktree leaves an orph | **anonymise** R17 |
| `lantern` | `docs/dev-log/issue-162-branch-convention.md:18` | Arc names arcs arc/<nn>-<slug>. [ROADZ](https://github.com/Lantern-Systems/roadz-sound-system) names them after the product component being revised, and declare | **anonymise** R17 |
| `lantern` | `docs/product-architecture/mechanisms/m40-autonomy-switch.md:327` | ROADZ reached one statement on install day, [44dbb06](https://github.com/Lantern-Systems/roadz-sound-system/commit/44dbb06): | **anonymise** R17 |
| `lantern` | `docs/reference-roadz/issue-writing/references/github.md:14` | **Cross-repository closing works** — Closes Lantern-Systems/other-repo#12 — but | **move** R1 |
| `lantern` | `docs/reference-roadz/README.md:3` | **Copied verbatim from R:\work_lantern\roadz-sound-system, 2026-08-16.** These are | **move** R1 |
| `lantern` | `docs/retrospectives/2026-09-dogfood/README.md:5` | **Source work:** Lantern ROADZ speaker / sound-system. | **anonymise** R8 |
| `lantern` | `docs/retrospectives/2026-09-dogfood/README.md:18` | \| Sources \| 23 files · 86.6 MB — two transcript directories plus the 5 curated saves in R:\work_lantern\_transcripts, deduplicated on text and timestamp \| | **anonymise** R8 |
| `lantern` | `docs/retrospectives/2026-09-dogfood/README.md:19` | \| Excluded \| R--work-lantern-roadz-pb-firmware — a different repository. [#141](https://github.com/Calyx-Engineering/arc/issues/141) \| | **anonymise** R8 |
| `lantern` | `evals/environment-blame/issue-68-gain-sweep-bench-blame/turns/39.md:1` | <ide_opened_file>The user opened the file r:\work_lantern\roadz-sound-system\tools\mso8204_bode_sweep\bode_config.yaml in the IDE. This may or may not be relate | **move** R5 |
| `lantern` | `evals/report-shape/cellular-recommendation-first/excerpt.md:3` | **Relates to:** [#26 — Onboard cell modem evaluation](https://github.com/Lantern-Systems/roadz-sound-system/issues/26) · [US001 — Two deployment configurat | **move** R5 |
| `lantern` | `evals/report-shape/light-dimming-findings-first/excerpt.md:3` | **Relates to:** [#1 — PCBA respin: Add dimmer/flasher capability](https://github.com/Lantern-Systems/roadz-sound-system/issues/1) | **move** R5 |
| `lantern` | `evals/report-shape/pin-allocation-ledger/excerpt.md:5` | \| 13 \| claimed \| report — PR [#48](https://github.com/Lantern-Systems/roadz-sound-system/pull/48) \| LGHTS_ON \| LIGHTS_ON \| Static on/off enable becomes  | **move** R5 |
| `lantern` | `evals/report-shape/pin-allocation-ledger/excerpt.md:6` | \| 14 \| claimed \| report — PR [#48](https://github.com/Lantern-Systems/roadz-sound-system/pull/48) \| LGHTS_nFAULT \| nDUSK_DETECT \| Light fault in, replac | **move** R5 |
| `lantern` | `evals/report-shape/pin-allocation-ledger/excerpt.md:8` | \| 18 \| **available** \| drawing — [#8](https://github.com/Lantern-Systems/roadz-sound-system/issues/8), reviewed \| PND.PWR_EN \| — \| Pendant 5V load swi | **move** R5 |
| `lantern` | `evals/report-shape/pin-allocation-ledger/excerpt.md:9` | \| 19 \| claimed \| thread [#24](https://github.com/Lantern-Systems/roadz-sound-system/issues/24) · drawing [#8](https://github.com/Lantern-Systems/roadz-sound | **move** R5 |
| `lantern` | `evals/report-shape/pin-allocation-ledger/excerpt.md:11` | \| 22 \| claimed \| thread — [#24](https://github.com/Lantern-Systems/roadz-sound-system/issues/24) \| 3V3_D2_EN \| IGNTN_OUT \| Ignition-derived enable out o | **move** R5 |
| `lantern` | `evals/report-shape/pin-allocation-ledger/excerpt.md:15` | [#38](https://github.com/Lantern-Systems/roadz-sound-system/issues/38)'s accessory rail and [#35](https://github.com/Lantern-Systems/roadz-sound-system/issues/3 | **move** R5 |
| `lantern` | `evals/report-shape/pin-allocation-ledger/excerpt.md:18` | two decisions did it: [#12](https://github.com/Lantern-Systems/roadz-sound-system/issues/12)'s SSR is ignition-driven, so it commands nothing; and its | **move** R5 |
| `lantern` | `evals/report-shape/poe-pse-question-first/excerpt.md:23` | [#38](https://github.com/Lantern-Systems/roadz-sound-system/issues/38) follows the block diagram | **move** R5 |
| `lantern` | `evals/saturation/issue-39-pinout-context-full/turns/2.md:1` | 1. clone lives here: R:\work_lantern\roadz_pb_firmware | **move** R5 |
| `lantern` | `evals/skill-firing/situation/copy-transcript-opening/prompt.md:1` | please copy this transcript ~/.claude/projects/r--work-lantern-roadz-sound-system/10774bf5-32a2-4629-b5fd-10c2fdf3388f.jsonl | **anonymise** R17 |
| `lantern` | `evals/skill-firing/situation/copy-transcript-opening/prompt.md:2` | → R:\work_lantern\_transcripts\2026-09-04-arc-rev-b-pr70-closeout.jsonl | **anonymise** R17 |
| `lantern` | `evals/skill-firing/situation/log-this-in-friction-log/prompt.md:1` | <ide_selection>The user selected the lines 606 to 606 from r:\work_lantern\roadz-sound-system\.timescope\logs.jsonl: | **anonymise** R17 |
| `lantern` | `evals/skill-firing/wrapped/handoff-updated-elsewhere/prompt.md:1` | <ide_opened_file>The user opened the file r:\work_lantern\roadz-sound-system\HANDOFF.md in the IDE. This may or may not be related to the current task.</ide_ope | **anonymise** R17 |
| `lantern` | `tools/hook-cases/camp-branch-check/fixtures/roadz/CLAUDE.md:10` | The Branching section below is [ROADZ](https://github.com/Lantern-Systems/roadz-sound-system)'s, | **anonymise** R17 |
| `lantern` | `tools/miner-scope.sh:10` | # real run also read R--work-lantern-roadz-pb-firmware, which is a different product. #141. | **anonymise** R17 |
| `lantern` | `tools/miner-scope.sh:40` | mkdir -p "$T/r--work-lantern-roadz-sound-system" "$T/R--work-lantern-roadz-sound-system--claude-worktrees-interface-pcba-rev-b-issue-1" "$T/R--work-lantern-road | **anonymise** R17 |
| `lantern` | `tools/miner-scope.sh:63` | t "the briefed directory is in scope" "IN r--work-lantern-roadz-sound-system" r--work-lantern-roadz-sound-system | **anonymise** R17 |
| `lantern` | `tools/miner-scope.sh:64` | t "a worktree of the briefed slug is in scope, despite the case difference" "IN R--work-lantern-roadz-sound-system--claude-worktrees" r--work-lantern-roadz-soun | **anonymise** R17 |
| `lantern` | `tools/miner-scope.sh:65` | t "a sibling repository sharing a stem is NEAR, not IN — the #141 case" "NEAR R--work-lantern-roadz-pb-firmware" r--work-lantern-roadz-sound-system | **anonymise** R17 |
| `lantern` | `tools/miner-scope.sh:66` | t "an unrelated repository is SKIP" "SKIP r--lodestar" r--work-lantern-roadz-sound-system | **anonymise** R17 |
| `lantern` | `tools/miner-scope.sh:67` | t "a second briefed slug brings its directory in" "IN r--arc" r--work-lantern-roadz-sound-system r--arc | **anonymise** R17 |
| `lantern` | `tools/miner-scope.sh:68` | t "nothing is silently omitted — every directory is on a line" "SKIP r--arc" r--work-lantern-roadz-sound-system | **anonymise** R17 |
| `lantern` | `tools/miner-scope.sh:71` | te "a valid brief exits 0" 0 r--work-lantern-roadz-sound-system | **anonymise** R17 |
| `lantern` | `tools/report-grade.sh:13` | # R:/work_lantern — a path that exists on ONE machine. Everywhere else every | **anonymise** R17 |
| `lantern` | `tools/report-grade.sh:58` | CORPUS="${REPORT_CORPUS_DIR:-R:/work_lantern}" | **anonymise** R17 |
| `local-path` | `.claude/arc/sessions.md:11` | \| R--arc-wt-16 \| R:/arc-wt/16 \| arc/04-dogfood-issue-16-session-index \| #16 \| arc/04-dogfood \| 2026-09-08 to 2026-09-08 \| orphaned \| | **move** R3 |
| `local-path` | `.claude/arc/sessions.md:12` | \| R--arc-wt-214 \| R:/arc-wt/214 \| arc/04-dogfood-issue-214-claim \| #214 \| arc/04-dogfood \| 2026-09-08 to 2026-09-09 \| orphaned \| | **move** R3 |
| `local-path` | `.claude/arc/sessions.md:13` | \| R--arc-wt-204 \| R:/arc-wt/204 \| detached \| - \| - \| 2026-09-08 to 2026-09-08 \| orphaned \| | **move** R3 |
| `local-path` | `.claude/arc/sessions.md:14` | \| R--arc-wt-174 \| R:/arc-wt/174 \| arc/04-dogfood-issue-174-response-verbosity \| #174 \| arc/04-dogfood \| 2026-09-08 to 2026-09-08 \| orphaned \| | **move** R3 |
| `local-path` | `.claude/arc/sessions.md:15` | \| R--arc-wt-136 \| R:/arc-wt/136 \| detached \| - \| - \| 2026-09-09 to 2026-09-09 \| orphaned \| | **move** R3 |
| `local-path` | `.claude/arc/sessions.md:16` | \| R--arc-wt-252 \| R:/arc-wt/252 \| detached \| - \| - \| 2026-09-09 to 2026-09-09 \| orphaned \| | **move** R3 |
| `local-path` | `.claude/arc/sessions.md:17` | \| R--arc-wt-265 \| R:/arc-wt/265 \| detached \| - \| - \| 2026-09-09 to 2026-09-09 \| orphaned \| | **move** R3 |
| `local-path` | `.claude/arc/sessions.md:18` | \| R--arc-wt-253 \| R:/arc-wt/253 \| arc/04-dogfood-issue-253-cold-start-score \| #253 \| arc/04-dogfood \| 2026-09-09 to 2026-09-09 \| orphaned \| | **move** R3 |
| `local-path` | `.claude/arc/sessions.md:19` | \| R--arc-wt-230 \| R:/arc-wt/230 \| detached \| - \| - \| 2026-09-09 to 2026-09-09 \| orphaned \| | **move** R3 |
| `local-path` | `.claude/arc/sessions.md:20` | \| R--arc-wt-272 \| R:/arc-wt/272 \| detached \| - \| - \| 2026-09-09 to 2026-09-09 \| orphaned \| | **move** R3 |
| `local-path` | `.claude/arc/sessions.md:21` | \| R--arc-wt-269 \| R:/arc-wt/269 \| arc/04-dogfood-issue-269-probe-rate-limit \| #269 \| arc/04-dogfood \| 2026-09-09 to 2026-09-09 \| orphaned \| | **move** R3 |
| `local-path` | `.claude/arc/sessions.md:22` | \| R--arc-wt-264 \| R:/arc-wt/264 \| detached \| - \| - \| 2026-09-09 to 2026-09-09 \| orphaned \| | **move** R3 |
| `local-path` | `.claude/arc/sessions.md:23` | \| R--arc-wt-263 \| R:/arc-wt/263 \| detached \| - \| - \| 2026-09-09 to 2026-09-09 \| orphaned \| | **move** R3 |
| `local-path` | `.claude/arc/sessions.md:24` | \| R--arc-wt-190 \| R:/arc-wt/190 \| detached \| - \| - \| 2026-09-09 to 2026-09-09 \| orphaned \| | **move** R3 |
| `local-path` | `.claude/arc/sessions.md:25` | \| R--arc-wt-267 \| R:/arc-wt/267 \| detached \| - \| - \| 2026-09-09 to 2026-09-09 \| orphaned \| | **move** R3 |
| `local-path` | `.claude/arc/sessions.md:26` | \| R--arc-wt-271 \| R:/arc-wt/271 \| detached \| - \| - \| 2026-09-09 to 2026-09-09 \| orphaned \| | **move** R3 |
| `local-path` | `.claude/arc/sessions.md:27` | \| R--arc-wt-274 \| R:/arc-wt/274 \| detached \| - \| - \| 2026-09-09 to 2026-09-09 \| orphaned \| | **move** R3 |
| `local-path` | `.claude/arc/sessions.md:28` | \| R--arc-wt-report \| R:/arc-wt/report \| arc/04-dogfood \| - \| arc/04-dogfood \| 2026-09-09 to 2026-09-09 \| live \| | **move** R3 |
| `local-path` | `.claude/arc/sessions.md:29` | \| R--arc-wt-260 \| R:/arc-wt/260 \| detached \| - \| - \| 2026-09-09 to 2026-09-09 \| orphaned \| | **move** R3 |
| `local-path` | `.claude/arc/sessions.md:30` | \| R--arc-wt-266 \| R:/arc-wt/266 \| detached \| - \| - \| 2026-09-09 to 2026-09-09 \| orphaned \| | **move** R3 |
| `local-path` | `.claude/arc/sessions.md:31` | \| R--arc-wt-134 \| R:/arc-wt/134 \| detached \| - \| - \| 2026-09-09 to 2026-09-09 \| live \| | **move** R3 |
| `local-path` | `agents/transcript-miner.md:36` | \| **Curated saves** \| A repository saves transcripts under a named folder — R:rc-transcripts, R:\work_lantern\_transcripts. Files are named <date>-<arc>-<i | **anonymise** R13 |
| `local-path` | `docs/arc-work/03-camp/friction-log.md:185` | R:\arc-transcripts\ holds **twelve** files. The handoff's table lists **four**. Eight | **move** R4 |
| `local-path` | `docs/arc-work/04-dogfood/handoff-baseline.md:157` | R:/arc/HANDOFF.md, gitignored and since overwritten; the copy that was read is the | **ask** R6 |
| `local-path` | `docs/arc-work/04-dogfood/handoff-baseline.md:226` | - **User next** — 20:25:29.904Z: *"1. clone lives here: R:\work_lantern\roadz_pb_firmware / you will want to pull the latest from origin. / 2. also, previous  | **ask** R6 |
| `local-path` | `docs/dev-log/issue-134-public-audit.md:27` | \| **One line can produce several rows** \| R:\work_lantern\roadz-sound-system is a machine path *and* a client name *and* a product name. Three separate decisi | **anonymise** R13 |
| `local-path` | `docs/dev-log/issue-142-skill-copies.md:13` | **The marketplace is a directory install pointing at R:\arc itself** — known_marketplaces.json: {"source": "directory", "path": "R:\arc"}. tools/plugin-reload | **anonymise** R13 |
| `local-path` | `docs/dev-log/issue-152-archive-before-overwrite.md:92` | C:/Users/.../Temp/x, so the prefix strip that derives a repo-relative path never matched and | **anonymise** R13 |
| `local-path` | `docs/dev-log/issue-158-length-budget.md:123` | The calyx-engineering marketplace is registered as {"source": "directory", "path": "R:\arc"} | **anonymise** R13 |
| `local-path` | `docs/dev-log/issue-158-length-budget.md:124` | with installLocation: R:\arc, so uninstall/install operates on the repository itself. | **anonymise** R13 |
| `local-path` | `docs/dev-log/issue-160-topic-numbering.md:80` | Every run: RL_PROBE_BUDGET=0.80, cwd R:/arc-wt/160, one case, three turns, one session each. | **anonymise** R13 |
| `local-path` | `docs/dev-log/issue-160-topic-numbering.md:147` | marketplace is a directory source at R:\arc — **the main tree**. Run from a worktree it | **anonymise** R13 |
| `local-path` | `docs/dev-log/issue-160-topic-numbering.md:190` | One character corrected: the body reads R:^Grc where it means R:\arc, a backslash mangled | **anonymise** R13 |
| `local-path` | `docs/dev-log/issue-160-topic-numbering.md:195` | \| **A probe cannot see a worktree's edit.** The calyx-engineering marketplace is a directory source at R:\arc — the main tree — so tools/plugin-reload.sh r | **anonymise** R13 |
| `local-path` | `docs/dev-log/issue-166-activation-log.md:60` | marketplace at R:\arc), which does not carry the library, and tools/plugin-reload.sh says a | **anonymise** R13 |
| `local-path` | `docs/dev-log/issue-16-session-index.md:16` | \| Live worktrees under R:/arc-wt \| **5** \| | **anonymise** R13 |
| `local-path` | `docs/dev-log/issue-16-session-index.md:135` | \| R--arc-wt-16 \| R:/arc-wt/16 \| arc/04-dogfood-issue-16-session-index \| #16 \| arc/04-dogfood \| 2026-09-08 to 2026-09-08 \| live \| | **anonymise** R13 |
| `local-path` | `docs/dev-log/issue-210-tracker-verify-trunk.md:64` | Nothing is broken today — R:/arc/.git/arc-default-branch-trunk holds main, written from the | **anonymise** R13 |
| `local-path` | `docs/dev-log/issue-211-plugin-reload-dirty-tree.md:44` | git clone --no-hardlinks R:/arc "$SCRATCH/arc-scratch" # then check out the branch | **anonymise** R13 |
| `local-path` | `docs/dev-log/issue-211-plugin-reload-dirty-tree.md:70` | source pointing at R:\arc, so a reload run from a worktree installs from the main tree. | **anonymise** R13 |
| `local-path` | `docs/dev-log/issue-211-plugin-reload-dirty-tree.md:136` | \| **What actually reverted skills/chat-response/SKILL.md in #158 is unidentified.** This unit ruled out the only named suspect by measurement. The untested can | **anonymise** R13 |
| `local-path` | `docs/dev-log/issue-239-log-rotation.md:48` | R:/arc/.git/worktrees/238/COMMIT_EDITMSG holds the message with a later mtime than the commit, | **anonymise** R13 |
| `local-path` | `docs/dev-log/issue-252-probe-handoff.md:119` | plugins serving a handoff skill at once: arc@calyx-engineering from R:\arc, and | **anonymise** R13 |
| `local-path` | `docs/dev-log/issue-252-probe-handoff.md:158` | \| bash tools/plugin-reload.sh \| exit 0. Installed skills/handoff/SKILL.md sha1 5a9b650c5e46, byte-identical to this branch's and to the marketplace source R:\ | **anonymise** R13 |
| `local-path` | `docs/dev-log/issue-252-probe-handoff.md:163` | R:\arc, which was dirty throughout, so re-running the command today reports a refusal rather than | **anonymise** R13 |
| `local-path` | `docs/dev-log/issue-253-live-cold-start.md:21` | \| 1 · the handoff written at a boundary \| Session 803108a7, R:/arc/HANDOFF.md, mtime 20:37:16 EDT \| | **anonymise** R13 |
| `local-path` | `docs/dev-log/issue-253-live-cold-start.md:59` | **Written by the first attempt, in R:/arc-wt/252, before the opening existed.** Kept verbatim: | **anonymise** R13 |
| `local-path` | `docs/dev-log/issue-253-live-cold-start.md:66` | \| **It names a different actor** \| The orchestrating session is the one in the main tree. This is a loop-dispatched issue run in R:/arc-wt/252, handed two iss | **anonymise** R13 |
| `local-path` | `docs/dev-log/issue-253-live-cold-start.md:67` | \| **The real handoff is in the main tree** \| R:/arc/HANDOFF.md, gitignored, headed *2026-09-09 00:50*. Run-instructions §4: *never cd to the main tree — an | **anonymise** R13 |
| `local-path` | `docs/dev-log/issue-259-numbering-headroom.md:86` | R:/arc-wt/259. Raw replies kept via TN_PROBE_OUT and re-scored free after the instrument was | **anonymise** R13 |
| `local-path` | `docs/dev-log/issue-271-related-table.md:39` | body reads R:^Grc where it means R:\arc, a backslash mangled before this run touched it. | **anonymise** R13 |
| `local-path` | `docs/dev-log/issue-272-no-repo-path.md:48` | **Spawned [#294](https://github.com/Calyx-Engineering/arc/issues/294).** An absolute path whose whole ancestor chain is absent resolves differently by root form | **anonymise** R13 |
| `local-path` | `docs/dev-log/issue-85-issue-template.md:59` | \| Transcript excerpts in R:\arc-transcripts\ \| Uncommitted and outside the repo, so the reference is unresolvable for anyone else \| | **anonymise** R13 |
| `local-path` | `docs/dev-log/issue-87-guarded-write-back.md:27` | \| **Windows paths called out as the repeat offender** \| "C:\Users\...", "R:\arc-transcripts\" — \U and \a are escapes and a trailing \ eats the closing quot | **anonymise** R13 |
| `local-path` | `docs/dev-log/pr-115-transcript-staleness.md:15` | R:\arc-transcripts\ held twelve files; the handoff's table listed four. **The check trips, | **anonymise** R13 |
| `local-path` | `docs/dev-log/pr-200-run-and-dispatch-fixes.md:68` | **The kill switch failed at the moment it existed for.** Needed, attempted, landed at r:\arc\HOOKS_OFF.txt — wrong directory, wrong name, no effect. An extens | **anonymise** R13 |
| `local-path` | `docs/product-architecture/archive/HANDOFF.md:17` | architecture. TimeScope's repo (R:\vscode_customizations\timescope) was read directly | **move** R2 |
| `local-path` | `docs/product-architecture/archive/responsibility-decomposition.md:19` | R:\vscode_customizations\timescope and read directly. It holds substantially more | **move** R2 |
| `local-path` | `docs/reference-roadz/README.md:3` | **Copied verbatim from R:\work_lantern\roadz-sound-system, 2026-08-16.** These are | **move** R1 |
| `local-path` | `docs/reference-timescope/README.md:3` | **Copied verbatim from R:\vscode_customizations\timescope, 2026-08-16.** These are | **anonymise** R13 |
| `local-path` | `docs/retrospectives/2026-09-dogfood/README.md:18` | \| Sources \| 23 files · 86.6 MB — two transcript directories plus the 5 curated saves in R:\work_lantern\_transcripts, deduplicated on text and timestamp \| | **anonymise** R8 |
| `local-path` | `evals/environment-blame/issue-68-gain-sweep-bench-blame/turns/39.md:1` | <ide_opened_file>The user opened the file r:\work_lantern\roadz-sound-system\tools\mso8204_bode_sweep\bode_config.yaml in the IDE. This may or may not be relate | **move** R5 |
| `local-path` | `evals/response-length/too-many-words-20-words/turns/12.md:1` | <ide_opened_file>The user opened the file r:\arc\hooks\camp-session-start in the IDE. This may or may not be related to the current task.</ide_opened_file> | **anonymise** R13 |
| `local-path` | `evals/response-length/too-many-words-20-words/turns/19.md:1` | <ide_opened_file>The user opened the file r:\arc\HOOKS_OFF.txt in the IDE. This may or may not be related to the current task.</ide_opened_file> | **anonymise** R13 |
| `local-path` | `evals/saturation/issue-39-pinout-context-full/turns/2.md:1` | 1. clone lives here: R:\work_lantern\roadz_pb_firmware | **move** R5 |
| `local-path` | `evals/skill-firing/situation/copy-transcript-opening/prompt.md:2` | → R:\work_lantern\_transcripts\2026-09-04-arc-rev-b-pr70-closeout.jsonl | **anonymise** R13 |
| `local-path` | `evals/skill-firing/situation/log-this-in-friction-log/prompt.md:1` | <ide_selection>The user selected the lines 606 to 606 from r:\work_lantern\roadz-sound-system\.timescope\logs.jsonl: | **anonymise** R13 |
| `local-path` | `evals/skill-firing/wrapped/handoff-if-it-exists-cold-review/prompt.md:4` | R:\arc-transcripts\2026-08-20-arc03-issue-76-work-navigation.jsonl | **anonymise** R13 |
| `local-path` | `evals/skill-firing/wrapped/handoff-updated-elsewhere/prompt.md:1` | <ide_opened_file>The user opened the file r:\work_lantern\roadz-sound-system\HANDOFF.md in the IDE. This may or may not be related to the current task.</ide_ope | **anonymise** R13 |
| `local-path` | `hooks/camp-branch-check:118` | # The payload holds a JSON string, so a Windows cwd arrives as R:\\arc-wt\\162. Unescape it | **ship** R12 |
| `local-path` | `hooks/handoff-archive:217` | # Windows /tmp/x comes back as C:/Users/.../Temp/x. Comparing the two forms as strings makes | **ship** R12 |
| `local-path` | `hooks/session-index:22` | # live worktrees under R:/arc-wt 5 | **ship** R12 |
| `local-path` | `hooks/session-index:58` | # [A-Za-z0-9] becomes a hyphen, measured off the real store on 2026-09-08 (R:/arc-wt/16 is stored | **ship** R12 |
| `local-path` | `skills/issue-write/references/github.md:62` | non-raw string literal is the repeat offender: "C:\Users\..." fails at parse time, before the | **ship** R12 |
| `local-path` | `skills/issue-write/SKILL.md:678` | \| **A Windows path in a non-raw string literal** \| The repeat offender. "C:\Users\..." and "R:\arc-transcripts\" — \U and \a are escapes and a trailing \ ea | **ship** R12 |
| `local-path` | `templates/session-index.md:48` | \| Worktree \| The repository root the session ran in. **May no longer exist** — that is the whole point \| R:/arc-wt/16 \| | **anonymise** R13 |
| `local-path` | `tests/verify-session-index.sh:29` | # the real store on 2026-09-08 (R:/arc-wt/16 is stored as R--arc-wt-16), which is evidence rather | **ship** R12 |
| `local-path` | `tests/verify-session-index.sh:320` | # Measured off the real store 2026-09-08: R:/arc-wt/16 is stored as R--arc-wt-16, so every | **ship** R12 |
| `local-path` | `tests/verify-session-index.sh:438` | other='\| Z--elsewhere-arc-wt-7 \| Z:/elsewhere/arc-wt/7 \| arc/04-dogfood-issue-7-x \| #7 \| arc/04-dogfood \| 2026-09-01 to 2026-09-01 \| live \|' | **ship** R12 |
| `local-path` | `tests/verify-session-index.sh:525` | # The real store holds r--arc for R:/arc and R--arc-wt-16 for R:/arc-wt/16 — the same | **ship** R12 |
| `local-path` | `tools/arc-loop.sh:135` | # Same path form as $ROOT (R:/arc on Windows), so worktree paths read the same everywhere. | **anonymise** R13 |
| `local-path` | `tools/handoff-openings.sh:140` | H='r:\\repo\\HANDOFF.md' | **ship** R12 |
| `local-path` | `tools/handoff-openings.sh:141` | O='r:\\repo\\docs\\notes.md' | **ship** R12 |
| `local-path` | `tools/handoff-openings.sh:144` | HD='r:\\repo\\HANDOFF-notes\\scratch.md' | **ship** R12 |
| `local-path` | `tools/hook-cases/branch-guard/deny/main-windows-path.json:2` | {"tool_name":"Edit","cwd":"__FIXTURE_MAIN__","tool_input":{"file_path":"r:\\arc\\src\\index.ts"}} | **ship** R12 |
| `local-path` | `tools/hook-cases/mode-guard/deny/manual-commit-chained.json:2` | {"tool_name":"Bash","cwd":"__FIXTURE_MANUAL__","tool_input":{"command":"cd r:/arc && git add -A && git commit -m \"a, b, c\"","description":"Chained commit"}} | **ship** R12 |
| `local-path` | `tools/plugin-reload.sh:51` | # a directory source pointing at R:\arc, so a reload run from a worktree still installs from | **anonymise** R13 |
| `local-path` | `tools/probe-handoff-checks.sh:28` | # carried arc:handoff from R:\arc and arc-scratch:handoff from another run's scratch | **anonymise** R13 |
| `local-path` | `tools/report-grade.sh:13` | # R:/work_lantern — a path that exists on ONE machine. Everywhere else every | **anonymise** R13 |
| `local-path` | `tools/report-grade.sh:58` | CORPUS="${REPORT_CORPUS_DIR:-R:/work_lantern}" | **anonymise** R13 |
| `person` | `docs/dev-log/issue-134-public-audit.md:75` | \| **heliman, a second GitHub identity**, was reported only as calyx-name and took ship — it would have survived publication \| Added to person \| | **anonymise** R15 |
| `person` | `docs/dev-log/issue-134-public-audit.md:97` | lantern, roadz, heliman, interface-pcba, rp2040 and three bench slugs. Staging it before | **anonymise** R15 |
| `person` | `docs/product-architecture/mechanisms/m12-issue-linking.md:364` | \| What if the user lacks permissions? \| David hit this already — *"i dont have authority to do it so i asked chad"* \| | **anonymise** R15 |
| `person` | `docs/product-architecture/mechanisms/m14-commit-rhythm.md:108` | \| **Verify the commit identity** \| *"we are supposed to be on my davidcalyx ID … it makes no sense to be committing as davidcalyx and commenting as heliman" | **anonymise** R15 |
| `person` | `docs/product-architecture/mechanisms/m16-hardware-record-structure.md:94` | \| Audience \| **User-facing** — David, Chad, reviewers \| **Agent-facing** — future sessions, and David when digging \| | **anonymise** R15 |
| `person` | `docs/reference-roadz/ROADZ Interface PCBA Revision Workflow.md:165` | - Request review from Chad. | **move** R1 |
| `person` | `docs/reference-roadz/ROADZ Interface PCBA Revision Workflow.md:166` | - Chad reviews the branch directly in Altium (schematic + PCB). | **move** R1 |
| `person` | `docs/retrospectives/2026-08-plugin-line/friction-transcript-log.md:144` | > where the requirement came from - january 15th from chad on slack: [link]"* | **anonymise** R8 |
| `person` | `docs/retrospectives/2026-08-plugin-line/friction-transcript-log.md:182` | > *"i found how to do it. i dont have authority to do it so i asked chad. please manually | **anonymise** R8 |
| `person` | `evals/saturation/issue-39-pinout-context-full/turns/3.md:1` | so check me on this conclusion of where we are at so i can send to chad for review: | **move** R5 |
| `person` | `evals/saturation/issue-39-pinout-context-full/turns/31.md:4` | 7, 8 - TBD i'm not sure how chad uses these | **move** R5 |
| `person` | `evals/saturation/issue-39-pinout-context-full/turns/31.md:12` | 20 - i'm asking chad now, my inclination was to keep clk_out so make a note on this row that keeping/droping the signal is TBD, it would be HIZ either way i thi | **move** R5 |
| `person` | `evals/saturation/issue-39-pinout-context-full/turns/33.md:1` | i am in conversation with chad. give me a quick 20 word explanation of what RTC_INT does and what the code uses the RTC chip for | **move** R5 |
| `person` | `evals/saturation/issue-39-pinout-context-full/turns/5.md:3` | Flag on GP18 - agreed, close #9 as wont do - because of new power tree in #8. Its already reviewed because Chad already reviewed the power tree. closing #9 is j | **move** R5 |
| `person` | `evals/saturation/issue-39-pinout-context-full/turns/51.md:2` | chad didn't respond, i'm making assumptions on his response and may re-touch the pinout document later. but that is fine | **move** R5 |
| `person` | `evals/skill-firing/situation/push-work-ahead-of-40/prompt.md:3` | PR21 and PR22 are chad's thing, i have no idea what they are doing or why. i think chad and his Claude just left them hanging and i dont know what is going on | **anonymise** R15 |
| `profanity` | `agents/transcript-miner.md:121` | \| Exasperation \| uggh, ooof, hmmm, argh, sigh, wtf, christ, seriously \| | **ship** R9 |
| `profanity` | `docs/arc-work/04-dogfood/handoff-baseline.md:257` | The angry corrections in this session (*"LOAD ALL YOUR FUCKING SKILLS"*, the next morning) fall | **ask** R6 |
| `profanity` | `docs/dev-log/issue-134-public-audit.md:76` | \| **freaking** was not an expletive to the pattern \| Added \| | **anonymise** R14 |
| `profanity` | `docs/dev-log/issue-134-public-audit.md:91` | reverting any one of them left the case green, and freaking with no case at all. **One term per | **anonymise** R14 |
| `profanity` | `docs/product-architecture/mechanisms/m10-branch-guard.md:15` | > **"CRAP!! we screwed up big time. and we both missed it. we are supposed to be working | **anonymise** R14 |
| `profanity` | `docs/retrospectives/2026-08-plugin-line/friction-transcript-log.md:40` | > **"CRAP!! we screwed up big time. and we both missed it. we are supposed to be | **ask** R7 |
| `profanity` | `docs/retrospectives/2026-09-dogfood/README.md:132` | - *"MOTHER FUCKER!!!! / LOAD ALL YOUR FUCKING SKILLS!!!! / you mis-labeled the branch so you're not using your issure writing skill or SOMETHING!"* — 2026-08- | **ask** R7 |
| `profanity` | `docs/retrospectives/2026-09-dogfood/README.md:160` | - *"tangent - you haven't listened on conciseness - log that in friction log. this is bullshit and i'm angry now."* — 2026-08-28-...-pr68-gain-sweep-tool.json | **ask** R7 |
| `profanity` | `evals/environment-blame/issue-68-gain-sweep-bench-blame/turns/34.md:1` | go, I'm not by the test setup, I have to pick up the kids. you took too freaking long. | **move** R5 |
| `profanity` | `evals/response-length/verbose-again-60-words/turns/73.md:9` | David (me right now in this message): ".... what the fuck, thats literally what i just said, so why are you using HUNDREDS OF WORDS to tell me i'm wrong and the | **anonymise** R14 |
| `roadz` | `docs/arc-log/arc-03-camp.md:458` | \| [#32](https://github.com/Calyx-Engineering/arc/issues/32) \| Size an issue title to what merging delivers \| **m11** issue-writing \| [skills/issue-write](.. | **anonymise** R17 |
| `roadz` | `docs/arc-log/arc-04-dogfood.md:12` | installed, and three weeks of real hardware work ran against it in ROADZ. | **anonymise** R17 |
| `roadz` | `docs/arc-log/arc-04-dogfood.md:30` | W["Real work<br/>ROADZ, 3 weeks"] --> T["Transcripts<br/>68 MB, 19 files"] | **anonymise** R17 |
| `roadz` | `docs/arc-log/arc-04-dogfood.md:172` | [#17](https://github.com/Calyx-Engineering/arc/issues/17)** — the fix that worked in ROADZ left | **anonymise** R17 |
| `roadz` | `docs/arc-log/arc-04-dogfood.md:577` | - [friction-log.md](https://github.com/Lantern-Systems/roadz-sound-system/blob/main/docs/arc-work/interface-pcba-rev-b/friction-log.md) — ROADZ's hand-written | **anonymise** R17 |
| `roadz` | `docs/arc-log/arc-04-dogfood.md:607` | \| tools/plugin-reload.sh ([#132](https://github.com/Calyx-Engineering/arc/issues/132)) \| Its own test, then nothing since \| **Partially soaked.** The uninsta | **anonymise** R17 |
| `roadz` | `docs/arc-work/02-foundation/closing-keywords-and-base-branch.md:4` | ROADZ's issue-writing skill: *"Observed on one repository, not isolated as a variable."* | **anonymise** R17 |
| `roadz` | `docs/arc-work/02-foundation/closing-keywords-and-base-branch.md:58` | - ROADZ issue-writing — where the unconfirmed observation was recorded | **anonymise** R17 |
| `roadz` | `docs/arc-work/04-dogfood/handoff-baseline.md:18` | bash tools/handoff-openings.sh r--work-lantern-roadz-sound-system r--arc \ | **ask** R6 |
| `roadz` | `docs/arc-work/04-dogfood/handoff-baseline.md:23` | the corpus lives in two of them — ROADZ and this repository; the ROADZ worktree directory | **ask** R6 |
| `roadz` | `docs/arc-work/04-dogfood/handoff-baseline.md:82` | \| 1 \| C2 \| Reported state and the next move, never why the pinout work was the approach \| **Not in it.** There was no handoff. Its writer put a careful docu | **ask** R6 |
| `roadz` | `docs/arc-work/04-dogfood/handoff-baseline.md:214` | went to a session scratchpad headed *"For a fresh chat. Not committed to ROADZ — this discussion | **ask** R6 |
| `roadz` | `docs/arc-work/04-dogfood/handoff-baseline.md:225` | - **C1** — 20:22:14.139Z: *"1. Clone roadz_pb_firmware, grep board-command for GP20/GP7/GP8 usage. 2. Fill §3.1 rows 2–4 with firmware evidence — no infe | **ask** R6 |
| `roadz` | `docs/arc-work/04-dogfood/handoff-baseline.md:226` | - **User next** — 20:25:29.904Z: *"1. clone lives here: R:\work_lantern\roadz_pb_firmware / you will want to pull the latest from origin. / 2. also, previous  | **ask** R6 |
| `roadz` | `docs/arc-work/04-dogfood/handoff-baseline.md:227` | - **The handoff's own lines**, 20:22:09.967Z: *"https://github.com/Lantern-Systems/roadz_pb_firmware — **not cloned here**"* and *"Fill in rows 2–4 with wha | **ask** R6 |
| `roadz` | `docs/arc-work/04-dogfood/handoff-rationale.md:27` | \| 1 \| C2 \| Nothing was carried. The writer's document went to a session scratchpad headed *"Not committed to ROADZ"*, and the reader found =====HANDOFF=====  | **anonymise** R17 |
| `roadz` | `docs/arc-work/04-dogfood/handoff-rationale.md:71` | bash tools/handoff-openings.sh r--work-lantern-roadz-sound-system r--arc \ | **anonymise** R17 |
| `roadz` | `docs/arc-work/04-dogfood/issue-plan.md:86` | \| Loop-1 \| [#138](https://github.com/Calyx-Engineering/arc/issues/138) an approved merge cannot run \| **You guide this.** You solved it in ROADZ and it left  | **anonymise** R17 |
| `roadz` | `docs/arc-work/04-dogfood/issue-plan.md:122` | \| Fire-8 \| [#162](https://github.com/Calyx-Engineering/arc/issues/162) camp-branch-check rejects conforming branches \| **P1.** Fired 5 times, correct 0 \| Re | **anonymise** R17 |
| `roadz` | `docs/arc-work/04-dogfood/skill-firing-baseline.md:13` | bash tools/skill-firing.sh r--work-lantern-roadz-sound-system r--arc --since 2026-08-24T09:40 | **anonymise** R17 |
| `roadz` | `docs/arc-work/04-dogfood/skill-firing-baseline.md:16` | **Corpus:** 11 sessions across 3 directories — this repository and ROADZ, including its worktree | **anonymise** R17 |
| `roadz` | `docs/arc-work/04-dogfood/skill-firing-baseline.md:66` | bash tools/skill-firing.sh r--work-lantern-roadz-sound-system r--arc --since 2026-08-24T09:40 | **anonymise** R17 |
| `roadz` | `docs/dev-log/issue-134-public-audit.md:27` | \| **One line can produce several rows** \| R:\work_lantern\roadz-sound-system is a machine path *and* a client name *and* a product name. Three separate decisi | **anonymise** R17 |
| `roadz` | `docs/dev-log/issue-134-public-audit.md:73` | \| **The three excluded files ship and had no disposition.** tools/audit-public.sh's class table is a dictionary of the client's parts; the audit quotes every h | **anonymise** R17 |
| `roadz` | `docs/dev-log/issue-134-public-audit.md:97` | lantern, roadz, heliman, interface-pcba, rp2040 and three bench slugs. Staging it before | **anonymise** R17 |
| `roadz` | `docs/dev-log/issue-135-related-table.md:11` | session-shaped. Observed in ROADZ: eight corrections between 2026-08-14 and 2026-09-05, with | **anonymise** R17 |
| `roadz` | `docs/dev-log/issue-136-manual-linking.md:75` | branch"* from ROADZ PR #55; m42 opens with *"GitHub ignores a closing keyword unless the PR | **anonymise** R17 |
| `roadz` | `docs/dev-log/issue-138-merge-route.md:16` | \| ROADZ \| 3 \| All three are copying a .jsonl transcript. **Zero merges** \| | **anonymise** R17 |
| `roadz` | `docs/dev-log/issue-138-merge-route.md:18` | ROADZ ran 12 merges and none was denied. Transcript-copy denial is a different gate — a data-egress shape, not an authorization one — and it was wrongly fol | **anonymise** R17 |
| `roadz` | `docs/dev-log/issue-138-merge-route.md:22` | ROADZ was fixed on install day, [44dbb06](https://github.com/Lantern-Systems/roadz-sound-system/commit/44dbb06): *"Two copies of the same rule drift, and the co | **anonymise** R17 |
| `roadz` | `docs/dev-log/issue-138-merge-route.md:24` | \| \| arc \| ROADZ \| | **anonymise** R17 |
| `roadz` | `docs/dev-log/issue-138-merge-route.md:50` | \| CLAUDE.md \| 231 → 148 lines. Mode stated once in ROADZ's shape; five preference rows, the branch mechanics, the gap-routing steps and the local-copies rat | **anonymise** R17 |
| `roadz` | `docs/dev-log/issue-138-merge-route.md:64` | **Two conflations were caught during the work.** Transcript-copy denials were folded into the evidence and pulled back out — same error string, different gate | **anonymise** R17 |
| `roadz` | `docs/dev-log/issue-140-read-back.md:9` | succeeds, every gate passes, and the record is wrong. Observed in ROADZ (PR #67, four stale README | **anonymise** R17 |
| `roadz` | `docs/dev-log/issue-140-read-back.md:37` | \| **A verify-all.sh gate on the read-back itself** \| Forbidden by the issue's first constraint, and correct: prose truth is not mechanically checkable. 78 off | **anonymise** R17 |
| `roadz` | `docs/dev-log/issue-141-miner-scope.md:7` | agents/transcript-miner said *"glob across every matching raw directory, never one"*, because worktrees get their own slug and a deleted worktree leaves an orph | **anonymise** R17 |
| `roadz` | `docs/dev-log/issue-141-miner-scope.md:17` | A directory is **IN** when, case-insensitively, its slug equals a briefed slug or begins with a briefed slug followed by -- — the worktree form. **A shared st | **anonymise** R17 |
| `roadz` | `docs/dev-log/issue-149-skill-firing.md:38` | [skill-firing-baseline.md](../arc-work/04-dogfood/skill-firing-baseline.md) — 11 post-install sessions across this repository and ROADZ. | **anonymise** R17 |
| `roadz` | `docs/dev-log/issue-14-work-watch.md:32` | **engineering-report gains a K-tier framing on the way across.** ROADZ's version says "one | **anonymise** R17 |
| `roadz` | `docs/dev-log/issue-159-report-conclusion-first.md:22` | \| evals/report-shape/ \| Three cases, each an excerpt copied verbatim from a real report in the ROADZ corpus, with the document and line range it came from. #1 | **anonymise** R17 |
| `roadz` | `docs/dev-log/issue-162-branch-convention.md:18` | Arc names arcs arc/<nn>-<slug>. [ROADZ](https://github.com/Lantern-Systems/roadz-sound-system) names them after the product component being revised, and declare | **anonymise** R17 |
| `roadz` | `docs/dev-log/issue-162-branch-convention.md:37` | \| **issue and pr are not derived** \| ROADZ's CLAUDE.md declares only the issue form, and its real …-pr58-arc-setup branches conform. Deriving labels *only*  | **anonymise** R17 |
| `roadz` | `docs/dev-log/issue-162-branch-convention.md:39` | \| **A name the section spells out in full is exempt** \| ROADZ declares interface-pcba/rev_b as its integration branch two lines above the work-branch form. It | **anonymise** R17 |
| `roadz` | `docs/dev-log/issue-162-branch-convention.md:49` | \| fixtures/roadz \| ROADZ's declared convention. The **regression** fixture: five of its real branch names, all of which reported before this change \| | **anonymise** R17 |
| `roadz` | `docs/dev-log/issue-162-branch-convention.md:53` | The real ROADZ names, all previously reported and all now passing: interface-pcba/rev_b-issue-1-dimmer-flasher, interface-pcba/rev-b-issue-15-audio-out-isolatio | **anonymise** R17 |
| `roadz` | `docs/dev-log/issue-162-branch-convention.md:76` | Before the change, the case directory as it then stood ran 15 passed, 5 failed. Against the directory as it stands now, the old hook runs 17 passed, 10 failed,  | **anonymise** R17 |
| `roadz` | `docs/dev-log/issue-162-branch-convention.md:82` | **Pass 1**, against the issue: nine findings. Seven in scope and fixed — git branch \| grep foo reported on \|; ROADZ's own integration branch was reported; t | **anonymise** R17 |
| `roadz` | `docs/dev-log/issue-162-branch-convention.md:103` | Unsoaked at merge. A hook change is exercised by the next work stretch that creates a branch — in this repo or in ROADZ, whose real names are now the regressi | **anonymise** R17 |
| `roadz` | `docs/dev-log/issue-16-session-index.md:20` | m32 recorded 2 orphans in ROADZ. This repository has seventeen. tools/arc-loop.sh names its | **anonymise** R17 |
| `roadz` | `docs/dev-log/issue-16-session-index.md:22` | alone — ROADZ's are not named that way, and there an orphan is a bare path. | **anonymise** R17 |
| `roadz` | `docs/dev-log/issue-16-session-index.md:37` | key because of m32's measured ROADZ case: #39 was worked on a branch *in the main repo*, and its | **anonymise** R17 |
| `roadz` | `docs/dev-log/issue-16-session-index.md:87` | \| **A worktree-removal trigger** \| m32 already measured this wrong: work done on a branch *in the main repo* never fires one, and that was ROADZ's #39 \| | **anonymise** R17 |
| `roadz` | `docs/dev-log/issue-17-transcript-miner.md:27` | **Exercised before it was registered.** The agent ran against 68 MB of ROADZ transcripts with its | **anonymise** R17 |
| `roadz` | `docs/dev-log/issue-17-transcript-miner.md:76` | ROADZ transcripts. | **anonymise** R17 |
| `roadz` | `docs/dev-log/issue-206-linked-branch-readback.md:97` | \| **Re-counting the ROADZ survey in m12** \| Different repo, not re-run here. Its conclusion is left standing and the recount marked unmeasured rather than ass | **anonymise** R17 |
| `roadz` | `docs/dev-log/issue-32-size-the-title.md:39` | \| **m11's spec is a frozen reference, not an editable spec** \| §9 traces this issue to m11, whose registry row links [docs/reference-roadz/issue-writing/SKIL | **anonymise** R17 |
| `roadz` | `docs/dev-log/issue-32-size-the-title.md:64` | \| + \| **m11's registry row** — pointed at the frozen ROADZ copy, where the rule does not exist \| Done, 319e45e \| | **anonymise** R17 |
| `roadz` | `docs/dev-log/issue-32-size-the-title.md:94` | \| *Consistent with every file in the repo?* \| m11's registry row pointed at the do-not-edit ROADZ copy, which has none of this. A session following the regist | **anonymise** R17 |
| `roadz` | `docs/dev-log/issue-48-skill-parity.md:53` | \| **Out of scope** \| Redesigning the copy arrangement — it is deleted at first release ([#68](https://github.com/Calyx-Engineering/arc/issues/68)'s own cons | **anonymise** R17 |
| `roadz` | `docs/dev-log/issue-48-skill-parity.md:72` | \| 6 \| **Repoint two registry rows** at skills/ — m18, which links the frozen docs/reference-roadz/ copy, and m33, which links .claude/skills/ \| | **anonymise** R17 |
| `roadz` | `docs/product-architecture/archive/HANDOFF.md:15` | A retrospective mined 28 Claude Code transcripts from four weeks of ROADZ hardware work | **move** R2 |
| `roadz` | `docs/product-architecture/archive/HANDOFF.md:133` | - ROADZ issue #1's worktree transcript is **not yet distilled** — David planned to delete | **move** R2 |
| `roadz` | `docs/product-architecture/archive/product-plan.md:129` | \| **Source** \| 🔥 friction — this retrospective \| 📐 design — Lodestar docs 01–04 \| ⚙️ proven — runs in TimeScope or ROADZ \| \| | **move** R2 |
| `roadz` | `docs/product-architecture/archive/product-plan.md:189` | ROADZ; most of the rest are low-effort adaptation. Its Agents and Self-improve groups are | **move** R2 |
| `roadz` | `docs/product-architecture/archive/responsibility-decomposition.md:73` | \| **State today** \| Open design (doc 04); branch pattern working in ROADZ but unwritten \| | **move** R2 |
| `roadz` | `docs/product-architecture/archive/responsibility-decomposition.md:85` | \| **State today** \| **Split verdict.** ROADZ ddr/_ddr.md = empty stub. TimeScope = **13 dev-logs + a working arc-log**, hook-enforced \| | **move** R2 |
| `roadz` | `docs/product-architecture/archive/responsibility-decomposition.md:95` | variable is not domain, it is whether a mechanism exists. ROADZ has no dev-log | **move** R2 |
| `roadz` | `docs/product-architecture/archive/responsibility-decomposition.md:108` | \| **State today** \| **Working in both repos.** ROADZ 11 pages + dated ingest log; TimeScope 6 pages. Third-party agent-wiki plugin — **decision: fork it** ( | **move** R2 |
| `roadz` | `docs/product-architecture/archive/responsibility-decomposition.md:120` | \| **State today** \| Built and portable — issue-writing, engineering-report. Link mechanics stuck in ROADZ CLAUDE.md \| | **move** R2 |
| `roadz` | `docs/product-architecture/archive/responsibility-decomposition.md:172` | \| **State today** \| **SW: solved by convention** (git, semver, tags — TimeScope's release skill does this). **HW: unsupported.** ROADZ has design_notebook/c | **move** R2 |
| `roadz` | `docs/product-architecture/archive/responsibility-decomposition.md:184` | the configuration it was measured against. ROADZ's own verification log format already | **move** R2 |
| `roadz` | `docs/product-architecture/archive/responsibility-decomposition.md:198` | surfaced from ROADZ. A software-only view of this problem would have missed it entirely. | **move** R2 |
| `roadz` | `docs/product-architecture/archive/responsibility-decomposition.md:207` | \| Artifact \| TimeScope (SW) \| ROADZ (HW) \| Mechanism present? \| | **move** R2 |
| `roadz` | `docs/product-architecture/archive/responsibility-decomposition.md:210` | \| **Rationale logs** \| **13 dev-logs + 1 arc-log** \| **0** (title-only stub) \| ✅ TS: template + Stop hook gate + skill. ❌ ROADZ: none \| | **move** R2 |
| `roadz` | `docs/product-architecture/archive/responsibility-decomposition.md:218` | with a filename and good intentions. Nothing about hardware caused the ROADZ stub. | **move** R2 |
| `roadz` | `docs/product-architecture/archive/responsibility-decomposition.md:223` | has **2 written stories and 11 admitted placeholders.** ROADZ has 2 stories. Two | **move** R2 |
| `roadz` | `docs/product-architecture/archive/responsibility-decomposition.md:277` | \| **R2 ↔ R9** \| TIGHT \| A verification result is meaningless without the configuration it was measured against. ROADZ's log format already fuses them infor | **move** R2 |
| `roadz` | `docs/product-architecture/archive/responsibility-decomposition.md:471` | both failed in ROADZ for the same reason, both are read by everyone. | **move** R2 |
| `roadz` | `docs/product-architecture/archive/responsibility-decomposition.md:490` | \| **arc** (name TBD) \| R3 + R6 + R2b + R4 + **R9** — arc spine, waves, branch model, issues/PRs, reports, dev-logs, **configuration management** \| TimeScop | **move** R2 |
| `roadz` | `docs/product-architecture/archive/responsibility-decomposition.md:492` | \| **ee-toolbox** \| R7 — netlist, schematic parse, bench instruments \| ROADZ \| **Extraction, domain-total** \| | **move** R2 |
| `roadz` | `docs/product-architecture/archive/responsibility-decomposition.md:715` | **Why it matters beyond convenience.** ROADZ currently sets the *arc branch* as the repo | **move** R2 |
| `roadz` | `docs/product-architecture/archive/responsibility-decomposition.md:718` | state. Worse, it silently mis-links rather than failing loudly (ROADZ #44/#45). | **move** R2 |
| `roadz` | `docs/product-architecture/archive/responsibility-decomposition.md:749` | **Not decided.** Flagged because ROADZ's empty ddr/_ddr.md is the DDR half, and it is | **move** R2 |
| `roadz` | `docs/product-architecture/archive/what-the-tools-do.md:88` | branch pattern is proven in hardware (ROADZ), but the two modes differ in control flow | **move** R2 |
| `roadz` | `docs/product-architecture/archive/what-the-tools-do.md:148` | Counted directly from ROADZ (hardware, four weeks of real work) and TimeScope | **move** R2 |
| `roadz` | `docs/product-architecture/archive/what-the-tools-do.md:153` | \| **Manage requirements** \| ❌ **Nothing works, in either repo** \| TimeScope: 2 stories + 11 admitted placeholders. ROADZ: 2 stories. Test plans hand-writte | **move** R2 |
| `roadz` | `docs/product-architecture/archive/what-the-tools-do.md:157` | \| **Track** \| ⚠️ Works via a trick \| ROADZ sets the arc branch as repo default so gh auto-links. Not multi-user safe \| | **move** R2 |
| `roadz` | `docs/product-architecture/archive/what-the-tools-do.md:160` | \| **Record why** \| ✅ Software; ❌ hardware \| TimeScope 13 dev-logs + arc-log. ROADZ: an empty stub \| | **move** R2 |
| `roadz` | `docs/product-architecture/archive/what-the-tools-do.md:161` | \| **Remember** \| ✅ **Works in both** \| ROADZ 11 wiki pages + dated log; TimeScope 6 pages \| | **move** R2 |
| `roadz` | `docs/product-architecture/archive/what-the-tools-do.md:263` | **The evidence.** [friction-transcript-log.md](../../retrospectives/2026-08-plugin-line/friction-transcript-log.md) was produced by reading 28 ROADZ | **move** R2 |
| `roadz` | `docs/product-architecture/mechanisms/m09-kickoff-scope-gate.md:16` | TimeScope enforces this as a literal stop before any branch is created. ROADZ has the same | **anonymise** R17 |
| `roadz` | `docs/product-architecture/mechanisms/m09-kickoff-scope-gate.md:18` | [Interface PCBA revision workflow](../../reference-roadz/ROADZ%20Interface%20PCBA%20Revision%20Workflow.md) | **anonymise** R17 |
| `roadz` | `docs/product-architecture/mechanisms/m09-kickoff-scope-gate.md:42` | **Branch naming comes out of this step.** ROADZ names an arc after the product component | **anonymise** R17 |
| `roadz` | `docs/product-architecture/mechanisms/m09-kickoff-scope-gate.md:73` | - [ROADZ Interface PCBA revision workflow](../../reference-roadz/ROADZ%20Interface%20PCBA%20Revision%20Workflow.md) — the guided flow, steps 1–3 | **anonymise** R17 |
| `roadz` | `docs/product-architecture/mechanisms/m12-issue-linking.md:43` | Same silent-failure class, different symptom. ROADZ hit it once: | **anonymise** R17 |
| `roadz` | `docs/product-architecture/mechanisms/m12-issue-linking.md:46` | > (PR #41) and needed a recovery merge."* — ROADZ CLAUDE.md | **anonymise** R17 |
| `roadz` | `docs/product-architecture/mechanisms/m12-issue-linking.md:60` | ROADZ currently sets the arc branch as repo default so gh auto-links Closes #NN. | **anonymise** R17 |
| `roadz` | `docs/product-architecture/mechanisms/m12-issue-linking.md:80` | It is a **parse-time quirk, not a base-branch restriction.** The ROADZ workaround was | **anonymise** R17 |
| `roadz` | `docs/product-architecture/mechanisms/m12-issue-linking.md:107` | \| Force re-parse \| Re-save the PR body (gh pr edit --body) \| ✅ documented in ROADZ CLAUDE.md \| | **anonymise** R17 |
| `roadz` | `docs/product-architecture/mechanisms/m12-issue-linking.md:195` | **What this does to the ROADZ survey below is unmeasured.** Its conclusion — git checkout -b | **anonymise** R17 |
| `roadz` | `docs/product-architecture/mechanisms/m12-issue-linking.md:197` | But the survey counted linkedBranches alone, and any ROADZ issue whose link *had* been promoted | **anonymise** R17 |
| `roadz` | `docs/product-architecture/mechanisms/m12-issue-linking.md:201` | ### The measured state of ROADZ | **anonymise** R17 |
| `roadz` | `docs/product-architecture/mechanisms/m12-issue-linking.md:331` | ROADZ issue #42 tracks restoring main as default at rev B close — that is m42's restore step, | **anonymise** R17 |
| `roadz` | `docs/product-architecture/mechanisms/m12-issue-linking.md:379` | - ROADZ CLAUDE.md — the same workaround, applied there before either mechanism existed; issue | **anonymise** R17 |
| `roadz` | `docs/product-architecture/mechanisms/m13-issue-write-back.md:61` | > decisions or thoughts. thats not what the section is for..."* — ROADZ, 2026-08-14 | **anonymise** R17 |
| `roadz` | `docs/product-architecture/mechanisms/m13-issue-write-back.md:63` | > *"why are you adding documents to the spawned section?"* — ROADZ | **anonymise** R17 |
| `roadz` | `docs/product-architecture/mechanisms/m13-issue-write-back.md:186` | Already known and documented in ROADZ CLAUDE.md — Closes #NN silently fails against | **anonymise** R17 |
| `roadz` | `docs/product-architecture/mechanisms/m13-issue-write-back.md:211` | - ROADZ .claude/skills/issue-writing/SKILL.md — the skill under evaluation | **anonymise** R17 |
| `roadz` | `docs/product-architecture/mechanisms/m14-commit-rhythm.md:181` | - ROADZ CLAUDE.md — tracker link mechanics | **anonymise** R17 |
| `roadz` | `docs/product-architecture/mechanisms/m15-handoff-spine.md:33` | \| **ROADZ handoff files** \| Ad-hoc markdown \| Written at session end \| **Tried and proved insufficient** — the 2026-08-10 failure \| | **anonymise** R17 |
| `roadz` | `docs/product-architecture/mechanisms/m15-handoff-spine.md:92` | failed bench attempt. In ROADZ that material lives in docs/report/issue-NN-*/, a | **anonymise** R17 |
| `roadz` | `docs/product-architecture/mechanisms/m15-handoff-spine.md:231` | Issues already record what spawned them (ROADZ practice, and the subject of the | **anonymise** R17 |
| `roadz` | `docs/product-architecture/mechanisms/m15-handoff-spine.md:292` | - ROADZ CLAUDE.md — arc-tracking GitHub mechanics | **anonymise** R17 |
| `roadz` | `docs/product-architecture/mechanisms/m16-hardware-record-structure.md:3` | **Status:** specified. Mostly **already grown organically in ROADZ** — this documents and | **anonymise** R17 |
| `roadz` | `docs/product-architecture/mechanisms/m16-hardware-record-structure.md:31` | ## What ROADZ already grew | **anonymise** R17 |
| `roadz` | `docs/product-architecture/mechanisms/m16-hardware-record-structure.md:78` | \| **Report vs dev-log unclear** \| ROADZ has docs/report/issue-NN/; TimeScope has docs/dev-log/issue-NN.md. Both per-issue, different purposes, no stated relat | **anonymise** R17 |
| `roadz` | `docs/product-architecture/mechanisms/m16-hardware-record-structure.md:400` | the one a future agent trusts. ROADZ .claude/wiki/speaker-power.md is a good example | **anonymise** R17 |
| `roadz` | `docs/product-architecture/mechanisms/m16-hardware-record-structure.md:431` | \| report/ or a neutral name? \| ROADZ calls it report/, but not everything in it is a report. analysis/ may fit better \| | **anonymise** R17 |
| `roadz` | `docs/product-architecture/mechanisms/m16-hardware-record-structure.md:434` | \| Figure naming \| ROADZ uses c25-0nf-1khz.png — condition-encoded. Worth making a convention \| | **anonymise** R17 |
| `roadz` | `docs/product-architecture/mechanisms/m16-hardware-record-structure.md:444` | - ROADZ docs/report/issue-01-warning-light-dimming/ — the working example | **anonymise** R17 |
| `roadz` | `docs/product-architecture/mechanisms/m16-hardware-record-structure.md:445` | - ROADZ .claude/skills/engineering-report/SKILL.md — governs K3 content | **anonymise** R17 |
| `roadz` | `docs/product-architecture/mechanisms/m17-k1-upkeep.md:31` | one read. Thirteen dev-logs exist. ROADZ has the same structure as an empty stub, which is | **anonymise** R17 |
| `roadz` | `docs/product-architecture/mechanisms/m17-k1-upkeep.md:35` | files above), enforcement (a Stop hook gating the PR). ROADZ had the template and neither | **anonymise** R17 |
| `roadz` | `docs/product-architecture/mechanisms/m20-arc-decomposition.md:56` | reliably. Guided hardware has no equivalent unit; the ROADZ rule is one issue per | **anonymise** R17 |
| `roadz` | `docs/product-architecture/mechanisms/m21-arc-tree.md:25` | Issues already record what spawned them — established ROADZ practice — so the data exists. | **anonymise** R17 |
| `roadz` | `docs/product-architecture/mechanisms/m21-arc-tree.md:78` | effort caused the issue to exist. ROADZ got this wrong at least once. The tree is only as | **anonymise** R17 |
| `roadz` | `docs/product-architecture/mechanisms/m22-configuration-management.md:35` | ROADZ names an arc branch after the product component being revised. That vocabulary — the | **anonymise** R17 |
| `roadz` | `docs/product-architecture/mechanisms/m22-configuration-management.md:55` | \| What does the CM need to see? \| The manufacturing package is the real artifact — see the ROADZ workflow, steps 6–7 \| | **anonymise** R17 |
| `roadz` | `docs/product-architecture/mechanisms/m22-configuration-management.md:62` | - [ROADZ workflow](../../reference-roadz/ROADZ%20Interface%20PCBA%20Revision%20Workflow.md) — steps 6–8, the manufacturing package and its record | **anonymise** R17 |
| `roadz` | `docs/product-architecture/mechanisms/m23-test-obligation-capture.md:3` | **Status:** specified. Already run by hand throughout ROADZ rev B. | **anonymise** R17 |
| `roadz` | `docs/product-architecture/mechanisms/m23-test-obligation-capture.md:18` | > of issues"* — David, ROADZ | **anonymise** R17 |
| `roadz` | `docs/product-architecture/mechanisms/m23-test-obligation-capture.md:40` | **Append or spawn is a judgement call.** ROADZ practice leans hard toward append: | **anonymise** R17 |
| `roadz` | `docs/product-architecture/mechanisms/m23-test-obligation-capture.md:50` | ## What ROADZ already establishes | **anonymise** R17 |
| `roadz` | `docs/product-architecture/mechanisms/m23-test-obligation-capture.md:90` | \| Cross-repo test items \| ROADZ firmware tests belong to roadz_pb_firmware, the design issue does not \| | **anonymise** R17 |
| `roadz` | `docs/product-architecture/mechanisms/m28-human-gate.md:55` | [ROADZ workflow](../../reference-roadz/ROADZ%20Interface%20PCBA%20Revision%20Workflow.md) | **anonymise** R17 |
| `roadz` | `docs/product-architecture/mechanisms/m28-human-gate.md:83` | - [ROADZ workflow](../../reference-roadz/ROADZ%20Interface%20PCBA%20Revision%20Workflow.md) — steps 5–8, the guided gates | **anonymise** R17 |
| `roadz` | `docs/product-architecture/mechanisms/m29-agent-wiki.md:16` | Working in both repos surveyed during the retrospective — ROADZ has 14 pages, TimeScope 6. | **anonymise** R17 |
| `roadz` | `docs/product-architecture/mechanisms/m29-agent-wiki.md:61` | testing, gotchas, plus the index. ROADZ grew fourteen, and they are hardware subjects — | **anonymise** R17 |
| `roadz` | `docs/product-architecture/mechanisms/m30-transcript-mining.md:43` | Proven once, by hand, on 2026-08-16. Reading 28 ROADZ transcripts corrected three | **anonymise** R17 |
| `roadz` | `docs/product-architecture/mechanisms/m30-transcript-mining.md:52` | Two skills in ROADZ (engineering-report, issue-writing) were precipitated out of | **anonymise** R17 |
| `roadz` | `docs/product-architecture/mechanisms/m30-transcript-mining.md:170` | \| **Cross-repo?** \| Patterns recurring in *both* ROADZ and TimeScope are portable-skill candidates by definition. Strong argument for scanning all projects, n | **anonymise** R17 |
| `roadz` | `docs/product-architecture/mechanisms/m30-transcript-mining.md:181` | - ROADZ .claude/skills/engineering-report, issue-writing — both precipitated from | **anonymise** R17 |
| `roadz` | `docs/product-architecture/mechanisms/m31-self-improvement-loop.md:333` | A worked example — one ROADZ issue, five plugin edits: | **anonymise** R17 |
| `roadz` | `docs/product-architecture/mechanisms/m31-self-improvement-loop.md:340` | \| Push \| ROADZ PR goes up. Plugin repo gets **its own PR**, carrying the 3 soaked edits \| | **anonymise** R17 |
| `roadz` | `docs/product-architecture/mechanisms/m31-self-improvement-loop.md:358` | soak: roadz 2026-08-16..09-13, 4 weeks live | **anonymise** R17 |
| `roadz` | `docs/product-architecture/mechanisms/m31-self-improvement-loop.md:362` | then exercised for four weeks in ROADZ, would leave its only evidence in a TimeScope | **anonymise** R17 |
| `roadz` | `docs/product-architecture/mechanisms/m32-session-preservation.md:19` | \| Live worktrees in ROADZ \| **2** \| | **anonymise** R17 |
| `roadz` | `docs/product-architecture/mechanisms/m32-session-preservation.md:20` | \| Transcript directories for ROADZ \| **4** \| | **anonymise** R17 |
| `roadz` | `docs/product-architecture/mechanisms/m32-session-preservation.md:127` | **Worktree removal is the wrong trigger.** Measured in ROADZ, 2026-08-16: | **anonymise** R17 |
| `roadz` | `docs/product-architecture/mechanisms/m32-session-preservation.md:134` | ROADZ's #39 work is on a branch in the main repo, not a worktree. A removal-based trigger | **anonymise** R17 |
| `roadz` | `docs/product-architecture/mechanisms/m40-autonomy-switch.md:322` | \| \| arc \| ROADZ \| | **anonymise** R17 |
| `roadz` | `docs/product-architecture/mechanisms/m40-autonomy-switch.md:327` | ROADZ reached one statement on install day, [44dbb06](https://github.com/Lantern-Systems/roadz-sound-system/commit/44dbb06): | **anonymise** R17 |
| `roadz` | `docs/product-architecture/mechanisms/m41-relief-valve.md:142` | [#36](https://github.com/Calyx-Engineering/arc/issues/36) mines this repository, ROADZ and | **anonymise** R17 |
| `roadz` | `docs/product-architecture/mechanisms/m41-relief-valve.md:175` | person's sessions in a docs-heavy repo. Hardware work in ROADZ may have a different natural | **anonymise** R17 |
| `roadz` | `docs/reference-roadz/README.md:1` | # Reference — ROADZ | **move** R1 |
| `roadz` | `docs/reference-roadz/README.md:3` | **Copied verbatim from R:\work_lantern\roadz-sound-system, 2026-08-16.** These are | **move** R1 |
| `roadz` | `docs/reference-roadz/README.md:4` | ROADZ's real working skills, not Arc's. They are here as the **source material** for | **move** R1 |
| `roadz` | `docs/reference-roadz/README.md:21` | is a copy plus whatever generalisation is needed to lift ROADZ-specific detail out. | **move** R1 |
| `roadz` | `docs/reference-roadz/ROADZ Interface PCBA Revision Workflow.md:1` | # ROADZ Interface PCBA Revision Workflow | **move** R1 |
| `roadz` | `docs/reference-roadz/ROADZ Interface PCBA Revision Workflow.md:4` | This document outlines a recommended workflow for planning, executing, reviewing, and releasing revisions of the **Interface PCBA** within the ROADZ Speaker Sys | **move** R1 |
| `roadz` | `docs/retrospectives/2026-08-plugin-line/friction-transcript-log.md:1` | # Friction transcript log — ROADZ rev B, 2026-07-21 → 2026-08-14 | **anonymise** R8 |
| `roadz` | `docs/retrospectives/2026-08-plugin-line/friction-transcript-log.md:4` | across the ROADZ branches and worktrees (~91 MB), filtered to 474 David messages, then | **anonymise** R8 |
| `roadz` | `docs/retrospectives/2026-08-plugin-line/friction-transcript-log.md:62` | protected branches. ROADZ has no equivalent, and none of these three checks exist. | **anonymise** R8 |
| `roadz` | `docs/retrospectives/2026-08-plugin-line/friction-transcript-log.md:117` | were tried in ROADZ and proved insufficient. | **anonymise** R8 |
| `roadz` | `docs/retrospectives/2026-08-plugin-line/friction-transcript-log.md:185` | Already documented in ROADZ CLAUDE.md (the default-branch workaround) and already | **anonymise** R8 |
| `roadz` | `docs/retrospectives/2026-08-plugin-line/friction-transcript-log.md:210` | \| Report style \| No \| No — ROADZ built the skill \| | **anonymise** R8 |
| `roadz` | `docs/retrospectives/2026-08-plugin-line/friction-transcript-log.md:239` | the working context a hardware session needs. Neither did ROADZ's handoff.md. | **anonymise** R8 |
| `roadz` | `docs/retrospectives/2026-08-plugin-line/friction-transcript-log.md:387` | The §2.4 correction was empirical. ROADZ has **2 live worktrees and 4 transcript | **anonymise** R8 |
| `roadz` | `docs/retrospectives/2026-09-dogfood/README.md:5` | **Source work:** Lantern ROADZ speaker / sound-system. | **anonymise** R8 |
| `roadz` | `docs/retrospectives/2026-09-dogfood/README.md:19` | \| Excluded \| R--work-lantern-roadz-pb-firmware — a different repository. [#141](https://github.com/Calyx-Engineering/arc/issues/141) \| | **anonymise** R8 |
| `roadz` | `docs/suite-architecture/domain-engineer-persona.md:224` | - ROADZ .claude/wiki/speaker-power.md — an existing example of captured device physics | **anonymise** R17 |
| `roadz` | `evals/environment-blame/issue-68-gain-sweep-bench-blame/turns/39.md:1` | <ide_opened_file>The user opened the file r:\work_lantern\roadz-sound-system\tools\mso8204_bode_sweep\bode_config.yaml in the IDE. This may or may not be relate | **move** R5 |
| `roadz` | `evals/report-shape/cellular-recommendation-first/case.yaml:1` | corpus: roadz-sound-system | **move** R5 |
| `roadz` | `evals/report-shape/cellular-recommendation-first/excerpt.md:3` | **Relates to:** [#26 — Onboard cell modem evaluation](https://github.com/Lantern-Systems/roadz-sound-system/issues/26) · [US001 — Two deployment configurat | **move** R5 |
| `roadz` | `evals/report-shape/light-dimming-findings-first/case.yaml:1` | corpus: roadz-sound-system | **move** R5 |
| `roadz` | `evals/report-shape/light-dimming-findings-first/excerpt.md:3` | **Relates to:** [#1 — PCBA respin: Add dimmer/flasher capability](https://github.com/Lantern-Systems/roadz-sound-system/issues/1) | **move** R5 |
| `roadz` | `evals/report-shape/pin-allocation-ledger/case.yaml:1` | corpus: roadz-sound-system | **move** R5 |
| `roadz` | `evals/report-shape/pin-allocation-ledger/excerpt.md:5` | \| 13 \| claimed \| report — PR [#48](https://github.com/Lantern-Systems/roadz-sound-system/pull/48) \| LGHTS_ON \| LIGHTS_ON \| Static on/off enable becomes  | **move** R5 |
| `roadz` | `evals/report-shape/pin-allocation-ledger/excerpt.md:6` | \| 14 \| claimed \| report — PR [#48](https://github.com/Lantern-Systems/roadz-sound-system/pull/48) \| LGHTS_nFAULT \| nDUSK_DETECT \| Light fault in, replac | **move** R5 |
| `roadz` | `evals/report-shape/pin-allocation-ledger/excerpt.md:8` | \| 18 \| **available** \| drawing — [#8](https://github.com/Lantern-Systems/roadz-sound-system/issues/8), reviewed \| PND.PWR_EN \| — \| Pendant 5V load swi | **move** R5 |
| `roadz` | `evals/report-shape/pin-allocation-ledger/excerpt.md:9` | \| 19 \| claimed \| thread [#24](https://github.com/Lantern-Systems/roadz-sound-system/issues/24) · drawing [#8](https://github.com/Lantern-Systems/roadz-sound | **move** R5 |
| `roadz` | `evals/report-shape/pin-allocation-ledger/excerpt.md:11` | \| 22 \| claimed \| thread — [#24](https://github.com/Lantern-Systems/roadz-sound-system/issues/24) \| 3V3_D2_EN \| IGNTN_OUT \| Ignition-derived enable out o | **move** R5 |
| `roadz` | `evals/report-shape/pin-allocation-ledger/excerpt.md:15` | [#38](https://github.com/Lantern-Systems/roadz-sound-system/issues/38)'s accessory rail and [#35](https://github.com/Lantern-Systems/roadz-sound-system/issues/3 | **move** R5 |
| `roadz` | `evals/report-shape/pin-allocation-ledger/excerpt.md:18` | two decisions did it: [#12](https://github.com/Lantern-Systems/roadz-sound-system/issues/12)'s SSR is ignition-driven, so it commands nothing; and its | **move** R5 |
| `roadz` | `evals/report-shape/poe-class-conflict/case.yaml:1` | corpus: roadz-sound-system | **move** R5 |
| `roadz` | `evals/report-shape/poe-device-under-test/case.yaml:1` | corpus: roadz-sound-system | **move** R5 |
| `roadz` | `evals/report-shape/poe-pse-question-first/case.yaml:1` | corpus: roadz-sound-system | **move** R5 |
| `roadz` | `evals/report-shape/poe-pse-question-first/excerpt.md:23` | [#38](https://github.com/Lantern-Systems/roadz-sound-system/issues/38) follows the block diagram | **move** R5 |
| `roadz` | `evals/report-shape/poe-pse-question-first/excerpt.md:31` | - Does the adapter itself carry any risk for use in the ROADZ Armor system? The teardown is an | **move** R5 |
| `roadz` | `evals/saturation/issue-39-pinout-context-full/turns/1.md:4` | Next is checking roadz_pb_firmware for GP20/GP7/GP8/GP18 overlap, then §3.1 of the pin allocation study. | **move** R5 |
| `roadz` | `evals/saturation/issue-39-pinout-context-full/turns/2.md:1` | 1. clone lives here: R:\work_lantern\roadz_pb_firmware | **move** R5 |
| `roadz` | `evals/skill-firing/situation/copy-transcript-opening/prompt.md:1` | please copy this transcript ~/.claude/projects/r--work-lantern-roadz-sound-system/10774bf5-32a2-4629-b5fd-10c2fdf3388f.jsonl | **anonymise** R17 |
| `roadz` | `evals/skill-firing/situation/log-this-in-friction-log/prompt.md:1` | <ide_selection>The user selected the lines 606 to 606 from r:\work_lantern\roadz-sound-system\.timescope\logs.jsonl: | **anonymise** R17 |
| `roadz` | `evals/skill-firing/wrapped/handoff-then-order-60-words/prompt.md:4` | Next is checking roadz_pb_firmware for GP20/GP7/GP8/GP18 overlap, then §3.1 of the pin allocation study. | **anonymise** R17 |
| `roadz` | `evals/skill-firing/wrapped/handoff-updated-elsewhere/prompt.md:1` | <ide_opened_file>The user opened the file r:\work_lantern\roadz-sound-system\HANDOFF.md in the IDE. This may or may not be related to the current task.</ide_ope | **anonymise** R17 |
| `roadz` | `hooks/camp-branch-check:110` | # Branch naming is per-repo. Arc names arcs arc/<nn>-<slug>; ROADZ names them after the | **anonymise** R17 |
| `roadz` | `hooks/camp-branch-check:167` | # A name the section spells out in full is a branch the repo has already decided on — ROADZ's | **anonymise** R17 |
| `roadz` | `hooks/camp-branch-check:181` | # which is why ROADZ's real …-pr58-arc-setup passes against a section that never mentions it. | **anonymise** R17 |
| `roadz` | `hooks/session-index:28` | # so the number is recoverable here by luck; ROADZ's worktrees are not named that way, and there | **anonymise** R17 |
| `roadz` | `hooks/session-index:37` | # It is a row per (directory, branch) rather than per directory because of m32's measured ROADZ | **anonymise** R17 |
| `roadz` | `README.md:140` | \| [docs/reference-roadz/](docs/reference-roadz/) \| ROADZ's issue-writing and engineering-report skills — same \| | **anonymise** R17 |
| `roadz` | `ROADMAP.md:169` | **A related gap surfaced 2026-08-17:** ROADZ's branch-naming vocabulary comes from a BOM | **anonymise** R17 |
| `roadz` | `skills/autonomy-set/SKILL.md:222` | merges denied; ROADZ states it once and had none across twelve. | **anonymise** R17 |
| `roadz` | `skills/issue-write/SKILL.md:770` | **Observed in ROADZ: eight corrections between 2026-08-14 and 2026-09-05.** Documents, a | **anonymise** R17 |
| `roadz` | `skills/record-route/SKILL.md:13` | > nothing — ROADZ had one and it stayed an empty stub for a month. The mechanism is the | **anonymise** R17 |
| `roadz` | `skills/relief-valve/SKILL.md:71` | [#36](https://github.com/Calyx-Engineering/arc/issues/36) mines this repository, ROADZ and | **anonymise** R17 |
| `roadz` | `templates/session-index.md:61` | It is keyed on the branch as well because of m32's measured case: ROADZ's #39 was worked on a | **anonymise** R17 |
| `roadz` | `tests/verify-autonomy.sh:12` | # durably authorized. arc stated the rule five times and had four merges denied. ROADZ states it | **anonymise** R17 |
| `roadz` | `tests/verify-session-index.sh:366` | # m32's measured case: ROADZ's #39 was worked on a branch in the main repo, so eighteen | **anonymise** R17 |
| `roadz` | `tools/hook-cases/camp-branch-check/fixtures/roadz/CLAUDE.md:10` | The Branching section below is [ROADZ](https://github.com/Lantern-Systems/roadz-sound-system)'s, | **anonymise** R17 |
| `roadz` | `tools/hook-cases/camp-branch-check/pass/declared-integration-branch.json:1` | # ROADZ, real: the integration branch its convention names in full, which carries no number | **anonymise** R17 |
| `roadz` | `tools/hook-cases/camp-branch-check/pass/declared-integration-branch.json:2` | {"cwd":"tools/hook-cases/camp-branch-check/fixtures/roadz","tool_name":"Bash","tool_input":{"command":"git checkout -b interface-pcba/rev_b"}} | **anonymise** R17 |
| `roadz` | `tools/hook-cases/camp-branch-check/pass/roadz-issue-hyphen.json:1` | # ROADZ, real: the current <module>/rev-<X>-issue-<NN>-<slug> form | **anonymise** R17 |
| `roadz` | `tools/hook-cases/camp-branch-check/pass/roadz-issue-hyphen.json:2` | {"cwd":"tools/hook-cases/camp-branch-check/fixtures/roadz","tool_name":"Bash","tool_input":{"command":"git switch -c interface-pcba/rev-b-issue-15-audio-out-iso | **anonymise** R17 |
| `roadz` | `tools/hook-cases/camp-branch-check/pass/roadz-issue-slug-digits.json:1` | # ROADZ, real: the slug carries digits (rp2040) — the number comes from the identifier, not the slug | **anonymise** R17 |
| `roadz` | `tools/hook-cases/camp-branch-check/pass/roadz-issue-slug-digits.json:2` | {"cwd":"tools/hook-cases/camp-branch-check/fixtures/roadz","tool_name":"Bash","tool_input":{"command":"git checkout -b interface-pcba/rev_b-issue-39-unify-rp204 | **anonymise** R17 |
| `roadz` | `tools/hook-cases/camp-branch-check/pass/roadz-issue-underscore.json:1` | # ROADZ, real: an issue branch on the pre-2026-08-24 underscore form its convention still allows | **anonymise** R17 |
| `roadz` | `tools/hook-cases/camp-branch-check/pass/roadz-issue-underscore.json:2` | {"cwd":"tools/hook-cases/camp-branch-check/fixtures/roadz","tool_name":"Bash","tool_input":{"command":"git checkout -b interface-pcba/rev_b-issue-1-dimmer-flash | **anonymise** R17 |
| `roadz` | `tools/hook-cases/camp-branch-check/pass/roadz-pr-branch.json:1` | # ROADZ, real: a no-issue branch carrying its PR number | **anonymise** R17 |
| `roadz` | `tools/hook-cases/camp-branch-check/pass/roadz-pr-branch.json:2` | {"cwd":"tools/hook-cases/camp-branch-check/fixtures/roadz","tool_name":"Bash","tool_input":{"command":"git checkout -b interface-pcba/rev-b-pr58-arc-setup"}} | **anonymise** R17 |
| `roadz` | `tools/hook-cases/camp-branch-check/pass/roadz-pr-sweep.json:1` | # ROADZ, real: a second PR-numbered branch, created with git branch | **anonymise** R17 |
| `roadz` | `tools/hook-cases/camp-branch-check/pass/roadz-pr-sweep.json:2` | {"cwd":"tools/hook-cases/camp-branch-check/fixtures/roadz","tool_name":"Bash","tool_input":{"command":"git branch interface-pcba/rev-b-pr70-inductance-sweep"}} | **anonymise** R17 |
| `roadz` | `tools/hook-cases/camp-branch-check/report/roadz-no-number.json:1` | # ROADZ: the module and revision are right and the identifier is missing — genuinely malformed | **anonymise** R17 |
| `roadz` | `tools/hook-cases/camp-branch-check/report/roadz-no-number.json:2` | {"cwd":"tools/hook-cases/camp-branch-check/fixtures/roadz","tool_name":"Bash","tool_input":{"command":"git checkout -b interface-pcba/rev-b-dimmer-flasher"}} | **anonymise** R17 |
| `roadz` | `tools/miner-scope.sh:9` | # shared prefix then pulled in a sibling repository: briefed on roadz-sound-system, the first | **anonymise** R17 |
| `roadz` | `tools/miner-scope.sh:10` | # real run also read R--work-lantern-roadz-pb-firmware, which is a different product. #141. | **anonymise** R17 |
| `roadz` | `tools/miner-scope.sh:16` | # A shared stem is not enough. "roadz-sound-system" is not a prefix of "roadz-pb-firmware" | **anonymise** R17 |
| `roadz` | `tools/miner-scope.sh:40` | mkdir -p "$T/r--work-lantern-roadz-sound-system" "$T/R--work-lantern-roadz-sound-system--claude-worktrees-interface-pcba-rev-b-issue-1" "$T/R--work-lantern-road | **anonymise** R17 |
| `roadz` | `tools/miner-scope.sh:63` | t "the briefed directory is in scope" "IN r--work-lantern-roadz-sound-system" r--work-lantern-roadz-sound-system | **anonymise** R17 |
| `roadz` | `tools/miner-scope.sh:64` | t "a worktree of the briefed slug is in scope, despite the case difference" "IN R--work-lantern-roadz-sound-system--claude-worktrees" r--work-lantern-roadz-soun | **anonymise** R17 |
| `roadz` | `tools/miner-scope.sh:65` | t "a sibling repository sharing a stem is NEAR, not IN — the #141 case" "NEAR R--work-lantern-roadz-pb-firmware" r--work-lantern-roadz-sound-system | **anonymise** R17 |
| `roadz` | `tools/miner-scope.sh:66` | t "an unrelated repository is SKIP" "SKIP r--lodestar" r--work-lantern-roadz-sound-system | **anonymise** R17 |
| `roadz` | `tools/miner-scope.sh:67` | t "a second briefed slug brings its directory in" "IN r--arc" r--work-lantern-roadz-sound-system r--arc | **anonymise** R17 |
| `roadz` | `tools/miner-scope.sh:68` | t "nothing is silently omitted — every directory is on a line" "SKIP r--arc" r--work-lantern-roadz-sound-system | **anonymise** R17 |
| `roadz` | `tools/miner-scope.sh:71` | te "a valid brief exits 0" 0 r--work-lantern-roadz-sound-system | **anonymise** R17 |

---

## 5 What you tick

**Twenty-one `ask` rows, in three groups.** Every other row has a proposed disposition and needs
nothing from you unless you want it changed.

| | Rows | The question |
| :--- | ---: | :--- |
| **A1** | 18 | `docs/arc-work/04-dogfood/handoff-baseline.md` — R6. It quotes conversation turns verbatim with wall-clock timestamps. Ship it anonymised, or move the file? |
| **A2** | 3 | The three profanity quotes in `docs/retrospectives/` — R7. Mask them, ship them as spoken, or move the two files? |
| **A3** | — | **D4, the licence.** Not a row; §1.2 |

**And any `anonymise` you want back.** The default is deliberately conservative: 339 rows are
`anonymise`, and several are the user's own machine paths rather than anything a client owns.

*End of the public audit.*
