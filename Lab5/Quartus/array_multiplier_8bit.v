module array_multiplier_8bit(
	input [7:0] A,
	input [7:0] B,
	output [15:0] P
);

	wire [7:0] pp0, pp1, pp2, pp3, pp4, pp5, pp6, pp7;
	wire [7:0] sum1, sum2, sum3, sum4, sum5, sum6, sum7;
	wire carry1, carry2, carry3, carry4, carry5, carry6, carry7;

	// Partial products: one row of AND gates for each bit of B.
	assign pp0 = A & {8{B[0]}};
	assign pp1 = A & {8{B[1]}};
	assign pp2 = A & {8{B[2]}};
	assign pp3 = A & {8{B[3]}};
	assign pp4 = A & {8{B[4]}};
	assign pp5 = A & {8{B[5]}};
	assign pp6 = A & {8{B[6]}};
	assign pp7 = A & {8{B[7]}};

	// Each row shifts the previous partial sum, as in Figure 5.
	ripple_adder_8bit row1(
		.A({1'b0, pp0[7:1]}),
		.B(pp1),
		.cin(1'b0),
		.S(sum1),
		.cout(carry1)
	);
	ripple_adder_8bit row2(
		.A({carry1, sum1[7:1]}),
		.B(pp2),
		.cin(1'b0),
		.S(sum2),
		.cout(carry2)
	);
	ripple_adder_8bit row3(
		.A({carry2, sum2[7:1]}),
		.B(pp3),
		.cin(1'b0),
		.S(sum3),
		.cout(carry3)
	);
	ripple_adder_8bit row4(
		.A({carry3, sum3[7:1]}),
		.B(pp4),
		.cin(1'b0),
		.S(sum4),
		.cout(carry4)
	);
	ripple_adder_8bit row5(
		.A({carry4, sum4[7:1]}),
		.B(pp5),
		.cin(1'b0),
		.S(sum5),
		.cout(carry5)
	);
	ripple_adder_8bit row6(
		.A({carry5, sum5[7:1]}),
		.B(pp6),
		.cin(1'b0),
		.S(sum6),
		.cout(carry6)
	);
	ripple_adder_8bit row7(
		.A({carry6, sum6[7:1]}),
		.B(pp7),
		.cin(1'b0),
		.S(sum7),
		.cout(carry7)
	);

	assign P = {carry7, sum7, sum6[0], sum5[0], sum4[0],
		sum3[0], sum2[0], sum1[0], pp0[0]};

endmodule

