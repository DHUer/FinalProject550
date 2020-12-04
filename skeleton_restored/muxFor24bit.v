module muxFor24bit(in0, in1, en, out);

	input[23: 0] in0;
	input[23: 0] in1;
	input en;
	output [23: 0] out;
	assign out = en ? in1: in0;
endmodule
