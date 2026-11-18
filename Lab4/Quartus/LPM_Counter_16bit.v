module LPM_Counter_16bit(
	input ena,
	input clk,
	input clear,
	output [15:0] count
);

	lpm_counter #(
		.lpm_width(16),
		.lpm_direction("UP"),
		.lpm_type("LPM_COUNTER")
	) LPM_1(
		.clock(clk),
		.clk_en(1'b1),
		.cnt_en(ena),
		.sclr(~clear),
		.aclr(1'b0),
		.aset(1'b0),
		.aload(1'b0),
		.sset(1'b0),
		.sload(1'b0),
		.data(16'd0),
		.updown(),
		.cin(1'b1),
		.q(count),
		.cout(),
		.eq()
	);

endmodule
