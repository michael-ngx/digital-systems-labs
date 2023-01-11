`timescale 1ns/1ns

//Hex Decoder 
module hex_decoder(c, display);
	input [3:0] c;
	output [6:0] display;
	
	assign display[0] = ~((c[3] | c[2] | c[1] | ~c[0]) & (c[3] | ~c[2] | c[1] | c[0]) & (~c[3] | c[2] | ~c[1] | ~c[0]) & (~c[3] | ~c[2] | c[1] | ~c[0]));
	
	assign display[1] = ~((c[3] | ~c[2] | c[1] | ~c[0]) & (c[3] | ~c[2] | ~c[1] | c[0]) & (~c[3] | c[2] | ~c[1] | ~c[0]) & (~c[3] | ~c[2] | c[1] | c[0]) & (~c[3] | ~c[2] | ~c[1] | c[0]) & (~c[3] | ~c[2] | ~c[1] | ~c[0]));
	
	assign display[2] = ~((c[3] | c[2] | ~c[1] | c[0]) & (~c[3] | ~c[2] | c[1] | c[0]) & (~c[3] | ~c[2] | ~c[1] | c[0]) & (~c[3] | ~c[2] | ~c[1] | ~c[0]));
	
	assign display[3] = ~((c[3] | c[2] | c[1] | ~c[0]) & (c[3] | ~c[2] | c[1] | c[0]) & (c[3] | ~c[2] | ~c[1] | ~c[0]) & (~c[3] | c[2] | ~c[1] | c[0]) & (~c[3] | ~c[2] | ~c[1] | ~c[0]));
	
	assign display[4] = ~((c[3] | c[2] | c[1] | ~c[0]) & (c[3] | c[2] | ~c[1] | ~c[0]) & (c[3] | ~c[2] | c[1] | c[0]) & (c[3] | ~c[2] | c[1] | ~c[0]) & (c[3] | ~c[2] | ~c[1] | ~c[0]) & (~c[3] | c[2] | c[1] | ~c[0]));
	
	assign display[5] = ~((c[3] | c[2] | c[1] | ~c[0]) & (c[3] | c[2] | ~c[1] | c[0]) & (c[3] | c[2] | ~c[1] | ~c[0]) & (c[3] | ~c[2] | ~c[1] | ~c[0]) & (~c[3] | ~c[2] | c[1] | ~c[0]));
	
	assign display[6] = ~((c[3] | c[2] | c[1] | c[0]) & (c[3] | c[2] | c[1] | ~c[0]) & (c[3] | ~c[2] | ~c[1] | ~c[0]) & (~c[3] | ~c[2] | c[1] | c[0]));
endmodule

//FULL ADDER 1-bit 
module FA(a,b,c_in, s, c_out); 
	input a,b,c_in; 
	output s, c_out; 
	assign s = a ^ b ^ c_in; 
	assign c_out = (a&b)|(a&c_in)|(b&c_in); 
endmodule 

//FULL ADDER RIPPLE CARRY 4 BITS 
module part2(a,b,c_in, s, c_out); 
	input[3:0] a,b; 
	input c_in; 
	output[3:0] s; 
	output c_out; 
	wire c1, c2, c3;
	
	FA bit0(a[0], b[0], c_in, s[0], c1); 
	FA bit1(a[1], b[1], c1, s[1], c2); 
	FA bit2(a[2], b[2], c2, s[2], c3); 
	FA bit3(a[3], b[3], c3, s[3], c_out); 
endmodule 

//ALU UNIT 
module part3(A,B, Function, ALUout);
	input [2:0] Function; 
	input [3:0] A, B; 
	output reg [7:0] ALUout;
	
	wire [3:0] s;
	wire c_out, caseZero, caseOne, caseTwo, caseThree, caseFour, caseFive, caseDefault;
	part2 u0(A, B, 0, s, c_out);
	
	assign caseZero = {3'b000, c_out, s[3:0]};
	assign caseOne = {3'b000, {{1'b0,A} + {1'b0, B}}};
	assign caseTwo = {B[3], B[3], B[3], B[3], B};
	assign caseThree= {7'b0000000, (A[0] | B[0]) | (A[1] | B[1]) | (A[2] | B[2]) | (A[3] | B[3])}; 
	assign caseFour= {7'b0000000, (A[0] & B[0]) & (A[1] & B[1]) & (A[2] & B[2]) & (A[3] & B[3])}; 
	assign caseFive= {A, B};
	assign caseDefault = {8'b00000000};
	
	always @(*)
	begin
		case(Function)
			3'b000: ALUout= caseZero; 
			3'b001: ALUout= caseOne; 
			3'b010: ALUout= caseTwo; 
			3'b011: ALUout= caseThree; 
			3'b100: ALUout= caseFour; 
			3'b101: ALUout= caseFive; 
			default: ALUout= caseDefault; //6 and 7 
		endcase
	end 
endmodule 


//Assign Switches and LEDs 
module topLevel(SW, KEY, LEDR, HEX); 
	input [7:0] SW; 
	input [2:0] KEY; 
	output [7:0] LEDR; 
	output [5:0] HEX; 
	 
	part3 u1(SW[7:4], SW[3:0], KEY[2:0], LEDR[7:0]); 
	
	hex_decoder Hex0(.c(SW[3:0]), .display(HEX[0])); //B
	hex_decoder Hex1(.c(4'b0000), .display(HEX[1])); //0
	hex_decoder Hex2(.c(SW[7:4]), .display(HEX[2])); //A
	hex_decoder Hex3(.c(4'b0000), .display(HEX[3])); //0
	hex_decoder Hex4(.c(LEDR[3:0]), .display(HEX[4])); //ALUout[3:0]
	hex_decoder Hex5(.c(LEDR[7:4]), .display(HEX[5])); //ALUout[7:4]
endmodule
