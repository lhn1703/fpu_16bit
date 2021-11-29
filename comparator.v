module comparator (output reg [2:0] result, input [15:0] X, Y, input clk);
    always @ (posedge clk) begin //{greater than, less than, equal to}
        if (X[15] == 1'b0 && Y[15] == 1'b1) //check the signed bits
            result <= 3'b100; 
        else if (X[15] == 1'b1 && Y[15] == 1'b0)
            result <= 3'b010;
        else if (X[14:10] > Y[14:10]) //check the exponents if the signed bits are equal
            result <= 3'b100; 
        else if (X[14:10] < Y[14:10])
            result <= 3'b010;
        else if (X[9:0] > Y[9:0]) //check the mantissas if the exponents are equal
            result <= 3'b100; 
        else if (X[9:0] < Y[9:0])
            result <= 3'b010;
        else 
            result <= 3'b001;
    end
endmodule
