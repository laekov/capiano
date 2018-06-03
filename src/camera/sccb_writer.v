module sccb_writer(
	input clk,
	input rst,
	output wire scl,
	output wire sda,
	output wire [31:0] debug_out,
	output wire work_done
);
	
	reg [7:0] stat;
	reg start;
	initial begin
		stat <= 8'h00;
		start <= 1'b0;
	end

	wire _done;
	assign work_done = _done;

	wire [31:0] cfg_debug_out;

	camera_configure#(.CLK_FREQ(12000000)) __configure(
		.clk(clk),
		.start(start),
		.sioc(scl),
		.siod(sda),
		.done(_done),
		.debug_out(cfg_debug_out)
	);

	assign debug_out = {3'b0, _done, cfg_debug_out[28:0]};

	reg [31:0] delay;

	always @(negedge rst or posedge clk) begin
		if (!rst) begin
			start <= 1'b0;
			stat <= 8'h00;
		end else begin
			case (stat)
				8'h00: begin
					start <= 1'b1;
					stat <= 8'h05;
					delay <= 10000;
				end
				8'h05: begin
					stat <= (delay == 0) ? 8'h01 : 8'h05;
					delay <= (delay == 0) ? 0 : delay - 1;
				end
				8'h01: begin
					if (_done) begin
						start <= 1'b0;
						stat <= 8'h02;
					end else begin
						start <= 1'b1;
						stat <= 8'h01;
					end
				end
				8'h02: begin
					stat <= 8'h02;
				end
			endcase
		end
	end

endmodule
