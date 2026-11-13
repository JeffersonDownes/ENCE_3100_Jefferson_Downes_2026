// Part II: active-low seven-segment tens digit, showing 0 or 1.
module CircuitB(input z, output [7:0] out);
    assign out[7] = 1'b1;
    assign out[6] = 1'b1;
    assign out[5] = z;
    assign out[4] = z;
    assign out[3] = z;
    assign out[2] = 1'b0;
    assign out[1] = 1'b0;
    assign out[0] = z;
endmodule
