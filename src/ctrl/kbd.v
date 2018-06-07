module kbd(
	input clk,
	input rst,
	input ps2c,
	input ps2d,
	output reg [7:0] real_data,
	output reg data_ready,
	output wire [31:0] debug_out
);

reg [7:0] stat;
reg prv_ps2c;
wire d;
assign d = ps2d;
wire act;
// assign act = prv_ps2c && !ps2c;
assign act = 1'b1;

wire even;
assign even = data[0] ^ data[1] ^ data[2] ^ data[3] ^ data[4] ^ data[5] ^ 
	         data[6] ^ data[7] ^ 1'b1;

assign debug_out = {real_data, stat, 3'b0, data_ready, 3'b0, act, 
	               3'b0, ps2c, 3'b0, ps2d};

initial begin
	stat <= 8'h00;
end

always @(posedge clk) begin
	prv_ps2c <= ps2c;
end

reg [15:0] rst_cnt;
reg [7:0] data;

initial begin
	rst_cnt = 0;
end

always @(posedge clk) begin
	if (stat[4] && !act) begin
		rst_cnt <= rst_cnt + 16'd1;
	end else begin
		rst_cnt <= 16'h0;
	end
end

always @(negedge ps2c or negedge rst) begin
	if (!rst) begin
		stat <= 8'h00;
		data_ready <= 1'b0;
	end else if (rst_cnt > 16'd20000) begin
		stat <= 8'h00;
	end else begin
		case (stat)
			8'h00: begin
				stat <= 8'h01;
			end
			8'h01: begin
				if (act && !d) begin
					stat <= 8'h10;
					data_ready <= 1'b0;
				end else begin
					stat <= 8'h01;
				end
			end
			8'h10: begin
				if (act) begin
					data[0] <= d;
					stat <= 8'h11;
				end
			end
			8'h11: begin
				if (act) begin
					data[1] <= d;
					stat <= 8'h12;
				end
			end
			8'h12: begin
				if (act) begin
					data[2] <= d;
					stat <= 8'h13;
				end
			end
			8'h13: begin
				if (act) begin
					data[3] <= d;
					stat <= 8'h14;
				end
			end
			8'h14: begin
				if (act) begin
					data[4] <= d;
					stat <= 8'h15;
				end
			end
			8'h15: begin
				if (act) begin
					data[5] <= d;
					stat <= 8'h16;
				end
			end
			8'h16: begin
				if (act) begin
					data[6] <= d;
					stat <= 8'h17;
				end
			end
			8'h17: begin
				if (act) begin
					data[7] <= d;
					stat <= 8'h03;
				end
			end
			8'h03: begin
				if (act) begin
					if (d == even) begin
						stat <= 8'h04;
						real_data <= data;
						data_ready <= 1'b1;
					end else begin
						stat <= 8'h01;
					end
				end
			end
			8'h04: begin
				if (act) begin 
					if (d) begin
						stat <= 8'h00;
					end else begin
						stat <= 8'h01;
					end
				end
			end
			default: begin
				stat <= 8'h00;
			end
		endcase
	end
end
endmodule
