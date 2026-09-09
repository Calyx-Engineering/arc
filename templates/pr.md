# arc-&lt;nn&gt;: &lt;type&gt;: &lt;what this diff delivers&gt; (#&lt;NN&gt;)

> The shape of a PR body. It is
> [`templates/issue.md`](https://github.com/Calyx-Engineering/arc/blob/main/templates/issue.md)'s
> order, differing where the table below says. **What to write and what to cut is
> [`issue-write`](https://github.com/Calyx-Engineering/arc/blob/main/skills/issue-write/SKILL.md)'s.**
> Delete this block and every `<placeholder>` before the write.

## Set at creation, not written into the body

| | |
|---|---|
| **Milestone** | Only on a direct PR: `gh pr create --milestone "<name>"`. A PR closing an issue takes none — the issue is the unit of work |
| **Base** | `--base arc/<nn>-<slug>`, the arc branch |
| **Draft** | `--draft`, before the work |
| **Label** | None. The `arc-<nn>:` title prefix is what groups arc PRs |

## What differs from the issue

| | |
|---|---|
| **No `Required` checklist, no `Constraints`** | The issue holds both |
| **Sections the issue has none of** | `What changed`, `Review passes`, `Evidence` |
| **`Closes #<NN>` is the last line** | After the `Related` table |

---

&lt;What this changes, in one or two sentences — the endpoint, not the starting point.&gt;

## What changed

&lt;The deliverable, in the reader's terms. A short list, one line each. Not a list of commits.&gt;

## Review passes

&lt;Every finding the read-back returned, and what happened to it. A pass that returned nothing
says so.&gt;

| Pass | Found | Disposition |
|---|---|---|
| &lt;n&gt; | &lt;the finding, or none&gt; | &lt;acted on, or declined with the reason&gt; |

## Evidence

| | |
|---|---|
| `bash tools/verify-all.sh` | &lt;N gates, all clean — exit 0&gt; |

## Related

&lt;Same table as the issue's. Delete the rows that do not apply.&gt;

| | Link | What it is |
| :--- | :--- | :--- |
| **Spawned by** | &lt;link&gt; | &lt;the effort that caused this PR to exist&gt; |
| **Spawned** | &lt;link&gt; | &lt;work this PR caused to exist&gt; |
| Blocked by | &lt;link&gt; | &lt;what has to land first&gt; |
| Related | &lt;link&gt; | &lt;exists independently, touches the same area&gt; |

Blocked by #&lt;NN&gt;

Closes #&lt;NN&gt;
