module ripple_adder_8bit(
	input [7:0] A,
	input [7:0] B,
	input cin,
	output [7:0] S,
	output cout
);

	wire carry_middle;

	Ripple_Adder_4 low_bits(
		.A(A[3:0]),
		.B(B[3:0]),
		.cin(cin),
		.S(S[3:0]),
		.cout(carry_middle)
	);
	Ripple_Adder_4 high_bits(
		.A(A[7:4]),
		.B(B[7:4]),
		.cin(carry_middle),
		.S(S[7:4]),
		.cout(cout)
	);

endmodule

