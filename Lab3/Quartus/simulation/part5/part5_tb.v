`timescale 1ns/1ps
module part5_tb;
	reg [9:0] SW = 10'h000;
	reg [1:0] KEY = 2'b11;
	wire [7:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;

	main dut(
		.SW(SW),
		.KEY(KEY),
		.HEX0(HEX0),
		.HEX1(HEX1),
		.HEX2(HEX2),
		.HEX3(HEX3),
		.HEX4(HEX4),
		.HEX5(HEX5)
	);

	// Expected active-low display bytes, ordered HEX3 through HEX0.
	task check_displays;
		input [31:0] expected;
		begin
			#1;
			if ({HEX3, HEX2, HEX1, HEX0} !== expected ||
				HEX4 !== 8'hFF || HEX5 !== 8'hFF) begin
				$display("FAIL at %0t: displays=%h expected=%h", $time,
					{HEX3, HEX2, HEX1, HEX0}, expected);
				$fatal(1);
			end
		end
	endtask

	initial begin
		#2;
		KEY[0] = 0;
		check_displays(32'hC0C0C0C0); // Reset: A=00, B=00.
		KEY[0] = 1;
		SW = 10'h012;
		KEY[1] = 0;
		check_displays(32'hC0C0F9A4); // Falling edge does not load A.
		KEY[1] = 1;
		check_displays(32'hF9A4F9A4); // Rising edge: A=12, B=12.
		SW = 10'h0AB;
		check_displays(32'hF9A48883); // Hold: A=12, B=AB.
		KEY[1] = 0;
		check_displays(32'hF9A48883);
		KEY[1] = 1;
		check_displays(32'h88838883); // Recapture: A=AB, B=AB.
		SW = 10'h0CD;
		check_displays(32'h8883C6A1);
		KEY[0] = 0;
		check_displays(32'hC0C0C6A1); // Clear A with clock held high.
		SW = 10'h0EF;
		check_displays(32'hC0C0868E); // Live B still follows switches.
		KEY[0] = 1;
		check_displays(32'hC0C0868E); // Releasing reset does not load A.
		SW = 10'h3EF;
		check_displays(32'hC0C0868E); // SW9 and SW8 are unused.
		$display("PASS: load, hold, recapture, asynchronous reset, live hex decoding, and unused outputs.");
		$finish;
	end
endmodule
