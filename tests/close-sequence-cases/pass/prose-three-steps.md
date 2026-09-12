<!-- expect: cites the sequence, states no count -->
# A skill that cites the sequence and counts something else

Close the issue by the order in [`close-sequence.md`](../../docs/product-architecture/close-sequence.md).

Run `git push`, then `gh pr create`, then `gh pr ready`. The three steps are independent, and a
middle one that fails leaves the first one done. #87's sentence, verbatim: about three shell
commands, nothing to do with the close sequence.
