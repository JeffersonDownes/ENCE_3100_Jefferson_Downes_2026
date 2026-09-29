module Counter_1Hz(
	input in_clk,
	input clear,
	output reg out_clk = 1'b0
);

	reg [25:0] count = 26'd0;

	always @(posedge in_clk) begin
		if(clear) begin
			out_clk <= 1'b0;
			count <= 26'd0;
		end
		else begin
			if(count == 26'd49_999_999) begin
				count <= 26'd0;
				out_clk <= 1'b0;
			end
			else begin
				count <= count + 26'd1;
				if(count == 26'd24_999_999)
					out_clk <= 1'b1;
			end
		end
	end
endmodule
