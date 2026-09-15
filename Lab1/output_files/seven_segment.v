module seven_segment(
    input  [2:0] c,
    output [6:0] segments
);

    // Segment 0: top
    assign segments[0] = c[2] | ~c[0];

    // Segment 1: upper right
    assign segments[1] = c[2]
                       | (~c[1] & c[0])
                       | (c[1] & ~c[0]);

    // Segment 2: lower right
    assign segments[2] = c[2]
                       | (~c[1] & c[0])
                       | (c[1] & ~c[0]);

    // Segment 3: bottom
    assign segments[3] = c[2] | (~c[1] & ~c[0]);

    // Segment 4: lower left
    assign segments[4] = c[2];

    // Segment 5: upper left
    assign segments[5] = c[2];

    // Segment 6: middle
    assign segments[6] = c[2] | c[1];

endmodule