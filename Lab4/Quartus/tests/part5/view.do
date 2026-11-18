view wave
add wave -label clk_50MHz part5:/part5_tb/clk
add wave -label clear part5:/part5_tb/clear
add wave -label enable part5:/part5_tb/ena
add wave -radix ascii -label HEX5_to_HEX0 part5:/part5_tb/word_text
configure wave -namecolwidth 135 -valuecolwidth 95 -rowmargin 4 -timelineunits ns
wave zoom range 0ns 780ns
