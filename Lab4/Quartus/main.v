module main(
    input  [9:0] SW,
    input        MAX10_CLK1_50,
    output [9:0] LEDR,
    output [7:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5
);

	wire w_clk;

	Counter_1Hz CLK_1(
		.in_clk(MAX10_CLK1_50),
		.clear(1'b0),
		.out_clk(w_clk)
	);

	Counter_8bit TFF_1(
		.ena(SW[0]),
		.clk(w_clk),
		.clear(SW[8]),
		.count(LEDR[7:0])
	);

	assign LEDR[9:8] = 2'b00;
	assign HEX0 = 8'hFF;
	assign HEX1 = 8'hFF;
	assign HEX2 = 8'hFF;
	assign HEX3 = 8'hFF;
	assign HEX4 = 8'hFF;
	assign HEX5 = 8'hFF;

endmodule