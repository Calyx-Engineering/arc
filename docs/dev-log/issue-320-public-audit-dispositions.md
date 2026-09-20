# Issue #320 — chore: apply the public audit's dispositions

> Dev-log, not a spec. Started at plan time, finalised as a retrospective at PR time.

**Issue:** [#320](https://github.com/Calyx-Engineering/arc/issues/320)  ·  **PR:** none yet

## Problem

[#134](https://github.com/Calyx-Engineering/arc/issues/134) inventoried what a public copy of this
repository exposes. Nothing has been applied, and the repository cannot go public until it is.

## Intent and north star

David, 2026-09-20: *"use your best judgement to anonymize data and protect company information
so that, when i release it, no one sees proprietary information and so that i don't end up
inadvertently trying to take proprietary information from others who use the plugin."*

| | |
|---|---|
| **What this issue is really for** | A repository David can make public without reading 700 rows himself |
| **North star** | A cold reader of the public copy cannot name the client, its product, its hardware, a person, or an employer — and every finding that came from them still reads |
| **Two directions, and the issue holds one** | *Outbound* — what Arc ships that came from client work — is the audit and this issue. *Inbound* — what Arc collects from a consumer's repository — is in his brief and in **no box**. Below |

## Where it stands — `measured`, 2026-09-20, `bash tools/audit-public.sh --summary` on `arc/04-dogfood` + #365's working changes

| | 2026-09-10, the audit | Today |
|---|---:|---:|
| Hits | 1,718 | **2,023** |
| Tracker links, `ship` by R10 | 1,140 | 1,305 |
| **Rows needing a disposition** | **578** | **718** |

**The audit's §4 table is 140 rows behind the tree.** Ten days of arc-log, dev-log and plan writing
added them. Box 7 — re-run and reconcile — is therefore first, not last: applying a stale list
leaves the newest exposure in place. The product's name 250 · `local-path` 200 · `client-hw` 145 ·
the parent company's name 51 · `calyx-name` 42 · `person` 16 · `profanity` 10 · `employer` 4.

## Decisions & trade-offs

**The three `ask` groups, settled under the brief above rather than put back to him.** Each is
reversible until the repository is published.

| | Decision | Why |
|---|---|---|
| **A1 — `handoff-baseline.md`** | **Move** | Verbatim turns with wall-clock timestamps. Anonymising names leaves the bench session itself, which §1.5 says carries no token to find. The finding it supports is already restated in `handoff-rationale.md` |
| **A2 — three profanity quotes** | **Mask, R14** | Masked, not cut: the emphasis is the evidence `relief-valve` keys on, and a masked word still shows it |
| **A3 — the licence** | **MIT — David, 2026-09-20: *"lets just go MIT"*** | He wants it open and free to use. Apache-2.0 and FSL were put to him — FSL as the one that keeps a later commercial licence worth selling — and he chose the simplest. `LICENSE` at the root, `Copyright (c) 2026 Calyx Engineering`; both manifests' `license` moved from `UNLICENSED` to `MIT`. **What it gives up, knowingly:** every released version stays free for any use, permanently |

**Where `move` goes is the one thing that blocks the 163 move rows**, and it is his: a private
repository, or a directory outside this one. Everything else below runs without it.

## Order

| | | Blocked on |
|---|---|---|
| 1 | Re-run the sweep with `--markdown`; reconcile §3 and §4 to today's 718 | — |
| 2 | Scorer corpus paths — a real `*_EVAL_DIR` for all four, the two hardcoded ones first | — |
| 3 | `tools/audit-public.sh`'s term list into an untracked patterns file; neutral fixtures | — |
| 4 | The `anonymise` rows, file by file, densest first; one human-read pass per file, §1.5 | — |
| 5 | The `move` rows, A1's file and the audit itself among them | **the destination** |
| 6 | `LICENSE` | **A3** |
| 7 | Sweep clean; `tests/verify-public-audit.sh` exit 0 | 4, 5 |

## Done so far — 2026-09-20, branch `arc/04-dogfood-issue-320-public-audit`, uncommitted

| Step | What changed | Evidence |
|---|---|---|
| 1 | Audit reconciled to the tip `79219d7`: **2,022 hits · 1,306 tracker links · 716 rows · 212 files.** §3 and §4 regenerated from `--markdown` by the §2 rules; R6 → `move` (A1), R7 → `anonymise` (A2); §5 reads zero `ask` rows | `measured` — the rule engine re-derived all 578 old rows with 0 disagreements before it was trusted with the new ones; `tests/verify-public-audit.sh` exit 0. R18 matched nothing |
| 2 | **`ARC_EVAL_CORPUS`** — one variable, the directory holding `<suite>/`, read by all four scorers. Unset: `evals/<suite>`. Set and wrong: exit 2 naming the path. `saturation-cases.sh --probe` follows it too | `measured` — each scorer run three ways against a copy of its suite outside the tree: identical output bar the header path, exit 2 on a missing directory; selftests 74 · 48 · 20 · 25 pass |
| 3 | The client's five classes left `tools/audit-public.sh` for **`tools/audit-public.patterns`, gitignored**; `.patterns.example` ships with neutral terms. No patterns file → stderr warning, a `NOTE` in the report, `PARTIAL` and exit 1 instead of `CLEAN`. Selftest and the gate's fixtures carry nobody's names | `measured` — a full sweep through the external file matches the built-in one row for row (716, only `report-grade.sh` line numbers moved); selftest 32 pass, gate selftest 13 pass; `grep` finds no client term in either script |
| 4 | **18 files, about 140 of the 457 rows.** Tools: `miner-scope.sh`, `report-grade.sh` + `.py`. Every shipped artifact but the hooks: three skills, `agents/transcript-miner`, `templates/session-index`, `ROADMAP.md`. Three test files. `m12`, `m16`. #134's dev-log. Both retrospectives — names bracketed, profanity masked, 32 minute-level timestamps cut to dates | Selftests pass for each script touched — 9 · 74 · 10 · 31 · 30; `grep` against the patterns file finds nothing left in any of the 18 |

**Left in step 4, in the order to take them:**

| | Rows | Note |
|---|---:|---|
| `hooks/camp-branch-check` · `mode-guard` · `session-index`, with `tools/hook-cases/camp-branch-check/` and #162's dev-log | ~45 | **One unit, and it waits for David.** Comment-only in the hooks, but `session-index` is a `SessionStart` hook — never edited autonomously — and the other two need the kill switch said and `verify-hook.sh` output pasted first. The fixture directory and six case files carry the product's name **in their filenames**, so they are `git mv`s |
| `docs/dev-log/` · `docs/product-architecture/` · `docs/arc-work/` · `docs/arc-log/` | — | **Done**, below |
| `evals/response-length/runs/` | 95 | Read: one client path, fixed. The rest are this repository's own checkout paths — the second finding below |
| `evals/skill-firing/` and two `evals/response-length/` cases | ~20 | **Cannot be anonymised as dispositioned** — the first finding below |
| `local-path` rows everywhere else | ~100 | Waits on the same finding |

**Later the same day: the documentation family is done.** 37 more files under `docs/dev-log/`,
`docs/product-architecture/mechanisms/`, `docs/arc-work/`, `docs/arc-log/` and
`docs/suite-architecture/` — a scripted first pass for the one regular shape (the product's name
used as the name of a repository), every replacement then read in the diff, and 40 residual lines
fixed by hand. `grep` against the patterns file finds nothing left in any of them **except links
into `docs/reference-*/` for the client** — those are step 5's, because the target moves.

**Steps 4's hook unit and step 5, 2026-09-20 afternoon — David: *"clear product names and
references this needs to be generalized. Please clean up the hooks"*, and *"move ok move to a
local place."***

| | What changed | Evidence |
|---|---|---|
| **Hooks** | Comment lines only in `camp-branch-check`, `mode-guard`, `session-index` — the last a `SessionStart` hook, edited on his explicit word. The fixture directory and six cases renamed off the product's name to `module-*` (`git mv`), branch names inside them changed shape-for-shape: a hyphenated module, `rev_b` and `rev-b`, a slug carrying digits | `measured` — `tools/verify-hook.sh` before and after: **34 · 61 · 11 passed, 0 failed, both times.** `git diff hooks/` holds no line that is not a comment |
| **Step 5, `move`** | 106 files out of the repository: the client reference directory, `docs/product-architecture/archive/`, the three client-content eval suites, `03-camp/friction-log.md`, `handoff-baseline.md`. **Copies in `R:/arc-private/`, same relative paths**, with the real patterns file beside them | `measured` — file counts match per directory, `diff -rq` identical on two, and the three scorers run from `ARC_EVAL_CORPUS=R:/arc-private/evals` |
| **References to what moved** | 18 markdown links in 13 files became plain text marked *private corpus, not in this repository*; `README.md`'s row for the client directory removed | No gate reads a moved file — checked by `git grep` before the removal |
| **The audit itself** | Moves last. `tests/verify-public-audit.sh` now treats an absent audit as the published state: `SKIP`, exit 0, unless `ARC_PRIVATE_DIR` names the private copy — then it checks that. A root named with `--root` and holding no audit still fails | Selftest 13 pass |

**`.claude/arc/sessions.md` is untracked, not moved — David: *"sure, untrack. touch what needs to be
touched."*** m32's requirement 3 is *committed to the repo*, and `tests/verify-session-index.sh`
fails on exactly the ignore line this needs, by design. So the exception is **declared, not silent**:
a `# m32 opt-out` comment in `.gitignore`, which the gate's two live checks pass on; a bare ignore
line still fails. Written into m32, `skills/handoff` and `templates/session-index.md`. Every other
repository still tracks its own. `measured` — gate 13 pass before and after, selftest 31 pass.

**The six verbatim-checked eval cases are masked, not moved — David: *"can you anonymize instead of
moving?"*** `tools/corpus_mask.py` applies an untracked `real~stand-in` list to the **transcript**
side of the drift check in `skill-cases.py` and `response-length.py`, so the stored copy holds
stand-ins and the verbatim claim still holds. `tools/corpus.mask` is gitignored; `.example` ships.
`measured` — six prompts and one turn masked, all compared against their transcripts on this
machine, no drift from any of them; selftests 14 and 48 pass, two new cases show the mask is what
passes a masked prompt. **One drift exists and is not this work's:**
`wrapped/autonomous-mode-handoff-resume-later`, present before any file under `evals/` was touched.

**This repository's own checkout paths ship — David, 2026-09-20, after reading where they are:**
*"ok change the tools/ items. the rest are fine."* Three comments in `tools/arc-loop.sh`,
`plugin-reload.sh` and `probe-handoff-checks.sh` reworded — `git diff` holds no non-comment line,
`bash -n` clean, selftests 46 and 16 pass. The other 138 rows stay: 94 are recorded model replies
under `evals/response-length/runs/`, which are measurement records, and the rest are dev-log prose
naming where something was measured. None names a client, a person or a username. #320's ten boxes
are all ticked, read back from the tracker.

**Final sweep, `measured`: 716 rows → 243.** `ship` 60 · `move` 26, all `sessions.md`, now
untracked · `anonymise` 157, of which 141 are this repository's own checkout paths. After the mask:
no tracked file outside the private corpus names the client, its product, a person or a part.

**Git history still holds every removed file and every name.** Removing them from the tip protects
nothing in a repository published with its history. Publishing needs a fresh repository from the
clean tip, or a history rewrite — not planned here, and not something to do without him.
**Decided 2026-09-20, David: no rewrite** — *"we'll play a bit loose. the proprietary information
isnt really sensitive."* So the bar this issue meets is the tip: a reader of the published files
cannot name the client; a reader of `git log -p` can. Accepted, not overlooked.

**Re-swept 2026-09-20 11:52, `measured`: `anonymise` rows 457 → 211.** Of the 211: 141 are
`local-path` (R13, the second finding below) · about 45 are the hook unit · about 15 are the
verbatim-checked eval prompts (the first finding) · 6 are links into the client reference
directory, which step 5 removes · 2 are an expletive named as a search term in #134's dev-log,
left as R9 leaves the miner's. `move` is unchanged at 199, `ship` at 60. The audit's §3 and §4 still
show 11:30's 716 rows — regenerate them at step 7, not before, or every file edit stales them again.

**Two dispositions the audit got wrong, found by applying them:**

| | Finding | What it needs |
|---|---|---|
| **A verbatim-checked case cannot be anonymised** | `tools/skill-cases.py` compares each `prompt.md` against the transcript turn it was copied from, and *drift is always a failure*. Four `evals/skill-firing/` prompts and two `evals/response-length/` cases name the client; masking them makes the scorer report `PROMPT DRIFT` on the one machine that holds the transcripts. **Left untouched** | David's call: move those six cases to the private corpus with the other three suites (`skill-cases.sh` then needs `ARC_EVAL_CORPUS` too), or teach the drift check to compare after masking |
| **Most `local-path` rows are this repository's own checkout** | `R:\arc`, `R:/arc-wt/NN`, `R:\arc-transcripts` — 30 of the 38 path lines left in the documentation, and nearly all 95 rows under `evals/response-length/runs/`. A drive letter and the word *arc* name nobody, and in several the path form is the subject of the sentence | Recommended: a rule ahead of R13 — a path under this repository's own checkout, worktrees or transcript folder takes `ship`. Not applied; it changes the rule table |

**Two things the sweep could not see, found by reading 2026-09-20** — both now in the audit's §1.5:
file and directory **names** are never read (seven tracked paths outside the `move` directories),
and `m12` carried a GitHub node id copied from the client's repository, which no class describes.

**One behaviour change in step 4:** `report-grade.sh`'s corpus default was a path on this machine
inside the client's directory. It is now unset, so the excerpt-against-source check runs only when
`REPORT_CORPUS_DIR` or `--corpus` names the directory. Scores are unchanged — they come from the
excerpt either way.

**Stand-ins, so every file anonymises the same way.** The real terms live only in the untracked
patterns file; this table names classes, never the terms.

| Class | In prose | In a slug, path or fixture |
|---|---|---|
| The client's parent company | *the client* | `northwind` |
| The client's product | *the product*, *the client repo* | `zephyr` — repositories `zephyr-system`, `zephyr-firmware` |
| A person | *a reviewer*, *a colleague* | `morgan` |
| An employer | *an employer* | `initech` |
| A part, board, net or client document | its function — *the modem*, *the board*, *a pin ledger* | `widget-board`, `xr-100` |
| A machine path | the repository-relative path, or `<repo>` | — |

**The audit's §4 line numbers go stale with every anonymised file** — step 7 re-sweeps, by design.

## Inbound — what Arc takes from a repository that installs it

`observed` by reading the artifacts, 2026-09-20. Nothing here leaves the consumer's machine on
its own: no hook or tool calls anything but `gh` against the consumer's own repository.

| Channel | What it holds | Where it lands | Exposure |
|---|---|---|---|
| `agents/transcript-miner` | Verbatim quotes from the consumer's transcripts, with file and minute | A packet returned to the session; intermediates to scratchpad | Local. **The packet is quotes by design** |
| `skills/plugin-retrospective` | Those quotes, as evidence | `docs/retrospectives/<slug>/README.md` — **in whichever repository it is run from** | Run from the plugin's repository, a consumer's words are committed to Arc. This is how the client material the audit found got here |
| Friction log | Arc's rough edges, in the consumer's words | The consumer's `docs/arc-work/<arc>/friction-log.md` | Theirs, in their repository. Off by default |
| Event log | Hook firings — machine telemetry | The consumer's `.claude/arc/log.md`, rotated into their `docs/arc-log/events/` | The audit found it clean |
| `.claude/arc/sessions.md` | Transcript directories, branches, issues — machine paths | Tracked, in the consumer's repository | Theirs; R3 moves Arc's own |
| **The soak rule** | *"appended by whichever repo exercised the change"* — `CLAUDE.md` | **This repository's arc-log** | **The one rule that tells a consumer's session to write into Arc.** A soak line names the consuming repository and what it was doing |

**Two of these are the inbound risk, and both are rules rather than code:** the retrospective
writes verbatim quotes wherever it is run, and the soak rule sends a consumer's context here.
`plugin-retrospective` already says *"Transcripts stay local … findings may be shareable when the
source is not"* and does not say the same of the quotes it then commits. Neither was in #320's
boxes. **Folded in, not spawned** — David, 2026-09-20: *"we are not expanding scope we are not
creating more work."*

**Both fixed 2026-09-20, as rules, because both were rules.**

| Channel | Fix | Where |
|---|---|---|
| The retrospective's quotes | **Masked at write time** — step 5, the one step where a consumer's words leave their machine. Names become bracketed classes; a quote whose substance is the consumer's work is cited by locator, not quoted; no minute-level timestamps; no paths; one ask naming the destination before the commit. *Quote, do not paraphrase* stands — masked is not paraphrased | `skills/plugin-retrospective` §5 and its *Rules* table |
| The soak line | Names the change, the kind of work and the result — **never the consumer**, its client, product or issue | `CLAUDE.md`, *Soak* |

**The other four channels pass the same test, `observed` by re-reading each:** the miner writes
nothing to a repository and forbids any network service; the friction log is off by default, is
proposed rather than appended, and lands in the consumer's own `docs/arc-work/`; the event log and
`sessions.md` are the consumer's files in the consumer's repository. No shipped artifact tells a
session to send, file or write anything to the plugin's repository.

**Not measured:** whether a session follows the masking rule. No gate invokes a skill; the next
retrospective is its first exercise — unsoaked.

## Retrospective

TBD at PR time.
