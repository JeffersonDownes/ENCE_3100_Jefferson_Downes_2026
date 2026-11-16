module FSM_Moore(
	input clk,
	input reset,
	input w,
	output reg [2:0] Y 
);

	reg [1:0] state, next_state;

	// States
	localparam [1:0] A = 3'b000, B = 3'b001, C = 3'b010, D = 3'b011, E = 3'b100, F = 3'b101; 

	// 1. State Register (sequential)
	always @(posedge clk) begin
		if(reset)
			state <= A;
		else
			state <= next_state;
	end
	
	// 2. Next-State Logic (combinational)
	always @(*) begin
		
		next_state = A; // default
	
		case(state)
			A: next_state = w ? C : B;
			B: next_state = w ? A : E;
			C: next_state = w ? A : D;
			D:	next_state = w ? A : F;
			E: next_state = w ? A : F;
			F: next_state = w ? A : F;
		endcase
	end
	
	// 3. Output Logic (combinational)
	
	always @(*) begin
	
		Y = 3'b111; //default
		
		case(state)
			A: Y = 3'b111; //no pattern
			B: Y = 3'b000; //pattern 1
			B: Y = 3'b001; //pattern 2
			B: Y = 3'b010; //pattern 3
			B: Y = 3'b011; //pattern 4
			B: Y = 3'b100; //pattern 5
		endcase
	end
	
endmodule
