module main(
	//input Clk,
	//input R,
	//input S,
	//input D,
	//output Q,
	//output Q_D,
	//output Q_FF,
	//output Qa,
	//output Qb,
	//output Qc,
	input [9:0] SW,
	//input [1:0] KEY,
	output [9:0] LEDR,
	output [7:0] HEX0,
	output [7:0] HEX1,
	output [7:0] HEX2,
	output [7:0] HEX3,
	output [7:0] HEX4,
	output [7:0] HEX5
);

/*
//Part I start:
	gated_rs_latch rs_latch(
		.Clk(SW[1]),
		.R(SW[0]),
		.S(SW[2]),
		.Q(LEDR[0])
	);

	// Only LEDR0 is used
	assign LEDR[9:1] = 9'b000000000;
	assign HEX0 = 8'hFF;
	assign HEX1 = 8'hFF;
	assign HEX2 = 8'hFF;
	assign HEX3 = 8'hFF;
	assign HEX4 = 8'hFF;
	assign HEX5 = 8'hFF;
//Part I end
*/

/*
//Part II start:
	gated_d_latch d_latch(
		.D(SW[0]),
		.Clk(SW[1]),
		.Q(LEDR[0])
	);

	// Only LEDR0 is used.
	assign LEDR[9:1] = 9'b000000000;
	assign HEX0 = 8'hFF;
	assign HEX1 = 8'hFF;
	assign HEX2 = 8'hFF;
	assign HEX3 = 8'hFF;
	assign HEX4 = 8'hFF;
	assign HEX5 = 8'hFF;
//Part II end
*/

/*
//Part III start:
	master_slave_d_flip_flop d_flip_flop(
		.D(SW[0]),
		.Clk(SW[1]),
		.Q(LEDR[0])
	);

	// Only LEDR0 is used.
	assign LEDR[9:1] = 9'b000000000;
	assign HEX0 = 8'hFF;
	assign HEX1 = 8'hFF;
	assign HEX2 = 8'hFF;
	assign HEX3 = 8'hFF;
	assign HEX4 = 8'hFF;
	assign HEX5 = 8'hFF;
//Part III end
*/

//Part IV start:
	behavioral_d_latch level_latch(
		.D(SW[0]),
		.Clk(SW[1]),
		.Q(LEDR[0])
	);

	rising_edge_d_flip_flop rising_flip_flop(
		.D(SW[0]),
		.Clk(SW[1]),
		.Q(LEDR[1])
	);

	falling_edge_d_flip_flop falling_flip_flop(
		.D(SW[0]),
		.Clk(SW[1]),
		.Q(LEDR[2])
	);

	// LEDR0 = Qa, LEDR1 = Qb, LEDR2 = Qc.
	assign LEDR[9:3] = 7'b0000000;
	assign HEX0 = 8'hFF;
	assign HEX1 = 8'hFF;
	assign HEX2 = 8'hFF;
	assign HEX3 = 8'hFF;
	assign HEX4 = 8'hFF;
	assign HEX5 = 8'hFF;
//Part IV end


/*
//Part V start:
	// DE10-Lite adaptation,store 8 bits using SW[7:0]
	wire [7:0] A;

	register_8bit stored_a(
		.D(SW[7:0]),
		.Clk(KEY[1]),
		.reset_n(KEY[0]),
		.Q(A)
	);

	hex_to_seven_segment a_high(
		.value(A[7:4]),
		.segments(HEX3[6:0])
	);
	hex_to_seven_segment a_low(
		.value(A[3:0]),
		.segments(HEX2[6:0])
	);

	hex_to_seven_segment b_high(
		.value(SW[7:4]),
		.segments(HEX1[6:0])
	);
	hex_to_seven_segment b_low(
		.value(SW[3:0]),
		.segments(HEX0[6:0])
	);

	// Turn off the decimal points and unused displays.
	assign HEX0[7] = 1'b1;
	assign HEX1[7] = 1'b1;
	assign HEX2[7] = 1'b1;
	assign HEX3[7] = 1'b1;
	assign HEX4 = 8'hFF;
	assign HEX5 = 8'hFF;
//Part V end
*/

endmodule
