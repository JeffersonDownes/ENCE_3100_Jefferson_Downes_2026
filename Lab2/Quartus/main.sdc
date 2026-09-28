# Only the operand-capture adapter is clocked; the lab arithmetic is combinational.
create_clock -name MAX10_CLK1_50 -period 20.000 [get_ports {MAX10_CLK1_50}]
# Switches/buttons are asynchronous manual controls, held stable when loading.
# KEY inputs are synchronized inside Switch_Registers.
set_false_path -from [get_ports {SW[*] KEY[*]}]
# LEDs and seven-segment displays are asynchronous, human-observed outputs.
set_false_path -to [get_ports {LEDR[*] HEX0[*] HEX1[*] HEX2[*] HEX3[*] HEX4[*] HEX5[*]}]
