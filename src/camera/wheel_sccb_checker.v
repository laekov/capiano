
module wheel_sccb_checker(
	input clk,
	input rst,
	output wire scl,
	inout sda,
	output wire [23:0] debug_out,
	output wire work_done
);
	wire _fin;
	assign debug_out = { 15'b0, _fin, 8'b0};
	assign work_done = _fin;

	I2C_CCD_Config i2cc(
		.iCLK(clk),
		.iRST_N(rst),
		.I2C_SCLK(scl),
		.I2C_SDAT(sda),
		.cmos_finish(_fin)
	);
endmodule

