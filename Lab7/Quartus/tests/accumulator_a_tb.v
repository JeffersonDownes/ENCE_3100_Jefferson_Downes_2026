`timescale 1ns/1ps
`default_nettype none

module accumulator_a_tb;
	reg MainClock = 0;
	reg ClearA = 0;
	reg LatchA = 0;
	reg EnableA = 0;
	reg [3:0] A = 0;
	wire [3:0] IB_BUS;
	wire [3:0] AluA;
	reg [3:0] stored;
	integer value;
	integer checks = 0;

	Accumulator_A dut(
		.MainClock(MainClock),
		.ClearA(ClearA),
		.LatchA(LatchA),
		.EnableA(EnableA),
		.A(A),
		.IB_BUS(IB_BUS),
		.AluA(AluA)
	);

	task check;
		input [3:0] expected_register;
		input [3:0] expected_bus;
		begin
			#1;
			if (AluA !== expected_register || IB_BUS !== expected_bus) begin
				$display("FAIL at %0t: AluA=%b expected=%b, IB_BUS=%b expected=%b",
					$time, AluA, expected_register, IB_BUS, expected_bus);
				$fatal(1, "Accumulator A check failed");
			end
			checks = checks + 1;
		end
	endtask

	initial begin
		$dumpfile("accumulator_a.vcd");
		$dumpvars(0, accumulator_a_tb);

		// Initialization: clear is synchronous and wins over load.
		ClearA = 1;
		LatchA = 1;
		A = 4'hF;
		#4 MainClock = 1;
		check(4'h0, 4'bzzzz);
		#4 MainClock = 0;
		ClearA = 0;
		LatchA = 0;
		EnableA = 1;
		stored = 0;
		check(stored, stored);

		// Exercise every 4-bit value: load edge, retention, bus enable, clear.
		for (value = 0; value < 16; value = value + 1) begin
			A = value;
			LatchA = 1;
			check(stored, stored);
			#4 MainClock = 1;
			stored = value;
			check(stored, stored);
			A = ~value;
			check(stored, stored);
			#4 MainClock = 0;
			check(stored, stored);
			LatchA = 0;
			#4 MainClock = 1;
			check(stored, stored);
			EnableA = 0;
			check(stored, 4'bzzzz);
			EnableA = 1;
			check(stored, stored);
			ClearA = 1;
			LatchA = 1;
			check(stored, stored);
			#4 MainClock = 0;
			check(stored, stored);
			#4 MainClock = 1;
			stored = 0;
			check(stored, stored);
			#4 MainClock = 0;
			ClearA = 0;
			LatchA = 0;
		end

		// Loading is independent of the output enable.
		EnableA = 0;
		A = 4'hA;
		LatchA = 1;
		#4 MainClock = 1;
		check(4'hA, 4'bzzzz);
		EnableA = 1;
		check(4'hA, 4'hA);
		$display("PASS: Accumulator A, %0d checks", checks);
		$finish;
	end

endmodule

`default_nettype wire
