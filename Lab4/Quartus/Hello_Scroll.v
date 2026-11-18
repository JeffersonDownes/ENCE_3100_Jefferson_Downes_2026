module Hello_Scroll(
	input ena,
	input clk,
	input clear,
	output [47:0] display
);

	// Active-low segments: bit 7 is the decimal point.
	localparam [7:0] BLANK = 8'hFF, H = 8'h89,
		E = 8'h86, L = 8'hC7, O = 8'hC0;

	// DE10-Lite: HEX5 on the left, HEX0 on the right.
	reg [47:0] pattern = {BLANK, H, E, L, L, O};

	always @(posedge clk) begin
		if(clear)
			pattern <= {BLANK, H, E, L, L, O};
		else if(ena)
			pattern <= {pattern[39:0], pattern[47:40]};
	end

	assign display = pattern;

endmodule
