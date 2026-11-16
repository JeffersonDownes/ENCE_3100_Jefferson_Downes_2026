create_clock -name accumulator_clock -period 20.000 [get_ports {Clk}]
derive_clock_uncertainty
# Manual controls and displays do not have synchronous external timing.
set_false_path -from [get_ports {A[*] add_sub Reset_n}]
set_false_path -to [get_ports {S[*] Overflow}]
