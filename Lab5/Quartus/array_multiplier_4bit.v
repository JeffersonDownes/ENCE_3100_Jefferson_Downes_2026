module array_multiplier_4bit(
	input [3:0] A,
	input [3:0] B,
	output [7:0] P
);

	wire [3:0] pp0, pp1, pp2, pp3;
	wire [3:0] sum1, sum2, sum3;
	wire [3:0] carry1, carry2, carry3;

	// Each partial product is one row of AND gates in Figure 4.
	assign pp0 = A & {4{B[0]}};
	assign pp1 = A & {4{B[1]}};
	assign pp2 = A & {4{B[2]}};
	assign pp3 = A & {4{B[3]}};

	// Row 1 adds pp1 to the remaining bits of pp0.
	Full_Adder row1_bit0(
		.a(pp0[1]), .b(pp1[0]), .cin(1'b0),
		.s(sum1[0]), .cout(carry1[0])
	);
	Full_Adder row1_bit1(
		.a(pp0[2]), .b(pp1[1]), .cin(carry1[0]),
		.s(sum1[1]), .cout(carry1[1])
	);
	Full_Adder row1_bit2(
		.a(pp0[3]), .b(pp1[2]), .cin(carry1[1]),
		.s(sum1[2]), .cout(carry1[2])
	);
	Full_Adder row1_bit3(
		.a(1'b0), .b(pp1[3]), .cin(carry1[2]),
		.s(sum1[3]), .cout(carry1[3])
	);

	// Row 2 includes the carry from the previous row.
	Full_Adder row2_bit0(
		.a(sum1[1]), .b(pp2[0]), .cin(1'b0),
		.s(sum2[0]), .cout(carry2[0])
	);
	Full_Adder row2_bit1(
		.a(sum1[2]), .b(pp2[1]), .cin(carry2[0]),
		.s(sum2[1]), .cout(carry2[1])
	);
	Full_Adder row2_bit2(
		.a(sum1[3]), .b(pp2[2]), .cin(carry2[1]),
		.s(sum2[2]), .cout(carry2[2])
	);
	Full_Adder row2_bit3(
		.a(carry1[3]), .b(pp2[3]), .cin(carry2[2]),
		.s(sum2[3]), .cout(carry2[3])
	);

	// Row 3 produces the upper five product bits.
	Full_Adder row3_bit0(
		.a(sum2[1]), .b(pp3[0]), .cin(1'b0),
		.s(sum3[0]), .cout(carry3[0])
	);
	Full_Adder row3_bit1(
		.a(sum2[2]), .b(pp3[1]), .cin(carry3[0]),
		.s(sum3[1]), .cout(carry3[1])
	);
	Full_Adder row3_bit2(
		.a(sum2[3]), .b(pp3[2]), .cin(carry3[1]),
		.s(sum3[2]), .cout(carry3[2])
	);
	Full_Adder row3_bit3(
		.a(carry2[3]), .b(pp3[3]), .cin(carry3[2]),
		.s(sum3[3]), .cout(carry3[3])
	);

	assign P = {carry3[3], sum3, sum2[0], sum1[0], pp0[0]};

endmodule
