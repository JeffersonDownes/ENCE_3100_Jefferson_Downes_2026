module rising_edge_d_flip_flop(
	input D,
	input Clk,
	output reg Q
);

	always @(posedge Clk) begin
		Q <= D;
	end

endmodule
