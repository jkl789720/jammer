`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/03/25 11:46:41
// Design Name: 
// Module Name: tt_dac_pre
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


module tt_dac_pre;
reg		clk150m,rst,fifo_wr_clr,fifo_wr_enable;
always begin
	clk150m = 0;
	#3.3333;
	clk150m = 1;
	#3.3333;
end
initial begin
force UUT.TRI_LV  = 100;
force UUT.DLY_PRT  = 2;
force UUT.PULSE_NUM  = 2;
force UUT.FRAME_LEN  = 10;
force UUT.PRF_INTERVAL  = 20;
force UUT.PRF_LEN  = 10;
force UUT.dac_start  = 0;





rst =1;
fifo_wr_enable = 0;
#100;
rst =0;
force UUT.dac_start  = 1;
#1000;
fifo_wr_enable = 1;

end

reg [15:0]      tesetnum;
always@(posedge clk150m)begin
    if(!fifo_wr_enable)begin
	    tesetnum <= 0;

    end
    else begin
         tesetnum <= tesetnum + 1;
    end
end

dac_data_pre UUT(
.adc_clk(clk150m),
.adc_rst(rst),

.dac_clk(clk150m),
.dac_rst(rst),

.m00_axis_tdata({8{tesetnum}}),
.m01_axis_tdata({8{tesetnum}})

);



endmodule
