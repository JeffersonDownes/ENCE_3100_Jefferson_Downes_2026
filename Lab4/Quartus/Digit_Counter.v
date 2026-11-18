module Digit_Counter(
	input ena,
	input clk,
	input clear,
	output reg [3:0] count = 4'd0
);

	always @(posedge clk) begin
		if(clear)
			count <= 4'd0;
		else if(ena) begin
			if(count == 4'd9)
				count <= 4'd0;
			else
				count <= count + 4'd1;
		end
	end

endmodule
