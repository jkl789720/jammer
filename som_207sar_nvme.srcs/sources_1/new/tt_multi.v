`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/01 19:05:44
// Design Name: 
// Module Name: tt_multi
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


module tt_multi;
reg clk150m;
reg s_axi_aresetn;
reg core_ext_start;


wire s_axi_aclk;
wire s_axi_aresetn;
wire core_ext_start;


wire  			bram_clk;
wire  			bram_rst;
wire  			bram_en;
wire  [23:0]	bram_addr;
wire  [3:0]		bram_we;
wire   [31:0]	bram_rddata;
wire  [31:0]	bram_wrdata;

always begin
	clk150m = 0;
	#3.3333;
	clk150m = 1;
	#6.6666;
end
initial begin
        s_axi_aresetn = 0;
        core_ext_start = 0;
    #1000;
         s_axi_aresetn = 1;
        core_ext_start = 0;
    #1000;
         s_axi_aresetn = 1;
        core_ext_start = 1; 
        force  UUT.data_pre_EP0.dac_data_pre_Ep0.addrparam = 32'h00;
    #100;
         s_axi_aresetn = 1;
        core_ext_start = 0; 
        force  UUT.data_pre_EP0.dac_data_pre_Ep0.addrparam = 32'h00;
    #5000;   
         force  UUT.data_pre_EP0.dac_data_pre_Ep0.addrparam = 32'h1;      
end

tt_axi_gen_wrapper tt_axi_gen_wrapper_Ep0
(   
.BRAM_PORTA_addr    (bram_addr),
.BRAM_PORTA_clk     (bram_clk),
.BRAM_PORTA_din     (bram_wrdata),
.BRAM_PORTA_dout    (bram_rddata),
.BRAM_PORTA_en      (bram_en),
.BRAM_PORTA_rst     (bram_rst),
.BRAM_PORTA_we      (bram_we),
.core_ext_start     (core_ext_start),
.irq_out            (),
.s_axi_aclk         (clk150m),
.s_axi_aresetn      (s_axi_aresetn)
);

multifunc UUT
(
.adc_clk(bram_clk),
.bram_clk(bram_clk),
.bram_rst(bram_rst),
.bram_en(bram_en),
.bram_addr(bram_addr),
.bram_we(bram_we),
.bram_rddata(bram_rddata),
.bram_wrdata(bram_wrdata)
);
endmodule
