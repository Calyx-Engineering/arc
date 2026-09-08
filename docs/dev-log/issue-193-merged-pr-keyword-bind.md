# Issue #193 — a merged PR still binds a closing keyword added afterwards

> Decision log, not a spec.

**Issue:** [#193](https://github.com/Calyx-Engineering/arc/issues/193)  ·  **PR:** [#235](https://github.com/Calyx-Engineering/arc/pull/235)  ·  **Batch:** #87 #135 #193, one PR

## Problem

`skills/issue-write`'s nearest statement read as the opposite of the truth:

> *"Re-saving the body forces a re-parse of a stale link. It cannot create a link the base
> branch forbids."*

The first sentence is about a link that already exists; read together the pair says a re-save
cannot create a link. On a base that is the default branch, it can — after the merge as well as
before.

## The re-test, which the issue demanded

The issue's own constraint: *"Verified once, on one PR. Re-test before it is written as a rule.
Two of three past tracker diagnoses in this repository were wrong."*

Probe issue [#225](https://github.com/Calyx-Engineering/arc/issues/225) against merged
PR [#215](https://github.com/Calyx-Engineering/arc/pull/215), base `arc/04-dogfood`, which is
this repository's default branch under m42.

| | Result |
|---|---|
| Keyword added after the merge binds | **Yes** — `closingIssuesReferences` returned `[225]` |
| It is a keyword link, not hand-attached | **Yes** — `userLinkedOnly:true` returned `[]` |
| The issue closes | **No** — #225 stayed open with the reference bound |
| The read-back answers immediately | **No** — the read straight after the edit returned `[]`, the next returned `[225]` |
| Removing the keyword unbinds | **Yes** — PR #215's body was restored and the reference cleared |

**Two of #193's premises did not survive.**

1. *"it is two commands"* — three. The link comes back; **the closure does not.** The merge
   event that closes an issue has already fired, so `gh issue close` is a separate step. Without
   it the recovery leaves an open issue with a bound reference, which reads as done and is not.
2. **A single read-back is a false negative.** The first read reported the recovery had failed.
   That is [#155](https://github.com/Calyx-Engineering/arc/issues/155)'s failure exactly — one
   read at one moment — reproduced against a different field.

Both went into the skill and the case file. Neither was in the issue.

## What changed

| | |
|---|---|
| **`skills/issue-write`** | The re-saving sentence corrected in place, saying what still holds and what it implied wrongly. New section *A missed keyword is recoverable after the merge* — the condition, the four measured properties, the steps with the poll and `gh issue close`, and what is not recoverable |
| **`tools/tracker-cases/binding/merged-pr-keyword-bind.md`** | The case, with both runs recorded |
| **`tools/verify-tracker-body.sh live-bind`** | The case as an executable test |

## Decisions

### The case had to be executable, and could not be a text fixture

*"So the claim is a test rather than a memory."* Every existing case under
`tools/tracker-cases/` is a file the checker reads. This claim is about what GitHub does, so
the only honest test writes to the API and reads it back.

| | |
|---|---|
| **It restores what it changed** | Appends the keyword, asserts, restores the body, asserts the reference cleared |
| **It refuses rather than clobber** | The PR must be merged, its base must be the default branch, and its body must carry **no** closing keyword already — restoring someone else's real binding is not a risk this check gets to take |
| **It polls** | Ten reads at three-second intervals. This is the measured behaviour, not defensive padding |
| **It is not in `verify-all.sh`** | It needs the network and it writes to the tracker. `selftest` prints one line naming it as not run, because a silent omission reads as coverage |

### The write-back inside it is guarded

`live-bind` uses #87's guarded form — `! cmp -s orig tmp && gh pr edit …`. The same batch fixed
that trap; a new tool reintroducing it would be the batch arguing with itself.

## What the review passes found in this work

Pass 1 read the finished tree against the three issues and found that `live-bind` — the tool
added to stop a silent tracker failure — carried three of its own:

| | |
|---|---|
| **An unchecked read feeding a destructive write** | `gh pr view --json body > "$orig"` with its exit status discarded. A failed read leaves `$orig` empty, the keyword guard passes on an empty file, and the restore then writes that empty file over a real merged PR's body. #87's exact shape, in the batch that fixed #87 |
| **A failed query reading as a pass** | The `userLinkedOnly` probe is the one assertion separating a keyword link from a hand-attached one, and a `gh` error returns the same empty string a clean result does |
| **No trap between the write and the restore** | An interrupt in that window leaves a probe keyword on a merged PR. Both the case file and the skill promised it "restores what it changed" |

Also: the restore was asserted by polling the *reference* until it went absent, which breaks out
on the first read that has not caught up — the same one-read false negative this check exists to
document, used as the check's own evidence.

All four fixed. The restore now checks `gh pr edit`'s exit status, reads the body back, and
asserts on that.

### Running it then found a fourth thing, in GitHub rather than in the code

The finished runner against PR #215 restored the body correctly — no keyword, nothing bound —
and its byte-for-byte assertion still failed. **GitHub normalises a body it is handed**, line
endings and trailing blank lines, so a restore written from an exact copy of what was read does
not read back identical. The comparison now normalises both sides, and `live_norm` is where that
lives.

### Then pass 3 asked whether the case was a test or a memory

It was still a memory. The runner existed and was sound, but the version carrying `live_norm`
had never completed a run — the recorded one predated it and had ended with two failed
assertions. An armed assertion that has never fired is a claim, not a test.

Discharged: probe [#233](https://github.com/Calyx-Engineering/arc/issues/233) against merged
PR [#200](https://github.com/Calyx-Engineering/arc/pull/200).

```text
$ bash tools/verify-tracker-body.sh live-bind 200 233
PASS  a keyword added after the merge bound #233 on merged PR 200
PASS  userLinkedOnly is [] — the link came from the keyword, not the UI
PASS  issue #233 is still OPEN — the bind restores the link, never the closure
PASS  PR 200's body reads back as it was, and the probe keyword is gone
PASS  #233 unbound
EXIT=0
```

PR #200 was restored — no keyword, nothing bound. The case file's fourth run row is that output,
and its preconditions now say the target issue must be **open**, which the earlier run's
arguments no longer satisfy.

## Not done

Nothing in `Required` was left open.

## Spawned

| | Link | What it is |
| :--- | :--- | :--- |
| **Spawned** | [#225](https://github.com/Calyx-Engineering/arc/issues/225) | the probe issue, closed with the measurements as its record |
