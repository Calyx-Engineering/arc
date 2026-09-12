# Issue #226 — The close-sequence gate fires on prose that is not a count claim

> Dev-log, not a spec. Started at plan time, finalised as a retrospective at PR time.

**Issue:** [#226](https://github.com/Calyx-Engineering/arc/issues/226)  ·  **PR:** batched with [#234](https://github.com/Calyx-Engineering/arc/issues/234), one PR

## Problem

`tests/verify-close-sequence.sh` reported *"skills/issue-write/SKILL.md states a step count that is
not ten — 431:The three steps"* during [#87](https://github.com/Calyx-Engineering/arc/issues/87).
The sentence was about three shell commands. The header said the gate recognised four claim
forms and was "not a scan for any number beside the word steps"; the regex's `the [a-z]+ steps`
alternation was that scan, in a file that qualified only because it linked the document.

## Intent and north star

| | |
|---|---|
| **What this issue is really for** | The gate stops shaping unrelated prose while still catching a count that drifted |
| **North star** | A file that cites the sequence can say *the three steps* about anything else; a file that says *the nine steps* of the sequence is still reported |
| **Out of scope** | Any change to what the close sequence says, or to the count |

## Decisions & trade-offs

| | |
|---|---|
| **The fourth form is tied to its line** | `the <n> steps` counts only on a line that also names the sequence — `close-sequence`, `close sequence` or whole-word `closing`. Every live claim of that form already sat beside the link or the adjective; #87's sentence did not. A paragraph-level tie was considered and rejected: the citation on line 3 and the prose on line 40 is the false positive again with one more step in it |
| **The count slot takes a number word only** | `[a-z]+` before *steps* let "the closing steps" read as a claim of a count called *closing*, and the comparison reported it as "not ten". Found while writing the drifted fixture, so it is a fixture now (`pass/the-closing-steps-no-count.md`). Digits are still invisible, as before, and the header now says so |
| **The other three forms are unchanged** | A heading, a bold lead-in opening with a count, and "the same N steps" are claim shapes wherever they appear. `skills/camp`'s bold lead-in has no tie word on its line; tying it would have silenced a real claim, which the issue's first constraint forbids |
| **A selftest with `expect:` markers** | Exit code alone cannot show that a claim is still recognised — a regex loosened to match nothing passes every pass case. Each pass fixture's first line says which pass it expects: *states no count* proves the prose was not read as a claim, *agrees on ten* proves a real claim still is. Four drifted fail fixtures, one per form, are the anti-silence half |
| **`closing` ties as a whole word** | Pass 1 found `enclosing` and `disclosing` tying a line. Anchored with `(^\|[^a-z])closing([^a-z]\|$)` |
| **File qualification is case-insensitive** | Pass 2 found the file scan keyed on `closing steps` lower-case while every line match was `-i`, so a file whose only tie was a sentence-initial *Closing steps* was never scanned. One flag |

## Rejected approaches

| | |
|---|---|
| **Dropping the fourth form** | `skills/camp` and `skills/decompose` state the count that way beside the link. Losing them is the silence the issue forbids |
| **Requiring the tie in the same paragraph** | Reintroduces the #87 shape one paragraph wide |

## What the run hit

| | |
|---|---|
| **Heredocs through the Bash tool eat backslashes** | `'\r'`, `'\1'` and `'\n'` inside a quoted-delimiter heredoc arrived in Python as a raw CR, `\x01` and a newline. Three edits were spent finding that. Built escapes with `chr(92)` instead |
| **Sub-agents hit the account's weekly limit** | Pass 3's first two dispatches were refused with HTTP 429 on two models; the run ended and was resumed. Passes 1, 2 and 3 all ran as sub-agents in the end |
| **`tools/verify-all.sh` and `tools/verify-linked-branch.sh` do not exist** | The run instructions name them under `tools/`; both live under `tests/`. Noted, not fixed — not this issue's |

## Evidence

`bash tests/verify-close-sequence.sh selftest` — 8 passed, exit 0. `bash tests/verify-close-sequence.sh` — 11 passed, exit 0. `bash tests/verify-all.sh` — in the commit body.

## Spawned

None.
