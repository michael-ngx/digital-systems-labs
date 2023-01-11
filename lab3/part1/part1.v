`timescale 1ns / 1ns // `timescale time_unit/time_precision

module part1(MuxSelect, Input, Out);
	input [2:0] MuxSelect;
	input [6:0] Input;
	output reg Out;
		always @(*)
			case (MuxSelect[2:0]) 
				3'b000: Out = Input[0]; 
				3'b001: Out = Input[1]; 
				3'b010: Out = Input[2]; 
				3'b011: Out = Input[3]; 
				3'b100: Out = Input[4]; 
				3'b101: Out = Input[5]; 
				3'b110: Out = Input[6]; 
				default: Out = 1;
			endcase
endmodule

module TOP(input [9:0] SW, output [1:0] LEDR);
	part1 u1(SW[9:7], SW[6:0], LEDR[0]);
endmodule 
