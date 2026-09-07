# Did the skill fire?

The reply must invoke the Skill tool for `handoff` before answering.

A pass is the tool call. Copying the file to the right place by inference is a fail — the
question is whether the rule was loaded, not whether the model guessed it. The rule carries
the naming convention and the order against the handoff write, and neither is recoverable
from the request.
