module addSubCircuit (
    output reg [1:0] OFUF, output reg done, output reg [15:0] result,
    input [15:0] X, Y,
    input addSub, reset, clk
    ); //addSub is 0 if add, 1 if subtract
    //reg [3:0] ps, ns;
    //reg [15:0] x, y;

    reg [3:0] state;
    reg xSign, ySign;
    reg [4:0] xExp, yExp;
    reg [9:0] xMan, yMan;

    reg [4:0] tempExp;
    reg [9:0] tempMan;

    always @ (*) begin
        if (xExp < yExp) begin //if x is smaller exp
            tempExp = xExp + 1; //increment smaller exp
            tempMan = xMan >> 1; //right shift mantissa
        end else if (xExp > yExp) begin
            tempExp = yExp + 1; //increment smaller exp
            tempMan = yMan >> 1; //right shift mantissa
        end 
    end

    always @ (posedge clk or posedge reset) begin
        if (reset) begin
            state <= 0;
            xSign <= X[15];
            ySign <= Y[15];
            xExp <= X[14:10];
            yExp <= Y[14:10];
            xMan <= X[9:0];
            yMan <= Y[9:0];
            done <= 0;
        end
        else begin
            case (state) 
                0: begin
                    // xSign <= X[15];
                    // ySign <= Y[15];
                    // xExp <= X[14:10];
                    // yExp <= Y[14:10];
                    // xMan <= X[9:0];
                    // yMan <= Y[9:0];
                    // done <= 0;

                    if (X == 0 || Y == 0)
                        state <= 1;
                    else begin
                        if (addSub) //1 for sub
                            state <= 2;
                        else begin //0 for add
                            if (xExp == yExp) //exp equal?
                                state <= 5;
                            else //exp not equal
                                state <= 3;
                        end
                    end
                end
                1: begin
                    if (X != 0)
                        result <= X;
                    else if (Y != 0)
                        result <= Y;                   
                    done <= 1;
                end
                2: begin
                    ySign <= ~ySign;
                    if (xExp == yExp) //exp equal?
                            state <= 5;
                    else //exp not equal
                                state <= 3;
                end
                3: begin
                    if (xExp < yExp) begin
                        xExp <= tempExp;
                        xMan <= tempMan;
                        if (tempMan == 0)
                            state <= 4;
                        else begin
                            if (tempExp == yExp) //exp equal?
                                state <= 5;
                            else 
                                state <= 3;
                        end
                    end else if (xExp < yExp) begin
                        yExp <= tempExp;
                        yMan <= tempMan;
                        if (tempMan == 0)
                            state <= 4;
                        else begin
                            if (tempExp == xExp) //exp equal?
                                state <= 5;
                            else 
                                state <= 3;
                        end
                    end
                end                
            endcase
        end
    end
endmodule
    /*always @ (posedge clk or posedge reset) begin
        if (reset) begin
            state <= 0;
            xSign <= X[15];
            ySign <= Y[15];
            xExp <= X[14:10];
            yExp <= Y[14:10];
            xMan <= X[9:0];
            yMan <= Y[9:0];
        end else begin
            case(state) 
                0: begin
                    
                end

            endcase
        end

    end*/
