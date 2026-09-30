module gated_rs_latch(
	input Clk,
	input R,
	input S,
	output Q
);


	wire R_g, S_g, Qa, Qb;

	and (R_g, R, Clk);  
	and (S_g, S, Clk);   

	nor (Qa, R_g, Qb);
	nor (Qb, S_g, Qa);

	assign Q = Qa;      

endmodule
