# 16-Bit Verilog FPU 
- this FPU computes IEEE 754 half-precision binary floating-point format
- there are four FPU operations: addition, subtraction, multiplication and division
- currently, excess bits are truncated (can implement a rounding feature in the future)
- this is a standalone computation unit, the other stages of computer architecture not imeplemented here
# Half Precision FPU Diagram
![alt text](https://github.com/lhn1703/fpu_16bit/blob/main/documentation/fpu%20controls%20block%20diagram.png)
# State Graphs 
- implemeneted with Moore Circuit methodology for stable computation, outputs may be delayed one cycle as a result
- note that state graphs may contain extra or be missing some transition signals to help decrease clutter
- the following logic flowcharts better describe the circuit's behavior
![alt text](https://github.com/lhn1703/fpu_16bit/blob/main/documentation/state%20graphs.png)
# FPU Internal Logic Flowcharts
- Addition/Subtraction
![alt text](https://github.com/lhn1703/fpu_16bit/blob/main/documentation/addition-subtraction%20flowchart.png)
- Multiplication/Division
![alt text](https://github.com/lhn1703/fpu_16bit/blob/main/documentation/multiplication-division%20flowchart.png)
- Comparator \
![alt text](https://github.com/lhn1703/fpu_16bit/blob/main/documentation/comparison.png)
# Fast Inverse Square Root Algorithm
```c++
//original 32-bit floating point algorithm courtesy of John Carmack
//the algorithm is set up in such a way that division is avoided
//half represents a 16-bit IEEE half precision floating point number

half invSqrt(half x) {
	const half threeHalfs = 1.50; //0x3E00
	half xHalf = x / 2; //[exponent bits] - 1
	half y = x;
	
	//casts the floating point as int to manually manipulate bits in C
	int bitHack = *(half*)&y;
	
	//cleverly reversed engineered constant that makes it work
	//basically an approximation of the optimal initial guess for Newton's Method  
	bitHack = 0x59BB - (bitHack >> 1);	

	//cast variable back to floating point format as is
	y = *(half*)&bitHack;
	
	//first iteration of Newton's Method
	y = y * (threehalfs - (xHalf * y * y)); 
	
	//second iteration not included since it would double execution time
	//y = y * (threehalfs - (xHalf * y * y)); 

	return y;
}	
```
- the circuit performs the computation states as follows:
		3. combinatorial binary bitHack calculation
		4. temp = bitHack * bitHack;
		5. temp = xHalf * temp;
		6. temp = 1.50 - temp;
		7. temp = bitHack * temp;
		8. return temp;
- the operation fails whenever overflow or underflow is detected from the fpu.
- this hardware implementation may not be as efficient as software implementation with compiler optimizations running on a pipelined computer
# Fast Inverse Square Root Circuit and Flowchart
- uses the FPU to perform its computations
![alt text](https://github.com/lhn1703/fpu_16bit/blob/main/documentation/fast%20inverse%20square%20root%20block%20diagram.png)
![alt text](https://github.com/lhn1703/fpu_16bit/blob/main/documentation/fast%20inverse%20sqrt%20flowchart.png)
