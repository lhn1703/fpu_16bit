module fastInvSqrtPipelinedComparison_tb();
    wire [1:0] OFUF0, OFUF1;
    wire done0, done1;
    wire [15:0] result0, result1;
    reg [15:0] Xin;
    reg reset = 0, clk = 0;

    reg [50000:0] cycleCounter = 0;

    wire [31:0] xinDec, result0Dec, resul1tDec;
    assign xinDec[31] = Xin[15];
    assign xinDec[30:23] = Xin[14:10] - 15 + 127;
    assign xinDec[22:0] = {Xin[9:0], 13'b0};

    assign resul1tDec[31] = result1[15];
    assign resul1tDec[30:23] = result1[14:10] - 15 + 127;
    assign resul1tDec[22:0] = {result1[9:0], 13'b0};

    assign result0Dec[31] = result0[15];
    assign result0Dec[30:23] = result0[14:10] - 15 + 127;
    assign result0Dec[22:0] = {result0[9:0], 13'b0};

    fastInvSqrt u000 (OFUF0, done0, result0, Xin, reset, clk);
    fastInvSqrtPipelined u001 (OFUF1, done1, result1, Xin, reset, clk);
    always clk = #5 ~clk; 
    always @ (posedge clk) begin
        if (reset)
            cycleCounter <= 0;
        else
            cycleCounter <= cycleCounter + 1;
    end
    initial begin
        #5;
        Xin = 16'h50BB; //37.86, works: expecting 0x3133
        #10 reset = 1;
        #10 reset = 0;
        #300;
        Xin = 16'h4DE1; //23.52, works: expecting 0x3298
        #10 reset = 1;
        #10 reset = 0;
		#300;
        Xin = 16'h71C0; //11776, works: expecting 0x20B7
        #10 reset = 1;
        #10 reset = 0;
        #320;
        Xin = 16'h0DB4; //0.0003481, works: expecting 0x52B2
        #10 reset = 1;
        #10 reset = 0;
        #320 $stop;
    end

endmodule
