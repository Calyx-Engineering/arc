# Issue #211 — fix: plugin-reload.sh reverts uncommitted edits to the plugin's own skills

**Issue:** [#211](https://github.com/Calyx-Engineering/arc/issues/211)  ·  **PR:** [#289](https://github.com/Calyx-Engineering/arc/pull/289)

## Problem

`tools/plugin-reload.sh` was believed to revert uncommitted edits inside the plugin's component
directories: [#158](https://github.com/Calyx-Engineering/arc/issues/158) lost
`skills/chat-response/SKILL.md` back to its `HEAD` content with an empty stash list and a reflog
showing only a branch checkout, and recovered it only because the diff was still on screen.

## Intent and north star

| | |
|---|---|
| **What this issue is really for** | The dev loop installs from the repository itself, so a reload is the one routine command that reads a live working tree. Nothing checked what state that tree was in |
| **North star** | The issue's verbatim *Done when*: "the script exits non-zero without touching the tree when a plugin component directory has uncommitted changes" |
| **What makes it durable** | The decision is a function over a directory, and its cases run against throwaway repositories with a stub in place of `claude` — so the gate runs anywhere, needs no marketplace, and cannot install anything |
| **Out of scope** | Finding what actually reverted #158's file. The measurement below rules out this script, which makes that a separate question with no lead — recorded under *Findings* rather than guessed at here. Also out: making the reload itself stash and restore, because a reload that edits the tree to make itself runnable is a second way to lose work |

Pass 2 changed one thing. Pass 1, from the issue body alone, read the guard as protecting the
tree *from the script*. The reproduction showed the script does not write to the tree at all, so
the guard protects the *installed plugin* from the tree instead — same refusal, same exit code,
different reason, and the reason is what the refusal message says.

## Decisions & trade-offs

**The reproduction came first, and it came back negative.** A clone of this repository was
renamed to `arc-scratch@calyx-scratch`, registered as a second directory-source marketplace, and
dirtied in every shape #158 reported — tracked modifications inside `skills/`, `hooks/`,
`agents/` and `commands/`, a tracked deletion, untracked files at three depths, a staged change.
`uninstall --keep-data` + `install` left all 632 files byte-identical by `md5sum`, and so did a
second pass through the script and a `marketplace update`. The cycle writes
`~/.claude/plugins/cache/<marketplace>/<plugin>/<version>/`, `installed_plugins.json` and
`known_marketplaces.json`. It writes nothing in the source directory.

**No gate re-derives that**, and review pass 3 was right to say so: the scratch clone is deleted,
the selftest stubs `claude` precisely so it never installs anything, and what survives in the tree
is this paragraph and the dated block at the top of `tools/plugin-reload.sh`. It is a measurement
with its method recorded, not a test. The method, so the next reader can re-run it rather than
trust it:

```bash
git clone --no-hardlinks R:/arc "$SCRATCH/arc-scratch"          # then check out the branch
# rename .claude-plugin/{plugin,marketplace}.json to arc-scratch@calyx-scratch, commit
claude plugin marketplace add "$SCRATCH/arc-scratch"
claude plugin install arc-scratch@calyx-scratch -y
# dirty it: modify tracked files inside skills/ hooks/ agents/ commands/, delete one,
# add untracked files, stage a change
find . -path ./.git -prune -o -type f -print0 | xargs -0 md5sum | sort -k2 > before
claude plugin uninstall arc-scratch@calyx-scratch --keep-data && \
  claude plugin install arc-scratch@calyx-scratch -y
find . -path ./.git -prune -o -type f -print0 | xargs -0 md5sum | sort -k2 > after
diff before after            # empty, on the run this records
claude plugin uninstall arc-scratch@calyx-scratch --keep-data
claude plugin marketplace remove calyx-scratch
```

The last two lines are not optional. A scratch marketplace left registered points
`known_marketplaces.json` at a directory that is about to be deleted.

**The guard is still worth having, for the reason the reproduction found rather than the one the
issue assumed.** The install reads the *working tree*, not `HEAD`: the cache received the dirty
content, honoured the deletion and copied the untracked files. So a reload on a dirty tree makes
the installed plugin a copy of something that exists in no commit, and the session then behaves
according to edits nobody can name — which is the state #158 was in when it noticed a file was
gone. Refusing until the tree is clean makes the installed plugin equal to a commit.

**It checks the marketplace's `installLocation`, not `$PWD`.** `calyx-engineering` is a directory
source pointing at `R:\arc`, so a reload run from a worktree installs from the main tree.
Checking the current directory would have cleared a tree the reload never reads, and passed.

**It fails closed, which is the opposite of the hook rule.** A hook exits 0 when it cannot decide
because it fires on every tool call in every repository. This script runs when a person asks for
it, and being unable to read the tree means being unable to prove the reload is safe — so exit 3,
naming the check it could not run. `--force` answers every refusal, which is what keeps
[#132](https://github.com/Calyx-Engineering/arc/issues/132)'s dev loop usable: the script refuses
and explains, and never silently serves a stale snapshot.

The draft claimed that and did not do it. Two paths reloaded unchecked and exited 0: a
`known_marketplaces.json` that could not be read at all was treated as "this plugin ships no
local tree", printing a reassuring line in front of a completely unguarded reload; and a
`git status` that failed on a repository that exists — a corrupt index, an I/O error, a
permissions problem — came back as an empty result and read as clean. (Not a held
`.git/index.lock`: status takes that lock with the non-fatal flag and still exits 0. An earlier
draft of this paragraph and of the script's comment both asserted otherwise, on no test.) Both now return their own code, both route through one
`cannot_check()` so the messages cannot drift apart, and each has a case. **"This ships no local
tree" and "I could not find out" are opposite answers**, and collapsing them is exactly how a
guard becomes a reassuring message. Same distinction `tools/verify-linked-branch.sh` draws
between exit 1 and exit 2.

**An exclusion list, not an inclusion list — and the first draft got this wrong.** The draft
listed the six obvious component directories and justified leaving `tools/` out with the issue's
own *Survived* column. Review pass 1 disproved it: `hooks/tracker-verify` resolves
`../tools/verify-tracker-body.sh`, `../tools/verify-linked-branch.sh` and
`../tools/verify-issue-boxes.sh` against the plugin root, which is the cache — so an uncommitted
verifier is copied there and then executed by a live hook on every issue write. `reference/` was
missing too: `skills/record-route` and `skills/engineering-report` both link
`../../reference/knowledge-tiers.md`. The issue's column named one inert file, `verify-all.sh`,
and the draft generalised it to the whole directory.

So the list inverted. Everything the reload ships is checked except paths proven inert, each with
its reason written beside it in the script: `docs/`, `evals/`, `.claude/`, `.vscode/`,
`.gitignore`, `.gitattributes`, `.markdownlint.json`, `README.md`, `ROADMAP.md`, `CLAUDE.md`. An
inclusion list would leave a new top-level directory silently uncovered, which is
[#68](https://github.com/Calyx-Engineering/arc/issues/68)'s lesson in `verify-all.sh`: the check
whose job is catching a gap reports success instead.

**`.claude/` is the entry that makes the guard usable**, and review pass 2 is what found it. The
inverted list covered it, and `skills/record-route` appends to `.claude/arc/log.md` and
`.claude/arc/sessions.md` in most sessions — so the guard would have refused nearly every reload
in this repository over bookkeeping the installed plugin never reads, which is precisely the
rejected-approach row two paragraphs down. An exclusion list fails safe on coverage and fails
*noisy* on usability, and the noise only shows up when it is pointed at a real tree.

## Rejected approaches

| Rejected | Why |
|---|---|
| Stash and restore around the reload | The issue offered it as an alternative. A script that edits the working tree to make itself runnable is a second way to lose work, and the stash stack is shared across every worktree on this machine — `CLAUDE.md`'s own warning |
| Refuse on any dirty file at all | `docs/` and `evals/` churn constantly and reach nothing at runtime. Refusing on them makes the guard the thing people work around |
| List ignored files too, with `--ignored` | It would name every `__pycache__` on every run. The trade is stated where it is made: an ignored file inside `skills/` is shipped without being named, so "the installed plugin equals a commit" holds with that one exception |
| Check `$PWD` | Silently correct only when the reload is run from the marketplace's own directory |
| A new `tools/verify-plugin-reload.sh` | The decision and its cases belong in the file they are about. Same shape as `tools/arc-claim.sh selftest` |

## Findings

**Issues:** none filed, so #211's `Related` table gains no `Spawned` row. Everything below is a
finding, and a finding is not a unit of work — it lives here.
[#288](https://github.com/Calyx-Engineering/arc/pull/288) merged that rule into
`run-instructions.md` §5 while this unit was in review, and the first draft of #211's body had
the `Spawned` heading the rule forbids. Removed; the content is these four entries.

| Finding | Where it went |
|---|---|
| **What actually reverted `skills/chat-response/SKILL.md` in #158 is unidentified.** This unit ruled out the only named suspect by measurement. The untested candidates: a concurrent session or worktree in `R:\arc`, an editor restoring a buffer, a `git checkout` whose reflog entry was read as the branch switch. Not investigated — that is not this issue, and the evidence is three weeks cold | Owed an issue. The driver decides |
| **The issue's *Observed* table is wrong about `tools/`.** `verify-all.sh` is genuinely inert, but `hooks/tracker-verify` executes three of its siblings from the plugin root, and two skills link into `reference/` | Absorbed here — the guard covers both directories |
| **`plugin-reload.sh` treated every argument as a plugin name.** Observed, not inferred: a probe run of the old script as `plugin-reload.sh --source-only` printed `Reloading --source-only from the working tree...` and then `Done.`, so both `claude` calls returned 0 for a plugin that does not exist and `set -euo pipefail` never fired | Fixed here, case `e4` |
| **The first draft of the cases ran `rm -rf` against `%TEMP%`** | Fixed here; the retrospective below is the write-up, because the lesson is not about this file |

## Retrospective

The unit delivered the guard the issue asked for and disproved the premise it was filed on. The
four `Required` boxes are ticked with their evidence; box 1's evidence is a negative result,
which is the finding, not a gap.

Two defects turned up that the issue did not name, both fixed here rather than deferred. The
first was in the old script: every argument was treated as a plugin name, so
`tools/plugin-reload.sh --anything` ran the uninstall/install cycle against a plugin called
`--anything` and exited 0. Case `e4` is that. The second was mine, and it ran: the first draft
of the cases used `local TMP="$(mktemp -d)"` with `trap 'rm -rf "$TMP"' EXIT`. An EXIT trap fires
after the function that set it has returned, so the `local` was out of scope and `$TMP` expanded
to the Windows environment variable of that name — `%TEMP%` — and the trap ran `rm -rf` against
the user's entire temp directory. Most of it was locked by running processes; this session's own
scratchpad was not, and went. The scratch directory is now a uniquely-named global, cleaned by a
function that checks the value is non-empty, is a directory, and matches the pattern `mktemp` was
asked for. **The lesson generalises past this file: an EXIT trap and a `local` are in different
scopes, and on Windows the obvious short names are already environment variables.**

`bash tools/verify-all.sh` exits 0 at 48 gates, the new one among them.
