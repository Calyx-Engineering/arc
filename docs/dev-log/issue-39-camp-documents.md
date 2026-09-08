# Issue #39 — Camp's three documents

> Dev-log, not a spec. Started at plan time, finalised as a retrospective at PR time.

**Issue:** [#39](https://github.com/Calyx-Engineering/arc/issues/39)  ·  **PR:** [#51](https://github.com/Calyx-Engineering/arc/pull/51)

## Problem

Camp has no identity until its documents exist. Every later issue in the arc reads or amends
them, so nothing else in wave 1 or 2 can start.

## Decisions & trade-offs

| | |
|---|---|
| **Two copies, not one generated from the other** | `templates/camp/` ships with the plugin; `.claude/arc/camp/` governs this repo. The live copy carries Arc's real standing corrections — David's, from `CLAUDE.md` — and the template carries four generic ones plus a place to add more. Generating one from the other would force the shipped default to be either empty or Arc-specific |
| **Standing corrections seeded from `CLAUDE.md`** | The *"Working with David"* table already is a standing-corrections list. Section 5 restates it as clauses Camp reads before acting; `CLAUDE.md` keeps it for sessions working on Arc. Duplication is deliberate — the two have different readers, and m43 §5.1.3 is explicit that a correction outliving its session is the point |
| **The rejected-approaches table lives in the agreement too** | `CLAUDE.md` carries *"Rejected, so they are not re-proposed"*. It is a standing correction in the same sense: things not to repeat |
| **`templates/camp/` as a subdirectory** | `templates/` was flat — `arc-log.md`, `dev-log.md`, `handoff.md`. Three more flat files would not read as one set, and Camp's three are installed together |
| **The template ships populated, and says so** | m43 §5.1.5 requires a populated default. The template's header states that unedited clauses govern, so an installer does not read them as unset |

## Rejected approaches

| Rejected | Why |
|---|---|
| A blank or placeholder agreement | m43 §5.1.5 — a blank one leaves Camp without obligations until the user writes them, making the first session useless |
| One agreement file with an *"Arc-specific"* section | The template is what a new repository installs. Shipping Arc's own corrections to every consumer is wrong; stripping them at install is a build step for a documents-only artifact |
| Placing the three under `docs/` | m43 §5.3 — configuration a human reviews, not documentation a human navigates. Agent space, namespaced under `arc/` so Lodestar's Star and Bench do not collide |

## Retrospective

Six files: three live under `.claude/arc/camp/`, three templates under `templates/camp/`.

The live agreement is the substantive half. Its section 5 converts `CLAUDE.md`'s *"Working
with David"* and *"Rejected, so they are not re-proposed"* tables into standing corrections —
which is what m43 §5.1.3 describes, arrived at independently. That the repo already kept such
a list by hand is the strongest available evidence the clause type is right.

**What could not be verified:** that any of this *governs*. Nothing here executes. The
documents are read by all five obligations, none of which are built — #40 reaches Camp,
#45 makes it report. Until those land, the agreement is a document with no reader, and the
`why-are-you-doing-this` test in section 1 has nothing enforcing it. This is the arc-log's
already-named *"skills cannot be executed here"* risk, showing up on the first issue.

**Checked against the m43 §2.1 diagram before the PR.** Every node and every arrow — three
documents, the amend/govern/style/inform arrows, propose-amendment, write-freely, and
answers-come-from-the-record — maps to delivered content. No mismatch.
