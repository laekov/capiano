`define Coor 15:0
`define ScreenWidth 16'h031f
`define ScreenHeight 16'h020c
`define ValidWidth 16'h0280
`define ValidHeight 16'h01e0

module vga_ctrl(
	input clk,
	input rst,
	input [8:0] q,
	output wire hs,
	output wire vs,
	output wire [2:0] r,
	output wire [2:0] g,
	output wire [2:0] b,
	output wire [31:0] addr
);
	reg [`Coor] cur_x;
	reg [`Coor] cur_y;
	assign addr = { cur_y, cur_x };

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

	assign r = (cur_x < `ValidWidth && cur_y < `ValidHeight) ? _r : 3'b0;
	assign g = (cur_x < `ValidWidth && cur_y < `ValidHeight) ? _g : 3'b0;
	assign b = (cur_x < `ValidWidth && cur_y < `ValidHeight) ? _b : 3'b0;


	always @(*) begin
		if (hs && vs) begin
			_r <= q[8:6];
			_g <= q[5:3];
			_b <= q[2:0];
		end else begin
			_r <= 3'b000;
			_g <= 3'b000;
			_b <= 3'b000;
		end
	end
endmodule

