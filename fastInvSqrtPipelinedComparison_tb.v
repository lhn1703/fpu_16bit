module fastInvSqrtPipelinedComparison_tb();
    wire [1:0] OFUF0, OFUF1;
    wire done0, done1;
    wire [15:0] result0, result1;
    reg [15:0] Xin;
    reg reset = 0, clk = 0;

    reg [50000:0] cycleCounter = 0;

    fastInvSqrt u000 (OFUF0, done0, result0, Xin, reset, clk);
    fastInvSqrtPipelined u001 (OFUF1, done1, result1, Xin, reset, clk);
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
		#300;
        Xin = 16'h71C0; //11776, works: expecting 0x20B7
        #10 reset = 1;
        #10 reset = 0;
        #400 $stop;
    end

endmodule
