# Part II: add/subtract accumulator

The handout extends Part I: add_sub=0 adds A and S; add_sub=1 subtracts A from S. The existing `accumulator_8bit` module now supports both operations, preserving Figure 2's input register and registered outputs. Part I addition remains available with SW[8]=0. No duplicate accumulator is needed.

## Controls

| Signal | Use |
| --- | --- |
| SW[7:0] | Input A |
| SW[8] | 0: add; 1: subtract |
| KEY[0] | Active-low asynchronous reset |
| KEY[1] | Manual clock; update on release (rising edge) |
| LEDR[7:0] | Stored 8-bit result S |
| LEDR[8] | Carry for addition; borrow for subtraction |

SW[9] is unused. LEDR[9] stays off and HEX displays stay blank. Device, pins, and top-level ports are unchanged. Both source files were already registered in the Quartus project.

Each rising edge loads the new A while calculating with the OLD A_stored and OLD S. SW[8] selects the operation at that edge; it is not delayed through the A register. Changing switches without a clock edge does not change the result LEDs. Reset clears the input, result, and flag registers immediately.

The `condition ? x : y` expression selects x when the condition is 1 and y otherwise. Here it chooses subtraction or addition. Both operands are extended to 9 bits to preserve carry/borrow. For example, 4-5 wraps to 8'hFF with borrow=1; displayed as an unsigned number, FF is 255. LEDR[8] is not a signed-overflow flag and is replaced on every rising edge.

## FPGA test sequence

Compile the updated project and program the newly generated main.sof before testing. Every clock action below means press and release KEY1. Expected values are decimal unless marked hex.

| Step | Action | Expected S | Expected LEDR[8] |
| --- | --- | --- | --- |
| 1 | SW[8]=0; press and release KEY0 | 0 | 0 |
| 2 | Set A=10 (SW3 and SW1 up); clock once | 0 | 0 |
| 3 | Set A=3 (only SW1 and SW0 up); clock once | 10 | 0 |
| 4 | Set SW[8]=1 without clocking | 10 | 0 |
| 5 | Clock once, keeping A=3 | 7 | 0 |
| 6 | Clock once, keeping A=3 | 4 | 0 |
| 7 | Set A=5 (only SW2 and SW0 up); clock once | 1 | 0 |
| 8 | Keep A=5; clock once | 252 (FC hex) | 1 |
| 9 | Set SW[8]=0; clock once | 1 | 1 |
| 10 | Keep SW[8]=0 and A=5; clock once | 6 | 0 |
| 11 | Press KEY0 without clocking | 0 | 0 |

Step 7 subtracts the previously stored 3 and loads 5. Step 8 computes 1-5, giving an 8-bit result of FC and borrow=1. Step 9 computes 252+5=257, giving result 1 and carry=1. Hold KEY1 down before a release to confirm that the falling edge does not update the stored result.

No compilation, external test scripts, functional simulation, or hardware tests were run for this change. These are expected results for your testing, not measured results. Existing generated reports and programming files do not validate Part II.
