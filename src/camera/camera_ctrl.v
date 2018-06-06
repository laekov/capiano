// Camera control for OV7670 with FIFO
`define CamHeight 479
`define CamWidth 639
module camera_ctrl #(
	parameter NUM_KEYS = 39
) (
	input clk,
	input man_clk,
	input rst,
	input [7:0] cam_data,
	input work_en,

	input ov_vs,
	input ov_hs,
	input ov_pclk,
	output wire ov_rst,
	output wire ov_pwdn,
	
	input [31:0] addr,
	output wire [8:0] q,
	output wire is_finger,
	output reg [NUM_KEYS:0] key_down,
	output wire [31:0] debug_out
);
	always @(posedge ov_pclk) begin
	end

	assign ov_pwdn = 1'b0;
	assign ov_rst = 1'b1;

	reg [14:0] c_addr;
	reg [8:0] c_data;
	reg f_data;
	reg [17:0] f_addr;
	wire [17:0] f_rd_addr;
	wire f_rd_data;

	vga_ram __vga_ram(
		.clk(clk),
		.rst(rst),
		.c_addr(c_addr),
		.c_data(c_data),
		.f_addr(f_addr),
		.f_data(f_data),
		.f_rd_addr(f_rd_addr),
		.f_rd_data(f_rd_data),
		.addr(addr),
		.is_finger(is_finger),
		.q(q)
	);

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

	reg [15:0] prvd;
	wire [8:0] cur_q;
	wire _is_finger;

	wire [31:0] yuv_out;
	yuv2rgb __yuv_converter(
		.man_clk(man_clk),
		.clk(ov_pclk),
		.yuv({prvd, data}),
		.is_finger(_is_finger),
		.rgb(cur_q),
		.debug_out(yuv_out)
	);
	assign debug_out = yuv_out;

	wire this_finger;
	assign this_finger = _is_finger;

	assign f_rd_addr = {cur_y[8:1], cur_x[9:1]};
	wire old_finger;
	assign old_finger = f_rd_data;
	reg [31:0] cnt_rst;
	initial begin
		cnt_rst = 0;
	end

	integer x_i;

	wire [15:0] key_id;
	reg [31:0] cnt_fingers [NUM_KEYS:0];
	assign key_id = {4'b0, cur_x[15:4]};
	integer i;

	always @(posedge ov_pclk or negedge rst) begin
		if (!rst) begin
			cur_x <= `CamWidth;
			cur_y <= 16'h0;
			for (i = 0; i <= NUM_KEYS; i = i + 1) begin
				cnt_fingers[i] <= 0;
			end
			cnt_rst <= 0;
		end else if (pixel_valid) begin
			if (cur_x[0]) begin
				prvd <= data;
			end else begin
				c_addr <= {cur_y[8:2], cur_x[9:2]};
				c_data <= cur_q;
				if (key_id <= NUM_KEYS && cur_y > 16'd320) begin
					cnt_fingers[key_id] <= cnt_fingers[key_id] +
					                       {31'b0, this_finger} -
										   {31'b0, old_finger};
				end
				f_addr <= {cur_y[8:1], cur_x[9:1]};
				f_data <= this_finger;
			end
			if (cur_x > 0) begin
				cur_x <= cur_x - 1;
				cur_y <= cur_y;
			end else begin 
				cur_x <= `CamWidth;
				cur_y <= cur_y + 1;
			end
		end else if (frame_done) begin
			if (cnt_rst > 30) begin
				for (x_i = 0; x_i <= NUM_KEYS; x_i = x_i + 1) begin
					cnt_fingers[x_i] <= 0;
				end
				cnt_rst <= 0;
			end else begin
				cnt_rst <= cnt_rst + 1;
			end
			for (x_i = 0; x_i <= NUM_KEYS; x_i = x_i + 1) begin
				key_down[x_i] <= (!cnt_fingers[x_i][31] &&
					              cnt_fingers[x_i] > 15);
				cnt_fingers[x_i] <= 0;
			end
			cur_x <= 16'h0;
			cur_y <= 16'h0;
		end
	end
endmodule
