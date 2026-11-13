// Part II: comparator, Circuit A, and four explicit one-bit multiplexers.
// Only Boolean assign expressions are used in these components.
module Binary4_BCD(
    input  [3:0] V,
    output [3:0] M,
    output       z
);
    wire [2:0] a;
    assign z = V[3] & (V[2] | V[1]);
    CircuitA adjust(.v(V[2:0]), .out(a));
    mux_2_1 m0(.s(z), .x(V[0]), .y(a[0]), .m(M[0]));
    mux_2_1 m1(.s(z), .x(V[1]), .y(a[1]), .m(M[1]));
    mux_2_1 m2(.s(z), .x(V[2]), .y(a[2]), .m(M[2]));
    mux_2_1 m3(.s(z), .x(V[3]), .y(1'b0), .m(M[3]));
endmodule
