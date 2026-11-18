module main(
    input  [9:0] SW,
    input  [1:0] KEY,
    input        MAX10_CLK1_50,
    output [9:0] LEDR,
    output [7:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5
);

	wire w_clk;
	wire w_ena;
	wire [3:0] w_digit;
	wire [15:0] w_count;

	/*
	Counter_1Hz CLK_1(
		.in_clk(MAX10_CLK1_50),
		.clear(1'b0),
		.out_clk(w_clk)
	);

	*/

	// assign w_clk = KEY[0];
	assign w_clk = MAX10_CLK1_50;

	/* Part I: retained for reference.
	Counter_8bit TFF_1(
		.ena(SW[1]),
		.clk(w_clk),
		.clear(SW[0]),
		.count(LEDR[7:0])
	);

	Seg7_Decoder HEX_LOW(
		.m(LEDR[3:0]),
		.out(HEX0)
	);

	Seg7_Decoder HEX_HIGH(
		.m(LEDR[7:4]),
		.out(HEX1)
	);

	assign LEDR[9:8] = 2'b00;
	assign HEX2 = 8'hFF;
	assign HEX3 = 8'hFF;
	*/

	/*
	// Part II: 16-bit behavioral counter.
	// KEY0 produces one enable after a debounced release.
	KEY0_Release KEY_1(
		.clk(w_clk),
		.clear(~SW[0]),
		.key(KEY[0]),
		.ena(w_ena)
	);

	Counter_16bit CNT_1(
		.ena(SW[1] & w_ena),
		.clk(w_clk),
		.clear(SW[0]),
		.count(w_count)
	);


	Seg7_Decoder HEX_LOW(
		.m(w_count[3:0]),
		.out(HEX0)
	);

	Seg7_Decoder HEX_HIGH(
		.m(w_count[7:4]),
		.out(HEX1)
	);

	Seg7_Decoder HEX_MID(
		.m(w_count[11:8]),
		.out(HEX2)
	);

	Seg7_Decoder HEX_TOP(
		.m(w_count[15:12]),
		.out(HEX3)
	);

	assign LEDR = w_count[9:0];

	assign HEX4 = 8'hFF;
	assign HEX5 = 8'hFF;

	
	*/
	/* Part III: 16-bit LPM counter.
	LPM_Counter_16bit CNT_1(
		.ena(SW[1]),
		.clk(w_clk),
		.clear(SW[0]),
		.count(w_count)
	);

	Seg7_Decoder HEX_LOW(
		.m(w_count[3:0]),
		.out(HEX0)
	);

	Seg7_Decoder HEX_HIGH(
		.m(w_count[7:4]),
		.out(HEX1)
	);

	Seg7_Decoder HEX_MID(
		.m(w_count[11:8]),
		.out(HEX2)
	);

	Seg7_Decoder HEX_TOP(
		.m(w_count[15:12]),
		.out(HEX3)
	);

	assign LEDR = w_count[9:0];

	assign HEX4 = 8'hFF;
	assign HEX5 = 8'hFF;
	*/
	/* Part IV: retained for reference.
	// Part IV: all registers use the 50 MHz clock.
	Counter_1Sec CLK_1(
		.clk(w_clk),
		.clear(~SW[0]),
		.ena(w_ena)
	);

	Digit_Counter CNT_1(
		.ena(w_ena),
		.clk(w_clk),
		.clear(~SW[0]),
		.count(w_digit)
	);

	Seg7_Decoder HEX_LOW(
		.m(w_digit),
		.out(HEX0)
	);

	assign LEDR = {6'b000000, w_digit};
	assign HEX1 = 8'hFF;
	assign HEX2 = 8'hFF;
	assign HEX3 = 8'hFF;
	assign HEX4 = 8'hFF;
	assign HEX5 = 8'hFF;
	*/
	// Part V: retained for reference.
	// Part V: reuse the one-second clock enable.
	Counter_1Sec CLK_1(
		.clk(w_clk),
		.clear(~SW[0]),
		.ena(w_ena)
	);

	Hello_Scroll CNT_1(
		.ena(w_ena),
		.clk(w_clk),
		.clear(~SW[0]),
		.display({HEX5, HEX4, HEX3, HEX2, HEX1, HEX0})
	);

	assign LEDR = 10'b0000000000;
endmodule
