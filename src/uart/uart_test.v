`define SendToPC 39
`define SendToPCSize 40
module uart_test(
	input clk,
	input rst,
	input send_done,
	input [39:0] InpData,
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
	if (!rst) status<=0;
	else begin
			case (status)
					0:begin
						status <= 1;
						tosend<=1'b0;
					end
					1:begin
						status <= 2;
						tosend<=1'b0;
						Data<=InpData;
					end
					2:begin
						if(send_done==1'b1)begin
							status<=4;
							tosend<=1'b0;
						end
						else begin
							status<=2;
							//Data<=40'b0000000000000000111111001111100111100111;
							tosend<=1'b1;
						end
					end
					3:begin
						tosend<=1'b0;
						status <= 4;
					end
					4:begin
						tosend<=1'b0;
						status <= 0;
					end
					5:begin
						tosend<=1'b0;
						status <= 5;
					end
					default: status<=5;
			endcase
		end
end

endmodule