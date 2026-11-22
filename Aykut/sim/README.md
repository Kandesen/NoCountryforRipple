# Simulations

## Main: LTspice with ADI's LTC7801 model (`ltspice/`)

Open the files with LTspice 24 or later. The LTC7801 symbol and model ship with LTspice, so nothing needs to be installed.

**Names match the board.** Every component in the schematics uses the KiCad reference designator (Q1, Q2, L1, R5, C10, R8/R9, R12–R14, R16/C20/C21 and so on), with three lumped parts: `C2_12` = C2–C5, C11, C12 (6 × 2.2 µF, about 6 µF at DC bias), `C6_9` = C6–C9 (4 × 22 µF, about 40 µF at 12 V) and, in step 1, `SQ1`/`SQ2` = Q1/Q2 as ideal switches. The closed-loop schematic started from ADI's LTC7801 demo circuit and was then changed to match the board: RUN/OVLO divider R12–R13–R14 (the demo tied RUN to VIN), the 10 Ω sense filter R6/R7 with C24, the input capacitors, DRVCC capacitor C16 = 10 µF, and the demo's unused NDRV MOSFET wiring removed.

| File | What it simulates | Main results (22 Nov 2026 runs) |
|---|---|---|
| `01_powerstage_ideal.asc` (`.cir`: same circuit as a netlist) | Step 1: ideal switches at a fixed duty cycle, 20/24/36/48 V | ΔiL 1.09–2.06 A, peak 5.55–6.03 A, ripple 13.0–24.7 mV (matches `calc/design_calc.m`) |
| `closed_loop.asc` | Step 2: full closed loop with BSC117N08NS5 models; soft start, then a 5 A → 2.5 A → 5 A load step at 20/24/36/48 V | 11.996 V, ripple 13.2–24.6 mV, step +194/−184 mV worst case, start-up overshoot ≤ 68 mV, fsw 202 kHz |
| `current_limit.asc` | Load sequence 2.4 Ω → 1.6 Ω → 0.5 Ω → short → 2.4 Ω at 24 V; steps `CCLOOP = 0` (add-on not fitted) and `1` (fitted) | With the add-on: 5.53–5.54 A from 1.6 Ω down to a dead short (also at 48 V), then recovery to 12.00 V, max 12.007 V |
| `hiccup_no_addon.asc` | Base converter only: 1.6 Ω overload, a 14 ms short, then 2.4 Ω, at 24 V | 7.50 A at 1.6 Ω in regulation; hiccup in the short (2.54 A average, 15.3 A peak); soft-start recovery, max 12.06 V |
| `04_reverse_polarity.asc` (`.cir`: same circuit) | Reverse-polarity MOSFET Q3 (BSC030N08NS5) at +48, −48, +20 and −20 V | VDS −4.1 mV at +48 V and −1.7 mV at +20 V, VGS 11.9 V; input blocked when reversed |

To change the input voltage, edit the `.step param Vin` line (or `.param Vin` in `current_limit.asc` and `hiccup_no_addon.asc`).
The closed-loop `.asc` files save every node, so the waveform files are large (up to about 1 GB per run). Add a line such as `.save V(out) I(L1) V(SW)` if disk space is short.

The optional current-limit add-on is a SPICE subcircuit (`CCLIMIT`) in the schematic text, with the board designators: U2 INA180A1 (gain 20), the R21/C25 + R22/C26 differential integrator around U3 (LM2904B), D2 (1N4148W) and R23 (22 kΩ) into VFB, the set point from R27/R28, and R15 (330 kΩ, SS to INTVCC). `CCLOOP = 0` removes all of them.

## Cross-check: ngspice 42 (top level)

Written before the LTspice model was available. The controller is behavioural (simplified LTC7801), so these files are only a cross-check. They use the analysis names from the report (RB/RA = R8/R9, Rc/Cc/Cc2 = R16/C20/C21, Rsen = R5; in `03_current_limit.cir` Rinf/Cinf/Ri/Ci = R21/C25/R22/C26 and Rinj = R23).

| File | What it simulates |
|---|---|
| `01_powerstage_ideal.cir` | Ideal switches, fixed duty cycle |
| `02_closed_loop.cir` | Closed loop with a behavioural LTC7801 model |
| `03_current_limit.cir` | Current-limit add-on with the same load sequence (`CCLOOP = 0/1`) |
| `04_reverse_polarity.cir` | Reverse-polarity MOSFET (Q3 BSC030N08NS5, same values as the LTspice file) |
| `run_0x.sh` | Linux scripts that run each netlist and print the measurements |

`03_current_limit.cir` (with the corrected 10 kΩ integrator resistor) gives 5.53 A at 1.6 Ω and 0.5 Ω, like LTspice. In a dead short it shows a 1 kHz limit cycle around 4 A average, because the behavioural ITH pin can swing below 0 V (the real pin is clamped). The official model holds 5.53 A there. Trust the LTspice result, and check the short on the bench.

Assumptions in the behavioural controller model: ITH 0.45 V ↔ 0 mV sense, 2.2 V ↔ 75 mV; slope compensation 50 % of the inductor down-slope. The official model has a higher ITH-to-current gain, about 12.5 A/V. The loop analysis in `calc/loop_gain.m` covers ×0.5 to ×2 of the estimate, which includes the measured value.
