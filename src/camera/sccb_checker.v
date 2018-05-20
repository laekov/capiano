module sccb_checker(
	input clk,
	input rst,
	output wire scl,
	inout sda,
	output wire [23:0] debug_out,
	output wire work_done
);

	reg iic_wr_en;
	reg iic_rd_en;

	reg [7:0] res1;
	reg [7:0] res2;

	reg rd_iic_data;
	reg [7:0] iic_addr;
	wire [7:0] iic_data;
	reg [7:0] wr_iic_data;
	wire iic_work_done;
	wire iic_ack;

	assign iic_data = rd_iic_data ? 8'bzzzzzzzz : wr_iic_data;

	wire [11:0] iic_debug_out;

	reg [5:0] stat;
	initial begin
		stat <= 6'hf;
	end

	assign debug_out = { iic_debug_out[7:0], res2, res1 }; //res1[3:0], iic_debug_out };

	assign work_done = stat == 6'h4;

	always @(posedge clk or negedge rst) begin
		if (!rst) begin
			stat <= 6'hf;
			res1 <= 8'b0;
			res2 <= 8'b0;
			iic_rd_en <= 1'b0;
			iic_wr_en <= 1'b0;
		end else begin
			case (stat) 
				6'hf: begin
					iic_rd_en <= 1'b0;
					iic_wr_en <= 1'b0;
					stat <= 6'h0;
				end
				6'h0: begin
					iic_addr <= 8'h1d;
					rd_iic_data <= 1'b1;
					iic_rd_en <= 1'b1;
					stat <= 6'h1;
				end
				6'h1: begin
					iic_rd_en <= 1'b0;
					if (iic_work_done) begin
						res1 <= iic_data;
						res2 <= 8'hbb;
						stat <= 6'h2;
					end else begin
						res1 <= 8'h12;
						res2 <= 8'hff;
					end
				end
				6'h2: begin
					iic_addr <= 8'h1c;
					rd_iic_data <= 1'b1;
					iic_rd_en <= 1'b1;
					stat <= 6'h3;
					res2 <= 8'haa;
				end
				6'h3: begin
					iic_rd_en <= 1'b0;
					if (iic_work_done) begin
						res2 <= iic_data;
						stat <= 6'h4;
					end
				end
				6'h4: begin
				end
			endcase
		end
	end
endmodule
