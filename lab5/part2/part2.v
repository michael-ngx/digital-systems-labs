`timescale 1ns/1ns

module mux4to1(a, b, c, d, s, m);
    input [10:0] a,b,c,d;
    input [1:0] s;
    output reg [10:0] m;
    always @ (*)
		case(s)
			2'b00: m = a;
			2'b01: m = b;
			2'b10: m = c;
			2'b11: m = d;
		endcase
endmodule
 
module RateDivider(ClockIn, Reset, Speed, enableOut);
    input ClockIn, Reset;
	input [1:0] Speed;
	wire [10:0] data;
    reg [10:0] Q;
    output enableOut;
	 
	mux4to1 mux(11'b0, 11'b00111110011, 11'b01111100111, 11'b11111001111, Speed, data);
	 
    always @ (posedge ClockIn)
		begin
			if(Reset == 1'b1)
				Q <= 11'b0;
			else if(Q == 11'b0)
				Q <= data;			// Loads new frequency
			else
				Q <= Q - 1'b1;
		end
    assign enableOut = (Q == 11'b0) ? 1'b1 : 1'b0;
	 
endmodule

module part2(ClockIn, Reset, Speed,  CounterValue);
    input ClockIn, Reset;
	input [1:0] Speed;
    output reg [3:0] CounterValue;
	wire EnableDC;
	 
	RateDivider rd(ClockIn, Reset, Speed, EnableDC);
	 
    always @ (posedge ClockIn)
        if(Reset == 1'b1)
            CounterValue <= 4'b0;
        else if(EnableDC == 1'b1)
            if (CounterValue == 4'b1111)
               CounterValue <= 4'b0;
			else
				CounterValue <= CounterValue + 1'b1;
endmodule
