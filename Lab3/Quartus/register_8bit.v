module register_8bit(
	input [7:0] D,
	input Clk,
	input reset_n,
	output reg [7:0] Q
);

	// Reset immediately when reset_n is 0; otherwise load on a rising edge.
	always @(posedge Clk or negedge reset_n) begin
		if (!reset_n)
			Q <= 8'h00;
		else
			Q <= D;
	end

endmodule
