# KiCad project: 60 W synchronous buck (LTC7801)

Open `NoCountryforRipple_Buck.kicad_pro` in KiCad 10. The files were generated with KiCad 7.0 tools, and KiCad 10 upgrades them when you save.

| File | Content |
|---|---|
| `NoCountryforRipple_Buck.kicad_sch` | Schematic (one A3 sheet): input + add-on 1, power stage, controller, add-on 2 |
| `NoCountryforRipple_Buck.kicad_pcb` | 4-layer PCB, 78 × 62 mm, fully routed |
| `lib/NCFR.kicad_sym` | Project symbols: `LTC7801` and `TLV431_DBZ` |
| `lib/NCFR.pretty/LTC7801_FE24_AA.kicad_mod` | LTC7801 TSSOP-24 footprint with exposed pad (FE24 AA: EP 2.74 × 3.25 mm, 6 thermal vias) |
| `bom/BOM_NoCountryforRipple_Buck.csv` | BOM grouped by MPN, with fit status and Digi-Key/Mouser search links |
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

## What has been verified
- **Schematic ↔ intended design:** KiCad's exported netlist was compared pin by pin with the intended netlist (191 pins, no differences). The intended netlist was reviewed net by net against the design.
- **Pinouts checked against datasheets:**
  - LTC7801 FE24: pin table; exposed pad = GND.
  - INA180A1 (pinout A): OUT 1, GND 2, IN+ 3, IN− 4, VS 5.
  - TLV431 DBZ: 1 REF, 2 K, 3 A (custom symbol).
  - BSC117N08NS5 / BSC040N08NS5 (TDSON-8): 1–3 S, 4 G, 5 D.
  - Electrolytic polarity on C1 and C10.
- **Board ↔ schematic:** every footprint is linked to its symbol, and all pad nets match the netlist (no differences).
- **DRC (KiCad 7.0.11):** no clearance errors, no unconnected items.
- **Copper continuity:** the VIN, VIN_N, SW, SNSP and VOUT copper each fill as one island. In1, In2 and B.Cu GND are each one island.
- **Kelvin sensing:** the sense traces from inside the R5 pads connect only to R6/R7 and U2. No other VOUT/SNSP copper touches them, so no load current flows in the sense lines.
- **Cost:** about 48 USD for one fully populated board at single-unit prices (Base 41, add-on 1 4, add-on 2 3); see the BOM totals.

## Known points to improve or check interactively
- **Gate drive and ringing:** the gate paths were shortened on 22 Nov (TG about 34 → 29 mm, BG 28 → 21 mm). If the switch node rings too much on the bench (TP3, 48 V, full load), first increase R2/R3 to 2.2–4.7 Ω, then fit the R4/C13 snubber (2.2 Ω, 330 pF C0G; R4 dissipates about 0.15 W at 48 V).
- **DRVCC capacitor C16** is about 10 mm of track from U1 pin 17. The datasheet asks for it right next to the pin, because it supplies the gate-driver current pulses. Moving it closer means rearranging the capacitor column left of U1 (C15–C18, C22); this is the next layout improvement before the 30 Nov submission.
- **Silkscreen:** every label is placed clear of pads and other labels. Five small parts next to the controller (C19, C20, C21, C28, R19) had no free space for a label, so their labels are hidden on the board; `docs/assembly_top.pdf` shows all references.
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
