`timescale 1ns/1ns

//Hex Decoder 
module hex_decoder(data, display);
	input [3:0] data;
	output [6:0] display;
	assign display[0] = ~((data[3]|data[2]|data[1]|~data[0])&(data[3]|~data[2]|data[1]|data[0])&(~data[3]|data[2]|~data[1]|~data[0])&(~data[3]|~data[2]|data[1]|~data[0]));
	assign display[1] = ~((data[3]|~data[2]|data[1]|~data[0])&(data[3]|~data[2]|~data[1]|data[0])&(~data[3]|data[2]|~data[1]|~data[0])&(~data[3]|~data[2]|data[1]|data[0])&(~data[3]|~data[2]|~data[1]|data[0])&(~data[3]|~data[2]|~data[1]|~data[0]));
	assign display[2] = ~((data[3]|data[2]|~data[1]|data[0])&(~data[3]|~data[2]|data[1]|data[0])&(~data[3]|~data[2]|~data[1]|data[0])&(~data[3]|~data[2]|~data[1]|~data[0]));
	assign display[3] = ~((data[3]|data[2]|data[1]|~data[0])&(data[3]|~data[2]|data[1]|data[0])&(data[3]|~data[2]|~data[1]|~data[0])&(~data[3]|data[2]|~data[1]|data[0])&(~data[3]|~data[2]|~data[1]|~data[0]));
	assign display[4] = ~((data[3]|data[2]|data[1]|~data[0])&(data[3]|data[2]|~data[1]|~data[0])&(data[3]|~data[2]|data[1]|data[0])&(data[3]|~data[2]|data[1]|~data[0])&(data[3]|~data[2]|~data[1]|~data[0])&(~data[3]|data[2]|data[1]|~data[0]));
	assign display[5] = ~((data[3]|data[2]|data[1]|~data[0])&(data[3]|data[2]|~data[1]|data[0])&(data[3]|data[2]|~data[1]|~data[0])&(data[3]|~data[2]|~data[1]|~data[0])&(~data[3]|~data[2]|data[1]|~data[0]));
	assign display[6] = ~((data[3]|data[2]|data[1]|data[0])&(data[3]|data[2]|data[1]|~data[0])&(data[3]|~data[2]|~data[1]|~data[0])&(~data[3]|~data[2]|data[1]|data[0]));
endmodule

//FULL ADDER 1-bit 
module FA(a,b,c_in, s, c_out); 
	input a,b,c_in; 
	output s, c_out; 
	assign s = a ^ b ^ c_in; 
	assign c_out = (a&b)|(a&c_in)|(b&c_in); 
endmodule 

//FULL ADDER RIPPLE CARRY 4 BITS 
module rippleAdder4bits(a, b, c_in, s, c_out); 
	input[3:0] a, b;
	input c_in; 
	output[3:0] s;
	output c_out;
	wire c1, c2, c3;
	
	FA bit0(a[0], b[0], c_in, s[0], c1); 
	FA bit1(a[1], b[1], c1, s[1], c2); 
	FA bit2(a[2], b[2], c2, s[2], c3); 
	FA bit3(a[3], b[3], c3, s[3], c_out); 
endmodule 

//ALU AND REGISTER
module part2(Clock, Reset_b, Data, Function, ALUout);
	input Clock, Reset_b;
	input [2:0] Function;
	input [3:0] Data;
	
	reg [7:0] aluout;
	output reg [7:0] ALUout;
	
	wire c_out;
	wire [3:0] s;
	rippleAdder4bits u0(Data, ALUout[3:0], 1'b0, s, c_out);
	
	// ALU block
	always @ (*)
		begin
			case(Function)
				3'b000: aluout = {3'b000, c_out, s};
				3'b001: aluout = Data + ALUout[3:0];
				3'b010: aluout = {ALUout[3], ALUout[3], ALUout[3], ALUout[3], ALUout[3:0]}; 
				3'b011: aluout = {7'b0000000, (Data[0]|ALUout[0])|(Data[1]|ALUout[1])|(Data[2]|ALUout[2])|(Data[3]|ALUout[3])}; 
				3'b100: aluout = {7'b0000000, (Data[0]&ALUout[0])&(Data[1]&ALUout[1])&(Data[2]&ALUout[2])&(Data[3]&ALUout[3])}; 
				3'b101: aluout = ALUout[3:0] << Data;
				3'b110: aluout = Data * ALUout[3:0];
				3'b111: aluout = ALUout;
				default: aluout = 8'b0;
			endcase
		end
	
	// Register block
	always @ (posedge Clock)
		if (Reset_b == 1'b0)
			ALUout <= 8'b0;
		else
			ALUout <= aluout;
	
endmodule

//Assign Switches and LEDs
module ALUreg(SW, KEY, LEDR, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5); 
	input [9:0] SW;
	input [3:0] KEY; 
	output [7:0] LEDR; 
	output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	
	part2 u1(KEY[0], SW[9], SW[3:0], KEY[3:1], LEDR[7:0]);
	
	hex_decoder Hex0(.data(SW[3:0]), .display(HEX0)); //Data
	hex_decoder Hex1(.data(4'b0000), .display(HEX1)); //0
	hex_decoder Hex2(.data(4'b0000), .display(HEX2)); //0
	hex_decoder Hex3(.data(4'b0000), .display(HEX3)); //0
	hex_decoder Hex4(.data(LEDR[3:0]), .display(HEX4)); //ALUout[3:0]
	hex_decoder Hex5(.data(LEDR[7:4]), .display(HEX5)); //ALUout[7:4]
endmodule
