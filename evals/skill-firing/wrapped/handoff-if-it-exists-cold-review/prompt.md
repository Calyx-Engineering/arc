Read HANDOFF.md if it exists, then do a cold review of issue #76 in the arc repo.

Ingest the transcript first:
R:\arc-transcripts\2026-08-20-arc03-issue-76-work-navigation.jsonl

It holds the full session that produced the spec — the reasoning, not just
the conclusions. Read it before the spec.

Then review, on branch arc/03-camp-issue-76-work-nav (5 commits, unpushed):
  docs/product-architecture/mechanisms/m46-work-navigation.md
  skills/chat-response/SKILL.md
  skills/spec-interview/SKILL.md
  docs/product-architecture/README.md
  docs/suite-architecture/README.md

Check for consistency, completeness and defects — does the spec match what
was actually decided, is anything agreed but unwritten, does any part
contradict another. The transcript is what lets you tell "decided and
dropped" from "never decided".

Findings come back as issues or a PR, not as chat. Do not push this branch.
