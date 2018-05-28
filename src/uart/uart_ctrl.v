module uart_ctrl(
	input clk,
	input rst,
	input uart_read_done,
	input uart_send_done,
	output wire uart_send,
	input [7:0] read_data,
	output wire [7:0] send_data,
	output wire send_done,
	input send,
	input [319:0] data,
	output wire [3:0] sta
);
reg tosend;
reg sendDone;
reg [9:0] pos;
reg [3:0] send_status;
reg [3:0] nxt_send_sta;
reg [7:0] sendData;
assign uart_send=tosend;
assign send_done=sendDone;
assign send_data=sendData;
assign sta=send_status;
integer i;
always @(posedge clk or negedge rst)begin
	if(!rst)send_status<=0;
	else begin
		send_status<=nxt_send_sta;
	end
end
always @(send_status)begin
	case (send_status)
		0:begin
			tosend<=1'b0;
			if(send==1'b1)begin
				pos<=0;
				sendDone<=1'b0;
				nxt_send_sta<=1;
			end
			else nxt_send_sta<=0;
		end
		1:begin
			if(pos>=320)begin
				nxt_send_sta<=3;
				//tosend<=1'b0;
			end
			else begin
				nxt_send_sta<=2;
				tosend<=1'b1;
				//sendData<=data[pos+7:pos];
				for(i=0;i<8;i=i+1)
					sendData[i]<=data[pos+i];
			end
		end
		2:begin
			if(uart_send_done==1'b1)begin
				tosend<=1'b0;
				nxt_send_sta<=1;
				pos<=pos+8;
			end
			else begin
				tosend<=1'b1;
				nxt_send_sta<=2;
			end
		end
		3:begin
			sendDone<=1'b1;
			tosend<=1'b0;
			nxt_send_sta<=0;
		end
	endcase
end
endmodule