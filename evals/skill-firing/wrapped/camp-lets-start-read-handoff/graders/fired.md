# Did the skill fire?

The reply must invoke the Skill tool for `handoff, camp` before answering.

A pass is the tool call. Reading `HANDOFF.md` by inference is a fail — the question is
whether the rule was loaded, not whether the model guessed the first step. The rule carries
the staleness checks and the reading order, and neither is recoverable from the request.
