module behavioral_d_latch(
	input D,
	input Clk,
	output reg Q
);

	always @(D or Clk) begin
		if (Clk)
			Q <= D;
	end

endmodule
