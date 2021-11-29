module fastInvSqrt_tb();
    wire [1:0] OFUF;
    wire done;
    wire [15:0] result;
    reg [15:0] Xin;
    reg reset = 0, clk = 0;

    fastInvSqrt u000 (OFUF, done, result, Xin, reset, clk);
    always clk = #5 ~clk;

    initial begin
        #5;
        Xin = 16'h50BB; //37.86, expecting 0x3133
        #10 reset = 1;
        #10 reset = 0;
    end

endmodule
