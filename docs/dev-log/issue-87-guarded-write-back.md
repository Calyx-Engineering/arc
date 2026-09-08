# Issue #87 — a failed edit writes the original body back

> Decision log, not a spec.

**Issue:** [#87](https://github.com/Calyx-Engineering/arc/issues/87)  ·  **PR:** written in when it opens  ·  **Batch:** #87 #135 #193, one PR

## Problem

`skills/issue-write`'s body-edit recipe was three independent commands. The middle one — the
step that actually edits the file — could die and the third would still run, writing the file
the *first* command produced. `gh` prints the issue URL and reports success; the body is
unchanged.

The skill documented only one route to that outcome, a redirect to a path a later step cannot
see. That wording points at path visibility, so a reader who wrote the temp file somewhere
plainly visible concludes the trap does not apply. It still does: the failure is that the edit
never ran.

## What changed

`skills/issue-write` §*A body edit replaces the whole body*:

| | |
|---|---|
| **The snippet is guarded** | `python edit.py body.md && ! cmp -s body.before body.md && gh issue edit …`. Two independent guards — the edit's exit status, and a comparison against a copy taken before the edit. Either alone stops the bad write |
| **The trap is named as the edit step failing** | Path visibility demoted to one of two causes, not the framing |
| **Windows paths called out as the repeat offender** | `"C:\Users\..."`, `"R:\arc-transcripts\"` — `\U` and `\a` are escapes and a trailing `\` eats the closing quote. It is a **parse**-time failure, so the edit never starts |
| **The read-back kept mandatory** | It is the detector, not the fix. It caught all three observed cases and nothing else would have |

## Reproduced while fixing it

The first attempt to splice this section wrote the replacement to Git Bash's `/tmp` and read it
from Windows Python:

```text
FileNotFoundError: [Errno 2] No such file or directory: '\tmp\new87.md'
```

That is the path-visibility half of #87, hit live, in the commit that fixes it. The edit step
died before touching `SKILL.md` — and because the splice is one script rather than a chain, the
file was left untouched rather than rewritten with its original content. The rewrite ran from
the session scratchpad instead.

The `/tmp` line in the skill's table is written from this, not from memory.

## Decisions

| | |
|---|---|
| **Both guards in the snippet, not one** | The issue permits either. `&&` alone misses an edit step that exits 0 having done nothing; `cmp` alone misses nothing but is easy to omit under time pressure. Shown together, the reader copies both |
| **The read is guarded too** | Neither of the two named guards covers a failed *read*: the redirect truncates `body.md` before `gh` fails, `body.before` is an empty copy of it, the edit writes the new section into the empty file, and `cmp` sees a difference. `[ -s body.md ]`. Pass 2 found this in the canonical snippet after pass 1 had already fixed it in the #193 one — the same file teaching two standards for one operation |
| **`cmp -s`, not a hash** | Present everywhere `gh` is, no second interpreter, and a no-op edit correctly skips the write |
| **No new gate** | The requirement is the documented procedure. A hook cannot see a run's shell chaining, and `tools/verify-tracker-body.sh` reads bodies, not command sequences |

## What the review passes found

Pass 1 found the fix contradicted twice in its own file, by the other two issues in the batch:

| | |
|---|---|
| **The #193 recovery snippet repeated the trap** | Its `gh pr view … > body.md` was unchained, so a failed read produced an empty file, an empty `body.before`, a difference the guard let through, and a PR body replaced by the keyword line alone. Two hundred lines below the section teaching the opposite. Now one `&&` chain with a `[ -s body.md ]` on it |
| **Then the canonical snippet turned out to have it too** | Pass 2's finding. Fixing the copy and leaving the original is worse than fixing neither, because the file then documents two standards and the weaker one is the normative example |
| **`live-bind` did the same against a merged PR** | The tool #193 added. Recorded in that issue's dev-log |

Neither was in a diff either author would have read as suspicious. Both were in the section the
diff does not show, which is why pass 1 reads whole files.

## Not done

Nothing in `Required` was left open.
