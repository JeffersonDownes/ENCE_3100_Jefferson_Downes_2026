
`default_nettype none

module main(
	// Board I/Os
	input		MAX10_CLK1_50,
	input 	[9:0]		SW,
	output	[9:0]		LEDR,
	inout		[35:0]	GPIO,
	output 	[7:0]		HEX0
);

	wire w_clk = MAX10_CLK1_50;
	wire RxD_data_ready;
	wire [7:0] RxD_data;

	async_receiver RX(
		.clk(w_clk), 
		.RxD(GPIO[35]), 
		.RxD_data_ready(RxD_data_ready), 
		.RxD_data(RxD_data)
	);
	async_transmitter TX(
		.clk(w_clk), 
		.TxD(GPIO[33]), 
		.TxD_start(RxD_data_ready), 
		.TxD_data(RxD_data)
	);
	// The display timer runs independently of the UART echo.
	uart_display Display(
		.clk(w_clk),
		.rx_ready(RxD_data_ready),
		.rx_data(RxD_data),
		.leds(LEDR[7:0]),
		.hex(HEX0)
	);

	assign LEDR[9:8] = 2'b00;

endmodule

`default_nettype wire
