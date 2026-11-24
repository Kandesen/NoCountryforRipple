# Review results, 24 Nov 2026 (LTspice 26.1.1, KiCad 10.0.8)

All runs use copies in this folder. Plots: `screenshots\shot_*.png` (LTspice window captures) and
`*.emf` (LTspice "Write image to .emf file"; LibreOffice renders these in black and white).

## Report simulations re-run (unchanged circuits)
| Quantity | 20 V | 24 V | 36 V | 48 V |
|---|---|---|---|---|
| Vout (closed_loop) | 11.996 V | 11.996 V | 11.996 V | 11.996 V |
| Output ripple p-p | 14.8 mV | 17.6 mV | 23.2 mV | 26.2 mV |
| Load step 5 -> 2.5 A (max) | 12.189 V | 12.184 V | 12.175 V | 12.170 V |
| Load step 2.5 -> 5 A (min) | 11.813 V | 11.816 V | 11.819 V | 11.820 V |
| Start-up max | 12.062 V | 12.060 V | 12.056 V | 12.053 V |
| Simulated efficiency | 98.4 % | 98.3 % | 98.2 % | 98.0 % |

Current limit (24 V): add-on on: 7.50 A at 1.6 ohm (12.00 V), 8.26 A at 0.5 ohm (4.13 V), 8.26 A in a short; IL peak 13.7 A.
Add-on off: hiccup in the short. Reverse polarity and ideal stage match Tables 11 and 14.
(LTspice sorts `.step ... list 1 0` ascending: step 1 is CCLOOP = 0.)

## New cases
**R28 now sets Vset** (`cc_r28.asc`, 4.97 V x R28 / (10k + R28)):

| R28 | Vin | 1.6 ohm | 1.52 ohm (-5 %) | 0.5 ohm | short | IL peak |
|---|---|---|---|---|---|---|
| 2.49k | 24 V | 7.50 A / 11.995 V | 7.89 A / 11.995 V | 8.26 A | 8.26 A | 13.7 A |
| 2.49k | 48 V | 7.50 A / 11.995 V | 7.89 A / 11.995 V | 8.26 A | 8.26 A | 13.3 A |
| 2.21k | 24 V | 7.50 A / 11.995 V | 7.82 A / 11.886 V, still falling | 7.50 A | 7.50 A | 13.8 A |
| 2.21k | 48 V | 7.50 A / 11.995 V | 7.82 A / 11.886 V, still falling | 7.50 A | 7.50 A | 13.3 A |

With 2.21k the limit sits exactly at the 1.6 ohm load current; near the threshold the integrator takes
several ms to act (2.5 ms after the 1.52 ohm step Vout is still falling).

**L1 datasheet L(I) vs fixed 22 uH** (`cc_Lnl.asc`, 48 V; L = 22 / 19.8 / 17.7 / 15.4 uH at 0 / 5.5 / 15 / 18 A):

| | fixed 22 uH | datasheet L(I) |
|---|---|---|
| 1.6 ohm: IL peak / ripple | 8.54 A / 2.07 A p-p | 8.69 A / 2.35 A p-p |
| Short entry, IL peak, add-on off | 14.10 A | 14.09 A |
| Short entry, IL peak, add-on on | 13.96 A | 14.08 A |

**Hot plug, 48 V, Q3 fitted** (`hotplug2.cir`; C1 = VIN to circuit ground):

| Lead L | 20 mohm | 50 mohm | 100 mohm |
|---|---|---|---|
| 0.5 uH | 68.3 V | 56.9 V | 48.1 V |
| 1 uH | 74.0 V | 63.6 V | 53.0 V |
| 2 uH | 78.9 V | 70.0 V | 59.6 V |

Input current peak 190-443 A. C1 (A786MN826M1JLAS018): 63 V rated, 72.45 V surge.
(`hotplug.cir` is void: LTspice treats a node named `gnd` as ground, which bypassed Q3.)

**Transient bonus, 24 V** (`tr_comp.asc`; deviation of the cycle-averaged Vout, settling to +-24 mV):

| | COMP1 10k / 6.8n / 150p (design) | COMP2 4.99k / 15n / 330p |
|---|---|---|
| Load 5 -> 2.5 A | +189 mV, 125 us | +267 mV, 186 us |
| Load 2.5 -> 5 A | -180 mV, 126 us | -256 mV (11.739 V, below 11.76 V), 187 us |
| Line 24 -> 36 V | +50 mV, 28 us | +64 mV, 106 us |
| Line 36 -> 24 V | -50 mV, 52 us | -66 mV, 102 us |

## KiCad 10.0.8 (`kicad_checks\`)
- ERC: 0 errors, 3 warnings (`lib_symbol_mismatch` Q1, Q2, Q3).
- DRC: 0 unconnected items; 60 warnings, all `lib_footprint_mismatch` (footprints differ from the KiCad 10 library copies).
- Schematic parity: 174 warnings.
  - 141 `net_conflict`: name only (PCB `VIN` vs schematic `/VIN`); pads are on the right nets.
  - 17 `footprint_symbol_mismatch`: **DNP differs for C13, D3, JP1, R4, R11**; exclude-from-BOM differs for H1-H4, TP1-TP5, TP8, TP9, TP13.
  - 16 `footprint_symbol_field_mismatch` (Note field), incl. **R28: PCB "2.37k for 7.94 A" vs schematic "8.26 A limit (7.5 A target); 1.54k for 5.53 A"**.
