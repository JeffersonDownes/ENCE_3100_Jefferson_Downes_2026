module AND8(
	input [7:0] A,
	input	[7:0] B,
	output [7:0] Y
);

	generate
		for (i = 0; i < 8; i = i + 1) begin: gen_led
			assign Y[i] = A[i] & B[i];
		end
	endgenerate
	
endmodule