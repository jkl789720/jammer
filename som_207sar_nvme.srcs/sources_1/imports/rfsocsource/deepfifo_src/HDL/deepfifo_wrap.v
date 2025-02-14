`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/05/25 12:18:06
// Design Name: 
// Module Name: deepfifo_wrap
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


module deepfifo_wrap
#(
  parameter BASE_ADDR = 0,   								    //DDRAXI4的起始地址
  parameter ADDR_WIDTH = 33,								    //DDRAXI4的地址宽度
  parameter LOG2_RAM_SIZE_ADDR =33,						    //DDR的AXI4使用总容量log2
  parameter LOG2_BURST_WORDS = 8,                             //DDR的AXI4一个BURST含word数量log2    尽量不要改动 
  parameter LOG2_WORD_WIDTH = 9,                              //DDR的AXI4数据位宽度log2             尽量不要改动  

  parameter DIN_WIDTH = 512,                                  //axi_s数据输入datain的数据宽度       尽量不要改动 
  parameter DOUT_WIDTH = 512                                  //axi_s数据输入dataout的数据宽度      尽量不要改动
)
(input deepfifo_lite_S_clk,                                     //axi_lite控制接口的时钟
input deepfifo_lite_S_aresetn,                                  //axi_lite控制接口的复位 低有效

input m_axis_deepfifo_rx_clk,                                   //axi_s数据输入dataout的时钟
input s_axis_deepfifo_rx_clk,                                   //axi_s数据输入datain的时钟,
//input rx_rst,
//input tx_rst,
////axi_s数据输入datain
input   [DIN_WIDTH-1:0] s_axis_deepfifo_rx_tdata,
input   s_axis_deepfifo_rx_tvalid,
output  s_axis_deepfifo_rx_tready,
input   s_axis_deepfifo_rx_tlast,
//axi_s数据输入dataout
output  [DOUT_WIDTH-1:0] m_axis_deepfifo_rx_tdata,
output  m_axis_deepfifo_rx_tvalid,
input   m_axis_deepfifo_rx_tready,
output  m_axis_deepfifo_rx_tlast,

//ddr
//output  							ddr4_sys_rst,                  
//input                				ddr4_init_calib_complete,
input                				ddr4_s_axi_clk,            //DDR4 AXI4数据的时钟
input                				ddr4_ui_clk_sync_rst,      //DDR4 AXI4数据的复位 高有效

//DDR AXI4接口
// Slave Interface Write Address Ports
output                 				ddr4_aresetn,
output  [0:0]     					ddr4_s_axi_awid,
output  [ADDR_WIDTH-1:0]   			ddr4_s_axi_awaddr,
output  [7:0]                       ddr4_s_axi_awlen,
output  [2:0]                       ddr4_s_axi_awsize,
output  [1:0]                       ddr4_s_axi_awburst,
output  [0:0]                       ddr4_s_axi_awlock,
output  [3:0]                       ddr4_s_axi_awcache,
output  [2:0]                       ddr4_s_axi_awprot,
output  [3:0]                       ddr4_s_axi_awqos,
output                              ddr4_s_axi_awvalid,
input                             	ddr4_s_axi_awready,
// Slave Interface Write Data Ports
output  [511:0]  					ddr4_s_axi_wdata,
output  [63:0] 						ddr4_s_axi_wstrb,
output         	                   	ddr4_s_axi_wlast,
output                            	ddr4_s_axi_wvalid,
input                         	  	ddr4_s_axi_wready,
// Slave Interface Write Response Ports
output                             	ddr4_s_axi_bready,
input [0:0]    						ddr4_s_axi_bid,
input [1:0]               	     	ddr4_s_axi_bresp,
input                     	        ddr4_s_axi_bvalid,
// Slave Interface Read Address Ports
output  [0:0]     					ddr4_s_axi_arid,
output  [ADDR_WIDTH-1:0]  			ddr4_s_axi_araddr,
output  [7:0]                      	ddr4_s_axi_arlen,
output  [2:0]                     	ddr4_s_axi_arsize,
output  [1:0]                  	    ddr4_s_axi_arburst,
output  [0:0]                 	    ddr4_s_axi_arlock,
output  [3:0]              	        ddr4_s_axi_arcache,
output  [2:0]                  	    ddr4_s_axi_arprot,
output  [3:0]               	    ddr4_s_axi_arqos,
output                        	    ddr4_s_axi_arvalid,
input                     	        ddr4_s_axi_arready,
// Slave Interface Read Data Ports
output                             	ddr4_s_axi_rready,
input [0:0]      					ddr4_s_axi_rid,
input [511:0]    					ddr4_s_axi_rdata,
input [1:0]                   	    ddr4_s_axi_rresp,
input                         	    ddr4_s_axi_rlast,
input                        	    ddr4_s_axi_rvalid,

//axi_lite 控制接口
/// Write address, data and response
input 	[31:0]						deepfifo_lite_S_awaddr,
input 	[2:0]						deepfifo_lite_S_awprot,
output	 							deepfifo_lite_S_awready,
input 								deepfifo_lite_S_awvalid,
input 	[31:0]						deepfifo_lite_S_wdata,
output	  							deepfifo_lite_S_wready,
input 	[3:0]						deepfifo_lite_S_wstrb,
input 								deepfifo_lite_S_wvalid,	
input 								deepfifo_lite_S_bready,
output	[1:0]						deepfifo_lite_S_bresp,
output	 							deepfifo_lite_S_bvalid,
		
// Read address and data    		
input 	[31:0]						deepfifo_lite_S_araddr,
input 	[2:0]						deepfifo_lite_S_arprot,
output 								deepfifo_lite_S_arready,
input 								deepfifo_lite_S_arvalid,	
output 	[31:0]						deepfifo_lite_S_rdata,
input 								deepfifo_lite_S_rready,
output 	[1:0]						deepfifo_lite_S_rresp,
output 								deepfifo_lite_S_rvalid

//deepfifo
//`include "ddr4_define.h"
//`include "ddr3_4GB_sr.v"
//input clk_ddr3,
//input[11:0] device_temp_i
//output init_calib_complete
);

wire        init_calib_complete1,init_calib_complete2;
wire       [31:0] cfg_deepfifo_ctrl;
wire       [31:0] cfg_deepfifo_status;
wire       [31:0] cfg_deepfifo_max_depth;
wire       [31:0] cfg_deepfifo_nonbypass_data_L;
wire       [31:0] cfg_deepfifo_nonbypass_data_H;
wire       [31:0] cfg_deepfifo_total_data_L;
wire       [31:0] cfg_deepfifo_total_data_H;
wire       [31:0] cfg_deepfifo_status7;
wire       [31:0] cfg_deepfifo_status8;
wire  reset_ddr;
wire[31:0]  status_1,status_2;
wire[31:0]  max_depth_1,max_depth_2;
wire[63:0]  nonbypass_data_1,nonbypass_data_2;
wire[63:0]  total_data_1,total_data_2;




deepfifo_wrapper_lite 
#(
.HIGH_END(32'h8000_8000),
.LOW_END(32'h8000_7000)
)
deepfifo_wrapper_lite_EP0(

//.app_lite_S(deepfifo_lite_S),
// Write address, data and response
.app_awaddr(deepfifo_lite_S_awaddr),
.app_awprot(deepfifo_lite_S_awprot),
.app_awready(deepfifo_lite_S_awready),
.app_awvalid(deepfifo_lite_S_awvalid),
.app_wdata(deepfifo_lite_S_wdata),
.app_wready(deepfifo_lite_S_wready),
.app_wstrb(deepfifo_lite_S_wstrb),
.app_wvalid(deepfifo_lite_S_wvalid),	
.app_bready(deepfifo_lite_S_bready),
.app_bresp(deepfifo_lite_S_bresp),
.app_bvalid(deepfifo_lite_S_bvalid),

// Read address and data
.app_araddr(deepfifo_lite_S_araddr),
.app_arprot(deepfifo_lite_S_arprot),
.app_arready(deepfifo_lite_S_arready),
.app_arvalid(deepfifo_lite_S_arvalid),	
.app_rdata(deepfifo_lite_S_rdata),
.app_rready(deepfifo_lite_S_rready),
.app_rresp(deepfifo_lite_S_rresp),
.app_rvalid(deepfifo_lite_S_rvalid), 

.axi_aresetn(deepfifo_lite_S_aresetn),    //input 
.axi_aclk(deepfifo_lite_S_clk),    //input 

//deepfifo 瀵勫瓨鍣ㄨ繛鎺?
.cfg_deepfifo_ctrl(cfg_deepfifo_ctrl),
.cfg_deepfifo_status(cfg_deepfifo_status),
.cfg_deepfifo_max_depth(cfg_deepfifo_max_depth),
.cfg_deepfifo_nonbypass_data_L(cfg_deepfifo_nonbypass_data_L),
.cfg_deepfifo_nonbypass_data_H(cfg_deepfifo_nonbypass_data_H),
.cfg_deepfifo_total_data_L(cfg_deepfifo_total_data_L),
.cfg_deepfifo_total_data_H(cfg_deepfifo_total_data_H),
.cfg_deepfifo_status7(cfg_deepfifo_status7),
.cfg_deepfifo_status8(cfg_deepfifo_status8)

);


assign reset_ddr = cfg_deepfifo_ctrl[0];
assign  cfg_deepfifo_status = status_1;
assign  cfg_deepfifo_max_depth =  max_depth_1 ;
assign  cfg_deepfifo_nonbypass_data_L =  nonbypass_data_1[31:0] ;
assign  cfg_deepfifo_nonbypass_data_H = nonbypass_data_1[63:32] ;
assign  cfg_deepfifo_total_data_L =  total_data_1[31:0] ;
assign  cfg_deepfifo_total_data_H = total_data_1[63:32] ;
assign  init_calib_complete = init_calib_complete1;


deepfifo_top#
( .BASE_ADDR(BASE_ADDR), 
  .PREFIFO_DIN_WIDTH(DIN_WIDTH),
  .POSTFIFO_DOUT_WIDTH(DOUT_WIDTH),
  .ADDR_WIDTH(ADDR_WIDTH),
  .LOG2_RAM_SIZE_ADDR(LOG2_RAM_SIZE_ADDR),
  .LOG2_WORD_WIDTH(LOG2_WORD_WIDTH),
  .LOG2_BURST_WORDS(LOG2_BURST_WORDS)
) ddr_deepfifo_EP0
(
//ddr4
.ddr4_sys_rst				(ddr4_sys_rst),


.ddr4_init_calib_complete	(ddr4_init_calib_complete),
.ddr4_ui_clk					(ddr4_s_axi_clk),
.ddr4_ui_clk_sync_rst		(ddr4_ui_clk_sync_rst),


// Slave Interface Write Address Ports
.ddr4_aresetn				(ddr4_aresetn),
.ddr4_s_axi_awid				(ddr4_s_axi_awid),
.ddr4_s_axi_awaddr			(ddr4_s_axi_awaddr),
.ddr4_s_axi_awlen			(ddr4_s_axi_awlen),
.ddr4_s_axi_awsize			(ddr4_s_axi_awsize),
.ddr4_s_axi_awburst			(ddr4_s_axi_awburst),
.ddr4_s_axi_awlock			(ddr4_s_axi_awlock),
.ddr4_s_axi_awcache			(ddr4_s_axi_awcache),
.ddr4_s_axi_awprot			(ddr4_s_axi_awprot),
.ddr4_s_axi_awqos			(ddr4_s_axi_awqos),
.ddr4_s_axi_awvalid			(ddr4_s_axi_awvalid),
.ddr4_s_axi_awready			(ddr4_s_axi_awready),
// Slave Interface Write Data Ports
.ddr4_s_axi_wdata			(ddr4_s_axi_wdata),
.ddr4_s_axi_wstrb			(ddr4_s_axi_wstrb),
.ddr4_s_axi_wlast			(ddr4_s_axi_wlast),
.ddr4_s_axi_wvalid			(ddr4_s_axi_wvalid),
.ddr4_s_axi_wready			(ddr4_s_axi_wready),
// Slave Interface Write Response Ports
.ddr4_s_axi_bready			(ddr4_s_axi_bready),
.ddr4_s_axi_bid				(ddr4_s_axi_bid),
.ddr4_s_axi_bresp			(ddr4_s_axi_bresp),
.ddr4_s_axi_bvalid			(ddr4_s_axi_bvalid),
// Slave Interface Read Address Ports
.ddr4_s_axi_arid				(ddr4_s_axi_arid),
.ddr4_s_axi_araddr			(ddr4_s_axi_araddr),
.ddr4_s_axi_arlen			(ddr4_s_axi_arlen),
.ddr4_s_axi_arsize			(ddr4_s_axi_arsize),
.ddr4_s_axi_arburst			(ddr4_s_axi_arburst),
.ddr4_s_axi_arlock			(ddr4_s_axi_arlock),
.ddr4_s_axi_arcache			(ddr4_s_axi_arcache),
.ddr4_s_axi_arprot			(ddr4_s_axi_arprot),
.ddr4_s_axi_arqos			(ddr4_s_axi_arqos),
.ddr4_s_axi_arvalid			(ddr4_s_axi_arvalid),
.ddr4_s_axi_arready			(ddr4_s_axi_arready),
// Slave Interface Read Data Ports
.ddr4_s_axi_rready			(ddr4_s_axi_rready),
.ddr4_s_axi_rid				(ddr4_s_axi_rid),
.ddr4_s_axi_rdata			(ddr4_s_axi_rdata),
.ddr4_s_axi_rresp			(ddr4_s_axi_rresp),
.ddr4_s_axi_rlast			(ddr4_s_axi_rlast),
.ddr4_s_axi_rvalid			(ddr4_s_axi_rvalid),





//`include "ddr4_inst.h"
.clk_ddr_sys(clk_ddr3),
.clk_postfifo(m_axis_deepfifo_rx_clk),
.clk_prefifo(s_axis_deepfifo_rx_clk),
.clk_status(deepfifo_lite_S_clk),
.m_axis_data_tdata(m_axis_deepfifo_rx_tdata),
.m_axis_data_tlast(m_axis_deepfifo_rx_tlast),
.m_axis_data_tready(m_axis_deepfifo_rx_tready),
.m_axis_data_tvalid(m_axis_deepfifo_rx_tvalid),
.max_depth(max_depth_1),
.nonbypass_data(nonbypass_data_1),
.reset(!deepfifo_lite_S_aresetn),

.reset_ddr(reset_ddr),
.s_axis_data_tdata(s_axis_deepfifo_rx_tdata),
.s_axis_data_tlast(s_axis_deepfifo_rx_tlast),
.s_axis_data_tready(s_axis_deepfifo_rx_tready),
.s_axis_data_tvalid(s_axis_deepfifo_rx_tvalid),
.status(status_1),
.init_calib_complete(init_calib_complete1),
.total_data(total_data_1)
) ;



endmodule