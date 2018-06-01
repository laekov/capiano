module uart_clk(
	input clk,
	input rst,
	output wire _uart_clk
);
reg [19:0] cnt;
`define N 5208
reg uart_clk;
reg clk1;
reg clk2;
reg out_clk;
assign _uart_clk=(~clk1) & clk2;
always @(posedge clk)begin
	clk1<=uart_clk;
end
always @(posedge clk)begin
	clk2<=clk1;
end
//clk1 <= clkin when rising_edge(fclk) ;
//	clk2 <= clk1 when rising_edge(fclk) ;
//	clk <= (not clk1) and clk2 ;
initial begin
	cnt<=0;
end
always @(posedge clk or negedge rst) begin  
    if (!rst) begin 
        cnt <= 0;  
    end  
    else if (cnt == `N-1) begin  
        cnt<= 0;
    end  
    else begin  
        cnt <= cnt + 1;  
    end  
end  
  
always @(posedge clk or negedge rst) begin  
    if (!rst) begin  
        uart_clk <= 0;  
    end  
    else if (cnt == `N-1) begin  
        uart_clk <= !uart_clk;  
    end
end  
endmodule