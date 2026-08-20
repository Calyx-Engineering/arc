# Cold review — m46, issue #76

Branch `arc/03-camp-issue-76-work-nav`, unpushed. Transcript ingested first (2293 lines), then
the five files.

**Verdict: the spec matches what was decided.** Every one of the ten settled decisions, plus
the five added during review, is present and worded as agreed. Nothing is in the document that
no discussion produced. The defects below are propagation failures — things decided late and
not carried to every surface — not disagreements with the record.

Nine findings raised. **Six were real and are fixed; three were withdrawn.**

| | | Outcome |
|---|---|---|
| **B1** | §6 contradicted §5.1's fix-now path | ✅ `eea24cb` |
| **B2** | Retired `spawned table` wording, four files | ✅ `7021add` |
| **S1** | §11's work was untracked | ✅ [#78](https://github.com/Calyx-Engineering/arc/issues/78) filed — **status-column half withdrawn** |
| **S2** | Mechanism count said 31 against a table of 34 | ✅ `eea24cb` |
| **S3** | No dev-log for issue #76 | ✅ `eea24cb`, and m46 §6.1 now makes it a rule |
| **S4** | Nothing back-referenced m46 | ✅ `8e46d7d` — also scheduled wave 6 |
| **S5** | *Relevance is not always the test* | ❌ **Withdrawn** — deliberate authorial wording |
| **N1** | §9's examples | ❌ **Withdrawn** — they are negative examples, and that is the point |
| **N2 · N3** | Notes | No action |

**Two findings were wrong in the same way.** S5 and N1 both judged a deliberate choice against
the transcript and called it a defect. A cold review checks whether the document matches what
was decided; it does not overrule the author on a judgement they own.

---

## B1 · §6 contradicts §5.1 — the last decision of the session did not propagate

> ✅ **Fixed** — uncommitted. §6's opening now reads:
>
> *"Recording it is not acting on it: the row is written first, and whether it is fixed now or
> at spawn time is the user's call ([§5.1](#51-not-everything-spotted-is-spawned-work))."*
>
> The user's reading was kept — *recording is not acting* survives as the first clause, which
> is what the original sentence was reaching for. What was added is the second half: the
> diagram's `Fix it now?` node, named as the user's decision, plus the anchor. **The diagram
> was treated as the authority.** §6's prose, §5's `BLEED` node and §5.1's *"usually left
> alone… sometimes it should not be"* now agree.

`m46-work-navigation.md:249`

> *"Nothing is acted on when it is spotted."*

§5.1 — written after §6, and the final substantive change of the session — establishes the
**fix-now** path: a recorded row that the user decides to fix immediately, on the current
branch, with the row left standing. §5's diagram carries it as the `BLEED` node.

§6's sentence is an absolute that forbids the path §5.1 creates. A reader following §6 alone
never fixes anything at spot time.

**Fix:** qualify it — *"Nothing is acted on when it is spotted, unless the user calls for an
immediate fix (§5.1)."* One clause; the rest of §6 is sound.

**Why this is the highest-value finding:** the fire-extinguisher gate was the hardest-won
decision in the transcript (the user spent ~20 minutes on the analogy, and the session's own
first attempt at the gate was rejected as overspecified). It is the decision most likely to be
lost, and §6 currently loses it.

---

## B2 · The retired wording `spawned table` survives in four files — including one this branch wrote

> ✅ **Fixed** — committed `7021add`, six files, 12 lines. Verified zero hits on the old term;
> both `.claude/` copies content-identical to source. m46 untouched by that commit.
> `issue-write`'s *defining* sentence was reworded too — it named the thing as *"a table at
> the end of the parent issue"* rather than by its section name.

The session deliberately retired *"spawned table"* in favour of the **`Spawned` section**,
because "table" understated it and the earlier "unfiled" framing was wrong. m46 was swept
clean — **0 hits, 6 uses of the new term.** The sweep stopped at m46.

| File | Line | Note |
|---|---|---|
| `skills/chat-response/SKILL.md` | 142 | **Added by this branch.** The worked example says *"Row it into the spawned table"* |
| `.claude/skills/chat-response/SKILL.md` | 142 | Same, in the local copy |
| `docs/product-architecture/README.md` | 89 | **Added by this branch.** m46's own row says *"the parent's spawned table"* |
| `skills/issue-write/SKILL.md` | 290 | Pre-existing; m46 §11 assigns this artifact the `Spawned` section |
| `docs/product-architecture/mechanisms/m21-arc-tree.md` | 111 | Pre-existing; m46 §12 cites it |

The first two matter most: the branch introduced the term it had just retired, and the README
row is the one-line summary most readers see before opening the spec.

**Fix:** replace with `Spawned` section in all four. Mechanical.

---

## S1 · §11's work is untracked — four of five artifacts unbuilt, no issue for building them

> ✅ **Resolved as [#78](https://github.com/Calyx-Engineering/arc/issues/78)**, scheduled wave 6.3.
>
> **The status-column half of this finding was withdrawn.** A spec says what the thing *is*;
> per-artifact status in every m-spec creates status-in-status with no single owner, and the
> product README's ⚪/🔵 column already owns it. Checked afterwards: **no sibling spec carries a
> status column in an artifact table** — m46 §11 was already house style.
>
> What survived is that nobody was going to build it. Issue
> [#76](https://github.com/Calyx-Engineering/arc/issues/76) is `spec:` and delivers the
> document; when it merges m46 is specified and nothing says who implements it.
> `record-route` was added later as a sixth artifact, so [#78](https://github.com/Calyx-Engineering/arc/issues/78) carries six.

`m46-work-navigation.md:378-387`. Verified by grep against each target:

| Artifact | m46 says it carries | Actually present |
|---|---|---|
| `skills/issue-write` | `Spawned` section, abandoned marker, mandatory retitling | **`Spawned` only.** Zero hits for *abandon*, zero for *retitle* |
| `skills/decompose` | Reading `Spawned` as input, recording origin | **Zero hits** for *spawned* or *origin* |
| `skills/chat-response` | The ascend/descend prompt as a standalone message | **Zero hits** for *ascend*/*descend*. §7.1's general rule landed; §7.2's specific prompt did not |
| `CLAUDE.md` — branching | Branch naming with the number | Only `arc/NN-short-slug`. No number form, neither `issue-<NN>` nor `pr<NN>` |
| `m21` | Rendering these relations | Work-item collapse present. Tangent/descent relations **not** rendered |

The header is a bare *"Carries"*, with no status column — unlike the product README's
mechanism table, which marks every row ⚪/🔵. A reader takes this as description of the
current state.

**Fix:** file the issue that builds them. **Not** a status column — see the note above.

---

## S2 · The mechanism count is now wrong by three

`docs/product-architecture/README.md:50` — *"Thirty-one mechanisms across the six pieces."*
The table holds **34** unique ids (m09–m33, m38–m46).

Already stale at the branch base (33 vs "Thirty-one" — m44/m45 landed without updating it).
This branch added m46 and widened the gap rather than causing it.

**Fix:** *Thirty-four*. Worth doing here since this branch is the one that moved the number.

---

## S3 · No dev-log for issue #76

Every comparable issue in this arc has one — `issue-41-status.md`, `issue-45-announce.md`,
and eight others. `record-route`'s first routing rule sends *"why we chose this, for one
issue"* to `docs/dev-log/issue-<N>-<slug>.md`, and its `checks` list includes `dev-log-exists`.

This is the issue with the most *why* behind it in the arc — three hours of reasoning the
transcript holds and no committed file does. The specific decisions worth recording, all
visible in the transcript and none in the spec:

- **Why the gate is a judgement, not a test.** The first version asked *"is it costing us every
  turn until it is fixed?"* and was rejected as overspecified from one instance. A future
  session will otherwise re-propose a mechanical test.
- **Why `-fix-` and a separate `fix<NN>` index were rejected** — a second counter creates two
  tokens for one thing, and GitHub numbers cannot be reserved.
- **Why the tree change stayed in PR #75 while issue #76 split** — the reviewable-unit call.
- **Why this is not m21, m20, or m43 obligation 0** — §2 states the conclusions but not the
  reasoning that got there.

**Fix:** write `docs/dev-log/issue-76-work-navigation.md`.

---

## S4 · Nothing back-references m46

Zero hits for `m46` outside its own spec and the README row. m43, m20 and m21 are all cited
*by* m46 and none points back. m42 and m44 both have arc-log entries; m46 and issue #76 have
none.

Consequence: a session working in m21 or `decompose` has no way to discover that m46 now
constrains it. m46 §11 assigns work to five artifacts, and none of them mentions it.

**Fix:** at minimum an arc-log row for issue #76, matching m42/m44's treatment. Back-references
into m21/m43 are optional and could reasonably wait for the artifacts to be built.

---

## ~~S5 · The uncommitted edit is right, and unexplained~~ — WITHDRAWN

**Not a finding.** The working-tree edit weakening *"Relevance is not always the test"* to
*"Relevance is not the test"* was **deliberate, by the user**, and has been reverted.

`always` is load-bearing: relevance **is** sometimes the test. The gate is a judgement call,
not a rule with a fixed criterion — which is the same correction the user made to the first
version of the gate during the session.

**My error:** I compared the working tree against the transcript and treated a deliberate
authorial choice as an uncommitted leftover. A cold review checks whether the document matches
what was decided; it does not get to overrule the author on a judgement they own.

**Note this sharpens B1** rather than weakening it. With relevance explicitly *sometimes* the
test, the gate has no mechanical criterion at all — so §6's absolute *"Nothing is acted on when
it is spotted"* contradicts an even more explicitly judgement-based path.

---

## ~~N1 · §9's rule is aspirational~~ — WITHDRAWN

**Not a finding. No change to §9.**

Two things wrong with it:

- **The current branch follows the rule.** `arc/03-camp-issue-76-work-nav` carries the number
  in the `issue-<NN>` form. The claim that nothing follows it was false.
- **The old names are negative examples, and that is the point.** `arc/03-camp-issue-write-no-issue-pr`
  and `arc/03-camp-chat-response-links` are *why the rule exists* — unsayable, unmatchable
  against a PR under review, and the direct cause of the eleven-PR confusion in §1. Marking
  them "forms, not history" would erase the evidence the rule is built on.

The reader is not at risk of mistaking them for a record. They are the chaos §1 describes.

---

## N2 · §5.1's own decision is not in §5's entry condition

§5's entry condition — *"a small, scoped discovery during manual work"* — was written before
the fix-now path existed. The fix-now case is by definition **not** small and scoped relative
to the unit; it is a separate unit fixed inline. Not a contradiction, but the entry condition
no longer covers everything the loop now does.

Low priority. Worth a glance when §6 is fixed for B1, since it is the same propagation gap.

---

## N3 · Cold readability holds

Checked specifically, since it is the failure mode the review exists for.

- §4's worked example was rewritten mid-session for exactly this reason and now stands alone —
  every row names the object, the relation and the base. **Verified factually accurate**
  against git history: PR #74, PR #75 and issue #45's branches all cut from `arc/03-camp`.
- Every number carries its kind (`issue #45`, `PR #74`) throughout, per the decision made
  during review.
- The one internal anchor, `#4-three-relations-not-two`, resolves.
- The `m40-autonomy-switch.md` link is dead, deliberately — issue #73's deliverable, disclosed
  in the handoff. Not a defect.
- Section numbering (1–12) is justified in the spec-interview edit and matches m43's precedent.

---

## What I checked and found clean

- **All ten settled decisions present**, matching the transcript's wording: three relations ·
  patch series named · descent grows the unit with mandatory retitling · git-graph vs
  work-tree · `Spawned` as scope buffer · abandoned markers · decompose reading it ·
  breath-ends-at-merge · decision-leads-the-message · manual-mode review.
- **Nothing written but never agreed.** Every section traces to a transcript exchange.
- **The registry fix is correct** — 38–46 Arc, next free 47, matching the nine live ids
  m38–m46. Lodestar's copy is untouched, as disclosed (lodestar#9 filed).
- **The two skill edits are faithful** to what was asked, and `spec-interview`'s section-
  numbering guidance correctly frames itself as per-document rather than blanket.
- **`chat-response`'s trim held** — the link rule is four lines, matching its neighbours, and
  the new subsection did not re-inflate it.
- Both `.claude/` copies are in sync with `skills/` for the two edited files.

---

## Suggested order

1. ~~**B2**~~ — **done.** Six files, zero old-term hits, both `.claude/` copies in sync.
2. **B1** — one clause in §6. The decision most at risk of being lost.
3. **S2** — one word in the README.
4. **S1** — a line or a column on §11.
5. **S3 / S4** — dev-log and arc-log row.

S5 withdrawn. N1–N3 are notes; no action needed unless you want them.
