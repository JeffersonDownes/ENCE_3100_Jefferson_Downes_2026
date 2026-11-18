onerror {quit -code 1 -force}
if {![file exists work]} {vlib work}
vmap work work
vlog ../../Accumulator_A.v
vlog -sv ../accumulator_a_tb.v
vsim -voptargs=+acc work.accumulator_a_tb
log -r /*
add wave -radix binary sim:/accumulator_a_tb/MainClock
add wave -radix binary sim:/accumulator_a_tb/ClearA
add wave -radix binary sim:/accumulator_a_tb/LatchA
add wave -radix binary sim:/accumulator_a_tb/EnableA
add wave -radix hexadecimal sim:/accumulator_a_tb/A
add wave -radix hexadecimal sim:/accumulator_a_tb/AluA
add wave -radix hexadecimal sim:/accumulator_a_tb/IB_BUS
run -all
wave zoom full
if {[batch_mode]} {quit -code 0 -force}
