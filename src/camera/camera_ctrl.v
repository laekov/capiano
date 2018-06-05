// Camera control for OV7670 with FIFO
`define CamHeight 479
`define CamWidth 639
module camera_ctrl #(
	parameter NUM_KEYS = 39
) (
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
	output reg [NUM_KEYS:0] key_down,
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
	reg finger [0:131072];

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

	wire thisisfinger;
	isfinger __is_finger(
		.q(cur_q),
		.is_finger(thisisfinger)
	);

	reg old_finger;
	always @(posedge ov_pclk) begin
		old_finger <= finger[{cur_y[8:1], cur_x[9:1]}];
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
			debug_out[31:16] <= 16'habcd;
		end else if (pixel_valid) begin
			if (cur_x[0]) begin
				prvd <= data;
			end else begin
				cvs[{cur_y[8:2], cur_x[9:2]}] <= cur_q;
				cnt_fingers[key_id] <= cnt_fingers[key_id] +
					                   {31'b0, thisisfinger} -
					                   {31'b0, old_finger};
				finger[{cur_y[8:1], cur_x[9:1]}] <= thisisfinger;
			end
			if (cur_x > 0) begin
				cur_x <= cur_x - 1;
				cur_y <= cur_y;
			end else begin 
				cur_x <= `CamWidth;
				cur_y <= cur_y + 1;
			end
		end else if (frame_done) begin
			debug_out[31:16] <= cnt_fingers[10][15:0];
			for (x_i = 0; x_i <= NUM_KEYS; x_i = x_i + 1) begin
				key_down[x_i] <= (!cnt_fingers[x_i][31] &&
					              cnt_fingers[x_i] > 30);
				cnt_fingers[x_i] <= 0;
			end
			cur_x <= 16'h0;
			cur_y <= 16'h0;
		end
	end
endmodule
