## 1 · Device under test

From the product label ([figure 10](figures/10_product_label.jpg)):

| | |
|---|---|
| Brand | PROCET PoE System |
| Model | `PT-PGC-AF` |
| Serial | `PT2616022625` |
| Label input | 44.0–57.0 V DC, IEEE 802.3af |
| Label output | 5.0 V DC, 2.0 A (10 W) |
| Data rate | 10/100/1000 Mbps |
| Marks | FCC, CE, NOM/NYCE, indoor-use, WEEE |
| PCB marking | `PT-P6C-AF REV1.5`, dated `2025.6.25` |
| ASIN | [B0CP296VXN](https://www.amazon.com/dp/B0CP296VXN) · UPC 656985568952 |
| Cable | 50 cm |

### The "30 W" claim

The Amazon listing describes the unit as 30 W input. **The label does not support this** — it
states 802.3af, which caps PD power at 12.95 W, and a 10 W output. The class 4 measurement in
Section 5 is the likely origin of the confusion; see Section 6.

The output load test that would have bounded the real number was run and delivered nothing —
the DUT was damaged. See Section 7. Unresolved, and not worth resolving.
