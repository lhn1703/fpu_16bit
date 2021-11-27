module addSubCircuit_tb ();
    wire [1:0] OFUF;
    wire done;
    wire [15:0] result;
    reg [15:0] X, Y;
    reg addSub, reset = 0, clk = 0;
    addSubCircuit u1 (OFUF, done, result, X, Y, addSub, reset, clk);
    always clk = #5 ~clk;


    initial begin
        addSub = 0;
        X = 16'h0F00;
        Y = 16'h0B80;
        #10 reset = 1;
        #10 reset = 0;
    end
    
endmodule
