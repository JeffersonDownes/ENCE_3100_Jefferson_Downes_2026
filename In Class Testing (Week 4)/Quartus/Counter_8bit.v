module Counter_8bit(
	input ena,
	input clk,
	input clear,
	output [7:0] count
);
	
	wire w_and[6:0];
	wire w_out[7:0];
	
	assign w_and[0] = ena & w_out[0];
	assign w_and[1] = w_and[0] & w_out[1];
	assign w_and[2] = w_and[1] & w_out[2];
	assign w_and[3] = w_and[2] & w_out[3];
	assign w_and[4] = w_and[3] & w_out[4];
	assign w_and[5] = w_and[4] & w_out[5];
	assign w_and[6] = w_and[5] & w_out[6];
	
	TFlipFlop TFF_1(
		.T(ena),
		.clk(clk),
		.clear(clear),
		.Qt(w_out[0])
	);
	TFlipFlop TFF_2(
		.T(w_and[0]),
		.clk(clk),
		.clear(clear),
		.Qt(w_out[1])
	);
	TFlipFlop TFF_3(
		.T(w_and[1]),
		.clk(clk),
		.clear(clear),
		.Qt(w_out[2])
	);
	TFlipFlop TFF_4(
		.T(w_and[2]),
		.clk(clk),
		.clear(clear),
		.Qt(w_out[3])
	);
	TFlipFlop TFF_5(
		.T(w_and[3]),
		.clk(clk),
		.clear(clear),
		.Qt(w_out[4])
	);
	TFlipFlop TFF_6(
		.T(w_and[4]),
		.clk(clk),
		.clear(clear),
		.Qt(w_out[5])
	);
	TFlipFlop TFF_7(
		.T(w_and[5]),
		.clk(clk),
		.clear(clear),
		.Qt(w_out[6])
	);
	TFlipFlop TFF_8(
		.T(w_and[6]),
		.clk(clk),
		.clear(clear),
		.Qt(w_out[7])
	);
	
	assign count = {w_out[7], w_out[6], w_out[5], w_out[4],
	                w_out[3], w_out[2], w_out[1], w_out[0]};
	
endmodule
