module main(
	// Board I/Os
	input		MAX10_CLK1_50,
	input 	[9:0]		SW,
	output	[9:0]		LEDR,
	output 	[9:0] 	KEY,
	output 	[35:0] 	GPIO
);
	 
	ram32x8_lut LUTO(
		.clk(SW[9]),
		.we(SW[8]),
		.addr(SW[4:0]),
		.din({5'd0, SW[7:5]}),
		.dout(w_mem_1)
	);
	
	ram32x8_ip IPRAM0(
		.address(~SW[4:0]),
		.clock(SW[9]),
		.data({5'd0, SW[7:5]}),
		.wren(SW[8]),
		.q(w_mem_2)
	);

	wire[7:0] w_mem_1;
	wire[7:0] w_mem_2;
	
	assign LEDR[7:0] = (KEY[0]) ? w_mem_1 : w_mem_2;
	
endmodule
