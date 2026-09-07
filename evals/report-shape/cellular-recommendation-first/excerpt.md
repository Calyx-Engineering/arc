# Onboard Cellular Module & Antenna — Options & Recommendation

**Relates to:** [#26 — Onboard cell modem evaluation](https://github.com/Lantern-Systems/roadz-sound-system/issues/26) · [US001 — Two deployment configurations](../../user-stories/US001-two-configurations.md)
**Author:** David Class · **Date:** 2026-07-27 · **Status:** ✅ **Branch A (Cat-4) selected**
**Scope:** Replace the Teltonika RUT241 (~$200) with an end-device-certified modem mounted on Interface PCBA rev B. Host processor is a standard **Raspberry Pi 4**.

---

## 1. Recommendation

Lay down **one 20-pin, 2 mm-pitch Skywire land pattern** on rev B and populate Cat-4 or Cat-M as a BOM option. Both parts are **end-device certified**, so FCC and carrier certification cost is **$0 either way** — identical to the RUT241 position today.

> ## ✅ Going with Branch A — Cat-4
> **Module:** `NL-SW-LTE-TC4NAG-B` — $120 · [Airgain product page](https://airgain.com/products/4g-lte-cat-4-na/) · [DigiKey](https://www.digikey.com/en/products/detail/airgain/NL-SW-LTE-TC4NAG-B/16500586)
> **Antenna:** `YEMN302Q1A` — $59.90 · [Quectel product page](https://www.quectel.com/product/yemn302q1a-lte-gnss-screw-mount-combo-antenna/) · [DigiKey](https://www.digikey.com/en/products/detail/quectel/YEMN302Q1A/26239590)
> Integration docs live on the manufacturer pages, not DigiKey — see §7.3 for the full list.
> **Saves ~$50/unit** vs the RUT241, at **$0** FCC and carrier certification cost.
> Keeps FirstNet Band 14 and full OTA throughput. Branch B remains a drop-in cost-down on the same footprint if B14 is later ruled out.

| | Today | **✅ Branch A — Cat-4** | Branch B — Cat-M |
|---|---|---|---|
| Module | RUT241 $200 | **`NL-SW-LTE-TC4NAG-B` $120** | `NL-SW-LTE-QBG95-D` $77 |
| Antenna | Bingfu $30 | **`YEMN302Q1A` $59.90** | `SWA2100` $50.58 |
| **Total RF** | **$230** | **$180** | $128 |
| **Saved / unit** | — | **$50** | $102 |
| @ 100–500 units/yr | — | **$5k–25k** | $10k–51k |
| Band 14 / FirstNet | ✅ | **✅** | ❌ |

**Why A over the cheaper B:** Cat-M cannot do Band 14, and B14/FirstNet is not yet ruled out. Cat-4 also carries the OTA headroom for Pi OS and container updates. The extra $52/unit buys both.

---

