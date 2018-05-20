module cmos_top(
			osc_24MHZ,
			iRST,
			clk,
			//ov7660
			ov7660_reset,
			ov7660_xclk,
			ov7660_pclk,
			ov7660_data_8bit,
			iVSYNC,
		    iLVAL,
			lcd2_cs,
			lcd2_wr,
			lcd2_rs,
			lcd2_reset,
			lcd2_rd,
			lcd2_data16,
			oDVAL,
			lcd_data_valid
		);
		input osc_24MHZ;
		input iRST;
		input clk;
		//ov7660
		output ov7660_reset;
		output ov7660_xclk;
		input ov7660_pclk;
		input [7:0] ov7660_data_8bit;
		input iVSYNC;
		input iLVAL;
		//tft
		output lcd2_cs;
		output lcd2_wr;
		output lcd2_rs;
		output lcd2_reset;
		output lcd2_rd;
		output [15:0] lcd2_data16;
		output lcd_data_valid;
///////////////////////////////////
		output oDVAL;
assign iCLK = ov7660_pclk;
assign lcd2_wr = reg_lcd2_wr;    
assign lcd2_rs = 1'b1; 
assign lcd2_rd = 1'b1;
assign lcd2_cs = 1'b0;
assign lcd2_reset = 1'b1;
assign lcd2_data16[15:0] = ov7660_data_16bit[15:0];
		
reg				Pre_FVAL;
reg				mCCD_FVAL;
reg				mCCD_LVAL;
reg		[7:0]	mCCD_DATA;
reg		[10:0]	X_Cont;
reg		[10:0]	Y_Cont;

assign	oX_Cont		=	X_Cont;
assign	oY_Cont		=	Y_Cont;
//assign	i0v7660_data_8bit[7:0]	=	mCCD_DATA[7:0];
assign	i0v7660_data_8bit[7:0]	= ov7660_data_8bit[7:0];
//assign	oDVAL		=	mCCD_FVAL&mCCD_LVAL;
assign	oDVAL		=	~iVSYNC;//   tft_outenable & (~iVSYNC);	
wire [7:0] i0v7660_data_8bit;
////////////////////////////////
//
assign iFVAL = iVSYNC;
reg [1:0] temp_count;
always@(posedge iCLK or negedge iRST)
begin
	if(!iRST)
	begin
		Pre_FVAL	<=	0;
		mCCD_FVAL	<=	0;
		mCCD_LVAL	<=	0;
		mCCD_DATA[7:0]	<=	8'h00;
		X_Cont		<=	0;
		Y_Cont		<=	0;
	end
	else
	begin
		Pre_FVAL	<=	iFVAL;
		if( {Pre_FVAL,iFVAL}==2'b10)
		mCCD_FVAL	<=	1;
		else if({Pre_FVAL,iFVAL}==2'b01)
		mCCD_FVAL	<=	0;
		
		mCCD_LVAL	<=	iLVAL;
		if(mCCD_FVAL)
		begin
			if(mCCD_LVAL)
			begin
				X_Cont	<=	X_Cont+1;
				if(X_Cont==639)
				begin
					X_Cont	<=	0;
					Y_Cont	<=	Y_Cont+1;
				end
			end
		end
		else
		begin
			X_Cont	<=	0;
			if(temp_count == 3)
				begin
				Y_Cont	<=	0;
				temp_count <= 2'b00;
				end
			else
				temp_count <= temp_count + 1'b1;
		end
	end
end
///////////////////////////////////////////////////////
//ov7660 data 8 bit to 16 bit
//功    能：将输入的8位数据转换成16位，同时进行位转换。
//由OV7660 RGB565 的输出格式 RRRRRGGGGGGBBBBB 改为 BBBBBGGGGGGRRRRR 格式
//转换后的数据符合TFT 数据输入格式
reg  state1;
reg [7:0] pre_i0v7660_data_8bit;
reg [15:0] ov7660_data_16bit;
always@(posedge iCLK or negedge iRST)
	if(!iRST)
		begin
			state1 <= 1'b0;
		end
	else
	begin
	if(iLVAL & mCCD_FVAL)
		case(state1)
		1'b0 : begin
			pre_i0v7660_data_8bit[7:0] <= i0v7660_data_8bit[7:0];
			state1 <= 1'b1;
			end
		1'b1 : begin
			ov7660_data_16bit[15:0] <= {pre_i0v7660_data_8bit[7:0],i0v7660_data_8bit[7:0]};
			state1 <= 1'b0;
			end
		default : state1 <= 1'b0;
		endcase
	end


reg temp1;
reg temp2;
always@(posedge iCLK or negedge iRST)
	if(!iRST)
		begin
			temp1 <= 1'b0;
			temp2 <= 1'b0;
		end
	else
		begin
			temp1 <= iLVAL;
			temp2 <= temp1;
		end		
	
reg reg_lcd2_wr;
reg write_state;
reg lcd_data_valid;
always@(negedge iCLK or negedge iRST)
	if(!iRST)
		begin
			reg_lcd2_wr <= 1'b1;
			write_state <= 1'b0;
			lcd_data_valid <= 1'b0;
		end
	else 
		case(write_state)
			0 : if(temp2&(Y_Cont == 0)&tft_outenable)
				begin
					reg_lcd2_wr <= ~reg_lcd2_wr;
					write_state <= 1'b1;
					lcd_data_valid <= 1'b1;
				end
				else
					begin
					reg_lcd2_wr <= 1'b1;
					lcd_data_valid <= 1'b0;
					end
			1 : begin
				if(temp2)
					reg_lcd2_wr <= ~reg_lcd2_wr;
				else
					reg_lcd2_wr <= 1'b1;
				if(Y_Cont < 240)
					write_state <= 1'b1;
				else
					begin
					write_state <= 1'b0;
					lcd_data_valid <= 1'b0;
					end
				end
		endcase
reg [2:0] Frame_Cont;
reg tft_outenable;
always@(posedge iCLK or negedge iRST)
begin
	if(!iRST)
		Frame_Cont	<=	0;
	else
	begin
		if({Pre_FVAL,iFVAL}==2'b10)
			if(Frame_Cont < 7)
				begin
				Frame_Cont	<=	Frame_Cont+1;
				tft_outenable <= 1'b0;
				end
			else
				tft_outenable <= 1'b1;
	end
end

endmodule



