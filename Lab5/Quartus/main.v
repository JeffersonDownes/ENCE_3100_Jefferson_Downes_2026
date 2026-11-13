module main(
	input [9:0] SW,
	input [1:0] KEY,
	output [9:0] LEDR,
	output [7:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5
);

/*
	wire add_sub;
//Part I start:
	accumulator_8bit accumulator(
		.A(SW[7:0]),
		.add_sub(add_sub),
		.Clk(KEY[1]),
		.Reset_n(KEY[0]),
		.S(LEDR[7:0]),
		.Overflow(LEDR[8])
	);
//Part I end

//Part II start:
	assign add_sub = SW[8];
//Part II end
*/
/*
	wire [7:0] product;
//Part III start:
	array_multiplier_4bit multiplier(
		.A(SW[7:4]),
		.B(SW[3:0]),
		.P(product)
	);

	Seg7_Decoder display_A(
		.m(SW[7:4]),
		.out(HEX5)
	);
	Seg7_Decoder display_B(
		.m(SW[3:0]),
		.out(HEX4)
	);
	Seg7_Decoder display_product_high(
		.m(product[7:4]),
		.out(HEX1)
	);
	Seg7_Decoder display_product_low(
		.m(product[3:0]),
		.out(HEX0)
	);
//Part III end
*/

//Part IV start:
	reg [7:0] operand_A, operand_B;
	wire [7:0] selected_operand;
	wire [15:0] product_p4;

	always @(posedge KEY[0]) begin
		if (SW[8])
			operand_B <= SW[7:0];
		else
			operand_A <= SW[7:0];
	end

	registered_multiplier_8bit multiplier_p4(
		.A(operand_A),
		.B(operand_B),
		.Clk(KEY[1]),
		.P(product_p4)
	);

	assign selected_operand = SW[8] ? operand_B : operand_A;
	assign LEDR = {1'b0, SW[8], SW[7:0]};

	Seg7_Decoder display_operand_high(
		.m(selected_operand[7:4]),
		.out(HEX5)
	);
	Seg7_Decoder display_operand_low(
		.m(selected_operand[3:0]),
		.out(HEX4)
	);
	Seg7_Decoder display_product_3(
		.m(product_p4[15:12]),
		.out(HEX3)
	);
	Seg7_Decoder display_product_2(
		.m(product_p4[11:8]),
		.out(HEX2)
	);
	Seg7_Decoder display_product_1(
		.m(product_p4[7:4]),
		.out(HEX1)
	);
	Seg7_Decoder display_product_0(
		.m(product_p4[3:0]),
		.out(HEX0)
	);
//Part IV end

endmodule
