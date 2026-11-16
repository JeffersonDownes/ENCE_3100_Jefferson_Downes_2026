module Full_Adder(
	input a,
	input b,
	input Cin,
	output Sum,
	output Cout
);
	
	assign Sum = a ^ b ^ Cin;
	assign Cout = (A & B) | (Cin & (A ^ B));
	
endmodule
