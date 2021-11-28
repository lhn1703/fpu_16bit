module mulDivCircuit (
    output reg [1:0] OFUF, output reg done, output reg [15:0] result,
    input [15:0] X, Y,
    input mulDiv, reset, clk
    ); //mulDiv is 0 if multiply, 1 if divide

    reg [3:0] state;
    reg xSign, ySign, zSign;
    reg [4:0] xExp, yExp, zExp;
    reg [10:0] xMan, yMan, zMan; //hidden bit

    reg [5:0] expSum;
    reg [21:0] manTemp;
    reg [21:0] manTempShifted;
    always @ (*) begin
        expSum = xExp + yExp - 15;

        if (mulDiv == 1'b0)
            manTemp = xExp * yExp;
        else    
            manTemp = xExp / yExp;

        zSign = xSign ^ ySign;
        manTempShifted = manTemp << 1;

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
            OFUF <= 2'b0;
        end else begin
            case (state)
                0: begin
                    if (X == 16'b0 or Y == 16'b0) begin
                        if (X == 16'b0)
                            result <= 16'b0;
                        else begin
                            if (mulDiv == 1'b0) //if multiply
                                result <= 16'b0;
                            else 
                                OFUF <= 2'b10;
                        end
                        done <= 1'b1;
                        state <= 1;
                    end
                    else 
                        state <= 2;
                end
                1: begin
                    state <= 1;
                end
                2: begin
                    if (xExp + yExp < 15) begin
                        OFUF <= 2'b01;
                        state <= 3;
                        done <= 1;
                    end else if (xExp + yExp > 46)  begin
                        OFUF <= 2'b10;
                        state <= 3;
                        done <= 1;
                    end
                end
                3: begin
                    state <= 3;
                end
                4: begin
                    if (manTemp[21] == 1)
                        state <= 7;
                    
                end
            endcase
        end

    end