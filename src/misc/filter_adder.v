module filter_adder(
	input [2:0] in_1,
	input [2:0] in_2,
	input black,
	output wire [2:0] out
);
	wire [7:0] _in_1 = { 5'b0, in_1 };
	wire [7:0] _in_2 = { 5'b0, in_2 };
	wire [7:0] in_s = _in_1 + _in_2;
	assign out = black ? 3'b0 : (in_s > 7 ? 7 : in_s);
endmodule
