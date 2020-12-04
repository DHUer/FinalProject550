module singleCell(
    input[9: 0] x,
    input[9: 0] y,
    input[9: 0] x_shape,
    input[9: 0] y_shape,
    output isInner,
    output isEdge);

	 localparam size = 16;
    assign isInner = (x > x_shape && x < x_shape + 16 && y > y_shape && y < y_shape + size) ? 1 : 0;
    assign isEdge = (x >= x_shape && x <= x_shape + 16 && y >= y_shape && y <= y_shape + size) ? 1 : 0;

endmodule