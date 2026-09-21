"""corpus_mask.py — compare a stored eval case against its transcript AFTER masking. #320.

A case's prompt or turn is a verbatim copy of what was said in a real session, and the scorers
check that claim against the transcript: drift is always a failure. Some of those sessions ran
in a client's repository, so the verbatim text names the client — and the repository is public.

Masking the stored copy alone breaks the claim it rests on. So the mask is applied to the
TRANSCRIPT side at compare time, and the stored copy holds the masked text: the check still says
"this is what was said, word for word", with the names swapped for stand-ins.

    tools/corpus.mask           gitignored. One `real~stand-in` per line, applied in file order
    tools/corpus.mask.example   tracked. The format, with nobody's names in it
    ARC_CORPUS_MASK=path        read the mask from somewhere else

THE MASK FILE IS NEVER TRACKED. Its left-hand column is the list of what must not be published.
Without it nothing is masked — which is also the state of every machine that has no client
transcripts, where the cases are reported absent rather than compared at all.

Literal and case-sensitive on purpose. A regex or a case-folded match would rewrite text nobody
listed, and a drift check that forgives what it was not told to forgive is not a drift check.
"""
import io
import os

_HERE = os.path.dirname(os.path.abspath(__file__))


def load(path=None):
    path = path or os.environ.get("ARC_CORPUS_MASK") or os.path.join(_HERE, "corpus.mask")
    pairs = []
    if not os.path.isfile(path):
        return pairs
    for line in io.open(path, encoding="utf-8"):
        line = line.rstrip("\r\n")
        if not line.strip() or line.lstrip().startswith("#") or "~" not in line:
            continue
        real, standin = line.split("~", 1)
        if real:
            pairs.append((real, standin))
    return pairs


def apply(text, pairs):
    for real, standin in pairs:
        text = text.replace(real, standin)
    return text
