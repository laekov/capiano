module ram_test(
	input clk,
	input rst,
	output wire toread,
	output wire towrite,
	output wire [3:0] res,
	output wire [19:0] addr,
	output wire [31:0] to_data,
	output wire [3:0] tststa,
	input [31:0] get_data,
	input workdone
);
reg [2:0] status;
reg [3:0] cnt;
reg [19:0] _addr;
reg [31:0] _data;
reg _read;
reg _write;
reg [2:0] nxt_sta;
reg [31:0] mem_data;
reg [3:0] out;
assign addr=_addr;
assign to_data=_data;
assign toread=_read;
assign towrite=_write;
assign res=out;
assign tststa=status;
always @(status)begin
	case (status)
		3'b000:nxt_sta=3'b001;
		3'b001:nxt_sta=3'b010;
		3'b010:nxt_sta=3'b011;
		3'b011:nxt_sta=3'b011;
		default:status=3'b0;
	endcase
end
always @(posedge clk or negedge rst)begin
	if(!rst)begin
		status=3'b0;
		cnt=cnt+1;
	end
	else begin
		case (status)
			3'b000:begin
				_read=1'b0;
				_write=1'b0;
				out=4'b0;
				status=nxt_sta;
			end
			3'b001:begin
				_addr=20'b0;
				_write=1'b1;
				_read=1'b0;
				_data={28'b0,cnt};
				if(workdone)begin
					status=nxt_sta;
					out=4'b0001;
				end
				else begin
					status=3'b001;
				end
			end
			3'b010:begin
				_addr=20'b0;
				_write=1'b0;
				_read=1'b1;
				if(workdone)begin
					status=nxt_sta;
					out=get_data[3:0];
				end
				else begin
					status=3'b010;
				end
			end
			default:begin
				_read=1'b0;
				_write=1'b0;
				status=nxt_sta;
			end
		endcase
	end
end
endmodule