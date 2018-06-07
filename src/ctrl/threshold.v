module threshold(
	input clk,
	input rst,
	input ps2c,
	input ps2d,
	output reg [31:0] rmax,
	output reg [31:0] gmin,
	output reg [31:0] bmax,
	output reg [31:0] cmin
);

wire key_ready;
wire [7:0] key_value;

kbd __kbd(
	.clk(clk),
	.rst(rst),
	.ps2c(ps2c),
	.ps2d(ps2d),
	.data_ready(data_ready),
	.real_data(key_value)
);

initial begin
	rmax = 32'h7f00;
	gmin = 32'h3f00;
	bmax = 32'h7f00;
	cmin = 32'h0010;
end

wire [31:0] r_lo;
wire [31:0] r_hi;
assign r_lo = (rmax == 32'h0) ? (32'hff00) : (rmax - 32'h100);
assign r_hi = (rmax == 32'hff00) ? (32'h0) : (rmax + 32'h100);

wire [31:0] g_lo;
wire [31:0] g_hi;
assign g_lo = (gmin == 32'h0) ? (32'hff00) : (gmin - 32'h100);
assign g_hi = (gmin == 32'hff00) ? (32'h0) : (gmin + 32'h100);

wire [31:0] b_lo;
wire [31:0] b_hi;
assign b_lo = (bmax == 32'h0) ? (32'hff00) : (bmax - 32'h100);
assign b_hi = (bmax == 32'hff00) ? (32'h0) : (bmax + 32'h100);

wire [31:0] c_lo;
wire [31:0] c_hi;
assign c_lo = (cmin == 32'h0) ? (32'hff) : (cmin - 32'h1);
assign c_hi = (cmin == 32'hff) ? (32'h0) : (cmin + 32'h1);

always @(posedge data_ready or negedge rst) begin
	if (!rst) begin
		rmax <= 32'h7f00;
		gmin <= 32'h3f00;
		bmax <= 32'h7f00;
		cmin <= 32'h0010;
	end else begin
		case (key_value) 
			8'h1c: rmax <= r_lo;
			8'h1b: gmin <= g_lo;
			8'h23: bmax <= b_lo;
			8'h2b: cmin <= c_lo;

			8'h15: rmax <= r_hi;
			8'h1d: gmin <= g_hi;
			8'h24: bmax <= b_hi;
			8'h2d: cmin <= c_hi;
		endcase
	end
end

endmodule
