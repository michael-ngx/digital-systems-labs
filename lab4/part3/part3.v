`timescale 1ns/1ns

// MUX
module mux2to1(x, y, s, m);
	input x, y, s;
	output m;
	assign m = (~s & x)|(s & y);
endmodule

// Flipflop
module flipflop (d, q, clock, reset);
	input d, clock, reset;
	output reg q;
	always @ (posedge clock)
		if (reset == 1)	// active high reset
			q <= 0;
		else
			q <= d;
endmodule

// All subcircuits
module subcircuit (LoadLeft, D, loadn, Q, clock, reset, right, left);
	input LoadLeft, D, loadn, clock, reset, right, left;
	output Q;
	wire w0, w1;
	mux2to1 M1(right, left, LoadLeft, w0);
	mux2to1 M2(D, w0, loadn, w1);
	
	flipflop ff(w1, Q, clock, reset);
	
endmodule

// Rotating register
module part3 (clock, reset, ParallelLoadn, RotateRight, ASRight, Data_IN, Q);
	input clock, reset, ParallelLoadn, RotateRight, ASRight;
	input [7:0] Data_IN;
	
	output [7:0] Q;
	wire asright;
	
	assign asright = (~ASRight & Q[0])|(ASRight & Q[7]);
		
	subcircuit sc7(RotateRight, Data_IN[7], ParallelLoadn, Q[7], clock, reset, Q[6], asright);
	subcircuit sc6(RotateRight, Data_IN[6], ParallelLoadn, Q[6], clock, reset, Q[5], Q[7]);
	subcircuit sc5(RotateRight, Data_IN[5], ParallelLoadn, Q[5], clock, reset, Q[4], Q[6]);
	subcircuit sc4(RotateRight, Data_IN[4], ParallelLoadn, Q[4], clock, reset, Q[3], Q[5]);
	subcircuit sc3(RotateRight, Data_IN[3], ParallelLoadn, Q[3], clock, reset, Q[2], Q[4]);
	subcircuit sc2(RotateRight, Data_IN[2], ParallelLoadn, Q[2], clock, reset, Q[1], Q[3]);
	subcircuit sc1(RotateRight, Data_IN[1], ParallelLoadn, Q[1], clock, reset, Q[0], Q[2]);
	subcircuit sc0(RotateRight, Data_IN[0], ParallelLoadn, Q[0], clock, reset, Q[7], Q[1]);
	
endmodule
