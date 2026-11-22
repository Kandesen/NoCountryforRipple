# KiCad project: 60 W synchronous buck (LTC7801)

Open `NoCountryforRipple_Buck.kicad_pro` in KiCad 10. The files were generated with KiCad 7.0 tools, and KiCad 10 upgrades them when you save.

| File | Content |
|---|---|
| `NoCountryforRipple_Buck.kicad_sch` | Schematic (one A3 sheet): input + add-on 1, power stage, controller, add-on 2 |
| `NoCountryforRipple_Buck.kicad_pcb` | 4-layer PCB, 78 × 62 mm, fully routed |
| `lib/NCFR.kicad_sym` | Project symbols: `LTC7801` and `TLV431_DBZ` |
| `lib/NCFR.pretty/LTC7801_FE24_AA.kicad_mod` | LTC7801 TSSOP-24 footprint with exposed pad (FE24 AA: EP 2.74 × 3.25 mm, 6 thermal vias) |
| `bom/BOM_NoCountryforRipple_Buck.csv` | BOM grouped by MPN, with fit status, supplier to order from (EKOM / Özdisan / Mouser), stock and prices at each, and Digi-Key/Mouser search links |
| `docs/` | Schematic PDF, layer plots and `assembly_top.pdf` (part outlines with every reference, A4, for hand assembly) |

## Symbol fields
Every part has `MPN`, `Manufacturer` and `Fit`. `Fit` is one of: Base, Add-on 1 (reverse polarity), Add-on 2 (current limit), or a DNP option. DNP parts carry KiCad's *Do not populate* flag.
- **Removing add-on 1:** leave Q3, R1 and D1 unpopulated and fit JP1 (a 0 Ω 2512 resistor or a wire).
- **Removing add-on 2:** leave every part in the add-on 2 box unpopulated (U2–U4, D2, R15, R20–R28, C23, C25–C28, TP13).

## Board
- **Stack-up:** F.Cu (power copper + parts), In1.Cu (solid GND), In2.Cu (signals + GND fill), B.Cu (signals + GND fill). Standard 1.6 mm, 1 oz outer layers.
- **Rules:** minimum clearance 0.2 mm, minimum track 0.2 mm, vias 0.6/0.3 mm, 0.5 mm to the board edge. Every part is on the top side; there is no stencil, so paste is applied with the dispenser.
- **Power copper (F.Cu zones):** VIN, VIN_N (reverse-polarity FET), SW, SNSP (L1 → R5) and VOUT. The six input ceramics sit on the VIN/GND boundary directly above Q1 and Q2 (hot loop about 10 × 8 mm over the solid In1 GND).
- **Current sense:** Kelvin traces from inside the R5 pads run on In2 to R6/R7 (LTC7801 SENSE± filter) and on B.Cu to U2 (INA180).
- **Gate drive:** U1 → R2/R3 (0 Ω, change to a few Ω to slow the edges) → vias next to the Q1/Q2 gate pads. R2 sits directly above the gate-driver pins and R3 on the direct line towards Q2; test points TP4 (TG) and TP5 (BG) are next to them. Controller pin to MOSFET gate: TG about 29 mm (the straight line is 22 mm, because Q1 is at the far end of the power stage), BG about 21 mm. The TG track runs on In2 next to its SW return for most of its length. D3 (optional bootstrap diode, not fitted) was moved above the controller to make room for R3.
- **DRC (KiCad 7):** no clearance errors, no unconnected items. No silkscreen overlaps. The only remaining items are "library footprint" notices that only appear because the generator did not have your library paths.

## Sourcing
- **Supplier order:** e-komponent.com (EKOM, Digi-Key's distributor in Turkey) and Özdisan first; Digi-Key or Mouser (mouser.com.tr) only for parts neither of them stocks. Rule per BOM line: the exact part at EKOM → EKOM; otherwise the exact part at Özdisan → Özdisan; otherwise an equivalent (same footprint, pinout and rating) at EKOM/Özdisan; otherwise Mouser/Digi-Key. The BOM's "Order from / Order part" columns apply this; the EKOM, Özdisan and Mouser/Digi-Key columns list what each one had on **22 Nov 2026**.
- **EKOM:** most of its stock is Digi-Key stock shipped from abroad (7–10 working days, estimated dispatch 1–7 Dec 2026); the price includes shipping and customs. Only R25 (RC0805FR-0730K1L) was in stock in Turkey (1–3 days). Prices in the BOM are EKOM's 1-piece USD price without the 20 % VAT (the TL price on the site includes VAT).
- **What the BOM orders:** every part, including the ones not fitted by default (D3, JP1, R4, C13, R11), plus a limited set of spares that keeps the order under the 100 USD budget. "Qty per board" is the fitted quantity, "Spares" the extra pieces and "Qty to order" their sum.
- **Spares and why:** one LTC7801 (hardest part to hand-solder without a stencil, longest lead time); one BSC117N08NS5 (Q1/Q2 are the most likely to fail during bring-up); one LM2904B and one 1N4148W (cheap); one of every 0805 resistor and capacitor in a fitted position, once per part number (easily lost when hand-soldering). No spares for L1, R5, the 1206/1210 capacitors, C1, C10, Q3, U2, U4 or the parts not fitted by default.
- **Cost of the order (single-unit prices, USD excl. VAT):** base 61.6, add-on 1 4.1, add-on 2 5.5, parts not fitted by default 1.7, spares 21.6, total about 94.5. By supplier: EKOM 61.2, Özdisan 2.2 (estimated with Mouser prices; Royalohm resistors are sold in 100s), Mouser 31.2. Quantity breaks make the real total a little lower, but EKOM's USD prices follow the exchange rate, so recheck the total on the order day.
- **Equivalents ordered instead of the design part** (same footprint and pinout):
  - C10: KEMET A768EB107M1ELAS036 (100 µF 25 V polymer, 6.3 mm can, 36 mΩ, AEC-Q200) instead of Panasonic EEH-ZA1E101XP (not listed).
  - C15: KEMET C0805C104K1RACTU; C20: KEMET C0805C682K5RACTU (the Yageo parts are not listed).
  - U2: INA180A1IDBVT (same IC, industrial grade). U4: TLV431BCDBZR (0–70 °C grade, same accuracy and pinout). D1: Taiwan Semiconductor BZT52C12-G RHG (12 V, 5 %, SOD-123).
  - J1/J2 plug: Phoenix 1765551 (MSTB 2,5/2-ST-5,08 AU, same series as the 1757019, which EKOM only quotes). The header 1757242 is stocked.
  - From Özdisan: Royalohm 0805S8F2372T5E for R14 (23.7 kΩ), sold in 100s.
- **From Mouser (mouser.com.tr):** U1 LTC7801EFE#PBF × 2 (EKOM lists only the LTC7801IFE#PBF, on request; Mouser Türkiye had 1,587), R12 1.02 MΩ, D3 BAT46ZFILM (no BAT46 in stock at EKOM) and JP1 CRF2512-J/-000ELF.
- **L1 (Würth 74435582200):** EKOM 101 (Digi-Key stock), 9.18 USD; Mouser 0 (3,543 due 11 Dec 2026). Order it first.
- **Parts not fitted by default** are ordered too: R4 (EKOM Yageo RC1206JR-072R2L, 5 %), C13 and R11 (EKOM), D3 and JP1 (Mouser). EKOM's Bourns CRF2512-JZ-R005ELF (5 mΩ metal strip) would also work for JP1 (48 mW at 3.1 A).
- Earlier swaps re-checked at EKOM: Murata GRM32ER72A225KA35L, Samsung CL32B226KAJNNNE / CL31B106KAHNNNE / CL21B104KCFNNNE and BAT46W-7-F are out of stock there; Yageo RC2512JK-070RL is stocked but rated 2 A (too low for JP1); INA180B1IDBVR is stocked but has the other pinout. None of the earlier swaps needs to be undone.

## What has been verified
- **Schematic ↔ intended design:** KiCad's exported netlist was compared pin by pin with the intended netlist (191 pins, no differences). The intended netlist was reviewed net by net against the design.
- **Pinouts checked against datasheets:**
  - LTC7801 FE24: pin table; exposed pad = GND.
  - INA180A1 (pinout A): OUT 1, GND 2, IN+ 3, IN− 4, VS 5.
  - TLV431 DBZ: 1 REF, 2 K, 3 A (custom symbol).
  - BSC117N08NS5 / BSC030N08NS5 (TDSON-8): 1–3 S, 4 G, 5 D.
  - Polarity of the polymer capacitors C1 and C10.
- **Simulation ↔ schematic:** the LTspice files in `sim/ltspice/` use the same reference designators and values as this schematic (lumped parts: C2_12 = C2–C5, C11, C12; C6_9 = C6–C9). The report figures and the BOM notes use the same names; RB/RA/RS/RC/CC/CC2 in the report's equations are R8/R9/R5/R16/C20/C21.
- **Board ↔ schematic:** every footprint is linked to its symbol, and all pad nets match the netlist (no differences).
- **DRC (KiCad 7.0.11):** no clearance errors, no unconnected items.
- **Copper continuity:** the VIN, VIN_N, SW, SNSP and VOUT copper each fill as one island. In1, In2 and B.Cu GND are each one island.
- **Kelvin sensing:** the sense traces from inside the R5 pads connect only to R6/R7 and U2. No other VOUT/SNSP copper touches them, so no load current flows in the sense lines.
- **Cost:** about 71 USD (excl. VAT) for one fully populated board (base 61.6, add-on 1 4.1, add-on 2 5.5); about 94.5 USD for the whole order with the parts not fitted by default and the spares. See the BOM totals.

## Known points to improve or check interactively
- **Gate drive and ringing:** the gate paths were shortened on 22 Nov (TG about 34 → 29 mm, BG 28 → 21 mm). If the switch node rings too much on the bench (TP3, 48 V, full load), first increase R2/R3 to 2.2–4.7 Ω, then fit the R4/C13 snubber (2.2 Ω, 330 pF C0G; R4 dissipates about 0.15 W at 48 V).
- **Decoupling at U1:** C16 (DRVCC, 10 µF) now sits left of the controller with about 4 mm of track to pins 17/18 (was about 10 mm), and C15 (VIN, 100 nF) about 4 mm from pin 19 (was 7.6 mm). Moved on 22 Nov; DRC clean.
- **Silkscreen:** every label is placed clear of pads and other labels. Six small parts next to the controller (C15, C19, C20, C21, C28, R19) had no free space for a label, so their labels are hidden on the board; `docs/assembly_top.pdf` shows all references.
- **Vias in the R5 pads:** the Kelvin vias sit inside R5's pads, so a little solder may wick into them. Use enough paste on R5.

## Before ordering (in KiCad 10)
1. Run ERC on the schematic. KiCad 7's command line has no ERC, so connectivity was checked instead by comparing the exported netlist pin by pin with the intended netlist.
2. Run *Tools → Update PCB from Schematic*. Nothing should change, because the footprints are linked to their symbols.
3. Refill zones (B), run DRC, and look at the 3D view.
4. Check the LTC7801 footprint against the datasheet's FE24(AA) drawing (exposed-pad size), and that the 5.08 mm header faces outward.
5. Ask the PCB manufacturer for its 4-layer stack-up and minimum rules (most allow 0.15 mm / 0.3 mm drill), then plot the Gerbers and drill files.

## Report names → KiCad designators
| Report | KiCad | | Report | KiCad |
|---|---|---|---|---|
| R_S (6 mΩ sense) | R5 | | R_SS (330 k) | R15 |
| R_A / R_B (feedback) | R9 / R8 | | R_inj (22 k) | R23 |
| R_C / C_C / C_C2 (ITH) | R16 / C20 / C21 | | R_i / C_i (integrator) | R22 / C26 |
| C_SS | C19 | | R_2 / C_2 (integrator input) | R21 / C25 |
| R_FREQ / R_DRVSET | R17 / R18 | | UVLO divider | R12, R13, R14 |
| Input ceramics | C2–C5, C11, C12 | | Output ceramics / polymer | C6–C9 / C10 |
