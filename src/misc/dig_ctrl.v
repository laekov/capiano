module dig_ctrl(
    input [3:0] dig,
    output reg [6:0] light
    );

	always @(*) begin
		case (dig)
			4'd0: light <= 7'b0111111;
			4'd1: light <= 7'b0000011;
			4'd2: light <= 7'b1011101;
			4'd3: light <= 7'b1001111;
			4'd4: light <= 7'b1100011;
			4'd5: light <= 7'b1101110;
			4'd6: light <= 7'b1111110;
			4'd7: light <= 7'b0001011;
			4'd8: light <= 7'b1111111;
			4'd9: light <= 7'b1101111;
			4'd10: light <= 7'b1111011;
			4'd11: light <= 7'b1110110;
			4'd12: light <= 7'b1010100;
			4'd13: light <= 7'b1010111;
			4'd14: light <= 7'b1111100;
			4'd15: light <= 7'b1111000;
		endcase
	end

	endmodule
