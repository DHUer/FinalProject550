// module getInnerOrEdge(
    // input [9: 0]x,
    // input [9: 0]y,
    // input [9: 0]x_shape,
    // input [9: 0]y_shape,
    // input [8: 0]shape_unit,
    // output isInnerRes,
    // output isEdgeRes
// );

// wire [8: 0] tempInner, tempEdge;
// wire [8: 0] oneHotInnter, oneHotEdge;
// parameter cell_size = 16;


// singleCell c0(.x(x), .y(y), .x_shape(x_shape - cell_size), .y_shape(y_shape - cell_size), .isInner(tempInner[0]), .isEdge(tempEdge[0]));
// singleCell c1(.x(x), .y(y), .x_shape(x_shape - cell_size), .y_shape(y_shape), .isInner(tempInner[1]), .isEdge(tempEdge[1]));
// singleCell c2(.x(x), .y(y), .x_shape(x_shape - cell_size), .y_shape(y_shape + cell_size), .isInner(tempInner[2]), .isEdge(tempEdge[1]));
// singleCell c3(.x(x), .y(y), .x_shape(x_shape), .y_shape(y_shape - cell_size), .isInner(tempInner[3]), .isEdge(tempEdge[3]));
// singleCell c4(.x(x), .y(y), .x_shape(x_shape), .y_shape(y_shape), .isInner(tempInner[4]), .isEdge(tempEdge[4]));
// singleCell c5(.x(x), .y(y), .x_shape(x_shape), .y_shape(y_shape + cell_size), .isInner(tempInner[5]), .isEdge(tempEdge[5]));
// singleCell c6(.x(x), .y(y), .x_shape(x_shape + cell_size), .y_shape(y_shape + cell_size), .isInner(tempInner[6]), .isEdge(tempEdge[6]));
// singleCell c7(.x(x), .y(y), .x_shape(x_shape + cell_size), .y_shape(y_shape), .isInner(tempInner[7]), .isEdge(tempEdge[7]));
// singleCell c8(.x(x), .y(y), .x_shape(x_shape + cell_size), .y_shape(y_shape - cell_size), .isInner(tempInner[8]), .isEdge(tempEdge[8]));



// assign oneHotInnter = tempInner & shape_unit;
// assign oneHotEdge = tempEdge & shape_unit;

// assign isInnerRes = oneHotInnter ? 1 : 0;
// assign isEdgeRes = oneHotEdge ? 1 : 0;

// endmodule

module getInnerOrEdge(
    input [9:0]  addr_x, addr_y,
    input [9:0]  ref_x, ref_y,
    input [8:0] blockNeighbors,
    output toShowShapeInner, toShowShapeEdge
    );

    parameter size = 16;

    wire [8:0] en_i_origin, en_e_origin, en_i, en_e;

    singleCell b0(addr_x, addr_y, ref_x - size, ref_y - size, en_i_origin[0], en_e_origin[0]);
    singleCell b1(addr_x, addr_y, ref_x - size, ref_y, en_i_origin[1], en_e_origin[1]);
    singleCell b2(addr_x, addr_y, ref_x - size, ref_y + size, en_i_origin[2], en_e_origin[2]);
    singleCell b3(addr_x, addr_y, ref_x , ref_y - size, en_i_origin[3], en_e_origin[3]);
    singleCell b4(addr_x, addr_y, ref_x , ref_y, en_i_origin[4], en_e_origin[4]);
    singleCell b5(addr_x, addr_y, ref_x , ref_y + size, en_i_origin[5], en_e_origin[5]);
    singleCell b6(addr_x, addr_y, ref_x + size, ref_y - size, en_i_origin[6], en_e_origin[6]);
    singleCell b7(addr_x, addr_y, ref_x + size, ref_y, en_i_origin[7], en_e_origin[7]);
    singleCell b8(addr_x, addr_y, ref_x + size, ref_y + size, en_i_origin[8], en_e_origin[8]);

    assign en_i = en_i_origin & blockNeighbors;
    assign en_e = en_e_origin & blockNeighbors;

    assign toShowShapeInner = en_i ? 1 : 0;
    assign toShowShapeEdge  = en_e ? 1 : 0;

    // assign toShowShapeInner = en_i[0] | en_i[1] | en_i[2] | en_i[3] | en_i[4] |
    //                         en_i[5] | en_i[6] | en_i[7] | en_i[8] | en_i[9] |
    //                         en_i[10] | en_i[11];
    // assign toShowShapeEdge  = en_e[0] | en_e[1] | en_e[2] | en_e[3] | en_e[4] |
    //                         en_e[5] | en_e[6] | en_e[7] | en_e[8] | en_e[9] |
    //                         en_e[10] | en_e[11];

endmodule
