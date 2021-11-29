module fastInvSqrt (
    output reg [1:0] OFUF,
    output reg done,
    output reg [15:0] result,
    input [15:0] Xin,
    input reset, clk
    );

    wire [1:0] fpuOFUF;
    wire [2:0] compResult;
    wire fpuDone;
    wire [15:0] fpuResult;

    reg [3:0] state;
    reg [15:0] xOp, yOp;

    reg fpuReset;
    reg [1:0] opcode;

    reg [15:0] xHalf;
    reg [5:0] expSub;
    reg [16:0] bitHack;

    fpu_16bit u00 (fpuOFUF, fpuDone, fpuResult, compResult, xOp, yOp, opcode, fpuReset, clk);

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
        else if (fpuOFUF == 2'b10 || fpuOFUF == 2'b01) begin
            OFUF <= fpuOFUF;
            state <= 9; //dead state
        end
        else begin
            case (state)
                0: begin
                    if (Xin == 16'b0) begin //if X == 0.0
                        state <= 1;
                        OFUF <= 2'b10;
                        done <= 1;
                    end 
                    else if (Xin == 16'h3C00) begin //if X == 1.0
                        result <= 16'h3C00;
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
                        state <= 9; //dead state
                    end
                    else begin
                        if (bitHack[16] == 1'b1) begin //subtraction overflow
                            OFUF <= 2'b10;
                            state <= 9; //dead state
                        end
                        else begin //state 4 set up
                            xOp <= bitHack;
                            yOp <= bitHack;
                            opcode <= 2;
                            fpuReset <= 1;
                            state <= 4;
                        end
                    end
                end
                4: begin //computing y = y * y
                    fpuReset <= 0;
                    if (fpuDone) begin
                        yOp <= fpuResult;
                        xOp <= xHalf[15:0]; 
                        opcode <= 2;
                        fpuReset <= 1;
                        state <= 5;
                    end
                    else
                        state <= 4;
                end
                5: begin //computing y = xHalf * (y * y)
                    fpuReset <= 0;
                    if (fpuDone) begin //state 6 setup
                        yOp <= fpuResult;
                        xOp <= 16'h3E00; //1.50
                        opcode <= 1;
                        fpuReset <= 1;
                        state <= 6;
                    end
                    else
                        state <= 5;
                end
                6: begin //computing y = 1.50 - (xHalf * (y * y))
                    fpuReset <= 0;
                    if (fpuDone) begin //state 7 setup
                        yOp <= fpuResult;
                        xOp <= bitHack[15:0]; 
                        opcode <= 2;
                        fpuReset <= 1;
                        state <= 7;
                    end
                    else
                        state <= 6;
                end
                7: begin //computing y = y * (3.50 - (xHalf * (y * y)))
                    fpuReset <= 0;
                    if (fpuDone) begin //output result if successful
                        result <= fpuResult;
                        done <= 1;
                        state <= 8;
                    end
                    else
                        state <= 7;
                end
                8: begin
                    done <= 1;
                    state <= 8;
                end
                9: begin
                    state <= 9;
                    done <= 1;
                end
                default: begin
                    state <= 0;
                end
            endcase
        end
    end

    
endmodule
