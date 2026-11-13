# Part I: 8-bit registered accumulator

Open `accumulator_8bit.circ` in Logisim-evolution 4.1.0. This standalone circuit matches Figure 2 of the Lab 5 handout; it does not depend on the Lab 4 counter circuit.

- `A`: 8-bit input, displayed in hexadecimal. Use the Poke tool to select the input and enter hexadecimal digits.
- `Clock`: manual input pin. Click to alternate 0 and 1; only 0 -> 1 updates the registers.
- `Reset_n`: active-low asynchronous reset. Set it to 0 to clear all three storage elements, then to 1 to operate.
- `A_stored`: value held in the input register.
- `S`: accumulated 8-bit sum, displayed in hexadecimal.
- `Overflow`: carry-out from the most recent registered addition; it is not a signed-overflow flag and is not sticky.

The same clock drives both 8-bit registers and the carry D flip-flop. Each rising edge loads A_stored from A and adds the OLD A_stored to the OLD S. Therefore, the first edge after reset loads A but leaves S at zero. Matching Clock and Clear tunnel labels represent connected wires. Register enables are tied to 1; adder carry-in and flip-flop preset are tied to 0.

## Manual verification and screenshots

Keep Reset_n at 1 after initialization. Values below are hexadecimal except Clock, Reset_n and Overflow. Return Clock to 0 before each requested rising edge.

| Step | Action | A_stored | S | Overflow | Caption |
| --- | --- | --- | --- | --- | --- |
| 1 | Clock=0; Reset_n=0; A=05 | 00 | 00 | 0 | Active-low reset clears all stored values. |
| 2 | Reset_n=1; Clock 0 -> 1 | 05 | 00 | 0 | First rising edge loads A into the input register. |
| 3 | Change A to 09 while Clock stays 1 | 05 | 00 | 0 | Input changes alone do not change stored values. |
| 4 | Clock 1 -> 0 | 05 | 00 | 0 | Falling edge preserves the register contents. |
| 5 | Clock 0 -> 1 | 09 | 05 | 0 | Rising edge adds the previously stored 05. |
| 6 | Clock 1 -> 0 -> 1 | 09 | 0E | 0 | Next rising edge adds 09 to the running sum. |
| 7 | Set Reset_n=0 while Clock stays 1 | 00 | 00 | 0 | Asynchronous reset clears the circuit without a clock edge. |
| 8 | Clock=0; A=FA; Reset_n=1; Clock 0 -> 1 | FA | 00 | 0 | Load FA for the carry demonstration. |
| 9 | Clock=0; A=0A; Clock 0 -> 1 | 0A | FA | 0 | Add FA and load the next operand, 0A. |
| 10 | Clock=0; A=00; Clock 0 -> 1 | 00 | 04 | 1 | FA + 0A = 104: sum wraps to 04 with carry 1. |
| 11 | Clock 1 -> 0 -> 1 | 00 | 04 | 0 | Adding zero preserves the sum and clears the new carry. |

Suggested circuit slide title: **Part I: 8-Bit Accumulator Implementation**.
Suggested verification slide title: **Part I: Accumulator State and Carry Verification**.

## Verification performed

The actual .circ file was loaded into the installed Logisim-evolution 4.1.0 simulation engine and tested by `tests/VerifyAccumulator.java`. It passed 9,081 assertions including 1,000 randomized rising edges, asynchronous resets, input-register latency, hold behavior, wraparound and carry updates. No bus-width incompatibilities were reported. The circuit was also rendered by Logisim's drawing engine and visually inspected.

This was scripted Logisim engine verification, not manual testing in the graphical app. Quartus timing simulation, timing-analyzer evidence, and hardware testing are outside this Logisim step and remain required for the full lab part.

The verification program takes the circuit path and a preview PNG output path as arguments and requires the installed Logisim JAR on the Java classpath. Windows emitted preference-registry access warnings under the sandbox; circuit loading, simulation and rendering completed successfully.
