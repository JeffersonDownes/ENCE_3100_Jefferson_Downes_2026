// Part VII: the same conditional-subtract stages used in the Logisim circuit.
module Subtract_10_Stage(input [5:0] V, output [5:0] R, output hit);
    assign hit = V > 6'd9;
    assign R = hit ? (V - 6'd10) : V;
endmodule

module Binary6_BCD(input [5:0] V, output [3:0] D0, output [3:0] D1);
    wire [5:0] r1, r2, r3, r4, r5, r6;
    wire h1, h2, h3, h4, h5, h6;
    Subtract_10_Stage s1(.V(V),  .R(r1), .hit(h1));
    Subtract_10_Stage s2(.V(r1), .R(r2), .hit(h2));
    Subtract_10_Stage s3(.V(r2), .R(r3), .hit(h3));
    Subtract_10_Stage s4(.V(r3), .R(r4), .hit(h4));
    Subtract_10_Stage s5(.V(r4), .R(r5), .hit(h5));
    Subtract_10_Stage s6(.V(r5), .R(r6), .hit(h6));
    assign D0 = r6[3:0];
    assign D1 = {3'b000,h1} + {3'b000,h2} + {3'b000,h3}
              + {3'b000,h4} + {3'b000,h5} + {3'b000,h6};
endmodule
