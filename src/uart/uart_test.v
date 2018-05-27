module uart_test(
	input clk,
	input rst,
	input send_done,
	output wire send,
	output wire [319:0] data
);
reg [319:0] Data;
reg tosend;
reg [3:0] status;
reg [3:0] nxt_sta;
assign send=tosend;
assign data=Data;
always @(posedge clk or negedge rst)begin
	if(!rst)status<=0;
	else status<=nxt_sta;
end
always @(status)begin
	case (status)
		0:begin
			tosend<=1'b0;
			nxt_sta<=1;
		end
		1:begin
			tosend<=1'b1;
			Data<=320'b0;
			nxt_sta<=2;
		end
		2:begin
			if(send_done==1'b1)begin
				tosend<=1'b0;
				nxt_sta<=3;
			end
			else nxt_sta<=2;
		end
		3:begin
			tosend<=1'b1;
			Data<=320'b1;
			nxt_sta<=4;
		end
		4:begin
			nxt_sta<=0;
		end
	endcase
end
endmodule