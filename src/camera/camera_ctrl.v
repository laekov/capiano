// Camera control for OV7670 with FIFO
`define CamHeight 239
`define CamWidth 319
module camera_ctrl(
	input mem_clk,
	input clk,
	input [7:0] cam_data,
	input work_en,
	output wire rclk,
	output wire fifo_wen,
	output wire fifo_wrst,
	output wire fifo_rrst,
	output wire fifo_oe,
	input ov_vsync,
	
	input [31:0] addr,
	output reg [8:0] q,
	output reg [15:0] debug_out
);

	reg [15:0] cvs [0:32767];

	reg [8:0] _q;
	// assign q = _q;

	reg _rrst;
	reg _wrst;
	reg _wen;

	reg fifo_reading;

	assign rclk = clk && fifo_reading;
	assign fifo_oe = 1'b0;
	assign fifo_wen = _wen;

	reg [15:0] cur_x;
	reg [15:0] cur_y;
	reg [15:0] data;

	reg [1:0] stat;

	initial begin
		cur_x = 16'h0000;
		cur_y = 16'h0000;
		_rrst = 1'b1;
		_wrst = 1'b1;
		_wen = 1'b1;
		stat = 2'b11;
		fifo_reading = 1'b0;
	end

	assign fifo_rrst = _rrst;
	assign fifo_wrst = _wrst;

	always @(posedge mem_clk) begin
		q <= cvs[{ addr[24:18], addr[9:2] }][8:0];
	end

	always @(posedge clk) begin
		if (stat == 2'b00) begin
			cvs[{ cur_y[7:1], cur_x[8:1] }] <= { 7'b0, data[15:13], data[10:7], data[4:2] };
		end
	end

	reg [15:0] cnt_sync;
	reg sync_done;
	initial begin
		cnt_sync = 16'h0000;
		sync_done = 1'b0;
	end

	always @(posedge ov_vsync) begin
		if (stat == 2'b11) begin
			sync_done <= 1'b1;
			_wen <= 1'b1;
			//_wrst <= 1'b1;
		end else begin
			sync_done <= 1'b0;
			_wen <= 1'b0;
			//_wrst <= 1'b0;
		end
	end
	
	always @(posedge clk) begin
		case (stat)
			2'b10: begin // init stat
				fifo_reading <= 1'b1;
				stat <= 2'b00;
				cur_x <= 16'h0000;
				cur_y <= 16'h0000;
				_rrst <= 1'b1;
			end 
			2'b11: begin
				if (sync_done && work_en) begin
					stat <= 2'b10;
					_rrst <= 1'b0;
				end else begin
					stat <= 2'b11;
				end
			end 
			2'b01: begin
				data[15:8] <= cam_data;
				if (cur_x >= `CamWidth) begin
					cur_x <= 16'h0000;
					if (cur_y >= `CamHeight) begin
						fifo_reading <= 1'b0;
						stat <= 2'b11;
					end else begin
						cur_y <= cur_y + 16'h0001;
						stat <= 2'b00;
					end
				end else begin
					cur_x <= cur_x + 16'h0001;
					cur_y <= cur_y;
					stat <= 2'b00;
				end
			end
			2'b00: begin
				data[7:0] <= cam_data;
				stat <= 2'b01;
			end
		endcase
	end
endmodule

