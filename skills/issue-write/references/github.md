# GitHub mechanics

Syntax and quirks. The discipline is in [`../SKILL.md`](../SKILL.md).

## Closing keywords

`close` · `closes` · `closed` · `fix` · `fixes` · `fixed` · `resolve` · `resolves` ·
`resolved`

All equivalent, case-insensitive. Each must be followed by `#NN`, or `owner/repo#NN` for a
cross-repository link. **Cross-repository closing works** but needs write access to both.

## Conditions for a link to bind

| | |
|---|---|
| Base branch | Must be the repository **default branch**. Otherwise the keyword is ignored |
| Placement | Own line, end of the body. Not inside a table cell or list item |
| Form | Keyword, whitespace, `#NN`. No intervening words |

The base-branch condition is confirmed, not suspected — see the SKILL's *base branch*
section for the isolating comparison.

Changing the default branch does not re-parse existing PRs; re-save the body to force it.
A re-save cannot create a link the base branch forbids — but on a base that **is** the default
branch it binds a keyword added even after the merge. See the SKILL's *A missed keyword is
recoverable after the merge*.

## Verify

```sh
# all closing links, both sources, plus the base that decides whether they can bind
gh pr view NN --json closingIssuesReferences,baseRefName

# hand-attached links only — these are NOT from the body
gh api graphql -f query='{repository(owner:"OWNER",name:"REPO"){
  pullRequest(number:NN){closingIssuesReferences(first:5,userLinkedOnly:true){nodes{number}}}}}'
```

If `userLinkedOnly` returns a node, no body edit removes it. No public mutation exists.
Hand the user the click: **PR → Development panel → ✕**.

## Editing bodies safely

`gh issue edit` and `gh pr edit` replace the whole body. To patch one section:

```sh
gh issue view NN --json body --jq .body > body.md \
  && [ -s body.md ] \
  && cp body.md body.before \
  && python edit.py body.md \
  && ! cmp -s body.before body.md \
  && gh issue edit NN --body-file body.md

gh issue view NN --json body --jq .body | grep -n 'the thing you changed'
```

**One chain, because the steps are independent and any of them can die.** The trap is not only
a path a later step cannot see — it is **the edit step failing at all**. Written as separate
commands, a middle step that dies leaves the write-back running against the file an earlier one
produced, and `gh` writes the **original** body back and reports success. A Windows path in a
non-raw string literal is the repeat offender: `"C:\Users\..."` fails at parse time, before the
edit runs.

**Always read back.** The guard stops the bad write; the read-back proves it. The full account
is in the SKILL's *A body edit replaces the whole body*.

## Useful queries

```sh
# what references this issue
gh issue view NN --json body --jq .body | grep -nE '^- #|Related'

# every issue with dates, to reconstruct what an effort spawned
gh issue list --state all --limit 100 \
  --json number,title,state,createdAt \
  --jq '.[] | "\(.number)\t\(.state)\t\(.createdAt[0:10])\t\(.title)"' | sort -n

# merge readiness
gh pr view NN --json state,baseRefName,mergeable,mergeStateStatus

# what an arc PR must close — every issue merged into the arc branch
gh pr list --state merged --base arc/NN-slug --json number,title
```

## Markdown notes

- Bodies render GitHub-flavoured Markdown; tables and task lists work
- `- [ ]` renders as a tracked checkbox. Use it for acceptance criteria
- Sub-issues and task-list linking are separate features from closing keywords
- Non-ASCII can be mangled by a Windows console codepage — write the body to a file rather
  than passing it inline
