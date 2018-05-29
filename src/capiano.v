module capiano(
	input man_clk,
	input clk,
	input rst,
	output wire vga_hs,
	output wire vga_vs,
	output wire [2:0] vga_r,
	output wire [2:0] vga_g,
	output wire [2:0] vga_b,
	output wire [55:0] led,

	output wire Mem_CS,
	output wire Mem_WE,
	output wire Mem_OE,
	output wire [19:0] Mem_addr,
	inout [31:0] Mem_data,
	
	input rx,
	output wire tx,
	
	input [7:0] cam_data,
	output wire scl,
	inout sda,
	output wire rclk,
	output wire fifo_wen,
	output wire fifo_wrst,
	output wire fifo_rrst,
	output fifo_oe,
	input ov_vsync
);
	wire [3:0] debug_out0;
	wire [3:0] debug_out1;
	wire [3:0] debug_out2;
	wire [3:0] debug_out3;
	wire [3:0] debug_out4;
	wire [3:0] debug_out5;
	wire [3:0] debug_out6;
	wire [3:0] debug_out7;
	wire [3:0] debug_out8;

	dig_ctrl __dig_0( .dig(debug_out0), .light(led[6:0]) );
	dig_ctrl __dig_1( .dig(debug_out1), .light(led[13:7]) );
	dig_ctrl __dig_2( .dig(debug_out2), .light(led[20:14]) );
	dig_ctrl __dig_3( .dig(debug_out3), .light(led[27:21]) );
	dig_ctrl __dig_4( .dig(debug_out4), .light(led[34:28]) );
	dig_ctrl __dig_5( .dig(debug_out5), .light(led[41:35]) );
	dig_ctrl __dig_6( .dig(debug_out6), .light(led[48:42]) );
	dig_ctrl __dig_7( .dig(debug_out7), .light(led[55:49]) );

	wire qu_clk;
	quarter_clk __quarter_clk(
		.raw_clk(clk),
		.out_clk(qu_clk)
	);

	wire [31:0] vga_addr;
	wire [8:0] vga_data;
	vga_ctrl __vga_ctrl(
		.clk(qu_clk),
		.rst(!rst),
		.hs(vga_hs),
		.vs(vga_vs),
		.r(vga_r),
		.g(vga_g),
		.b(vga_b),
		.addr(vga_addr),
		.q(vga_data)
	);

	camera_ctrl __cam0(
		.clk(qu_clk),
		.cam_data(cam_data),
		.rclk(rclk),
		.fifo_wen(fifo_wen),
		.fifo_rrst(fifo_rrst),
		.fifo_oe(fifo_oe),
		.ov_vsync(ov_vsync),
		.addr(vga_addr),
		.q(vga_data)
	);

	wire [23:0] sccb_out;
	wire sccb_done;
	wheel_sccb_checker __sccb0(
		.clk(qu_clk),
		.rst(rst),
		.scl(scl),
		.sda(sda),
		.debug_out(sccb_out),
		.work_done(sccb_done)
	);
	
	wire toread;
	wire towrite;
	wire [3:0]res;
	wire [19:0] mem_addr;
	wire [31:0] in_data;
	wire [31:0] back_data;
	wire [3:0] tststa;
	wire workdone;
	
	ram_test __ramtest(
		.clk(qu_clk),
		.rst(rst),
		.toread(toread),
		.towrite(towrite),
		.res(res),
		.addr(mem_addr),
		.to_data(in_data),
		.get_data(back_data),
		.workdone(workdone),
		.tststa(tststa)
	);
	
	wire [3:0] ram_sta;
	wire [3:0] ram_cnt;
	ram_ctrl __ramctrl(
		.clk(qu_clk),
		.rst(rst),
		.read(toread),
		.write(towrite),
		.inp_addr(mem_addr),
		.inp_data(in_data),
		.addr(Mem_addr),
		.data(Mem_data),
		.CS(Mem_CS),
		.OE(Mem_OE),
		.WE(Mem_WE),
		.workdone(workdone),
		.out_data(back_data),
		.nowsta(ram_sta),
		.nowcnt(ram_cnt)
	);
	
	wire uart_send_done;
	wire uart_read_done;
	wire uart_ctrl_send_done;
	wire uart_ctrl_send;
	wire uart_send;
	wire uart_clk;
	wire [7:0] uart_read_data;
	wire [7:0] uart_send_data;
	wire [319:0] ToPC;
	wire [3:0] uart_test_sta;
	wire [3:0] uart_send_sta;
	wire [7:0] uart_ctrl_sta;
	uart_test __uart_test(
	.clk(clk),
	.rst(rst),
	.send_done(uart_ctrl_send_done),
	.send(uart_ctrl_send),
	.data(ToPC),
	.sta(uart_test_sta)
	);
	uart_ctrl __uart_ctrl(
		.clk(clk),
		.rst(rst),
	.uart_read_done(uart_read_done),
	.uart_send_done(uart_send_done),
	.uart_send(uart_send),
	.read_data(uart_read_data),
	.send_data(uart_send_data),
	.send_done(uart_ctrl_send_done),
	.send(uart_ctrl_send),
	.data(ToPC),
	.sta(uart_ctrl_sta),
	);
	uart __uart(
		.clk(clk),
		.rst(rst),
	.send(uart_send),
	.rx(rx),
	.send_data(uart_send_data),
	.read_data(uart_read_data),
	.tx(tx),
	.read_done(uart_read_done),
	.send_done(uart_send_done),
	.send_sta(uart_send_sta),
	.subclk(uart_clk)
	);
	
	// debug output from right to left 0 to 7
	assign debug_out0 = uart_test_sta;
	assign debug_out1 = uart_ctrl_sta[3:0];
	assign debug_out2 = uart_send_sta;
	assign debug_out3 = {3'b0,uart_ctrl_send_done};
	assign debug_out4 = {3'b0,uart_send_done};
	assign debug_out5 = {3'b0,uart_send};
	assign debug_out6 = uart_ctrl_sta[7:4];
	assign debug_out7 = uart_read_data[7:4];
endmodule
