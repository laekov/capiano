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

always @(posedge clk or negedge rst)begin
	if(!rst)send_status<=0;
	else begin	
		send_status<=nxt_send_sta;
	end
end
initial begin
	send_status<=0;
	nxt_send_sta<=0;
	tosend<=1'b0;
	sendDone<=1'b0;
end
always @(rst,send_status)begin
  if(!rst)nxt_send_sta<=0;
  else begin
    case (send_status)
    0:nxt_send_sta<=(send==1'b1)?1:0;
      1:nxt_send_sta<=(uart_send_sta==9)?1:2;
      2:nxt_send_sta<=(uart_send_done==1'b1)?3:2;
      3:nxt_send_sta<=(uart_send_sta==9)?3:4;
      4:nxt_send_sta<=(uart_send_done==1'b1)?5:4;
      5:nxt_send_sta<=(uart_send_sta==9)?5:6;
      6:nxt_send_sta<=(uart_send_done==1'b1)?7:6;
      7:nxt_send_sta<=(uart_send_sta==9)?7:8;
      8:nxt_send_sta<=(uart_send_done==1'b1)?9:8;
      9:nxt_send_sta<=(uart_send_sta==9)?9:10;
      10:nxt_send_sta<=(uart_send_done==1'b1)?11:10;
      11:nxt_send_sta<=0;
      12:nxt_send_sta<=12;
      default:nxt_send_sta<=12;
    endcase
  end
end
always @(*)begin
  case (send_status)
  0:begin
    tosend<=1'b0;
    if(send==1'b1)begin
      sendDone<=1'b0;
      Data<=data;
      end
  end
  1:begin
    tosend<=1'b0;
    sendData<=Data[7:0];
  end
  2:tosend<=1'b1;
  3:begin
    tosend<=1'b0;
    sendData<=Data[15:8];
  end
  4:tosend<=1'b1;
  5:begin
    tosend<=1'b0;
    sendData<=Data[23:16];
  end
  6:tosend<=1'b1;
  7:begin
    tosend<=1'b0;
    sendData<=Data[31:24];
  end
  8:tosend<=1'b1;
  9:begin
    tosend<=1'b0;
    sendData<=Data[39:32];
  end
  10:tosend<=1'b1;
  11:begin
    sendDone<=1'b1;
    tosend<=1'b0;
  end
  default: tosend<=1'b0;
  endcase
end


endmodule