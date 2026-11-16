module main(
    input  [9:0] SW,
    input        MAX10_CLK1_50,
    output [9:0] LEDR,
    output [7:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5
);
	/*
	wire[3:0] count_4bit
	parameterized_counter u_counter_4 (
		.clk(SW[9]),
		.rst_n(SW[8]),
		.count(count_4bit)
	);

	wire [7:0] count_8bit;
	parameterized_counter #(.WIDTH(8)) u_counter_8 (
		.clk(SW[9]),
		.rst_n(SW[8]),
		.count(count_4bit)
	);

	
	LEDArray led_array (
		.SW(SW[7:0]),
		.LED(LEDR[7:0])
	);
	*/
	 wire [7:0] A;
    wire [7:0] B;
    wire [7:0] Sum;
    wire Cout;

    assign A = {4'b0, SW[3:0]};
    assign B = {4'b0, SW[7:4]};

    Ripple_Carry_Adder RCA (
        .A(A),
        .B(B),
        .Cin(SW[8]),
        .Sum(Sum),
        .Cout(Cout)
    );

    assign LEDR[7:0] = Sum;
    assign LEDR[8] = Cout;
    assign LEDR[9] = 1'b0;
endmodule