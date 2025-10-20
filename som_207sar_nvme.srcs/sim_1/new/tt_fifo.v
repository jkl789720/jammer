`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/12/11 20:06:03
// Design Name: 
// Module Name: tt_fifo
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tt_fifo;
reg		clk150m,clkref,rst;
always begin
	clk150m = 0;
	#3.3333;
	clk150m = 1;
	#6.6666;
end
always begin
	clkref = 0;
	#80;
	clkref = 1;
	#80;
end

initial begin
rst=1;
#100;
rst=0;
end
ddr_top_post_fifo_0 ddr_top_post_fifo_0_EP0
(
.rst(rst),
.wr_clk(clk150m),
.rd_clk(clk150m),
.din(0),
.wr_en(0),
.rd_en(0),
.dout(),
.full(),
.empty(),
.rd_data_count(),
.wr_data_count(),
.wr_rst_busy(),
.rd_rst_busy()
  );

endmodule
