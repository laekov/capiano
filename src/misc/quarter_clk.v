module quarter_clk(
	input raw_clk,
	output wire[31:0] out_clk
);
	reg [31:0] clks;
	assign out_clk = clks;
	initial begin
		clks = 32'h00000000;
	end

	always @(posedge raw_clk) begin
		clks <= (clks == 32'hffffffff) ? 32'h00000000 : (clks + 1);
	end
endmodule
