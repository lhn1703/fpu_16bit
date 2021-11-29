module fastInvSqrtPipelined (
    output reg [1:0] OFUF,
    output reg done,
    output reg [15:0] result,
    input [15:0] Xin,
    input reset, clk
    );

    wire [1:0] fpuOFUF1, fpuOFUF2;
    wire [2:0] compResult1, compResult2;
    wire fpuDone1, fpuDone2;
    wire [15:0] fpuResult1, fpuResult2;

    reg [3:0] state;
    reg [15:0] xOp1, yOp1, xOp2, yOp2;

    reg fpuReset1, fpuReset2;
    reg [1:0] opcode1, opcode2;

    reg [15:0] xHalf;
    reg [5:0] expSub;
    reg [16:0] bitHack;


    fpu_16bit u00 (fpuOFUF1, fpuDone1, fpuResult1, compResult1, xOp1, yOp1, opcode1, fpuReset1, clk);
    fpu_16bit u01 (fpuOFUF2, fpuDone2, fpuResult2, compResult2, xOp2, yOp2, opcode2, fpuReset2, clk);

    always @ (*) begin
        expSub = {1'b0, Xin[14:10]} - 1;
        xHalf = {Xin[15], expSub[4:0], Xin[9:0]};
        bitHack = 16'h59BB - (Xin >> 1);
    end

    always @ (posedge clk or posedge reset) begin
        if (reset) begin
            state <= 0;
            OFUF <= 2'b00;
            done <= 0;
        end 
        else if (fpuOFUF1 == 2'b10 || fpuOFUF1 == 2'b01) begin
            OFUF <= fpuOFUF1;
            state <= 8; //dead state
        end 
        else if (fpuOFUF2 == 2'b10 || fpuOFUF2 == 2'b01) begin
            OFUF <= fpuOFUF2;
            state <= 8; //dead state
        end
        else begin
            case (state)
                0: begin
                    if (Xin == 16'b0) begin //if X == 0.0 then overflow
                        state <= 1;
                        OFUF <= 2'b10; 
                        done <= 1;
                    end 
                    else if (Xin == 16'h3C00) begin //if X == 1.0
                        result <= 16'h3C00; //1.0
                        done <= 1;
                        state <= 2;
                    end 
                    else begin //state 3 precompute
                        state <= 3;
                    end
                end
                1: begin
                    state <= 1;
                    done <= 1;
                end
                2: begin
                    state <= 2;
                    done <= 1;
                end
                3: begin //computing bitHack and xHalf
                    if (Xin[14:10] == 0) begin //division by 2 underflow
                        OFUF <= 2'b01;
                        state <= 8; //dead state
                    end
                    else begin
                        if (bitHack[16] == 1'b1) begin //subtraction overflow
                            OFUF <= 2'b10;
                            state <= 8; //dead state
                        end
                        else begin //state 4 set up
                            xOp1 <= bitHack;
                            yOp1 <= bitHack;
                            opcode1 <= 2;
                            fpuReset1 <= 1;

                            xOp2 <= bitHack;
                            yOp2 <= xHalf;
                            opcode2 <= 2;
                            fpuReset2 <= 1;

                            state <= 4;
                        end
                    end
                end
                4: begin //computing y1 = y * y and y2 = y * xHalf
                    fpuReset1 <= 0;
                    fpuReset2 <= 0;
                    if (fpuDone1 && fpuDone2) begin //state 5 setup
                        xOp1 <= bitHack;
                        yOp1 <= 16'h3E00; //1.50 
                        opcode1 <= 2;
                        fpuReset1 <= 1;

                        xOp2 <= fpuResult1;
                        yOp2 <= fpuResult2;
                        opcode2 <= 2;
                        fpuReset2 <= 1;

                        state <= 5;
                    end
                    else
                        state <= 4;
                end
                5: begin //computing y1 = y * 1.50 and  y2 = (y * y) * (y * xHalf) = y1 * y2
                    fpuReset1 <= 0;
                    fpuReset2 <= 0;
                    if (fpuDone1 && fpuDone2) begin //state 6 setup
                        xOp1 <= fpuResult1;
                        yOp1 <= fpuResult2;
                        opcode1 <= 1;
                        fpuReset1 <= 1;
                        state <= 6;
                    end
                    else
                        state <= 5;
                end
                6: begin //computing  y1 = (y * 1.50) - (y * y) * (y * xHalf) = y1 - y2
                    fpuReset1 <= 0;
                    if (fpuDone1) begin //output result of successful
                        result <= fpuResult1;
                        done <= 1;
                        state <= 7;
                    end
                    else
                        state <= 6;
                end
                7: begin //computing y = y * (3.50 - (xHalf * (y * y)))
                    done <= 1;
                    state <= 7;
                end
                8: begin
                    done <= 1;
                    state <= 8;
                end
                default: state <= 0;
            endcase
        end
    end

    
endmodule
