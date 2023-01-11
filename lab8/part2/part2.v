//
// This is the template for Part 2 of Lab 7.
//
// Paul Chow
// November 2021
//
 
module part2(iResetn,iPlotBox,iBlack,iColour,iLoadX,iXY_Coord,iClock,oX,oY,oColour,oPlot,oDone);
   parameter X_SCREEN_PIXELS = 8'd160;		// 8 for testing
   parameter Y_SCREEN_PIXELS = 7'd120;		// 5 for testing
 
   input wire iResetn, iPlotBox, iBlack, iLoadX;
   input wire [2:0] iColour;
   input wire [6:0] iXY_Coord;
   input wire       iClock;
  
   output wire [7:0] oX;         // VGA pixel coordinates
   output wire [6:0] oY;
   output wire [2:0] oColour;     // VGA pixel colour (0-7)
   output wire       oPlot;       // Pixel draw enable
   output wire       oDone;       // goes high when finished drawing frame
 
   wire ld_x, ld_y, ld_xy_0, draw, draw_black, done_black;
   wire [4:0] sum;
  
   control c0 (iClock, iResetn, iPlotBox, iBlack, iLoadX, sum, done_black, ld_x, ld_y, ld_xy_0, oPlot, oDone, draw, draw_black);
   datapath d0 (iClock, iResetn, iColour, iXY_Coord, ld_x, ld_y, ld_xy_0, oPlot, draw, draw_black, oX, oY, oColour, sum, done_black, X_SCREEN_PIXELS, Y_SCREEN_PIXELS);
 
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
					done_black <= 1'b0;										//////////////////////////////////////////
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
                   done_black <= 1'b1;									//////////////////////////////////////////////
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

