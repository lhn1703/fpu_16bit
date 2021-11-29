module fpu_16bit_tb ();
    wire [1:0] OFUF;
    wire done;
    wire [15:0] result;
    wire [2:0] compResult;
    reg [15:0] X, Y;
    reg [1:0] opcode;
    reg reset = 0, clk = 0;

    fpu_16bit u00 (OFUF, done, result, compResult, X, Y, opcode, reset, clk);
    always clk = #5 ~clk;

    initial begin
        //works, expected result 0x1160
        opcode = 0;
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
        opcode = 1; //subtraction
        #10 reset = 1;
        #10 reset = 0;

        #100; 
        //works, expected result 0x6F08
        X = 16'h118D;
        Y = 16'hEF08;
        #10 reset = 1;
        #10 reset = 0;

        #200; 
        //works, expected result 0x41FD, truncated actual 0x41FD
        X = 16'h418D;
        Y = 16'hB308;
        #10 reset = 1;
        #10 reset = 0;

        #100;
        //works, expected 0x1E90
        opcode = 2;
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
        opcode = 3; 
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

        //#100 $stop;
        #100;
        //works, expected 0x6598
        opcode = 2;
        X = 16'h50BB; //37.84
        Y = X;
        #10 reset = 1;
        #10 reset = 0;

        #200 $stop;
    end
    
endmodule
