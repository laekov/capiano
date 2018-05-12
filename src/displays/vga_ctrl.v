`define Coor 15:0
`define ScreenWidth 16'h031f
`define ScreenHeight 16'h020c

module vga_ctrl(
	input clk,
	input rst,
	output wire hs,
	output wire vs,
	output wire [2:0] r,
	output wire [2:0] g,
	output wire [2:0] b
);
	reg [`Coor] cur_x;
	reg [`Coor] cur_y;

	initial begin
		cur_x = 16'b0;
		cur_y = 16'b0;
	end

	always @(posedge clk or posedge rst) begin
		if (rst) begin
			cur_x <= 16'b0;
			cur_y <= 16'b0;
		end else begin
			cur_x <= (cur_x == `ScreenWidth) ? 16'b0 : (cur_x + 16'h0001);
			cur_y <= (cur_x == `ScreenWidth) ? ((cur_y == `ScreenHeight) ? 16'b0 : (cur_y + 16'h0001)) : cur_y;
		end
	end

	assign hs = !rst && (cur_x < 16'd656 || cur_x >= 16'd752);
	assign vs = !rst && (cur_y < 16'd490 || cur_y >= 16'd492);

	reg [2:0] _r;
	reg [2:0] _g;
	reg [2:0] _b;

	assign r = _r;
	assign g = _g;
	assign b = _b;

	always @(*) begin
		if (hs && vs) begin
			_r <= (cur_x < 16'd400) ? 3'b111 : 3'b000;
			_g <= (cur_y < 16'd300) ? 3'b111 : 3'b000;
			_b <= (cur_x > 16'd300 && cur_y > 16'd300) ? 3'b111 : 3'b000;
		end else begin
			_r <= 3'b000;
			_g <= 3'b000;
			_b <= 3'b000;
		end
	end
endmodule

