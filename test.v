module test();
	reg [10:0] x, y;
	reg [21:0] result;
	initial begin
		x = 11'h700;
		y = 11'h780;
		#10 result = x * y;
	end
endmodule
