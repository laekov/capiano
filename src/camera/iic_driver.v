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
	inout [7:0] data,
	output wire [11:0] debug_out
);
	reg [5:0] stat;
	reg [5:0] next_stat;
	reg not_working;
	reg _sda;
	reg _wr;
	reg _rd;
	reg [23:0] cmb_data;
	reg [7:0] _data;
	
	reg [7:0] wr_flag;
	reg [7:0] rd_flag;

	reg [2:0] acks;
	
	reg sda_writing;
	reg _done;

	initial begin
		stat = 6'h0;
		not_working = 1'b1;
		_sda = 1'b1;
		wr_flag = 8'h42;
		rd_flag = 8'h43;
		_wr = 1'b0;
		_rd = 1'b0;
		sda_writing = 1'b1;
	end

	assign debug_out = { _wr, acks[2:0], sda, _rd, stat};

	assign scl = not_working || !clk;
	assign sda = sda_writing ? _sda : 1'bz;
	assign data = _rd ? _data[7:0] : 8'bzzzzzzzz;
	assign ack = acks[0] & acks[1] & acks[2];
	assign work_done = _done;

	always @(posedge wr_en or posedge rd_en or negedge rst) begin
		if (!rst) begin
			_wr <= 1'b0;
			_rd <= 1'b0;
		end else begin
			_wr <= wr_en ? 1'b1 : _wr;
			_rd <= rd_en ? 1'b1 : _rd;
		end
	end

	always @(posedge clk or negedge rst) begin
		if (!rst) begin
			stat <= 6'b000000;
		end else begin
			if (_wr || _rd) begin
				stat <= next_stat;
			end else if (stat != 6'b000000) begin
				stat <= 6'b111111;
			end
		end
	end

	always @(*) begin
		if (stat == 6'b111111) begin
			next_stat <= 6'b111111;
		end else if (stat[5:3] == 3'b111) begin // special events
			if (stat[2] == 1'b1) begin // send ack 
				if (stat[1:0] == 2'b10) begin // goto stop process
					next_stat <= 6'b111010;
				end else begin // send next byte
					next_stat <= { 1'b1, stat[1:0] + 2'b01, 3'b111 };
				end
			end else begin
				case (stat[2:0])
					3'b000: begin  // begin step 0, lower sda to begin
						next_stat <= 6'b111001; 
					end
					3'b001: begin  // begin step 1, enable scl
						next_stat <= 6'b100111; 
					end
					3'b010: begin  // end step 0, lower sda, disable scl
						next_stat <= 6'b111011; 
					end
					3'b011: begin // end step 1, higher sda
						next_stat <= 6'b000000;
					end
				endcase
			end
		end else if (stat[5] == 1'b1) begin // normally send bits
			if (stat[2:0] != 3'b000) begin
				next_stat <= stat - 6'h1;
			end else begin
				next_stat <= { 4'b1111, stat[4:3] };
			end
		end else begin
			next_stat <= (wr_en || rd_en) ? 6'b111000 : 6'b000000;
		end
	end

	always @(posedge clk or negedge rst) begin
		if (!rst) begin
			acks <= 4'b0000; 
			_done <= 1'b0;
			_sda <= 1'b1;
			not_working <= 1'b1;
		end else if (stat[5:3] == 3'b111) begin // special events
			if (stat[2] == 1'b1) begin // send ack 
				_sda <= 1'b1;
				if (stat[1:0] == 2'b01 && _rd) begin
					sda_writing = 1'b0;
				end
			end else begin
				case (stat[2:0])
					3'b000: begin  // begin step 0, lower sda to begin
						_sda <= 1'b0;
						acks <= 4'b0000; 
						_done <= 1'b0;
					end
					3'b001: begin  // begin step 1, enable scl
						cmb_data <= { data, addr, _wr ? 8'h42 : 8'h43 };
						not_working <= 1'b0; 
					end
					3'b010: begin  // end step 0, lower sda, disable scl
						acks[2] <= sda;
						_sda <= 1'b0;
						not_working <= 1'b1;
						sda_writing = 1'b1;
					end
					3'b011: begin // end step 1, higher sda
						_sda <= 1'b1;
						_done <= 1'b1;
					end
				endcase
			end
		end else if (stat[5] == 1'b1) begin // normally send bits
			if (stat[4:3] != 2'b00 && stat[2:0] == 3'b111) begin // receive ack
				acks[{ 1'b0, stat[4] }] <= sda;
			end
			if (_rd && stat[4:3] == 2'b10) begin
				_sda <= 1'b1;
				_data[stat[2:0]] <= sda;
			end else begin
				_sda <= cmb_data[stat[4:0]];
			end
		end
	end

endmodule
