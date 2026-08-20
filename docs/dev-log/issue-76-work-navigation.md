# Issue #76 — How discovered work is recorded, navigated, and merged

> Decision log, not a spec. Started at plan time, finalised as a retrospective at PR time.

**Issue:** [#76](https://github.com/Calyx-Engineering/arc/issues/76)  ·  **Spec:** [m46](../product-architecture/mechanisms/m46-work-navigation.md)

## Problem

Work is discovered while doing other work, and nothing said where it went. A discovery either
derailed the current work or was lost.

The visible cost was eleven PRs open across five branches, each cut from a different base. A
review begun in one branch lost its subject when the working tree moved to another — reported
as happening at least eight times over three days, each time discarding the review already
done.

**The naming was the symptom. The cause was that a discovery moved the working tree at all.**

## Decisions & trade-offs

The spec states these. What it does not state is why the alternatives lost.

| | |
|---|---|
| **Three relations, not two** | Tangent and descent were the first cut. *Tangent with dependency* — shared base, but it would not exist without the parent — turned out to be the common case and has no distinct branch shape. Collapsing it into either of the other two loses the reason the work exists |
| **The two views stay separate** | The git graph carries dependency; the `Spawned` tree carries the work story. Forcing either to match the other loses information — a tangent-with-dependency is a child in the tree and a sibling in the graph, and both are correct |
| **Patch series, not trunk-based** | Both traditions agree the unit is *one reviewable unit with one coherent story*; they disagree on whether that unit is a commit or a PR. Discovery work produces changes that only make sense together — a rule and the artifact that reads it. Splitting them ships a rule nothing honours |
| **The anti-pattern is not size** | It is a unit that grows without its title growing. This is why retitling is mandatory rather than encouraged — the failure being fixed was a PR that expanded four times under its first title |
| **`Spawned` is a scope buffer, not a to-do list** | Rows are edited as understanding improves, not only appended. A table that grew for three days is evidence of scope, and it is `decompose`'s other input |
| **A breath ends at merge** | Not at "I moved on". An abandoned row stays, marked at the front — a record of what was chosen against is worth more than a tidy table |
| **The fix-now gate is a judgement, not a test** | See below. The most contested decision in the issue |
| **Any decision leads the message** | Generalised from the ascend/descend prompt after the same failure recurred: a decision buried under 120 words of analysis got answered as though nothing had been proposed |

### Why the fix-now gate is a judgement

The first version asked *"is it costing us every turn until it is fixed?"* — rejected, and the
rejection is the decision worth recording:

> *"is heavily overspecified. you picked out **ONE** case of why we'd have to fix it
> immediately. its ultimately my judgement call, not a yes/no to a single question."*

`chat-response` happened to be a repeating defect, so the gate had been written as *"is it a
repeating defect?"*, excluding every other reason to interrupt. It became a judgement node
styled like the ascend/descend prompt — two user decisions in the loop, visually identical.

The analogy that fixed it, and the reason it beats a list of conditions:

> *"If you're building a house and it catches on fire you don't tell yourself 'that has nothing
> to do with finishing the wall i'm framing right now.' You just grab a fire extinguisher and
> go."*

**Relevance is not always the test** — the wording is deliberate. Relevance sometimes *is* the
test; what decides the case is the cost of waiting. That is why no scope rule can answer it:
scope asks whether the thing belongs here, this asks whether it can wait.

## Rejected approaches

| Rejected | Why |
|---|---|
| **One PR in flight at a time** | Proposed, then withdrawn. It forces exactly the backlog that small-PR discipline exists to avoid. The binding constraint is not how many PRs are open — it is how many branches the working tree visits. Open PRs never hurt; the checkouts did |
| **Open the PR first to get the number, then branch** | GitHub will not create a PR without a pushed branch. The workaround — a draft PR on an empty commit, then force-push the rename — force-pushes a published branch, which CLAUDE.md forbids |
| **A separate `fix<NN>` index** | A second counter means `fix-42` and `#42` are different things and every reference has to say which. The value wanted was a *sayable unique token*, and a parallel sequence collides with the one that already exists |
| **Predicting the next number** (read max + 1) | Silently wrong whenever anything lands between the read and the create. GitHub numbers cannot be reserved — allocation happens at creation |
| **A GitHub Action allocating from a file** | Real reservation, but a commit per allocation, a race of its own, and infrastructure to maintain for a branch name |
| **Backgrounding an unscoped tangent in a worktree** | Presumes the tangent is ready to work when spotted. Usually it has been *spotted, not scoped* — backgrounding it produces work that must then be reviewed cold, which is the failure already being fixed. Worktrees are right once the user has scoped it |
| **Merging a small fix immediately, before review** | Proposed and corrected: in manual mode that merges unreviewed work. The branch is transient; the review is not |

## Where this does not belong

Three homes were considered and rejected, and §2 records the conclusions without the reasoning:

- **Not [m21](../product-architecture/mechanisms/m21-arc-tree.md)** — m21 renders a tree. This is how work is created and navigated, which is upstream of rendering.
- **Not [m20](../product-architecture/mechanisms/m20-arc-decomposition.md)** — m20 sequences an arc's known issues at kickoff. This navigates discovery at any point. They meet only when a discovery is large enough to become an arc.
- **Not [m43](../product-architecture/mechanisms/m43-camp-assistant.md) obligation 0** — scope asks whether a discovery belongs in this arc. Different question, and the fire-extinguisher case is precisely one where scope says no and the answer is still *fix it now*.
- **Not arc-scoped at all** — discovery happens outside arcs, so it is its own mechanism.

## Spawned

- **Issues:** [#78](https://github.com/Calyx-Engineering/arc/issues/78) — builds the five artifacts m46 §11 names. This issue specifies; it does not deliver
- **Issues:** [#77](https://github.com/Calyx-Engineering/arc/issues/77) — a spec-reviewer agent, to automate the cold review this issue closed with. No milestone
- **Issues:** [lodestar#9](https://github.com/Calyx-Engineering/lodestar/issues/9) — Lodestar reads Arc's mechanism registry rather than mirroring it. Found while fixing the stale registry
- **PRs:** [#74](https://github.com/Calyx-Engineering/arc/pull/74) · [#75](https://github.com/Calyx-Engineering/arc/pull/75) — the two no-issue PRs whose confusion produced this mechanism. Both are rows 2 and 3 of m46 §4's worked example

## Retrospective

**The spec was written in the window that produced it, deliberately.** The issue body held the
decisions but not the reasoning, and a fresh session reading only conclusions rebuilds the spec
worse. This dev-log exists for the same reason — it was missing at the cold review, which is
where the gap was caught.

Two things the spec carries that the original scope never asked for, both added during review:
**§5.1's fix-now path** and **§7.1's generalisation** from the ascend/descend prompt to any
decision that moves the work. Both came from the same failure recurring during the writing.

The mechanism was applied to itself throughout. Section numbering and the issue/PR labelling
rule were both spotted mid-review, rowed into `Spawned` rather than acted on, and PR'd after
the review finished. `chat-response` was the counterexample — rowed *and* fixed immediately,
which is the case that exposed the missing third path.

### Open

- **Nothing here has been executed.** m46 is a document; the artifacts that carry it are [#78](https://github.com/Calyx-Engineering/arc/issues/78)
- **[m40](../product-architecture/mechanisms/m40-autonomy-switch.md) is a dead link** — §8 defers auto and manual to it, and it lands with [#73](https://github.com/Calyx-Engineering/arc/issues/73)
- **`docs/suite-architecture/README.md` is mirrored** and lodestar's copy did not get the registry fix — [lodestar#9](https://github.com/Calyx-Engineering/lodestar/issues/9)
