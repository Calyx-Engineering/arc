# Issue #162 — `camp-branch-check` rejects conforming branches

**Issue:** [#162](https://github.com/Calyx-Engineering/arc/issues/162)  ·  **PR:** pending

## Problem

The hook matched one repository's branch shape:

```sh
case "$NAME" in
  arc/*-issue-*) ;;
  arc/*-pr[0-9]*) ;;
  arc/*)  add "… is an arc branch, not a work branch" ;;
  *)      add "… matches neither arc/<nn>-<slug>-issue-<N>-<slug> nor …" ;;
esac
```

Arc names arcs `arc/<nn>-<slug>`. The client repo names them after the product component being revised, and declares so in its own `CLAUDE.md`: *"New branches take `<module>/rev-<X>-issue-<NN>-<slug>`"*. Every branch on that convention fell through to the last arm. Five firings in three weeks of hardware work, correct none of the times.

The hook was not wrong about the rule. It was wrong about whose rule it was.

## The fix — the convention is read, not assumed

| | |
|---|---|
| **Where it reads it** | `CLAUDE.md`'s branching section, from the nearest `CLAUDE.md` up the tree from the payload's `cwd`. That is the file the session was already given, so a repo that declares a convention to its agents has already declared it to this hook |
| **What it takes from it** | The backticked branch names in that section. Those carrying a labelled number are the *declared forms*; the label is what the repo calls its numbers |
| **What it checks** | One thing: does the name carry an identifier number. `issue` and `pr` hold everywhere — they are m46 §9's, not any repo's — and the declared forms add whatever else this repo labels a number with |
| **What it no longer checks** | The shape. No branch pattern is compiled into the hook at all |

**A repo that declares nothing gets silence.** No `cwd`, no `CLAUDE.md`, no branching section: `exit 0`. With no convention to check against, anything the hook said would be its own opinion — which is how the five false reports happened.

### Decisions

| | |
|---|---|
| **`issue` and `pr` are not derived** | The client repo's `CLAUDE.md` declares only the issue form, and its real `…-pr58-arc-setup` branches conform. Deriving labels *only* from the declared text would have re-created the bug against a repo that documents one of its two forms |
| **A declared form ends `-<number>-<slug>`** | The trailing separator is what separates an identifier from a version tag. `release/2026-q4` ends at its number; reading `q` out of it as a label let `feat/q4-anything` pass as numbered — [pass 2](#the-review-passes) caught that, live |
| **A name the section spells out in full is exempt** | The client repo declares `widget-board/rev_b` as its integration branch two lines above the work-branch form. It carries no number and is not meant to. Telling a repo to rename the branch its own convention names is the failure being fixed |
| **Link targets and filenames are not branch names** | `skills/issue-write` and `tools/new-direct-pr.sh` both appear in Arc's branching section |
| **Only shell metacharacters are rejected, never "illegal" ref names** | `git branch \| grep foo` put an operator in the name slot and got a report about a branch called `\|`. The first repair whitelisted ref-shaped names instead and silenced `'fix-the-thing'`, `fix-the-thing;` and `_wip` — legal names, one of them exactly what the hook is for |

## The cases

`tools/hook-cases/camp-branch-check/` — 28 assertions, three fixtures.

| Fixture | What it is for |
|---|---|
| `fixtures/module-rev` | The client repo's declared convention. The **regression** fixture: five of its real branch names, all of which reported before this change |
| `fixtures/labelled` | A convention labelling numbers `ticket`, a word Arc does not know. The **proof of the read** — and only as a pair, because a pass case alone is also green when nothing was read |
| `fixtures/silent` | A `CLAUDE.md` with no branching section. One of the two silences; `__FIXTURE_MAIN__` is the other, a repo with no `CLAUDE.md` at all |

The client repo's branch shapes (names changed), all previously reported and all now passing: `widget-board/rev_b-issue-1-lamp-driver`, `widget-board/rev-b-issue-15-output-isolation`, `widget-board/rev_b-issue-39-unify-mcu2040-pinout`, `widget-board/rev-b-pr58-arc-setup`, `widget-board/rev-b-pr70-bench-sweep`. The third carries digits in its slug (`mcu2040`), which is the case that pins *extract the number, do not match the slug*.

## Three repairs the issue does not name

The convention read exposed defects in the surrounding code that had to be fixed for it to work at all.

| | |
|---|---|
| **`field()` matched an unquoted substring** | `grep -m1 -- "$1"` matches any key *or value* containing the field name. The helper was dead code until this change; the convention read is its first caller, and the path it returns had to be the `cwd` key. Now `"\"$1\""`, as `mode-guard` has it |
| **`CMD` kept the payload's closing braces** | `s/"$//` strips a quote only at end of line, so a `…"}}`-terminated payload put `widget-board/rev-b-pr70-bench-sweep"}}` in the report — the name quoted back was not the name created |
| **`NAME` can be emptied after it is read** | Stripping quotes and a `;` from a shell token can leave nothing, so the emptiness test is repeated after the strip |

**Eight existing cases changed their `cwd`** from a throwaway fixture repo to `.`, because a hook that reads a convention cannot be tested against a repo that has none. The consequence is a coupling worth knowing: those eight now read **Arc's own `CLAUDE.md`**, so editing this repo's branching section changes their verdicts.

## Verification

```text
bash tools/verify-hook.sh hooks/camp-branch-check   → 28 passed, 0 failed   exit 0
bash tests/verify-all.sh                            → 13 gates, all clean   exit 0
```

**Run them one at a time** — see the last row of *Not done*.

Before the change, the case directory as it then stood ran 15 passed, 5 failed. Against the directory as it stands now, the old hook runs 17 passed, 10 failed, and **all five client-repo names report in one run**. An earlier reading of this dev-log said four of the five reported and the fifth was confirmed by hand; that was the kill-switch race below, not a property of the hook.

## The review passes

The three passes are the record's substance here, because two of them found defects the run had already convinced itself were not there.

**Pass 1**, against the issue: nine findings. Seven in scope and fixed — `git branch | grep foo` reported on `|`; the client repo's own integration branch was reported; the `camp-reports:` declaration named a `base-is-arc` check that does not exist and printed a skip reason that was false when a base *was* given; the section extraction merged two headings; a Windows `cwd` arrives escaped and was silently discarded; and two cases passed for the wrong reason.

**Pass 2**, against pass 1's repairs: the two that mattered were both introduced by the repairs.

- The ref-name whitelist silenced `'fix-the-thing'`, `fix-the-thing;` and `_wip` — three names the hook should report, and a straight regression on the defect class being fixed.
- `release/2026-q4` in the labelled fixture entered the declared forms, contributed `q` as a label, and made `feat/q4-sync-retry` pass as numbered. It also meant the one report case in that fixture quoted the wrong form while staying green, because `verify-hook.sh` asserts exit codes and never report text.

Both are now cases: `report/quoted-name`, `report/version-tag-not-a-label`.

**A repeated pass would have found neither.** Pass 1 read the hook against the issue and was right about it; the damage was in what pass 1's own fixes did afterwards.

## Not done, and what it spawned

| | |
|---|---|
| **A convention with no word label reports everything** | A repo declaring `feature/<NN>-<slug>` — a number with no label — conforms to itself and gets reported, because `issue`/`pr` are the fallback. Accepting a bare number as an identifier would make `arc/04-next` pass, which is a report worth keeping. No such repo exists in this line |
| **`CMD` truncates at an escaped quote** | `echo \"x\" && git checkout -b …` is never examined. Fails open, so it is a missed report, not a false one |
| **`tools/verify-hook.sh` cannot be edited here** | It is hard-excluded from autonomous edits (`CLAUDE.md`, safe hook editing), so two limits stand: the fixture cases carry repo-relative `cwd`, valid only when the suite is run from the repo root; and the kill-switch assertion `touch`es and then removes the shared `~/.claude/HOOKS_OFF` (`verify-hook.sh` §kill switch). **Reproduced.** Run A touches the file; run B starts, records it as pre-existing, finds every `report/` case suppressed — 7 failed, exit 1 — and run A then deletes it. Seen twice here against an unchanged tree, once with all seven report cases failing at once, while the same tree run alone is 28 passed, 0 failed. Any two gate runs on this machine collide, including runs from a different worktree or a different session. A fix belongs in `verify-hook.sh`: a private `HOME` for the suppression assertion, or a lock |

## Soak

Unsoaked at merge. A hook change is exercised by the next work stretch that creates a branch — in this repo or in the client repo, whose branch shapes are now the regression cases. The soak line belongs in this repo's `arc-log`, appended by whichever repo exercises it.
