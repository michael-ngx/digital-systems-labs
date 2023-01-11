`timescale 1ns / 1ns // `timescale time_unit/time_precision

module FA (a, b, c_in, s, c_out);
	input a, b, c_in;
	output s, c_out;
	assign s = c_in ^ a ^ b;
	assign c_out = (a & b) | (b & c_in) | (c_in & a);
endmodule

module part2(a, b, c_in, s, c_out);
	input [3:0] a, b;
	input c_in;
	output [3:0] s;
	output c_out;
	wire w0, w1, w2;
	FA u0 (a[0], b[0], c_in, s[0], w0);
	FA u1 (a[1], b[1], w0, s[1], w1);
	FA u2 (a[2], b[2], w1, s[2], w2);
	FA u3 (a[3], b[3], w2, s[3], c_out);
endmodule

//module TOP(input [8:0] SW, output [9:0] LEDR);
//	part2 uu(SW[7:4], SW[3:0], SW[8], LEDR[3:0], LEDR[9]);
//endmodule 

