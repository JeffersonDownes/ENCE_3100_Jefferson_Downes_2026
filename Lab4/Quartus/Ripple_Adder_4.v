// Part III: four explicit full-adder instances, least significant bit first.
module Ripple_Adder_4(
    input [3:0] A, input [3:0] B, input cin,
    output [3:0] S, output cout
);
    wire c1, c2, c3;
    Full_Adder fa0(.a(A[0]), .b(B[0]), .cin(cin), .s(S[0]), .cout(c1));
    Full_Adder fa1(.a(A[1]), .b(B[1]), .cin(c1),  .s(S[1]), .cout(c2));
    Full_Adder fa2(.a(A[2]), .b(B[2]), .cin(c2),  .s(S[2]), .cout(c3));
    Full_Adder fa3(.a(A[3]), .b(B[3]), .cin(c3),  .s(S[3]), .cout(cout));
endmodule
