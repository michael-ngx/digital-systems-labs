//
// This is the template for Part 1 of Lab 8.
//
// Paul Chow
// November 2021
//

// iColour is the colour for the box
//
// oX, oY, oColour and oPlot should be wired to the appropriate ports on the VGA controller
//

// Some constants are set as parameters to accommodate the different implementations
// X_SCREEN_PIXELS, Y_SCREEN_PIXELS are the dimensions of the screen
//       Default is 160 x 120, which is size for fake_fpga and baseline for the DE1_SoC vga controller
// CLOCKS_PER_SECOND should be the frequency of the clock being used.

module part1(iColour,iResetn,iClock,oX,oY,oColour,oPlot,oNewFrame);
	input wire [2:0] iColour;
   input wire 	    iResetn;
   input wire 	    iClock;
   output wire [7:0] oX;         // VGA pixel coordinates
   output wire [6:0] oY;

   output wire [2:0] oColour;     // VGA pixel colour (0-7)
   output wire 	     oPlot;     // Pixel drawn enable
   output wire       oNewFrame;

   parameter
     X_BOXSIZE = 8'd4,   // Box X dimension
     Y_BOXSIZE = 7'd4,   // Box Y dimension
     X_SCREEN_PIXELS = 9,  // X screen width for starting resolution and fake_fpga
     Y_SCREEN_PIXELS = 7,  // Y screen height for starting resolution and fake_fpga
     CLOCKS_PER_SECOND = 5000, // 5 KHZ for fake_fpga
     X_MAX = X_SCREEN_PIXELS - 1 - X_BOXSIZE, // 0-based and account for box width
     Y_MAX = Y_SCREEN_PIXELS - 1 - Y_BOXSIZE,

     FRAMES_PER_UPDATE = 15,
     PULSES_PER_SIXTIETH_SECOND = CLOCKS_PER_SECOND / 60
	  ;

   //
   // Your code goes here
   //


endmodule // part1


module RateDivider(ClockIn, Reset, Speed, enableOut);
    input ClockIn, Reset;
	 input [1:0] Speed;
	 wire [27:0] data;
    reg [27:0] Q;
    output enableOut;
	 
	 mux4to1 mux(28'b0, 28'b0010111110101111000001111111, 28'b0101111101011110000011111111, 28'b1011111010111100000111111111, Speed, data);
	 
    always @ (posedge ClockIn)
		begin
		 if(Reset == 1'b1)
			Q <= 28'b0;
		 else if(Q == 28'b0)
			Q <= data;			// Loads new frequency
		 else
			Q <= Q - 1'b1;
		end
    assign enableOut = (Q == 28'b0) ? 1'b1 : 1'b0;
	 
endmodule

module demo(ClockIn, Reset, Speed,  CounterValue);
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



module control(
   input iClock,
   input iResetn, iPlotBox, iBlack, iLoadX,
   input [4:0] sum,    // To check if we finished drawing
 
   input done_black,
  
   output reg ld_x, ld_y, ld_xy_0,
   output reg oPlot,
   output reg oDone,
  
   output reg draw, draw_black
   );
 
   reg [4:0] current_state, next_state;
 
   localparam  S_LOAD_X        = 5'd0,
               S_LOAD_X_WAIT   = 5'd1,
               S_LOAD_Y        = 5'd2,
               S_LOAD_Y_WAIT   = 5'd3,
               DRAW_1          = 5'd4,
					DRAW_2			 = 5'd5,
               DRAW_BLACK_1    = 5'd6,
					DRAW_BLACK_2	 = 5'd7,
               DONE            = 5'd8,
               DONE_WAIT_LOAD_X = 5'd9,
               DONE_WAIT_LOAD_Y = 5'd10,
               DONE_WAIT_DRAW  = 5'd11,
               DONE_WAIT_BLACK = 5'd12,
					X_WAIT_BLACK    = 5'd13;
              
   // Next state logic aka our state table
   always@(*) begin
           case (current_state)
               S_LOAD_X:     begin
											if (iBlack)
												 next_state = X_WAIT_BLACK;
											else if (iLoadX)
												 next_state = S_LOAD_X_WAIT;
											else
												 next_state = S_LOAD_X;
									  end
					X_WAIT_BLACK: next_state = iBlack ? X_WAIT_BLACK : DRAW_BLACK_1;
					
               S_LOAD_X_WAIT:  next_state = iLoadX ? S_LOAD_X_WAIT : S_LOAD_Y;     // Loop in current state until signal goes low
               S_LOAD_Y:       next_state = iPlotBox ? S_LOAD_Y_WAIT : S_LOAD_Y;   // Loop in current state until value is input
               S_LOAD_Y_WAIT:  next_state = iPlotBox ? S_LOAD_Y_WAIT : DRAW_1;       // Loop in current state until signal goes low
					DRAW_1: 			 next_state = DRAW_2;
               DRAW_2:         next_state = (sum == 5'b10000) ? DONE : DRAW_2;
					DRAW_BLACK_1:   next_state = DRAW_BLACK_2;
               DRAW_BLACK_2:   next_state = done_black ? DONE : DRAW_BLACK_2;
               DONE:   begin
                           if (iBlack)
                               next_state = DONE_WAIT_BLACK;
                           else if (iLoadX)
                               next_state = DONE_WAIT_LOAD_X;
                           else
                               next_state = DONE;
                       end
               DONE_WAIT_LOAD_X: next_state = iLoadX ? DONE_WAIT_LOAD_X : DONE_WAIT_LOAD_Y; // oDone still high while pressing iLoadX
               DONE_WAIT_LOAD_Y: next_state = iPlotBox ? DONE_WAIT_DRAW : DONE_WAIT_LOAD_Y;
               DONE_WAIT_DRAW:   next_state = iPlotBox ? DONE_WAIT_DRAW : DRAW_1;                // oDone still high until released iPlotBox
               DONE_WAIT_BLACK:  next_state = iBlack ? DONE_WAIT_BLACK : DRAW_BLACK_1;           // oDone still high until released iBlack
              
               default: next_state = S_LOAD_X;
       endcase
   end
 
   // Output logic aka all of our datapath control signals
   always @(*)
   begin
       // By default make all our signals 0
       ld_x = 1'b0;
       ld_y = 1'b0;
       oPlot = 1'b0;
       oDone = 1'b0;
       draw = 1'b0;
       draw_black = 1'b0;
       ld_xy_0 = 1'b0;
 
       case (current_state)
           S_LOAD_X: ld_x = 1'b1;
           S_LOAD_Y: ld_y = 1'b1;
           DRAW_1:
					begin
                   draw = 1'b1;
               end
			  DRAW_2:
               begin
                   draw = 1'b1;
                   oPlot = 1'b1;
               end
			  DRAW_BLACK_1:
				   begin
                   draw_black = 1'b1;
               end
           DRAW_BLACK_2:
               begin
                   draw_black = 1'b1;
                   oPlot = 1'b1;
               end
           DONE: oDone = 1'b1;
           DONE_WAIT_LOAD_X:
               begin
                   ld_x = 1'b1;
                   oDone = 1'b1;
               end
           DONE_WAIT_LOAD_Y:
               begin
                   ld_y = 1'b1;
                   oDone = 1'b1;
               end
           DONE_WAIT_DRAW: oDone = 1'b1;
           DONE_WAIT_BLACK: 
				  begin
						ld_xy_0 = 1'b1;
						oDone = 1'b1;
				  end
       endcase
   end
 
   // current_state registers
   always@(posedge iClock)
   begin
       if(!iResetn)
           current_state <= S_LOAD_X;
       else
           current_state <= next_state;
   end
endmodule
 
module datapath(
   input iClock,
   input iResetn,
   input [2:0] iColour,
   input [6:0] iXY_Coord,
   
   input ld_x, ld_y, ld_xy_0,
   input oPlot,
   input draw, draw_black,
   
   output reg [7:0] oX,
   output reg [6:0] oY,
   output reg [2:0] oColour,
   output reg [4:0] sum,
   
   output reg done_black,
   input [7:0] x_size,
	input [6:0] y_size
   );
 
   // input registers
	reg [7:0] x;
   reg [6:0] y;
   reg [2:0] colorreg;
 
   // Registers x, y with respective input logic
   always@(posedge iClock) begin
       if(!iResetn) begin
           x <= 8'b0;
           y <= 7'b0;
           colorreg <= 3'b000;
           sum <= 5'b0;
           oX <= 8'b0;
           oY <= 7'b0;
           oColour <= 3'b0;
			  done_black <= 1'b0;
       end
       else begin
           if(ld_x)
               x <= {1'b0, iXY_Coord};
           else if (ld_y) begin
               y <= iXY_Coord;
               colorreg <= iColour;
           end
 
           else if (ld_xy_0) begin
               x <= 8'b0;
               y <= 7'b0;
					done_black <= 1'b0;
               colorreg <= 3'b000;
           end
              
           else if(draw) begin
               oX <= x;
               oY <= y;
               oColour <= colorreg;
              
               sum <= sum + 1'b1;
					if (sum == 5'b10000) begin
						sum <= 5'b0;
					end
               if (sum == 5'b00011 | sum == 5'b00111 | sum == 5'b01011) begin
                       y <= y + 1'b1;
                       x <= x - 2'b11;
               end
               else begin
                       x <= x + 1'b1;
               end
           end
              
           else if (draw_black) begin
               oX <= x;
               oY <= y;
               oColour <= colorreg;
              
               if (x == (x_size-1) & (y == y_size-1)) begin
                   done_black <= 1'b1;	
               end
               else if (x == (x_size-1)) begin
                   x <= 8'b0;
                   y <= y + 1'b1;
               end
               else begin
                   x <= x + 1'b1;
               end
           end
       end
   end
endmodule