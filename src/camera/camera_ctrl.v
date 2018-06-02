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
	initial begin
		debug_out = 32'h0;
	end
	always @(posedge ov_pclk) begin
	end

	assign ov_pwdn = 1'b0;
	assign ov_rst = 1'b1;

	reg [15:0] cvs [0:32767];

	wire [15:0] data;
	wire pixel_valid;
	wire frame_done;

	camera_read __reader(
		.p_clock(ov_pclk),
		.vsync(ov_vs),
		.href(ov_hs),
		.p_data(cam_data),
		.pixel_data(data),
		.pixel_valid(pixel_valid),
		.frame_done(frame_done)
	);

	reg [15:0] cur_x;
	reg [15:0] cur_y;
	initial begin
		cur_x = 16'h0000;
		cur_y = 16'h0000;
	end

	always @(posedge mem_clk) begin
		q <= cvs[{addr[24:18], addr[9:2]}];
	end

	reg [31:0] ca;
	reg [31:0] pau;
	initial begin
		pau = 0;
		ca = 0;
	end
	always @(posedge ov_pclk or negedge rst) begin
		if (!rst) begin
			pau <= 0;
			ca <= 0;
		end else if (pau < 100000000) begin
			if (ov_vs) begin
				ca <= ca + 1;
			end
			pau <= pau + 1;
			debug_out <= ca;
		end
	end

	always @(posedge pixel_valid or posedge frame_done or negedge rst) begin
		if (pixel_valid) begin
			cvs[{cur_y[8:2], cur_x[9:2]}] <= data;
			if (cur_x < `CamWidth) begin
				cur_x <= cur_x + 1;
				cur_y <= cur_y;
			end else begin 
				cur_x <= 16'h0000;
				cur_y <= cur_y + 1;
			end
		end else begin
			cur_x <= 16'h0;
			cur_y <= 16'h0;
		end 
	end
endmodule
