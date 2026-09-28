// Part V: two instances of the Part IV circuit; decimal carry links the stages.
module BCD_Adder_2(
    input [7:0] A, input [7:0] B,
    output [3:0] S0, output [3:0] S1, output [3:0] S2, output error
);
    wire c1, c2, e0, e1;
    BCD_Adder_1 units(.A(A[3:0]), .B(B[3:0]), .cin(1'b0),
        .S0(S0), .S1(c1), .raw_sum(), .raw_carry(), .error(e0));
    BCD_Adder_1 tens(.A(A[7:4]), .B(B[7:4]), .cin(c1),
        .S0(S1), .S1(c2), .raw_sum(), .raw_carry(), .error(e1));
    assign S2 = {3'b000, c2};
    assign error = e0 | e1;
endmodule
