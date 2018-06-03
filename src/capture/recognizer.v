module recognizer #(
	parameter NUM_KEYS = 39
) (
	input clk,
	input rst,
	input [31:0] addr,
	input [1:0] q,
	output reg [NUM_KEYS:0] key_down
);
	reg [31:0] cnt_fingers [NUM_KEYS:0];
	wire [15:0] x;
	assign x = addr[15:0];
	assign key_id = addr[15:3];

	integer i;

	always @(negedge rst or posedge clk) begin
		if (!rst) begin
			for (i = 0; i <= NUM_KEYS; i = i + 1) begin
				cnt_fingers[i] <= 0;
				key_down[i] <= 0;
			end
		end else begin
			if (key_id <= NUM_KEYS) begin
				if (q[1]) begin
					if (q[0]) begin
						cnt_fingers[key_id] <= cnt_fingers[key_id] + 1;
					end else begin
						cnt_fingers[key_id] <= cnt_fingers[key_id] - 1;
					end
					key_down[key_id] <= cnt_fingers[key_id] > 5;
				end
			end
		end
	end
endmodule
