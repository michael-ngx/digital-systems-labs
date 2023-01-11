`timescale 1ns/1ns

module mux8to1(Letter, out);
    input[2:0] Letter;
    output reg [11:0] out;
    always @ (*)
        case(Letter)
            3'b000: out = 12'b101110000000; //A
            3'b001: out = 12'b111010101000; //B
            3'b010: out = 12'b111010111010; //C
            3'b011: out = 12'b111010100000; //D
            3'b100: out = 12'b100000000000; //E
            3'b101: out = 12'b101011101000; //F
            3'b110: out = 12'b111011101000; //G
            3'b111: out = 12'b101010100000; //H
            default: out = 12'b0;
         endcase    
endmodule

module RateDivider(ClockIn, Start, enableOut);
    input ClockIn, Start;
    output enableOut;
	 
    reg [7:0] Q;
	 
    always @ (posedge ClockIn)
        if(Start == 1'b1)
            Q <= 8'b11111001;
        else if(Q == 8'b0)
            Q <= 8'b11111001;			// Loads 249 when Q reaches 0
        else
            Q <= Q - 1'b1;

    assign enableOut = (Q == 8'b0) ? 1'b1 : 1'b0;
endmodule
 
module part3(ClockIn, Resetn, Start, Letter, DotDashOut, NewBitOut);
    input ClockIn, Resetn, Start;  
    input [2:0] Letter;
    output reg DotDashOut, NewBitOut;
 
	wire [11:0] encodedLetter;					// Encoded letter (to be updated)
    mux8to1 lookup(Letter, encodedLetter);
	
	wire enable;
	RateDivider rd(ClockIn, Start, enable);		// enable is 1 every 0.5 seconds from the first start
	
    reg [11:0] Q;								// Code line to be shifted and displayed
	
	always @ (posedge ClockIn, negedge Resetn)
		if (Resetn == 1'b0)
			DotDashOut <= 1'b0;	
		else if (Start == 1'b1)
			Q <= encodedLetter;
		else if (enable == 1'b1)
			begin
				NewBitOut <= 1'b1;
				DotDashOut <= Q[11];
				Q <= Q << 1;
			end
		else
			begin
				DotDashOut <= DotDashOut;
				NewBitOut <= 1'b0;
			end
endmodule
