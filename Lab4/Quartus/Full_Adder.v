// Part III, Figure 2a: two XOR gates and a mux for carry-out.
module Full_Adder(input a, input b, input cin, output s, output cout);
    wire p;
    assign p = a ^ b;
    assign s = p ^ cin;
    mux_2_1 carry_mux(.s(p), .x(b), .y(cin), .m(cout));
endmodule
