module vga_controller(iRST_n,
                      iVGA_CLK,
                      oBLANK_n,
                      oHS,
                      oVS,
                      b_data,
                      g_data,
                      r_data,
							 ps2_out,
							 ps2_key_pressed);

	
input iRST_n;
input iVGA_CLK;
input [7: 0] ps2_out;
input ps2_key_pressed;

//// set const value for UP, DOWN, LEFT, RIGHT 
	localparam LEFT = 8'h6b;
	localparam RIGHT = 8'h74;
	localparam UP = 8'h75;
	localparam DOWN = 8'h72;
	
output reg oBLANK_n;
output reg oHS;
output reg oVS;
output [7:0] b_data;
output [7:0] g_data;  
output [7:0] r_data;                        
///////// ////  registers                   
reg [18:0] ADDR;
reg [23:0] bgr_data;
reg [199: 0] matrix;
reg [8: 0] shape_unit;
reg [3: 0] shape_type;

///////////// wires
wire [12: 0] randNumber;
wire [1: 0] shape_innerOrEdge;
wire [23: 0] resultColor;

reg key_pressed; 		//shake reduction

reg [28:0] counter;
reg sel; //use to choose betwen the background and the squre in mux
wire [9:0] x,y; //x rows, y columns
reg  [9:0] x_shape, y_shape;  //coordinates of the top left corner of the squre, with length of 

wire VGA_CLK_n;
wire [7:0] index;
wire [23:0] bgr_data_raw;
wire cBLANK_n,cHS,cVS,rst;


wire backedge;			//enable background's edge display


parameter FREQUENCY = 20000000;
parameter blocksize=16;

initial 
begin
	x_shape = 10'd80;
	y_shape = 10'd320;
	sel=0;
	key_pressed=1'b0;
	shape_type = 0;
end

// counter
always@(posedge iVGA_CLK) begin
   if (counter == FREQUENCY)
       counter <= 0;
   else
       counter = counter + 1;
end

////
assign rst = ~iRST_n;
video_sync_generator LTM_ins (.vga_clk(iVGA_CLK),
                              .reset(rst),
                              .blank_n(cBLANK_n),
                              .HS(cHS),
                              .VS(cVS));
////
////Addresss generator
always@(posedge iVGA_CLK,negedge iRST_n)
begin
  if (!iRST_n)
     ADDR<=19'd0;
  else if (cHS==1'b0 && cVS==1'b0)
     ADDR<=19'd0;
  else if (cBLANK_n==1'b1)
     ADDR<=ADDR+19'd1;
end
//////////////////////////
//////INDEX addr.
assign VGA_CLK_n = ~iVGA_CLK;
img_data	img_data_inst (
	.address ( ADDR ),
	.clock ( VGA_CLK_n ),
	.q ( index )
	);
	
/////////////////////////
// translate the ADDR to x rows, y columns
vgaAddrTranslater ADDRtrans(.ADDR(ADDR), .x(x), .y(y));


/****************************
** Random number generate
*****************************/
LFSR pseudoRandomGenerate(randNumber, 1'b1, iVGA_CLK);

/****************************
** map shape_type to shape_unit
****************************/
always @(posedge VGA_CLK_n) begin
  case(shape_type)
	0: shape_unit = 12'h039;
	1: shape_unit = 12'h03C;
	2: shape_unit = 12'h036;
	3: shape_unit = 12'h01E;
	4: shape_unit = 12'h03A;
	5: shape_unit = 12'h033;
	endcase
end

//////Add switch-input logic here
///// 

/**************************************************************************************
** get x or y whether is in edge or inner
**************************************************************************************/
getInnerOrEdge innerOrEdge(x, y, x_shape, y_shape, shape_unit, shape_innerOrEdge[0], shape_innerOrEdge[1]);


/***************************
** keyboard move the block
****************************/
always@(posedge iVGA_CLK) begin
	if(counter == FREQUENCY) begin
		if(x_shape < 400-blocksize) begin
			x_shape = x_shape + blocksize;
		end
		else begin
		  x_shape = 80;
		  y_shape = 320;
		  shape_type = randNumber % 6;
		end
   end
	else begin
		if(ps2_key_pressed) begin
			key_pressed=1'b1;
		end
		else if(key_pressed) begin
		  case (ps2_out)
				UP: begin
					if(x_shape > 80)  begin
						x_shape = x_shape - blocksize;
					end
				end
				DOWN: begin
					if(x_shape < 400-blocksize) begin
						x_shape = x_shape + blocksize;
					end
				end
				LEFT: begin
					if(y_shape > 240) begin
						y_shape = y_shape - blocksize;
					end
				end
				RIGHT: begin
					if(y_shape < 400-blocksize) begin
						y_shape = y_shape + blocksize;
					end
				end
		  endcase
		  key_pressed=1'b0;
		end
	end
end

//choose whether it is background or the squre
// always@(posedge iVGA_CLK,negedge iRST_n)
// begin
	// if(!iRST_n)
		// sel <= 1'b0;
	// else if(x>x_shape&&x<x_shape+blocksize&&y>=y_shape&&y<y_shape+blocksize-1)
		// sel <= 1'b1;
	// else 
		// sel <= 1'b0;
// end

//////Color table output
img_index	img_index_inst (
	.address ( index ),
	.clock ( iVGA_CLK ),
	.q ( bgr_data_raw)
	);	
//////

//use mux to choose the bgr data

//select background grid

bgGrid bgGrid0(x, y, backedge);
wire [23:0] bgGridData;
assign bgGridData=backedge==1?24'h444444:bgr_data_raw;
wire [23: 0] tempData, tempData1;
muxFor24bit mux_edge(bgGridData, 24'h000000, shape_innerOrEdge[1], tempData);
muxFor24bit mux_inner(tempData, 24'h00004F, shape_innerOrEdge[0], tempData1);


//////latch valid data at falling edge;
//always@(posedge VGA_CLK_n) bgr_data <= bgr_data_raw;
// always@(posedge VGA_CLK_n) bgr_data <= sel? 24'h0000ff : bgGridData;
always@(posedge VGA_CLK_n) bgr_data <= tempData1;
assign b_data = bgr_data[23:16];
assign g_data = bgr_data[15:8];
assign r_data = bgr_data[7:0]; 
///////////////////
//////Delay the iHD, iVD,iDEN for one clock cycle;
always@(negedge iVGA_CLK)
begin
  oHS<=cHS;
  oVS<=cVS;
  oBLANK_n<=cBLANK_n;
end

endmodule
 	















