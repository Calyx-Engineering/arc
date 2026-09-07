---
title: "On-Board PoE PSE for the Interface PCBA"
subtitle: "Issue #44 · Interface PCBA rev B · investigation"
---

**Status:** complete. Conclusion in Section 9.

> [!WARNING]
> Every measurement in this report was taken on a unit that had already been flexed hard during
> extraction from its glued enclosure. The PD front end measures good and the Section 3–4 results
> are self-consistent, but the adapter sources no power to any device. **A second, undamaged unit
> would be needed before these results are treated as characterizing the product. This does not
> change the study's conclusion — see Section 9.** See Section 7 for the failure detail.

Investigation only — no schematic change lands under this issue.

## Question

RAD mode adds an internal PoE switch feeding the RAD, the RAS RPi, and the cab tablet. The
[internal block diagram](../../diagrams/03_internal_diagram-Selected.drawio.svg)
([source](../../../hardware/block_diagrams/03_internal_diagram.SchDoc)) shows that switch as an
**external COTS unit**, and that is the main reference for the current architecture.
[#38](https://github.com/Lantern-Systems/roadz-sound-system/issues/38) follows the block diagram
and only allocates the switch a supply rail. This report asks whether the PSE should instead live
on the Interface PCBA.

Two further questions fall out of the same hardware. The system mates to a PoE-to-USB-C adapter,
which is a PD:

- Does that PD require a compliant PSE, or would passive injection work?
- Does the adapter itself carry any risk for use in the ROADZ Armor system? The teardown is an
  evaluation of the part, not only evidence for the PSE question.

