module main(
	//pinout assignmnet
	input		[9:0] SW,
	output	[9:0] LEDR,
	
	input 	MAX10_CLK1_50,
	output	[7:0]		HEX0,
	output	[7:0]		HEX1,
	output	[7:0]		HEX2,
	output	[7:0]		HEX3,
	output	[7:0]		HEX4,
	output	[7:0]		HEX5
);
	//assign LEDR[9:0] = SW[9:0];
	//Part II
	
	wire [3:0] w_m;
	
	//7 Segment Display
	Seg7_Decoder D0(
	.m(SW[3:0]), //4bits
	.out(HEX0) //8bits
);
	//Multiplexers
		wire w_z;
		assign w_z = SW[9];
		
	mux_2_1 M0(
		.s(w_z),
		.x(SW[0]),
		.y(1'b0),
		.m(w_m[0])
	);
	mux_2_1 M1(
		.s(w_z),
		.x(SW[1]),
		.y(1'b0),
		.m(w_m[1])
	);
	mux_2_1 M2(
		.s(w_z),
		.x(SW[2]),
		.y(1'b0),
		.m(w_m[2])
	);
	mux_2_1 M3(
		.s(w_z),
		.x(SW[3]),
		.y(1'b0),
		.m(w_m[3])
	);

endmodule