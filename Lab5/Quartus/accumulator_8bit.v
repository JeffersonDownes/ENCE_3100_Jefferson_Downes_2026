module accumulator_8bit(
	input [7:0] A,
	input add_sub,
	input Clk,
	input Reset_n,
	output reg [7:0] S,
	output reg Overflow
);

	reg [7:0] A_stored;
	wire [8:0] total;

	assign total = add_sub ? ({1'b0, S} - {1'b0, A_stored})
		: ({1'b0, S} + {1'b0, A_stored});

	always @(posedge Clk or negedge Reset_n) begin
		if (!Reset_n) begin
			A_stored <= 8'd0;
			S <= 8'd0;
			Overflow <= 1'b0;
		end
		else begin
			A_stored <= A;
			// Use stored values. Overflow is carry for add, borrow for subtract.
			{Overflow, S} <= total;
		end
	end

endmodule
