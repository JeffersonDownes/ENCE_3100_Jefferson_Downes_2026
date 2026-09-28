# Lab 2 Verilog - DE10-Lite

Open **main.qpf in this Quartus folder**. All seven lab sections are in **main.v**, with reusable modules in the supporting `.v` files. The project settings include every source file and retain the existing board's 71 used pin locations.

## Enable one part

1. Comment out the two `assign` statements between `BEGIN IDLE` and `END IDLE`.
2. Remove the standalone `/*` and `*/` around the desired part.
3. Compile and test. Comment that part again before enabling another one.

All seven parts are currently commented out. The active idle section mirrors switches on the LEDs and blanks the displays. Keep the common port list and `Switch_Registers` instance enabled.

## DE10-Lite controls

The PDF's DE2 has more switches, LEDs, and displays than this project. These adaptations keep the existing DE10-Lite pinout:

| Part | Controls and outputs |
| --- | --- |
| I | Set SW7..0 and press KEY0 to store the upper two digits; repeat with KEY1 for the lower two. HEX3..0 display all four digits. |
| II | SW3..0 is binary 0..15; HEX1..0 show decimal 00..15. |
| III | SW7..4 = A, SW3..0 = B, SW8 = carry-in. SW9=0 mirrors inputs on LEDR8..0; SW9=1 shows the five-bit binary sum on LEDR4..0. |
| IV | Same arithmetic inputs as III. HEX5=A, HEX4=B, HEX1..0=decimal result. SW9 selects input LEDs or the raw binary sum; LEDR9 always flags an invalid BCD input. |
| V | Capture packed BCD A with KEY0 and B with KEY1. SW9=0 displays A on HEX5/4 and B on HEX3/2; SW9=1 displays the three-digit result on HEX2..0. LEDR9 flags invalid stored digits. |
| VI | Same controls as V, using the algorithmic implementation instead of cascaded structural BCD adders. |
| VII | SW5..0 is binary 0..63; HEX1..0 show its decimal value. |

For captures, hold SW7..0 steady while pressing the key. Registers initialize to zero. The keys are synchronized to the existing 50 MHz clock; pressing a key loads a value, rather than incrementing anything. SW8 is unused by Parts I, V, and VI.

Each BCD nibble must be 0..9. To enter decimal 99, set SW7..0 to **1001 1001**. Capturing this into both A and B, then selecting the result view in Part V or VI, should display **198**. Invalid BCD results are unspecified while the error LED is on.

## Implementation notes

- `CircuitA.v` was completed and the digit-7 expression in `Seg7_Decoder.v` was corrected.
- Parts I and II use Boolean expressions. Part III explicitly instantiates four full adders. Part IV uses those adders plus Boolean decimal-correction logic. Part V instantiates two Part IV adders.
- Part VI deliberately uses addition, comparison, and `if/else`, with five-bit intermediate values to preserve sums of 16..19.
- Part VII follows the Logisim conditional-subtract-10 converter.
- `main.sdc` constrains the 50 MHz capture clock; manual switch/button inputs and human-observed LED/display outputs have no external synchronous timing requirement.

Functional testing is left to you as requested. Before testing was stopped, Questa compiled all seven enabled variants with zero errors and warnings, and Quartus synthesized Part I. No complete functional simulation or FPGA programming was performed. Optional testbench files are in `tests/`; the installed Questa simulator reported a host-mismatched license.
