module multD (output reg[1:0] OFUF, output reg mulDivDone, output reg [15:0] result, 
										 input [15:0] x, y, input mulDivReset, clk, mulOrDiv);

reg [2:0] state;
reg norm;
reg expOF;
reg expUF;
reg [4:0] expx, expy; 
always @ (posedge clk) begin

	case (state)
		
		0: begin
			if (mulDivReset == 1) state <= 0'b0;
			else begin
				state <= 1'b1;
			end
		end

		1: begin
		
			if(x == 0 || y == 0) begin
				mulDivDone <= 1;
				OFUF <= 2'b00;
				result <= 0;
			end
			
			else state <= 2'b1000;
		end
		
		2: begin
			expx <= x[14:10];
			expy <= y[14:10];
		end

	endcase
end
endmodule

			

			