module vgaAddrTranslater(ADDR, x, y);

input [18:0] ADDR;
output [9:0] x, y;

assign x = ADDR / 10'd640;  //rows
assign y = ADDR % 10'd640;  //columns

endmodule
