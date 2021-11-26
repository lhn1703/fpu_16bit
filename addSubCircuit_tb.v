module addSubCircuit_tb ();
    wire [1:0] OFUF;
    wire done;
    wire [15:0] result;
    reg [15:0] X = 16'b0_00001_1111111111, Y = 16'b0_10101_1111111111;
    reg addSub = 0, reset = 0, clk = 0;
    addSubCircuit u1 (OFUF,done,result,X, Y,addSub, reset, clk);
    always clk = #5 ~clk;


    initial begin
        #10 reset = 1;
        #10 reset = 0;
    end
    
endmodule
