module quarter_clk(
	input raw_clk,
	output wire half,
	output wire qu,
	output wire d8
);
	reg [2:0] cnt;
	reg stat;

	assign half = cnt[0];
	assign qu = cnt[1];
	assign d8 = cnt[2];

	initial begin
		cnt = 3'b000;
	end

	always @(posedge raw_clk) begin
		cnt <= (cnt == 3'b111) ? 3'b000 : (cnt + 3'b001);
	end
endmodule
