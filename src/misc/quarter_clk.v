module quarter_clk(
	input raw_clk,
	output wire out_clk
);
	reg [1:0] cnt;
	reg stat;

	assign out_clk = stat;

	initial begin
		cnt = 1'b0;
		stat = 1'b0;
	end

	always @(posedge raw_clk) begin
		if (cnt == 1'b0) begin
			cnt <= 1'b1;
			stat <= stat;
		end else begin
			cnt <= 1'b0;
			stat <= !stat;
		end
	end
endmodule
