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
///////// ////                     
reg [18:0] ADDR;
reg [23:0] bgr_data;

reg [18:0] count;
reg sel; //use to choose betwen the background and the squre in mux
wire [9:0] x,y; //x rows, y columns
reg  [9:0] x_squre, y_squre;  //coordinates of the top left corner of the squre, with length of 40

wire VGA_CLK_n;
wire [7:0] index;
wire [23:0] bgr_data_raw;
wire cBLANK_n,cHS,cVS,rst;


wire backedge;			//enable background's edge display


initial 
begin
	x_squre = 10'd80;
	y_squre = 10'd320;
	sel=0;
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

//////Add switch-input logic here

//keyboard move the block

	always@(posedge ps2_key_pressed) begin
	  case (ps2_out)
		UP: begin
		  if(x_squre > 80)  begin
			x_squre = x_squre - 16;
		  end
		end
		DOWN: begin
		  if(x_squre < 400-16) begin
			x_squre = x_squre + 16;
		  end
		end
		LEFT: begin
		  if(y_squre > 240) begin
			y_squre = y_squre - 16;
		  end
		end
		RIGHT: begin
		  if(y_squre < 400-16) begin
			y_squre = y_squre + 16;
		  end
		end
	  endcase
	end

//choose whether it is background or the squre
always@(posedge iVGA_CLK,negedge iRST_n)
begin
	if(!iRST_n)
		sel <= 1'b0;
	else if(x>x_squre&&x<x_squre+10'd16&&y>=y_squre&&y<y_squre+10'd16-1)
		sel <= 1'b1;
	else 
		sel <= 1'b0;
end

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

//////latch valid data at falling edge;
//always@(posedge VGA_CLK_n) bgr_data <= bgr_data_raw;
always@(posedge VGA_CLK_n) bgr_data <= sel? 24'h0000ff : bgGridData;
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
 	















