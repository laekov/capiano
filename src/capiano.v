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
	output wire rclk,
	output wire fifo_wen,
	output wire fifo_wrst,
	output wire fifo_rrst,
	output wire fifo_oe,
	input ov_vsync
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

	wire hf_clk;
	wire qu_clk;
	wire d8_clk;
	wire d16_clk;
	quarter_clk __quarter_clk(
		.raw_clk(clk),
		.qu(qu_clk),
		.half(hf_clk),
		.d8(d8_clk),
		.d16(d16_clk)
	);

	wire [31:0] vga_addr;
	wire [8:0] vga_data;
	vga_ctrl __vga_ctrl(
		.clk(qu_clk),
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
	camera_ctrl __cam0(
		.mem_clk(qu_clk),
		.clk(d8_clk),
		.rst(rst),
		.cam_data(cam_data),
		.work_en(cam0_en),
		.rclk(rclk),
		.fifo_wen(fifo_wen),
		.fifo_rrst(fifo_rrst),
		.fifo_oe(fifo_oe),
		.ov_vsync(ov_vsync),
		.addr(vga_addr),
		.q(vga_data),
		.debug_out(cam_out)
	);

	wire [31:0] sccb_out;
	sccb_checker __sccb0(
		.clk(man_clk),
		.rst(rst),
		.scl(scl),
		.sda(sda),
		.debug_out(sccb_out),
		.work_done(cam0_en)
	);

	// debug output from right to left 0 to 7
	wire [31:0] _out;
	assign _out = sccb_out;
	assign debug_out0 = _out[3:0];
	assign debug_out1 = _out[7:4];
	assign debug_out2 = _out[11:8];
	assign debug_out3 = _out[15:12];
	assign debug_out4 = _out[19:16];
	assign debug_out5 = _out[23:20];
	assign debug_out6 = _out[27:24];
	assign debug_out7 = _out[31:28];
endmodule
