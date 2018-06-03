// Camera control for OV7670 with FIFO
`define CamHeight 479
`define CamWidth 639
module camera_ctrl(
	input mem_clk,
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

	reg [8:0] cvs [0:32767];

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

	always @(posedge frame_done) begin
		debug_out[15:0] <= {cur_y};
	end

	reg [15:0] prvd;
	wire [8:0] cur_q;
	yuv2rgb __yuv_converter(
		.yuv({prvd, data}),
		.rgb(cur_q)
	);

	always @(posedge ov_pclk or negedge rst) begin
		if (!rst) begin
			cur_x <= `CamWidth;
			cur_y <= 16'h0;
		end else if (pixel_valid) begin
			if (cur_x[0]) begin
				prvd <= data;
			end else begin
				cvs[{cur_y[8:2], cur_x[9:2]}] <= cur_q;
			end
			debug_out[31:16] <= data;
			if (cur_x > 0) begin
				cur_x <= cur_x - 1;
				cur_y <= cur_y;
			end else begin 
				cur_x <= `CamWidth;
				cur_y <= cur_y + 1;
			end
		end else if (frame_done) begin
			cur_x <= 16'h0;
			cur_y <= 16'h0;
		end
	end
endmodule
