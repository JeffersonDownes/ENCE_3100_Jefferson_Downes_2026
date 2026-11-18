# Accumulator A verification

## Implementation

`../Accumulator_A.v` follows the Verilog shown on page 4 of the Lab 7 handout. The existing named connections in `../main.v` already match page 6 and were preserved. The main Quartus project keeps top-level entity `main` and target device `10M50DAF484C7G`.

- `AluA` stores four bits by default (`N = 4`).
- On each rising edge of `MainClock`, `ClearA = 1` clears the register. Clear has priority over load.
- Otherwise, `LatchA = 1` loads `A`; `LatchA = 0` retains the stored value.
- `EnableA = 1` connects the stored value to `IB_BUS`. When disabled, the bus output is `z` (high impedance), allowing another module to drive the shared bus.
- Output enable does not control loading. Other bus drivers must be disabled while Accumulator A drives the shared bus.

`posedge` means rising clock edge. `reg` holds the value assigned inside the clocked block, and `<=` updates it after that edge. `assign` continuously controls the bus output. Explicit `wire` declarations identify signal connections and allow Questa to compile this module with `default_nettype none`; the storage behavior is unchanged.

Corrected the misspelled `Acculumator_A.v` source reference in `../main.qsf`.

## Checks performed on November 3, 2026

| Check | Result |
| --- | --- |
| Compare source and named top-level connections with handout pages 4-6 | Matches |
| Questa 2025.2 compile of module and testbench | Passed; zero compile errors or warnings |
| Quartus 25.1 Analysis & Synthesis of Accumulator A alone | Passed; zero errors, one warning |
| Functional simulation | Blocked before execution by invalid-host Questa license |
| Actual RTL Viewer screenshot, timing analysis, FPGA test | Not performed |

Quartus warning 18236 says that the processor count was not specified. Quartus used the 16 detected processors; this concerns compilation resource use, not an inferred latch or a circuit error. Questa also reported that `+acc` disables some optimizations; that option preserves signals for waveform inspection. Its license error is separate and prevents simulation.

The isolated synthesis project uses the same MAX 10 device as `main.qsf`, with `Accumulator_A` as its temporary top-level entity. It does not change the board interface or the main project's top-level entity. The main processor project was not synthesized: it still contains unfinished modules and unrelated missing source-file references. Passing the isolated check does not establish that the processor works.

## Repeat the checks

Run `./check_accumulator_a.ps1` from PowerShell. Its optional `-ToolsRoot` parameter selects a different Quartus installation. All generated projects, databases, simulation logs, and waveforms go into the ignored `generated` folder. The testbench is kept as source.

The testbench checks all 16 input values, rising-edge loading, falling-edge retention, disabled-load retention, synchronous clear, clear priority, bus release, and loading while the bus output is disabled. It is prepared but has not run successfully because Questa reports an invalid host for its `intelqsimstarter` license. After the license is repaired, rerun the script and require a `PASS: Accumulator A` result.

For waveform inspection, start Questa in `tests/generated` and run `do ../accumulator_a.do` with finish behavior set to Stop. The script adds the clock, controls, input, stored output, and bus to the waveform window. The initialization asserts clear and then generates a rising edge; changing clear alone does not initialize this synchronous register.

After synthesis, open `generated/accumulator_a_synthesis.qpf` in Quartus and use Tools > Netlist Viewers > RTL Viewer for Accumulator A evidence. This does not replace functional simulation.

Accumulator A's implementation and isolated synthesis are ready. Successful functional simulation and the required report evidence remain before declaring this lab work fully complete. The final processor video also remains a requirement for the full lab.
