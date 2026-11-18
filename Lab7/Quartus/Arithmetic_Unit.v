
`default_nettype none

module Arithmetic_Unit #
(
	parameter N = 4
)
(
	input EnableALU,
	input AddSub,
	input [N-1:0] A,
	input [N-1:0] B,
	output reg Carry,
	output reg [N-1:0] IB_ALU
);

	always @(*) begin
		IB_ALU = {N{1'bz}};
		Carry = 1'b0;

		if(EnableALU) begin
			if(AddSub) begin
				{Carry, IB_ALU} = {1'b0, A} - {1'b0, B};
			end
			else begin
				{Carry, IB_ALU} = {1'b0, A} + {1'b0, B};
			end
		end
	end

endmodule

`default_nettype wire
