module capiano(
	input man_clk,
	input clk,
	input rst,
	output wire vga_hs,
	output wire vga_vs,
	output wire [2:0] vga_r,
	output wire [2:0] vga_g,
	output wire [2:0] vga_b,
	output wire [55:0] led
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

	vga_ctrl __vga_ctrl(
		.clk(clk),
		.rst(rst),
		.hs(vga_hs),
		.vs(vga_vs),
		.r(vga_r),
		.g(vga_g),
		.b(vga_b)
	);

	assign debug_out0 = { 1'b0, vga_r };
	assign debug_out1 = { 1'b0, vga_g };
	assign debug_out2 = { 1'b0, vga_b };
	assign debug_out3 = { vga_hs, vga_vs, clk, rst };
	assign debug_out4 = 4'h4;
	assign debug_out5 = 4'h5;
	assign debug_out6 = 4'ha;
	assign debug_out7 = 4'hc;

endmodule
