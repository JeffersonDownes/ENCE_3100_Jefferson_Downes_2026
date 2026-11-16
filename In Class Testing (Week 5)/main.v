module main(
	// Board I/Os
	input		MAX10_CLK1_50,
	input 	[9:0]		SW,
	output	[9:0]		LEDR,
	output	[35:0]	GPIO
);

	wire w_clk = MAX10_CLK1_50;

	wire w_tick;
	
	wire w_dir = SW[7];
	wire w_en = SW[8];
	wire w_rst = SW[9];
	
	wire [9:0] w_counter1;
	wire [9:0] w_counter2;
	wire [9:0] w_counter3;
	wire [9:0] w_counter4;
	wire [9:0] w_counter5;
	
	wire [2:0] w_Y;
	
	FSM_Moore U1(
		.clk(SW[1]),
		.reset(w_rst),
		.w(SW[0]),
		.Y(w_Y) 
	);
	
	MUX8_1_10bit MUX0(
		.in0(w_counter1),
		.in1(w_counter2),
		.in2(w_counter3),
		.in3(w_counter4),
		.in4(w_counter5),
		.in5(10'd0),
		.in6(10'd0),
		.in7(10'd0),
		.sel(w_Y),
		.out(LEDR[9:0])
	);
	
	// Patterns
	Pattern1 Patt1 (
		.clk(w_clk),
		.rst(w_rst),
		.en(w_en),
		.dir(w_dir),                 
		.counter(w_counter1)
	);
	
	Pattern2 Patt2 (
		.clk(w_clk),
		.rst(w_rst),
		.en(w_en),
		.dir(w_dir),                  
		.counter(w_counter2)
	);
	
	Pattern3 Patt3 (
		.clk(w_clk),
		.rst(w_rst),
		.en(w_en),
		.dir(w_dir),                  
		.counter(w_counter3)
	);
	
	Pattern4 Patt4 (
		.clk(w_clk),
		.rst(w_rst),
		.en(w_en),
		.dir(w_dir),                 
		.counter(w_counter4)
	);
	
	Pattern5 Patt5 (
		.clk(w_clk),
		.rst(w_rst),
		.en(w_en),
		.dir(w_dir),                
		.counter(w_counter5)
	);

endmodule
