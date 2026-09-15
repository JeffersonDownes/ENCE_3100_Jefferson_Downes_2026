module mux_5_1_3b(
    input  [2:0] s,
    input  [2:0] u,
    input  [2:0] v,
    input  [2:0] w,
    input  [2:0] x,
    input  [2:0] y,
    output [2:0] m
);

    wire [2:0] uv;
    wire [2:0] wx;
    wire [2:0] uvwx;
    wire [2:0] result;

    // Select between U and V.
    mux_2_1_3b MUX0(
        .s(s[0]),
        .x(u),
        .y(v),
        .m(uv)
    );

    // Select between W and X.
    mux_2_1_3b MUX1(
        .s(s[0]),
        .x(w),
        .y(x),
        .m(wx)
    );

    // Select between the first two pairs.
    mux_2_1_3b MUX2(
        .s(s[1]),
        .x(uv),
        .y(wx),
        .m(uvwx)
    );

    // Select between U/V/W/X and Y.
    mux_2_1_3b MUX3(
        .s(s[2]),
        .x(uvwx),
        .y(y),
        .m(result)
    );

    // Output zero for unused selections 101, 110, and 111.
    assign m = (s > 3'b100) ? 3'b000 : result;

endmodule