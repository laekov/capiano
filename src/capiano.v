module capiano(
	input man_clk,
	input clk,
	input rst,
	output wire vga_hs,
	output wire vga_vs,
	output wire [2:0] vga_r,
	output wire [2:0] vga_g,
	output wire [2:0] vga_b,
	output wire [55:0] led,

	input [7:0] cam_data,
	output wire scl,
	inout sda,
	input ov_vs,
	input ov_hs,
	input ov_pclk,
	output wire ov_mclk,
	output wire ov_rst,
	input ov_pwdn
);
	wire [3:0] debug_out0;
	wire [3:0] debug_out1;
	wire [3:0] debug_out2;
	wire [3:0] debug_out3;
	wire [3:0] debug_out4;
	wire [3:0] debug_out5;
	wire [3:0] debug_out6;
	wire [3:0] debug_out7;
	wire [3:0] debug_out8;

	dig_ctrl __dig_0( .dig(debug_out0), .light(led[6:0]) );
	dig_ctrl __dig_1( .dig(debug_out1), .light(led[13:7]) );
	dig_ctrl __dig_2( .dig(debug_out2), .light(led[20:14]) );
	dig_ctrl __dig_3( .dig(debug_out3), .light(led[27:21]) );
	dig_ctrl __dig_4( .dig(debug_out4), .light(led[34:28]) );
	dig_ctrl __dig_5( .dig(debug_out5), .light(led[41:35]) );
	dig_ctrl __dig_6( .dig(debug_out6), .light(led[48:42]) );
	dig_ctrl __dig_7( .dig(debug_out7), .light(led[55:49]) );

	wire clk24;
	wire clk12;
	wire clk6;
	pll __pll(
		.inclk0(clk),
		.c0(clk24)
	);
	quarter_clk __divider1(
		.raw_clk(clk24),
		.out_clk(clk12)
	);
	quarter_clk __divider2(
		.raw_clk(clk12),
		.out_clk(clk6)
	);

	wire [31:0] vga_addr;
	wire [8:0] vga_data;
	vga_ctrl __vga_ctrl(
		.clk(clk24),
		.rst(!rst),
		.hs(vga_hs),
		.vs(vga_vs),
		.r(vga_r),
		.g(vga_g),
		.b(vga_b),
		.addr(vga_addr),
		.q(vga_data)
	);

	wire [31:0] cam_out;
	wire cam0_en;
	assign ov_mclk = clk12;
	wire [8:0] cam_vga_data;
	wire [1:0] cam_delta;
	camera_ctrl __cam0(
		.mem_clk(clk24),
		.rst(rst),
		.cam_data(cam_data),
		.ov_vs(ov_vs),
		.ov_hs(ov_hs),
		.ov_pclk(ov_pclk),
		.ov_rst(ov_rst),
		.ov_pwdn(ov_pwdn),
		.addr(vga_addr),
		.q(cam_vga_data),
		.delta(cam_delta),
		.debug_out(cam_out)
	);

	wire [39:0] key_down;
	recognizer __recog(
		.clk(ov_pclk),
		.rst(rst),
		.addr(vga_addr),
		.q(cam_delta),
		.key_down(key_down)
	);

	ui __ui(
		.addr(vga_addr),
		.canvas_color(cam_vga_data),
		.key_down(key_down),
		.q(vga_data)
	);

	// debug output from right to left 0 to 7
	wire [31:0] _out;
	reg [3:0] cntt;
	initial cntt = 0;
	always @(posedge man_clk) begin
		cntt <= cntt + 1;
	end
	assign _out[3:0] = cntt;
	// assign _out = {15'b0, cam0_en, cam_out[15:0]};
	assign debug_out0 = _out[3:0];
	assign debug_out1 = _out[7:4];
	assign debug_out2 = _out[11:8];
	assign debug_out3 = _out[15:12];
	assign debug_out4 = _out[19:16];
	assign debug_out5 = _out[23:20];
	assign debug_out6 = _out[27:24];
	assign debug_out7 = _out[31:28];
endmodule
