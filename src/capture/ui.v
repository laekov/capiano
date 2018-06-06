module ui #(
	parameter NUM_KEYS = 39
) (
	input [31:0] addr,
	input [8:0] canvas_color,
	input [NUM_KEYS:0] key_down,
	input is_finger,
	output wire [8:0] q
);
	wire [8:0] _q;
	wire [15:0] y;
	wire [15:0] x;
	wire [15:0] key_id;
	wire this_down;

	assign y = addr[31:16];
	assign x = addr[15:0];
	assign key_id = {4'b0, addr[15:4]};
	assign this_down = key_id <= NUM_KEYS ? key_down[key_id] : 1'b0;

	wire is_key;
	wire is_key_vertical_line;
	wire is_key_horizontal_line;
	wire [8:0] filter;
	wire [8:0] filtered_col;

	assign is_key = (y > 320);
	assign is_key_vertical_line = is_key && (x[3:0] < 2);
	assign is_key_horizontal_line = (y < 320 && y > 317);
	assign filter = is_key_horizontal_line ? 9'b000100000 : (is_key ? (this_down ? 9'b100100000 : 9'b110110110) : 9'b0);

	assign q = is_finger ? 9'b111000000 : (this_down && is_key ? 9'b111111100 : _q);

	filter_adder ar(
		.in_1(canvas_color[8:6]),
		.in_2(filter[8:6]),
		.out(_q[8:6]),
		.black(is_key_vertical_line)
	);

	filter_adder ag(
		.in_1(canvas_color[5:3]),
		.in_2(filter[5:3]),
		.out(_q[5:3]),
		.black(is_key_vertical_line)
	);

	filter_adder ab(
		.in_1(canvas_color[2:0]),
		.in_2(filter[2:0]),
		.out(_q[2:0]),
		.black(is_key_vertical_line)
	);

endmodule
