module sccb_checker(
	input clk,
	input rst,
	output wire scl,
	inout sda,
	output wire [31:0] debug_out,
	output wire work_done
);

	reg iic_wr_en;
	reg iic_rd_en;

	reg [7:0] res1;
	reg [7:0] res2;

	reg [7:0] iic_addr;
	reg [7:0] iic_wr_data;
	wire [7:0] iic_rd_data;
	wire iic_work_done;
	wire iic_ack;

	wire [31:0] iic_debug_out;

	reg [5:0] stat;
	initial begin
		stat <= 6'hf;
	end

	assign debug_out = iic_debug_out[31:0];

	assign work_done = stat == 6'h4;

	iic_driver __driver(
		.clk(clk),
		.rst(rst),
		.scl(scl),
		.sda(sda),
		.wr_en(iic_wr_en),
		.rd_en(iic_rd_en),
		.addr(iic_addr),
		.work_done(iic_work_done),
		.ack(iic_ack),
		.wr_data(iic_wr_data),
		.rd_data(iic_rd_data),
		.debug_out(iic_debug_out)
	);

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
					iic_rd_en <= 1'b1;
					stat <= 6'h9;
				end
				6'h9: begin
					iic_rd_en <= 1'b0;
					stat <= 6'h1;
				end
				6'h1: begin
					if (iic_work_done) begin
						res1 <= iic_rd_data;
						res2 <= 8'hbb;
						stat <= 6'h4;
					end else begin
						res1 <= 8'h12;
						res2 <= 8'hff;
					end
				end
				6'h2: begin
					iic_addr <= 8'h1c;
					iic_rd_en <= 1'b1;
					stat <= 6'h8;
					res2 <= 8'haa;
				end
				6'h8: begin
					iic_rd_en <= 1'b0;
					stat <= 6'h3;
				end
				6'h3: begin
					if (iic_work_done) begin
						res2 <= iic_rd_data;
						stat <= 6'h4;
					end
				end
				6'h4: begin
					stat <= 6'h4;
				end
			endcase
		end
	end
endmodule
