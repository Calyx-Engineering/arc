# Issue #&lt;N&gt; — &lt;title&gt;

> Decision log, not a spec. Started at plan time, finalised as a retrospective at PR time.
> Keep it short — capture the *why*, not a blow-by-blow. Skip any section that doesn't apply.

**Issue:** &lt;link&gt;  ·  **PR:** &lt;link&gt;

## Problem

What wasn't working, or what this enables. A sentence or two.

## Intent and north star

**Written before the plan, in two passes.** Pass 1 from the issue body alone; pass 2 after
reading what it links to, the spec section it delivers, and the artifacts it names — recording
what changed, or that nothing did.

| | |
|---|---|
| **What this issue is really for** | Not a restatement of the title |
| **North star** | What must be true when this merges. Tested against the issue's verbatim quote where it has one |
| **What makes it durable** | What the fix has to survive |
| **Out of scope** | What refinement must not grow this into |

Carried into the PR body verbatim, so the final review tests the diff against it.

## Decisions & trade-offs

The choices that shaped the work, and why. The reasoning that won't survive in the diff.

## Rejected approaches

Options considered and dropped, with the reason. (Delete if none.)

## Spawned

Everything this issue produced beyond the diff. Written as things are created, not at the
end — a document nothing points at is a document nobody finds. **Omit the section entirely
when nothing was spawned.**

- **Scratch:** [&lt;topic&gt;](../scratch/issue-&lt;N&gt;-&lt;slug&gt;/&lt;topic&gt;.md)
- **Report:** [&lt;capability&gt;](../report/&lt;capability-slug&gt;/README.md)
- **Arc work:** [&lt;topic&gt;](../arc-work/&lt;arc-slug&gt;/&lt;topic&gt;.md)
- **Issues:** #&lt;N&gt;, #&lt;N&gt; — spawned from &lt;what caused them&gt;

## Retrospective

Filled in at PR time: what actually got built, what changed from the plan, and what a future
reader needs to know. One paragraph, then links down — this is the index into depth, not the
depth itself.
