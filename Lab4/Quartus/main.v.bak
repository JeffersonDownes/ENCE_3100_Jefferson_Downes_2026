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
	/*PART II
	mux_2_1_8b MUX0(
		.s(SW[0]),
		.x(SW[7:0]),
		.y(8'd255),
		.m(LEDR[7:0])
	);
	*/
	/*Part III
	    mux_5_1_3b MUX0(
        .s(SW[9:7]),
        .u(SW[2:0]),
        .v(SW[3:1]),
        .w(SW[4:2]),
        .x(SW[5:3]),
        .y(SW[6:4]),
        .m(LEDR[2:0])
    );
		//Remaining LEDs show their corresponding switches.
			assign LEDR[9:3] = SW[9:3];
	*/
	//Part IV
	seven_segment DECODER0(
        .c(SW[2:0]),
        .segments(HEX0[6:0])
    );
	//Turn off HEX0's decimal point
	assign HEX0[7] = 1'b1;

endmodule