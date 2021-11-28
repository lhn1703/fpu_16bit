
module compExpMan (output reg [2:0] compResult, input [15:0] x, y, input clk);


	reg [4:0] expx, expy;
	reg [9:0] manx, many;
	reg state = 0;
	reg i = 15;

	
	
	

	always @ (posedge clk) begin //< > =
		case(state)
			0: begin
				state <= state+1;
				end
			1: begin

				while(compResult == 3'b000 || i < 14) begin //checks sign bit and msb of exponent
					
					if(x[i] > y[i]) compResult <= 3'b010; //greater than
					else if (x[i] < y[i]) compResult <= 3'b100; //less than
					else i= i-1;
				end

				if (compResult == 3'b000) begin
					expx <= x[14:10];
					expy <= y[14:10];

					if(expx > expy) compResult <= 3'b010; //greater than
					else if(expx > expy) compResult <= 3'b100; //less than 
					else if(expx == expy) begin //same exponent
						manx <= x[9:0];
						many <= y[9:0];
						if (manx > many) compResult <= 3'b010; //greater than
						else if (manx < many) compResult <= 3'b100; //less than
						else if (manx == many) compResult <= 3'b001; //equal to
					end
				end
			end
		endcase
	end
endmodule
		
	

