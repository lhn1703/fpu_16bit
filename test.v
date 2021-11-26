module test(output reg[3:0] out, input [3:0] in, input reset, clk);
    reg [3:0] state;
    reg [3:0] out1, out2;
    always @ (*) begin
        out1 = out + 1;
        out2 = out + 2;
    end

    always @ (posedge clk or posedge reset) begin
        if (reset) begin
            state <= 0;
            out <= in;
        end else begin
            case (state)
                0: begin
                    //out <= in;
                    state <= 1;
                end
                1: begin
                    out <= out1;
                    if (out1 == 7)
                        state <= 2;
                    else state <= 1;
                end
                2: begin
                    out <= out2;
                    state <= 2;
                end
                default: out <= 15;
            endcase
        end
    end



endmodule
