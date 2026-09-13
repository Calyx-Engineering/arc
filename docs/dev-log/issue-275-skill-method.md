# Issue #275 — scope: the skill-writing method and its keeper

> Dev-log, not a spec. Started at plan time, finalised as a retrospective at PR time.

**Issue:** [#275](https://github.com/Calyx-Engineering/arc/issues/275)  ·  **PR:** filled in when it opens

## Problem

Thirteen skills, 4,610 body lines, none written or reviewed with a skill-writing tool. Five tools
were installed or built in and no run had invoked any. The limit in force was 180 lines, recorded
in two dev-logs and in no live artifact, and eleven of thirteen skills exceeded it unnoticed.

## Intent and north star

| | |
|---|---|
| **What this issue is really for** | To make the five review issues below it comparable. Without one method they produce five differently shaped answers about thirteen skills, and nothing can be read across them |
| **North star** | A session about to edit a skill knows which tool to reach for, what the limit is, and what will report on it — without reading this document |
| **What makes it durable** | The decision is named in a hook that fires on the write, not in prose. `tests/verify-skill-method.sh` fails if the decision record loses a decision, or if 180 comes back |
| **Out of scope** | Reviewing any skill — #277–#281. Building the length gate — #276, which merged mid-run. Writing the `CLAUDE.md` line or the hook — #282. Fixing the frontmatter the trial found broken — #338, filed. Each exclusion is a filed issue in the same workstream, so none of them is lost by being out of this unit |

## Decisions & trade-offs

**The two tools split by what they can do with no model run, not by their descriptions.** Both
`skill-creator` and superpowers `writing-skills` claim creating *and* editing skills, so the
descriptions do not discriminate. The trial ran both arms on the same target and asked what each
produced with no model, no subagent dispatch and no human: `writing-skills` produced 17
body-level findings from two markdown files; `skill-creator` produced one mechanical finding and
then needed `claude -p` or a person for everything else. That is the whole basis of the split.

**17 findings is not a better score than 6.** Several of the seventeen are Arc conventions — dated
provenance, a narrative example, a description over 500 characters that
[#155](https://github.com/Calyx-Engineering/arc/issues/155) measured into existence. A checklist
with no notion of a deliberate deviation reports house style as a defect. So the method gained a
fourth bucket, **D — deviation**, recorded once in §4.1 rather than re-argued in five review
issues. Without it the first review would have re-opened #155.

**The limit is lines of body, not lines of file and not words.** `writing-skills` carries a second
budget — *"Other skills: <500 words"* — which puts all thirteen over, and #90 forbids scope
reduction. Anthropic's published number is 500 lines of body; Arc takes that.

**180 needed no deletion.** It was only ever in the dev-logs for #42 and #73, where it correctly
records what was true when they were written. The retirement is a statement plus a gate that fails
if a live artifact ties a limit to 180 again — what made 180 invisible was that nothing read it.

**The reviews' input was already written.** Ten skills declare a `checks:` list in frontmatter, 67
entries. That is the candidate set for bucket **C**, so no review re-derives it by reading 4,610
lines. The three declaring none are a finding in themselves.

## Rejected approaches

| Rejected | Why |
|---|---|
| `claude plugin eval` as the reviewer | `` `plugin eval` is currently in early access ``, exit 1. Gated — [#181](https://github.com/Calyx-Engineering/arc/issues/181) |
| `claude plugin validate skills --strict` as the reviewer | Exit 0 on all thirteen skills, including an 852-line body and five whose frontmatter a conformant YAML parser rejects. On a fixture it caught a missing `description` and missed a 900-line body, a 1,500-character description, and a `name:` matching neither its directory nor the naming rules. Kept as a precondition |
| `/skill-doctor` as the reviewer | Its own description is *"Show which loaded skills are unused and costing context"*. It reads one session's usage, not a skill |
| Adopting `writing-skills`' TDD cycle | Its Iron Law is *"NO SKILL WITHOUT A FAILING TEST FIRST… applies to NEW skills AND EDITS… Write skill before testing? Delete it. Start over."* Thirteen exercised, tuned skills cannot be deleted and re-derived, and #90 says *Edit in place* and *No rule is lost* |
| Answering the cheaper-carrier question for all thirteen skills here | The issue's own box routes it — *"the question the reviews below answer"*. §4.2 gives each review its first question and marks itself a starting point, not a verdict |
| A second gate measuring skill length | #276 owns that. Two gates reporting the same number is how they drift — which is also why #341 corrects #276's rather than adding one here |

## Findings

**`claude plugin validate .` at the repo root validates the marketplace manifest and not one
skill**, printing `✔ Validation passed`. The skills are only reached by naming the directory. A
run that types the obvious form gets a green result having checked nothing. In §2.1, so the
command the method names is the one that works.

**Five of thirteen skills have frontmatter a spec-conformant YAML parser rejects** — `camp`,
`chat-response`, `engineering-report`, `handoff`, `record-route`. A `: ` inside an unquoted
`description` scalar. Confirmed with `yaml.safe_load` over all thirteen, independently of the tool
that found it. They load today only because Claude Code's own loader is lenient. Filed as
[#338](https://github.com/Calyx-Engineering/arc/issues/338), with the ten skills carrying
out-of-spec top-level keys folded in — same edit.

**Four skills have no hook and no script naming them at all** — `record-route`, `arc-intent`,
`spec-interview`, `plugin-retrospective`. `record-route` is the interesting one:
`tests/verify-dev-log-name.sh` checks its `dev-log-exists` rule without naming the skill, so the
carrier exists and the link does not.

**A `| tail -30` on `verify-all.sh` produced a zero-byte output file for thirty minutes**, reading
exactly like a hang. `tail` buffers to EOF, so a backgrounded run piped through it shows no
progress at all. Redirect to a log instead. Worth knowing before anyone concludes the suite has
stalled — two `TaskOutput` blocks were spent on it.

## Spawned

- **Arc work:** [the skill-writing method](../arc-work/04-dogfood/skill-method-decision.md)
- **Issues:** [#338](https://github.com/Calyx-Engineering/arc/issues/338) — frontmatter is not spec-conformant, found by the trial's mechanical pre-pass · [#341](https://github.com/Calyx-Engineering/arc/issues/341) — the length gate measures the file where the limit is the body

## Retrospective

Four decisions, one document, one gate. Review is superpowers `writing-skills`' checklist applied
statically; writing is `skill-creator`; `quick_validate.py` is a free mechanical pre-pass on both
paths. The limit is 500 lines of body measured on `skills/`. The keeper is `hooks/skill-guard`,
named here and built by #282.

What changed from the plan is the fourth bucket. The issue asked for three routes — judgement,
evidence, checkable — and the trial showed that a reviewer with no concept of a deliberate
deviation would push Arc's own measured decisions back into review five times over. §4.1 is the
list that stops that, and it is the part of the document a reviewer needs before the part that
chose the tools.

**#276 merged into the base mid-run**, which is how #341 was found: its gate counts file lines
where §3 had just adopted body lines. A future reader should note the order — the divergence was
visible only because the merge happened while the decision was still being written, and the two
numbers would otherwise have sat in the repo unnoticed exactly as 180 did.
