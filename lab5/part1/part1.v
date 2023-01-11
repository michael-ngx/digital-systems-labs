`timescale 1ns/1ns

module tflipflop (Clock, Enable, Clear_b, Q);
	input Clock, Enable, Clear_b;
	output reg Q;
	
	always @ (posedge Clock)
		if (Clear_b == 1'b0)
			Q <= 0;
		else
			if (Enable == 1'b1)
				Q <= ~Q;
			else
				Q <= Q;
endmodule

module part1(Clock, Enable, Clear_b, CounterValue);
	input Clock, Enable, Clear_b;
	output [7:0] CounterValue;
	wire [7:0] w;
	
	assign w[0] = Enable;
	assign w[1] = w[0] & CounterValue[0];
	assign w[2] = w[1] & CounterValue[1];
	assign w[3] = w[2] & CounterValue[2];
	assign w[4] = w[3] & CounterValue[3];
	assign w[5] = w[4] & CounterValue[4];
	assign w[6] = w[5] & CounterValue[5];
	assign w[7] = w[6] & CounterValue[6];

	tflipflop tff0(Clock, w[0], Clear_b, CounterValue[0]);
	tflipflop tff1(Clock, w[1], Clear_b, CounterValue[1]);
	tflipflop tff2(Clock, w[2], Clear_b, CounterValue[2]);
	tflipflop tff3(Clock, w[3], Clear_b, CounterValue[3]);
	tflipflop tff4(Clock, w[4], Clear_b, CounterValue[4]);
	tflipflop tff5(Clock, w[5], Clear_b, CounterValue[5]);
	tflipflop tff6(Clock, w[6], Clear_b, CounterValue[6]);
	tflipflop tff7(Clock, w[7], Clear_b, CounterValue[7]);
endmodule

module eightbitcounter (KEY, SW, HEX0, HEX1);
	input [0:0] KEY;
	input [1:0] SW;
	wire [7:0] w;
	output [3:0] HEX0, HEX1;
	
	assign HEX0 = w[3:0];
	assign HEX1 = w[7:4];
	
	part1 p1(KEY[0], SW[1], SW[0], w);
	
endmodule
