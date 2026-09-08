# Issue #203 — The coordination prefix is a setting

> Dev-log, not a spec. Started at plan time, finalised as a retrospective at PR time.

**Issue:** [#203](https://github.com/Calyx-Engineering/arc/issues/203)  ·  **PR:** [#249](https://github.com/Calyx-Engineering/arc/pull/249)

## Problem

`hooks/branch-guard` classified a coordination branch with `arc/*)`.
[PR #200](https://github.com/Calyx-Engineering/arc/pull/200) fixed the work-branch half — it
keys on the `-issue-<N>-` or `-pr<N>-` segment rather than the prefix — and left the
coordination half compiled in. A repository whose branches are `rev/…` got no coordination
guard at all, silently.

## Intent and north star

| | |
|---|---|
| **What this issue is really for** | The prefix is the repository's decision, and the operating agreement is where a repository states its decisions. The hook was holding one of them |
| **North star** | Changing one value in the agreement changes which branch the guard treats as coordination, in the shipped template as well as here |
| **What makes it durable** | The value reaches a `case` pattern. It has to be impossible for a clause someone types to deny every source edit in their repository |
| **Out of scope** | Which labels mark a work branch — `issue` and `pr` are still compiled in. That is a second setting and a second decision, recorded on the issue's `Spawned` table. Also `camp-session-start`'s own hardcoded `arc/*)`: one hook per commit |

## Decisions & trade-offs

| | |
|---|---|
| **The clause is a value line, not a checkbox** | Section 3 is checkbox lists, but a prefix is not a choice among options. A bolded label and a code span — the value here is `arc/` — matching the **Repository:** line the file already opens with |
| **The read is bounded at the repository root** | `git rev-parse --show-toplevel`, then one `[ -f ]`. `camp-branch-check` walks up the tree for `CLAUDE.md`; here that walk could reach a `.claude/` outside the repository, and a per-repository setting read from outside the repository is worse than not reading it |
| **Every form a user types is read** | Indented, bulleted, checkboxed, colon outside the bold, and with or without the code span. The section's own instruction is *"check one per setting"*, so a checkbox is what a reader reaches for — and a form that silently reverts to `arc/` is the misclassification this issue is about, arriving by a different door |
| **The value must end in its separator** | `arc/`, `rev-`. This is the agreement's own wording, and it is what tells a prefix from a word: `none`, `unset` and `TBD` are how a repository says it has none, and reading one literally would classify nothing as coordination and switch the guard off across the whole repository |
| **`KIND=arc` became `KIND=coord`** | The value reaches the activation log. `branch-kind=arc` on a `rev/` branch is a record that reads wrong |
| **A second verifier, not new cases in `verify-hook.sh`** | Every case here needs a repository holding an agreement, which no case payload can express — and that script is on CLAUDE.md's never-edited-autonomously list. Same precedent as `verify-workspace-guard.sh` |
| **The `checks:` header is unchanged** | The prefix read is an input to `branch-kind`, not a check of its own. It surfaces as `prefix=` on the `edit-checked` event instead |

## Rejected approaches

| Rejected | Why |
|---|---|
| Reading the prefix from `CLAUDE.md`'s branching section, as `camp-branch-check` does | The issue names the agreement, and the agreement is the file the user amends by reviewed diff. That the two hooks now read two files is recorded in [m10](../product-architecture/mechanisms/m10-branch-guard.md)'s *What is not decided* |
| Adding the cases to `tools/verify-workspace-guard.sh` | Its name is the worktree check. A prefix section there makes the file's name wrong |
| Deriving the coordination prefix from the current branch | Inference is what the hardcoded `arc/` already was, one level up |

## Retrospective

Three review passes, and passes 1 and 2 each found the safety argument wrong.

**Pass 1** disproved the comment that justified the design. It claimed a clause reading `*`
would classify every branch as coordination; `"$PREFIX"*` is a **quoted** expansion, matched
literally, so a glob is inert. It also found that a value typed without backticks parsed to
empty and fell back silently.

**Pass 2** disproved the replacement. The corrected comment credited the charset test's `+`
with holding off the empty value; what actually holds it off is that `printf '%s' ""` emits no
line for `grep` to match at all — a mutation replacing the whole pattern with `*$` left every
fixture green. Pass 2 also found `none` and `unset` being taken as prefixes, and the checkbox
form reverting silently. Both are now fixtures.

**Pass 3** confirmed all three boxes behaviourally rather than by text, and named the tension
in the issue's own wording: *"an unreadable agreement means allow, never deny"* against
*"default to `arc/` when unset"*. An unreadable agreement on an `arc/`-prefixed branch still
denies. The two cannot both hold literally; the code resolves it as **never deny more than
before this change**, which is what fail-open means here.

**Not soaked.** The hook fires from the installed plugin copy, current only after
`tools/plugin-reload.sh`, and five runs are working in parallel worktrees off this base —
reloading from one of them is not this unit's call. `.claude/arc/log.md` carries no
`prefix=` entry, so the change is unsoaked in the record and soaks on the next work stretch.

**Gates:** `bash tools/verify-all.sh` → exit 0, 38 gates clean, including the new
`branch prefix` gate at 17 cases. `bash tools/verify-hook.sh hooks/branch-guard` → 18 passed,
0 failed.
