module addSubCircuit (
    output reg [1:0] OFUF, output reg done, output reg [15:0] result,
    input [15:0] X, Y,
    input addSub, reset, clk
    ); //addSub is 0 if add, 1 if subtract
    //reg [3:0] ps, ns;
    //reg [15:0] x, y;


    reg [3:0] state;
    reg xSign, ySign, zSign;
    reg [4:0] xExp, yExp, zExp;
    reg [10:0] xMan, yMan, zMan; //hidden bit

    reg xBigger;

    reg [4:0] tempExp;
    reg [10:0] tempMan; //state 3 continuous assign
    reg [11:0] addSubManTemp; //hidden and overflow bit state 5 continouous assign
    
    reg [10:0] subNormTemp; //state 9 continouous assign 
    reg [4:0] tempZExp; //state 9 continuous assign
    wire normalized; //state 9 boolean check
    assign normalized = (subNormTemp[10] == 1'b1); //state 9 normalized check

    always @ (*) begin //combinational logic
        //state 3 loop check
        if (xExp < yExp) begin //if x is smaller exp
            tempExp = xExp + 1; //increment smaller exp
            tempMan = xMan >> 1; //right shift mantissa
        end else if (xExp > yExp) begin
            tempExp = yExp + 1; //increment smaller exp
            tempMan = yMan >> 1; //right shift mantissa
        end 
        
        //state 5 check
        if (xSign == ySign) begin //simple addition for both positive
            addSubManTemp = xMan + yMan;
            zSign = xSign;
        end else begin
            if (xBigger) 
                addSubManTemp = xMan - yMan;
            else 
                addSubManTemp = yMan - xMan;
            zSign = (xSign == xBigger); //negative larger x means neg exponent
        end

        //state 9 loop check
        if (addSubManTemp[10] == 1'b0) begin//if the hidden bit is 0
            subNormTemp = zMan << 1;
            tempZExp = zExp - 1;
        end
    end

    always @ (posedge clk or posedge reset) begin
        if (reset) begin
            state <= 0;
            xSign <= X[15];
            ySign <= Y[15];
            xExp <= X[14:10];
            yExp <= Y[14:10];
            xMan <= {1'b1, X[9:0]};
            yMan <= {1'b1, Y[9:0]};
            if (X[14:10] > Y[14:10])
                xBigger <= 1;
            else if (X[14:10] < Y[14:10])
                xBigger <= 0;
            else begin
                if (X[9:0] > Y[9:0])
                    xBigger <= 1;
                else 
                    xBigger <= 0;    
            end
            done <= 0;
            OFUF <= 2'b0;
        end
        else begin
            case (state) 
                0: begin
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
                    if (X != 0) begin
                        result <= X;
                    end else if (Y != 0) begin
                        if (addSub)
                            result <= {~Y[15], Y[14:0]};
                        else    
                            result <= Y;  
                    end                 
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
                    //temporary combinational logic takes care of the bug
                    //where the computation does not execute if transitioning to the same state
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
                4: begin //note that moore circuit output is delayed by 1 cycle
                    if (xMan == 0)
                        result <= Y;
                    else if (yMan == 0)
                        result <= X;
                    done <= 1;
                end        
                5: begin
                    zExp <= xExp; //doesn't matter which one gets chosen they are equal
                    zMan <= addSubManTemp[10:0]; //initialize the zMan for state 9
                    if (addSubManTemp == 0) begin
                        state <= 6;
                    end else begin
                        if (addSubManTemp[11] == 1'b1) //if the mantissa result msb is a 1 (overflow)
                            state <= 7;
                        else begin
                            if (addSubManTemp[10] == 1'b0) //if the hidden bit 0, need to left shift to normalize
                                state <= 9;
                            else 
                                state <= 11; //else if the overflow msb == 0 and hidden bit == 1, then number is normalized
                        end
                    end
                end    
                6: begin
                    result <= 16'b0;
                    done <= 1;
                end
                7: begin //addition overflow state
                    if (zExp == 5'b11110) //mantissa overflow with maximum representable exponent
                        state <= 8;
                    else begin //else handles addition overflow (normalize rightwards)
                        zMan <= addSubManTemp >> 1;
                        zExp <= zExp + 1;
                        state <= 11; //will be normalized already after shifting
                    end
                end
                8: begin //exponent overflow
                    result <= 16'bz;
                    OFUF <= 2'b10;
                end
                9: begin //subtraction underflow state 
                    if (zExp == 5'b0) //mantissa underflow with minimum representable exponent
                        state <= 10;
                    else begin
                        zMan <= subNormTemp;
                        zExp <= tempZExp;
                        if (normalized) //normalized signal will be set asynchronously before zMan grabs the correct result on the posedge
                            state <= 11;
                        else //repeat the computations this state
                            state <= 9;
                    end
                end
                10: begin //exponent underflow
                    OFUF <= 2'b01;
                    done <= 1;
                end
                11: begin
                    result <= {zSign, zExp, zMan[9:10]};
                    done <= 1;
                end
            endcase
        end
    end
endmodule
