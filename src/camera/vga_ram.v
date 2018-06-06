module vga_ram(
	input clk,
	input rst, 
	input [31:0] addr,
	input [14:0] c_addr,
	input [8:0] c_data,
	input [17:0] f_addr,
	input [17:0] f_rd_addr,
	input f_data,
	output reg [8:0] q,
	output reg f_rd_data,
	output reg is_finger
);

reg finger [0:131072];
reg [8:0] cvs [0:32767];


always @(posedge clk) begin
	cvs[c_addr] <= c_data;
end

always @(negedge clk) begin
	q <= cvs[{addr[24:18], addr[9:2]}];
end

always @(posedge clk) begin
	finger[f_addr] <= f_data;
end

always @(negedge clk) begin
	is_finger <= finger[{addr[24:17], addr[9:1]}];
	f_rd_data <= finger[f_rd_addr];
end

endmodule
