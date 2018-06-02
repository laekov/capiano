// Camera control for OV7670 with FIFO
`define CamHeight 479
`define CamWidth 639
module camera_ctrl(
	input mem_clk,
	input clk,
	input rst,
	input [7:0] cam_data,
	input work_en,

	input ov_vs,
	input ov_hs,
	input ov_pclk,
	output wire ov_rst,
	output wire ov_pwdn,
	
	input [31:0] addr,
	output reg [8:0] q,
	output reg [31:0] debug_out
);

	assign ov_pwdn = 1'b0;
	assign ov_rst = 1'b1;

	reg [15:0] cvs [0:32767];

	reg [8:0] _q;
	// assign q = _q;

endmodule
