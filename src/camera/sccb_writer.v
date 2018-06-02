module sccb_writer(
	input clk,
	input rst,
	output wire scl,
	inout sda,
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

	camera_configure __configure(
		.clk(clk),
		.start(start),
		.sioc(scl),
		.siod(sda),
		.done(_done)
	);

	assign debug_out[3:0] = { 3'b0, _done };

	always @(negedge rst or posedge clk) begin
		if (!rst) begin
			start <= 1'b0;
			stat <= 8'h00;
		end else begin
			case (stat)
				8'h00: begin
					start <= 1'b1;
					stat <= 8'h01;
				end
				8'h01: begin
					start <= 1'b0;
					if (_done) begin
						stat <= 8'h02;
					end
				end
				8'h02: begin
					stat <= 8'h02;
				end
			endcase
		end
	end

endmodule
