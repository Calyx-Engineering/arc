# GitHub mechanics

Syntax and quirks. The discipline is in [`../SKILL.md`](../SKILL.md).


## Closing keywords

`close` · `closes` · `closed` · `fix` · `fixes` · `fixed` · `resolve` · `resolves` ·
`resolved`

All are equivalent. Case-insensitive. Each must be followed by `#NN` (or
`owner/repo#NN` for a cross-repository link).

**Cross-repository closing works** — `Closes Lantern-Systems/other-repo#12` — but
requires write access to both repositories.


## Conditions for a link to bind

| | |
| --- | --- |
| Base branch | Must be the repository **default branch**. Otherwise the keyword is ignored |
| Placement | Own line, end of the body. Not inside a table cell or list item |
| Form | Keyword, whitespace, `#NN`. No intervening words |

Changing the default branch does not re-parse existing PRs. Re-save the body to force
it, then verify.


## Verify

```sh
# all closing links, both sources
gh pr view NN --json closingIssuesReferences

# hand-attached links only — these are NOT from the body
gh api graphql -f query='{repository(owner:"OWNER",name:"REPO"){
  pullRequest(number:NN){closingIssuesReferences(first:5,userLinkedOnly:true){nodes{number}}}}}'
```

If `userLinkedOnly` returns a node, no body edit will remove it. There is no public
mutation to unlink. Hand the user the click: **PR → Development panel → ✕**.


## Editing bodies safely

`gh issue edit` and `gh pr edit` replace the whole body. To patch one section:

```sh
gh issue view NN --json body --jq .body > body.md
# edit body.md
gh issue edit NN --body-file body.md
```

Write the temp file somewhere the shell and any helper script agree on. **A redirect to
a path a later step cannot see will silently produce an unmodified body, and `gh` will
report success.** Always read back:

```sh
gh issue view NN --json body --jq .body | grep -n 'the thing you changed'
```


## Useful queries

```sh
# provenance sweep — what references this issue
gh issue view NN --json body --jq .body | grep -nE '^- #|Related'

# all issues with dates, to reconstruct what an effort spawned
gh issue list --state all --limit 100 \
  --json number,title,state,createdAt \
  --jq '.[] | "\(.number)\t\(.state)\t\(.createdAt[0:10])\t\(.title)"' | sort -n

# merge readiness
gh pr view NN --json state,baseRefName,mergeable,mergeStateStatus
```


## Markdown notes

- Issue and PR bodies render GitHub-flavoured Markdown; tables and task lists work
- `- [ ]` task lists render as checkboxes and are tracked in the UI. Use them for
  acceptance criteria
- Sub-issues and task-list linking are separate features from closing keywords
- Emoji and HTML entities survive round-tripping through `gh`, but non-ASCII can be
  mangled by a Windows console codepage — write the body to a file rather than passing
  it inline
