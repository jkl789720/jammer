
//Copyright 1986-2016 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2016.4 (win63) Build 1756540 Mon Jan 23 19:11:23 MST 2017
//Date        : Mon Jun 01 14:57:46 2020
//Host        : Dell-PC running 63-bit Service Pack 1  (build 7601)
//Command     : generate_target deepfifo_top.bd
//Design      : deepfifo_top
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CORE_GENERATION_INFO = "deepfifo_top,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=ddr_top,x_ipVersion=1.00.a,x_ipLanguage=VERILOG,numBlks=6,numReposBlks=6,numNonXlnxBlks=0,numHierBlks=0,maxHierDepth=0,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=2,numPkgbdBlks=0,bdsource=USER,synth_mode=OOC_per_IP}" *) (* HW_HANDOFF = "ddr_top.hwdef" *) 
module deepfifo_top #(
  parameter BASE_ADDR = 0,
  parameter PREFIFO_DIN_WIDTH = 512,
  parameter POSTFIFO_DOUT_WIDTH = 512,
  parameter ADDR_WIDTH = 33,
  parameter LOG2_RAM_SIZE_ADDR =33,
  parameter LOG2_BURST_WORDS = 8,
  parameter LOG2_WORD_WIDTH =9
 // parameter LOG2_FIFO_WORDS = 10,
 // parameter FIFO_THRESHOLD = 256
  )
   (
  //  `include "ddr4_define.h" 
   
   //DDR4 interface
   output  								ddr4_sys_rst,


   input                				ddr4_init_calib_complete,
   input                				ddr4_ui_clk,
   input                				ddr4_ui_clk_sync_rst,


   // Slave Interface Write Address Ports
   output                 				ddr4_aresetn,
   output  [0:0]     					ddr4_s_axi_awid,
   output  [ADDR_WIDTH-1:0]   					ddr4_s_axi_awaddr,
   output  [7:0]                       	ddr4_s_axi_awlen,
   output  [2:0]                       	ddr4_s_axi_awsize,
   output  [1:0]                       	ddr4_s_axi_awburst,
   output  [0:0]                       	ddr4_s_axi_awlock,
   output  [3:0]                       	ddr4_s_axi_awcache,
   output  [2:0]                       	ddr4_s_axi_awprot,
   output  [3:0]                       	ddr4_s_axi_awqos,
   output                              	ddr4_s_axi_awvalid,
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
   output  [ADDR_WIDTH-1:0]  						ddr4_s_axi_araddr,
   output  [7:0]                      	ddr4_s_axi_arlen,
   output  [2:0]                     	ddr4_s_axi_arsize,
   output  [1:0]                  	    ddr4_s_axi_arburst,
   output  [0:0]                 	    ddr4_s_axi_arlock,
   output  [3:0]              	        ddr4_s_axi_arcache,
   output  [2:0]                  	    ddr4_s_axi_arprot,
   output  [3:0]               	        ddr4_s_axi_arqos,
   output                        	    ddr4_s_axi_arvalid,
   input                     	        ddr4_s_axi_arready,
   // Slave Interface Read Data Ports
   output                             	ddr4_s_axi_rready,
   input [0:0]      					ddr4_s_axi_rid,
   input [511:0]    					ddr4_s_axi_rdata,
   input [1:0]                   	    ddr4_s_axi_rresp,
   input                         	    ddr4_s_axi_rlast,
   input                        	    ddr4_s_axi_rvalid,
     
   
  input clk_ddr_sys,
  input clk_postfifo,
  input clk_prefifo,
  input clk_status,

  output [POSTFIFO_DOUT_WIDTH-1:0]m_axis_data_tdata,
  output m_axis_data_tlast,
  input m_axis_data_tready,
  output m_axis_data_tvalid,
  output [31:0]max_depth,
  output [63:0]nonbypass_data,
  input reset,

  input reset_ddr,
  input [PREFIFO_DIN_WIDTH-1:0]s_axis_data_tdata,
  input s_axis_data_tlast,
  output s_axis_data_tready,
  input s_axis_data_tvalid,
  output [31:0]status,
  output init_calib_complete,
  output [63:0]total_data);
 
  
  
  
  reg                   c0_ddr4_aresetn;
  wire                  c0_ddr4_clk;
  wire                  c0_ddr4_rst;
  wire                  c0_init_calib_complete;

  wire post_rd_EN;
  wire [63:0]blk_mem_gen_0_doutb;
  wire clk_ddr_sys_1;
  wire clk_postfifo_1;
  wire clk_prefifo_1;
  wire clk_status_1;
  wire [32:0]deepfifo_0_axi_ARADDR;
  wire [1:0]deepfifo_0_axi_ARBURST;
  wire [7:0]deepfifo_0_axi_ARLEN;
  wire deepfifo_0_axi_ARREADY;
  wire [2:0]deepfifo_0_axi_ARSIZE;
  wire deepfifo_0_axi_ARVALID;
  wire [32:0]deepfifo_0_axi_AWADDR;
  wire [1:0]deepfifo_0_axi_AWBURST;
  wire [7:0]deepfifo_0_axi_AWLEN;
  wire deepfifo_0_axi_AWREADY;
  wire [2:0]deepfifo_0_axi_AWSIZE;
  wire deepfifo_0_axi_AWVALID;
  wire deepfifo_0_axi_BREADY;
  wire deepfifo_0_axi_BVALID;
  wire [511:0]deepfifo_0_axi_RDATA;
  wire deepfifo_0_axi_RLAST;
  wire deepfifo_0_axi_RREADY;
  wire deepfifo_0_axi_RVALID;
  wire [511:0]deepfifo_0_axi_WDATA;
  wire deepfifo_0_axi_WLAST;
  wire deepfifo_0_axi_WREADY;
  wire [63:0]deepfifo_0_axi_WSTRB;
  wire deepfifo_0_axi_WVALID;
  wire deepfifo_0_axi_aresetn;
  wire [31:0]deepfifo_0_bursts_stored;
  wire deepfifo_0_do_from_ram_burst;
  wire [511:0]deepfifo_0_fifo_post_din;
  wire deepfifo_0_fifo_post_wr_en;
  wire deepfifo_0_fifo_pre_rd_en;

  wire [POSTFIFO_DOUT_WIDTH -1:0]post_fifo_dout;
  wire post_fifo_empty;
  wire post_fifo_full;
  wire [11:0]post_fifo_wr_data_count;
  wire [511:0]pre_fifo_dout;
  wire pre_fifo_empty;
  wire pre_fifo_full;
  wire [10:0]pre_fifo_rd_data_count;
  wire [11:0]pre_fifo_wr_data_count;
  wire reset_1;
  wire reset_ddr_1;
  wire [PREFIFO_DIN_WIDTH -1 :0]s_axis_data_1_TDATA;
  wire s_axis_data_1_TLAST;
  wire s_axis_data_1_TREADY;
  wire s_axis_data_1_TVALID;
  wire [1:0]status_reg_0_addr_r;
  wire [1:0]status_reg_0_addr_w;
  wire status_reg_0_clk_ddr3sys_out;
  wire status_reg_0_clk_postfifo_out;
  wire status_reg_0_clk_prefifo_out;
  wire status_reg_0_clka;
  wire status_reg_0_clkb;
  wire [63:0]status_reg_0_data_w;
  wire [POSTFIFO_DOUT_WIDTH -1:0]status_reg_0_m_axis_data_TDATA;
  wire status_reg_0_m_axis_data_TLAST;
  wire status_reg_0_m_axis_data_TREADY;
  wire status_reg_0_m_axis_data_TVALID;
  wire [31:0]status_reg_0_max_depth;
  wire [63:0]status_reg_0_nonbypass_data;
  wire [PREFIFO_DIN_WIDTH -1 :0]status_reg_0_pre_fifo_dout;
  wire status_reg_0_pre_fifo_wn;
  wire status_reg_0_reset_ddr_syn;
  wire status_reg_0_reset_deepfifo_syn;
  wire status_reg_0_reset_postfifo_syn;
  wire status_reg_0_reset_prefifo_syn;
  wire status_reg_0_reset_ddr_axi_syn;
  wire [31:0]status_reg_0_status;
  wire [63:0]status_reg_0_total_data;
  wire status_reg_0_wea;


  assign clk_ddr_sys_1 = clk_ddr_sys;
  assign clk_postfifo_1 = clk_postfifo;
  assign clk_prefifo_1 = clk_prefifo;
  assign clk_status_1 = clk_status;

  assign m_axis_data_tdata[POSTFIFO_DOUT_WIDTH -1:0] = status_reg_0_m_axis_data_TDATA;
  assign m_axis_data_tlast = status_reg_0_m_axis_data_TLAST;
  assign m_axis_data_tvalid = status_reg_0_m_axis_data_TVALID;
  assign max_depth[31:0] = status_reg_0_max_depth;
  assign nonbypass_data[63:0] = status_reg_0_nonbypass_data;
  assign reset_1 = reset;
  assign reset_ddr_1 = reset_ddr;
  assign s_axis_data_1_TDATA = s_axis_data_tdata[PREFIFO_DIN_WIDTH-1:0];
  assign s_axis_data_1_TLAST = s_axis_data_tlast;
  assign s_axis_data_1_TVALID = s_axis_data_tvalid;
  assign s_axis_data_tready = s_axis_data_1_TREADY;
  assign status[31:0] = status_reg_0_status;
  assign status_reg_0_m_axis_data_TREADY = m_axis_data_tready;
  assign total_data[63:0] = status_reg_0_total_data;
  assign init_calib_complete=c0_init_calib_complete;
  
  //参数存储和读取时钟转�?
  ddr_top_blk_mem_gen_0_0 blk_mem_gen_0
       (.addra(status_reg_0_addr_w),
        .addrb(status_reg_0_addr_r),
        .clka(status_reg_0_clka),
        .clkb(status_reg_0_clkb),
        .dina(status_reg_0_data_w),
        .doutb(blk_mem_gen_0_doutb),
        .wea(status_reg_0_wea));

deepfifo  #( .base_addr(BASE_ADDR),
             .addr_width(ADDR_WIDTH),
             .log2_ram_size_addr(LOG2_RAM_SIZE_ADDR),
             .log2_word_width(LOG2_WORD_WIDTH),
             .log2_fifo_words(11),
             .log2_burst_words(LOG2_BURST_WORDS),
             .fifo_threshold(512)
//             .log2_word_addr_size(6),
//             .log2_words_in_ram(26),
//             .log2_bursts_in_ram(18),
//             .word_width(512),
//             .strobe_width(63)
        )


deepfifo_EP0(
        .axi_araddr(deepfifo_0_axi_ARADDR),
        .axi_arburst(deepfifo_0_axi_ARBURST),
        .axi_aresetn(deepfifo_0_axi_aresetn),
        .axi_arlen(deepfifo_0_axi_ARLEN),
        .axi_arready(deepfifo_0_axi_ARREADY),
        .axi_arsize(deepfifo_0_axi_ARSIZE),
        .axi_arvalid(deepfifo_0_axi_ARVALID),
        .axi_awaddr(deepfifo_0_axi_AWADDR),
        .axi_awburst(deepfifo_0_axi_AWBURST),
        .axi_awlen(deepfifo_0_axi_AWLEN),
        .axi_awready(deepfifo_0_axi_AWREADY),
        .axi_awsize(deepfifo_0_axi_AWSIZE),
        .axi_awvalid(deepfifo_0_axi_AWVALID),
        .axi_bready(deepfifo_0_axi_BREADY),
        .axi_bvalid(deepfifo_0_axi_BVALID),
        .axi_rdata(deepfifo_0_axi_RDATA),
        .axi_rlast(deepfifo_0_axi_RLAST),
        .axi_rready(deepfifo_0_axi_RREADY),
        .axi_rvalid(deepfifo_0_axi_RVALID),
        .axi_wdata(deepfifo_0_axi_WDATA),
        .axi_wlast(deepfifo_0_axi_WLAST),
        .axi_wready(deepfifo_0_axi_WREADY),
        .axi_wstrb(deepfifo_0_axi_WSTRB),
        .axi_wvalid(deepfifo_0_axi_WVALID),
        .bursts_stored(deepfifo_0_bursts_stored),
        .clk(c0_ddr4_clk),
        .do_from_ram_burst(deepfifo_0_do_from_ram_burst),
        .fifo_post_din(deepfifo_0_fifo_post_din),
        .fifo_post_full(post_fifo_full),
        .fifo_post_wr_count(post_fifo_wr_data_count),
        .fifo_post_wr_en(deepfifo_0_fifo_post_wr_en),
        .fifo_pre_dout(pre_fifo_dout),
        .fifo_pre_empty(pre_fifo_empty),
        .fifo_pre_rd_count(pre_fifo_rd_data_count),
        .fifo_pre_rd_en(deepfifo_0_fifo_pre_rd_en),
        .reset(status_reg_0_reset_deepfifo_syn));
        
  /* ddr4_0 mig_7series_0
       (.aresetn(deepfifo_0_axi_aresetn),
        .clk_ref_i(status_reg_0_clk_ddr3sys_out),
        .ddr3_addr(mig_7series_0_DDR3_ADDR),
        .ddr3_ba(mig_7series_0_DDR3_BA),
        .ddr3_cas_n(mig_7series_0_DDR3_CAS_N),
        .ddr3_ck_n(mig_7series_0_DDR3_CK_N),
        .ddr3_ck_p(mig_7series_0_DDR3_CK_P),
        .ddr3_cke(mig_7series_0_DDR3_CKE),
        .ddr3_cs_n(mig_7series_0_DDR3_CS_N),
        .ddr3_dm(mig_7series_0_DDR3_DM),
        .ddr3_dq(DDR0_dq[63:0]),
        .ddr3_dqs_n(DDR0_dqs_n[7:0]),
        .ddr3_dqs_p(DDR0_dqs_p[7:0]),
        .ddr3_odt(mig_7series_0_DDR3_ODT),
        .ddr3_ras_n(mig_7series_0_DDR3_RAS_N),
        .ddr3_reset_n(mig_7series_0_DDR3_RESET_N),
        .ddr3_we_n(mig_7series_0_DDR3_WE_N),
        .device_temp_i(device_temp_i_1),
        .init_calib_complete(mig_7series_0_init_calib_complete),
        .mmcm_locked(mig_7series_0_mmcm_locked),
        .s_axi_araddr(deepfifo_0_axi_ARADDR),
        .s_axi_arburst(deepfifo_0_axi_ARBURST),
        .s_axi_arcache({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arid({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arlen(deepfifo_0_axi_ARLEN),
        .s_axi_arlock(1'b0),
        .s_axi_arprot({1'b0,1'b0,1'b0}),
        .s_axi_arqos({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arready(deepfifo_0_axi_ARREADY),
        .s_axi_arsize(deepfifo_0_axi_ARSIZE),
        .s_axi_arvalid(deepfifo_0_axi_ARVALID),
        .s_axi_awaddr(deepfifo_0_axi_AWADDR),
        .s_axi_awburst(deepfifo_0_axi_AWBURST),
        .s_axi_awcache({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awid({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awlen(deepfifo_0_axi_AWLEN),
        .s_axi_awlock(1'b0),
        .s_axi_awprot({1'b0,1'b0,1'b0}),
        .s_axi_awqos({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awready(deepfifo_0_axi_AWREADY),
        .s_axi_awsize(deepfifo_0_axi_AWSIZE),
        .s_axi_awvalid(deepfifo_0_axi_AWVALID),
        .s_axi_bready(deepfifo_0_axi_BREADY),
        .s_axi_bvalid(deepfifo_0_axi_BVALID),
        .s_axi_rdata(deepfifo_0_axi_RDATA),
        .s_axi_rlast(deepfifo_0_axi_RLAST),
        .s_axi_rready(deepfifo_0_axi_RREADY),
        .s_axi_rvalid(deepfifo_0_axi_RVALID),
        .s_axi_wdata(deepfifo_0_axi_WDATA),
        .s_axi_wlast(deepfifo_0_axi_WLAST),
        .s_axi_wready(deepfifo_0_axi_WREADY),
        .s_axi_wstrb(deepfifo_0_axi_WSTRB),
        .s_axi_wvalid(deepfifo_0_axi_WVALID),
        .sys_clk_i(status_reg_0_clk_ddr3sys_out),
        .sys_rst(status_reg_0_reset_ddr_syn),
        .ui_clk(c0_ddr4_clk)); */
    //***************************************************************************
// The User design is instantiated below. The memory interface ports are
// connected to the top-level and the application interface ports are
// connected to the traffic generator module. This provides a reference
// for connecting the memory controller to system.
//***************************************************************************

  // user design top is one instance for all controllers

/*  

ddr4_0 u_ddr4_0
  (
   .sys_rst           (status_reg_0_reset_ddr_syn),
   `include "ddr4_inst.h" 
   

   .c0_init_calib_complete (c0_init_calib_complete),
   .c0_ddr4_ui_clk                (c0_ddr4_clk),
   .c0_ddr4_ui_clk_sync_rst       (c0_ddr4_rst),
  // .addn_ui_clkout1                            (),
  // .dbg_clk                                    (dbg_clk),
  // Slave Interface Write Address Ports
  .c0_ddr4_aresetn                     (c0_ddr4_aresetn),
  .c0_ddr4_s_axi_awid                  ({1'b0,1'b0,1'b0,1'b0}),
  .c0_ddr4_s_axi_awaddr                (deepfifo_0_axi_AWADDR),
  .c0_ddr4_s_axi_awlen                 (deepfifo_0_axi_AWLEN),
  .c0_ddr4_s_axi_awsize                (deepfifo_0_axi_AWSIZE),
  .c0_ddr4_s_axi_awburst               (deepfifo_0_axi_AWBURST),
  .c0_ddr4_s_axi_awlock                (1'b0),
  .c0_ddr4_s_axi_awcache               ({1'b0,1'b0,1'b0,1'b0}),
  .c0_ddr4_s_axi_awprot                ({1'b0,1'b0,1'b0}),
  .c0_ddr4_s_axi_awqos                 ({1'b0,1'b0,1'b0,1'b0}),
  .c0_ddr4_s_axi_awvalid               (deepfifo_0_axi_AWVALID),
  .c0_ddr4_s_axi_awready               (deepfifo_0_axi_AWREADY),
  
  // Slave Interface Write Data Ports
  .c0_ddr4_s_axi_wdata                 (deepfifo_0_axi_WDATA),
  .c0_ddr4_s_axi_wstrb                 (deepfifo_0_axi_WSTRB),
  .c0_ddr4_s_axi_wlast                 (deepfifo_0_axi_WLAST),
  .c0_ddr4_s_axi_wvalid                (deepfifo_0_axi_WVALID),
  .c0_ddr4_s_axi_wready                (deepfifo_0_axi_WREADY),
  
  // Slave Interface Write Response Ports
  .c0_ddr4_s_axi_bid                   (c0_ddr4_s_axi_bid),
  .c0_ddr4_s_axi_bresp                 (c0_ddr4_s_axi_bresp),
  .c0_ddr4_s_axi_bvalid                (deepfifo_0_axi_BVALID),
  .c0_ddr4_s_axi_bready                (deepfifo_0_axi_BREADY),
  // Slave Interface Read Address Ports
  .c0_ddr4_s_axi_arid                  ({1'b0,1'b0,1'b0,1'b0}),
  .c0_ddr4_s_axi_araddr                (deepfifo_0_axi_ARADDR),
  .c0_ddr4_s_axi_arlen                 (deepfifo_0_axi_ARLEN),
  .c0_ddr4_s_axi_arsize                (deepfifo_0_axi_ARSIZE),
  .c0_ddr4_s_axi_arburst               (deepfifo_0_axi_ARBURST),
  .c0_ddr4_s_axi_arlock                (1'b0),
  .c0_ddr4_s_axi_arcache               ({1'b0,1'b0,1'b0,1'b0}),
  .c0_ddr4_s_axi_arprot                (3'b0),
  .c0_ddr4_s_axi_arqos                 (4'b0),
  .c0_ddr4_s_axi_arvalid               (deepfifo_0_axi_ARVALID),
  .c0_ddr4_s_axi_arready               (deepfifo_0_axi_ARREADY),
  
  // Slave Interface Read Data Ports
  .c0_ddr4_s_axi_rid                   (c0_ddr4_s_axi_rid),
  .c0_ddr4_s_axi_rdata                 (deepfifo_0_axi_RDATA),
  .c0_ddr4_s_axi_rresp                 (c0_ddr4_s_axi_rresp),
  .c0_ddr4_s_axi_rlast                 (deepfifo_0_axi_RLAST),
  .c0_ddr4_s_axi_rvalid                (deepfifo_0_axi_RVALID),
  .c0_ddr4_s_axi_rready                (deepfifo_0_axi_RREADY),
   
  // Debug Port
  .dbg_bus         (dbg_bus)                                             

  );
*/ 
 
//DDR signal

  assign  ddr4_sys_rst           				=		status_reg_0_reset_ddr_syn;
               		
														
														
  assign  c0_init_calib_complete 				=		ddr4_init_calib_complete;
  assign  c0_ddr4_clk      						=		ddr4_ui_clk;         
  assign  c0_ddr4_rst       					=		ddr4_ui_clk_sync_rst;
														
  // Slave Interface Write Address Ports      		
  assign  ddr4_aresetn                    		=		c0_ddr4_aresetn;
  assign  ddr4_s_axi_awid                 		=		{1'b0,1'b0,1'b0,1'b0};
  assign  ddr4_s_axi_awaddr               		=		deepfifo_0_axi_AWADDR;
  assign  ddr4_s_axi_awlen                		= 		deepfifo_0_axi_AWLEN;
  assign  ddr4_s_axi_awsize               		=		deepfifo_0_axi_AWSIZE;
  assign  ddr4_s_axi_awburst              		=		deepfifo_0_axi_AWBURST;
  assign  ddr4_s_axi_awlock               		=		1'b0;
  assign  ddr4_s_axi_awcache              		=		{1'b0,1'b0,1'b0,1'b0};
  assign  ddr4_s_axi_awprot               		=		{1'b0,1'b0,1'b0};
  assign  ddr4_s_axi_awqos                		=		{1'b0,1'b0,1'b0,1'b0};
  assign  ddr4_s_axi_awvalid              		=		deepfifo_0_axi_AWVALID;
  assign  deepfifo_0_axi_AWREADY              	=		ddr4_s_axi_awready;
														
  // Slave Interface Write Data Ports	       		
  assign  ddr4_s_axi_wdata                		=		deepfifo_0_axi_WDATA;
  assign  ddr4_s_axi_wstrb                		=		deepfifo_0_axi_WSTRB;
  assign  ddr4_s_axi_wlast                		=		deepfifo_0_axi_WLAST;
  assign  ddr4_s_axi_wvalid               		=		deepfifo_0_axi_WVALID;
  assign  deepfifo_0_axi_WREADY               	=		ddr4_s_axi_wready;
														
  // Slave Interface Write Response Ports	   	
  assign  c0_ddr4_s_axi_bid               		=		ddr4_s_axi_bid;   
  assign  c0_ddr4_s_axi_bresp               	=		ddr4_s_axi_bresp;
  assign  deepfifo_0_axi_BVALID               	=		ddr4_s_axi_bvalid;
  assign  ddr4_s_axi_bready               		=		deepfifo_0_axi_BREADY;
  // Slave Interface Read Address Ports	    	   	
  assign  ddr4_s_axi_arid                 		=		{1'b0,1'b0,1'b0,1'b0};
  assign  ddr4_s_axi_araddr               		=		deepfifo_0_axi_ARADDR;
  assign  ddr4_s_axi_arlen                		=		deepfifo_0_axi_ARLEN;
  assign  ddr4_s_axi_arsize               		=		deepfifo_0_axi_ARSIZE;
  assign  ddr4_s_axi_arburst              		=		deepfifo_0_axi_ARBURST;
  assign  ddr4_s_axi_arlock               		=		1'b0;
  assign  ddr4_s_axi_arcache              		=		{1'b0,1'b0,1'b0,1'b0};
  assign  ddr4_s_axi_arprot               		=		3'b0;
  assign  ddr4_s_axi_arqos                		=		4'b0;
  assign  ddr4_s_axi_arvalid              		=		deepfifo_0_axi_ARVALID;
  assign  deepfifo_0_axi_ARREADY              	=		ddr4_s_axi_arready;
															
  // Slave Interface Read Data Ports	    	  	
  assign  c0_ddr4_s_axi_rid               		=		ddr4_s_axi_rid;   
  assign  deepfifo_0_axi_RDATA               	=		ddr4_s_axi_rdata; 
  assign  c0_ddr4_s_axi_rresp               	=		ddr4_s_axi_rresp; 
  assign  deepfifo_0_axi_RLAST               	=		ddr4_s_axi_rlast; 
  assign  deepfifo_0_axi_RVALID              	=		ddr4_s_axi_rvalid;
  assign  ddr4_s_axi_rready               		=		deepfifo_0_axi_RREADY;




 
  wire post_wr_rst_busy;
  wire post_rd_rst_busy;
  wire pre_wr_rst_busy;
  wire pre_rd_rst_busy;
  
 
  wire post_wr_rst_busy_r2;
  wire post_rd_rst_busy_r2;
  wire pre_wr_rst_busy_r2;
  wire pre_rd_rst_busy_r2;
  
  wire status_reg_0_reset_postfifo_syn_r1;
  wire status_reg_0_reset_prefifo_syn_r1;
  
    always @(posedge c0_ddr4_clk) begin
     c0_ddr4_aresetn <= ~c0_ddr4_rst;
   end
  
fifo_reset_delay fifo_reset_postfifo_EP0(
.wr_clk(c0_ddr4_clk),
.rd_clk(status_reg_0_clk_postfifo_out),
.rst_in(status_reg_0_reset_postfifo_syn),
.wr_rst_busyin(post_wr_rst_busy),
.rd_rst_busyin(post_rd_rst_busy),
	
.rst_out(status_reg_0_reset_postfifo_syn_r1),
.wr_rst_busyout(post_wr_rst_busy_r2),
.rd_rst_busyout(post_rd_rst_busy_r2)
);
  
ddr_top_post_fifo_0 post_fifo
(.din(deepfifo_0_fifo_post_din),
.dout(post_fifo_dout),
.empty(post_fifo_empty),
.full(post_fifo_full),
.rd_clk(status_reg_0_clk_postfifo_out),
.rd_en(post_rd_EN&!post_rd_rst_busy_r2),
.rst(status_reg_0_reset_postfifo_syn_r1), 
.wr_clk(c0_ddr4_clk),
.wr_data_count(post_fifo_wr_data_count),
.wr_en(deepfifo_0_fifo_post_wr_en&!post_wr_rst_busy_r2),
.wr_rst_busy(post_wr_rst_busy),
.rd_rst_busy(post_rd_rst_busy));
  
    
  
  
  
fifo_reset_delay fifo_reset_prefifo_EP0(
.wr_clk(mem_clk),
.rd_clk(c0_ddr4_clk),
.rst_in(status_reg_0_reset_prefifo_syn),
.wr_rst_busyin(pre_wr_rst_busy),
.rd_rst_busyin(pre_rd_rst_busy),
	
.rst_out(status_reg_0_reset_prefifo_syn_r1),
.wr_rst_busyout(pre_wr_rst_busy_r2),
.rd_rst_busyout(pre_rd_rst_busy_r2)
);


  ddr_top_pre_fifo_0 pre_fifo
       (.din(status_reg_0_pre_fifo_dout),
        .dout(pre_fifo_dout),
        .empty(pre_fifo_empty),
        .full(pre_fifo_full),
        .rd_clk(c0_ddr4_clk),
        .rd_data_count(pre_fifo_rd_data_count),
        .rd_en(deepfifo_0_fifo_pre_rd_en&!pre_rd_rst_busy_r2),
        .rst(status_reg_0_reset_prefifo_syn_r1),
        .wr_clk(status_reg_0_clk_prefifo_out),
        .wr_data_count(pre_fifo_wr_data_count),
        .wr_en(status_reg_0_pre_fifo_wn&!pre_wr_rst_busy_r2),
		.wr_rst_busy(pre_wr_rst_busy),
		.rd_rst_busy(pre_rd_rst_busy));


//reg [31:0] post_counter;
/* always @(posedge status_reg_0_clk_postfifo_out or posedge reset) begin
if (reset)
		post_counter <= 0;
else begin
	if(post_rd_EN ==1) begin
		post_counter <= post_counter + 1;	
	end
end
end */

`ifndef BYPASS_ALLSCOPE
ila_deepfifo ila_deepfifo_ep0(
.clk(c0_ddr4_clk),
.probe0(deepfifo_0_fifo_post_din),
.probe1(pre_fifo_dout),
.probe2(post_fifo_full),
.probe3(pre_fifo_empty),
.probe4(deepfifo_0_fifo_pre_rd_en),
.probe5(deepfifo_0_fifo_post_wr_en),
.probe6(pre_fifo_rd_data_count),
.probe7(post_fifo_wr_data_count),
.probe8(status_reg_0_reset_deepfifo_syn ),
.probe9(deepfifo_0_do_from_ram_burst),
.probe10(deepfifo_0_bursts_stored),
.probe11(post_wr_rst_busy),
.probe12(pre_rd_rst_busy),
.probe13(post_fifo_empty ),
.probe14(post_rd_EN),
.probe15(status_reg_0_pre_fifo_wn),
.probe16(pre_fifo_full),
.probe17(post_rd_rst_busy),
.probe18(pre_wr_rst_busy),
.probe19(post_wr_rst_busy_r2),
.probe20(pre_rd_rst_busy_r2),
.probe21(post_rd_rst_busy_r2),
.probe22(pre_wr_rst_busy_r2)
);


ila_deepfifo_post ila_deepfifo_post_ep0(
.clk(status_reg_0_clk_postfifo_out),
.probe0(post_fifo_dout),
.probe1(post_rd_EN),
//.probe2(post_fifo_full ),
.probe2(post_fifo_empty ),
.probe3(status_reg_0_reset_postfifo_syn ),
.probe4(post_rd_rst_busy)
);

ila_deepfifo_pre ila_deepfifo_pre_ep0(
.clk(status_reg_0_clk_prefifo_out),
.probe0(status_reg_0_pre_fifo_dout),
.probe1(status_reg_0_pre_fifo_wn  ),
.probe2(pre_fifo_full ),
//.probe3(pre_fifo_empty ),
.probe3(pre_fifo_wr_data_count),
.probe4(status_reg_0_reset_prefifo_syn),
.probe5(pre_rd_rst_busy)
//.probe6(status_reg_0_reset_deepfifo_syn)
);
`endif
//xpm_fifo_async # (

//  .FIFO_MEMORY_TYPE          ("block"),           //string; "auto", "block", or "distributed";
//  .ECC_MODE                  ("no_ecc"),         //string; "no_ecc" or "en_ecc";
//  .RELATED_CLOCKS            (0),                //positive integer; 0 or 1
//  .FIFO_WRITE_DEPTH          (2048*512/PREFIFO_DIN_WIDTH),             //positive integer 总数据容量是512*2048
//  .WRITE_DATA_WIDTH          (PREFIFO_DIN_WIDTH),               //positive integer
//  .WR_DATA_COUNT_WIDTH       ($clog2(2048*512/PREFIFO_DIN_WIDTH)),               //positive integer
//  .PROG_FULL_THRESH          (10),               //positive integer
//  .FULL_RESET_VALUE          (0),                //positive integer; 0 or 1
//  .READ_MODE                 ("std"),            //string; "std" or "fwft";
//  .FIFO_READ_LATENCY         (1),                //positive integer;
//  .READ_DATA_WIDTH           (512),               //positive integer
//  .RD_DATA_COUNT_WIDTH       (11),               //positive integer
//  .PROG_EMPTY_THRESH         (10),               //positive integer
//  .DOUT_RESET_VALUE          ("0"),              //string
//  .CDC_SYNC_STAGES           (6),                //positive integer
//  .WAKEUP_TIME               (0)                 //positive integer; 0 or 2;

//) pre_fifo (
//   .din(status_reg_0_pre_fifo_dout),
//   .dout(pre_fifo_dout),
//   .empty(pre_fifo_empty),
//   .full(pre_fifo_full),
//   .rd_clk(c0_ddr4_clk),
//   .rd_data_count(pre_fifo_rd_data_count),
//   .rd_en(deepfifo_0_fifo_pre_rd_en),
//   .rst(status_reg_0_reset_prefifo_syn),
//   .wr_clk(status_reg_0_clk_prefifo_out),
//   .wr_data_count(pre_fifo_wr_data_count),
//   .wr_en(status_reg_0_pre_fifo_wn),
 
//  .overflow         (overflow),
//  .wr_rst_busy      (wr_rst_busy),
//  .underflow        (underflow),
//  .rd_rst_busy      (rd_rst_busy),
//  .prog_full        (prog_full),

//  .prog_empty       (prog_empty),

//  .sleep            (1'b0),
//  .injectsbiterr    (1'b0),
//  .injectdbiterr    (1'b0),
//  .sbiterr          (),
//  .dbiterr          ()

//);


  status_reg 
  #(
    .PREFIFO_DIN_WIDTH(PREFIFO_DIN_WIDTH),
    .POSTFIFO_DOUT_WIDTH(POSTFIFO_DOUT_WIDTH)
    ) status_reg_0 
        (.DDR3_init_calib_complete(c0_init_calib_complete),
        .DDR3_mmcm_locked(0),
        .addr_r(status_reg_0_addr_r),
        .addr_w(status_reg_0_addr_w),
        .bursts_stored(deepfifo_0_bursts_stored),
     //   .clk_ddr3sys_out(status_reg_0_clk_ddr3sys_out),
        .clk_ddr_sys(clk_ddr_sys_1),
        .clk_postfifo(clk_postfifo_1),
        .clk_postfifo_out(status_reg_0_clk_postfifo_out),
        .clk_prefifo(clk_prefifo_1),
        .clk_prefifo_out(status_reg_0_clk_prefifo_out),
        .clk_r(clk_status_1),
        .clk_w_ddr(c0_ddr4_clk),
        .clka(status_reg_0_clka),
        .clkb(status_reg_0_clkb),
        .data_r(blk_mem_gen_0_doutb),
        .data_w(status_reg_0_data_w),
        .do_from_ram(deepfifo_0_do_from_ram_burst),
        .m_axis_data_tdata(status_reg_0_m_axis_data_TDATA),
        .m_axis_data_tlast(status_reg_0_m_axis_data_TLAST),
        .m_axis_data_tready(status_reg_0_m_axis_data_TREADY),
        .m_axis_data_tvalid(status_reg_0_m_axis_data_TVALID),
        .max_depth(status_reg_0_max_depth),
        .nonbypass_data(status_reg_0_nonbypass_data),
        .post_fifo_din(post_fifo_dout),
        .post_fifo_empty(post_fifo_empty),
        .post_fifo_rn(post_rd_EN),
        .postfifo_wn(deepfifo_0_fifo_post_wr_en),
        .pre_fifo_data_count(pre_fifo_wr_data_count),
        .pre_fifo_dout(status_reg_0_pre_fifo_dout),
        .pre_fifo_full(pre_fifo_full),
        .pre_fifo_wn(status_reg_0_pre_fifo_wn),
        .reset(reset_1),
        .reset_ddr(reset_ddr_1),
        .reset_ddr_syn(status_reg_0_reset_ddr_syn),
        .reset_deepfifo_syn(status_reg_0_reset_deepfifo_syn),
        .reset_postfifo_syn(status_reg_0_reset_postfifo_syn),
        .reset_prefifo_syn(status_reg_0_reset_prefifo_syn),
//        .reset_ddr_axi_syn(status_reg_0_reset_ddr_axi_syn),
        .s_axis_data_tdata(s_axis_data_1_TDATA),
        .s_axis_data_tlast(s_axis_data_1_TLAST),
        .s_axis_data_tready(s_axis_data_1_TREADY),
        .s_axis_data_tvalid(s_axis_data_1_TVALID),
        .status(status_reg_0_status),
        .total_data(status_reg_0_total_data),
        .wea(status_reg_0_wea));
endmodule
