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
	output fifo_oe,
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

	wire qu_clk;
	quarter_clk __quarter_clk(
		.raw_clk(clk),
		.out_clk(qu_clk)
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

	camera_ctrl __cam0(
		.clk(qu_clk),
		.cam_data(cam_data),
		.rclk(rclk),
		.fifo_wen(fifo_wen),
		.fifo_rrst(fifo_rrst),
		.fifo_oe(fifo_oe),
		.ov_vsync(ov_vsync),
		.addr(vga_addr),
		.q(vga_data)
	);

	wire [23:0] sccb_out;
	wire sccb_done;
	wheel_sccb_checker __sccb0(
		.clk(qu_clk),
		.rst(rst),
		.scl(scl),
		.sda(sda),
		.debug_out(sccb_out),
		.work_done(sccb_done)
	);

	// debug output from right to left 0 to 7
	assign debug_out0 = cam_data[3:0];
	assign debug_out1 = cam_data[7:4];
	assign debug_out2 = { 3'b0, fifo_rrst };
	assign debug_out3 = { 3'b0, rclk };
	assign debug_out4 = 4'ha;
	assign debug_out5 = { 2'b0, sccb_out[21:20] };
	assign debug_out6 = { 3'b0, sccb_out[22] };
	assign debug_out7 = { 3'b0, sccb_out[23] };
endmodule
