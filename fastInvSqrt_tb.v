module fastInvSqrt_tb();
    wire [1:0] OFUF;
    wire done;
    wire [15:0] result;
    reg [15:0] Xin;
    reg reset = 0, clk = 0;

    reg [50000:0] cycleCounter = 0;

    fastInvSqrt u000 (OFUF, done, result, Xin, reset, clk);
    always clk = #5 ~clk;
    always cycleCounter = #10 cycleCounter + 1;
    initial begin
        #5;
        Xin = 16'h50BB; //37.86, works: expecting 0x3133
        #10 reset = 1;
        #10 reset = 0;
        #500;
        Xin = 16'h4DE1; //23.52, works: expecting 0x3298
        #10 reset = 1;
        #10 reset = 0;
    end

endmodule
