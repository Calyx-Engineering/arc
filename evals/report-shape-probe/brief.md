Three days on the bench, THERM-4 fan-controller boards. 40 came back from the field with
intermittent fan stall. Here is everything I have.

I started by reproducing the stall. It shows up at fan spin-up and nowhere else. Put a scope on
TP7 and the 12V rail sags to 9.4 V for about 180 ms every time the fan starts — 20 boards on the
bench, all 20 do it.

Then I went looking for what the fan needs. Its datasheet, page 4, gives a minimum start voltage
of 10.8 V.

Next I looked at the bulk capacitance. The BOM calls for a 470 uF part on the 12V rail and the
vendor's product page for that part number says 470 uF, plus or minus 20 percent. I pulled 12
parts from the same stock reel and put them on an LCR meter: every one reads between 180 uF and
240 uF.

I called the supplier's quality contact about it. He said on the phone that the reel we bought
was a "capacity-equivalent substitute". Nothing in writing.

To check the theory I fitted 1000 uF parts to 5 boards and re-ran the spin-up. The sag is gone —
minimum 11.6 V measured on the same scope and the same test point.

I also checked firmware, in case it was a drive-profile problem. Three versions across the 40
returned boards, no correlation with the fault.

What I do not know: how many field units carry the substituted reel. Production has no lot
traceability back to reel, so this is an estimate from the purchase dates at best.

Write this up for the electrical lead, who was not on the bench for any of it. Write it to
`report.md` in the current directory. Nothing else.
