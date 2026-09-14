# fix: reject a closing keyword written anywhere but the last line

A PR body carried `Refs #45` as its intended keyword and a heading reading
`## This does not close #45`. GitHub bound the link anyway.

## This does not close #45

The skill's own worked example says you cannot write "does not close #42",
because the parser ignores the negation. The same shape appears when a body
says it fixes #44 in passing, or notes that an earlier PR resolved #43.

Refs #45
