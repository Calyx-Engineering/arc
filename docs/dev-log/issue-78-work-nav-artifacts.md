# Issue #78 — the artifacts that carry work navigation

> Dev-log, not a spec. Started at plan time, finalised as a retrospective at PR time.

**Issue:** [#78](https://github.com/Calyx-Engineering/arc/issues/78)  ·  **PR:** [#121](https://github.com/Calyx-Engineering/arc/pull/121)

## Problem

[m46](../product-architecture/mechanisms/m46-work-navigation.md) is specified and nothing
carries it. Its §11 table names six artifacts; four hold none of what it assigns them, one holds
half, and the sixth — `CLAUDE.md` — holds the branch form without the number that makes it
useful.

A specification with no carrier is the failure mode this arc has already recorded twice:
[m46 §9](../product-architecture/mechanisms/m46-work-navigation.md#9-branch-naming)'s branch rule
existed for a day before three no-issue branches shipped without numbers, and auto mode was
declared in prose five times before [#73](https://github.com/Calyx-Engineering/arc/issues/73)
gave it state. **A rule that lives only in a mechanism spec is read when someone reads that
spec, which is not when the rule fires.**

## Intent and north star

### Pass 1 — from the issue body alone

[#78](https://github.com/Calyx-Engineering/arc/issues/78) carries no verbatim quote. Its
authority is m46, and its checklist is ten boxes across six files.

| | |
|---|---|
| **What this is really for** | Not writing ten paragraphs. The nine capability boxes are each a rule that must fire **at the moment the work reaches it** — while a title is being written, while a discovery is being recorded, while a branch is being named — and none of those moments involve opening m46 |
| **North star (pass 1)** | Each of m46's rules lives in the artifact whose reader is already at the moment the rule governs, so the rule is reached without anyone deciding to look it up |

### Pass 2 — after reading m46 whole, all four skills, m21, `CLAUDE.md` and the arc-log

**Four things changed. The second is the one that changes the design.**

| | |
|---|---|
| **The issue's own verification is stale** | Its body says *"Verified by grep against each target on `arc/03-camp-issue-76-work-nav`."* [PR #114](https://github.com/Calyx-Engineering/arc/pull/114), [PR #115](https://github.com/Calyx-Engineering/arc/pull/115) and [PR #116](https://github.com/Calyx-Engineering/arc/pull/116) have all edited these skills since. Every box was re-grepped against this branch before planning — the arc-log's §12.3 names *issues are not re-read against the tree before being picked up* as what wave 5 did not fix, and this is that case again |
| **`issue-write` already carries a retitling rule, and it says the opposite** | Line 100: *"Retitle before children exist, not after — once a title is referenced from comments, documents and other issues, changing it costs more than the wrong title does."* m46 §3 and §9 require the opposite: a unit that grows is retitled as it grows. **Both are right about different units**, and neither names its unit |
| **`chat-response` already has m46 §7.1** | *A decision leads the message*, with the form, the bold-and-set-apart rule, and the sentence *"This applies to any decision that moves the work — which branch, fold in or split off."* §7.2 is a named instance of a rule already present, not a new rule. That changes what the edit is: name the instance and its firing condition, do not restate the general rule |
| **`record-route` keys on the issue in five separate places** | Not one. The routing table, the dev-log template line, the *Plan time* row, the *PR time* row and the templates list all say `issue-<N>` or *one per issue*. Fixing the routing table alone leaves four places contradicting it — which is precisely [#62](https://github.com/Calyx-Engineering/arc/issues/62)'s defect |

**The retitling conflict is the finding.** It is the same shape as
[#34](https://github.com/Calyx-Engineering/arc/issues/34)'s — `chat-response`'s *one decision per
question* against `spec-interview`'s *two or three questions per set*, both right, neither naming
its unit. The resolution is the same: name the units.

| Rule | Unit | When |
|---|---|---|
| **Size it at filing, then leave it** | An **issue** title | Before children exist. Retitling costs more than the wrong title once comments and documents reference it |
| **Retitle as the unit grows** | A **PR** title, and its description | Whenever a descent changes what the unit is. m46 §3's anti-pattern is not size — it is a unit that grew without its title growing with it |

**These do not conflict once the units are named.** An issue is a stable identifier other things
point at; a PR is a description of a diff that is still being written. Writing one rule without
its unit is what made them look contradictory.

**North star.** A session that has never read m46 still follows it, because each rule sits where
that session already is:

> - Writing a `Spawned` row, it finds the abandoned marker in `issue-write`
> - A PR's scope descends, and `issue-write` says retitle — with the issue rule right beside it, so neither is applied to the wrong unit
> - Decomposing, it finds `decompose` naming the `Spawned` section as an input of equal standing to a spec
> - Standing at a fork, it finds `chat-response`'s ascend/descend prompt and the condition that fires it
> - Naming a branch, it finds both forms in `CLAUDE.md` — the file read every turn, not the spec read when an issue traces to it
> - Merging anything, it finds `record-route` requiring a dev-log whether or not an issue exists

| | |
|---|---|
| **What makes it durable** | It survives a session that never opens m46, which is every session where these rules actually fire. It survives the retitling rule being read in isolation, because the unit is named in the same row. It survives `sync-local-skills.sh --check`, because both trees are written |
| **Out of scope** | Re-deriving m46. The spec is the authority and its §11 table is the checklist. **Not sweeping specs outside this issue's reach** — §6.1.3, and [#105](https://github.com/Calyx-Engineering/arc/issues/105) owns the rest |

### Intent check

**Agreed.** [#78](https://github.com/Calyx-Engineering/arc/issues/78) is step 23 / wave 6.3 of
§10's execution order, in the milestone, and is the last build row of the arc. It builds a spec
this arc produced. No ladder question arises.

**One item is *derived*, and it is named rather than assumed:** m46 §11's table omits
`tools/new-direct-pr.sh` and `hooks/camp-branch-check`, both of which already carry §9 and §9.1.
Adding those two rows is not in the issue's checklist. It is §6.1.3's rule — *a spec you touch
names the artifacts that implement it* — applied to the spec this issue is built from, and the
table is the checklist this issue works against, so an incomplete one misleads the next reader of
it. Two rows, no new prose.

## The plan

Nine capability boxes across six files, plus the arc-log's three owed items, which the handoff
assigns to this PR rather than a separate one.

| # | File | Carries |
|---|---|---|
| 1 | `skills/issue-write` | The abandoned marker, at the front of the row |
| 2 | `skills/issue-write` | Retitling as the unit grows — **with the issue/PR units named**, beside the existing filing-time rule |
| 3 | `skills/decompose` | The `Spawned` section as an input alongside a spec |
| 4 | `skills/decompose` | Recording which of the two it read, so the set carries its origin |
| 5 | `skills/chat-response` | The ascend/descend prompt, as a named instance of the rule already there |
| 6 | `CLAUDE.md` | Both branch forms, with the number |
| 7 | m21 | The three relations rendered |
| 8 | `skills/record-route` | A dev-log per merged unit — **all five places that key on the issue** |
| 9 | `skills/record-route` | The `pr-<NN>-<slug>.md` form |
| 10 | m46 §11 | The two artifacts the table omits — *derived*, above |
| 11 | Arc-log | m40's soak row, `verify-all.sh`'s soak line, §10 rows for [#119](https://github.com/Calyx-Engineering/arc/issues/119) and [#120](https://github.com/Calyx-Engineering/arc/issues/120), §14 naming the release |

Then `tools/sync-local-skills.sh`, `bash tools/verify-all.sh`, and a grep of every box against
the file — the tenth acceptance item, and the one that makes the other nine checkable.

## Retrospective

**Ten acceptance boxes, seven files touched, and four more that contradicted the result.** The
plan's eleven items all landed. What the plan did not have is the fourth line of the table
below — the sweep for contradictions, which found more than the checklist did.

| | |
|---|---|
| **The retitling conflict was the whole of pass 2's value** | A single-pass read would have added *retitle as the unit grows* twelve lines below *retitle before children exist, not after* and shipped a skill arguing with itself. The resolution is [#34](https://github.com/Calyx-Engineering/arc/issues/34)'s, reused: **name the unit each rule governs** |
| **`record-route` keyed on the issue in five places, not one** | The routing table is the one the checklist points at. The other four — the scratch trap, *Plan time*, the templates list, and the template file itself — would each have kept saying *per issue* under a routing table that no longer did |
| **The contradictions did not stop at the six artifacts** | m17's K1 table, `close-sequence` step 2, the registry's m17 one-liner and `work-watch`'s *"File it now"*. **None is in the issue.** They were found by grepping the *rule*, not the *file list* — and a rule contradicted somewhere else is [#62](https://github.com/Calyx-Engineering/arc/issues/62) exactly |
| **The issue's own verification was stale and said so** | *"Verified by grep against `arc/03-camp-issue-76-work-nav`."* Three PRs edited these skills after that branch. Re-running it cost one command; trusting it would have cost a wrong plan. §12.3 names this as what wave 5 did not fix, and it is still not fixed — nothing prompts the re-read, the loop's pass 2 just happens to catch it |

**What review found that four refining passes did not.** Three placement defects, all created
by the edits themselves: two paragraphs swept under a new heading they did not belong to, a
step-6 note separated from its step-2 sibling, and a diagram labelling the one edge the table
above it calls unlabelled. **All three are the cost of inserting into a document rather than
appending to one**, and none is visible without reading the rendered result rather than the edit.

**What is not established.** Nothing here executes a skill. Every rule in this PR is verified as
text — the box exists, in both trees, with the wording the spec asks for — and never as
behaviour. m46's status line now says this outright rather than leaving *specified* to imply
more than it means.

### Spawned

- **Nothing new filed.** The four contradicting artifacts were fixed here rather than rowed out: each is one line, and a rule that ships contradicted teaches the contradiction
- **Named and not filed:** `skills/camp` is m21's settled carrier and does not render the tree. That is m21's own open question, and its `Related` now says so beside the link rather than leaving a reader to look for it
