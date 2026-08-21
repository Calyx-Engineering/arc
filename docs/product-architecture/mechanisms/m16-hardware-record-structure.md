# Mechanism — Hardware Record Structure

**Status:** specified. Mostly **already grown organically in ROADZ** — this documents and
tightens what exists.
**Home:** Arc — Knowledge. Guided mode, per m40.
**Spawned from:** the context ladder in [handoff-spine](m15-handoff-spine.md).
**Tiers:** K1–K4 as defined in [knowledge-tiers](knowledge-tiers.md) — this file is the
folder layout that realises K1–K3.

---

## The problem

> *"in HW the work is highly analytical. there is all sorts of background analysis that
> happens that we want to reference later but not present for summary (like the current
> arc-log and dev-log). so what sort of file-structure might support this."*
> — David, 2026-08-16

TimeScope's model is **one compact file per arc, one per issue.** That works for software
and is exactly what makes it reviewable.

Hardware generates a third body of material that fits neither: analyses, measurements,
scope captures, datasheet reasoning, rejected circuit topologies. It must be
**referenceable later** but must **never enter the summary** — otherwise the compact
files stop being compact, and their review value is destroyed.

**This is the one structural thing hardware needs that software does not.**

---

## What ROADZ already grew

Discovered by doing, not designed. `docs/report/issue-01-warning-light-dimming/`:

```text
issue-01-warning-light-dimming/
├── README.md                       ← conclusions, 1–2 pages
├── analysis-driver.md              ← the analytical body
├── analysis-driver-options.md
├── analysis-driver-switching.md
├── analysis-emi-budget.md
├── analysis-night-detect.md
├── archive-t-series-lights.md      ← superseded, deliberately kept
├── t-series-brochure.pdf           ← source material
└── figures/
    ├── emi/
    │   ├── emi_budget_plot.py      ← generator committed beside output
    │   ├── conducted-vs-limits.svg
    │   └── radiated-vs-limits.svg
    ├── load-switch/
    │   ├── c25-0nf-1khz.png        ← scope captures
    │   └── setup.jpg               ← bench photo
    └── night-detect/
```

**Five conventions already working:**

| Convention | Effect |
|---|---|
| `README.md` holds conclusions only | Stays 1–2 pages; the reviewable surface |
| `analysis-<topic>.md` per thread | One file per line of enquiry; bounded, linkable |
| `archive-<topic>.md` for superseded work | Ideas kept without polluting current thinking |
| `figures/<topic>/` grouped by subject | Scales past a flat folder |
| Generators committed beside outputs | `emi_budget_plot.py` — figures regenerable |

`engineering-report` already encodes the first, and the topical-prefix scheme was
settled during the rev B work.

---

## What is missing

| Gap | Consequence |
|---|---|
| **No arc-level analysis home** | Cross-issue findings (EMI budget, thermal, power) have nowhere to live; they land in whichever issue happened to raise them |
| **Retrospective does not link down** | The dev-log's retrospective is the natural index into the analyses; it does not point at them |
| **No graduation step** | Durable facts stay buried in an issue folder instead of reaching the wiki |
| **Report vs dev-log unclear** | ROADZ has `docs/report/issue-NN/`; TimeScope has `docs/dev-log/issue-NN.md`. Both per-issue, different purposes, no stated relationship |

---

## Reports and scratchpad analysis are different artifacts

They share a phase — discovery produces both — but differ in audience, scope, and
lifetime.

> *"the reports provide information for you but, more critically, are user facing and
> thus cover the major capabilities of the product. if there are 300 reports for a
> product as complex as the RAS then it is way too many and I, as the design engineer,
> now lose the ability to process these important things."*

| | **Report** | **Scratchpad analysis** |
|---|---|---|
| Audience | **User-facing** — David, Chad, reviewers | **Agent-facing** — future sessions, and David when digging |
| Scope | **A product capability** | **One issue's working-out** |
| Frequency | **Rare** — a handful per product | **Common** — most non-trivial issues |
| Lifetime | Durable product documentation | Durable but rarely re-read |
| Governed by | `engineering-report` — layering, budgets, no dev narrative | Nothing strict; it is a notebook |
| Failure if overused | **300 reports ⇒ none get read** | Clutter only |

### Reports are not per-issue

The naming `report/issue-01-.../` is misleading. What #1 actually documents is **PWM
dimming as a product capability** — the issue was the vehicle, not the subject. Same for
#26: adding major features and unifying the configurations is a *product architecture*
change.

> *"#26 explored adding major new features and re-arcitecting the whole product … #1 is
> two part with part one basically complete — the exploration. Its adding a major new
> feature to the product."*

**Several issues can feed one report. Most issues feed none.** A report's unit is the
capability; an issue's relationship to it is many-to-one.

### The phase effect

This is why the current structure looked right — everything visible so far is discovery.

| Phase | Produces |
|---|---|
| **Discovery** — architecture, feasibility, new capability | Reports **and** scratchpad. Issues spawn many issues |
| **Execution** — implementing a decided solution | **Scratchpad only.** No report |

> *"when i get to the execution phase where i'm implementing solutions — then i won't be
> generating reports. but i'll still have scratchpad level analysis that we'd want to
> keep."*

Example: **#8, the hard-kill path.** May produce scratchpad work; will not produce a
report. The capability was already decided.

**Consequence for the mechanism:** scratchpad is the default and the common case; a
report is a deliberate, occasional decision. The structure must make scratchpad cheap
and reports explicit.

---

## Proposed structure

### The subject/concern matrix — David, 2026-08-16

**The subject is the folder; the concern is a facet of it.**

> *"there is an EMI analysis for the PWM light dimming. i want that to live with the
> report on pwm not in the emi-budget folder … as the user i'd expect those discussions
> to live with the concept/feature discussion, not spread across 3 or 5 other folders."*

Hardware documentation is a matrix:

| | EMI | Safety | Thermal | BOM |
|---|---|---|---|---|
| **PWM light dimming** | ✓ | ✓ | | ✓ |
| **Hard-kill path** | | ✓ | | |
| **Cellular module** | ✓ | | ✓ | ✓ |

Concern-folders shatter one feature's analysis across the tree, which is the wrong shape
for the person who thinks in features.

**Cross-cutting concerns get a flat index file, not a folder** — a page that links to
where each analysis actually lives.

> *"Maybe those cross cutting things could have documents that link to other places to
> serve as a reference … that would let them live in a more flat fashion (not needing a
> folder dedicated to them)."*

**Does an agent need co-location to reason deeply? No.** Findability is what matters, and
a link index provides it. Co-location serves the human and costs nothing here.

**When a concern earns a real report:** when it becomes evidence-backed and revision-
scoped — an EMI report tied to test results for rev B. That is a K3 report about a
concern rather than a capability, and it is rare.

---

```text
docs/
├── arc-log/
│   └── arc-<slug>.md               ← K1 · compact, read every session
│
├── dev-log/
│   └── issue-<N>-<slug>.md         ← K1 · compact per issue, unchanged
│
├── arc-work/<arc-slug>/            ← K2a · ARC-LEVEL depth
│   ├── bom-analysis.md             ·   spans the whole revision
│   ├── pinout-unification.md
│   └── figures/<topic>/
│
├── scratch/issue-<N>-<slug>/       ← K2b · per-issue working notes
│   ├── <topic>.md                  ·   created on demand, not every issue
│   └── figures/
│
└── report/<capability-slug>/       ← K3 · USER-FACING · rare
    ├── README.md                   ·   conclusions, 1–2 pages
    ├── analysis-emi.md             ·   the EMI facet OF THIS capability
    ├── analysis-safety.md
    └── figures/<topic>/

.claude/
└── index/                          ← AGENT-FACING · not user documentation
    ├── emi.md                      ·   where every EMI analysis lives
    ├── safety.md
    └── bom.md
```

**Why this shape:**

| Change | Why |
|---|---|
| `arc-work/` restored as its own tier | BOM analysis for rev B is arc-scoped, not issue-scoped. David: *"i want that back"* |
| `scratch/` renamed from `analysis/` | *"i don't like it living in something named 'analysis' — that's human facing and not where i'd expect to see this"* |
| Concerns are **flat index files**, not folders | The matrix correction above |
| Concern analyses live **inside the subject folder** | `report/pwm-light-dimming/analysis-emi.md` |

### Naming

| Path | Example |
|---|---|
| Arc-level work | `arc-work/interface-pcba-rev-b/bom-analysis.md` |
| Per-issue scratch | `scratch/issue-08-hard-kill-path/gate-drive-margin.md` |
| Agent index | `.claude/index/emi.md` — links only, no status |
| Capability report | `report/pwm-light-dimming/README.md` |
| Concern facet of a capability | `report/pwm-light-dimming/analysis-emi.md` |

### The second axis is an agent index, not user documentation

Two reasons it sits in agent space rather than `docs/`:

> *"`concerns` is not [good], that doesn't read well to a human. also, right now, i think
> that is more useful for you and not me … it won't be useful to me as it will be
> something like emi.md with a link to a bunch of stuff i will already be looking at."*

**1. It is agent-facing.** Its value is letting a session ask *"where is every EMI
analysis?"* without walking the tree. David already knows where his own analyses are.
Anything under `docs/` implies documentation a human navigates.

**Therefore it moves to `.claude/index/`** — beside the wiki, in agent space, named for
what it does.

**2. It collides with the RD.** The more serious objection:

> *"i can see how — for me as the user — it could directly conflict with something like
> the RD documents that provide a matrix of what is complete right now."*

A user-facing matrix of *"which subjects touch EMI, and what is their status"* **is a
traceability matrix** — stories × configurations × verification state. That is
Lodestar's job. Building a second one in Arc means two systems answering overlapping
questions and drifting apart.

| | `.claude/index/emi.md` | Lodestar RD |
|---|---|---|
| Audience | Agent | Human, and regulators |
| Answers | *Where does the analysis live?* | *What must be true, and is it proven?* |
| Content | Paths | Requirements and status |
| Authority | None — a lookup table | The source of truth |

**Rule: the index carries no status.** No "verified", no "open", no coverage claims. The
moment it does, it is competing with the RD and one of them will be stale.

```markdown
# EMI — where the analysis lives

Lookup table for agents. No findings, no status. Status lives in the RD.

| Subject | Analysis |
|---|---|
| PWM light dimming | [analysis-emi](../../docs/report/pwm-light-dimming/analysis-emi.md) |
| Cellular module | [emi-coexistence](../../docs/arc-work/interface-pcba-rev-b/emi-coexistence.md) |
```

**The rule: an index never holds findings.** The moment it does, the same fact exists in
two places and the stale copy wins.

**Open:** if Lodestar's RD can already group by a concern axis, this index may be
redundant entirely. Worth testing before building it.

### Is scratch created for every issue?

**No — and this is the asymmetry with the dev-log.**

| | Dev-log | Scratch |
|---|---|---|
| Created | **Every issue** | **On demand** |
| Why | Every issue has a *why* worth recording | Many issues need no working notes |
| Template | Yes | No — it is a notebook |

An empty scratch folder is worse than none: it implies work that was never done.

### Promotion path

```text
scratch/issue-01-.../emi-notes.md
        ↓  it matured into a real finding for this capability
report/pwm-light-dimming/analysis-emi.md
        ↓  register it
.claude/index/emi.md   (a link is added — content stays put)
        ↓  it outlives the arc as a durable product fact
.claude/wiki/emi.md
```

**Only the first step is a rewrite** (notes → written analysis). Registering in a concern
index is a link. Graduating to the wiki replaces the ladder entry with a link, never a
copy.

### When a report exists

A report is warranted when **all** hold:

- It documents a **product capability**, not a task
- Someone other than the author will read it — a colleague, a reviewer, a future
  maintainer
- The conclusions outlive the issue that produced them

Otherwise: analysis. **When in doubt, analysis** — an unnecessary report costs the
attention of every future reader; an unnecessary analysis file costs disk.

### The two compact files stay compact

**Nothing about the dev-log changes** except one line: its retrospective gains a link
into the analyses. Its template rule — *"Decision log, not a spec … capture the why, not
a blow-by-blow"* — is what makes it reviewable and must not be relaxed.

```markdown
## Retrospective

PWM at 1.3 kHz dims the light without a dedicated driver; the load switch
cannot do it at any capacitance.

**Scratch:** [driver switching](../scratch/issue-01-.../driver-switching.md)
**Report:** [PWM light dimming](../report/pwm-light-dimming/README.md)
```

### The dev-log gets a Spawned section

> *"we should have a link section in the devlog to point to 'spawned' documents or
> something so that **if** there is a scratchpad or report we see it in the dev log."*

A new optional section — **omitted entirely when nothing was spawned**, per the
template's existing "skip any section that doesn't apply" rule.

```markdown
## Spawned

- **Scratch:** [gate drive margin](../scratch/issue-08-.../gate-drive-margin.md)
- **Report:** [PWM light dimming](../report/pwm-light-dimming/README.md)
- **Arc work:** [BOM analysis](../arc-work/interface-pcba-rev-b/bom-analysis.md)
- **Issues:** #49, #50 — spawned from the EMI finding
```

**Why it belongs in the dev-log rather than only in the retrospective:**

| | Retrospective links | Spawned section |
|---|---|---|
| Written | At PR time | **As things are created** |
| Holds | What a reader should follow | Everything this issue produced |
| Risk without it | Documents exist that nothing points at | — |

Spawned **issues** belong here too — that is the raw material for the arc-tree diagram
in [handoff-spine](m15-handoff-spine.md), and it addresses the friction-log §2.7 case where
agreed follow-ups were never filed.

**One dev-log per issue remains the entry point to everything that issue produced.**

**This is the key move.** The retrospective becomes the **index into depth** — a
one-paragraph summary plus links. A reader gets the conclusion in ten seconds and can
descend only if they need to. The report link appears only when a report exists, which
is the minority of issues.

### Which tier does a piece of work belong in?

| Ask | Answer |
|---|---|
| Does this span the whole revision or arc? | `arc-work/<arc-slug>/` — BOM analysis, pinout unification |
| Is it working-out for one issue? | `scratch/issue-NN-.../` |
| Does it document a product capability for other people? | `report/<capability>/` |
| Is it a facet of a capability — EMI, safety, BOM impact? | Inside that capability's folder, as `analysis-<concern>.md` |
| Is it a concern spanning many subjects? | `.claude/index/<concern>.md` — **links only, no findings, no status** |

**BOM analysis for rev B is the worked example.** It is not one issue's problem and not a
product capability — it belongs to the arc. That is why `arc-work/` exists as its own
tier rather than being folded into per-issue scratch.

---

## The graduation path

The ladder is working memory. The wiki is long-term memory. Without a promotion step,
the wiki starves while issue folders accumulate durable facts nobody can find.

```text
issue analysis  →  arc analysis  →  wiki
   (this issue)     (this arc)      (forever)
```

| At | Do |
|---|---|
| Issue close | Retrospective links to the analyses; promote anything already cross-cutting to K2 |
| Arc close | Sweep tiers 2 and 3; promote durable product facts to the wiki |
| After promotion | The ladder entry becomes a **link, not a copy** |

**Duplication is the failure mode.** A fact in two places drifts, and the stale copy is
the one a future agent trusts. ROADZ `.claude/wiki/speaker-power.md` is a good example
of a graduated fact — device physics that outlived the analysis that produced it.

---

## Autonomy-switch behaviour

Per [friction-transcript-log](../../retrospectives/2026-08-plugin-line/friction-transcript-log.md) §3.2b, the switch is autonomy, not domain.

| | Autonomous | Guided |
|---|---|---|
| K1 arc-log, dev-log | Yes | Yes |
| **K2 analysis** | Occasionally — a perf study, a protocol comparison | **Yes — most non-trivial issues** |
| **K3 report** | Rare | **Rare** |

**K3 is rare in both modes.** A report is gated on being user-facing and
capability-scoped, and neither of those is a function of autonomy. Software producing a
genuine capability study writes one on the same terms.

**K2 is where the modes actually differ** — guided work generates analytical
by-product on nearly every issue; autonomous work usually does not.

**Nothing forks.** Guided mode fills K2 more often; it does not change how any tier
works.

---

## Open questions

| Question | Notes |
|---|---|
| `report/` or a neutral name? | ROADZ calls it `report/`, but not everything in it is a report. `analysis/` may fit better |
| Does K3 need its own README when small? | A single-analysis issue may not warrant one |
| Who writes K3? | Likely a scribe-type agent; the analysis itself is the engineer's |
| Figure naming | ROADZ uses `c25-0nf-1khz.png` — condition-encoded. Worth making a convention |
| How does a fresh session find K2? | The arc-log needs a "Related analysis" section |
| Retention of source PDFs | Datasheets and brochures in the issue folder — commit, or link? |

---

## Related

- [handoff-spine.md](m15-handoff-spine.md) — the three-tier ladder this implements
- [friction-transcript-log.md](../../retrospectives/2026-08-plugin-line/friction-transcript-log.md) §3.2b — the autonomy switch
- ROADZ `docs/report/issue-01-warning-light-dimming/` — the working example
- ROADZ `.claude/skills/engineering-report/SKILL.md` — governs K3 content
- TimeScope `docs/dev-log/TEMPLATE.md` — the compact form to preserve
