
module compExpMan (output reg [2:0] compResult, input [15:0] x, y, input clk, reset);


	reg [4:0] expx, expy;
	reg [9:0] manx, many;
	reg state = 0;
	reg i = 15;

	
	
	

	always @ (posedge clk) begin //(1)
		case(state) //(2)
			0: begin
				if (reset == 1) compResult <= 3'b000;
				else state <= 1;
			end

			1: begin //(3)

				if (reset == 1) state <= 0;
				else begin	//(4)

					while(compResult == 3'b000 || i < 14) begin //checks sign bit and msb of exponent
					
						if(x[i] > y[i]) compResult <= 3'b010; //greater than
						else if (x[i] < y[i]) compResult <= 3'b100; //less than
						else i= i-1;
					end

					if (compResult == 3'b000) begin //(5)
						expx <= x[14:10];
						expy <= y[14:10];

						if(expx > expy) compResult <= 3'b010; //greater than
						else if(expx > expy) compResult <= 3'b100; //less than 
						else if(expx == expy) begin //same exponent (6)
							manx <= x[9:0];
							many <= y[9:0];
							if (manx > many) compResult <= 3'b010; //greater than
							else if (manx < many) compResult <= 3'b100; //less than
							else if (manx == many) compResult <= 3'b001; //equal to
						end//end else if (6) 
					end //end if statement (5)
				end  //end else statement (4)
			end //end case 1 (3)
		endcase //end case(2)
	end //end always (1)
endmodule
		
	

