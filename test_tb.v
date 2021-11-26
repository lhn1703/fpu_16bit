module test_tb();
    reg [3:0] in = 0;
    wire [3:0] out;
    reg reset = 0, transition = 0, clk = 0;
    test u1(out, in, reset, clk);
    always clk = #5 ~clk;
    initial begin
        #10 reset = 1;
        #10 reset = 0;
    end

endmodule
