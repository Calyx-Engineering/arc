# Issue #134 — review what ships before making Arc public

**Issue:** [#134](https://github.com/Calyx-Engineering/arc/issues/134)  ·  **PR:** [#319](https://github.com/Calyx-Engineering/arc/pull/319)

## Problem

Arc is private and installed from a local directory. Using it at another employer means
publishing it, and nothing had been reviewed for what that exposes. The repository was built
*inside* client work: it quotes real engineering reports, names a real client's parts, carries the
user's own machine paths, and holds 124 files of verbatim conversation.

## Intent and north star

| | |
|---|---|
| **What this issue is really for** | Making the exposure *countable* before anyone decides what to do about it. The decisions are cheap once the list exists and impossible to make from an impression |
| **North star** | A row per hit with a proposed disposition, and a command that regenerates the hit list after the fixes. The issue's own framing: *"this run produces an inventory with dispositions and changes nothing else"* |
| **What makes it durable** | The sweep is a script, not a reading. A hit list produced by a session dies with the session; one produced by `tools/audit-public.sh` can be re-run after every fix and before publication |
| **Out of scope** | **Applying any disposition** — the issue says a second run does that, once the `ask` rows are settled. **TimeScope** — the user's own system, named as out of scope. **Anonymising the retrospective's content** — the issue pre-decided that its content is fine and only names inside it get `anonymise` |

## Decisions & trade-offs

| | |
|---|---|
| **The instrument carries no policy** | `tools/audit-public.sh --markdown` emits the rows with an **empty** disposition column. Dispositions live in the audit document's rules table, so regenerating the hit list after a fix cannot silently overwrite a decision the user made |
| **Nine classes, each with its reason on its own line** | The class table is a tilde-separated here-doc rather than an array. A class added without a reason is a class nobody can review |
| **One line can produce several rows** | A path through the client's directory to its product's repository is a machine path *and* a client name *and* a product name. Three separate decisions, so three rows. The single exception is `calyx-name`, tested against the line with the repository's own GitHub URLs stripped — without that, every issue link in the repository reports as an organisation-name exposure |
| **`calyx-url` is counted, not listed** | 1,140 links to this repository's own tracker. Enumerating them would bury the 578 rows that need a human, and the decision on them is collective anyway — one row in the audit, not 1,140 |
| **Dispositions come from eighteen ordered rules, not per-row judgment** | Every row cites the rule that produced it, so a reader can disagree with one rule instead of 578 rows. `R18`, the fallback, matched nothing — which is the check that the seventeen above it are complete |
| **The gate checks the document against itself, not against the tree** | The live sweep takes **69 seconds** and its answer moves with every commit. A gate that re-swept would be slow on every unit and red on most of them. So `tests/verify-public-audit.sh` checks the four views inside the document for agreement, and `verify-all.sh --list` records the live sweep as the pre-publication step |
| **The licence is left undone on purpose** | It is an `ask`, and the issue says the user ticks those. The recommendation is recorded with its reasoning; the box is not ticked |

## Rejected approaches

| Rejected | Why |
|---|---|
| Enumerating the `calyx-url` class in the audit | 1,140 identical rows. `docs/arc-log/arc-03-camp.md` would top a table whose subject is client exposure |
| Encoding the dispositions in `tools/audit-public.sh` | It would make the tool's output authoritative over the user's edits. The second run reads the document, not the script |
| Re-running the sweep inside `verify-all.sh` | 69 seconds on every unit, for an answer that legitimately changes with every commit |
| `delete` as a disposition | The issue forbids it. The gate names it separately from "not in the set" so the error says which rule was broken |

## Spawned

- **Arc work:** public-audit.md (private corpus, not in this repository) — the inventory, 578 rows
- **Issues:** none. Everything found is either a row in the audit or one of the three `ask` groups in its §5

## Findings a second run needs

| | |
|---|---|
| **Transcript content ships, and the box asking otherwise cannot be ticked** | 124 files in `evals/` are verbatim turns, prompts, client report excerpts and model replies. Two friction logs, two documents quoting turns with wall-clock timestamps, and `.claude/arc/sessions.md` are the rest |
| **The eval corpus is both the exposure and the instruments** | `report-grade.sh`, `response-length.sh`, `saturation-cases.sh` and `environment-blame.sh` score against it. Anonymising a pinout discussion destroys what it measures, so the three client-content suites are `move` — into a corpus directory outside the published repository. **No scorer can take a corpus path today**: `report-grade.sh:605` and `response-length.sh:409` have an `*_EVAL_DIR_OVERRIDE` that exists for their own selftest, and `saturation-cases.sh:238` and `environment-blame.sh:269` hardcode theirs. `REPORT_CORPUS_DIR` is the source-repository root and is unrelated — review pass 4 caught this claim |
| **The committed event-log archive is clean** | 63,231 lines, zero hits in every class but one link in its own header. Machine telemetry exposes nothing, which is worth knowing before anyone proposes pruning it |
| **The sweep matches named entities, not described work** | `docs/arc-work/04-dogfood/handoff-rationale.md:31` describes a real bench session — *"a DC-ramp capacitance rig ... for a setup that measures inductance"* — and carries no matchable token. The 578 rows are a floor |

## Two defects found in the gate's own parsing, both by running it

| | |
|---|---|
| **`\|` in an awk regex is alternation, not a literal pipe** | gawk downgrades the undefined escape to plain `\|` with a warning. Written that way, the row pattern matched almost any line and the field extractions returned fragments of the wrong cell. Every pipe in the gate is now `[\|]` |
| **`sub(/…\.\*$/)` can fail on a line `~` says matches** | On `docs/product-architecture/archive/product-plan.md:129` — a row quoting a Markdown table, emoji included — `line ~ /…\.\*$/` returned 1 and the identical `sub` replaced nothing. Fields now come out by `split` on the backtick and `match` on the tail, never by a `sub` ending in `.*$` |

Both are recorded in the gate's header, because a later edit that "simplifies" either one reintroduces the defect.

## What review pass 1 changed

**On the tree as it then stood, the sweep it reviewed reported 474 rows and the sweep it left
reported 561** — 87 missed, 16% of the true total, all of it in classes that are literal lists.
(The committed totals are higher again, 578, because this dev-log is itself scanned.)

| Found | Fix |
|---|---|
| **The three excluded files ship and had no disposition.** `tools/audit-public.sh`'s class table is a dictionary of the client's parts; the audit quotes every hit verbatim — 113 lines of the parent company's name, 344 of the product's. An exclusion had been read as a decision that a file is safe | Audit §2.1 dispositions all three by hand, and the tool's header says an exclusion is a limit on the instrument, never a verdict |
| **`client-hw` matched the board's name with a space.** The repository writes it hyphenated — the branch, the wiki page, the milestone. 53 lines carry the board name and 39 were invisible to the space-only pattern, in files dispositioned `ship` | A `[ _-]` alternative for the board, plus the MCU family, a wiki page, and six document and bench slugs. **`client-hw` went from 49 hits to 134**, and to 136 once this dev-log was staged |
| **A second GitHub identity**, was reported only as `calyx-name` and took `ship` — it would have survived publication | Added to `person` |
| **`freaking`** was not an expletive to the pattern | Added |
| Three prose/count contradictions — R10 saying 1,131 where everything else said 1,138; the turns count 94 where `git ls-files` says 97; §1.1 calling `docs/suite-architecture/` and `docs/reference-timescope/` clean where §4 gave each a row | Corrected |

**The pattern worth keeping:** every one of these was found by *reading*, not by running the
instrument, and three of the nine classes are lists that can only ever be as complete as their
last editor. That is now §1.5's second blind spot rather than a footnote.

## What review passes 2 and 3 changed

**Pass 2 read pass 1's own edits.** It found the renumbering had left `tools/audit-public.sh`
pointing at the wrong section; §2.1's counts of the three excluded files taken before the
regeneration; `docs/release/` still called *clean* when §4 gives it two rows — the same defect pass
1 had fixed for two other directories and missed on a third; and one flatly false claim, that the
gate *"checks this document against the tree"*, which is the one thing its own header says it does
not do. It also found selftest case 7b putting three new alternatives on one fixture line, so
reverting any one of them left the case green, and `freaking` with no case at all. **One term per
fixture file now**, and the suite went from 28 cases to 32.

**Pass 3 read the checklist against the tree** and found five of the seven boxes carrying numbers
from an earlier sweep. It also found the thing neither earlier pass could: **this dev-log is a
shipping artifact too.** Untracked, `git ls-files` never showed it to the sweep, and it carries
the parent company, the product, the second identity, the board, the MCU and three bench slugs. Staging it before
the final sweep is why the committed totals are 578 rows across 153 files rather than 561 across
152 — **the audit now includes the document that describes it.**

## Retrospective

Built an instrument, a gate and an inventory. `tools/audit-public.sh` sweeps every tracked file for
nine classes of exposure and reports 1,718 hits; `docs/arc-work/04-dogfood/public-audit.md` carries
578 of them as rows with a disposition each, the rules that produced those dispositions, a
per-file summary and the three groups that need the user; `tests/verify-public-audit.sh` keeps the
document's four views in agreement as the second run edits it.

**Five of seven boxes are ticked.** The licence is an `ask` with a recommendation recorded, and the
*confirm no transcript content ships* box is left unticked with the reason — it was checked, and it
does ship. Ticking it would have asserted the opposite of what was found.

**What a future reader needs:** the disposition rules, not the rows. Eighteen rules in the audit's
§2 produced all 578, so disagreement is cheap — change a rule, re-derive. The rows themselves are
a snapshot of a tree that has moved since.
