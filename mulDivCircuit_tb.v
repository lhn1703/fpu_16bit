module mulDivCircuit_tb ();
    wire [1:0] OFUF;
    wire done;
    wire [15:0] result;
    reg [15:0] X, Y;
    reg mulDiv, reset = 0, clk = 0;
    mulDivCircuit u1 (OFUF, done, result, X, Y, mulDiv, reset, clk);
    always clk = #5 ~clk;


    initial begin
        //works, expected 0x1E90
        mulDiv = 0;
        X = 16'h4F00; 
        Y = 16'h0B80; 
        #10 reset = 1;
        #10 reset = 0;

        #100;  
        //works, expected 0xECE0 
        X = 16'hD98D;
        Y = 16'h4F08;
        #10 reset = 1;
        #10 reset = 0;

        #100; 
        //works, expected 0xC650 
        mulDiv = 1; 
        #10 reset = 1;
        #10 reset = 0;

        #160; 
        //works, expected underflow
        X = 16'h118D;
        Y = 16'hEF08;
        #10 reset = 1;
        #10 reset = 0;

        #40; 
        //works, expected 0xCA50
        X = 16'h418D;
        Y = 16'hB308;
        #10 reset = 1;
        #10 reset = 0;

        #100 $stop;
    end
    
endmodule

