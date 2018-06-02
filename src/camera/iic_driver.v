`define TOTALSTAT 13
module iic_driver(
	input clk,
	input rst,
	output wire scl,
	inout sda,
	
	input wr_en,
	input rd_en,
	input [7:0] addr,
	output wire work_done,
	output wire ack,
	input [7:0] wr_data,
	output wire [7:0] rd_data,
	output wire [31:0] debug_out
);
	reg [7:0] stat;
	reg [7:0] next_stat;
	reg not_working;

	reg _sda;
	reg _wr;
	reg _rd;

	reg [7:0] _data;
	
	reg [7:0] wr_flag;
	reg [7:0] rd_flag;
	wire [7:0] _flag;

	assign _flag = _rd ? rd_flag : wr_flag;

	reg [2:0] acks;
	
	reg sda_writing;
	reg _done;

	initial begin
		stat = 6'h0;
		_sda = 1'b1;
		wr_flag = 8'h42;
		rd_flag = 8'h43;
		_wr = 1'b0;
		_rd = 1'b0;
		sda_writing = 1'b1;
	end

	assign scl = not_working || !clk;
	assign sda = sda_writing ? _sda : 1'bz;
	assign rd_data = _data;
	assign ack = acks[0] & acks[1] & acks[2];
	assign work_done = _done;

	always @(posedge clk or negedge rst) begin
		if (!rst) begin
			stat <= 6'b000000;
		end else begin
			if (_wr || _rd) begin
				stat <= next_stat;
			end else begin
				stat <= 6'b000000;
			end
		end
	end

	always @(*) begin
		if (stat == 8'hff) begin
			next_stat <= 8'hff;
		end else if (_wr || _rd) begin
			if (stat < `TOTALSTAT || !_done) begin
				if (stat == 8'd20 && _rd) begin
					next_stat <= 8'h4d;
				end else begin
					next_stat <= stat + 8'h1;
				end
			end else begin
				next_stat <= 8'h0;
			end
		end else begin
			next_stat <= 8'h0;
		end
	end

	always @(negedge rst or posedge clk) begin
		if (!rst) begin
			_rd <= 1'b0;
			_wr <= 1'b0;
			acks <= 3'b0;
			_done <= 1'b0;
			not_working <= 1'b1;
			sda_writing <= 1'b1;
			_sda <= 1'b1;
		end else begin
			case (stat)
				8'd0: begin 
					if (rd_en) begin
						_rd <= 1'b1;
					end
					if (wr_en) begin
						_wr <= 1'b1;
					end
					_sda <= 1'b1;
					sda_writing <= 1'b1;
				end
				8'd1: begin acks <= 3'b0; _done <= 1'b0; sda_writing <= 1'b1; end
				8'd2: begin not_working <= 1'b1; end
				8'd3: begin _sda <= wr_flag[7]; not_working <= 1'b0; end
				8'd4: begin _sda <= wr_flag[6]; end
				8'd5: begin _sda <= wr_flag[5]; end
				8'd6: begin _sda <= wr_flag[4]; end
				8'd7: begin _sda <= wr_flag[3]; end
				8'd8: begin _sda <= wr_flag[2]; end
				8'd9: begin _sda <= wr_flag[1]; end
				8'd10: begin _sda <= wr_flag[0]; end
				8'd11: begin sda_writing <= 1'b0; end
				8'd12: begin acks[0] <= sda; sda_writing <= 1'b1; _sda <= addr[7]; end
				8'd13: begin _sda <= addr[6]; end
				8'd14: begin _sda <= addr[5]; end
				8'd15: begin _sda <= addr[4]; end
				8'd16: begin _sda <= addr[3]; end
				8'd17: begin _sda <= addr[2]; end
				8'd18: begin _sda <= addr[1]; end
				8'd19: begin _sda <= addr[0]; end
				8'd20: begin sda_writing <= 1'b0; end
				8'd21: begin acks[1] <= sda; sda_writing <= _wr;  _sda <= wr_data[7]; end
				8'd22: begin _sda <= wr_data[6]; end
				8'd23: begin _sda <= wr_data[5]; end
				8'd24: begin _sda <= wr_data[4]; end
				8'd25: begin _sda <= wr_data[3]; end
				8'd26: begin _sda <= wr_data[2]; end
				8'd27: begin _sda <= wr_data[1]; end
				8'd28: begin _sda <= wr_data[0]; end
				8'd29: begin sda_writing <= 1'b0; end
				8'd30: begin acks[2] <= sda; sda_writing <= 1'b1; _sda <= 1'b0; end
				8'd31: begin not_working <= 1'b1; end
				8'd32: begin _sda <= 1'b1; _rd <= 1'b0; _wr <= 1'b0; _done <= 1'b1; end

				8'h4d: begin sda_writing <= 1'b1; _sda <= rd_flag[7]; acks[1] <= sda; end
				8'h4e: begin _sda <= rd_flag[6]; end
				8'h4f: begin _sda <= rd_flag[5]; end 
				8'h50: begin _sda <= rd_flag[4]; end
				8'h51: begin _sda <= rd_flag[3]; end
				8'h52: begin _sda <= rd_flag[2]; end
				8'h53: begin _sda <= rd_flag[1]; end
				8'h54: begin _sda <= rd_flag[0]; end
				8'h55: begin sda_writing <= 1'b0; not_working <= 1'b1; end
				8'h56: begin sda_writing <= 1'b1; _sda <= 1'b1; end
				8'h57: begin _sda <= 1'b0; end
				8'h58: begin not_working <= 1'b0; sda_writing <= 1'b0; end
				8'h59: begin _data[7] = sda; end
				8'h5a: begin _data[6] = sda; end
				8'h5b: begin _data[5] = sda; end
				8'h5c: begin _data[4] = sda; end
				8'h5d: begin _data[3] = sda; end
				8'h5e: begin _data[2] = sda; end
				8'h5f: begin _data[1] = sda; end
				8'h60: begin _data[0] = sda; sda_writing <= 1'b1; _sda <= 1'b0; end
				8'h61: begin _sda <= 1'b1; end
				8'h62: begin not_working <= 1'b1; _sda <= 1'b0; end
				8'h63: begin _sda <= 1'b1; end
				8'h64: begin _rd <= 1'b0; _wr <= 1'b0; _done <= 1'b1; end
			endcase
		end
	end

	assign debug_out[31:24] = stat;
	assign debug_out[23:20] = { 2'b0, sda_writing, sda };
	assign debug_out[19:16] = { _wr, _rd, _done, not_working };
	assign debug_out[15:8] = _data;
	assign debug_out[7:0] = _flag;
endmodule
