module comparator_tb();
    reg [15:0] x, y;
    reg clk = 0;
    wire [2:0] result;
    always clk = #5 ~clk;

    comparator u0 (result, x, y, clk);

    initial begin
        //equal
        x = 0;
        y = 0;

        #10; //x larger
        x = 16'h543E; //67.9
        y = 16'h5092; //36.57

        #10; //y larger
        y = 16'h717C; //11232

        #10; //x larger
        y = 16'hDD43; //-68.2

        #10; //y larger
        x = 16'hD8EA; //-157.3
        
        #10; //y larger
        y = 16'h0DD8; //0.0003567

        #10; //equal
        x = 16'h0DD8; //0.0003567

        #10 $stop;
    end
endmodule
