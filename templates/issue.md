# &lt;type&gt;: &lt;what merging delivers&gt;

> The shape of an issue body, in order. **What to write and what to cut is
> [`issue-write`](https://github.com/Calyx-Engineering/arc/blob/main/skills/issue-write/SKILL.md)'s** —
> this file does not repeat its rules, or the two drift. Delete this block and every
> `&lt;placeholder&gt;` before the write.

## Set at creation, not written into the body

Three fields live on the issue itself. None of them belongs in the text, and each is invisible
once missed.

| | |
|---|---|
| **Milestone** | `gh issue create --milestone "&lt;name&gt;"`. Without it the issue drops out of the milestone view, which is where an arc reads as one unit |
| **Label** | The title prefix decides it — `tools/verify-labels.sh` holds the mapping. Set it at creation; nothing infers it later |
| **Base** | An issue has none. A PR's base is the arc branch — [`templates/pr.md`](https://github.com/Calyx-Engineering/arc/blob/main/templates/pr.md) |

## The order

**Four sections, and the order is the rule.** `Related` is last, its spawn rows are the last
rows in it, and a heading after them is a reportable defect —
`tools/verify-tracker-body.sh body &lt;file&gt;`.

| | Section | Holds |
|---|---|---|
| 1 | Opening | The defect or the need. No heading — the body opens with it |
| 2 | `Required` | What must be true when this is done |
| 3 | `Constraints` | Numbers, parts, interfaces, standards |
| 4 | `Related` | Every edge, spawn rows included. **Last, always** |
| — | `Blocked by #&lt;NN&gt;` | A bare line under the table, for the driver's grep |
| — | `Closes #&lt;NN&gt;` | **A PR's last line, never an issue's.** After the spawn rows, on its own line |

---

&lt;The defect or the need, in one or two sentences. State it; do not explain why it is a
problem.&gt;

## Required

&lt;What must be true when this is done. A checklist where there are several — it is the
acceptance criteria and the only definition of done.&gt;

- [ ] &lt;one thing that must be true&gt;
- [ ] &lt;another&gt;

## Constraints

&lt;Numbers, parts, interfaces, standards. Delete the section when there are none.&gt;

| | |
|---|---|
| **&lt;name&gt;** | &lt;the constraint, in the fewest words that make it actionable&gt; |

## Related

&lt;One table. Four kinds of edge and there is no fifth: **Spawned by**, **Spawned**,
**Blocked by**, **Related**. The spawn edge is the first row. Delete the rows that do not
apply, and the whole section when none do.&gt;

| | Link | What it is |
| :--- | :--- | :--- |
| **Spawned by** | &lt;link&gt; | &lt;the effort that caused this issue to exist&gt; |
| **Spawned** | &lt;link&gt; | &lt;work this issue caused to exist&gt; |
| Blocked by | &lt;link&gt; | &lt;what has to land before this can start&gt; |
| Related | &lt;link&gt; | &lt;exists independently, touches the same area&gt; |

Blocked by #&lt;NN&gt;
