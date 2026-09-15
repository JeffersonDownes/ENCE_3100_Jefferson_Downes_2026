module mux_2_1_3b(
    input        s,
    input  [2:0] x,
    input  [2:0] y,
    output [2:0] m
);

    mux_2_1 MUX0(
        .s(s),
        .x(x[0]),
        .y(y[0]),
        .m(m[0])
    );

    mux_2_1 MUX1(
        .s(s),
        .x(x[1]),
        .y(y[1]),
        .m(m[1])
    );

    mux_2_1 MUX2(
        .s(s),
        .x(x[2]),
        .y(y[2]),
        .m(m[2])
    );

endmodule