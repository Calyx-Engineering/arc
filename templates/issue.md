# &lt;type&gt;: &lt;what merging delivers&gt;

> The shape of an issue body, in order. **What to write and what to cut is
> [`issue-write`](https://github.com/Calyx-Engineering/arc/blob/main/skills/issue-write/SKILL.md)'s** —
> this file does not repeat its rules, or the two drift. Delete this block and every
> `<placeholder>` before the write.

## Set at creation, not written into the body

Three fields are set at creation, not written into the text. Each is invisible once missed.

| | |
|---|---|
| **Milestone** | `gh issue create --milestone "<name>"` |
| **Label** | The title prefix decides it — the mapping is [`issue-write`](https://github.com/Calyx-Engineering/arc/blob/main/skills/issue-write/SKILL.md)'s *Labels* section, and `tests/verify-labels.sh` enforces it |
| **Base** | An issue has none. A PR's base is the arc branch — [`templates/pr.md`](https://github.com/Calyx-Engineering/arc/blob/main/templates/pr.md) |

## The order

**Four sections, and the order is the rule.** `Related` is last; a heading after it is a
reportable defect — `tests/verify-tracker-body.sh body <file>`.

| | Section | Holds |
|---|---|---|
| 1 | Opening | The defect or the need. No heading — the body opens with it |
| 2 | `Required` | What must be true when this is done |
| 3 | `Constraints` | Numbers, parts, interfaces, standards |
| 4 | `Related` | **The last section, always.** Every edge, spawn rows at the top of the table |
| — | `Blocked by #<NN>` | A bare line under the table |
| — | `Closes #<NN>` | **A PR's last line, never an issue's** |

---

&lt;The defect or the need, in one or two sentences.&gt;

## Required

&lt;What must be true when this is done. A checklist where there are several.&gt;

- [ ] &lt;one thing that must be true&gt;
- [ ] &lt;another&gt;

## Constraints

&lt;Numbers, parts, interfaces, standards. Delete the section when there are none.&gt;

| | |
|---|---|
| **&lt;name&gt;** | &lt;the constraint&gt; |

## Related

&lt;One table, four kinds. Delete the rows that do not apply, and the whole section when none
do.&gt;

| | Link | What it is |
| :--- | :--- | :--- |
| **Spawned by** | &lt;link&gt; | &lt;the effort that caused this issue to exist&gt; |
| **Spawned** | &lt;link&gt; | &lt;work this issue caused to exist&gt; |
| Blocked by | &lt;link&gt; | &lt;what has to land before this can start&gt; |
| Related | &lt;link&gt; | &lt;exists independently, touches the same area&gt; |

Blocked by #&lt;NN&gt;
