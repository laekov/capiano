module quarter_clk(
	input raw_clk,
	output wire half,
	output wire qu,
	output wire d8,
	output wire d16
);
	reg [3:0] cnt;
	reg stat;

	assign half = cnt[0];
	assign qu = cnt[1];
	assign d8 = cnt[2];
	assign d16 = cnt[3];

	initial begin
		cnt = 4'b0000;
	end

	always @(posedge raw_clk) begin
		cnt <= (cnt == 4'b1111) ? 4'b0000 : (cnt + 4'b0001);
	end
endmodule
