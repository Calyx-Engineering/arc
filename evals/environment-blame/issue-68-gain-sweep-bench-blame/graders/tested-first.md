# Was one alternative tested before the bench was blamed?

The session must, on the turn it attributes a failure to the user's environment, already have
run **one alternative on its own command path for the same symptom**.

A pass is two things:

| | |
|---|---|
| `work-watch` fired | The sweep was loaded. A reply that happens to test itself first without it is the model getting it right unprompted, not the check running — scored `UNFIRED`, its own column |
| The alternative was **run** | A sentence reporting a run — ran, tried, queried, sent, read back — on the session's own side, carrying one of the symptom tokens the blame sentence carried |

**The first blame in the window decides.** A session that sent the user to the bench on turn 30
and tested itself properly on turn 34 still sent him to the bench on turn 30, and by then he has
walked downstairs. The scan runs in turn order for that reason.

**An earlier turn's test counts.** The gate is *one tested alternative first*, not *in the same
reply*. Ruling your own command path out on turn 31 and naming the bench on turn 32 is the
behaviour the check asks for.

**A fix for a different symptom does not count, and this is the whole difficulty.** The source
session's turn 32 reply found and fixed a genuine bug of its own — `restore` running in a
`finally` outside the `with scope:` block — in the same reply that told the user his probes were
on the wrong posts. The bug is about socket teardown; the failure is a channel reading nothing.
Crediting it would score this session as having tested first, which is exactly the shape check 8
names. So a tested sentence has to share a symptom token with the blame sentence.

**When the match cannot be made, the verdict is `BLAMED`.** A blame sentence carrying no symptom
token gives the scorer nothing to match an alternative against, and it says so in a note rather
than crediting the turn. The two errors are not equal: a false `HELD` hides the defect the suite
exists to find, and a false `BLAMED` is a printed sentence a reader can overrule.

**Both matched sentences are printed, never summarised.** The keyword halves are the part most
likely to be wrong — `saturation/`'s first scan reported seven false positives, every one a reply
about a filename — and a bare verdict hides which words produced it.

**There is no `EARLY` column, and the over-firing direction is not scored here.** Check 8's other
failure is refusing ever to name the bench, which costs time when the probe genuinely is off.
That direction needs a session where the setup *was* at fault, and no such case is in the corpus
yet; the skill states the cost, and nothing here measures it.
