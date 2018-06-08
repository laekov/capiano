//`define SendToPC 319
//`define SendToPCSize 320
`define SendToPC 39
`define SendToPCSize 40
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
	input ov_vs,
	input ov_hs,
	input ov_pclk,
	output wire ov_mclk,
	output wire ov_rst,
	input ov_pwdn,

	input ps2c,
	input ps2d
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

wire clk24;
wire clk12;
wire clk6;
wire clk3;
pll __pll(
	.inclk0(clk),
	.c0(clk24)
);
quarter_clk __divider1(
	.raw_clk(clk24),
	.out_clk(clk12)
);
quarter_clk __divider2(
	.raw_clk(clk12),
	.out_clk(clk6)
);

quarter_clk __divider3(
	.raw_clk(clk6),
	.out_clk(clk3)
);
wire [31:0] vga_addr;
wire [8:0] vga_data;
wire [8:0] cam_vga_data;
vga_ctrl __vga_ctrl(
	.clk(clk24),
	.rst(!rst),
	.hs(vga_hs),
	.vs(vga_vs),
	.r(vga_r),
	.g(vga_g),
	.b(vga_b),
	.addr(vga_addr),
	.q(vga_data)
);

wire [31:0] cam_out;
wire cam0_en;
assign ov_mclk = clk12;
wire [1:0] cam_delta;
wire cam_refr;
wire [39:0] key_down;
wire cis_finger;

wire [31:0] r_max;
wire [31:0] g_min;
wire [31:0] b_max;
wire [31:0] c_min;

camera_ctrl __cam0(
	.clk(clk24),
	.rst(rst),
	.cam_data(cam_data),
	.ov_vs(ov_vs),
	.ov_hs(ov_hs),
	.ov_pclk(ov_pclk),
	.ov_rst(ov_rst),
	.ov_pwdn(ov_pwdn),
	.addr(vga_addr),
	.key_down(key_down),
	.q(cam_vga_data),
	.is_finger(cis_finger),
	.r_max(r_max),
	.g_min(g_min),
	.b_max(b_max),
	.c_min(c_min),
	.debug_out(cam_out)
);

threshold __thres_ctrl(
	.clk(clk),
	.rst(rst),
	.ps2c(ps2c),
	.ps2d(ps2d),
	.rmax(r_max),
	.gmin(g_min),
	.bmax(b_max),
	.cmin(c_min)
);

ui __ui(
	.addr(vga_addr),
	.canvas_color(cam_vga_data),
	.is_finger(cis_finger),
	.key_down(key_down),
	.q(vga_data)
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
wire u_clk;
wire [7:0] uart_read_data;
wire [7:0] uart_send_data;
wire [3:0] uart_test_sta;
wire [3:0] uart_send_sta;
wire [3:0] uart_test_nxtsta;
wire [7:0] uart_ctrl_sta;
wire [7:0] uart_ctrl_nxtsta;
wire [7:0] uart_data;
wire [39:0] uart_ctrl_data;
uart_clk __uart_clk(
	.clk(clk),
	.rst(rst),
	._uart_clk(u_clk)
);
wire flag;
uart_test __uart_test(
	.clk(u_clk),
	.rst(rst),
	.send_done(uart_ctrl_send_done),
	.send(uart_ctrl_send),
	.InpData(key_down),
	.data(uart_ctrl_data),
	.sta(uart_test_sta),
	.nxtsta(uart_test_nxtsta)
);
uart_ctrl __uart_ctrl(
	.clk(u_clk),
	.rst(rst),
	.uart_read_done(uart_read_done),
	.uart_send_done(uart_send_done),
	.uart_send(uart_send),
	.read_data(uart_read_data),
	.send_data(uart_send_data),
	.send_done(uart_ctrl_send_done),
	.send(uart_ctrl_send),
	.data(uart_ctrl_data),
	.sta(uart_ctrl_sta),
	.uart_send_sta(uart_send_sta),
	.nxtsta(uart_ctrl_nxtsta),
	.flag(flag)
);
uart __uart(
	.fclk(clk),
	.clk(u_clk),
	.rst(rst),
	.send(uart_send),
	.rx(rx),
	.send_data(uart_send_data),
	.read_data(uart_read_data),
	.tx(tx),
	.read_done(uart_read_done),
	.send_done(uart_send_done),
	.send_sta(uart_send_sta),
	.uart_data(uart_data)
);

// debug output from right to left 0 to 7
wire [31:0] _out;
assign _out = {r_max[15:8], g_min[15:8], b_max[15:8], c_min[7:0]};
// assign _out = {15'b0, cam0_en, cam_out[15:0]};
assign debug_out0 = uart_test_sta;
assign debug_out1 = uart_ctrl_sta;
assign debug_out2 = uart_send_sta;
assign debug_out3 = uart_send_done;
assign debug_out4 = {3'b0,uart_ctrl_send};
assign debug_out5 = {3'b0,uart_ctrl_send_done};
assign debug_out6 = uart_ctrl_data[15:8];
assign debug_out7 = uart_ctrl_data[7:0];
endmodule
