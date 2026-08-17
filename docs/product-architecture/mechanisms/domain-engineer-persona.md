# Mechanism — Domain Engineer Persona

**Status:** proposed.
**Home:** Bench (the EE instance); the pattern generalises.
**Spawned from:** [friction-log.md](../friction-log.md) §2.6.

---

## The diagnosis

The defect is **analysis depth, not missing input.** The information was available — in
datasheets, largely as graphs — and was not retrieved. This is a competence gap, not a
communication gap, so no amount of the user stating more up front would fix it.

> *"These aren't assumptions that are invisible until wrong. This is me asking you to
> function as a design engineer. That means i'm leaning into your intelligence and
> finding that there are gaps."*

David's own characterisation of the level reached: **"sophomore EE college student."**
Correct in outline, binary where the real device is continuous, and not consulting the
primary source.

---

## The three cases

### Case 1 — PTC fuse treated as binary

**What happened.** A PTC (positive temperature coefficient) fuse was analysed as
`tripped` / `not tripped`. The real device is **approximately linear** — its behaviour
is a curve of trip time against current and temperature, published as *graphs* in the
datasheet.

**What deeper reasoning would have produced.** Combining the datasheet curves with two
facts about the product:

- Lights are on for **a few seconds at a time, ~10 s maximum**, with long gaps between
- Probability of a sustained 4 A output is **low**

…gives a fuse surviving **hundreds to thousands of seconds** of that duty. Not an
issue. At most a logged risk — a footnote or fishbone entry for future field-failure
root-causing.

**What happened instead:** the same non-issue was raised four or five times until David
said, in effect, stop and trust me.

> *"you're going to have to trust me that your analysis is wrong. I don't have time to
> explain it to you."* — 2026-08-12

**Two failures, not one:**

1. Shallow device model — binary instead of curve-based
2. **No escalation ceiling** — the same concern re-raised repeatedly without new
   evidence

The second is independently damaging. Repeating an unresolved concern is not diligence;
it burns the human's patience and trains them to dismiss future flags.

**The missing requirement.** David also identifies a root cause on his side: the duty
cycle (~10 s bursts, long gaps) **existed in weeks of conversation but was never written
down**. Had it been a story with acceptance criteria, the analysis would have had it.

> *"a **story that was missing in md** (critical fault) but present in our long
> discussions over the past few weeks"*

**This is the clearest single instance of the Lodestar gap causing concrete engineering
cost.** Not a hypothetical benefit — a real analysis that went wrong four or five times
because a known fact was never captured.

### Case 2 — Inductor saturation treated as a cliff

**What happened.** Saturation modelled as a threshold. Real power inductors roll off
**gradually**, and that gradual roll-off is a deliberately engineered characteristic.
The curve is in the datasheet.

> *"Saturation isnt a cliff. for power inductors like this its more linear … Saturation
> is typically defined (in the DS as either -20% or -30% inductance). In this case at
> 25A the inductance is 0.7uH. At 30A it is 0.65uH."*

David then had to specify the analysis himself — *"run a quick variance analysis
assuming a -30% inductance loss at 24A"* — work the persona should have proposed.

**Same root cause as case 1:** datasheet not consulted, device modelled as a switch
rather than a curve.

### Case 3 — BOM reuse never considered

**What happened.** A component was selected on its merits alone, without checking what
the design already used.

> *"as a good design engineer one thing that should be done is to look at your existing
> BOM and see what can be reused … minimize the number of unique parts. That drops the
> overall cost and makes things much more maintainable when we go to rework boards."*

Corrected in-session:

> *"update your assumptions, i already have a 2mOhm in the LTC surge stopper. plan on a
> 2mOhm and common FET with surge stopper — there is a lot of overlap/repeated parts in
> this approach which simplifies the BOM."*

**Different failure from 1 and 2.** Not depth — *scope*. Component selection was treated
as a local optimisation when it is a system-level one. Part-count minimisation is
standard design-engineering practice with cost, procurement, and rework consequences.

**Generalises beyond electrical:** *"Same concept applies to mechanical design — minimize
the number of unique parts."*

---

## What the persona must do

| Behavior | From |
|---|---|
| **Read the requirements before analysing** | Case 1. See below — this is a first-class step, not a courtesy |
| **Read the datasheet, including the graphs** | Cases 1, 2. Curves are frequently images, not text |
| **Model devices as continuous, not binary** | Cases 1, 2. Ask "what is the curve?" before "is it in spec?" |
| **Apply real duty cycle, not worst case forever** | Case 1. A 10 s burst is not steady-state |
| **Check the existing BOM before selecting a part** | Case 3 |
| **Minimise unique part count** | Case 3. Cost, procurement, rework |
| **Escalate once, then log it** | Case 1. Re-raising an answered concern is a defect |
| **Distinguish a risk from a problem** | Case 1. Risks get logged for future root-causing; problems block |

### Ask Star for the requirements — do not read them directly

Case 1 failed twice in series. This persona owns the second failure, but **not by
learning the requirements set** — by querying the agent that owns it.

| Stage | Failure | Owner |
|---|---|---|
| Capture | The PRD format discarded the duty-cycle context | Lodestar |
| **Consumption** | **The analysis never went looking for it** | **This persona — via Star** |

> *"the engineering analysis would have needed to know to go back to the stories to pull
> that important context out if it **were** there."* — David, 2026-08-16

**Star is the requirements interface.** Doc 04 defines her as the PO-delegate answering
*"what does the user want?"* mid-build, on the graduated Star authority ladder — Agreed /
Derived-provisional / Escalate. The engineering persona asks a question in engineering
terms and gets an answer with a known confidence level.

**Why a query beats reading files:**

| | Persona reads stories | Persona asks Star |
|---|---|---|
| Knows the schema, ID scheme, RD layout | Required | Not required |
| Handles a missing requirement | Silently assumes | **Escalates — a known Star behavior** |
| Marks a derived answer as provisional | No | **Yes, with a logged trail** |
| Survives Lodestar's format changing | No | Yes |

**The worked example.** *"What duty cycle applies to the light output?"* → Star returns
~10 s bursts with long gaps, cited to its story; **or** escalates because nothing carries
it. Either answer prevents the wrong PTC analysis. The second also surfaces a
requirements gap as a by-product of engineering work — a capture trigger arriving from an
unexpected direction.

**What to ask about:** duty cycle, environment, operating limits, expected lifetime,
fault tolerance. These change an answer by orders of magnitude and live in requirements,
not datasheets.

**Cite the answer and its tier** in the analysis, so a reader can tell a grounded input
from a provisional one.

**When Star is absent** (no Lodestar in the repo), state the assumption explicitly —
*"assuming continuous operation, worst-case; no duty-cycle requirement available"* — and
carry on. The persona must degrade gracefully.

### The escalation rule, stated plainly

> A concern raised and answered is **closed**. Re-raise it only with new evidence. If it
> is real but not blocking, write it down as a risk — a footnote or fishbone entry a
> future session can use during field-failure root-causing — and move on.

---

## How it gets invoked

**The trigger problem.** David's request is phrased naturally:

> *"when I say i'd like you to look at these things as a 'design engineer' or 'electrical
> engineer' … I don't know if i can create a word driven hook for this so just try to
> sus out what you can."*

| Option | Assessment |
|---|---|
| Keyword hook on "design engineer" / "electrical engineer" | Brittle; misses the many times the request is implied |
| Skill with a description matching analysis tasks | Fires on component selection, tolerance, thermal, protection work |
| **Dedicated agent** | Best fit — analysis is token-heavy (datasheets, PDFs, curves) and returns a bounded conclusion |
| Always-on persona | Wrong; most work is not electrical analysis |

**Leaning: an agent, invoked when the task is electrical analysis**, with a skill
carrying the checklist so the behaviour applies inline for small questions too.

**A datasheet-reading capability is a hard prerequisite.** Cases 1 and 2 both turn on
graphs inside PDFs. Without that, the persona cannot do the job that defines it.

---

## Why this belongs to Bench

It is domain-total. Nothing here transfers to software work. The *pattern* — a
domain-expert persona with a depth checklist and an escalation ceiling — generalises,
but every rule in it is electrical engineering.

**A mechanical-engineering sibling is already implied** by David's part-count comment.

---

## Open questions

| Question | Notes |
|---|---|
| How is depth verified? | "Did you read the datasheet curve?" is checkable; "did you reason deeply?" is not |
| Where do logged risks live? | Fishbone, footnote, or a risk register. None exists yet |
| Does the persona get the BOM automatically? | Needs a machine-readable BOM. Related to configuration management |
| How does it know product duty cycle? | **From stories.** Direct dependency on Lodestar — this is case 1's root cause |
| Escalation-ceiling enforcement | Track raised-and-answered concerns per session, or across sessions? |

---

## Related

- [friction-log.md](../friction-log.md) §2.6 — the entry this corrects
- Lodestar docs — case 1's missing duty-cycle story is the requirements gap, observed live
- ROADZ `.claude/wiki/speaker-power.md` — an existing example of captured device physics
