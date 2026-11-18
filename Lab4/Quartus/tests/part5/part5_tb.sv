`timescale 1ns/1ps
module interval_tb;
	reg clk=0;
	reg [9:0] SW=10'd1;
	wire [9:0] LEDR;
	wire [7:0] HEX0,HEX1,HEX2,HEX3,HEX4,HEX5;
	time first,second;
	main dut(.SW(SW),.KEY(2'b11),.MAX10_CLK1_50(clk),.LEDR(LEDR),
		.HEX0(HEX0),.HEX1(HEX1),.HEX2(HEX2),.HEX3(HEX3),.HEX4(HEX4),.HEX5(HEX5));
	always #10 clk=~clk;
	initial begin
		if(dut.CLK_1.CLOCK_CYCLES != 50000000) $fatal(1,"wrong default");
		@(posedge dut.w_ena); first=$time;
		if(first != 999999970) $fatal(1,"first enable timing");
		if({HEX5,HEX4,HEX3,HEX2,HEX1,HEX0} !== 48'hFF8986C7C7C0) $fatal(1,"early shift");
		@(negedge dut.w_ena);
		if($time-first != 20) $fatal(1,"enable pulse width");
		#1; if({HEX5,HEX4,HEX3,HEX2,HEX1,HEX0} !== 48'h8986C7C7C0FF) $fatal(1,"first shift");
		@(posedge dut.w_ena); second=$time;
		if(second-first != 1000000000) $fatal(1,"enable spacing");
		@(negedge dut.w_ena); #1;
		if({HEX5,HEX4,HEX3,HEX2,HEX1,HEX0} !== 48'h86C7C7C0FF89) $fatal(1,"second shift");
		SW[0]=0; #1;
		if({HEX5,HEX4,HEX3,HEX2,HEX1,HEX0} !== 48'h86C7C7C0FF89) $fatal(1,"asynchronous reset");
		@(posedge clk); #1;
		if({HEX5,HEX4,HEX3,HEX2,HEX1,HEX0} !== 48'hFF8986C7C7C0 || dut.CLK_1.count !== 0) $fatal(1,"reset");
		$display("PASS: production 50,000,000 cycles; 1 s spacing; 20 ns enable; two natural scroll steps; synchronous reset"); $finish;
	end
	initial begin #2000000100; $fatal(1,"timeout"); end
endmodule

module part5_tb;
	reg clk=0;
	reg [9:0] SW=0;
	reg [1:0] KEY=2'b11;
	wire [9:0] LEDR;
	wire [7:0] HEX0,HEX1,HEX2,HEX3,HEX4,HEX5;
	wire clear=~SW[0];
	wire ena=dut.w_ena;
	wire [47:0] display={HEX5,HEX4,HEX3,HEX2,HEX1,HEX0};
	wire [47:0] word_text={letter(HEX5),letter(HEX4),letter(HEX3),letter(HEX2),letter(HEX1),letter(HEX0)};
	integer phase=0,updates=0,seen=0;
	main dut(.SW(SW),.KEY(KEY),.MAX10_CLK1_50(clk),.LEDR(LEDR),
		.HEX0(HEX0),.HEX1(HEX1),.HEX2(HEX2),.HEX3(HEX3),.HEX4(HEX4),.HEX5(HEX5));
	defparam dut.CLK_1.CLOCK_CYCLES=5;
	always #10 clk=~clk;
	function [7:0] letter(input [7:0] segments);
		case(segments)
			8'hFF:letter="_"; 8'h89:letter="H";
			8'h86:letter="E"; 8'hC7:letter="L";
			8'hC0:letter="O"; default:letter="?";
		endcase
	endfunction
	function [47:0] expected(input integer step);
		case(step)
			0:expected=48'hFF8986C7C7C0;
			1:expected=48'h8986C7C7C0FF;
			2:expected=48'h86C7C7C0FF89;
			3:expected=48'hC7C7C0FF8986;
			4:expected=48'hC7C0FF8986C7;
			5:expected=48'hC0FF8986C7C7;
		endcase
	endfunction
	always @(posedge clk) begin
		if(clear) phase=0;
		else if(ena) begin phase=(phase+1)%6; updates=updates+1; end
		#1;
		if(display !== expected(phase)) $fatal(1,"pattern/hold/reset mismatch at phase %0d",phase);
		if(LEDR !== 0) $fatal(1,"LED output");
		seen=seen | (1<<phase);
	end
	// No output may change between rising clock edges, even during reset.
	reg [47:0] last_display=48'hFF8986C7C7C0;
	always @(negedge clk) last_display=display;
	always @(display) if($time>0 && clk===0) $fatal(1,"display changed without clock edge");
	initial begin
		#20; SW[0]=1;
		#1250; SW[0]=0;
		#40; SW[0]=1;
		#650;
		if(seen!=63 || updates<18) $fatal(1,"insufficient coverage");
		$display("PASS: all six frames, leftward movement, repeated wrap, hold, reset/restart, segment codes, decimal points and LEDs"); $finish;
	end
	// Unused inputs must not affect the scrolling display.
	initial begin #160;KEY=0;SW[9:1]=9'h1FF;#20;KEY=3;SW[9:1]=0;end
endmodule
