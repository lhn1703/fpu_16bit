module add_sub (
    output reg [1:0] OFUF, output reg done, output reg [15:0] result,
    input [15:0] X, Y,
    input addSub, reset, clk
    ); //addSub is 0 if add, 1 if subtract
    reg [3:0] ps, ns;
    reg [15:0] x, y;

    `define x_exp x[14:10];
    `define y_exp y[14:10];
    `define x_man x[9:0];
    `define y_man y[9:0];


    always @ (posedge clk) begin //moore synchronous reset
        if (reset) begin
            ps <= 0;
            ns <= 0;
        end
        else
            ps <= ns;
    end

    //posedge clk in case a state loops back to itself and requires the same 
    //computations done
    always @ (ps) begin 
        case (ps)
            0: begin //load x and y into temp storage
                x = X;
                y = Y;
                done = 0;
                if (x == 0 || y == 0)
                    ns = 1;
                else begin
                    if (addSub) //1 for sub
                        ns = 2;
                    else begin //0 for add
                        if (`x_exp == `y_exp) //exp equal?
                            ns = 5;
                        else //exp not equal
                            ns = 3;
                    end
                end
            end
            1: begin
                if (x != 0)
                    result = x;
                else if (y != 0)
                    result = y;                   
                done = 1;
            end
            2: begin
                y[15] = ~y[15];
                if (`x_exp == `y_exp) //exp equal?
                            ns = 5;
                else //exp not equal
                            ns = 3;
            end
            3: begin
                if (`x_exp < `y_exp) begin //if x is smaller exp
                    `x_exp = `x_exp + 1; //increment smaller exp
                    `x_man = `x_man >> 1; //right shift mantissa
                    if (`x_man == 0)
                        ns = 4;
                    else begin
                        if (`x_exp == `y_exp) //exp equal?
                            ns = 5;
                        else //exp not equal /// BUG will looping back to 3 again trigger the logic again?
                            ns = 3;
                    end
                end
                else begin //if y is smaller exp
                    `y_exp = `y_exp + 1; //increment smaller exp
                    `y_man = `y_man >> 1; //right shift mantissa
                    if (`y_man == 0)
                        ns = 4;
                    else begin
                        if (`x_exp == `y_exp) //exp equal?
                            ns = 5;
                        else //exp not equal /// BUG will looping back to 3 again trigger the logic again?
                            ns = 3;
                    end
                end
                //////looping back to 3 again will trigger the logic again?
            end
        endcase
    end

endmodule
