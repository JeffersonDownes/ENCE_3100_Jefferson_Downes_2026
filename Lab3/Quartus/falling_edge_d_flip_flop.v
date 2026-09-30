module falling_edge_d_flip_flop(
	input D,
	input Clk,
	output reg Q
);

	always @(negedge Clk) begin
		Q <= D;
	end

endmodule
