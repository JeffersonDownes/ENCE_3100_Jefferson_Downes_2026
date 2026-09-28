// Part IV: structural/Boolean BCD addition, without if/case/arithmetic operators.
// Decimal carry k is true for raw sums 10..19. Adding 6 then yields units 0..9.
module BCD_Adder_1(
    input [3:0] A, input [3:0] B, input cin,
    output [3:0] S0, output S1,
    output [3:0] raw_sum, output raw_carry, output error
);
    wire [3:0] correction;
    wire unused_carry;
    Ripple_Adder_4 binary_sum(.A(A), .B(B), .cin(cin),
        .S(raw_sum), .cout(raw_carry));
    assign S1 = raw_carry | (raw_sum[3] & (raw_sum[2] | raw_sum[1]));
    assign correction = {1'b0, S1, S1, 1'b0};
    Ripple_Adder_4 decimal_correction(.A(raw_sum), .B(correction), .cin(1'b0),
        .S(S0), .cout(unused_carry));
    assign error = (A[3] & (A[2] | A[1])) | (B[3] & (B[2] | B[1]));
endmodule
