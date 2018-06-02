`define SendToPC 31
`define SendToPCSize 32
module uart_test(
	input clk,
	input rst,
	input send_done,
	output wire send,
	output wire [`SendToPC:0] data,
	output wire [3:0] sta,
	output wire [3:0] nxtsta
);
reg [`SendToPC:0] Data;
reg tosend;
reg [3:0] status;
reg [3:0] nxt_sta;
assign send=tosend;
assign data=Data;
assign sta=status;
assign nxtsta=nxt_sta;
//initial begin
//	tosend<=1'b0;
//	status<=0;
//end
always @(posedge clk or negedge rst)begin
	if(!rst)status<=0;
	else status<=nxt_sta;
end
always @(status,rst)begin
	if (!rst) nxt_sta <= 0;
	else begin
			case (status)
					0: nxt_sta <= 1;
					1: nxt_sta <= 2;
					2: nxt_sta<=(send_done==1'b1)?4:2;
					3: nxt_sta <= 4;
					4: nxt_sta <= 4;
					5: nxt_sta <= 5;
					default: nxt_sta <= 5;
			endcase
		end
end
always @(*)begin
	case (status)
		0:tosend<=1'b0;
		1:begin
			tosend<=1'b1;
			//Data<=32'b0;
			Data<=32'b00000000000000001111111111111111;
			//Data<=32'b11111111111111111111111111111111;
		end
		2:tosend<=1'b1;
		3:begin
			tosend<=1'b0;
		end
		4:begin
			tosend<=1'b0;
		end
		5:begin
			tosend<=1'b0;
		end
		default:begin
			tosend<=1'b0;
		end
	endcase
end
endmodule