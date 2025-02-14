`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/11/29 14:31:06
// Design Name: 
// Module Name: datachannel_wrap
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
`include "axi_interface.svh"

//`define DEV_VERSION_ID 32'h20230416
`define NO_DEEPFIFO
module datachannel_wrap
#(
parameter LOCAL_DWIDTH = 256,
parameter LOCAL_AWIDTH = 32,
parameter CFG_AWIDTH = 32,
parameter APP_HIGHEND = 32'h82000000,
parameter APP_LOWEND =32'h81000000
)
(
//system
input 						core_clk,
input						core_rst,
input 						adc_clk,
input						adc_rst,
input						dac_clk,
input						dac_rst,
input 						PPS_GPS_PL,
input	[1:0]				rec_fifo_overflow,
output 						preprf,
output 						prfin,
input						prffix,     
output						prfmux,
input						prfin_ex,    

input						host_loopsel,
input						host_ready,
//需要移除的寄存器	
output [31:0]           	cfg_dev_adc_ctrl,
output [31:0]           	cfg_dev_adc_iodelay,
input						init_calib_complete,
//mem axi4	
input						mem_clk,
input						mem_rst,
axi4.AXI_MASTER 			mem_axi_M,
axi4.AXI_MASTER 			HPC1_axi_M,
axi4.AXI_MASTER 			deepfifo_axi_M,

//Control_time
output 						mfifo_wr_clr_ctrl,	// active high, only one cycle
output 						mfifo_wr_valid_ctrl,
output 						mfifo_wr_enable_ctrl,
output 						mfifo_rd_clr_ctrl,	// active high, only one cycle
output 						mfifo_rd_valid_ctrl,
output 						mfifo_rd_enable_ctrl,

output 						fifo_rd_clr_ctrl,	// active high, only one cycle
output 						fifo_rd_valid_ctrl,
output 						fifo_rd_enable_ctrl,
output 						fifo_wr_clr_ctrl,	// active high, only one cycle
output 						fifo_wr_valid_ctrl,
output 						fifo_wr_enable_ctrl,
//local_channel
//AD
input 						mfifo_wr_clr,	// active high, only one cycle
input 						mfifo_wr_valid,
input 						mfifo_wr_enable,
input [LOCAL_DWIDTH-1:0] 	mfifo_wr_data,

//DA
input 						mfifo_rd_clr,	// active high, only one cycle
input 						mfifo_rd_valid,
input 						mfifo_rd_enable,
output [LOCAL_DWIDTH-1:0] 	mfifo_rd_data,


/* //AD
input [LOCAL_DWIDTH-1:0] 	mfifo_wr_data,
//DA
output 						mfifo_rd_enable,
output [LOCAL_DWIDTH-1:0]	mfifo_rd_data,
input						DAC_VOUT,

output 						fifo_wr_clr,
output 						fifo_wr_valid,
output 						fifo_wr_enable, */

//host_channel
//AD datain
input [255:0] 				m_axis_hostc_AD_tdata,
input  						m_axis_hostc_AD_tvalid,
output 						m_axis_hostc_AD_tready,
input  						m_axis_hostc_AD_tlast,
//DA dataout	
output [255:0] 				m_axis_hostc_DA_tdata,
output 	 					m_axis_hostc_DA_tvalid,
input  						m_axis_hostc_DA_tready,
output  					m_axis_hostc_DA_tlast,

output 						AUXRAM_en,
output [15:0] 				AUXRAM_we,
output [31:0] 				AUXRAM_addr,
output [127:0] 				AUXRAM_din,
input  [127:0] 				AUXRAM_dout,
	
//app axi_lite 	
input						axi_aresetn,    //input 
input						axi_aclk,    //input 
axi4.AXI_Lite_S 			app_lite_S
);
`include "version_date.vh" 	
// app wrap
wire [31:0] cfg_H2D_addr_dma;
wire [31:0] cfg_H2D_size_dma;
wire [31:0] cfg_H2D_burst_len;
wire [31:0] cfg_H2D_frame_len;
wire [31:0] cfg_H2D_trans_len;
wire [31:0] cfg_H2D_axi_ctrl;
wire [31:0] cfg_H2D_axi_status;
wire [31:0] cfg_D2H_addr_dma;
wire [31:0] cfg_D2H_addr_sym;
wire [31:0] cfg_D2H_size_dma;
wire [31:0] cfg_D2H_size_sym;
wire [31:0] cfg_D2H_burst_len;
wire [31:0] cfg_D2H_frame_len;
wire [31:0] cfg_D2H_trans_len;
wire [31:0] cfg_D2H_axi_ctrl;
wire [31:0] cfg_D2H_axi_status;
wire [31:0] aux_H2D_addr_dma;
wire [31:0] aux_H2D_size_dma;
wire [31:0] aux_H2D_burst_len;
wire [31:0] aux_H2D_frame_len;
wire [31:0] aux_H2D_axi_ctrl;
wire [31:0] aux_H2D_axi_status;
wire [31:0] aux_D2H_addr_dma;
wire [31:0] aux_D2H_size_dma;
wire [31:0] aux_D2H_burst_len;
wire [31:0] aux_D2H_frame_len;
wire [31:0] aux_D2H_axi_ctrl;
wire [31:0] aux_D2H_axi_status;
wire [31:0] cfg_AD_rnum;
wire [31:0] cfg_AD_anum;
wire [31:0] cfg_AD_delay;
wire [31:0] cfg_AD_mode;
wire [31:0] cfg_AD_base;
wire [31:0] cfg_AD_status;
wire [31:0] cfg_DA_rnum;
wire [31:0] cfg_DA_anum;
wire [31:0] cfg_DA_delay;
wire [31:0] cfg_DA_mode;
wire [31:0] cfg_DA_base;
wire [31:0] cfg_DA_status;
wire [31:0] cfg_prftime;
wire [31:0] cfg_pretime;
wire [31:0] cfg_prfmode;
wire [31:0] cfg_mode_ctrl;
//wire [31:0] cfg_dev_adc_ctrl;
wire [31:0] cfg_dev_adc_ro;
wire [31:0] cfg_dev_adc_filter;
//wire [31:0] cfg_dev_adc_iodelay;
wire [31:0] cfg_dev_dac_ctrl;
wire [31:0] cfg_dev_dac_ro;
wire [31:0] cfg_dev_dac_filter;
wire [31:0] cfg_dev_dac_iodelay;
wire [31:0] cfg_dev_ctrl;
wire [31:0] cfg_dev_status;
wire [31:0] cfg_dev_version;
wire [31:0] cfg_dev_spisel;
wire [31:0] cfg_mAD_rnum;
wire [31:0] cfg_mAD_anum;
wire [31:0] cfg_mAD_delay;
wire [31:0] cfg_mAD_mode;
wire [31:0] cfg_mAD_base;
wire [31:0] cfg_mAD_status;
wire [31:0] cfg_mDA_rnum;
wire [31:0] cfg_mDA_anum;
wire [31:0] cfg_mDA_delay;
wire [31:0] cfg_mDA_mode;
wire [31:0] cfg_mDA_base;
wire [31:0] cfg_mDA_status;
assign cfg_dev_version = FPGA_VERSION_DATA;
assign cfg_dev_status  = {FPGA_VERSION_PRIME[7:0],FPGA_VERSION_TIME[23:0]};

app_wrapper_lite 
#(
.HIGH_END(APP_HIGHEND),
.LOW_END(APP_LOWEND)
)
app_wrap1_EP0(
.app_awaddr(app_lite_S.axi_awaddr),    //input [31:0]
.app_awprot(app_lite_S.axi_awprot),    //input [2:0]
.app_awready(app_lite_S.axi_awready),    //output 
.app_awvalid(app_lite_S.axi_awvalid),    //input 
.app_wdata(app_lite_S.axi_wdata),    //input [31:0]
.app_wready(app_lite_S.axi_wready),    //output 
.app_wstrb(app_lite_S.axi_wstrb),    //input [3:0]
.app_wvalid(app_lite_S.axi_wvalid),    //input 
.app_bready(app_lite_S.axi_bready),    //input 
.app_bresp(app_lite_S.axi_bresp),    //output [1:0]
.app_bvalid(app_lite_S.axi_bvalid),    //output 
.app_araddr(app_lite_S.axi_araddr),    //input [31:0]
.app_arprot(app_lite_S.axi_arprot),    //input [2:0]
.app_arready(app_lite_S.axi_arready),    //output 
.app_arvalid(app_lite_S.axi_arvalid),    //input 
.app_rdata(app_lite_S.axi_rdata),    //output [31:0]
.app_rready(app_lite_S.axi_rready),    //input 
.app_rresp(app_lite_S.axi_rresp),    //output [1:0]
.app_rvalid(app_lite_S.axi_rvalid),    //output 
.axi_aresetn(axi_aresetn),    //input 
.axi_aclk(axi_aclk),    //input 

.cfg_H2D_addr_dma(cfg_H2D_addr_dma),    //output [31:0]
.cfg_H2D_size_dma(cfg_H2D_size_dma),    //output [31:0]
.cfg_H2D_burst_len(cfg_H2D_burst_len),    //output [31:0]
.cfg_H2D_frame_len(cfg_H2D_frame_len),    //output [31:0]
.cfg_H2D_trans_len(cfg_H2D_trans_len),    //output [31:0]
.cfg_H2D_axi_ctrl(cfg_H2D_axi_ctrl),    //output [31:0]
.cfg_H2D_axi_status(cfg_H2D_axi_status),    //input [31:0]
.cfg_D2H_addr_dma(cfg_D2H_addr_dma),    //output [31:0]
.cfg_D2H_addr_sym(cfg_D2H_addr_sym),    //output [31:0]
.cfg_D2H_size_dma(cfg_D2H_size_dma),    //output [31:0]
.cfg_D2H_size_sym(cfg_D2H_size_sym),    //output [31:0]
.cfg_D2H_burst_len(cfg_D2H_burst_len),    //output [31:0]
.cfg_D2H_frame_len(cfg_D2H_frame_len),    //output [31:0]
.cfg_D2H_trans_len(cfg_D2H_trans_len),    //output [31:0]
.cfg_D2H_axi_ctrl(cfg_D2H_axi_ctrl),    //output [31:0]
.cfg_D2H_axi_status(cfg_D2H_axi_status),    //input [31:0]
.aux_H2D_addr_dma(aux_H2D_addr_dma),    //output [31:0]
.aux_H2D_size_dma(aux_H2D_size_dma),    //output [31:0]
.aux_H2D_burst_len(aux_H2D_burst_len),    //output [31:0]
.aux_H2D_frame_len(aux_H2D_frame_len),    //output [31:0]
.aux_H2D_axi_ctrl(aux_H2D_axi_ctrl),    //output [31:0]
.aux_H2D_axi_status(aux_H2D_axi_status),    //input [31:0]
.aux_D2H_addr_dma(aux_D2H_addr_dma),    //output [31:0]
.aux_D2H_size_dma(aux_D2H_size_dma),    //output [31:0]
.aux_D2H_burst_len(aux_D2H_burst_len),    //output [31:0]
.aux_D2H_frame_len(aux_D2H_frame_len),    //output [31:0]
.aux_D2H_axi_ctrl(aux_D2H_axi_ctrl),    //output [31:0]
.aux_D2H_axi_status(aux_D2H_axi_status),    //input [31:0]

.cfg_AD_rnum(cfg_AD_rnum),    //output [31:0]
.cfg_AD_anum(cfg_AD_anum),    //output [31:0]
.cfg_AD_delay(cfg_AD_delay),    //output [31:0]
.cfg_AD_mode(cfg_AD_mode),    //output [31:0]
.cfg_AD_base(cfg_AD_base),    //output [31:0]
.cfg_AD_status(cfg_AD_status),    //input [31:0]
.cfg_DA_rnum(cfg_DA_rnum),    //output [31:0]
.cfg_DA_anum(cfg_DA_anum),    //output [31:0]
.cfg_DA_delay(cfg_DA_delay),    //output [31:0]
.cfg_DA_mode(cfg_DA_mode),    //output [31:0]
.cfg_DA_base(cfg_DA_base),    //output [31:0]
.cfg_DA_status(cfg_DA_status),    //input [31:0]
.cfg_prftime(cfg_prftime),    //output [31:0]
.cfg_pretime(cfg_pretime),    //output [31:0]
.cfg_prfmode(cfg_prfmode),    //output [31:0]
.cfg_mode_ctrl(cfg_mode_ctrl),    //output [31:0]
.cfg_dev_adc_ctrl(cfg_dev_adc_ctrl),    //output [31:0]
.cfg_dev_adc_ro(cfg_dev_adc_ro),    //input [31:0]
.cfg_dev_adc_filter(cfg_dev_adc_filter),    //output [31:0]
.cfg_dev_adc_iodelay(cfg_dev_adc_iodelay),    //output [31:0]
.cfg_dev_dac_ctrl(cfg_dev_dac_ctrl),    //output [31:0]
.cfg_dev_dac_ro(cfg_dev_dac_ro),    //input [31:0]
.cfg_dev_dac_filter(cfg_dev_dac_filter),    //output [31:0]
.cfg_dev_dac_iodelay(cfg_dev_dac_iodelay),    //output [31:0]
.cfg_dev_ctrl(cfg_dev_ctrl),    //output [31:0]
.cfg_dev_status(cfg_dev_status),    //input [31:0]
.cfg_dev_version(cfg_dev_version),    //input [31:0]

.cfg_dev_spisel(cfg_dev_spisel),    //output [31:0]
.cfg_mAD_rnum(cfg_mAD_rnum),    //output [31:0]
.cfg_mAD_anum(cfg_mAD_anum),    //output [31:0]
.cfg_mAD_delay(cfg_mAD_delay),    //output [31:0]
.cfg_mAD_mode(cfg_mAD_mode),    //output [31:0]
.cfg_mAD_base(cfg_mAD_base),    //output [31:0]
.cfg_mAD_status(cfg_mAD_status),    //input [31:0]
.cfg_mDA_rnum(cfg_mDA_rnum),    //output [31:0]
.cfg_mDA_anum(cfg_mDA_anum),    //output [31:0]
.cfg_mDA_delay(cfg_mDA_delay),    //output [31:0]
.cfg_mDA_mode(cfg_mDA_mode),    //output [31:0]
.cfg_mDA_base(cfg_mDA_base),    //output [31:0]
.cfg_mDA_status(cfg_mDA_status)    //input [31:0]
);


// control unit

wire [CFG_AWIDTH-1:0] tl_AD_base;
wire [CFG_AWIDTH-1:0] tl_AD_rnum;
wire  tl_AD_repeat;
wire  tl_AD_reset;
wire [CFG_AWIDTH-1:0] tl_DA_base;
wire [CFG_AWIDTH-1:0] tl_DA_rnum;
wire  tl_DA_repeat;
wire  tl_DA_reset;
wire [31:0] tl_DA_status;
wire [31:0] tl_AD_status;
wire adc_mask;
wire dac_mask;
//wire  mfifo_rd_clr;
//wire  mfifo_rd_valid;
//wire  mfifo_rd_enable;
//wire  mfifo_wr_clr;
//wire  mfifo_wr_valid;
//wire  mfifo_wr_enable;
wire  fifo_rd_clr;

wire  fifo_rd_valid;
wire  fifo_rd_enable;



//wire  prfmux;
//wire  prffix;
wire [31:0] prfcnt;
//wire  PRFIN_IOSIMU;
//assign prfin_ex = PRFIN_IOSIMU;
control_unit control_unit_EP0(
.pcie_clk(core_clk),    //input 
.pcie_rst(core_rst),    //input 
.cfg_AD_base(cfg_AD_base),    //input [31:0]
.cfg_AD_rnum(cfg_AD_rnum),    //input [31:0]
.cfg_AD_anum(cfg_AD_anum),    //input [31:0]
.cfg_AD_delay(cfg_AD_delay),    //input [31:0]
.cfg_AD_mode(cfg_AD_mode),    //input [31:0]
.cfg_AD_status(cfg_AD_status),    //output [31:0]
.cfg_DA_base(cfg_DA_base),    //input [31:0]
.cfg_DA_rnum(cfg_DA_rnum),    //input [31:0]
.cfg_DA_anum(cfg_DA_anum),    //input [31:0]
.cfg_DA_delay(cfg_DA_delay),    //input [31:0]
.cfg_DA_mode(cfg_DA_mode),    //input [31:0]
.cfg_DA_status(cfg_DA_status),    //output [31:0]

.cfg_mAD_rnum(cfg_mAD_rnum),    //input [31:0]
.cfg_mAD_anum(cfg_mAD_anum),    //input [31:0]
.cfg_mAD_delay(cfg_mAD_delay),    //input [31:0]
.cfg_mAD_mode(cfg_mAD_mode),    //input [31:0]
.cfg_mAD_base(cfg_mAD_base),    //input [31:0]
.cfg_mAD_status(cfg_mAD_status),    //output [31:0]
.cfg_mDA_rnum(cfg_mDA_rnum),    //input [31:0]
.cfg_mDA_anum(cfg_mDA_anum),    //input [31:0]
.cfg_mDA_delay(cfg_mDA_delay),    //input [31:0]
.cfg_mDA_mode(cfg_mDA_mode),    //input [31:0]
.cfg_mDA_base(cfg_mDA_base),    //input [31:0]
.cfg_mDA_status(cfg_mDA_status),    //output [31:0]
.cfg_prftime(cfg_prftime),    //input [31:0]
.cfg_pretime(cfg_pretime),    //input [31:0]
.cfg_prfmode(cfg_prfmode),    //input [31:0]
.prfin_ex(prfin_ex),    //input 
.cfg_mode_ctrl(cfg_mode_ctrl),    //input [31:0]
.PPS_GPS_PL(PPS_GPS_PL),

.mem_clk(mem_clk),    //input 
.mem_rst(mem_rst),    //input 
.tl_AD_base(tl_AD_base),    //output [31:0]
.tl_AD_rnum(tl_AD_rnum),    //output [31:0]
.tl_AD_repeat(tl_AD_repeat),    //output 
.tl_AD_reset(tl_AD_reset),    //output 
.tl_AD_status(tl_AD_status),    //input [31:0] 
.tl_DA_base(tl_DA_base),    //output [31:0]
.tl_DA_rnum(tl_DA_rnum),    //output [31:0]
.tl_DA_repeat(tl_DA_repeat),    //output 
.tl_DA_reset(tl_DA_reset),    //output 
.tl_DA_status(tl_DA_status),    //input [31:0] 
.adc_clk(adc_clk),    //input 
.adc_rst(adc_rst),    //input 
.dac_clk(dac_clk),    //input 
.dac_rst(dac_rst),    //input 
.adc_mask(adc_mask),    //input 
.dac_mask(dac_mask),    //input 
.preprf(preprf),    //output 
.prfin(prfin),    //output 
.prffix(prffix),    //input 
.prfmux(prfmux),    //output 
.prfcnt(prfcnt),    //output [31:0]
.mfifo_rd_clr(mfifo_rd_clr_ctrl),    //output 
.mfifo_rd_valid(mfifo_rd_valid_ctrl),    //output 
.mfifo_rd_enable(mfifo_rd_enable_ctrl),    //output 
.mfifo_wr_clr(mfifo_wr_clr_ctrl),    //output 
.mfifo_wr_valid(mfifo_wr_valid_ctrl),    //output 
.mfifo_wr_enable(mfifo_wr_enable_ctrl),    //output 
.fifo_rd_clr(fifo_rd_clr_ctrl),    //output 
.fifo_rd_valid(fifo_rd_valid_ctrl),    //output 
.fifo_rd_enable(fifo_rd_enable_ctrl),    //output 
.fifo_wr_clr(fifo_wr_clr_ctrl),    //output 
.fifo_wr_valid(fifo_wr_valid_ctrl),    //output 
.fifo_wr_enable(fifo_wr_enable_ctrl)    //output 
);

// local channel
reg ad_mem_rst, da_mem_rst;
always@(posedge mem_clk)ad_mem_rst <= mem_rst | (~cfg_mAD_mode[8]);
always@(posedge mem_clk)da_mem_rst <= mem_rst | (~cfg_mDA_mode[8]);

assign adc_mask = 0;
assign dac_mask = 0;

local_channel 
#(
.DIN_WIDTH(LOCAL_DWIDTH),
.AWIDTH(LOCAL_AWIDTH),
.CFG_AWIDTH(CFG_AWIDTH)
)
local_channel_EP0(
.mem_clk(mem_clk),    //input 
.ad_mem_rst(ad_mem_rst),    //input 
.da_mem_rst(da_mem_rst),    //input 
.mem_init_done(init_calib_complete),    //input 
.tl_AD_base(tl_AD_base),    //input [31:0]
.tl_AD_rnum(tl_AD_rnum),    //input [31:0]
.tl_AD_repeat(tl_AD_repeat),    //input 
.tl_AD_reset(tl_AD_reset),    //input 
.tl_AD_status(tl_AD_status),    //output 
.tl_DA_base(tl_DA_base),    //input [31:0]
.tl_DA_rnum(tl_DA_rnum),    //input [31:0]
.tl_DA_repeat(tl_DA_repeat),    //input 
.tl_DA_reset(tl_DA_reset),    //input 
.tl_DA_status(tl_DA_status),    //output 
.adc_clk(adc_clk),    //input 
.adc_rst(adc_rst),    //input 
.dac_clk(dac_clk),    //input 
.dac_rst(dac_rst),    //input 
.mfifo_rd_clr(mfifo_rd_clr),    //input 
.mfifo_rd_valid(mfifo_rd_valid),    //input 
.mfifo_rd_enable(mfifo_rd_enable),    //input 
.mfifo_rd_data(mfifo_rd_data),    //output [DIN_WIDTH-1:0]
.mfifo_wr_clr(mfifo_wr_clr),    //input 
.mfifo_wr_valid(mfifo_wr_valid),    //input 
.mfifo_wr_enable(mfifo_wr_enable),    //input 
.mfifo_wr_data(mfifo_wr_tdata),    //input [DIN_WIDTH-1:0]
.m_axi_araddr(mem_axi_M.axi_araddr[LOCAL_AWIDTH-1:0]),    //output [AWIDTH-1 : 0]
.m_axi_arlen(mem_axi_M.axi_arlen),    //output [LWIDTH-1 : 0]
.m_axi_arsize(mem_axi_M.axi_arsize),    //output [2 : 0]
.m_axi_arvalid(mem_axi_M.axi_arvalid),    //output 
.m_axi_arready(mem_axi_M.axi_arready),    //input 
.m_axi_rdata(mem_axi_M.axi_rdata),    //input [DOUT_WIDTH-1 : 0]
.m_axi_rresp(mem_axi_M.axi_rresp),    //input [1 : 0]
.m_axi_rlast(mem_axi_M.axi_rlast),    //input 
.m_axi_rvalid(mem_axi_M.axi_rvalid),    //input 
.m_axi_rready(mem_axi_M.axi_rready),    //output 
.m_axi_arburst(mem_axi_M.axi_arburst),    //output [1 : 0]
.m_axi_arprot(mem_axi_M.axi_arprot),    //output [2 : 0]
.m_axi_arlock(mem_axi_M.axi_arlock),    //output 
.m_axi_arcache(mem_axi_M.axi_arcache),    //output [3 : 0]
.m_axi_awaddr(mem_axi_M.axi_awaddr[LOCAL_AWIDTH-1:0]),    //output [AWIDTH-1 : 0]
.m_axi_awlen(mem_axi_M.axi_awlen),    //output [LWIDTH-1 : 0]
.m_axi_awsize(mem_axi_M.axi_awsize),    //output [2 : 0]
.m_axi_awvalid(mem_axi_M.axi_awvalid),    //output 
.m_axi_awready(mem_axi_M.axi_awready),    //input 
.m_axi_wdata(mem_axi_M.axi_wdata),    //output [DOUT_WIDTH-1 : 0]
.m_axi_wlast(mem_axi_M.axi_wlast),    //output 
.m_axi_wvalid(mem_axi_M.axi_wvalid),    //output 
.m_axi_wready(mem_axi_M.axi_wready),    //input 
.m_axi_bready(mem_axi_M.axi_bready),    //output 
.m_axi_bresp(mem_axi_M.axi_bresp),    //input [1 : 0]
.m_axi_bvalid(mem_axi_M.axi_bvalid),    //input 
.m_axi_awburst(mem_axi_M.axi_awburst),    //output [1 : 0]
.m_axi_awprot(mem_axi_M.axi_awprot),    //output [2 : 0]
.m_axi_awlock(mem_axi_M.axi_awlock),    //output 
.m_axi_awcache(mem_axi_M.axi_awcache),    //output [3 : 0]
.m_axi_wstrb(mem_axi_M.axi_wstrb)    //output [DOUT_WIDTH/8-1 : 0]
);
assign mem_axi_M.axi_arqos = 0;
assign mem_axi_M.axi_arregion = 0;
assign mem_axi_M.axi_awqos = 0;
assign mem_axi_M.axi_awregion = 0;
assign mem_axi_M.axi_araddr[35:LOCAL_AWIDTH] = 4'h4;
assign mem_axi_M.axi_awaddr[35:LOCAL_AWIDTH] = 4'h4;
assign HPC1_axi_M.axi_awaddr[48:32] = 17'h0008;
assign HPC1_axi_M.axi_araddr[48:32] = 17'h0008;

wire [255:0] m_axis_deepfifo_tdata;
wire  m_axis_deepfifo_tvalid;
wire  m_axis_deepfifo_tready;
wire  m_axis_deepfifo_tlast;
wire [255:0] m_axis_mux_tdata;
wire  m_axis_mux_tvalid;
wire  m_axis_mux_tready;
wire  m_axis_mux_tlast;
wire [255:0] m_axis_dout_tdata;
wire  m_axis_dout_tvalid;
wire  m_axis_dout_tready;
wire  m_axis_dout_tlast;

wire [31:0] cfg_D2H_ptr_sym;
assign cfg_D2H_ptr_sym = cfg_dev_dac_filter;
wire [31:0] cfg_D2H_axi_status_out;
assign cfg_D2H_axi_status = {cfg_D2H_axi_status_out[31:2], rec_fifo_overflow};
host_channel host_channel_EP0(
.app_clk(core_clk),    //input 
.app_rst(core_rst),    //input 
.cfg_H2D_addr_dma(cfg_H2D_addr_dma),    //input [AWIDTH-1:0]
.cfg_H2D_size_dma(cfg_H2D_size_dma),    //input [AWIDTH-1:0]
.cfg_H2D_burst_len(cfg_H2D_burst_len),    //input [31:0]
.cfg_H2D_frame_len(cfg_H2D_frame_len),    //input [31:0]
.cfg_H2D_trans_len(cfg_H2D_trans_len),    //input [31:0]
.cfg_H2D_axi_ctrl(cfg_H2D_axi_ctrl),    //input [31:0]
.cfg_H2D_axi_status(cfg_H2D_axi_status),    //output [31:0]
.cfg_D2H_addr_dma(cfg_D2H_addr_dma),    //input [AWIDTH-1:0]
.cfg_D2H_addr_sym(cfg_D2H_addr_sym),    //input [AWIDTH-1:0]
.cfg_D2H_size_dma(cfg_D2H_size_dma),    //input [AWIDTH-1:0]
.cfg_D2H_size_sym(cfg_D2H_size_sym),    //input [AWIDTH-1:0]
.cfg_D2H_burst_len(cfg_D2H_burst_len),    //input [31:0]
.cfg_D2H_frame_len(cfg_D2H_frame_len),    //input [31:0]
.cfg_D2H_trans_len(cfg_D2H_trans_len),    //input [31:0]
.cfg_D2H_axi_ctrl(cfg_D2H_axi_ctrl),    //input [31:0]
.cfg_D2H_axi_status(cfg_D2H_axi_status_out),    //output [31:0]
.cfg_D2H_ptr_sym(cfg_D2H_ptr_sym),    //input [31:0]
.adc_clk(adc_clk),    //input 
.adc_rst(adc_rst),    //input 
.s_axis_data_tdata (m_axis_mux_tdata),    //input [DIN_WIDTH-1:0]
.s_axis_data_tvalid(m_axis_mux_tvalid),    //input 
.s_axis_data_tready(m_axis_mux_tready),    //output 
.s_axis_data_tlast (m_axis_mux_tlast),    //input 
.cfg_axi_deepfifo_reset(cfg_axi_dinfifo_reset),
.dac_clk(dac_clk),    //input 
.dac_rst(dac_rst),    //input 
.m_axis_data_tdata (m_axis_dout_tdata),    //output [DIN_WIDTH-1:0]
.m_axis_data_tvalid(m_axis_dout_tvalid),    //output 
.m_axis_data_tready(m_axis_dout_tready | host_ready),    //input 
.m_axis_data_tlast (m_axis_dout_tlast),    //output 
.mem_clk(core_clk),    //input 
.mem_rst(core_rst),    //input 
.dac_aux_status(dac_aux_status),    //input [255:0]
.adc_aux_status(adc_aux_status),    //input [255:0]
.ram_enb(AUXRAM_en),    //output 
.ram_we(AUXRAM_we),    //output [31:0]
.ram_addr(AUXRAM_addr),    //output [31:0]
.ram_din(AUXRAM_din),    //output [255:0]
.ram_dout(AUXRAM_dout),    //input [255:0]
.m_axi_araddr(HPC1_axi_M.axi_araddr[31:0]),    //output [AWIDTH-1 : 0]
.m_axi_arlen(HPC1_axi_M.axi_arlen),    //output [LWIDTH-1 : 0]
.m_axi_arsize(HPC1_axi_M.axi_arsize),    //output [2 : 0]
.m_axi_arvalid(HPC1_axi_M.axi_arvalid),    //output 
.m_axi_arready(HPC1_axi_M.axi_arready),    //input 
.m_axi_rdata(HPC1_axi_M.axi_rdata),    //input [DOUT_WIDTH-1 : 0]
.m_axi_rresp(HPC1_axi_M.axi_rresp),    //input [1 : 0]
.m_axi_rlast(HPC1_axi_M.axi_rlast),    //input 
.m_axi_rvalid(HPC1_axi_M.axi_rvalid),    //input 
.m_axi_rready(HPC1_axi_M.axi_rready),    //output 
.m_axi_arburst(HPC1_axi_M.axi_arburst),    //output [1 : 0]
.m_axi_arprot(HPC1_axi_M.axi_arprot),    //output [2 : 0]
.m_axi_arlock(HPC1_axi_M.axi_arlock),    //output 
.m_axi_arcache(HPC1_axi_M.axi_arcache),    //output [3 : 0]
.m_axi_awaddr(HPC1_axi_M.axi_awaddr[31:0]),    //output [AWIDTH-1 : 0]
.m_axi_awlen(HPC1_axi_M.axi_awlen),    //output [LWIDTH-1 : 0]
.m_axi_awsize(HPC1_axi_M.axi_awsize),    //output [2 : 0]
.m_axi_awvalid(HPC1_axi_M.axi_awvalid),    //output 
.m_axi_awready(HPC1_axi_M.axi_awready),    //input 
.m_axi_wdata(HPC1_axi_M.axi_wdata),    //output [DOUT_WIDTH-1 : 0]
.m_axi_wlast(HPC1_axi_M.axi_wlast),    //output 
.m_axi_wvalid(HPC1_axi_M.axi_wvalid),    //output 
.m_axi_wready(HPC1_axi_M.axi_wready),    //input 
.m_axi_bready(HPC1_axi_M.axi_bready),    //output 
.m_axi_bresp(HPC1_axi_M.axi_bresp),    //input [1 : 0]
.m_axi_bvalid(HPC1_axi_M.axi_bvalid),    //input 
.m_axi_awburst(HPC1_axi_M.axi_awburst),    //output [1 : 0]
.m_axi_awprot(HPC1_axi_M.axi_awprot),    //output [2 : 0]
.m_axi_awlock(HPC1_axi_M.axi_awlock),    //output 
.m_axi_awcache(HPC1_axi_M.axi_awcache),    //output [3 : 0]
.m_axi_wstrb(HPC1_axi_M.axi_wstrb)    //output [DOUT_WIDTH/8-1 : 0]
);	
assign HPC1_axi_M.axi_arid = 0;
assign HPC1_axi_M.axi_awid = 0;
assign HPC1_axi_M.axi_awqos = 4'hF;
assign HPC1_axi_M.axi_arqos = 4'hF;
assign HPC1_axi_M.axi_aruser = 0;
assign HPC1_axi_M.axi_awuser = 0;	
// lopback

wire [255:0] m_axis_din_tdata;
wire  m_axis_din_tvalid;
wire  m_axis_din_tready;
wire  m_axis_din_tlast;
wire  m_axis_dout_tready_r1;

// ila_fifo ila_fifo_ep0(
// .clk(adc_clk),
// .probe0(m_axis_mux_tvalid),    // input wire s_axis_tvalid
// .probe1(m_axis_mux_tready),    // output wire s_axis_tready
// .probe2(m_axis_mux_tdata),      // input wire [127 : 0] s_axis_tdata
// .probe3(m_axis_mux_tlast),      // input wire s_axis_tlast
// .probe4(m_axis_dout_tvalid),    // output wire m_axis_tvalid
// .probe5(m_axis_dout_tready),    // input wire m_axis_tready
// .probe6(m_axis_dout_tdata),      // output wire [127 : 0] m_axis_tdata
// .probe7(m_axis_dout_tlast)      // output wire m_axis_tlast
// );
axis_data_fifox256 axis_data_fifox256_ep (
  .s_axis_aresetn(~cfg_axi_dinfifo_reset),  // input wire s_axis_aresetn
  .s_axis_aclk(adc_clk),        // input wire s_axis_aclk
  .s_axis_tvalid(m_axis_dout_tvalid),    // input wire s_axis_tvalid
  .s_axis_tready(m_axis_dout_tready_r1),    // output wire s_axis_tready
  .s_axis_tdata (m_axis_dout_tdata),      // input wire [127 : 0] s_axis_tdata
  .s_axis_tlast (m_axis_dout_tlast),      // input wire s_axis_tlast
  .m_axis_tvalid(m_axis_din_tvalid),    // output wire m_axis_tvalid
  .m_axis_tready(m_axis_din_tready),    // input wire m_axis_tready
  .m_axis_tdata (m_axis_din_tdata),      // output wire [127 : 0] m_axis_tdata
  .m_axis_tlast (m_axis_din_tlast)      // output wire m_axis_tlast
);


//----------------------------- deepfifo start -----------------------------------
assign m_axis_mux_tdata = host_loopsel?m_axis_din_tdata:m_axis_deepfifo_tdata;
assign m_axis_mux_tvalid = host_loopsel?m_axis_din_tvalid:m_axis_deepfifo_tvalid;
assign m_axis_mux_tlast = host_loopsel?m_axis_din_tlast:m_axis_deepfifo_tlast;
assign m_axis_deepfifo_tready = host_loopsel?1'b0:m_axis_mux_tready;
assign m_axis_din_tready = host_loopsel?m_axis_mux_tready:1'b0;

assign	m_axis_hostc_DA_tdata = m_axis_dout_tdata; 
assign  m_axis_hostc_DA_tvalid = m_axis_dout_tvalid;
assign  m_axis_dout_tready = host_loopsel? m_axis_dout_tready_r1:m_axis_hostc_DA_tready;
assign  m_axis_hostc_DA_tlast = m_axis_dout_tlast;



assign m_axis_mux_tdata = host_loopsel?m_axis_din_tdata:m_axis_deepfifo_tdata;
assign m_axis_mux_tvalid = host_loopsel?m_axis_din_tvalid:m_axis_deepfifo_tvalid;
assign m_axis_mux_tlast = host_loopsel?m_axis_din_tlast:m_axis_deepfifo_tlast;
assign m_axis_deepfifo_tready = host_loopsel?1'b0:m_axis_mux_tready;
assign m_axis_din_tready = host_loopsel?m_axis_mux_tready:1'b0;
`ifndef NO_DEEPFIFO
deepfifo_wrap 
#(
.BASE_ADDR(0),
.ADDR_WIDTH(31),
.LOG2_RAM_SIZE_ADDR(31),
.DIN_WIDTH(256),
.DOUT_WIDTH(256)
)deepfifo_wrap_EP0
(
.deepfifo_lite_S_clk(axi_aclk),
.deepfifo_lite_S_aresetn(!fifo_wr_clr),

.m_axis_deepfifo_rx_clk(adc_clk),//dataout,
.s_axis_deepfifo_rx_clk(adc_clk),//datain,
//.rx_rst(rx_rst),
//input tx_rst,
//AXI_S
.s_axis_deepfifo_rx_tdata(m_axis_hostc_AD_tdata),
.s_axis_deepfifo_rx_tvalid(m_axis_hostc_AD_tvalid),
.s_axis_deepfifo_rx_tready(m_axis_hostc_AD_tready),
.s_axis_deepfifo_rx_tlast(m_axis_hostc_AD_tlast),

.m_axis_deepfifo_rx_tdata(m_axis_deepfifo_tdata),
.m_axis_deepfifo_rx_tvalid(m_axis_deepfifo_tvalid),
.m_axis_deepfifo_rx_tready(m_axis_deepfifo_tready),
.m_axis_deepfifo_rx_tlast(m_axis_deepfifo_tlast),

//ddr
//.ddr4_sys_rst(ddr4_sys_rst),
//.ddr4_init_calib_complete(ddr4_init_calib_complete),
.ddr4_s_axi_clk(core_clk),
.ddr4_ui_clk_sync_rst(core_rst),

// Slave Interface Write Address Ports
.ddr4_aresetn(ddr4_aresetn),
.ddr4_s_axi_awid(deepfifo_axi_M.axi_awid),
.ddr4_s_axi_awaddr(deepfifo_axi_M.axi_awaddr[30:0]),
.ddr4_s_axi_awlen(deepfifo_axi_M.axi_awlen),
.ddr4_s_axi_awsize(deepfifo_axi_M.axi_awsize),
.ddr4_s_axi_awburst(deepfifo_axi_M.axi_awburst),
.ddr4_s_axi_awlock(deepfifo_axi_M.axi_awlock),
.ddr4_s_axi_awcache(deepfifo_axi_M.axi_awcache),
.ddr4_s_axi_awprot(deepfifo_axi_M.axi_awprot),
.ddr4_s_axi_awqos(deepfifo_axi_M.axi_awqos),
.ddr4_s_axi_awvalid(deepfifo_axi_M.axi_awvalid),
.ddr4_s_axi_awready(deepfifo_axi_M.axi_awready),
// Slave Interface Write Data Ports
.ddr4_s_axi_wdata(deepfifo_axi_M.axi_wdata),
.ddr4_s_axi_wstrb(deepfifo_axi_M.axi_wstrb),
.ddr4_s_axi_wlast(deepfifo_axi_M.axi_wlast),
.ddr4_s_axi_wvalid(deepfifo_axi_M.axi_wvalid),
.ddr4_s_axi_wready(deepfifo_axi_M.axi_wready),
// Slave Interface Write Response Ports
.ddr4_s_axi_bready(deepfifo_axi_M.axi_bready),
.ddr4_s_axi_bid(deepfifo_axi_M.axi_bid),
.ddr4_s_axi_bresp(deepfifo_axi_M.axi_bresp),
.ddr4_s_axi_bvalid(deepfifo_axi_M.axi_bvalid),
// Slave Interface Read Address Ports
.ddr4_s_axi_arid(deepfifo_axi_M.axi_arid),
.ddr4_s_axi_araddr(deepfifo_axi_M.axi_araddr[30:0]),
.ddr4_s_axi_arlen(deepfifo_axi_M.axi_arlen),
.ddr4_s_axi_arsize(deepfifo_axi_M.axi_arsize),
.ddr4_s_axi_arburst(deepfifo_axi_M.axi_arburst),
.ddr4_s_axi_arlock(deepfifo_axi_M.axi_arlock),
.ddr4_s_axi_arcache(deepfifo_axi_M.axi_arcache),
.ddr4_s_axi_arprot(deepfifo_axi_M.axi_arprot),
.ddr4_s_axi_arqos(deepfifo_axi_M.axi_arqos),
.ddr4_s_axi_arvalid(deepfifo_axi_M.axi_arvalid),
.ddr4_s_axi_arready(deepfifo_axi_M.axi_arready),
// Slave Interface Read Data Ports
.ddr4_s_axi_rready(deepfifo_axi_M.axi_rready),
.ddr4_s_axi_rid(deepfifo_axi_M.axi_rid),
.ddr4_s_axi_rdata(deepfifo_axi_M.axi_rdata),
.ddr4_s_axi_rresp(deepfifo_axi_M.axi_rresp),
.ddr4_s_axi_rlast(deepfifo_axi_M.axi_rlast),
.ddr4_s_axi_rvalid(deepfifo_axi_M.axi_rvalid),

//axi_lite
/// Write address, data and response
.deepfifo_lite_S_awaddr(),
.deepfifo_lite_S_awprot(),
.deepfifo_lite_S_awready(),
.deepfifo_lite_S_awvalid(),
.deepfifo_lite_S_wdata(),
.deepfifo_lite_S_wready(),
.deepfifo_lite_S_wstrb(),
.deepfifo_lite_S_wvalid(),	
.deepfifo_lite_S_bready(),
.deepfifo_lite_S_bresp(),
.deepfifo_lite_S_bvalid(),
		
// Read address and data    		
.deepfifo_lite_S_araddr(),
.deepfifo_lite_S_arprot(),
.deepfifo_lite_S_arready(),
.deepfifo_lite_S_arvalid(),	
.deepfifo_lite_S_rdata(),
.deepfifo_lite_S_rready(),
.deepfifo_lite_S_rresp(),
.deepfifo_lite_S_rvalid() 

//ddr
//.init_calib_complete(init_calib_complete)
);
assign	deepfifo_axi_M.axi_awaddr[35:31] = 5'h9;
assign	deepfifo_axi_M.axi_araddr[35:31] = 5'h9;
`else
assign m_axis_deepfifo_tdata = m_axis_hostc_AD_tdata;
assign m_axis_deepfifo_tvalid = m_axis_hostc_AD_tvalid;
assign m_axis_hostc_AD_tready = m_axis_deepfifo_tready;
assign m_axis_deepfifo_tlast = m_axis_hostc_AD_tlast;
`endif
//----------------------------- deepfifo stop -----------------------------------

	
endmodule
