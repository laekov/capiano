module kbd(
	input clk,
	input rst,
	input ps2c,
	input ps2d,
	output reg [7:0] data,
	output reg data_ready,
	output wire [31:0] debug_out
);

reg [15:0] stat;
reg prv_ps2c;
wire d;
assign d = ps2d;
wire act;
assign act = prv_ps2c && !ps2c;
reg [2:0] di;

assign debug_out = {data, 1'b0, di, stat[3:0], 3'b0, data_ready, 3'b0, act, 3'b0, ps2c, 3'b0, ps2d};

initial begin
	stat <= 16'h00;
end

always @(posedge clk) begin
	prv_ps2c <= ps2c;
end

always @(posedge clk or negedge rst) begin
	if (!rst) begin
		stat <= 16'h00;
		data_ready <= 1'b0;
	end else begin
		case (stat)
			16'h00: begin
				stat <= 16'h01;
			end
			16'h01: begin
				if (act) begin
					if (!d) begin
						stat <= 16'h02;
						di <= 3'b000;
						data_ready <= 1'b0;
					end
				end else begin
					stat <= 16'h10;
				end
			end
			16'h10: begin
				if (act) begin
					data[0] <= d;
					stat <= 16'h11;
				end
			end
			16'h11: begin
				if (act) begin
					data[1] <= d;
					stat <= 16'h12;
				end
			end
			16'h12: begin
				if (act) begin
					data[2] <= d;
					stat <= 16'h13;
				end
			end
			16'h13: begin
				if (act) begin
					data[3] <= d;
					stat <= 16'h14;
				end
			end
			16'h14: begin
				if (act) begin
					data[4] <= d;
					stat <= 16'h15;
				end
			end
			16'h15: begin
				if (act) begin
					data[5] <= d;
					stat <= 16'h16;
				end
			end
			16'h16: begin
				if (act) begin
					data[6] <= d;
					stat <= 16'h17;
				end
			end
			16'h17: begin
				if (act) begin
					data[7] <= d;
					stat <= 16'h03;
				end
			end
			16'h03: begin
				if (act) begin
					stat <= 16'h00;
				end
			end
			16'h04: begin
				if (d) begin
					stat <= 16'h00;
				end else begin
					stat <= 16'h01;
				end
				data_ready <= 1'b1;
			end
		endcase
	end
end
endmodule
