module I2C_CCD_Config (	//	Host Side
	iCLK,
	iRST_N,
	//iExposure,
	//	I2C Side
	I2C_SCLK,
	I2C_SDAT,
	cmos_finish	);
	//	Host Side
	input			iCLK;
	input			iRST_N;
	//input	[15:0]	iExposure;
	//	I2C Side
	output		I2C_SCLK;
	inout		I2C_SDAT;
	
	output cmos_finish;
	//	Internal Registers/Wires
	reg	[15:0]	mI2C_CLK_DIV;
	reg	[23:0]	mI2C_DATA;
	reg			mI2C_CTRL_CLK;
	reg			mI2C_GO;
	wire		mI2C_END;
	wire		mI2C_ACK;
	reg	[15:0]	LUT_DATA;
	reg	[15:0]	LUT_INDEX;
	reg	[3:0]	mSetup_ST;
	
	//	Clock Setting
	parameter	CLK_Freq	=	100000000;	//	100	MHz
	parameter	I2C_Freq	=	20000;		//	200	KHz
	//	LUT Data Number
	parameter	LUT_SIZE	=	163;
	
	/////////////////////	I2C Control Clock	////////////////////////
	always@(posedge iCLK or negedge iRST_N)
	begin
		if(!iRST_N)
		begin
			mI2C_CTRL_CLK	<=	0;
			mI2C_CLK_DIV	<=	0;
		end
		else
		begin
			if( mI2C_CLK_DIV	< (CLK_Freq/I2C_Freq) )
				mI2C_CLK_DIV	<=	mI2C_CLK_DIV+1;
			else
			begin
				mI2C_CLK_DIV	<=	0;
				mI2C_CTRL_CLK	<=	~mI2C_CTRL_CLK;
			end
		end
	end
	////////////////////////////////////////////////////////////////////
	I2C_Controller 	ua	(	.CLOCK(mI2C_CTRL_CLK),		//	Controller Work Clock
		.I2C_SCLK(I2C_SCLK),		//	I2C CLOCK
		.I2C_SDAT(I2C_SDAT),		//	I2C DATA
		.I2C_DATA(mI2C_DATA),		//	DATA:[SLAVE_ADDR,SUB_ADDR,DATA]
		.GO(mI2C_GO),      			//	GO transfor
		.END(mI2C_END),				//	END transfor 
		.ACK(mI2C_ACK),				//	ACK
		.RESET(iRST_N)	);
	////////////////////////////////////////////////////////////////////
	/*the slave device 8-bit address. The SADDR pin is used
	to select between two different addresses in case of 
	conflict with another device. If SADDR is LOW, the 
	slave address is 0x90; if SADDR is HIGH, the slave 
		address is 0xBA.*/
	   //////////////////////	Config Control	////////////////////////////
	   reg cmos_finish;
	   always@(posedge mI2C_CTRL_CLK or negedge iRST_N)
	   begin
		   if(!iRST_N)
		   begin
			   LUT_INDEX	<=	0;
			   mSetup_ST	<=	0;
			   mI2C_GO		<=	0;
			   cmos_finish <= 1'b0;
		   end
		   else
		   begin
			   if(LUT_INDEX<LUT_SIZE)
			   begin
				   case(mSetup_ST)
					   0:	begin
						   mI2C_DATA	<=	{8'h42,LUT_DATA};
						   mI2C_GO		<=	1;
						   mSetup_ST	<=	1;
					   end
					   1:	begin
						   if(mI2C_END)
						   begin
							   if(!mI2C_ACK)
								   mSetup_ST	<=	2;
							   else
								   mSetup_ST	<=	0;							
							   mI2C_GO		<=	0;
						   end
					   end
					   2:	begin
						   LUT_INDEX	<=	LUT_INDEX+1;
						   mSetup_ST	<=	0;
					   end
				   endcase
			   end
			   else
				   cmos_finish <= 1'b1;
		   end
	   end
	   ////////////////////////////////////////////////////////////////////
	   /////////////////////	Config Data LUT	  //////////////////////////	
	   always
	   begin
		   case(LUT_INDEX)
			   0: LUT_DATA <= 16'h3a04;
			   1: LUT_DATA <= 16'h40d0;
			   2: LUT_DATA <= 16'h1214;
			   3: LUT_DATA <= 16'h3280;
			   4: LUT_DATA <= 16'h1716;
			   5: LUT_DATA <= 16'h1804;
			   6: LUT_DATA <= 16'h1902;
			   7: LUT_DATA <= 16'h1a7b;
			   8: LUT_DATA <= 16'h0306;
			   9: LUT_DATA <= 16'h0c04;
			   10: LUT_DATA <= 16'h3e00;
			   11: LUT_DATA <= 16'h703a;
			   12: LUT_DATA <= 16'h7135;
			   13: LUT_DATA <= 16'h7211;
			   14: LUT_DATA <= 16'h7300;
			   15: LUT_DATA <= 16'ha202;
			   16: LUT_DATA <= 16'h1181;
			   17: LUT_DATA <= 16'h7a20;
			   18: LUT_DATA <= 16'h7b1c;
			   19: LUT_DATA <= 16'h7c28;
			   20: LUT_DATA <= 16'h7d3c;
			   21: LUT_DATA <= 16'h7e55;
			   22: LUT_DATA <= 16'h7f68;
			   23: LUT_DATA <= 16'h8076;
			   24: LUT_DATA <= 16'h8180;
			   25: LUT_DATA <= 16'h8288;
			   26: LUT_DATA <= 16'h838f;
			   27: LUT_DATA <= 16'h8496;
			   28: LUT_DATA <= 16'h85a3;
			   29: LUT_DATA <= 16'h86af;
			   30: LUT_DATA <= 16'h87c4;
			   31: LUT_DATA <= 16'h88d7;
			   32: LUT_DATA <= 16'h89e8;
			   33: LUT_DATA <= 16'h13e0;
			   34: LUT_DATA <= 16'h0000;
			   35: LUT_DATA <= 16'h1000;
			   36: LUT_DATA <= 16'h0d00;
			   37: LUT_DATA <= 16'h1428;
			   38: LUT_DATA <= 16'ha505;
			   39: LUT_DATA <= 16'hab07;
			   40: LUT_DATA <= 16'h2475;
			   41: LUT_DATA <= 16'h2563;
			   42: LUT_DATA <= 16'h26a5;
			   43: LUT_DATA <= 16'h9f78;
			   44: LUT_DATA <= 16'ha068;
			   45: LUT_DATA <= 16'ha103;
			   46: LUT_DATA <= 16'ha6df;
			   47: LUT_DATA <= 16'ha7df;
			   48: LUT_DATA <= 16'ha8f0;
			   49: LUT_DATA <= 16'ha990;
			   50: LUT_DATA <= 16'haa94;
			   51: LUT_DATA <= 16'h13e5;
			   52: LUT_DATA <= 16'h0e61;
			   53: LUT_DATA <= 16'h0f4b;
			   54: LUT_DATA <= 16'h1602;
			   55: LUT_DATA <= 16'h1e07;
			   56: LUT_DATA <= 16'h2102;
			   57: LUT_DATA <= 16'h2291;
			   58: LUT_DATA <= 16'h2907;
			   59: LUT_DATA <= 16'h330b;
			   60: LUT_DATA <= 16'h350b;
			   61: LUT_DATA <= 16'h371d;
			   62: LUT_DATA <= 16'h3871;
			   63: LUT_DATA <= 16'h392a;
			   64: LUT_DATA <= 16'h3c78;
			   65: LUT_DATA <= 16'h4d40;
			   66: LUT_DATA <= 16'h4e20;
			   67: LUT_DATA <= 16'h6900;
			   68: LUT_DATA <= 16'h6b60;
			   69: LUT_DATA <= 16'h7419;
			   70: LUT_DATA <= 16'h8d4f;
			   71: LUT_DATA <= 16'h8e00;
			   72: LUT_DATA <= 16'h8f00;
			   73: LUT_DATA <= 16'h9000;
			   74: LUT_DATA <= 16'h9100;
			   75: LUT_DATA <= 16'h9200;
			   76: LUT_DATA <= 16'h9600;
			   77: LUT_DATA <= 16'h9a80;
			   78: LUT_DATA <= 16'hb084;
			   79: LUT_DATA <= 16'hb10c;
			   80: LUT_DATA <= 16'hb20e;
			   81: LUT_DATA <= 16'hb382;
			   82: LUT_DATA <= 16'hb80a;
			   83: LUT_DATA <= 16'h4314;
			   84: LUT_DATA <= 16'h44f0;
			   85: LUT_DATA <= 16'h4534;
			   86: LUT_DATA <= 16'h4658;
			   87: LUT_DATA <= 16'h4728;
			   88: LUT_DATA <= 16'h483a;
			   89: LUT_DATA <= 16'h5988;
			   90: LUT_DATA <= 16'h5a88;
			   91: LUT_DATA <= 16'h5b44;
			   92: LUT_DATA <= 16'h5c67;
			   93: LUT_DATA <= 16'h5d49;
			   94: LUT_DATA <= 16'h5e0e;
			   95: LUT_DATA <= 16'h6404;
			   96: LUT_DATA <= 16'h6520;
			   97: LUT_DATA <= 16'h6605;
			   98: LUT_DATA <= 16'h9404;
			   99: LUT_DATA <= 16'h9508;
			   100: LUT_DATA <= 16'h6c0a;
			   101: LUT_DATA <= 16'h6d55;
			   102: LUT_DATA <= 16'h6e11;
			   103: LUT_DATA <= 16'h6f9f;
			   104: LUT_DATA <= 16'h6a40;
			   105: LUT_DATA <= 16'h0140;
			   106: LUT_DATA <= 16'h0240;
			   107: LUT_DATA <= 16'h13e7;
			   108: LUT_DATA <= 16'h1500;
			   109: LUT_DATA <= 16'h4f80;
			   110: LUT_DATA <= 16'h5080;
			   111: LUT_DATA <= 16'h5100;
			   112: LUT_DATA <= 16'h5222;
			   113: LUT_DATA <= 16'h535e;
			   114: LUT_DATA <= 16'h5480;
			   115: LUT_DATA <= 16'h589e;
			   116: LUT_DATA <= 16'h4108;
			   117: LUT_DATA <= 16'h3f00;
			   118: LUT_DATA <= 16'h7505;
			   119: LUT_DATA <= 16'h76e1;
			   120: LUT_DATA <= 16'h4c00;
			   121: LUT_DATA <= 16'h7701;
			   122: LUT_DATA <= 16'h3dc2;
			   123: LUT_DATA <= 16'h4b09;
			   124: LUT_DATA <= 16'hc960;
			   125: LUT_DATA <= 16'h4138;
			   126: LUT_DATA <= 16'h5640;
			   127: LUT_DATA <= 16'h3411;
			   128: LUT_DATA <= 16'h3b02;
			   129: LUT_DATA <= 16'ha489;
			   130: LUT_DATA <= 16'h9600;
			   131: LUT_DATA <= 16'h9730;
			   132: LUT_DATA <= 16'h9820;
			   133: LUT_DATA <= 16'h9930;
			   134: LUT_DATA <= 16'h9a84;
			   135: LUT_DATA <= 16'h9b29;
			   136: LUT_DATA <= 16'h9c03;
			   137: LUT_DATA <= 16'h9d4c;
			   138: LUT_DATA <= 16'h9e3f;
			   139: LUT_DATA <= 16'h7804;
			   140: LUT_DATA <= 16'h7901;
			   141: LUT_DATA <= 16'hc8f0;
			   142: LUT_DATA <= 16'h790f;
			   143: LUT_DATA <= 16'hc800;
			   144: LUT_DATA <= 16'h7910;
			   145: LUT_DATA <= 16'hc87e;
			   146: LUT_DATA <= 16'h790a;
			   147: LUT_DATA <= 16'hc880;
			   148: LUT_DATA <= 16'h790b;
			   149: LUT_DATA <= 16'hc801;
			   150: LUT_DATA <= 16'h790c;
			   151: LUT_DATA <= 16'hc80f;
			   152: LUT_DATA <= 16'h790d;
			   153: LUT_DATA <= 16'hc820;
			   154: LUT_DATA <= 16'h7909;
			   155: LUT_DATA <= 16'hc880;
			   156: LUT_DATA <= 16'h7902;
			   157: LUT_DATA <= 16'hc8c0;
			   158: LUT_DATA <= 16'h7903;
			   159: LUT_DATA <= 16'hc840;
			   160: LUT_DATA <= 16'h7905;
			   161: LUT_DATA <= 16'hc830;
			   162: LUT_DATA <= 16'h7926;
			   163: LUT_DATA <= 16'h0900;
			   default:LUT_DATA	<=	16'h0000;
		   endcase
	   end
	   ////////////////////////////////////////////////////////////////////
	   endmodule
