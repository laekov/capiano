module recognizer #(
	parameter NUM_KEYS = 39
) (
	input clk,
	input rst,
	input [31:0] addr,
	input [1:0] q,
	output reg [NUM_KEYS:0] key_down,
	output reg [31:0] debug_out
);
	reg [31:0] cnt_fingers [NUM_KEYS:0];
	wire [15:0] x;
	wire [15:0] y;
	wire [15:0] key_id;
	assign x = addr[15:0];
	assign y = addr[31:16];
	assign key_id = {4'b0, addr[15:4]};

	integer i;

	always @(negedge rst or posedge clk) begin
		debug_out <= {cnt_fingers[2][15:0], key_id[7:0], 2'b0, q[1], 3'b0, q[0]};
		if (!rst) begin
			for (i = 0; i <= NUM_KEYS; i = i + 1) begin
				cnt_fingers[i] <= 0;
				key_down[i] <= 0;
			end
		end else begin
			if (y > 320 && key_id <= NUM_KEYS) begin
				if (q[1]) begin
					if (q[0]) begin
						cnt_fingers[key_id] <= cnt_fingers[key_id] + 1;
					end else begin
						cnt_fingers[key_id] <= cnt_fingers[key_id] - 1;
					end
					key_down[key_id] <= !cnt_fingers[key_id][31] && cnt_fingers[key_id] > 5;
				end
			end
		end
	end
endmodule
