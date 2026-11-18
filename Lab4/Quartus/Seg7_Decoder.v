// Active-low hexadecimal decoder: 0-9 and A-F.
// out[6:0] = g,f,e,d,c,b,a; out[7] is the decimal point (off).
module Seg7_Decoder(
	input [3:0] m,
	output [7:0] out
);

	wire [6:0] decimal_segments;

	assign out[7] = 1'b1;
	assign decimal_segments[6] = (~m[3] & ~m[2] & ~m[1]) | (m[2] & m[1] & m[0]);
	assign decimal_segments[5] = (~m[3] & ~m[2] & m[0]) | (~m[2] & m[1]) | (m[1] & m[0]);
	assign decimal_segments[4] = m[0] | (m[2] & ~m[1]);
	assign decimal_segments[3] = (~m[3] & ~m[2] & ~m[1] & m[0]) | (m[2] & ~m[1] & ~m[0]) | (m[2] & m[1] & m[0]);
	assign decimal_segments[2] = (~m[2] & m[1] & ~m[0]);
	assign decimal_segments[1] = (m[2] & ~m[1] & m[0]) | (m[2] & m[1] & ~m[0]);
	assign decimal_segments[0] = (~m[3] & ~m[2] & ~m[1] & m[0]) | (m[2] & ~m[1] & ~m[0]);

	// Use the original equations for 0-9; select patterns for A-F.
	assign out[6:0] = (m == 4'hA) ? 7'b0001000 :
		(m == 4'hB) ? 7'b0000011 :
		(m == 4'hC) ? 7'b1000110 :
		(m == 4'hD) ? 7'b0100001 :
		(m == 4'hE) ? 7'b0000110 :
		(m == 4'hF) ? 7'b0001110 : decimal_segments;

endmodule
