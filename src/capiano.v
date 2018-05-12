module capiano(
	input clk,
	input rst,
	output wire vga_hs,
	output wire vga_vs,
	output wire [2:0] vga_r,
	output wire [2:0] vga_g,
	output wire [2:0] vga_b
);
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
endmodule
