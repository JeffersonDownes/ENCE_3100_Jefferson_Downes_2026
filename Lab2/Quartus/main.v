module main(
    input  [9:0] SW,
    input  [1:0] KEY,
    input        MAX10_CLK1_50,
    output [9:0] LEDR,
    output [7:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5
);
    wire [7:0] stored_A, stored_B;
    Switch_Registers operand_registers(
        .clk(MAX10_CLK1_50), .key_n(KEY), .switches(SW[7:0]),
        .A(stored_A), .B(stored_B)
    );

    

/*
    // BEGIN PART I
    // PART I - Four independent decimal digits.
    Seg7_Decoder p1_d3(.m(stored_A[7:4]), .out(HEX3));
    Seg7_Decoder p1_d2(.m(stored_A[3:0]), .out(HEX2));
    Seg7_Decoder p1_d1(.m(stored_B[7:4]), .out(HEX1));
    Seg7_Decoder p1_d0(.m(stored_B[3:0]), .out(HEX0));
    assign {HEX5, HEX4} = 16'hffff;
    assign LEDR = SW;
    // END PART I
*/


/*
    // BEGIN PART II
    wire [3:0] p2_m;
    wire p2_z;
    Binary4_BCD p2_converter(.V(SW[3:0]), .M(p2_m), .z(p2_z));
    Seg7_Decoder p2_units(.m(p2_m), .out(HEX0));
    CircuitB p2_tens(.z(p2_z), .out(HEX1));
    assign {HEX5, HEX4, HEX3, HEX2} = 32'hffffffff;
    assign LEDR = SW;
    // END PART II
*/

/*
    // BEGIN PART III
    wire [3:0] p3_sum;
    wire p3_cout;
    Ripple_Adder_4 p3_adder(.A(SW[7:4]), .B(SW[3:0]), .cin(SW[8]),
        .S(p3_sum), .cout(p3_cout));
    assign LEDR = ({10{~SW[9]}} & {1'b0, SW[8:0]})
                | ({10{ SW[9]}} & {5'b00000, p3_cout, p3_sum});
    assign {HEX5, HEX4, HEX3, HEX2, HEX1, HEX0} = 48'hffffffffffff;
    // END PART III
*/

/*
    // BEGIN PART IV
    wire [3:0] p4_s0, p4_raw;
    wire p4_s1, p4_carry, p4_error;
    BCD_Adder_1 p4_adder(.A(SW[7:4]), .B(SW[3:0]), .cin(SW[8]),
        .S0(p4_s0), .S1(p4_s1), .raw_sum(p4_raw),
        .raw_carry(p4_carry), .error(p4_error));
    Seg7_Decoder p4_a(.m(SW[7:4]), .out(HEX5));
    Seg7_Decoder p4_b(.m(SW[3:0]), .out(HEX4));
    Seg7_Decoder p4_units(.m(p4_s0), .out(HEX0));
    CircuitB p4_tens(.z(p4_s1), .out(HEX1));
    assign {HEX3, HEX2} = 16'hffff;
    assign LEDR[9] = p4_error;
    assign LEDR[8:0] = ({9{~SW[9]}} & SW[8:0])
                    | ({9{ SW[9]}} & {4'b0000, p4_carry, p4_raw});
    // END PART IV
*/

    // BEGIN PART V
    wire [3:0] p5_s0, p5_s1, p5_s2;
    wire p5_error;
    wire [7:0] p5_a1, p5_a0, p5_b1, p5_b0, p5_h2, p5_h1, p5_h0;
    BCD_Adder_2 p5_adder(.A(stored_A), .B(stored_B),
        .S0(p5_s0), .S1(p5_s1), .S2(p5_s2), .error(p5_error));
    Seg7_Decoder p5_da1(.m(stored_A[7:4]), .out(p5_a1));
    Seg7_Decoder p5_da0(.m(stored_A[3:0]), .out(p5_a0));
    Seg7_Decoder p5_db1(.m(stored_B[7:4]), .out(p5_b1));
    Seg7_Decoder p5_db0(.m(stored_B[3:0]), .out(p5_b0));
    Seg7_Decoder p5_ds2(.m(p5_s2), .out(p5_h2));
    Seg7_Decoder p5_ds1(.m(p5_s1), .out(p5_h1));
    Seg7_Decoder p5_ds0(.m(p5_s0), .out(p5_h0));
    assign HEX5 = SW[9] ? 8'hff : p5_a1;
    assign HEX4 = SW[9] ? 8'hff : p5_a0;
    assign HEX3 = SW[9] ? 8'hff : p5_b1;
    assign HEX2 = SW[9] ? p5_h2 : p5_b0;
    assign HEX1 = SW[9] ? p5_h1 : 8'hff;
    assign HEX0 = SW[9] ? p5_h0 : 8'hff;
    assign LEDR = {p5_error, SW[8:0]};
    // END PART V
endmodule
