module yuv2rgb(
	input [31:0] yuv,
	output wire [8:0] rgb,
	output wire is_finger
);
	wire [31:0] y;
	wire [31:0] u;
	wire [31:0] v;
	wire [31:0] c;
	wire [31:0] d;
	wire [31:0] e;
	wire [31:0] r;
	wire [31:0] g;
	wire [31:0] b;
	wire [31:0] _r;
	wire [31:0] _g;
	wire [31:0] _b;
	assign rgb = {r[15:13], g[15:13], b[15:13]};

	assign y = {24'b0, yuv[23:16]};
	assign u = {24'b0, yuv[15:8]};
	assign v = {24'b0, yuv[31:24]};

	assign c = y - 16;
	assign d = u - 128;
	assign e = v - 128;

	assign _r = (298 * c + 409 * e + 128);
	assign _g = (298 * c - 100 * d - 298 * e + 128);
	assign _b = (298 * c + 516 * d + 128);

	assign r = _r[31] ? 0 : ((_r >= 32'h10000) ? 32'hff00: _r);
	assign g = _g[31] ? 0 : ((_g >= 32'h10000) ? 32'hff00: _g);
	assign b = _b[31] ? 0 : ((_b >= 32'h10000) ? 32'hff00: _b);

	assign is_finger = r < 200 && g > 100 && b < 200;
endmodule
