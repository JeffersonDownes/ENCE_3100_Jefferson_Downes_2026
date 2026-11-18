module Counter_1Sec #(
	parameter CLOCK_CYCLES = 50_000_000
)(
	input clk,
	input clear,
	output ena
);

	reg [25:0] count = 26'd0;

	always @(posedge clk) begin
		if(clear)
			count <= 26'd0;
		else if(count == CLOCK_CYCLES - 1)
			count <= 26'd0;
		else
			count <= count + 26'd1;
	end

	assign ena = ~clear & (count == CLOCK_CYCLES - 1);

endmodule
