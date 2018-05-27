module uart(
	input clk,
	input rst,
	input send,
	input rx,
	input [7:0] send_data,
	output wire [7:0] read_data,
	output wire tx,
	output wire read_done,
	output wire send_done
);
reg [7:0] cnt;
reg uart_clk;
reg TX;
reg [3:0] read_status;
reg [3:0] nxt_read_sta;
reg [3:0] nxt_send_sta;
reg [3:0] send_status;
reg [7:0] readData;
reg [7:0] sendData;
reg readDone;
reg sendDone;
assign read_data=readData;
assign read_done=readDone;
assign send_done=sendDone;
assign tx=TX;
always @(posedge clk or negedge rst)begin
	if(!rst)cnt<=0;
	else begin
		if(cnt==867)cnt<=0;
		else cnt<=cnt+1;
	end
end
always @(posedge clk or negedge rst)begin
	if(!rst)uart_clk<=1'b0;
	else begin
		if(cnt==867)uart_clk<=1'b1;
		else uart_clk<=1'b0;
	end
end
always @(posedge uart_clk or negedge rst)begin
	if(!rst)begin
		read_status<=0;
		send_status<=0;
	end
	else begin
		read_status<=nxt_read_sta;
		send_status<=nxt_send_sta;
	end
end
always @(read_status)begin
	case(read_status)
		0:begin
			readDone<=1'b0;
			if(rx==1'b0)nxt_read_sta<=1;
			else nxt_read_sta<=0;
		end
		1:begin
			readData[0]<=rx;
			nxt_read_sta<=2;
		end
		2:begin
			readData[1]<=rx;
			nxt_read_sta<=3;
		end
		3:begin
			readData[2]<=rx;
			nxt_read_sta<=4;
		end
		4:begin
			readData[3]<=rx;
			nxt_read_sta<=5;
		end
		5:begin
			readData[4]<=rx;
			nxt_read_sta<=6;
		end
		6:begin
			readData[5]<=rx;
			nxt_read_sta<=7;
		end
		7:begin
			readData[6]<=rx;
			nxt_read_sta<=8;
		end
		8:begin
			readData[7]<=rx;
			nxt_read_sta<=9;
		end
		9:begin
			readDone<=1'b1;
			nxt_read_sta<=0;
		end
	endcase
end
always @(send_status)begin
	case(send_status)
		0:begin
			sendDone<=1'b0;
			if(send==1'b1)begin
				nxt_send_sta<=1;
				TX<=1'b0;
				sendData<=send_data;
			end
			else begin
				nxt_send_sta<=0;
				TX<=1'b1;
			end
		end
		1:begin
			TX<=sendData[0];
			nxt_send_sta<=2;
		end
		2:begin
			TX<=sendData[1];
			nxt_send_sta<=3;
		end
		3:begin
			TX<=sendData[2];
			nxt_send_sta<=4;
		end
		4:begin
			TX<=sendData[3];
			nxt_send_sta<=5;
		end
		5:begin
			TX<=sendData[4];
			nxt_send_sta<=6;
		end
		6:begin
			TX<=sendData[5];
			nxt_send_sta<=7;
		end
		7:begin
			TX<=sendData[6];
			nxt_send_sta<=8;
		end
		8:begin
			TX<=sendData[7];
			nxt_send_sta<=9;
		end
		9:begin
			sendDone<=1'b1;
			TX<=1'b1;
			nxt_send_sta<=0;
		end
	endcase
end
endmodule