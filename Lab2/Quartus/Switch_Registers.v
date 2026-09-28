// DE10-Lite adaptation for Parts I, V, and VI.
// Set SW[7:0], then press active-low KEY0 to load A or KEY1 to load B.
// Hold switches steady while pressing. Bounce may repeat the same load;
// it cannot increment or otherwise change a stable switch value.
module Switch_Registers(
    input clk, input [1:0] key_n, input [7:0] switches,
    output reg [7:0] A = 8'h00,
    output reg [7:0] B = 8'h00
);
    reg [1:0] key_meta = 2'b11;
    reg [1:0] key_sync = 2'b11;
    reg [1:0] key_previous = 2'b11;
    always @(posedge clk) begin
        key_meta <= key_n;
        key_sync <= key_meta;
        key_previous <= key_sync;
        if (key_previous[0] & ~key_sync[0]) A <= switches;
        if (key_previous[1] & ~key_sync[1]) B <= switches;
    end
endmodule
