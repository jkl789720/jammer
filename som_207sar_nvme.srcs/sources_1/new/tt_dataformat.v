`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/02/07 09:57:10
// Design Name: 
// Module Name: tt_dataformat
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


module tt_dataformat;
reg		clk150m,rst,fifo_wr_clr,fifo_wr_enable;
always begin
	clk150m = 0;
	#3.3333;
	clk150m = 1;
	#6.6666;
end

initial begin
rst=1;
fifo_wr_enable=0;
fifo_wr_clr =0;
#100;
rst=0;
fifo_wr_enable=0;
fifo_wr_clr =0;
#100;
rst=0;
fifo_wr_enable=0;
fifo_wr_clr =1;
#110;
rst=0;
fifo_wr_enable=0;
fifo_wr_clr =0;
#300;
rst=0;
fifo_wr_enable=1;
fifo_wr_clr =0;

#80000;
rst=0;
fifo_wr_enable=0;
fifo_wr_clr =0;
end


data_format UTT(
.adc_clk(clk150m),
.adc_rst(rst),

.preprf(0),
.prfin(0),
.fifo_wr_clr(fifo_wr_clr),
.fifo_wr_valid(),
.fifo_wr_enable(fifo_wr_enable),
.cfg_AD_rnum(0),
.fifo_overflow(),

.adc0_data(256'h000F000E000D000C000B000A0009000800070006000500040003000200010000),
.adc1_data(256'h100F100E100D100C100B100A1009100810071006100510041003100210011000),
.div_width(0),
.div_pulse(0),
.ctrl_data(0),
.status_data(0),
.param_data(0),
.debug_data(0),

.adc_ready(1'b1),
.adc_valid(),
.adc_data
);

endmodule
