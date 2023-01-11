
module fill
	(
		CLOCK_50,						//	On Board 50 MHz
		KEY,							// On Board Keys
		SW,
		LEDR,
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,					//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B   						//	VGA Blue[9:0]
	);
 
	input	CLOCK_50;				//	50 MHz Clock
	input	[3:0]	KEY;					
	// Declare your inputs and outputs here
	input [9:0] SW;
	output [0:0] LEDR;
	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;			//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[7:0]	VGA_R;   				//	VGA Red[7:0] Changed from 10 to 8-bit DAC
	output	[7:0]	VGA_G;	 				//	VGA Green[7:0]
	output	[7:0]	VGA_B;   				//	VGA Blue[7:0]
	
	wire resetn;
	assign resetn = KEY[0];
	
	// Create the colour, x, y and writeEn wires that are inputs to the controller.
 
	wire [2:0] colour;
	wire [7:0] x;
	wire [6:0] y;
	wire writeEn;
 
	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(writeEn),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "black.mif";
			
	// Put your code here. Your code should produce signals x,y,colour and writeEn
	// for the VGA controller, in addition to any other functionality your design may require.
	wire [6:0] ixy_Coord;
	assign ixy_Coord = SW[6:0];
 
	wire [2:0] icolour;
	assign icolour = SW[9:7];
 
	wire done;
	assign LEDR[0] = done;
	
	wire plot;
	assign plot = ~KEY[1];
	
	wire black;
	assign black = ~KEY[2];
	
	wire loadx;
	assign loadx = ~KEY[3];
	
	part2 vgaDriver(.iResetn(resetn), .iPlotBox(plot), .iBlack(black), .iColour(icolour), .iLoadX(loadx), .iXY_Coord(ixy_Coord), .iClock(CLOCK_50), .oX(x), .oY(y), .oColour(colour), .oPlot(writeEn), .oDone(done));
	
endmodule


