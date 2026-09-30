module gated_d_latch(
	input D,
	input Clk,
	output Q
);

	wire R, S_g, R_g, Qa, Qb;

	assign R = ~D;

	assign S_g = ~(D & Clk);
	assign R_g = ~(R & Clk);

	assign Qa = ~(S_g & Qb);
	assign Qb = ~(R_g & Qa);

	assign Q = Qa;

endmodule
