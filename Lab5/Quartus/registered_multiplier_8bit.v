module registered_multiplier_8bit(
	input [7:0] A,
	input [7:0] B,
	input Clk,
	output reg [15:0] P
);

	reg [7:0] A_stored, B_stored;
	wire [15:0] product;

	array_multiplier_8bit multiplier(
		.A(A_stored),
		.B(B_stored),
		.P(product)
	);

	// The output uses the operands stored on the previous rising edge.
	always @(posedge Clk) begin
		A_stored <= A;
		B_stored <= B;
		P <= product;
	end

endmodule

