# Issue #152 — a file the user authored is overwritten with no copy kept

**Issue:** [#152](https://github.com/Calyx-Engineering/arc/issues/152)  ·  **PR:** [#237](https://github.com/Calyx-Engineering/arc/pull/237)

## Problem

`HANDOFF.md` is gitignored, so rewriting it destroys the state the session was given and leaves
no copy anywhere. Same shape as replacing a diagram the user spent hours on instead of archiving
it.

## Intent and north star

| | |
|---|---|
| **What this issue is really for** | Making destruction of user-authored work recoverable, without turning recovery into record |
| **North star** | A handoff rewrite leaves the prior version on disk, asserted by a case |
| **What makes it durable** | The archive rule is derived, not listed. *Whatever git cannot restore* needs no maintenance as new file types appear; a hardcoded list of filenames would go stale the first time someone adds an untracked artifact |
| **Out of scope** | **A `SessionStart` hook** — CLAUDE.md bars one from being written autonomously, and this is an autonomous run, so the stronger form is a proposal rather than a diff. **Pruning or rotating the archive** — deferred, because a store that deletes things is a new way to lose work and #152 asks for the opposite. **Restoring automatically** — not this unit's job; recovery is a deliberate act by the user, and a hook that puts files back would fight the session that moved them |

## Decisions & trade-offs

**The archive rule is "whatever git cannot restore".** This is what generalises *the handoff* to
#152's *any user-authored file* without a list. A tracked file already has a copy — that is what
git is, and archiving it would bury the real recoveries in noise. An untracked or ignored file
has nothing behind it, so overwriting it is destruction. `git ls-files --error-unmatch` is the
whole test.

**Two moments, because they are two different questions.** The handoff is snapshotted at the
session's first edit *of anything*, keyed to the session id — that is #152's *cold start, not
write time*, and a session that crashes has already been covered. Every other file is archived as
it is about to be replaced, because nothing can know in advance which file that will be. Once per
session per file: the first copy holds what the *user* wrote, later ones would only hold this
session's own edits.

**Registered on the `Bash` matcher as well as on the edit tools.** `cat > HANDOFF.md`, `mv`,
`sed -i` and `rm` destroy a file without ever reaching `Edit` or `Write`; on the edit matchers
alone the hook missed every one of them, which would have left the central requirement true only
for the tools that happen to be typed. Bash gets moment 1, the snapshot, and not moment 2 — a
shell command is not parsed for the files it will overwrite, because those forms compose and a
wrong guess copies the wrong thing while reporting success. It is also **silent** on Bash: `permissionDecision: "allow"` approves a call rather than
annotating it, so speaking there would auto-approve the session's first shell command as a side
effect of taking a snapshot — and that command can be anything. The copy still happens; the
message does not. Cost on every Bash call after the first in a session: reading stdin, three
`field` calls, one `git rev-parse --git-dir` and one file test — tens of small processes, which
is the floor for a hook on this matcher.

**`.arc-work/archive/`, not inside `.git/`.** Under `.git/` would be more strongly excluded, but
a recovery copy nobody can find is not a recovery copy. `.arc-work/` is already gitignored, so
the requirement is met and the user can `cp` a file back by hand.

**The side effect needed its own gate.** `tools/verify-hook.sh` scores a hook's *verdict* —
allow, deny, report — which is the right question for a guard and the wrong one for a hook whose
entire job is a side effect. A hook could report "archived" and copy nothing and every case there
would pass. `tools/verify-handoff-archive.sh` runs the hook against real repositories and reads
the archive back.

## Rejected approaches

**Cases for ordering inside `tools/hook-cases/`.** *The second edit does not retake the snapshot*
needs a first edit to have happened, and `verify-hook.sh` runs a case directory as an unordered
set — the first attempt at this passed or failed depending on which directory `pass/` or
`report/` was walked first. Sequencing moved to the new verifier, where each firing is explicit.
The hook-cases directory keeps only order-independent cases.

**Archiving on a filename allow-list (`HANDOFF.md`, `*.excalidraw`, …).** Rejected: it answers
"which files matter" with a guess that ages badly, where git already answers "which files are
unrecoverable" exactly.

## Spawned

- **Still uncovered, named rather than implied away** — a Bash command that overwrites an
  *untracked file which is not the handoff*. The snapshot covers the handoff on any tool; the
  per-file archive needs a named target, and shell redirection does not give one.
- **Convention drift** — this hook carries an issue number where the others carry a mechanism id
  (`branch-guard` → m10). It has no mechanism row and no artifact-table entry. `mode-guard` is in
  the same position, so this is drift rather than a regression, and no gate enforces it.
- **Proposal, not filed** — a `SessionStart` variant of this hook. It would also cover a session
  that reads, crashes and never edits. That session destroyed nothing, so the gap is harmless,
  but the stronger form belongs to the user: CLAUDE.md excludes `SessionStart` hooks from
  autonomous editing and this run is autonomous.

## Retrospective

Built: `hooks/handoff-archive` (PreToolUse on `Edit|Write|NotebookEdit` **and on `Bash`**,
registered in `hooks/hooks.json`), nine cases under `tools/hook-cases/handoff-archive/`, and
`tools/verify-handoff-archive.sh` — 6 live probes and 16 fixture cases, wired into
`verify-all.sh` as two gates.

**What changed from the plan:** two hook-cases had to be withdrawn and rewritten as sequenced
cases in the new verifier, and a path bug surfaced only because the cases assert the filesystem.
Under Git for Windows the shell's `/tmp/x` comes back from `git rev-parse --show-toplevel` as
`C:/Users/.../Temp/x`, so the prefix strip that derives a repo-relative path never matched and
the per-file archive silently never fired. The handoff snapshot kept working throughout, because
it builds its path from the root rather than reducing one against it — so a verdict-only gate
would have shown nothing wrong. Both paths are now canonicalised through the same `cd && pwd`.

**Three defects came out of registering on Bash, and all three were found by review rather than
by a gate.** The hook auto-approved the first shell command of every session, because the report
shape it inherited from the edit tools grants permission rather than annotating. The fast path
could not fire in the common case, because its marker was written inside `archive_file` past that
function's own early returns — so it existed only where there had been an untracked handoff, and
every repo without one ran the full body on every Bash call. And `field` is an unanchored grep
over the payload, which now carries the command text, so a command mentioning `file_path`
returned itself as a target. The first is the one that mattered.

**What a future reader needs to know:** the gate runs the hook as a program. It does not prove a
live session invokes it — no gate here does, `verify-all.sh --list` says so — and registration in
`hooks.json` is checked as text, which is presence rather than firing.
