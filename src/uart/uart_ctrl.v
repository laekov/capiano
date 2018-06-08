`define SendToPC 39
`define SendToPCSize 40
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
	input [`SendToPC:0] data,
	output wire [7:0] sta,
	input [3:0] uart_send_sta,
	output wire [7:0] nxtsta,
	output wire flag
);
reg tosend;
reg sendDone;
reg [7:0] nxt_send_sta;
reg [7:0] sendData;
reg [7:0] send_status;
reg [`SendToPC:0] Data;
assign uart_send=tosend;
assign send_done=sendDone;
assign send_data=sendData;
assign sta=send_status;
assign nxtsta=nxt_send_sta;
//assign flag=(send_status[7:4]==0&&send_status[3:0]==0)?1'b1:1'b0;
assign flag=(send_status==0)?1'b1:1'b0;
initial begin
	send_status<=0;
	nxt_send_sta<=0;
	tosend<=1'b0;
	sendDone<=1'b0;
end
always @(posedge clk or negedge rst)begin
	if(!rst)send_status<=0;
	else begin
		case (send_status)
			0:begin
				if(send==1'b1)begin
					send_status<=1;
					sendDone<=1'b0;
					tosend<=1'b0;
					sendData<=data[7:0];
				end
				else begin
					sendDone<=1'b0;
					send_status<=0;
					tosend<=1'b0;
				end
			end
			1:begin
				if(uart_send_sta==9)begin
					send_status<=1;
					tosend<=1'b0;
					sendData<=data[7:0];
				end
				else begin
					send_status<=2;
					tosend<=1'b1;
					sendData<=data[7:0];
				end
			end
			2:begin
				if(uart_send_done==1'b1)begin
					send_status<=3;
					tosend<=1'b0;
					sendData<=data[15:8];
				end
				else begin
					send_status<=2;
					tosend<=1'b1;
					sendData<=data[7:0];
				end
			end
			3:begin
				if(uart_send_sta==9)begin
					send_status<=3;
					tosend<=1'b0;
					sendData<=data[15:8];
				end
				else begin
					send_status<=4;
					tosend<=1'b1;
					sendData<=data[15:8];
				end
			end
			4:begin
				if(uart_send_done==1'b1)begin
					send_status<=5;
					tosend<=1'b0;
					sendData<=data[23:16];
				end
				else begin
					send_status<=4;
					tosend<=1'b1;
					sendData<=data[15:8];
				end
			end
			5:begin
				if(uart_send_sta==9)begin
					send_status<=5;
					tosend<=1'b0;
					sendData<=data[23:16];
				end
				else begin
					send_status<=6;
					tosend<=1'b1;
					sendData<=data[23:16];
				end
			end
			6:begin
				if(uart_send_done==1'b1)begin
					send_status<=7;
					tosend<=1'b0;
					sendData<=data[31:24];
				end
				else begin
					send_status<=6;
					tosend<=1'b1;
					sendData<=data[23:16];
				end
			end
			7:begin
				if(uart_send_sta==9)begin
					send_status<=7;
					tosend<=1'b0;
					sendData<=data[31:24];
				end
				else begin
					send_status<=8;
					tosend<=1'b1;
					sendData<=data[31:24];
				end
			end
			8:begin
				if(uart_send_done==1'b1)begin
					send_status<=9;
					tosend<=1'b0;
					sendData<=data[39:32];
				end
				else begin
					send_status<=8;
					tosend<=1'b1;
					sendData<=data[31:24];
				end
			end
			9:begin
				if(uart_send_sta==9)begin
					send_status<=9;
					tosend<=1'b0;
					sendData<=data[39:32];
				end
				else begin
					send_status<=10;
					tosend<=1'b1;
					sendData<=data[39:32];
				end
			end
			10:begin
				if(uart_send_done==1'b1)begin
					send_status<=11;
					sendDone<=1'b1;
					tosend<=1'b0;
				end
				else begin
					send_status<=10;
					tosend<=1'b1;
					sendData<=data[39:32];
				end
			end
			11:begin
				send_status<=0;
				sendDone<=1'b1;
				tosend<=1'b0;
			end
			12:begin
				send_status<=12;
				tosend<=1'b0;
			end
			default:send_status<=12;
		endcase
	end
end



endmodule