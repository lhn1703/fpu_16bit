module addSubCircuit_tb ();
    wire [1:0] OFUF;
    wire done;
    wire [15:0] result;
    reg [15:0] X, Y;
    reg addSub, reset = 0, clk = 0;
    addSubCircuit u1 (OFUF, done, result, X, Y, addSub, reset, clk);
    always clk = #5 ~clk;


    initial begin
        //works, expected result 0x1160
        addSub = 0;
        X = 16'h0F00; //0_1100000000_00011
        Y = 16'h0B80; //0_1110000000_00010
        #10 reset = 1;
        #10 reset = 0;

        #100;    
        //works, expected result 0xD8AC
        X = 16'hD98D;
        Y = 16'h4F08;
        #10 reset = 1;
        #10 reset = 0;

        #100; 
        //works, expected result 0xDA6E
        addSub = 1; //subtraction
        #10 reset = 1;
        #10 reset = 0;

        #100; 
        //works, expected result 0x6F08
        X = 16'h118D;
        Y = 16'hEF08;
        #10 reset = 1;
        #10 reset = 0;

        #100; 
        //works, expected result 0x41FD, truncated actual 0x41FE
        X = 16'h418D;
        Y = 16'hB308;
        #10 reset = 1;
        #10 reset = 0;

        #100 $stop;
    end
    
endmodule
