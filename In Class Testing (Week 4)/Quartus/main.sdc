# FPGA oscillator: 50 MHz.
create_clock -name MAX10_CLK1_50 -period 20.000 [get_ports {MAX10_CLK1_50}]
# Hardware divider output is 1 Hz. TimeQuest cannot represent a 1-second period.
# Use a conservative 1 kHz timing constraint for the slow counter domain.
create_generated_clock -name clk_1hz -source [get_ports {MAX10_CLK1_50}] -divide_by 50000 [get_registers {*CLK_1|out_clk}]
derive_clock_uncertainty
# Switches are asynchronous manual controls.
set_false_path -from [get_ports {SW[*]}]
# LEDs and seven-segment displays are human-observed outputs.
set_false_path -to [get_ports {LEDR[*] HEX0[*] HEX1[*] HEX2[*] HEX3[*] HEX4[*] HEX5[*]}]
