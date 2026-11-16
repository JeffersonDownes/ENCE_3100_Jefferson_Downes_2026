`timescale 1ns/1ps
// Tests the actual sections extracted from main.v, not substitute implementations.
module lab2_tb;
    reg clk = 0;
    always #10 clk = ~clk;
    reg [9:0] sw [0:5];
    reg [1:0] key_n [0:5];
    wire [9:0] led [0:5];
    wire [7:0] h0 [0:5], h1 [0:5], h2 [0:5], h3 [0:5], h4 [0:5], h5 [0:5];
    integer checks = 0;
    integer a,b,k,v,i,total,view;
    reg [7:0] packed_a,packed_b;
    reg [47:0] expected_hex;
    reg [9:0] expected_led;
    `define DUT(N,M) M dut``N(.SW(sw[N]),.KEY(key_n[N]),.MAX10_CLK1_50(clk),.LEDR(led[N]),.HEX0(h0[N]),.HEX1(h1[N]),.HEX2(h2[N]),.HEX3(h3[N]),.HEX4(h4[N]),.HEX5(h5[N]));
    `DUT(0,main_idle)
    `DUT(1,main_part_I)
    `DUT(2,main_part_II)
    `DUT(3,main_part_III)
    `DUT(4,main_part_IV)
    `DUT(5,main_part_V)
    `undef DUT

    function automatic [7:0] seg(input integer digit);
        case(digit)
            0:seg=8'hc0; 1:seg=8'hf9; 2:seg=8'ha4; 3:seg=8'hb0;
            4:seg=8'h99; 5:seg=8'h92; 6:seg=8'h82; 7:seg=8'hf8;
            8:seg=8'h80; 9:seg=8'h90; default:seg=8'hxx;
        endcase
    endfunction
    function automatic [7:0] bcd(input integer n);
        bcd=((n/10)<<4)|(n%10);
    endfunction
    task automatic expect_led(input integer part, input [9:0] want);
        begin
            if(led[part] !== want) $fatal(1,"Part %0d LEDR: got %h expected %h SW=%h",part,led[part],want,sw[part]);
            checks=checks+1;
        end
    endtask
    task automatic expect_hex(input integer part,input [47:0] want);
        reg [47:0] got;
        begin
            got={h5[part],h4[part],h3[part],h2[part],h1[part],h0[part]};
            if(got !== want) $fatal(1,"Part %0d HEX5..0: got %h expected %h SW=%h",part,got,want,sw[part]);
            checks=checks+1;
        end
    endtask
    task automatic load(input integer part,input integer which,input [7:0] data);
        begin
            @(negedge clk); sw[part][7:0]=data;key_n[part]=2'b11;
            repeat(5) @(negedge clk);
            key_n[part][which]=0;
            repeat(5) @(negedge clk);
            key_n[part][which]=1;
            repeat(5) @(negedge clk);
        end
    endtask
    initial begin
        for(i=0;i<6;i=i+1) begin sw[i]=0;key_n[i]=3;end
        repeat(8) @(negedge clk);
        // Registers initialize to 00; a held button must not continuously load.
        expect_hex(1,{16'hffff,seg(0),seg(0),seg(0),seg(0)});
        sw[1]=10'h012;key_n[1]=2'b10;
        repeat(5) @(negedge clk);
        sw[1]=10'h034;
        repeat(5) @(negedge clk);
        expect_hex(1,{16'hffff,seg(1),seg(2),seg(0),seg(0)});
        key_n[1]=3;repeat(5) @(negedge clk);

        for(v=0;v<1024;v=v+1) begin
            sw[0]=v;#1;
            expect_led(0,v);expect_hex(0,48'hffffffffffff);
        end
        $display("PASS IDLE: all 1024 switch states");

        for(a=0;a<100;a=a+1) begin
            load(1,0,bcd(a));
            for(b=0;b<100;b=b+1) begin
                load(1,1,bcd(b));
                expect_hex(1,{16'hffff,seg(a/10),seg(a%10),seg(b/10),seg(b%10)});
                expect_led(1,sw[1]);
            end
        end
        $display("PASS PART I: all 10000 valid digit combinations and capture/hold checks");

        for(v=0;v<1024;v=v+1) begin
            sw[2]=v;#1;
            expect_hex(2,{32'hffffffff,seg((v%16)/10),seg((v%16)%10)});
            expect_led(2,v);
        end
        $display("PASS PART II: all 1024 switch states (all 16 values)");

        for(a=0;a<16;a=a+1)for(b=0;b<16;b=b+1)for(k=0;k<2;k=k+1)for(view=0;view<2;view=view+1)begin
            sw[3]=(view<<9)|(k<<8)|(a<<4)|b;total=a+b+k;#1;
            expected_led=view ? total : ((k<<8)|(a<<4)|b);
            expect_led(3,expected_led);expect_hex(3,48'hffffffffffff);
        end
        $display("PASS PART III: 512 additions in both LED views");

        for(a=0;a<16;a=a+1)for(b=0;b<16;b=b+1)for(k=0;k<2;k=k+1)for(view=0;view<2;view=view+1)begin
            sw[4]=(view<<9)|(k<<8)|(a<<4)|b;total=a+b+k;#1;
            expected_led=(view ? total : ((k<<8)|(a<<4)|b)) | (((a>9)||(b>9))<<9);
            expect_led(4,expected_led);
            if(a<10 && b<10)expect_hex(4,{seg(a),seg(b),16'hffff,seg(total/10),seg(total%10)});
            if(h3[4]!==8'hff || h2[4]!==8'hff)$fatal(1,"Part IV unused displays not blank");
        end
        $display("PASS PART IV: all 512 input combinations in both LED views, including errors");

        for(a=0;a<100;a=a+1)begin
            load(5,0,bcd(a));
            for(b=0;b<100;b=b+1)begin
                load(5,1,bcd(b));total=a+b;
                for(view=0;view<2;view=view+1)begin
                    sw[5][9]=view;#1;
                    expected_hex=view ? {24'hffffff,seg(total/100),seg((total/10)%10),seg(total%10)}
                                      : {seg(a/10),seg(a%10),seg(b/10),seg(b%10),16'hffff};
                    expect_hex(5,expected_hex);
                    expect_led(5,{1'b0,sw[5][8:0]});
                end
            end
        end
        // Exercise every invalid nibble value in each of the four positions.
        for(i=0;i<4;i=i+1)for(v=10;v<16;v=v+1)begin
            packed_a=0;packed_b=0;
            case(i)
                0:packed_a[3:0]=v;1:packed_a[7:4]=v;
                2:packed_b[3:0]=v;3:packed_b[7:4]=v;
            endcase
            load(5,0,packed_a);load(5,1,packed_b);
            expect_led(5,{1'b1,sw[5][8:0]});
        end
        $display("PASS PART V: all 10000 valid operand pairs in both display views; invalid-digit flags");
        $display("ALL PASS: %0d output assertions",checks);
        $finish;
    end
    initial begin #100000000; $fatal(1,"Test timeout"); end
endmodule
