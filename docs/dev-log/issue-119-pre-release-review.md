# Issue #119 — the pre-release review

> Decision log, not a spec. Started at plan time, finalised as a retrospective at PR time.

**Issue:** [#119](https://github.com/Calyx-Engineering/arc/issues/119)  ·  **PR:** —

## Problem

**Almost nothing Arc ships has ever run.** `hooks/hooks.json` resolves `${CLAUDE_PLUGIN_ROOT}`,
which resolves only for an installed plugin, so no hook has fired in a live session and no skill
has been invoked. Every acceptance criterion written as runtime behaviour is asserted.

Thirteen skills, four hooks, two commands, five templates and a manifest are about to be
released on that basis.

## Intent and north star

### Pass 1 — from the issue body alone

| | |
|---|---|
| **What this is really for** | Not finding bugs. **This is the last moment a defect is cheap** — the issue says so outright, and after the release a defect is in someone else's workflow rather than in a file we own |
| **North star (pass 1)** | Every shipping artifact has been read against what it claims, by someone who did not write it that day, and the reading is repeatable — the second review executes the document rather than re-deriving the method |

### Pass 2 — after an orienting sweep of the whole shipping tree

**Three things changed, and the third resizes the deliverable.**

| | |
|---|---|
| **The review has a shape the issue's checklist does not** | Its seven boxes are a *list of surfaces*. What they are actually asking for is four kinds of question — does it parse, does it resolve, does it match its own declaration, does it match the mechanism it claims. **Those are passes, and they are ordered**: a skill whose frontmatter does not parse cannot have its declaration checked |
| **`tools/` already answers a third of it, and nothing says so** | `verify-all.sh` runs 8 gates over hooks, tracker rules, the autonomy arms and skill parity. The review must not re-do by eye what a script already does exactly — it must **say which boxes the runner closes** and spend its attention on the ones no script can |
| **The blind spot is not one line, it is the review's whole boundary** | *Nothing here proves a hook fires* understates it. Nothing proves a **skill is invoked**, that a `description:` triggers, that a `command` loads, or that the manifest installs. The review can only check that each artifact is **internally coherent and consistent with what specifies it**. Saying that once at the bottom is not enough — it has to be visible where a reader would otherwise conclude the opposite |

**A concrete instance found in the sweep, before the review proper.** `hooks/camp-session-start`
is registered as a `PreToolUse` hook on `Edit|Write|NotebookEdit`. Its name says `SessionStart`.
The header comment says the registration is deliberate — so this is not a mismatch, it is a name
that will be read as one. **That is exactly the class this review is for**: nothing is broken, and
the next person to read `hooks.json` loses time deciding whether it is.

**North star.** A second reviewer, cold, executes `docs/release/pre-release-review.md` and reaches
the same findings — and can tell, without asking, which claims the review actually establishes and
which it only says are unchecked.

| | |
|---|---|
| **What makes it durable** | It survives the artifact list growing, because the passes are defined over *kinds* of artifact rather than a list of files. It survives being run by someone who did not build any of it. It survives the release, because the same document is what a second release runs |
| **Out of scope** | **Fixing.** The issue is explicit — findings are filed, not repaired in place, or the review leaves no record of what was wrong. Also out: proving runtime behaviour, which only an install does |

### Intent check

**Agreed.** Step 24 / wave 6.4 of §10, in the milestone, and it gates
[#120](https://github.com/Calyx-Engineering/arc/issues/120). *Why this arc exists* names Arc's
operation being invisible as one of the two failures Camp exists to fix; shipping thirteen
unexercised skills without a written account of what was and was not checked is that failure
about Arc itself.

## The plan

| # | | |
|---|---|---|
| 1 | **Write `docs/release/pre-release-review.md` first** | The passes, the routing of a finding, and what the review cannot establish. Two mermaid diagrams — the pass order, and a finding's route from spotted to filed |
| 2 | **Run it**, pass by pass, recording findings as they appear | Read, do not repair |
| 3 | **`bash tools/verify-all.sh`** | And record which of the issue's boxes it closes, rather than re-checking them by eye |
| 4 | **File the findings** | One issue per finding, or one issue per cluster where a fix is one change. **Nothing fixed in this PR** |
| 5 | **Record the result in the document** | The first run's findings live with the process that found them, so the second run has a baseline |

**The document is written before the review, not after it.** Writing it afterwards produces a
description of what happened to be done, which is the thing that cannot be executed twice.

## Retrospective

*Written at PR time.*
