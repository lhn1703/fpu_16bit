# fpu_16_bit
- this FPU computes IEEE 754 half-precision binary floating-point format
- there are four FPU operations: addition, subtraction, multiplication and division
- currently, excess bits are truncated (can implement a rounding feature in the future)
# Half Precision FPU Diagram
![alt text](https://github.com/lhn1703/fpu_16bit/blob/main/documentation/fpu%20controls%20block%20diagram.png)
# State Graphs 
- implemeneted with Moore Circuit methodology for stable computation, outputs may be delayed one cycle as a result
- note that state graphs may contain extra or be missing some transition signals to help decrease clutter
- the follow logic flowcharts better describe the FPU behavior
![alt text](https://github.com/lhn1703/fpu_16bit/blob/main/documentation/state%20graphs.png)
# FPU Internal Logic Flowcharts
- Addition/Subtraction
![alt text](https://github.com/lhn1703/fpu_16bit/blob/main/documentation/addition-subtraction%20flowchart.png)
- Multiplication/Division
![alt text](https://github.com/lhn1703/fpu_16bit/blob/main/documentation/multiplication-division%20flowchart.png)
- Comparator 
![alt text](https://github.com/lhn1703/fpu_16bit/blob/main/documentation/comparison.png)
# Fast Inverse Square Root Circuit
- uses the FPU to perform its computations
![alt text](https://github.com/lhn1703/fpu_16bit/blob/main/documentation/fast%20inverse%20square%20root%20block%20diagram.png)
# Fast Inverse Square Root Algorithm
- may not be as efficient as software implementation with compiler optimizations running on a pipelined computer
![alt text](https://github.com/lhn1703/fpu_16bit/blob/main/documentation/fast%20inverse%20sqrt%20flowchart.png)
