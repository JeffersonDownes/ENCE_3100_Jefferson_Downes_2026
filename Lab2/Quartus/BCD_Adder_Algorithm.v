// Part VI: the PDF's algorithm, intentionally using +, >, and if/else.
// Five-bit intermediates prevent overflow when a digit sum reaches 16..19.
module BCD_Adder_Algorithm(
    input [7:0] A, input [7:0] B,
    output reg [3:0] S0, output reg [3:0] S1, output reg [3:0] S2
);
    reg [4:0] T0, T1, Z0, Z1;
    reg c1, c2;
    always @* begin
        T0 = {1'b0, A[3:0]} + {1'b0, B[3:0]};
        if (T0 > 5'd9) begin
            Z0 = 5'd10;
            c1 = 1'b1;
        end else begin
            Z0 = 5'd0;
            c1 = 1'b0;
        end
        S0 = T0 - Z0;

        T1 = {1'b0, A[7:4]} + {1'b0, B[7:4]} + {4'b0000, c1};
        if (T1 > 5'd9) begin
            Z1 = 5'd10;
            c2 = 1'b1;
        end else begin
            Z1 = 5'd0;
            c2 = 1'b0;
        end
        S1 = T1 - Z1;
        S2 = {3'b000, c2};
    end
endmodule
