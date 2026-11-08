# EE463 Hardware Project — Project Roadmap

**Team:** 3 members  
**Plan date:** 8 November 2026  
**Goal:** Meet the core project requirements and pursue every technical bonus except the topology bonus. Also contribute useful technical support to other groups toward the individual Karma bonus.

> This is a working plan, not a completed design or a record of test results. Component candidates and preliminary values will be finalized after simulation, availability checks, and hardware verification. Current course announcements and the [official project specification](https://github.com/odtu/EE463/blob/master/Hardware%20Project/EE463%20Hardware%20Project.md) take precedence. Task allocation will be agreed separately by the team.

## 1. Quick Overview: What Are We Going to Do?

1. **Confirm the scope and deliverables.** Document the requirements, open questions, and measurable outcomes for each stage.
2. **Start with a single-phase synchronous buck converter.** Compare suitable alternatives and explain the selection in the report. The topology bonus is outside our target scope.
3. **Size the power stage for 90 W from the beginning.** Normal operation is 12 V at 5 A; the overload target is 12 V at 7.5 A.
4. **Design voltage and current regulation together.** A CC/CV structure will support both output current limiting and battery charging.
5. **Check controller and critical component availability early.** Stock, lead time, package, and assembly requirements will influence the design.
6. **Move from calculations to a simple simulation, then to a realistic model.** Investigate the input range, load changes, startup, and protection behavior.
7. **Prepare the schematic and initial PCB layout.** Include auxiliary supplies, protection circuits, test points, and enclosure constraints in the first design.
8. **Complete the preliminary report and feedback presentation.** Submit the report on 15 November, incorporate feedback, and prepare PCB files for 25 November.
9. **Bring up the board in stages.** Auxiliary supplies → gate drivers → low power → 60 W → 90 W → protection and charging tests.
10. **Demonstrate the bonuses with measurements.** Keep consistent records for efficiency, two controller settings, protection behavior, and enclosed operation.

**Main approach:** Plan all features in the first schematic, then verify the hardware progressively.

### Tasks for the First 24 Hours

- [ ] Confirm the design targets and list unresolved technical questions.
- [ ] Review the three roles and the dependencies between them; agree on individual assignments separately.
- [ ] Create the repository structure and initial task list.
- [ ] Prepare an availability table for controller, MOSFET, and inductor candidates.
- [ ] Confirm the supported PCB layer count, copper thickness, and manufacturing rules.
- [ ] Build the basic buck simulation at 24 V input and check the power stage.
- [ ] Track the pending battery requirements, common test procedure, and bonus details.

## 2. Roles, Responsibilities, and Working Principles

The project is divided into three roles. **All roles are currently unassigned; the team will decide who takes each role.** Responsibilities can be shared or adjusted as the work progresses.

| Role | Main responsibilities | Expected deliverables |
|---|---|---|
| **Role A — Simulation, Control, and System Integration** | System modeling; CC/CV control; compensation design; comparison of two controller settings; test planning; integration of calculations and results; progress tracking | Reproducible simulation models, control calculations, transient comparisons, test procedures, and a consolidated results table |
| **Role B — Power Stage, Protection, and Procurement** | Power-stage calculations; MOSFET, inductor, capacitor, and sensing selection; auxiliary supplies; current-limit and reverse-polarity circuits; loss and thermal estimates; component availability | Power-stage and protection schematics, component stress and loss tables, BOM, alternative parts, and procurement information |
| **Role C — PCB, Enclosure, and Manufacturing** | Complete schematic integration; PCB placement and routing; footprints and connectors; test-point access; enclosure and mounting; manufacturing-file preparation; assembly planning | Complete schematic and PCB sources, checked Gerber/drill files, enclosure drawings, mechanical fit checks, and an assembly plan |

### Coordination Between Roles

- **Control and power stage:** Agree on the switching frequency, sensing method, current limits, startup behavior, and component assumptions before finalizing the schematic.
- **Power stage and PCB:** Confirm packages, footprints, current paths, cooling needs, and available alternatives before committing the layout.
- **PCB and control:** Keep feedback, sensing, compensation, and measurement connections accessible and consistent with the control design.

**Shared work:** Architecture decisions, design reviews, assembly and bring-up, hardware measurements, demo preparation, and final report/presentation review. Each role prepares the documentation for its work, and the team checks the combined results. All members should understand the overall converter and support testing and troubleshooting.

### Working Principles

- Record important design choices and the reasons behind them.
- Define each task by its expected output, target date, dependencies, and acceptance criteria.
- Treat a task as complete when its output is in the repository and has been reviewed.
- Review the schematic, PCB, and component limits together before manufacturing.
- Ensure every team member can explain the overall converter operation and the main design choices.
- Keep calculations, simulations, and hardware measurements clearly distinguished.

## 3. Schedule and Deliverables

| Date | Type | Expected output |
|---|---|---|
| 8–9 November | Internal target | Architecture, component candidates, availability checks, and manufacturing constraints |
| 10–11 November | Internal target | Preliminary calculations, power-stage simulation, and closed-loop simulation |
| 12–13 November | Internal target | Preliminary schematic, bill of materials (BOM), initial PCB layout, and report draft |
| **15 November 2026** | **Official deadline** | **Preliminary report: design and simulation** |
| **16–20 November 2026** | **Official presentation window** | **Design presentation and feedback; individual slots will be announced separately** |
| 21–24 November | Internal target | Revisions, schematic/PCB review, and manufacturing-file checks |
| **25 November 2026** | **Official deadline** | **PCB files for sponsored production** |
| December | Internal target, subject to board and component delivery | Assembly, staged bring-up, nominal operation, bonus tests, and enclosure integration |
| Late December | Internal target | Demo rehearsal, remaining measurements, and file cleanup |
| **4 January 2027** | **Official demonstration** | **Working hardware and supporting measurements** |
| To be announced | Official deadline | Final report |

The group must cover the cost of new or revised PCBs produced after the sponsored round. The first board should therefore include the necessary circuits and practical adjustment options.

## 4. Design Targets

| Item | Official requirement or team target |
|---|---|
| Input | 20–48 V DC |
| Nominal operation | 12 V, 5 A, 60 W; nominal 2.4 Ω resistive load |
| Overload target | 12 V, 7.5 A, 90 W; nominal 1.6 Ω resistive load |
| Steady-state output voltage | 11.76–12.24 V |
| Steady-state ripple limit | Maximum 120 mV peak-to-peak |
| Internal ripple target | Approximately below 60 mV peak-to-peak in preliminary calculations/simulation, leaving margin for hardware effects |
| Output current limiting | Target of 7.5 A because the overload bonus is included; verify tolerances and transition behavior |
| Control | Closed-loop regulation; CV in normal operation and CC when required |
| Power source | One main input supplying the controller, drivers, sensors, and any fan |
| Implementation | Our own PCB; a complete enclosed system for the compactness bonus |
| Minimum demonstration | At least 5 minutes at rated resistive load; the enclosed system must also meet the requirements |
| Efficiency target | Average efficiency of 93–95% across the four specified input points at 60 W; a design target, not a measured result |

The nominal resistor value alone does not prove the delivered power. Record the actual output voltage and current, and calculate **Pout = Vout × Iout** for every operating point.

Battery charging voltage and current will be configured separately once the battery is announced. A 7.5 A charging current is not appropriate for every battery. Charging settings must satisfy the battery limits and the converter power capability. A buck implementation is suitable only if the required charging voltage stays sufficiently below the available input voltage.

## 5. Design Development

### 5.1 Architecture and Controller Selection

The starting architecture is a **single-phase synchronous buck converter with CC/CV control, input protection, and auxiliary supplies derived from the main input**.

The preliminary report should compare a diode-based buck, a synchronous buck, and at least one suitable alternative. Explain why each option is selected or rejected. The input always being above the nominal 12 V output supports the buck choice. Synchronous rectification is intended to reduce conduction losses.

Two initial controller candidates are:

- **LM5116:** Offers a wide input range and a published 12 V, 5 A reference design. The external sensing/control arrangement needed to regulate average output current must be evaluated separately.
- **LM5117:** Offers average-current monitoring and a published CC/CV application. Evaluate current accuracy, input transients relative to its 65 V operating limit, and availability.

No controller has been finalized. Compare input-voltage margin, CC/CV implementation, short-circuit behavior, startup supply, measurement accuracy, package, simulation support, and procurement. If the reference design's inductance, capacitance, or switching frequency changes, recalculate compensation and current-sensing settings.

**Deliverable:** A justified controller selection, a description of each circuit block, and an initial BOM with stock and lead-time information.

### 5.2 Analytical Calculations and Component Selection

Perform calculations for both 60 W and 90 W. Investigate **250 kHz and 22 µH** as starting values for the first simulation. These are not final production values.

For an ideal buck operating in continuous conduction mode:

$$
D \approx \frac{V_o}{V_{in}}, \qquad
\Delta i_{L,pp} \approx \frac{V_o(1-D)}{L f_s}, \qquad
I_{L,pk} \approx I_o + \frac{\Delta i_{L,pp}}{2}
$$

Preliminary results for a 12 V output, 250 kHz, and 22 µH:

| Vin | Ideal duty cycle | Inductor ripple | Peak at 5 A output | Peak at 7.5 A output |
|---|---:|---:|---:|---:|
| 20 V | 60% | 0.87 A peak-to-peak | 5.44 A | 7.94 A |
| 24 V | 50% | 1.09 A peak-to-peak | 5.55 A | 8.05 A |
| 36 V | 33.3% | 1.45 A peak-to-peak | 5.73 A | 8.23 A |
| 48 V | 25% | 1.64 A peak-to-peak | 5.82 A | 8.32 A |

These values assume nominal parameters. Account separately for inductance tolerance, temperature, switching-frequency tolerance, current-limit delay, and transient conditions.

Check the following during component selection:

- **Inductor:** Saturation current, RMS/thermal current rating, DC resistance, and core loss. Do not select saturation current using only the nominal output current.
- **MOSFETs:** VDS stress including spikes, RDS(on) at the actual gate voltage, resistance increase with temperature, gate charge, and switching loss. Investigate 100 V devices initially.
- **Output capacitors:** Effective capacitance, ESR, ripple-current rating, startup, and load transients. For the 12 V mode, 220–470 µF of low-ESR capacitance with suitable ceramics is an initial candidate; finalize voltage ratings together with the charging range.
- **Input capacitors:** Voltage margin, ceramic-capacitor DC-bias effects, and RMS current. A simplified estimate gives about 3.75 A RMS input-capacitor ripple current at 7.5 A output and 50% duty cycle.
- **Current sensing:** Shunt loss and tolerance, amplifier gain/offset, temperature effects, and Kelvin connections. Include calibration if required.
- **Auxiliary supplies:** Startup before the output exists, gate-charge demand on the supply, and continued control operation during an output short circuit.
- **Thermal design:** MOSFET, inductor, shunt, protection, and auxiliary-circuit losses. Evaluate open-board and enclosed temperatures separately.

A first estimate of output ripple is:

$$
\Delta V_{o,pp} \approx \frac{\Delta i_{L,pp}}{8 f_s C_{out}} + \Delta i_{L,pp}\,ESR
$$

This estimate does not fully capture switching spikes or PCB parasitics. Likewise, an efficiency estimate must include all loss contributions, not just MOSFET conduction losses.

**Deliverable:** Calculation files, a component voltage/current stress table, a loss budget, and justified component choices.

### 5.3 Simulation Sequence

1. **Basic power stage:** Start with 24 V input, approximately 50% duty cycle, and a 2.4 Ω load. Compare Vout, iL, and switch waveforms with the calculations.
2. **Input and load sweep:** Check 20, 24, 36, and 48 V at light load, 5 A, and 7.5 A. Account for possible conduction-mode changes at light load.
3. **Closed-loop operation:** Represent the actual selected control architecture. Adding an ideal PID to a buck model alone does not verify the chosen controller hardware.
4. **CC/CV transitions:** Check normal voltage regulation, current regulation under excessive load, and recovery when the load returns to normal.
5. **Realistic model:** Include MOSFET behavior, gate driving/dead time, inductor resistance, capacitor ESR, and relevant parasitics.
6. **Startup and faults:** Test startup with the load connected, soft-start, short-circuit behavior, and recovery. For charging, investigate the voltage limit and the battery's effect when the input is off.
7. **Two controller settings:** Compare overshoot, undershoot, settling time, and oscillation using identical input and load changes.

The simulation time step must resolve the switching behavior. Check that reducing it does not materially change the important results. Do not present the efficiency of an ideal model as a hardware prediction.

**Deliverable:** A reproducible simulation model, documented parameters, and a results table for each scenario.

## 6. Bonus Implementation Plan

The minimum project requirements must be met to qualify for bonuses. Our target is to verify all seven technical categories below. No point values are assumed for categories whose scoring has not yet been announced.

| Bonus | Design work | Evidence to retain |
|---|---|---|
| **Overload** | Size the power paths for 90 W and operate with a nominal 1.6 Ω load | Actual Vout/Iout/Pout, ripple, temperatures, and component limits |
| **Current Limit** | Regulate output current around the 7.5 A target and design short-circuit protection | Vout/Iout waveforms during overload, short circuit, and recovery |
| **Input Reverse Polarity Protection** | Implement low-loss MOSFET-based protection; check gate limits and current paths | Reverse-connection test, recovery with correct polarity, and protection losses |
| **Battery Charging** | Configure the same power stage for battery-appropriate CC/CV operation, voltage limits, and reverse-current behavior | Charging voltage/current, mode transition or termination, and test conditions |
| **Efficiency** | Reduce total losses and auxiliary consumption | Efficiency at 20/24/36/48 V with 60 W output, and the arithmetic mean |
| **Line and Load Transient Response** | Develop two controller/compensation settings | Line and load comparisons for both settings in simulation and hardware |
| **Compactness** | Fit the power stage, controller, and auxiliary supplies inside an enclosure | External dimensions, volume, photographs, and enclosed-operation tests |

### Shared Control for Current Limiting and Charging

The voltage loop will maintain 12 V in normal operation. If the load demands more current, the current loop will reduce the output voltage. For example, an ideal 1 Ω load with a 7.5 A limit results in approximately 7.5 V output.

Design average output-current regulation separately from fast inductor/switch peak-current protection. Peak protection must allow the ripple current during normal 7.5 A operation while protecting the components. Verify that current-sensing tolerances do not cause premature limiting at the 90 W operating point.

During a short circuit, the charged output capacitor can initially supply additional current. Distinguish this transient discharge from the converter's continuing current-limit behavior in the measurements. The laboratory supply's current limit does not replace protection implemented by the converter itself.

Once the battery is specified, record its chemistry, cell count, permitted charging current, and final voltage. CC charging must stop or change mode at the voltage limit; CV charging must include appropriate current limiting. Validate the settings before connecting a real battery.

### Efficiency and Enclosure Design

$$
\eta = \frac{P_{out}}{P_{in}}, \qquad
\bar{\eta} = \frac{\eta_{20}+\eta_{24}+\eta_{36}+\eta_{48}}{4}
$$

The efficiency score in the specification uses efficiencies as fractions between 0 and 1:

$$
B_\eta = \begin{cases}
50(\bar{\eta}-0.80), & \bar{\eta}<0.80 \\
100(\bar{\eta}-0.80), & \bar{\eta}\geq0.80
\end{cases}
$$

For example, a 93% average gives +13 points and a 95% average gives +15 points. Negative scores below 80% are not clipped to zero. Input power must include protection, the controller, gate drivers, sensors, and any fan.

At 60 W output, 95% efficiency corresponds to approximately 3.16 W of total loss. Reducing losses also makes enclosure cooling easier. Evaluate the switching-loss penalty when increasing frequency to reduce inductor size. Compactness is assessed using the enclosure's external volume, not just PCB area.

### Karma Bonus

Karma is an individual bonus awarded by anonymous student vote for helping other groups. Useful measurement notes, practical troubleshooting support, and sharing lessons learned can contribute toward it; the outcome cannot be guaranteed.

## 7. Schematic, PCB, and Manufacturing Checks

Develop the schematic and PCB together. Consider critical component packages and switching-loop placement before treating the schematic as final.

- [ ] All controller, driver, power-stage, and auxiliary-supply connections are complete.
- [ ] Switching-current loops are compact, with input ceramics close to the relevant MOSFETs.
- [ ] Gate traces are short; bootstrap and driver-supply capacitors are placed appropriately.
- [ ] Feedback and current-sense traces avoid the noisy switching node; required Kelvin connections are included.
- [ ] Analog and power grounding follow the selected controller's layout recommendations.
- [ ] Copper paths, vias, and connectors have been checked for the currents and temperatures at 90 W.
- [ ] Input, output, auxiliary rails, gate-source signals, and current measurements are accessible.
- [ ] Compensation components are accessible, with space for snubber or gate-resistor adjustments if needed.
- [ ] The enclosure, heatsink, connectors, and mounting holes fit the mechanical layout.
- [ ] Actual part numbers, datasheet pinouts, symbols, and footprints have been cross-checked.
- [ ] ERC/DRC results have been reviewed, with no unexplained errors remaining.
- [ ] Gerber and drill files have been inspected in an independent viewer; the schematic, PCB sources, and BOM refer to the same revision.
- [ ] The complete team has reviewed the design before manufacturing.

## 8. Hardware Bring-Up and Measurement Plan

1. Inspect soldering, polarity, shorts, and connections before applying power.
2. Verify auxiliary supplies and startup behavior with power switching inhibited.
3. Check gate-source waveforms, driver voltages, and dead-time behavior using a suitable measurement setup.
4. Start with a current-limited supply and a light load; monitor output voltage, input current, and temperatures.
5. Increase the load gradually and first verify the 60 W requirements at the four input points.
6. Proceed to 90 W tests and record voltage, ripple, current, and thermal behavior.
7. Use a controlled setup for overload, short-circuit, recovery, and reverse-polarity tests.
8. Measure line and load responses for both controller settings under identical conditions.
9. Once battery requirements are finalized, validate the charging settings and perform the charging test.
10. Test the final assembly inside its enclosure and repeat the necessary operating-point checks and demo rehearsal.

**Measurement setup:** Use suitable differential measurement for the high-side gate-source signal. Do not attach an earth-referenced oscilloscope ground clip to the switching node. Measure ripple near the output capacitor with a short ground connection. Record bandwidth and probe settings; use the announced common measurement procedure for final evaluation.

**Laboratory supply:** The specification states 30 V/6 A in parallel mode and 60 V/3 A in series mode. At 90 W output and an assumed 93% efficiency, approximately 4.84 A is required at 20 V input and 2.02 A at 48 V. Select the supply configuration accordingly and remove power before changing connections or operating mode. No additional connection, including USB, may power the converter during the final demonstration.

**Resistive load:** Check continuous power rating, cooling requirements, and resistance change with temperature in addition to the nominal 2.4 Ω and 1.6 Ω values. Record the actual load voltage and current.

### Test Matrix

| Test | Internal verification points | Main records |
|---|---|---|
| Nominal operation | 20/24/36/48 V at 60 W, with additional checks between these input points | Vout, Iout, Pout, ripple, and temperatures |
| Overload | Internal target: 20/24/36/48 V at 90 W | Regulation, ripple, and component temperatures |
| Efficiency | 20/24/36/48 V at the actual 60 W output point | Pin, Pout, auxiliary consumption, individual efficiencies, and average |
| Line transient | Fixed load; identical achievable input changes for both controller settings | Actual Vin change recorded together with Vout response |
| Load transient | Fixed Vin; for example, a 2.5 A ↔ 5 A load step for both settings | Actual Iout change recorded together with Vout response |
| Current limiting | Excessive load, short circuit, and fault removal | Current/voltage, transient peak, and recovery |
| Reverse polarity | Controlled reverse/correct connection after reviewing the protection circuit | Protection and return to normal operation |
| Charging | Battery and conditions to be announced | Vbat, Ibat, time, and mode transition/termination |
| Enclosure and duration | At least 5 minutes at nominal load; longer testing when needed for thermal evaluation | Temperature over time, ripple, and output power |

Update this matrix when the overload duration, additional test conditions, and measurement details are announced. Testing 90 W at all four input points is our internal verification target. A five-minute demonstration alone does not establish thermal equilibrium.

## 9. GitHub Structure and Workflow

| Folder or file | Contents |
|---|---|
| `README.md` | Project overview, team, targets, current status, and key links |
| `EE463_Project_Roadmap.md` | This working plan |
| `docs/` | Requirements, design decisions, meeting notes, and revision history |
| `calculations/` | Calculations, parameter files, and loss/thermal analyses |
| `simulations/` | Models, instructions for running them, and scenario parameters |
| `hardware/` | Schematic and PCB sources, BOM, and manufacturing files |
| `mechanical/` | Enclosure, mounting, and cooling design |
| `measurements/` | Raw data, oscilloscope captures, photographs, and processed plots |
| `reports/` | Preliminary report, presentation, and final report |
| `firmware/` | Code and settings only if a microcontroller is used |

Track work with GitHub issues containing a target date, dependencies, expected output, and acceptance criteria. Example: **“Select an inductor for 90 W: saturation/thermal current checks, loss calculation, and two available candidates.”**

A brief daily note should record progress, blockers, and the next concrete output. Coordinate changes to shared schematic and PCB files to avoid conflicting edits.

For each measurement, record the date, board revision, controller setting, Vin, load, probe/bandwidth settings, ambient/component temperatures, and instruments used. Preserve raw data. Label simulation plots and hardware measurements separately.

## 10. Report, Presentation, and Final Deliverables

**Preliminary report:** Requirements, topology comparison, selected architecture, analytical calculations, component stresses, loss/thermal estimates, control approach, simulations, component candidates, and auxiliary circuits.

**Feedback presentation:** Preliminary schematic, BOM, initial PCB layout, simulation results, critical decisions, known limitations, and remaining work before production.

**Manufacturing submission:** Revised schematic/PCB sources, BOM, Gerber files, and drill files incorporating the feedback.

**Final report:** Comparison of calculations, simulations, and measurements; design changes; nominal and overload results; control, protection, and charging tests; efficiency; temperatures; enclosure; and current design files. Clearly distinguish estimates from measured results.

## 11. Decisions Still to Be Finalized

| Topic | Information or decision needed | When to resolve it |
|---|---|---|
| Controller, current sensing, and CC/CV implementation | Compare suitable circuits, performance limits, and availability | Before completing the preliminary schematic and ordering critical components |
| Critical components and alternatives | Confirm stock, lead times, packages, and viable replacements | Before finalizing footprints |
| PCB layers, copper, and manufacturing rules | Obtain the supported production constraints | At the start of layout |
| Battery type, charging limits, and test conditions | Follow course announcements and assess the impact on the circuit | Preferably before PCB finalization; if still unknown, address the design implications during feedback |
| Bonus scores, fault-test conditions, and ripple measurement settings | Follow course announcements | Update the test matrix when announced |
| Enclosure size, cooling, and assembly method | Check electrical, thermal, and mechanical compatibility | Before finalizing PCB mechanical dimensions |

## References

- [Official EE463 hardware project specification](https://github.com/odtu/EE463/blob/master/Hardware%20Project/EE463%20Hardware%20Project.md) — checked on 8 November 2026.
- [TI AN-1713 — LM5116 12 V, 5 A reference design](https://www.ti.com/lit/ug/snva285a/snva285a.pdf)
- [TI LM5116 datasheet](https://www.ti.com/lit/ds/symlink/lm5116.pdf)
- [TI SNVA829 — CC/CV buck converter design using the LM5117](https://www.ti.com/lit/an/snva829/snva829.pdf)
- [TI LM5117 datasheet](https://www.ti.com/lit/ds/symlink/lm5117.pdf)

Reference documents are starting points. Recalculate the design for the selected components and any changed values, then verify the results in simulation and hardware.
