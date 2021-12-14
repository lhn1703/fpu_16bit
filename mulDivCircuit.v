module mulDivCircuit (
    output reg [1:0] OFUF, output reg done, output reg [15:0] result,
    input [15:0] X, Y,
    input mulDiv, reset, clk
    ); //mulDiv is 0 if multiply, 1 if divide

    reg [2:0] state;
    reg xSign, ySign, zSign;
    reg [4:0] xExp, yExp, zExp, tempExp;
    reg [10:0] xMan, yMan; //hidden bit

    reg signed [5:0] expSum;
    reg [21:0] manTemp; //22 bits for the overflow from 11bit x 11bit 
    reg [21:0] manTempShifted;
    
    always @ (*) begin
        
        if (mulDiv == 1'b0) begin //multiply
            expSum = xExp + yExp - 15;
            manTemp = xMan * yMan;
        end else begin //divide
            expSum = xExp - yExp + 15; //shifting the quotient to the top
            manTemp = {xMan, {11{1'b0}}}  / {{11{1'b0}}, yMan}; 
        end  
        zSign = xSign ^ ySign;
       
        tempExp = zExp + 1; //must store as 5 bits
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
            
            done <= 0;
            OFUF <= 2'b00;
        end else begin
            case (state)
                0: begin
                    if (X == 16'b0 || Y == 16'b0) begin
                        if (X == 16'b0)
                            result <= 16'b0;
                        else begin
                            if (mulDiv == 1'b0) //if multiply
                                result <= 16'b0;
                            else //divide by zero yields overflow
                                OFUF <= 2'b10;
                        end
                        state <= 1;
                    end
                    else 
                        state <= 2;
                end
                1: begin
                    state <= 1;
                end
                2: begin
                    if (expSum < 0) begin //exponent underflow since bias gets subtracted
                        OFUF <= 2'b01;
                        state <= 3;
                        done <= 1;
                    end else if (expSum > 30)  begin //exponent overflow
                        state <= 3;
                    end else
                        state <= 4;
                end
                3: begin
                        state <= 3;
                end
                4: begin
                    zExp <= expSum;

                    if (mulDiv) //shift the lower half upwards for division
                        manTempShifted <= {1'b0, manTemp[10:0], {10{1'b0}}} ; //divison will never have overflow so MSB will be 0
                    else //for multplication take the upper half as well
                        manTempShifted <= manTemp;

                    if (manTemp[21] == 1) begin //mantissa overflow
                        if (expSum == 30) begin //adding 1 more would cause overflow 
                            OFUF <= 2'b10;
                            done <= 1;
                            state <= 3;
                        end 
                        else
                            state <= 7;
                    end 
                    else begin
                        if (manTemp[20] == 1'b1) begin //special case for state 4-7 transition where shift needs to happen right away
                            state <= 7;
                            manTempShifted <= manTemp << 1;
                        end
                        else
                            state <= 5;
                    end
                end
                5: begin
                    if (zExp == 1'b0) //underflow if subtracted from 0 before clk edge
                        state <= 6;
                    else begin
                        manTempShifted <= manTempShifted << 1;
                        zExp <= zExp - 1;
                        if (manTempShifted[20] == 1) //manTemp has not been updated yet before clk edge
                            state <= 7;
                        else
                            state <= 5;
                    end
                end
                6: begin
                    OFUF <= 2'b01;
                    done <= 1;
                    state <= 6;
                end
                7: begin
                    if (manTemp[21] == 1) //mantissa overflow
                        result <= {zSign, tempExp, manTemp[20:11]};
                    else 
                        result <= {zSign, zExp, manTempShifted[20:11]}; //extract the 10 msb bits excluding the hidden bit          
                    done <= 1;
                    state <= 7;
                end
            endcase
        end
    end
endmodule