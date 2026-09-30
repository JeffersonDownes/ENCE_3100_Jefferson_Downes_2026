module master_slave_d_flip_flop(
	input D,
	input Clk,
	output Q
);

	wire Clk_not, Qm;

	assign Clk_not = ~Clk;

	gated_d_latch master(
		.D(D),
		.Clk(Clk_not),
		.Q(Qm)
	);

	gated_d_latch slave(
		.D(Qm),
		.Clk(Clk),
		.Q(Q)
	);

endmodule
