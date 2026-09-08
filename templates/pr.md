# arc-&lt;nn&gt;: &lt;type&gt;: &lt;what this diff delivers&gt; (#&lt;NN&gt;)

> The shape of a PR body. It is
> [`templates/issue.md`](https://github.com/Calyx-Engineering/arc/blob/main/templates/issue.md)'s
> order with four differences, below. **What to write and what to cut is
> [`issue-write`](https://github.com/Calyx-Engineering/arc/blob/main/skills/issue-write/SKILL.md)'s.**
> Delete this block and every `&lt;placeholder&gt;` before the write.

## Set at creation, not written into the body

| | |
|---|---|
| **Milestone** | `gh pr create --milestone "<name>"`. A PR with no milestone drops out of the milestone view, which is where the arc reads as one unit |
| **Base** | `--base arc/&lt;nn&gt;-&lt;slug&gt;`. The arc branch, not the default branch |
| **Draft** | `--draft`, before the work. It is marked ready after the final review pass |
| **Label** | None. The `arc-&lt;nn&gt;:` prefix in the title is what groups arc PRs |

## What differs from the issue

| | |
|---|---|
| **No `Required` checklist** | The issue holds it. This body says what happened to it |
| **One section the issue has none of** | The read-back's dispositions — every finding, acted on or declined with the reason. A pass that returned nothing is recorded as having returned nothing |
| **`Closes #&lt;NN&gt;` is the last line** | On its own line, after the spawn rows. One keyword, one number, and prose around it changes nothing |
| **Retitled as the unit grows** | An issue is sized at filing; a PR title describes a diff still being written |

---

&lt;What this changes, in one or two sentences. The endpoint, not the starting point — a
reviewer reads this before the diff.&gt;

## What changed

&lt;The deliverable, in the reader's terms. A short list, one line each. Not a list of commits.&gt;

## Review passes

&lt;Every finding the read-back returned, and what happened to it. **A pass that returned
nothing says so** — silence here is indistinguishable from a pass nobody ran.&gt;

| Pass | Found | Disposition |
|---|---|---|
| &lt;n&gt; | &lt;the finding, or none&gt; | &lt;acted on, or declined with the reason&gt; |

## Evidence

&lt;Gate output, with the exit code. A claim without one is not evidence.&gt;

| | |
|---|---|
| `bash tools/verify-all.sh` | &lt;N gates, all clean — exit 0&gt; |

## Related

&lt;Same table as the issue's, same four kinds. Delete the rows that do not apply.&gt;

| | Link | What it is |
| :--- | :--- | :--- |
| **Spawned by** | &lt;link&gt; | &lt;the effort that caused this PR to exist&gt; |
| **Spawned** | &lt;link&gt; | &lt;work this PR caused to exist&gt; |
| Blocked by | &lt;link&gt; | &lt;what has to land first&gt; |
| Related | &lt;link&gt; | &lt;exists independently, touches the same area&gt; |

Blocked by #&lt;NN&gt;

Closes #&lt;NN&gt;
