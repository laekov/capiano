// Camera control for OV7670 with FIFO
`define CamHeight 239
`define CamWidth 319
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
	output reg [15:0] debug_out
);

	assign ov_pwdn = 1'b0;
	assign ov_rst = 1'b1;

	reg [15:0] cvs [0:32767];

	reg [8:0] _q;
	// assign q = _q;

	reg [15:0] cur_x;
	reg [15:0] cur_y;
	reg [15:0] data;

	reg [1:0] stat;

	initial begin
		cur_x = 16'h0000;
		cur_y = 16'h0000;
		stat = 2'b11;
	end

	always @(posedge mem_clk) begin
		q <= cvs[{ addr[24:18], addr[9:2] }][8:0];
	end

	always @(posedge clk) begin
		if (stat == 2'b01) begin
			if ({ 17'b0, cur_y[14:0] } <= `CamHeight && { 17'b0, cur_x[14:0] } <= `CamHeight) begin
				cvs[{ cur_y[7:1], cur_x[8:1] }] <= { 7'b0, data[15:13], data[10:8], cam_data[4:2] };
			end
		end
	end

	reg [15:0] cnt_sync;
	reg sync_done;
	reg [15:0] f_cnt;
	initial begin
		cnt_sync = 16'h0000;
		sync_done = 1'b0;
		f_cnt = 16'h0000;
	end

	reg [15:0] clk_cnt;
	always @(posedge ov_pclk) begin
		clk_cnt <= clk_cnt + 16'h1;
		debug_out <= clk_cnt;
	end

	always @(posedge ov_vs or posedge ov_hs) begin
		if (ov_vs == 1'b1) begin
			cur_y <= 16'h8000 - 16'd17;
		end else begin
			cur_y <= cur_y + 16'h1;
		end
	end

	always @(posedge ov_pclk or negedge ov_hs) begin
		if (ov_hs == 1'b0) begin
			cur_x <= 16'h8000 - 16'd125;
			stat <= 2'b00;
		end else begin
			case (stat)
				2'b00: begin
					data[15:7] <= cam_data;
					stat <= 2'b01;
				end
				2'b01: begin
					cur_x <= cur_x + 16'h1;
					stat <= 2'b00;
				end
			endcase
		end
	end
endmodule
