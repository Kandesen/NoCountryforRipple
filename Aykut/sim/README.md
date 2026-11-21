# Simulations

## Main: LTspice with ADI's LTC7801 model (`ltspice/`)

Open the files with LTspice 24 or later. The LTC7801 symbol and model ship with LTspice, so nothing needs to be installed. The schematics start from ADI's LTC7801 demo circuit, with our component values.

| File | What it simulates | Main results |
|---|---|---|
| `01_powerstage_ideal.cir` | Step 1: ideal switches at a fixed duty cycle, 20/24/36/48 V | ΔiL 1.09–2.06 A, peak 5.54–6.03 A, ripple 13–25 mV (matches `calc/design_calc.m`) |
| `closed_loop.asc` | Step 2: full closed loop with BSC117N08NS5 models; soft start, then a 5 A → 2.5 A → 5 A load step at 20/24/36/48 V | 11.996 V, ripple 14–24 mV, step +189/−187 mV worst case, fsw 202 kHz |
| `current_limit.asc` | Load sequence 2.4 Ω → 1.6 Ω → 0.5 Ω → short → 2.4 Ω at 24 V; steps `CCLOOP = 0` (add-on not fitted) and `1` (fitted) | With the add-on: 5.53 A from 1.6 Ω down to a dead short, then recovery to 12.00 V without overshoot |
| `hiccup_no_addon.asc` | Base converter only: 1.6 Ω overload, a 14 ms short, then 2.4 Ω, at 24 V | 7.5 A at 1.6 Ω in regulation; hiccup in the short (≈2.5 A average); soft-start recovery, max 12.06 V |
| `04_reverse_polarity.cir` | Reverse-polarity MOSFET at +48, −48, +20 and −20 V | Vds −7 mV at +48 V (≈9 mW), input blocked at −48 V |

To change the input voltage, edit the `.step param Vin` line (or `.param Vin` in `current_limit.asc` and `hiccup_no_addon.asc`).
The `.asc` files save every node, so the waveform files are large (up to about 1 GB per run). Add a line such as `.save V(out) I(L1) V(SW)` if disk space is short.

The optional current-limit add-on is drawn as a SPICE subcircuit (`CCLIMIT`) in the schematic text: INA180A1 (gain 20), the R2/C2 + Ri/Ci differential integrator around the LM2904B, the 1N4148W and the 22 kΩ injection resistor into VFB, and R_SS (330 kΩ, SS to INTVCC). `CCLOOP = 0` removes all of them.

## Cross-check: ngspice 42 (top level)

Written before the LTspice model was available. The controller is behavioural (simplified LTC7801), so these files are only a cross-check.

| File | What it simulates |
|---|---|
| `01_powerstage_ideal.cir` | Ideal switches, fixed duty cycle |
| `02_closed_loop.cir` | Closed loop with a behavioural LTC7801 model |
| `03_current_limit.cir` | Current-limit add-on with the same load sequence (`CCLOOP = 0/1`) |
| `04_reverse_polarity.cir` | Reverse-polarity MOSFET |
| `run_0x.sh` | Linux scripts that run each netlist and print the measurements |

`03_current_limit.cir` (with the corrected 10 kΩ integrator resistor) gives 5.53 A at 1.6 Ω and 0.5 Ω, like LTspice. In a dead short it shows a 1 kHz limit cycle around 4 A average, because the behavioural ITH pin can swing below 0 V (the real pin is clamped). The official model holds 5.53 A there. Trust the LTspice result, and check the short on the bench.

Assumptions in the behavioural controller model: ITH 0.45 V ↔ 0 mV sense, 2.2 V ↔ 75 mV; slope compensation 50 % of the inductor down-slope. The official model has a higher ITH-to-current gain, about 12.5 A/V. The loop analysis in `calc/loop_gain.m` covers ×0.5 to ×2 of the estimate, which includes the measured value.
