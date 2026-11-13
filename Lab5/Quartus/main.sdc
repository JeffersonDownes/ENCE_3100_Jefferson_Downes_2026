# Part IV manual clocks: 20 ns is an analysis target, not a button rate.
create_clock -name operand_load_clock -period 20.000 [get_ports {KEY[0]}]
create_clock -name multiplier_clock -period 20.000 [get_ports {KEY[1]}]
# Load both operands first; keep them stable while clocking the multiplier.
set_clock_groups -asynchronous -group {operand_load_clock} -group {multiplier_clock}
derive_clock_uncertainty
# Switches are asynchronous manual controls.
set_false_path -from [get_ports {SW[*]}]
# LEDs and seven-segment displays are human-observed outputs.
set_false_path -to [get_ports {LEDR[*] HEX0[*] HEX1[*] HEX2[*] HEX3[*] HEX4[*] HEX5[*]}]
