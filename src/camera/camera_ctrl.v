// Camera control for OV7670 with FIFO
`define CvsHeight 119
`define CvsWidth 159
module camera_ctrl(
	input clk,
	input [7:0] cam_data,
	output wire rclk,
	output wire fifo_wen,
	output wire fifo_wrst,
	output wire fifo_rrst,
	output wire fifo_oe,
	input ov_vsync,
	
	input [31:0] addr,
	output wire [8:0] q
);

	reg [8:0] cvs [0:`CvsHeight][0:`CvsWidth];

	// assign q = (addr[31:17] <= `CvsHeight && addr[15:1] <= `CvsWidth) ? cvs[addr[31:17]][addr[15:1]] : 9'b000000000;
	reg [8:0] _q;
	assign q = _q;

	reg _rrst;
	reg _wrst;

	assign rclk = clk;
	assign fifo_oe = 1'b0;
	assign fifo_wen = 1'b1;
	assign fifo_rrst = _rrst;
	assign fifo_wrst = _wrst;

	reg [15:0] cur_x;
	reg [15:0] cur_y;
	reg [15:0] data;

	reg [1:0] stat;

	initial begin
		cur_x = 16'h0000;
		cur_y = 16'h0000;
		_rrst = 1'b1;
		_wrst = 1'b1;
		stat = 2'b00;
	end

	always @(posedge rclk) begin
		if (stat == 2'b00) begin
			// cvs[cur_y[15:2]][cur_x[15:2]] <= { data[14:12], data[9:7], data[4:2] };
			_q <= { data[15:13], data[10:8], data[4:2] };
			data[7:0] <= cam_data;
			stat <= 2'b01;
		end else if (stat == 2'b01) begin
			data[15:8] <= cam_data;
			if (cur_x == `CvsWidth) begin
				cur_x <= 16'h0000;
			end else begin
				cur_x <= cur_x + 16'h0001;
				if (cur_y == `CvsHeight) begin
					cur_y <= 16'h0000;
				end else begin
					cur_y <= cur_y + 16'h0001;
				end
			end
			stat <= 2'b00;
		end
	end
endmodule

