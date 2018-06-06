module quarter_clk(
	input raw_clk,
	output reg out_clk
);
	initial begin
		out_clk = 1'b0;
	end

	always @(posedge raw_clk) begin
		out_clk <= ~out_clk;
	end
endmodule
