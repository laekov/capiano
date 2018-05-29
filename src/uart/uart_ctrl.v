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
	output wire [7:0] sta
);
reg tosend;
reg sendDone;
reg [7:0] send_status;
reg [7:0] nxt_send_sta;
reg [7:0] sendData;
assign uart_send=tosend;
assign send_done=sendDone;
assign send_data=sendData;
assign sta=send_status;
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
always @(send_status)begin
	case (send_status)
		0:begin
			tosend<=1'b0;
			if(send==1'b1)begin
				sendDone<=1'b0;
				nxt_send_sta<=1;
			end
			else begin
				nxt_send_sta<=0;
			end
		end
1:begin
  nxt_send_sta<=2;
  tosend<=1'b1;
  sendData=data[7:0];
end
2:begin
  if(uart_send_done==1'b1)begin
    tosend<=1'b0;
    nxt_send_sta<=3;
  end
  else begin
    tosend<=1'b1;
    nxt_send_sta<=2;
  end
end
3:begin
  nxt_send_sta<=4;
  tosend<=1'b1;
  sendData=data[15:8];
end
4:begin
  if(uart_send_done==1'b1)begin
    tosend<=1'b0;
    nxt_send_sta<=5;
  end
  else begin
    tosend<=1'b1;
    nxt_send_sta<=4;
  end
end
5:begin
  nxt_send_sta<=6;
  tosend<=1'b1;
  sendData=data[23:16];
end
6:begin
  if(uart_send_done==1'b1)begin
    tosend<=1'b0;
    nxt_send_sta<=7;
  end
  else begin
    tosend<=1'b1;
    nxt_send_sta<=6;
  end
end
7:begin
  nxt_send_sta<=8;
  tosend<=1'b1;
  sendData=data[31:24];
end
8:begin
  if(uart_send_done==1'b1)begin
    tosend<=1'b0;
    nxt_send_sta<=9;
  end
  else begin
    tosend<=1'b1;
    nxt_send_sta<=8;
  end
end
9:begin
  nxt_send_sta<=10;
  tosend<=1'b1;
  sendData=data[39:32];
end
10:begin
  if(uart_send_done==1'b1)begin
    tosend<=1'b0;
    nxt_send_sta<=11;
  end
  else begin
    tosend<=1'b1;
    nxt_send_sta<=10;
  end
end
11:begin
  nxt_send_sta<=12;
  tosend<=1'b1;
  sendData=data[47:40];
end
12:begin
  if(uart_send_done==1'b1)begin
    tosend<=1'b0;
    nxt_send_sta<=13;
  end
  else begin
    tosend<=1'b1;
    nxt_send_sta<=12;
  end
end
13:begin
  nxt_send_sta<=14;
  tosend<=1'b1;
  sendData=data[55:48];
end
14:begin
  if(uart_send_done==1'b1)begin
    tosend<=1'b0;
    nxt_send_sta<=15;
  end
  else begin
    tosend<=1'b1;
    nxt_send_sta<=14;
  end
end
15:begin
  nxt_send_sta<=16;
  tosend<=1'b1;
  sendData=data[63:56];
end
16:begin
  if(uart_send_done==1'b1)begin
    tosend<=1'b0;
    nxt_send_sta<=17;
  end
  else begin
    tosend<=1'b1;
    nxt_send_sta<=16;
  end
end
17:begin
  nxt_send_sta<=18;
  tosend<=1'b1;
  sendData=data[71:64];
end
18:begin
  if(uart_send_done==1'b1)begin
    tosend<=1'b0;
    nxt_send_sta<=19;
  end
  else begin
    tosend<=1'b1;
    nxt_send_sta<=18;
  end
end
19:begin
  nxt_send_sta<=20;
  tosend<=1'b1;
  sendData=data[79:72];
end
20:begin
  if(uart_send_done==1'b1)begin
    tosend<=1'b0;
    nxt_send_sta<=21;
  end
  else begin
    tosend<=1'b1;
    nxt_send_sta<=20;
  end
end
21:begin
  nxt_send_sta<=22;
  tosend<=1'b1;
  sendData=data[87:80];
end
22:begin
  if(uart_send_done==1'b1)begin
    tosend<=1'b0;
    nxt_send_sta<=23;
  end
  else begin
    tosend<=1'b1;
    nxt_send_sta<=22;
  end
end
23:begin
  nxt_send_sta<=24;
  tosend<=1'b1;
  sendData=data[95:88];
end
24:begin
  if(uart_send_done==1'b1)begin
    tosend<=1'b0;
    nxt_send_sta<=25;
  end
  else begin
    tosend<=1'b1;
    nxt_send_sta<=24;
  end
end
25:begin
  nxt_send_sta<=26;
  tosend<=1'b1;
  sendData=data[103:96];
end
26:begin
  if(uart_send_done==1'b1)begin
    tosend<=1'b0;
    nxt_send_sta<=27;
  end
  else begin
    tosend<=1'b1;
    nxt_send_sta<=26;
  end
end
27:begin
  nxt_send_sta<=28;
  tosend<=1'b1;
  sendData=data[111:104];
end
28:begin
  if(uart_send_done==1'b1)begin
    tosend<=1'b0;
    nxt_send_sta<=29;
  end
  else begin
    tosend<=1'b1;
    nxt_send_sta<=28;
  end
end
29:begin
  nxt_send_sta<=30;
  tosend<=1'b1;
  sendData=data[119:112];
end
30:begin
  if(uart_send_done==1'b1)begin
    tosend<=1'b0;
    nxt_send_sta<=31;
  end
  else begin
    tosend<=1'b1;
    nxt_send_sta<=30;
  end
end
31:begin
  nxt_send_sta<=32;
  tosend<=1'b1;
  sendData=data[127:120];
end
32:begin
  if(uart_send_done==1'b1)begin
    tosend<=1'b0;
    nxt_send_sta<=33;
  end
  else begin
    tosend<=1'b1;
    nxt_send_sta<=32;
  end
end
33:begin
  nxt_send_sta<=34;
  tosend<=1'b1;
  sendData=data[135:128];
end
34:begin
  if(uart_send_done==1'b1)begin
    tosend<=1'b0;
    nxt_send_sta<=35;
  end
  else begin
    tosend<=1'b1;
    nxt_send_sta<=34;
  end
end
35:begin
  nxt_send_sta<=36;
  tosend<=1'b1;
  sendData=data[143:136];
end
36:begin
  if(uart_send_done==1'b1)begin
    tosend<=1'b0;
    nxt_send_sta<=37;
  end
  else begin
    tosend<=1'b1;
    nxt_send_sta<=36;
  end
end
37:begin
  nxt_send_sta<=38;
  tosend<=1'b1;
  sendData=data[151:144];
end
38:begin
  if(uart_send_done==1'b1)begin
    tosend<=1'b0;
    nxt_send_sta<=39;
  end
  else begin
    tosend<=1'b1;
    nxt_send_sta<=38;
  end
end
39:begin
  nxt_send_sta<=40;
  tosend<=1'b1;
  sendData=data[159:152];
end
40:begin
  if(uart_send_done==1'b1)begin
    tosend<=1'b0;
    nxt_send_sta<=41;
  end
  else begin
    tosend<=1'b1;
    nxt_send_sta<=40;
  end
end
41:begin
  nxt_send_sta<=42;
  tosend<=1'b1;
  sendData=data[167:160];
end
42:begin
  if(uart_send_done==1'b1)begin
    tosend<=1'b0;
    nxt_send_sta<=43;
  end
  else begin
    tosend<=1'b1;
    nxt_send_sta<=42;
  end
end
43:begin
  nxt_send_sta<=44;
  tosend<=1'b1;
  sendData=data[175:168];
end
44:begin
  if(uart_send_done==1'b1)begin
    tosend<=1'b0;
    nxt_send_sta<=45;
  end
  else begin
    tosend<=1'b1;
    nxt_send_sta<=44;
  end
end
45:begin
  nxt_send_sta<=46;
  tosend<=1'b1;
  sendData=data[183:176];
end
46:begin
  if(uart_send_done==1'b1)begin
    tosend<=1'b0;
    nxt_send_sta<=47;
  end
  else begin
    tosend<=1'b1;
    nxt_send_sta<=46;
  end
end
47:begin
  nxt_send_sta<=48;
  tosend<=1'b1;
  sendData=data[191:184];
end
48:begin
  if(uart_send_done==1'b1)begin
    tosend<=1'b0;
    nxt_send_sta<=49;
  end
  else begin
    tosend<=1'b1;
    nxt_send_sta<=48;
  end
end
49:begin
  nxt_send_sta<=50;
  tosend<=1'b1;
  sendData=data[199:192];
end
50:begin
  if(uart_send_done==1'b1)begin
    tosend<=1'b0;
    nxt_send_sta<=51;
  end
  else begin
    tosend<=1'b1;
    nxt_send_sta<=50;
  end
end
51:begin
  nxt_send_sta<=52;
  tosend<=1'b1;
  sendData=data[207:200];
end
52:begin
  if(uart_send_done==1'b1)begin
    tosend<=1'b0;
    nxt_send_sta<=53;
  end
  else begin
    tosend<=1'b1;
    nxt_send_sta<=52;
  end
end
53:begin
  nxt_send_sta<=54;
  tosend<=1'b1;
  sendData=data[215:208];
end
54:begin
  if(uart_send_done==1'b1)begin
    tosend<=1'b0;
    nxt_send_sta<=55;
  end
  else begin
    tosend<=1'b1;
    nxt_send_sta<=54;
  end
end
55:begin
  nxt_send_sta<=56;
  tosend<=1'b1;
  sendData=data[223:216];
end
56:begin
  if(uart_send_done==1'b1)begin
    tosend<=1'b0;
    nxt_send_sta<=57;
  end
  else begin
    tosend<=1'b1;
    nxt_send_sta<=56;
  end
end
57:begin
  nxt_send_sta<=58;
  tosend<=1'b1;
  sendData=data[231:224];
end
58:begin
  if(uart_send_done==1'b1)begin
    tosend<=1'b0;
    nxt_send_sta<=59;
  end
  else begin
    tosend<=1'b1;
    nxt_send_sta<=58;
  end
end
59:begin
  nxt_send_sta<=60;
  tosend<=1'b1;
  sendData=data[239:232];
end
60:begin
  if(uart_send_done==1'b1)begin
    tosend<=1'b0;
    nxt_send_sta<=61;
  end
  else begin
    tosend<=1'b1;
    nxt_send_sta<=60;
  end
end
61:begin
  nxt_send_sta<=62;
  tosend<=1'b1;
  sendData=data[247:240];
end
62:begin
  if(uart_send_done==1'b1)begin
    tosend<=1'b0;
    nxt_send_sta<=63;
  end
  else begin
    tosend<=1'b1;
    nxt_send_sta<=62;
  end
end
63:begin
  nxt_send_sta<=64;
  tosend<=1'b1;
  sendData=data[255:248];
end
64:begin
  if(uart_send_done==1'b1)begin
    tosend<=1'b0;
    nxt_send_sta<=65;
  end
  else begin
    tosend<=1'b1;
    nxt_send_sta<=64;
  end
end
65:begin
  nxt_send_sta<=66;
  tosend<=1'b1;
  sendData=data[263:256];
end
66:begin
  if(uart_send_done==1'b1)begin
    tosend<=1'b0;
    nxt_send_sta<=67;
  end
  else begin
    tosend<=1'b1;
    nxt_send_sta<=66;
  end
end
67:begin
  nxt_send_sta<=68;
  tosend<=1'b1;
  sendData=data[271:264];
end
68:begin
  if(uart_send_done==1'b1)begin
    tosend<=1'b0;
    nxt_send_sta<=69;
  end
  else begin
    tosend<=1'b1;
    nxt_send_sta<=68;
  end
end
69:begin
  nxt_send_sta<=70;
  tosend<=1'b1;
  sendData=data[279:272];
end
70:begin
  if(uart_send_done==1'b1)begin
    tosend<=1'b0;
    nxt_send_sta<=71;
  end
  else begin
    tosend<=1'b1;
    nxt_send_sta<=70;
  end
end
71:begin
  nxt_send_sta<=72;
  tosend<=1'b1;
  sendData=data[287:280];
end
72:begin
  if(uart_send_done==1'b1)begin
    tosend<=1'b0;
    nxt_send_sta<=73;
  end
  else begin
    tosend<=1'b1;
    nxt_send_sta<=72;
  end
end
73:begin
  nxt_send_sta<=74;
  tosend<=1'b1;
  sendData=data[295:288];
end
74:begin
  if(uart_send_done==1'b1)begin
    tosend<=1'b0;
    nxt_send_sta<=75;
  end
  else begin
    tosend<=1'b1;
    nxt_send_sta<=74;
  end
end
75:begin
  nxt_send_sta<=76;
  tosend<=1'b1;
  sendData=data[303:296];
end
76:begin
  if(uart_send_done==1'b1)begin
    tosend<=1'b0;
    nxt_send_sta<=77;
  end
  else begin
    tosend<=1'b1;
    nxt_send_sta<=76;
  end
end
77:begin
  nxt_send_sta<=78;
  tosend<=1'b1;
  sendData=data[311:304];
end
78:begin
  if(uart_send_done==1'b1)begin
    tosend<=1'b0;
    nxt_send_sta<=79;
  end
  else begin
    tosend<=1'b1;
    nxt_send_sta<=78;
  end
end
79:begin
  nxt_send_sta<=80;
  tosend<=1'b1;
  sendData=data[319:312];
end
80:begin
  if(uart_send_done==1'b1)begin
    tosend<=1'b0;
    nxt_send_sta<=81;
  end
  else begin
    tosend<=1'b1;
    nxt_send_sta<=80;
  end
end
		81:begin
			sendDone<=1'b1;
			tosend<=1'b0;
			nxt_send_sta<=0;
		end
		
	endcase
end
endmodule