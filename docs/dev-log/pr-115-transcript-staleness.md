# PR #115 — the staleness check compares transcripts by mtime

> Decision log, not a spec. No issue behind it — the fix was smaller than the issue would have
> been. Found by `/arc-next` firing it during [#48](https://github.com/Calyx-Engineering/arc/issues/48)'s cold start.

**Issue:** none  ·  **PR:** [#115](https://github.com/Calyx-Engineering/arc/pull/115)

## Problem

`commands/arc-next.md` runs seven staleness checks before a handoff may be acted on. One read:

> **Transcripts newer than the handoff** — stale when a file in the transcript directory the
> handoff's *Transcripts* table does not list. A session ran and its decisions are not in here.

`R:\arc-transcripts\` held twelve files; the handoff's table listed four. **The check trips,
and its prescribed response is not soft** — *"stop and report the specific contradiction … do
not proceed on a guess."* An autonomous run halts before its first action, over a table being
a short list.

The paragraph meant to prevent a false positive is what caused this one: *"Compare against the
handoff's own list, not against the date."*

## Intent and north star

**What this is really for.** Not the wording of one row. The check compares a **curated**
artifact against a **complete** directory, and those two grow by different rules — so the
false positive is structural and returns however the row is reworded.

**North star.** The check asks one question with one mechanical answer — *did a session run
after this handoff was written* — and the artifacts that own the two halves say so, so they
cannot drift back into disagreement.

| | |
|---|---|
| **What makes it durable** | It survives the arc accumulating sessions, which is what broke it. It survives someone curating the table harder, which is the correct thing to do to it |
| **Out of scope** | Moving the staleness checks out of the command and into `skills/handoff`. The command carries thirty lines the skill does not, which is one fact in two places waiting to happen — but it is [#105](https://github.com/Calyx-Engineering/arc/issues/105)'s, and nothing is duplicated today |

## Decisions & trade-offs

| | |
|---|---|
| **`find <dir> -newer HANDOFF.md`** | One command, no parsing, no sort, and it answers in both directions. The table promises *"they cost one command each"* and this is the only row that was not one |
| **The save order makes it self-consistent** | `skills/handoff` fixes the order at a break — save the transcript, **then** write the handoff. So the newest file is always older than `HANDOFF.md` by construction, and the just-saved transcript can never trip the check. That was the real content of the paragraph being deleted; it was reached by the wrong route |
| **Both halves say it, not just the check** | The check now says the table must not be the comparand; `skills/handoff` and `templates/handoff.md` say the table is curated and why. A rule stated only where it is enforced gets edited out by whoever maintains the other end |
| **The limit is written down** | A session that ran and saved no transcript is invisible to this check, and no rewording changes that. The other six checks catch it — a commit, a branch, or a PR the handoff does not account for. Naming it stops the next reader from re-deriving that the check is incomplete |
| **The banner left two blank lines, in every copy** | The string carried a trailing newline and `print` adds another — invisible in the source, present in all twelve copies since the sync was written. Fixed, with a fixture case that reads the blank count out of a written copy rather than predicting it. Whitespace-only, one line per file |
| **m15 carries the behaviour now, not just the links** | The spec was **silent on the staleness checks entirely** — its entry-point section named "two stated failure modes" while the command carried seven checks. That silence is why a check comparing a curated list to a complete directory was written with nothing to review it against. It now says what a check must be: one command, one mechanical answer, two comparands maintained the same way, and its blind spot named |
| **Three sections added to m15's table** | It listed six; the skill and template carry nine. *Do these in order* shipped in [#61](https://github.com/Calyx-Engineering/arc/issues/61) three waves ago, *What was ruled out* and *Transcripts* later — none reached the spec. **The spec had drifted three waves behind its own skill** |
| **m15's `Related` fixed while here** | It named none of its artifacts. [PR #107](https://github.com/Calyx-Engineering/arc/pull/107) wrote that rule into `spec-interview` and the arc-log and **repaired no actual spec** — the four instances the wave 5 review found are all still open. Only the two this PR edits are fixed; the rest are [#105](https://github.com/Calyx-Engineering/arc/issues/105)'s |

## Rejected approaches

| | |
|---|---|
| **Listing every transcript in the handoff's table** | Makes the comparison valid by making the handoff a directory listing. `skills/handoff` warns about exactly this two sections above — a handoff that grows until reading it is itself expensive is the spine window's failure relocated to a file |
| **Comparing filename dates** | What the old paragraph prescribed. Filenames are `YYYY-MM-DD` only, so every same-day session is indistinguishable — and this arc ran four sessions in one day |
| **Filing an issue first** | The defect and the fix are the same size. m46 §9 is explicit that a fix found while doing something else goes branch-to-PR |

## Spawned

Nothing new. Two existing entries were closed out:

- **Friction log entry 3** — this PR is its *Where it went*
- **Friction log entry 4** — resolved the same day, and it turned out to be entry 1's answer
  rather than a new cause. The arc-log's §12.1 and its *Soak* row both credited
  `.claude/settings.json` with five unattended merges; those five were in a session where the
  user had asked, and [PR #114](https://github.com/Calyx-Engineering/arc/pull/114) was denied
  twice with that file unchanged. Both corrected here

## Retrospective

**The check was written from the thing it was checking.** Whoever wrote the row had a handoff
in front of them whose table happened to be complete, so "the table" and "the directory" were
the same set and the difference was invisible. It stayed invisible until the arc ran enough
sessions to separate them — the fourth cold start, not the first.

**The tell was in the row's own promise.** Six checks are a command; this one was a
comparison to be performed by judgement, and it was the only one that misfired. *One command
each* was already the standard the table set for itself.
