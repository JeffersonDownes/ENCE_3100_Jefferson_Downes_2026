`default_nettype none

module uart_display #(
    parameter [27:0] HOLD_CYCLES = 28'd250000000
)(
    input clk,
    input rx_ready,
    input [7:0] rx_data,
    output [7:0] leds,
    output [7:0] hex
);

    localparam IDLE = 1'b0;
    localparam HOLD = 1'b1;
    localparam [27:0] LAST_COUNT = HOLD_CYCLES - 28'd1;

    reg state = IDLE;
    reg [27:0] count = 28'd0;
    reg [7:0] held_char = 8'h00;
    wire [7:0] segments;

    // A new byte wins if it arrives on the timeout edge.
    always @(posedge clk) begin
        if (rx_ready) begin
            held_char <= rx_data;
            count <= 28'd0;
            state <= HOLD;
        end else if (state == HOLD) begin
            if (count == LAST_COUNT) begin
                count <= 28'd0;
                state <= IDLE;
            end else begin
                count <= count + 28'd1;
            end
        end
    end

    char2seg decoder(.char(held_char), .HEX0(segments));

    assign leds = state == HOLD ? held_char : 8'h00;
    assign hex = state == HOLD ? segments : 8'hFF;

endmodule

`default_nettype wire
