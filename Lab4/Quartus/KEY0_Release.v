module KEY0_Release #(
	parameter DEBOUNCE_CYCLES = 1_000_000
)(
	input clk,
	input clear,
	input key,
	output reg ena = 1'b0
);

	// Two flip-flops synchronize the active-low button.
	(* preserve *) reg key_meta = 1'b1;
	(* preserve *) reg key_sync = 1'b1;
	reg key_stable = 1'b1;
	localparam COUNT_WIDTH = (DEBOUNCE_CYCLES > 1) ?
		$clog2(DEBOUNCE_CYCLES) : 1;
	reg [COUNT_WIDTH-1:0] count = 0;

	always @(posedge clk) begin
		key_meta <= key;
		key_sync <= key_meta;
	end

	// Accept a new state after 20 ms at 50 MHz.
	always @(posedge clk) begin
		ena <= 1'b0;
		if(clear) begin
			key_stable <= 1'b1;
			count <= 0;
		end
		else if(key_sync == key_stable)
			count <= 0;
		else if(count == DEBOUNCE_CYCLES - 1) begin
			key_stable <= key_sync;
			count <= 0;
			// Only a stable press followed by release counts.
			if(key_sync)
				ena <= 1'b1;
		end
		else
			count <= count + 1'b1;
	end

endmodule
