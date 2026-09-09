# Issue #174 — Response verbosity is a setting, not a fixed default

> Dev-log, not a spec. Started at plan time, finalised as a retrospective at PR time.

**Issue:** [#174](https://github.com/Calyx-Engineering/arc/issues/174)  ·  **PR:** [#255](https://github.com/Calyx-Engineering/arc/pull/255)

## Problem

The operating agreement carried Camp's report and nudge verbosity and nothing for the session's
own replies. `skills/chat-response` held a fixed default table and consulted no setting, so the
only way to shorten replies was to say a number in conversation — which
[#158](https://github.com/Calyx-Engineering/arc/issues/158) measured being lost after one turn.

The fact that makes it matter — *he reads slowly and deliberately* — lived in this repository's
`CLAUDE.md`, where it reached no other repository and no other machine.

`skills/decompose` named a second missing clause in its own *Known gaps*: work size, stated as
a preference with no home and no boundary.

## Intent and north star

| | |
|---|---|
| **What this issue is really for** | A length preference is a property of the reader. It belongs in the file the user amends, not in one repository's instructions and not compiled into a skill |
| **North star** | Checking `brief` in the agreement shortens every reply in the session, in any repository Arc is installed in |
| **What makes it durable** | The number reaches an instrument. `tools/response-length.sh` scores a reply against the clause, so a setting that stops being read is a failing case rather than a silent regression |
| **Out of scope** | Whether a stated budget survives ten turns — that is [#158](https://github.com/Calyx-Engineering/arc/issues/158) and [#213](https://github.com/Calyx-Engineering/arc/issues/213), and this changes where the budget comes from, not how long it is held |

## Decisions & trade-offs

| | |
|---|---|
| **The clause is a checkbox, in section 1** | The issue's constraint, and it is right: `camp:307` already reads two verbosity settings out of that section by checked box. A third one costs no new mechanism |
| **The number lives in the clause, not in the scorer** | A user editing `brief` from 40 down to 25 is scored at 25. A scorer holding its own copy of what `brief` means would score every repository identically, which is the opposite of a user-owned setting |
| **Which levels carry a number is the level's property, not the line's** | Only `brief` and `Other:` state a budget. `normal` and `full` return none whatever their lines say — see the retrospective, where reading a number off the wrong line was the defect both review passes found, in opposite directions |
| **`normal` is the shipped default and is the existing table** | The issue's second constraint. No clause, no file and an unreadable value all mean `normal`, so a repository that never opens the agreement behaves exactly as before |
| **`full` sets no budget at all** | It reports as unscorable rather than passing. An agreement saying *as long as it takes* has not set a number, and inventing one for it would grade a rule nobody wrote |
| **Section 4's *Chat length* keeps the order, section 1 takes the length** | The agreement already had a `Short`/`Full` clause about whether the answer or the reasoning comes first. Two clauses stating a number would be two numbers to keep in step; one line in section 4 now says which is which |
| **The work-size clause is a value line, not a checkbox** | A ceiling is a number, not a choice among options — same precedent as the branch prefix, [#203](https://github.com/Calyx-Engineering/arc/issues/203) |
| **Seven is measured** | The 90th percentile of the `Required` checklists in the Dogfood milestone — 67 issues carry one, median 4. The clause carries the command that reproduces it, because a number stated without one is a number nobody can check |
| **A fixture case's `turns/` and `replies/` check each other** | Bounded by `first_turn..last_turn`. With no transcript to compare against, nothing else notices a reply added with no turn asking for it, or a turn whose reply was deleted — the first widens the case, the second narrows it |
| **The eval case is a fixture, not a replay** | Every other `evals/response-length` case names a recorded session. No recorded session was ever governed by a clause that did not exist when the corpus was captured, so this case stores its replies beside it. It is portable as a result — no transcript, no corpus, scorable anywhere |
| **`--probe` skips a fixture case** | A live probe cannot install the case's agreement into the session it opens. It would score the reply against *this* repository's agreement and report the wrong number with no sign anything was substituted |

## Rejected approaches

| Rejected | Why |
|---|---|
| Extending section 4's *Chat length* instead of adding a section 1 clause | The issue names section 1, and the reason holds: section 1 is the section a mechanism reads by checked box. Section 4 is prose about shape and nothing reads it |
| Putting the level definitions in `voice.md` | That file is how *Camp* sounds. Reply length is the session's, not Camp's — the friction-log clause already links `record-route` rather than `voice.md`, so a per-clause link is the established form |
| A table of three level budgets compiled into `tools/response-length.py` as the authority | Only `brief` keeps a fallback there, for a clause that names no number at all. Making the file the authority would mean the scorer, not the user, owned the setting |
| Deleting section 4's *Chat length* | It carries a real preference — answer first versus reasoning first — that section 1 does not hold |

## Evidence

| | |
|---|---|
| `bash tools/response-length.sh selftest` | 48 passed, 0 failed — 23 of them new: the agreement read, an edited number, `Other: <n> words`, the uncapped level, the shipped `normal` level, a blank clause, two boxes checked, a repository with no clause, and four fixture pairing cases |
| `bash tools/response-length.sh` | The new case scores `1/3 0.33` at 40 words: `replies/2.md` is 149 words of correct answer and 3.7× the budget the agreement set |
| `bash tests/verify-all.sh` | See the PR body |

## Retrospective

**The issue's first box was already half-built and the second was already whole.** Section 4
carried a *Chat length* clause nothing read, and section 3 carried an *Issue granularity* clause
that stated a direction without a boundary. Reading the required boxes as *add two clauses*
would have produced a file with two settings about reply length and two about issue size. What
each box actually asked for was the half that was missing: a value a mechanism reads.

**The same defect was written twice, in opposite directions, and each review pass caught one.**

| | The parser | What it did |
|---|---|---|
| First version | any `<n> words` on the checked line | Read `~150` out of `normal`'s descriptive prose. **Every repository that never edited its agreement got a flat 150-word budget nobody chose** — the issue's *default unchanged* constraint broken in the one configuration almost every repository is in. Pass 1 |
| Second version | a **bolded** `**<n> words**` | A user editing `brief` to `25 words of prose` without asterisks got 40 and no warning. The same defect mirrored, and the likelier edit of the two. Pass 2 |
| Third | the level decides whether to look at all | `normal` and `full` never carry a budget; `brief` and `Other:` take any figure on their line |

**Both versions failed the same way: they asked the line what it meant instead of asking the
setting.** The fix is not a better regex. `normal` is a table and `full` is uncapped, so neither
can hold a number however it is typed, and once that is the rule the formatting stops mattering.

**Pass 2 also found the assertions could not have caught it.** The selftest asserted `brief, 40
words` — which is also the fallback constant, so deleting the number-reading entirely left every
test green. Reading a user's number is now tested at 25, a value that exists nowhere in the
scorer.

**Seven, not nine.** The first ceiling was the 90th percentile of *every checkbox in the issue
body*; the clause governs the `Required` section, whose 90th percentile is 7. The number was
wrong because the measurement measured something adjacent to what the clause said.

**Pass 4 found three numbers about checklist length in one section.** The `Issue granularity`
checkboxes were left as written — *"a fourteen-point checklist is two or more issues"*, and
*"twenty to forty checklist items"* on the alternative — six lines above the new
`Checklist ceiling: 7`. Adding a value clause beside an option that already states its own
number leaves a reader with two answers and a user who edits the ceiling with three. The
checkboxes now carry the direction only, which is the split section 4's *Chat length* had
already been given in this same PR and section 3 had not.

**It also found the PR title missing its type.** `arc-04: the operating agreement tunes…`
against every other PR in the arc's `arc-04: <type>: <summary> (#NN)`. That is the pass-4 class
exactly: nothing about it is visible until the unit is a PR, and the branch, the commits and the
issue all read correctly.

**And m43 §5.1.2 still described section 4 as *"where long is wanted, where short"*** — true
before this PR moved length into section 1, and left describing the file as it used to be.
