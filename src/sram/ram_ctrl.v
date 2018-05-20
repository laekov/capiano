module ram_ctrl(
	input clk,
	input rst,
	input read,
	input write,
	input [19:0] inp_addr,
	input [31:0] inp_data,
	output wire [19:0] addr,
	inout [31:0] data,
	output wire CS,
	output wire OE,
	output wire WE,
	output wire workdone,
	output wire [31:0] out_data,
	output wire [3:0] nowsta,
	output wire [3:0] nowcnt
);
reg [19:0] mem_addr;
reg [19:0] mem_data;
reg [2:0] status;
reg [2:0] nxt_sta;
reg [2:0] cnt;
reg cs;
reg oe;
reg we;
reg reading;
reg done;
localparam num = 3'b011;
localparam INIT_STATUS = 3'b000;
localparam READ_ADDR = 3'b001;
localparam READ = 3'b010;
localparam WRITE1 = 3'b011;
localparam WRITE2 = 3'b100;
localparam PENDING = 3'b101;
localparam WRITE_END = 3'b110;
localparam READ_END = 3'b111;

assign addr=mem_addr;
assign data=(reading==1'b1)?mem_data:32'bz;
assign workdone=done;
assign out_data=mem_data;
assign CS=cs;
assign OE=oe;
assign WE=we;
assign nowsta={1'b0,status};
assign nowcnt={1'b0,cnt};

always @(status,rst) begin
	if (!rst) nxt_sta=READ_ADDR;
	else begin
			case (status)
					INIT_STATUS: nxt_sta = ((write==1'b1) || (read==1'b1))?READ_ADDR:INIT_STATUS;
					READ_ADDR: nxt_sta = (write==1'b1)?WRITE1:READ;
					READ: nxt_sta= PENDING;
					WRITE1: nxt_sta = WRITE2;
					WRITE2: nxt_sta = PENDING;
					PENDING: nxt_sta = (write==1'b1)?WRITE_END:READ_END;
					WRITE_END: nxt_sta=INIT_STATUS;
					READ_END: nxt_sta=INIT_STATUS;
					default: nxt_sta = INIT_STATUS;
			endcase
		end
end
always @(posedge clk or negedge rst)begin
	if(!rst)status=INIT_STATUS;
	else begin
		case (status)
			INIT_STATUS: status=nxt_sta;
			READ_ADDR: status=nxt_sta;
			READ: begin
				status=nxt_sta;
				cnt=3'b000;
			end
			WRITE1: status=nxt_sta;
			WRITE2:begin
				status=nxt_sta;
				cnt=3'b000;
			end
			PENDING:begin
				if(cnt==num)begin
					status=nxt_sta;
					cnt=3'b000;
				end
				else cnt=cnt+1;
			end
			WRITE_END: status=nxt_sta;
			READ_END: status=nxt_sta;
			default: status=INIT_STATUS;
		endcase
	end
end
always @(*) begin
	case (status)
		INIT_STATUS: begin
			reading=1'b0;
		end
		READ_ADDR: begin
			done=1'b0;
			mem_addr=inp_addr;
		end
		READ: begin
			cs=1'b0;//????
			oe=1'b0;//????
			we=1'b1;
			reading=1'b0;
		end
		WRITE1: begin
			cs=1'b0;
			we=1'b0;
			oe=1'b0;
		end
		WRITE2: begin
			reading=1'b1;
			mem_data=inp_data;
		end
		READ_END: begin
			mem_data=data;
			done=1'b1;
			cs=1'b1;
			oe=1'b1;
			we=1'b1;
		end
		WRITE_END: begin
			done=1'b1;
			reading=1'b0;
			cs=1'b1;
			oe=1'b1;
			we=1'b1;
		end
	endcase
end
endmodule