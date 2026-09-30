module main(
	input Clk,
	//input R,
	//input S,
	input D,
	//output Q,
	//output Q_D,
	//output Q_FF,
	output Qa,
	output Qb,
	output Qc
);

/*Part I start:
	gated_rs_latch rs_latch(
		.Clk(Clk),
		.R(R),
		.S(S),
		.Q(Q)
	);
Part I end
*/
/*Part II start:
	gated_d_latch d_latch(
		.D(D),
		.Clk(Clk),
		.Q(Q_D)
	);
//Part II end
*/
/*
//Part III start:
	master_slave_d_flip_flop d_flip_flop(
		.D(D),
		.Clk(Clk),
		.Q(Q_FF)
	);
//Part III end
*/
//Part IV start:
	behavioral_d_latch level_latch(
		.D(D),
		.Clk(Clk),
		.Q(Qa)
	);

	rising_edge_d_flip_flop rising_flip_flop(
		.D(D),
		.Clk(Clk),
		.Q(Qb)
	);

	falling_edge_d_flip_flop falling_flip_flop(
		.D(D),
		.Clk(Clk),
		.Q(Qc)
	);
//Part IV end

endmodule
