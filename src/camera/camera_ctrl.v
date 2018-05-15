// Camera control for OV7670 with FIFO
`define CvsHeight 239
`define CvsWidth 319
module camera_ctrl(
	input clk,
	input [7:0] cam_data,
	input rclk,
	output wire fifo_wen,
	input fifo_wrst,
	input fifo_rrst,
	input fifo_oe,
	input ov_vsync,
	
	input [31:0] addr,
	output [8:0] q
);

	// reg [8:0] cvs [0:131071];

	// assign q = (addr[31:17] <= `CvsHeight && addr[15:1] <= `CvsWidth) ? cvs[addr[31:17]][addr[15:1]] : 9'b000000000;
	reg [2:0] _r;
	reg [2:0] _g;
	reg [2:0] _b;
	assign q = { _r, _g, _b };

	reg _wen;
	assign fifo_wen = _wen;
	initial begin
		_wen = 1'b1;
	end

	reg [15:0] cur_x;
	reg [15:0] cur_y;

	initial begin
		cur_x = 16'h0000;
		cur_y = 16'h0000;
	end

	always @(posedge rclk) begin
		{ _r, _g, _b } <= { cur_x[4:0], cur_y[3:0] };
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
	end
endmodule

