# EE463 Hardware Project — 60 W Synchronous Buck Converter

Group repo: NoCountryforRipple · Folder owner: Aykut

## Specification (from the project brief)

| Parameter | Requirement |
|---|---|
| Input | 20–48 V DC, single source (all auxiliary supplies derived from VIN) |
| Output | 12 V ±2 % (11.76–12.24 V), ripple ≤ 120 mV p-p |
| Rated load | 5 A / 60 W, resistive 2.4 Ω |
| Overload bonus | 7.5 A / 90 W, 1.6 Ω |
| Control | Closed-loop output voltage regulation |
| Demo | ≥ 5 min continuous at rated load |

## Course constraints (from the course assistant)

- Component budget: 100 USD per group, listed on the sponsorship sheet (part no., Digi-Key/Mouser link, Turkish supplier link, quantity, price). Parts can be changed until the PCB production day.
- Avoid Israel-made components (e.g. Vishay and its brands: Siliconix, Dale, Sprague, Vitramon, BCcomponents; Recom). Shipping them to Turkey is largely restricted.
- PCB: max 200 × 200 mm, up to 4 layers. Sponsorship covers the PCB only, with no stencil.
- Assembly by the team: lab reflow oven plus solder paste dispenser. Use 0805 or larger; 0603 only for a few parts if needed; no 0402.
- Connectors: pluggable 5.08 mm terminal blocks ("klemens") are suggested.
- Lab supply: 30 V / 6 A (parallel) or 60 V / 3 A (series).

- Sourcing: the sponsorship sheet's main column is the Digi-Key/Mouser link; a Turkish supplier link is optional ("if available"). Mouser Türkiye ships free over €60, and duties are paid on delivery.

## Deadlines (updated 2026-11-21)

| Deliverable | Date |
|---|---|
| Pre-report (design and simulation) | 22 Nov 2026 |
| Feedback presentation | 25 Nov 2026 |
| PCB files for sponsored production | 30 Nov 2026 |
| Hardware demo | 4 Jan 2027 |

## Decision log

| Date | Decision | Reason |
|---|---|---|
| 2026-11-21 | Topology: synchronous buck | The low-side MOSFET replaces the Schottky diode. This saves about 1–2 W, or about 2 %-points of average efficiency, worth about 2 efficiency-bonus points. See `calc/sync_vs_async.m`. |
| 2026-11-21 | Control: analog synchronous-buck controller IC with built-in gate drivers, powered from VIN | Meets the single-source rule without an extra supply, gives the highest efficiency and has built-in protection. Candidates are being compared. |
| 2026-11-21 | Bonuses targeted: current limit, reverse polarity, efficiency | Overload: still to be decided (proposal: size the parts for 7.5 A). |
| 2026-11-21 | KiCad files generated with KiCad 7 tools; the user has KiCad 10 | KiCad 10 opens the files. Final DRC and Gerber export will be done in KiCad 10. |
| 2026-11-21 | Bonuses: efficiency, reverse polarity, current limit. No battery charging or compactness bonus. Overload probably not demoed, but the power stage is rated for 7.5 A. | Rating for 7.5 A costs little and keeps the overload option open after the PCB is made. |
| 2026-11-21 | Both add-ons are optional | Reverse polarity: the FET has a 0 Ω bypass footprint. Current limit: its circuit can be left unpopulated without affecting the converter. |
| 2026-11-21 | Controller: ADI LTC7801EFE#PBF (150 V, peak current mode, TSSOP-24 with exposed pad) | Large input-voltage margin. EXTVCC lets the gate drive run from the 12 V output, which helps efficiency. Leaded package that can be soldered without a stencil. LTspice model available. |
| 2026-11-21 | MOSFETs: Infineon BSC117N08NS5 for both high side and low side (80 V, 11.7 mΩ, SuperSO8) | At 5 A the small, fast MOSFET beats a 4 mΩ low-side part (BSC040N08NS5): 97.29 % vs 97.19 % average efficiency. See `calc/design_calc.m`. |
| 2026-11-21 | fsw = 200 kHz, L = 22 µH Würth 74435582200 (7 mΩ, Isat 18 A), Rsense = 6 mΩ | Best efficiency/ripple trade-off: 41 % ripple at 48 V. The calculated average efficiency is 97.3 %. |
| 2026-11-21 | Reverse polarity: low-side N-MOSFET BSC040N08NS5 with a 12 V Zener gate clamp | Loss is 20–40 mW. The Vin− terminal is offset from circuit ground by only about I·R (≈15 mV). |
| 2026-11-21 | Current limit: INA180A1 on the shared Rsense, plus an LM2904B integrator that injects current into VFB. The limit is set to 5.5 A (one resistor change for 8 A). | The built-in limit is a peak-current limit of 11–14 A, with about 5.5 A in a dead short (foldback). The add-on gives a precise constant-current limit. |
| 2026-11-21 | Compensation: RC = 10 kΩ, CC = 6.8 nF, CC2 = 150 pF (crossover ≈ 10 kHz) | Phase margin ≥ 67° and gain margin ≥ 7.8 dB with the controller gain varied ×0.5…×2. See `calc/loop_gain.m`. |
| 2026-11-21 | Auxiliary circuits: DRVCC = 10 V; EXTVCC from VOUT through a 0 Ω link; UVLO 17.0/15.9 V; OVLO 55.6 V; CSS = 22 nF; RFREQ = 37.4 kΩ; forced continuous mode | All supplies are derived from VIN (single source). The 0 Ω link is a fallback against overshoot at the EXTVCC pin. |
| 2026-11-21 | Simulations confirm the design (ngspice, behavioural controller) | Output 12.000 V at 20/24/36/48 V; ripple 12–24 mV; load step ±0.22 V; current limit 5.53 A with the add-on; reverse polarity blocks the input. |
| 2026-11-22 | LTspice with ADI's official LTC7801 model becomes the main simulation tool | The vendor model includes the real current-sense gain, the INTVCC/DRVCC regulators, REGSD and the other protection logic, which the behavioural ngspice model did not. ngspice stays as a cross-check. |
| 2026-11-22 | RFREQ = 36.5 kΩ (was 37.4 kΩ) | The LTspice model gives 210 kHz with 37.4 kΩ and 202 kHz with 36.5 kΩ. |
| 2026-11-22 | NDRV tied to DRVCC; CPUMP_EN to INTVCC; DRVSET 100 kΩ to GND (DRVCC = 10 V) | NDRV must be tied to DRVCC when no external NDRV MOSFET is used (datasheet pin functions). CPUMP_EN as in ADI's reference design. A DRVSET resistor (DRVCC ≈ R/10 kΩ volts) matches the simulation and lets the gate-drive voltage be changed with one part. |
| 2026-11-22 | Controller gain measured: 12.5 A/V from ITH to inductor current (estimate was 7.14 A/V) | Inside the ±2× range already analysed: fc ≈ 17.5 kHz, PM 79°/74°, GM 9.0/14.5 dB at 20/48 V. Compensation unchanged. |
| 2026-11-22 | Without the add-on, a hard short causes hiccup (REGSD), not a latch or an overshoot | With EXTVCC below its switchover (≈7.5 V) and SS above 2.2 V, the controller shuts down, discharges SS and restarts. Average short-circuit current is about 2.5 A, and recovery is a normal soft start (max 12.06 V). |
| 2026-11-22 | Current-limit add-on: R_SS = 330 kΩ from SS to INTVCC | Without it, REGSD would end constant-current operation about 3 ms into an overload with Vout below 7.5 V. With it, the limit holds at 5.53 A down to a dead short at both 24 V and 48 V. Fitted only with the add-on. |
| 2026-11-22 | Current-limit integrator: R2 = 10 kΩ, C2 = 10 nF on the non-inverting input (was 1 kΩ), matching Ri·Ci = 100 µs | With 1 kΩ the stage also passed the sense signal through at unity gain, which oscillated at 23 kHz in current limit (the averages still looked right). With matched time constants it is a pure differential integrator: no oscillation at 1.6 Ω, 0.5 Ω or a short. |
| 2026-11-22 | KiCad project created: one-sheet schematic and a 4-layer, 78 × 62 mm PCB with every part on top (see `kicad/README.md`) | KiCad's exported netlist was checked pin by pin against the intended netlist. KiCad 7 DRC: no clearance errors, no unconnected items. |
| 2026-11-22 | Input ceramics: 6 × 2.2 µF / 100 V instead of 4 | With 4, the 100 µF electrolytic would carry about 0.7 A RMS (rated 0.4 A) and lose about 0.15 W. With 6, that drops to about 0.5 A and 0.07 W. Cost about 1 USD. |
| 2026-11-22 | TLV431 uses a project symbol (`NCFR:TLV431_DBZ`: 1 = REF, 2 = K, 3 = A) | KiCad's `TL431DBZ` symbol numbers its pins 1 = K, 2 = REF, which is wrong for the TLV431 in SOT-23 (DBZ). |
| 2026-11-22 | INA180 supply taken from the TLV431 rail through R20 = 100 Ω, with its 100 nF bypass after R20 | TI only guarantees TLV431 stability with no load capacitor. The resistor isolates the bypass capacitor from the shunt regulator. |
| 2026-11-22 | Layout options: 0 Ω gate resistors R2/R3, snubber footprint R4/C13 (DNP), external boost diode D3 (DNP), EXTVCC fallback R11 (DNP) | Switching speed, ringing and bias supply can be tuned on the bench without a new board. |
| 2026-11-22 | Removed the feed-forward capacitor footprint and the ITH/FB test points | They added copper stubs to high-impedance nodes. ITH and FB can be probed at C21 and R9. |
| 2026-11-22 | Snubber starting values 2.2 Ω (1206) + 330 pF C0G 100 V (KEMET C0805C331J1GACTU), still not fitted by default | The planned 1 nF would put C·Vin²·fsw ≈ 0.46 W into R4 at 48 V, above the 1206 rating (0.25 W). With 330 pF it is about 0.15 W. |
| 2026-11-22 | Gate drive re-routed: R2 directly above the driver pins, R3 on the direct line to Q2, D3 (not fitted) moved above the controller, TP4/TP5 next to R2/R3 | Controller pin to gate: TG about 34 → 29 mm (straight line 22 mm), BG 28 → 21 mm. The TG track runs next to its SW return. DRC still clean. |
| 2026-11-22 | C16 (DRVCC) and C15 (VIN) moved next to U1: about 4 mm of track to their pins (were about 10 mm and 7.6 mm) | The DRVCC capacitor supplies the gate-driver current pulses and the datasheet asks for it right at the pin. VIN, EXTVCC, RUN and OVLO re-routed; DRC clean. |
| 2026-11-22 | Parts stocked at Özdisan used where an equivalent exists: Q3 BSC030N08NS5 (3 mΩ, was BSC040N08NS5), Samsung CL32B226KAJNNNE / CL31B106KAHNNNE / CL21B104KCFNNNE / CL21B104KBCNNNC ceramics, Panjit 1N4148W | Same footprints and equal or better ratings; local stock checked on ozdisan.com. The BOM's Özdisan column lists the status of every line. |
| 2026-11-22 | Parts that were end-of-life, not recommended for new designs or out of stock at both Digi-Key and Mouser replaced (Murata 1210/0805 ceramics → Yageo/KEMET/Samsung, BZT52C12-7-F → BZT52B12-HF, BAT46W-7-F → BAT46ZFILM, INA180A1IDBVR → INA180A1IDBVT); BOM now lists Mouser/Digi-Key stock and the Özdisan part and stock for every line | Every line was checked on the distributor pages on 22 Nov. Same footprints, values and ratings; only L1 is waiting for stock (due 11 Dec), so it should be ordered first. |

## Folder layout

- `calc/`: analytical calculations (MATLAB `.m`, tested in GNU Octave; `*_output.txt` holds the printed results)
- `sim/`: simulations. `sim/ltspice/` holds the main LTspice files (ADI's LTC7801 model); the top level holds the earlier ngspice cross-check netlists (see sim/README.md)
- `kicad/`: KiCad project (schematic, 4-layer PCB, project libraries, BOM); see kicad/README.md
- `docs/`: pre-report (Word + PDF preview) and its figures
