module yuv2rgb(
	input clk,
	input [31:0] yuv,
	input [31:0] r_max,
	input [31:0] g_min,
	input [31:0] b_max,
	output wire [8:0] rgb,
	output wire is_finger,
	output wire [31:0] debug_out
);
	reg [31:0] y;
	reg [31:0] u;
	reg [31:0] v;
	reg [31:0] c;
	reg [31:0] d0;
	reg [31:0] d1;
	reg [31:0] e0;
	reg [31:0] e1;
	wire [31:0] r;
	wire [31:0] g;
	wire [31:0] b;
	reg [31:0] _r;
	reg [31:0] _g;
	reg [31:0] _b;
	assign rgb = {r[15:13], g[15:13], b[15:13]};

	always @(posedge clk) begin
		y = {24'b0, yuv[23:16]} - 16;
		u = {24'b0, yuv[15:8]} - 128;
		v = {24'b0, yuv[31:24]} - 128;
	end

	always @(posedge clk) begin
		c <= y * 298;
		d0 <= u * 100;
		d1 <= u * 516;
		e0 <= v * 409;
		e1 <= v * 298;
	end

	always @(posedge clk) begin
		_r = c + e0 + 128;
		_g = c - d0 - e1 + 128;
		_b = c + d1 + 128;
	end

	assign r = _r[31] ? 0 : ((_r >= 32'h10000) ? 32'hff00: _r);
	assign g = _g[31] ? 0 : ((_g >= 32'h10000) ? 32'hff00: _g);
	assign b = _b[31] ? 0 : ((_b >= 32'h10000) ? 32'hff00: _b);

	assign is_finger = r < r_max && g > g_min && b < b_max;
endmodule
