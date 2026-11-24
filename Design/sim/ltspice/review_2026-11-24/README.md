# Review runs, 24 Nov 2026

Copies of the project simulations plus the extra cases from the design review, run in LTspice 26.1.1
from the LTspice window. Results: `RESULTS.md`; plots: `screenshots\`. Nothing outside this folder was changed.

| File | What it runs |
|---|---|
| `cl_report.asc`, `cc_report.asc`, `ideal_report.asc`, `rp_report.asc` | The report simulations unchanged (only `.save` lines added) |
| `cc_r28.asc` | Current limit with Vset computed from R28 (2.49k, 2.21k) at 24 and 48 V; loads 2.4, 1.6, 1.52, 0.5 ohm, short |
| `cc_Lnl.asc` | 48 V, add-on off/on, L1 fixed 22 uH vs datasheet L(I) curve; 2.4 -> 1.6 ohm -> short -> 2.4 ohm |
| `tr_comp.asc` | Two compensation settings (10k/6.8n/150p and 4.99k/15n/330p), load step and 24 <-> 36 V line step at 24 V |
| `hotplug2.cir` | Board plugged into a live 48 V supply, Q3 fitted, lead L 0.5-2 uH x R 20-100 mohm |
| `kicad_checks.bat` (+ `chain_kicad.bat`) | KiCad 10 kicad-cli ERC and DRC with schematic parity on a copy of `..\..\..\kicad` in `kicad_copy\` (ignored); reports in `kicad_checks\` |
