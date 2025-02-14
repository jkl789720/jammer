`include "axi_interface.svh" 

module cpu_rfdc_wrap
#(
    parameter DWIDTH = 128,
    parameter KWIDTH = DWIDTH/8
)
(
input [31:0]AUXRAM_addr,
input AUXRAM_clk,
input [127:0]AUXRAM_din,
output [127:0]AUXRAM_dout,
input AUXRAM_en,
input AUXRAM_rst,
input [15:0]AUXRAM_we,
output [3:0] over_range,
output [3:0] over_voltage,
input [3:0] clear_or,
input [3:0] clear_ov,
input PLUART_rxd,
output PLUART_txd,
input useruart0_rx,
output useruart0_tx,
input useruart1_rx,
output useruart1_tx,

// SPI
output PL_SPI_SCK, 
output PL_SPI_CS_N, 
output PL_SPI_MOSI, 
input PL_SPI_MISO,

output pl_clk0,
output [0:0]pl_resetn0,
output pl_clk1,
output [0:0]pl_resetn1,

`ifndef SIMULATION
// DDR
output DDR4_act_n,
output [16:0]DDR4_adr,
output [1:0]DDR4_ba,
output [0:0]DDR4_bg,
output [0:0]DDR4_ck_c,
output [0:0]DDR4_ck_t,
output [0:0]DDR4_cke,
output [0:0]DDR4_cs_n,
inout [3:0]DDR4_dm_n,
inout [31:0]DDR4_dq,
inout [3:0]DDR4_dqs_c,
inout [3:0]DDR4_dqs_t,
output [0:0]DDR4_odt,
output DDR4_reset_n,

// PCIe
output RST_NVME_0_N,
output RST_NVME_1_N,
input pci0_clk_clk_n,
input pci0_clk_clk_p,
input pci1_clk_clk_n,
input pci1_clk_clk_p,
input [3:0]pcie0_exp_rxn,
input [3:0]pcie0_exp_rxp,
output [3:0]pcie0_exp_txn,
output [3:0]pcie0_exp_txp,
input [3:0]pcie1_exp_rxn,
input [3:0]pcie1_exp_rxp,
output [3:0]pcie1_exp_txn,
output [3:0]pcie1_exp_txp,
output pcie_userclk0,
output pcie_userclk1,
`endif
input c0_sys_clk_n,
input c0_sys_clk_p,
output clk_out100,
output init_calib_complete,
output [5:0]cfg_ltssm_state0,
output [5:0]cfg_ltssm_state1,
output user_lnk_up0,
output user_lnk_up1,

// fast channel
/* input [48:0]S_AXI_HPC1_araddr,
input [1:0]S_AXI_HPC1_arburst,
input [5:0]S_AXI_HPC1_arid,
input [7:0]S_AXI_HPC1_arlen,
input S_AXI_HPC1_arlock,
input [3:0]S_AXI_HPC1_arqos,
output S_AXI_HPC1_arready,
input [2:0]S_AXI_HPC1_arsize,
input S_AXI_HPC1_aruser,
input S_AXI_HPC1_arvalid,
input [48:0]S_AXI_HPC1_awaddr,
input [1:0]S_AXI_HPC1_awburst,
input [5:0]S_AXI_HPC1_awid,
input [7:0]S_AXI_HPC1_awlen,
input S_AXI_HPC1_awlock,
input [3:0]S_AXI_HPC1_awqos,
output S_AXI_HPC1_awready,
input [2:0]S_AXI_HPC1_awsize,
input S_AXI_HPC1_awuser,
input S_AXI_HPC1_awvalid,
output [5:0]S_AXI_HPC1_bid,
input S_AXI_HPC1_bready,
output [1:0]S_AXI_HPC1_bresp,
output S_AXI_HPC1_bvalid,
output [127:0]S_AXI_HPC1_rdata,
output [5:0]S_AXI_HPC1_rid,
output S_AXI_HPC1_rlast,
input S_AXI_HPC1_rready,
output [1:0]S_AXI_HPC1_rresp,
output S_AXI_HPC1_rvalid,
input [127:0]S_AXI_HPC1_wdata,
input S_AXI_HPC1_wlast,
output S_AXI_HPC1_wready,
input [15:0]S_AXI_HPC1_wstrb,
input S_AXI_HPC1_wvalid,
// deepfifo channel
input [35:0]deepfifo_axi_araddr,
input [1:0]deepfifo_axi_arburst,
input [3:0]deepfifo_axi_arcache,
input [7:0]deepfifo_axi_arlen,
input [0:0]deepfifo_axi_arlock,
input [2:0]deepfifo_axi_arprot,
input [3:0]deepfifo_axi_arqos,
output deepfifo_axi_arready,
input [3:0]deepfifo_axi_arregion,
input [2:0]deepfifo_axi_arsize,
input deepfifo_axi_arvalid,
input [35:0]deepfifo_axi_awaddr,
input [1:0]deepfifo_axi_awburst,
input [3:0]deepfifo_axi_awcache,
input [7:0]deepfifo_axi_awlen,
input [0:0]deepfifo_axi_awlock,
input [2:0]deepfifo_axi_awprot,
input [3:0]deepfifo_axi_awqos,
output deepfifo_axi_awready,
input [3:0]deepfifo_axi_awregion,
input [2:0]deepfifo_axi_awsize,
input deepfifo_axi_awvalid,
input deepfifo_axi_bready,
output [1:0]deepfifo_axi_bresp,
output deepfifo_axi_bvalid,
output [511:0]deepfifo_axi_rdata,
output deepfifo_axi_rlast,
input deepfifo_axi_rready,
output [1:0]deepfifo_axi_rresp,
output deepfifo_axi_rvalid,
input [511:0]deepfifo_axi_wdata,
input deepfifo_axi_wlast,
output deepfifo_axi_wready,
input [63:0]deepfifo_axi_wstrb,
input deepfifo_axi_wvalid,
// DDR channel
input [35:0]mem_axi_araddr,
input [1:0]mem_axi_arburst,
input [3:0]mem_axi_arcache,
input [7:0]mem_axi_arlen,
input [0:0]mem_axi_arlock,
input [2:0]mem_axi_arprot,
input [3:0]mem_axi_arqos,
output mem_axi_arready,
input [3:0]mem_axi_arregion,
input [2:0]mem_axi_arsize,
input mem_axi_arvalid,
input [35:0]mem_axi_awaddr,
input [1:0]mem_axi_awburst,
input [3:0]mem_axi_awcache,
input [7:0]mem_axi_awlen,
input [0:0]mem_axi_awlock,
input [2:0]mem_axi_awprot,
input [3:0]mem_axi_awqos,
output mem_axi_awready,
input [3:0]mem_axi_awregion,
input [2:0]mem_axi_awsize,
input mem_axi_awvalid,
input mem_axi_bready,
output [1:0]mem_axi_bresp,
output mem_axi_bvalid,
output [511:0]mem_axi_rdata,
output mem_axi_rlast,
input mem_axi_rready,
output [1:0]mem_axi_rresp,
output mem_axi_rvalid,
input [511:0]mem_axi_wdata,
input mem_axi_wlast,
output mem_axi_wready,
input [63:0]mem_axi_wstrb,
input mem_axi_wvalid,
// config interface
output [39:0]app_lite_araddr,
output [2:0]app_lite_arprot,
input app_lite_arready,
output app_lite_arvalid,
output [39:0]app_lite_awaddr,
output [2:0]app_lite_awprot,
input app_lite_awready,
output app_lite_awvalid,
output app_lite_bready,
input [1:0]app_lite_bresp,
input app_lite_bvalid,
input [31:0]app_lite_rdata,
output app_lite_rready,
input [1:0]app_lite_rresp,
input app_lite_rvalid,
output [31:0]app_lite_wdata,
input app_lite_wready,
output [3:0]app_lite_wstrb,
output app_lite_wvalid, */
axi4.AXI_SLAVE 			mem_axi_S,
axi4.AXI_SLAVE 			HPC1_axi_S,
axi4.AXI_SLAVE 			deepfifo_axi_S,
axi4.AXI_Lite_M			app_lite_S,
// DMA
input           		adc_clk,
input [DWIDTH-1:0]    	adc_data,
input           		adc_valid,
output reg				adc_ready,
output reg				adc_start,
input 					adc_last,

// CFG
output 					bram_clk,
output 					bram_rst,
output 					bram_en,
output [23:0]			bram_addr,
output [3:0]			bram_we,
input [31:0]			bram_rddata,
output [31:0]			bram_wrdata,

// rfdc part
output clk_adc_out,
output [127:0]m00_axis_tdata,
output [127:0]m01_axis_tdata,
output [127:0]m02_axis_tdata,
output [127:0]m03_axis_tdata,
output [127:0]m10_axis_tdata,
output [127:0]m11_axis_tdata,
output [127:0]m12_axis_tdata,
output [127:0]m13_axis_tdata,
output clk_dac_out,
input [255:0]s00_axis_tdata,
input [255:0]s02_axis_tdata,
input [255:0]s10_axis_tdata,
input [255:0]s12_axis_tdata,

// physical ports
input sysref_in_diff_n,
input sysref_in_diff_p,
input dac0_clk_clk_n,
input dac0_clk_clk_p,
input adc0_clk_clk_n,
input adc0_clk_clk_p,
input adc1_clk_clk_n,
input adc1_clk_clk_p,
input SYSREF_PL_N,
input SYSREF_PL_P,
input CLK_DCLK_PL_N,
input CLK_DCLK_PL_P, 
output CLK_DCLK_LOCK,

output clk_adc0,
output clk_adc1,
output clk_dac0,
output clk_dac1,
input vin0_01_v_n,
input vin0_01_v_p,
input vin0_23_v_n,
input vin0_23_v_p,
input vin1_01_v_n,
input vin1_01_v_p,
input vin1_23_v_n,
input vin1_23_v_p,
output vout00_v_n,
output vout00_v_p,
output vout02_v_n,
output vout02_v_p,
output vout10_v_n,
output vout10_v_p,
output vout12_v_n,
output vout12_v_p
);
wire [3:0] app_clear_or;
wire [3:0] app_clear_ov;

// system reset
wire adc_rstn_in;
wire dac_rstn_in;
reg adc_rstn = 0;
reg dac_rstn = 0;
always@(posedge clk_adc_out)adc_rstn <= pl_resetn1;
always@(posedge clk_dac_out)dac_rstn <= pl_resetn1;
assign adc_rstn_in = adc_rstn;
assign dac_rstn_in = dac_rstn;

// SYSREF
wire sysref_pl_in;
IBUFDS sysref_ibuf (
.O(sysref_pl_in),   // 1-bit output: Buffer output
.I(SYSREF_PL_P),   // 1-bit input: Diff_p buffer input (connect directly to top-level port)
.IB(SYSREF_PL_N)  // 1-bit input: Diff_n buffer input (connect directly to top-level port)
);
reg sysref_pl;
always@(posedge clk_adc_out)sysref_pl <= sysref_pl_in;
reg user_sysref_adc;
reg user_sysref_dac;
always @(posedge clk_adc_out)user_sysref_adc <= sysref_pl;
always @(posedge clk_dac_out)user_sysref_dac <= sysref_pl;

// system clock
wire PL_CLK_clk;
IBUFDS plclk_ibuf (
.O(PL_CLK_clk),   // 1-bit output: Buffer output
.I(CLK_DCLK_PL_P),   // 1-bit input: Diff_p buffer input (connect directly to top-level port)
.IB(CLK_DCLK_PL_N)  // 1-bit input: Diff_n buffer input (connect directly to top-level port)
);
wire PL_CLK_bufg;
BUFG plclk_bufg (
.O(PL_CLK_bufg), // 1-bit output: Clock output.
.I(PL_CLK_clk)  // 1-bit input: Clock input.
);
wire user_dclk;
clk_dclk clk_dclk0(
.clk_in1(PL_CLK_bufg),
.reset(0),
.clk_out1(user_dclk),
.locked(locked)
);
assign clk_adc_out = user_dclk;
assign clk_dac_out = user_dclk;
assign CLK_DCLK_LOCK = locked;

  

// ADDA filler signal  
wire m00_axis_tready;
wire m00_axis_tvalid;
wire m01_axis_tready;
wire m01_axis_tvalid;
wire m02_axis_tready;
wire m02_axis_tvalid;
wire m03_axis_tready;
wire m03_axis_tvalid;
wire m10_axis_tready;
wire m10_axis_tvalid;
wire m11_axis_tready;
wire m11_axis_tvalid;
wire m12_axis_tready;
wire m12_axis_tvalid;
wire m13_axis_tready;
wire m13_axis_tvalid;
wire s00_axis_tready;
wire s00_axis_tvalid;
wire s02_axis_tready;
wire s02_axis_tvalid;
wire s10_axis_tready;
wire s10_axis_tvalid;
wire s12_axis_tready;
wire s12_axis_tvalid;
assign m00_axis_tready = 1;
assign m01_axis_tready = 1;
assign m02_axis_tready = 1;
assign m03_axis_tready = 1;
assign m10_axis_tready = 1;
assign m11_axis_tready = 1;
assign m12_axis_tready = 1;
assign m13_axis_tready = 1;
assign s00_axis_tvalid = 1;
assign s02_axis_tvalid = 1;
assign s10_axis_tvalid = 1;
assign s12_axis_tvalid = 1;

// SPI interface
wire SPI0_io0_i;
wire SPI0_io0_io;
wire SPI0_io0_o;
wire SPI0_io0_t;
wire SPI0_io1_i;
wire SPI0_io1_io;
wire SPI0_io1_o;
wire SPI0_io1_t;
wire SPI0_sck_i;
wire SPI0_sck_io;
wire SPI0_sck_o;
wire SPI0_sck_t;
wire SPI0_ss_i;
wire SPI0_ss_io;
wire SPI0_ss_o;
wire SPI0_ss_t;
assign PL_SPI_SCK = SPI0_sck_o;
assign PL_SPI_CS_N = SPI0_ss_o;
assign PL_SPI_MOSI = SPI0_io0_o;
assign SPI0_io1_i = PL_SPI_MISO;

wire [127:0]M_DMA_AXIS_tdata;
wire [15:0]M_DMA_AXIS_tkeep;
wire M_DMA_AXIS_tlast;
wire M_DMA_AXIS_tready;
wire M_DMA_AXIS_tvalid;
wire [127:0]S_DMA_AXIS_tdata;
wire [15:0]S_DMA_AXIS_tkeep;
wire S_DMA_AXIS_tlast;
wire S_DMA_AXIS_tready;
wire S_DMA_AXIS_tvalid;
wire [31:0]app_param0;
wire [31:0]app_param1;
wire [31:0]app_param2;
wire [31:0]app_param3;
wire [31:0]app_param4;
wire [31:0]app_param5;
wire [31:0]app_param6;
wire [31:0]app_param7;
wire [31:0]app_status0;
wire [31:0]app_status1;
wire [31:0]app_status2;
wire [31:0]app_status3;
wire [31:0]app_status4;
wire [31:0]app_status5;
wire [31:0]app_status6;
wire [31:0]app_status7;
wire [3:0]axcache;
wire [2:0]axprot;
wire mm2s_resetn_out;
wire s2mm_resetn_out;
reg ddr_rst;
always@(posedge pl_clk1)ddr_rst <= ~pl_resetn1;
wire [4:0]adc0_dsa_rts_converter01_dsa_code;
wire [4:0]adc0_dsa_rts_converter23_dsa_code;
wire adc0_dsa_rts_dsa_update;
wire adc0_rts_converter01_clear_or;
wire adc0_rts_converter01_clear_ov;
wire adc0_rts_converter01_cm_over_voltage;
wire adc0_rts_converter01_cm_under_voltage;
wire adc0_rts_converter01_over_range;
wire adc0_rts_converter01_over_threshold1;
wire adc0_rts_converter01_over_threshold2;
wire adc0_rts_converter01_over_voltage;
wire adc0_rts_converter0_pl_event;
wire adc0_rts_converter1_pl_event;
wire adc0_rts_converter23_clear_or;
wire adc0_rts_converter23_clear_ov;
wire adc0_rts_converter23_cm_over_voltage;
wire adc0_rts_converter23_cm_under_voltage;
wire adc0_rts_converter23_over_range;
wire adc0_rts_converter23_over_threshold1;
wire adc0_rts_converter23_over_threshold2;
wire adc0_rts_converter23_over_voltage;
wire adc0_rts_converter2_pl_event;
wire adc0_rts_converter3_pl_event;
wire adc0_rts_sync_out;
wire adc0_rts_sysref_gate;
wire [4:0]adc1_dsa_rts_converter01_dsa_code;
wire [4:0]adc1_dsa_rts_converter23_dsa_code;
wire adc1_dsa_rts_dsa_update;
wire adc1_rts_converter01_clear_or;
wire adc1_rts_converter01_clear_ov;
wire adc1_rts_converter01_cm_over_voltage;
wire adc1_rts_converter01_cm_under_voltage;
wire adc1_rts_converter01_over_range;
wire adc1_rts_converter01_over_threshold1;
wire adc1_rts_converter01_over_threshold2;
wire adc1_rts_converter01_over_voltage;
wire adc1_rts_converter0_pl_event;
wire adc1_rts_converter1_pl_event;
wire adc1_rts_converter23_clear_or;
wire adc1_rts_converter23_clear_ov;
wire adc1_rts_converter23_cm_over_voltage;
wire adc1_rts_converter23_cm_under_voltage;
wire adc1_rts_converter23_over_range;
wire adc1_rts_converter23_over_threshold1;
wire adc1_rts_converter23_over_threshold2;
wire adc1_rts_converter23_over_voltage;
wire adc1_rts_converter2_pl_event;
wire adc1_rts_converter3_pl_event;
wire adc1_rts_sync_out;
wire adc1_rts_sysref_gate;
assign over_range[0] = adc0_rts_converter01_over_range;
assign over_range[1] = adc0_rts_converter23_over_range;
assign over_range[2] = adc1_rts_converter01_over_range;
assign over_range[3] = adc1_rts_converter23_over_range;
assign adc0_rts_converter01_clear_or = clear_or[0] | app_clear_or[0];
assign adc0_rts_converter23_clear_or = clear_or[1] | app_clear_or[1];
assign adc1_rts_converter01_clear_or = clear_or[2] | app_clear_or[2];
assign adc1_rts_converter23_clear_or = clear_or[3] | app_clear_or[3];
assign over_voltage[0] = adc0_rts_converter01_over_voltage;
assign over_voltage[1] = adc0_rts_converter23_over_voltage;
assign over_voltage[2] = adc1_rts_converter01_over_voltage;
assign over_voltage[3] = adc1_rts_converter23_over_voltage;
assign adc0_rts_converter01_clear_ov = clear_ov[0] | app_clear_ov[0];
assign adc0_rts_converter23_clear_ov = clear_ov[1] | app_clear_ov[1];
assign adc1_rts_converter01_clear_ov = clear_ov[2] | app_clear_ov[2];
assign adc1_rts_converter23_clear_ov = clear_ov[3] | app_clear_ov[3];
assign adc0_dsa_rts_dsa_update = 0;
assign adc1_dsa_rts_dsa_update = 0;

assign app_status4 = {24'h0, over_voltage, over_range};
assign app_clear_or = app_param4[3:0];
assign app_clear_ov = app_param4[7:4];


`ifndef SIMULATION
cpu_subsys cpu_subsys_EP0(
.adc0_dsa_rts_converter01_dsa_code(adc0_dsa_rts_converter01_dsa_code),
.adc0_dsa_rts_converter23_dsa_code(adc0_dsa_rts_converter23_dsa_code),
.adc0_dsa_rts_dsa_update(adc0_dsa_rts_dsa_update),
.adc0_rts_converter01_clear_or(adc0_rts_converter01_clear_or),
.adc0_rts_converter01_clear_ov(adc0_rts_converter01_clear_ov),
.adc0_rts_converter01_cm_over_voltage(adc0_rts_converter01_cm_over_voltage),
.adc0_rts_converter01_cm_under_voltage(adc0_rts_converter01_cm_under_voltage),
.adc0_rts_converter01_over_range(adc0_rts_converter01_over_range),
.adc0_rts_converter01_over_threshold1(adc0_rts_converter01_over_threshold1),
.adc0_rts_converter01_over_threshold2(adc0_rts_converter01_over_threshold2),
.adc0_rts_converter01_over_voltage(adc0_rts_converter01_over_voltage),
.adc0_rts_converter0_pl_event(adc0_rts_converter0_pl_event),
.adc0_rts_converter1_pl_event(adc0_rts_converter1_pl_event),
.adc0_rts_converter23_clear_or(adc0_rts_converter23_clear_or),
.adc0_rts_converter23_clear_ov(adc0_rts_converter23_clear_ov),
.adc0_rts_converter23_cm_over_voltage(adc0_rts_converter23_cm_over_voltage),
.adc0_rts_converter23_cm_under_voltage(adc0_rts_converter23_cm_under_voltage),
.adc0_rts_converter23_over_range(adc0_rts_converter23_over_range),
.adc0_rts_converter23_over_threshold1(adc0_rts_converter23_over_threshold1),
.adc0_rts_converter23_over_threshold2(adc0_rts_converter23_over_threshold2),
.adc0_rts_converter23_over_voltage(adc0_rts_converter23_over_voltage),
.adc0_rts_converter2_pl_event(adc0_rts_converter2_pl_event),
.adc0_rts_converter3_pl_event(adc0_rts_converter3_pl_event),
.adc0_rts_sync_out(adc0_rts_sync_out),
.adc0_rts_sysref_gate(adc0_rts_sysref_gate),
.adc1_dsa_rts_converter01_dsa_code(adc1_dsa_rts_converter01_dsa_code),
.adc1_dsa_rts_converter23_dsa_code(adc1_dsa_rts_converter23_dsa_code),
.adc1_dsa_rts_dsa_update(adc1_dsa_rts_dsa_update),
.adc1_rts_converter01_clear_or(adc1_rts_converter01_clear_or),
.adc1_rts_converter01_clear_ov(adc1_rts_converter01_clear_ov),
.adc1_rts_converter01_cm_over_voltage(adc1_rts_converter01_cm_over_voltage),
.adc1_rts_converter01_cm_under_voltage(adc1_rts_converter01_cm_under_voltage),
.adc1_rts_converter01_over_range(adc1_rts_converter01_over_range),
.adc1_rts_converter01_over_threshold1(adc1_rts_converter01_over_threshold1),
.adc1_rts_converter01_over_threshold2(adc1_rts_converter01_over_threshold2),
.adc1_rts_converter01_over_voltage(adc1_rts_converter01_over_voltage),
.adc1_rts_converter0_pl_event(adc1_rts_converter0_pl_event),
.adc1_rts_converter1_pl_event(adc1_rts_converter1_pl_event),
.adc1_rts_converter23_clear_or(adc1_rts_converter23_clear_or),
.adc1_rts_converter23_clear_ov(adc1_rts_converter23_clear_ov),
.adc1_rts_converter23_cm_over_voltage(adc1_rts_converter23_cm_over_voltage),
.adc1_rts_converter23_cm_under_voltage(adc1_rts_converter23_cm_under_voltage),
.adc1_rts_converter23_over_range(adc1_rts_converter23_over_range),
.adc1_rts_converter23_over_threshold1(adc1_rts_converter23_over_threshold1),
.adc1_rts_converter23_over_threshold2(adc1_rts_converter23_over_threshold2),
.adc1_rts_converter23_over_voltage(adc1_rts_converter23_over_voltage),
.adc1_rts_converter2_pl_event(adc1_rts_converter2_pl_event),
.adc1_rts_converter3_pl_event(adc1_rts_converter3_pl_event),
.adc1_rts_sync_out(adc1_rts_sync_out),
.adc1_rts_sysref_gate(adc1_rts_sysref_gate),

.AUXRAM_addr(AUXRAM_addr),
.AUXRAM_clk(AUXRAM_clk),
.AUXRAM_din(AUXRAM_din),
.AUXRAM_dout(AUXRAM_dout),
.AUXRAM_en(AUXRAM_en),
.AUXRAM_rst(AUXRAM_rst),
.AUXRAM_we(AUXRAM_we),
.PLUART_rxd(PLUART_rxd),
.PLUART_txd(PLUART_txd),

.DDR4_act_n(DDR4_act_n),    //output 
.DDR4_adr(DDR4_adr),    //output [16:0]
.DDR4_ba(DDR4_ba),    //output [1:0]
.DDR4_bg(DDR4_bg),    //output [0:0]
.DDR4_ck_c(DDR4_ck_c),    //output [0:0]
.DDR4_ck_t(DDR4_ck_t),    //output [0:0]
.DDR4_cke(DDR4_cke),    //output [0:0]
.DDR4_cs_n(DDR4_cs_n),    //output [0:0]
.DDR4_dm_n(DDR4_dm_n),    //inout [3:0]
.DDR4_dq(DDR4_dq),    //inout [31:0]
.DDR4_dqs_c(DDR4_dqs_c),    //inout [3:0]
.DDR4_dqs_t(DDR4_dqs_t),    //inout [3:0]
.DDR4_odt(DDR4_odt),    //output [0:0]
.DDR4_reset_n(DDR4_reset_n),    //output 

.RST_NVME_0_N(RST_NVME_0_N),
.RST_NVME_1_N(RST_NVME_1_N),
.pci0_clk_clk_n(pci0_clk_clk_n),
.pci0_clk_clk_p(pci0_clk_clk_p),
.pci1_clk_clk_n(pci1_clk_clk_n),
.pci1_clk_clk_p(pci1_clk_clk_p),
.pcie0_exp_rxn(pcie0_exp_rxn),
.pcie0_exp_rxp(pcie0_exp_rxp),
.pcie0_exp_txn(pcie0_exp_txn),
.pcie0_exp_txp(pcie0_exp_txp),
.pcie1_exp_rxn(pcie1_exp_rxn),
.pcie1_exp_rxp(pcie1_exp_rxp),
.pcie1_exp_txn(pcie1_exp_txn),
.pcie1_exp_txp(pcie1_exp_txp),
.pcie_userclk0(pcie_userclk0),
.pcie_userclk1(pcie_userclk1),
.user_lnk_up0(user_lnk_up0),
.user_lnk_up1(user_lnk_up1),
.cfg_ltssm_state0(cfg_ltssm_state0),
.cfg_ltssm_state1(cfg_ltssm_state1),

.M_DMA_AXIS_tdata(M_DMA_AXIS_tdata),    //output [127:0]
.M_DMA_AXIS_tkeep(M_DMA_AXIS_tkeep),    //output [15:0]
.M_DMA_AXIS_tlast(M_DMA_AXIS_tlast),    //output 
.M_DMA_AXIS_tready(M_DMA_AXIS_tready),    //input 
.M_DMA_AXIS_tvalid(M_DMA_AXIS_tvalid),    //output 
.SPI0_io0_i(SPI0_io0_i),    //input 
.SPI0_io0_o(SPI0_io0_o),    //output 
.SPI0_io0_t(SPI0_io0_t),    //output 
.SPI0_io1_i(SPI0_io1_i),    //input 
.SPI0_io1_o(SPI0_io1_o),    //output 
.SPI0_io1_t(SPI0_io1_t),    //output 
.SPI0_sck_i(SPI0_sck_i),    //input 
.SPI0_sck_o(SPI0_sck_o),    //output 
.SPI0_sck_t(SPI0_sck_t),    //output 
.SPI0_ss_i(SPI0_ss_i),    //input 
.SPI0_ss_o(SPI0_ss_o),    //output 
.SPI0_ss_t(SPI0_ss_t),    //output 
.S_AXI_HPC1_araddr(HPC1_axi_S.axi_araddr),    //input [48:0]
.S_AXI_HPC1_arburst(HPC1_axi_S.axi_arburst),    //input [1:0]
.S_AXI_HPC1_arid(HPC1_axi_S.axi_arid),    //input [5:0]
.S_AXI_HPC1_arlen(HPC1_axi_S.axi_arlen),    //input [7:0]
.S_AXI_HPC1_arlock(HPC1_axi_S.axi_arlock),    //input 
.S_AXI_HPC1_arqos(HPC1_axi_S.axi_arqos),    //input [3:0]
.S_AXI_HPC1_arready(HPC1_axi_S.axi_arready),    //output 
.S_AXI_HPC1_arsize(HPC1_axi_S.axi_arsize),    //input [2:0]
.S_AXI_HPC1_aruser(HPC1_axi_S.axi_aruser),    //input 
.S_AXI_HPC1_arvalid(HPC1_axi_S.axi_arvalid),    //input 
.S_AXI_HPC1_awaddr(HPC1_axi_S.axi_awaddr),    //input [48:0]
.S_AXI_HPC1_awburst(HPC1_axi_S.axi_awburst),    //input [1:0]
.S_AXI_HPC1_awid(HPC1_axi_S.axi_awid),    //input [5:0]
.S_AXI_HPC1_awlen(HPC1_axi_S.axi_awlen),    //input [7:0]
.S_AXI_HPC1_awlock(HPC1_axi_S.axi_awlock),    //input 
.S_AXI_HPC1_awqos(HPC1_axi_S.axi_awqos),    //input [3:0]
.S_AXI_HPC1_awready(HPC1_axi_S.axi_awready),    //output 
.S_AXI_HPC1_awsize(HPC1_axi_S.axi_awsize),    //input [2:0]
.S_AXI_HPC1_awuser(HPC1_axi_S.axi_awuser),    //input 
.S_AXI_HPC1_awvalid(HPC1_axi_S.axi_awvalid),    //input 
.S_AXI_HPC1_bid(HPC1_axi_S.axi_bid),    //output [5:0]
.S_AXI_HPC1_bready(HPC1_axi_S.axi_bready),    //input 
.S_AXI_HPC1_bresp(HPC1_axi_S.axi_bresp),    //output [1:0]
.S_AXI_HPC1_bvalid(HPC1_axi_S.axi_bvalid),    //output 
.S_AXI_HPC1_rdata(HPC1_axi_S.axi_rdata),    //output [127:0]
.S_AXI_HPC1_rid(HPC1_axi_S.axi_rid),    //output [5:0]
.S_AXI_HPC1_rlast(HPC1_axi_S.axi_rlast),    //output 
.S_AXI_HPC1_rready(HPC1_axi_S.axi_rready),    //input 
.S_AXI_HPC1_rresp(HPC1_axi_S.axi_rresp),    //output [1:0]
.S_AXI_HPC1_rvalid(HPC1_axi_S.axi_rvalid),    //output 
.S_AXI_HPC1_wdata(HPC1_axi_S.axi_wdata),    //input [127:0]
.S_AXI_HPC1_wlast(HPC1_axi_S.axi_wlast),    //input 
.S_AXI_HPC1_wready(HPC1_axi_S.axi_wready),    //output 
.S_AXI_HPC1_wstrb(HPC1_axi_S.axi_wstrb),    //input [15:0]
.S_AXI_HPC1_wvalid(HPC1_axi_S.axi_wvalid),    //input 
.S_DMA_AXIS_tdata(S_DMA_AXIS_tdata),    //input [127:0]
.S_DMA_AXIS_tkeep(S_DMA_AXIS_tkeep),    //input [15:0]
.S_DMA_AXIS_tlast(S_DMA_AXIS_tlast),    //input 
.S_DMA_AXIS_tready(S_DMA_AXIS_tready),    //output 
.S_DMA_AXIS_tvalid(S_DMA_AXIS_tvalid),    //input 
.adc0_clk_clk_n(adc0_clk_clk_n),    //input 
.adc0_clk_clk_p(adc0_clk_clk_p),    //input 
.adc1_clk_clk_n(adc1_clk_clk_n),    //input 
.adc1_clk_clk_p(adc1_clk_clk_p),    //input 
.adc_clk(clk_adc_out),    //input 
.adc_rstn(adc_rstn_in),    //input 
.app_lite_araddr(app_lite_S.axi_araddr),    //output [39:0]
.app_lite_arprot(app_lite_S.axi_arprot),    //output [2:0]
.app_lite_arready(app_lite_S.axi_arready),    //input 
.app_lite_arvalid(app_lite_S.axi_arvalid),    //output 
.app_lite_awaddr(app_lite_S.axi_awaddr),    //output [39:0]
.app_lite_awprot(app_lite_S.axi_awprot),    //output [2:0]
.app_lite_awready(app_lite_S.axi_awready),    //input 
.app_lite_awvalid(app_lite_S.axi_awvalid),    //output 
.app_lite_bready(app_lite_S.axi_bready),    //output 
.app_lite_bresp(app_lite_S.axi_bresp),    //input [1:0]
.app_lite_bvalid(app_lite_S.axi_bvalid),    //input 
.app_lite_rdata(app_lite_S.axi_rdata),    //input [31:0]
.app_lite_rready(app_lite_S.axi_rready),    //output 
.app_lite_rresp(app_lite_S.axi_rresp),    //input [1:0]
.app_lite_rvalid(app_lite_S.axi_rvalid),    //input 
.app_lite_wdata(app_lite_S.axi_wdata),    //output [31:0]
.app_lite_wready(app_lite_S.axi_wready),    //input 
.app_lite_wstrb(app_lite_S.axi_wstrb),    //output [3:0]
.app_lite_wvalid(app_lite_S.axi_wvalid),    //output 
.app_param0(app_param0),    //output [31:0]
.app_param1(app_param1),    //output [31:0]
.app_param2(app_param2),    //output [31:0]
.app_param3(app_param3),    //output [31:0]
.app_param4(app_param4),    //output [31:0]
.app_param5(app_param5),    //output [31:0]
.app_param6(app_param6),    //output [31:0]
.app_param7(app_param7),    //output [31:0]
.app_status0(app_status0),    //input [31:0]
.app_status1(app_status1),    //input [31:0]
.app_status2(app_status2),    //input [31:0]
.app_status3(app_status3),    //input [31:0]
.app_status4(app_status4),    //input [31:0]
.app_status5(app_status5),    //input [31:0]
.app_status6(app_status6),    //input [31:0]
.app_status7(app_status7),    //input [31:0]
.axcache(axcache),    //input [3:0]
.axprot(axprot),    //input [2:0]
.bram_addr(bram_addr),    //output [23:0]
.bram_clk(bram_clk),    //output 
.bram_en(bram_en),    //output 
.bram_rddata(bram_rddata),    //input [31:0]
.bram_rst(bram_rst),    //output 
.bram_we(bram_we),    //output [3:0]
.bram_wrdata(bram_wrdata),    //output [31:0]
.c0_sys_clk_n(c0_sys_clk_n),    //input 
.c0_sys_clk_p(c0_sys_clk_p),    //input 
.clk_out100(clk_out100),    //output 
.dac0_clk_clk_n(dac0_clk_clk_n),    //input 
.dac0_clk_clk_p(dac0_clk_clk_p),    //input 
.dac_clk(clk_dac_out),    //input 
.dac_rstn(dac_rstn_in),    //input 
.ddr_rst(ddr_rst),    //input 
.init_calib_complete(init_calib_complete),    //output 
.m00_axis_tdata(m00_axis_tdata),    //output [127:0]
.m00_axis_tready(m00_axis_tready),    //input 
.m00_axis_tvalid(m00_axis_tvalid),    //output 
.m01_axis_tdata(m01_axis_tdata),    //output [127:0]
.m01_axis_tready(m01_axis_tready),    //input 
.m01_axis_tvalid(m01_axis_tvalid),    //output 
.m02_axis_tdata(m02_axis_tdata),    //output [127:0]
.m02_axis_tready(m02_axis_tready),    //input 
.m02_axis_tvalid(m02_axis_tvalid),    //output 
.m03_axis_tdata(m03_axis_tdata),    //output [127:0]
.m03_axis_tready(m03_axis_tready),    //input 
.m03_axis_tvalid(m03_axis_tvalid),    //output 
.m10_axis_tdata(m10_axis_tdata),    //output [127:0]
.m10_axis_tready(m10_axis_tready),    //input 
.m10_axis_tvalid(m10_axis_tvalid),    //output 
.m11_axis_tdata(m11_axis_tdata),    //output [127:0]
.m11_axis_tready(m11_axis_tready),    //input 
.m11_axis_tvalid(m11_axis_tvalid),    //output 
.m12_axis_tdata(m12_axis_tdata),    //output [127:0]
.m12_axis_tready(m12_axis_tready),    //input 
.m12_axis_tvalid(m12_axis_tvalid),    //output 
.m13_axis_tdata(m13_axis_tdata),    //output [127:0]
.m13_axis_tready(m13_axis_tready),    //input 
.m13_axis_tvalid(m13_axis_tvalid),    //output 
.mem_axi_araddr(mem_axi_S.axi_araddr),    //input [35:0]
.mem_axi_arburst(mem_axi_S.axi_arburst),    //input [1:0]
.mem_axi_arcache(mem_axi_S.axi_arcache),    //input [3:0]
.mem_axi_arlen(mem_axi_S.axi_arlen),    //input [7:0]
.mem_axi_arlock(mem_axi_S.axi_arlock),    //input [0:0]
.mem_axi_arprot(mem_axi_S.axi_arprot),    //input [2:0]
.mem_axi_arqos(mem_axi_S.axi_arqos),    //input [3:0]
.mem_axi_arready(mem_axi_S.axi_arready),    //output 
.mem_axi_arregion(mem_axi_S.axi_arregion),    //input [3:0]
.mem_axi_arsize(mem_axi_S.axi_arsize),    //input [2:0]
.mem_axi_arvalid(mem_axi_S.axi_arvalid),    //input 
.mem_axi_awaddr(mem_axi_S.axi_awaddr),    //input [35:0]
.mem_axi_awburst(mem_axi_S.axi_awburst),    //input [1:0]
.mem_axi_awcache(mem_axi_S.axi_awcache),    //input [3:0]
.mem_axi_awlen(mem_axi_S.axi_awlen),    //input [7:0]
.mem_axi_awlock(mem_axi_S.axi_awlock),    //input [0:0]
.mem_axi_awprot(mem_axi_S.axi_awprot),    //input [2:0]
.mem_axi_awqos(mem_axi_S.axi_awqos),    //input [3:0]
.mem_axi_awready(mem_axi_S.axi_awready),    //output 
.mem_axi_awregion(mem_axi_S.axi_awregion),    //input [3:0]
.mem_axi_awsize(mem_axi_S.axi_awsize),    //input [2:0]
.mem_axi_awvalid(mem_axi_S.axi_awvalid),    //input 
.mem_axi_bready(mem_axi_S.axi_bready),    //input 
.mem_axi_bresp(mem_axi_S.axi_bresp),    //output [1:0]
.mem_axi_bvalid(mem_axi_S.axi_bvalid),    //output 
.mem_axi_rdata(mem_axi_S.axi_rdata),    //output [511:0]
.mem_axi_rlast(mem_axi_S.axi_rlast),    //output 
.mem_axi_rready(mem_axi_S.axi_rready),    //input 
.mem_axi_rresp(mem_axi_S.axi_rresp),    //output [1:0]
.mem_axi_rvalid(mem_axi_S.axi_rvalid),    //output 
.mem_axi_wdata(mem_axi_S.axi_wdata),    //input [511:0]
.mem_axi_wlast(mem_axi_S.axi_wlast),    //input 
.mem_axi_wready(mem_axi_S.axi_wready),    //output 
.mem_axi_wstrb(mem_axi_S.axi_wstrb),    //input [63:0]
.mem_axi_wvalid(mem_axi_S.axi_wvalid),    //input 
.deepfifo_axi_araddr(deepfifo_axi_S.axi_araddr),    //input [35:0]
.deepfifo_axi_arburst(deepfifo_axi_S.axi_arburst),    //input [1:0]
.deepfifo_axi_arcache(deepfifo_axi_S.axi_arcache),    //input [3:0]
.deepfifo_axi_arlen(deepfifo_axi_S.axi_arlen),    //input [7:0]
.deepfifo_axi_arlock(deepfifo_axi_S.axi_arlock),    //input [0:0]
.deepfifo_axi_arprot(deepfifo_axi_S.axi_arprot),    //input [2:0]
.deepfifo_axi_arqos(deepfifo_axi_S.axi_arqos),    //input [3:0]
.deepfifo_axi_arready(deepfifo_axi_S.axi_arready),    //output 
.deepfifo_axi_arregion(deepfifo_axi_S.axi_arregion),    //input [3:0]
.deepfifo_axi_arsize(deepfifo_axi_S.axi_arsize),    //input [2:0]
.deepfifo_axi_arvalid(deepfifo_axi_S.axi_arvalid),    //input 
.deepfifo_axi_awaddr(deepfifo_axi_S.axi_awaddr),    //input [35:0]
.deepfifo_axi_awburst(deepfifo_axi_S.axi_awburst),    //input [1:0]
.deepfifo_axi_awcache(deepfifo_axi_S.axi_awcache),    //input [3:0]
.deepfifo_axi_awlen(deepfifo_axi_S.axi_awlen),    //input [7:0]
.deepfifo_axi_awlock(deepfifo_axi_S.axi_awlock),    //input [0:0]
.deepfifo_axi_awprot(deepfifo_axi_S.axi_awprot),    //input [2:0]
.deepfifo_axi_awqos(deepfifo_axi_S.axi_awqos),    //input [3:0]
.deepfifo_axi_awready(deepfifo_axi_S.axi_awready),    //output 
.deepfifo_axi_awregion(deepfifo_axi_S.axi_awregion),    //input [3:0]
.deepfifo_axi_awsize(deepfifo_axi_S.axi_awsize),    //input [2:0]
.deepfifo_axi_awvalid(deepfifo_axi_S.axi_awvalid),    //input 
.deepfifo_axi_bready(deepfifo_axi_S.axi_bready),    //input 
.deepfifo_axi_bresp(deepfifo_axi_S.axi_bresp),    //output [1:0]
.deepfifo_axi_bvalid(deepfifo_axi_S.axi_bvalid),    //output 
.deepfifo_axi_rdata(deepfifo_axi_S.axi_rdata),    //output [511:0]
.deepfifo_axi_rlast(deepfifo_axi_S.axi_rlast),    //output 
.deepfifo_axi_rready(deepfifo_axi_S.axi_rready),    //input 
.deepfifo_axi_rresp(deepfifo_axi_S.axi_rresp),    //output [1:0]
.deepfifo_axi_rvalid(deepfifo_axi_S.axi_rvalid),    //output 
.deepfifo_axi_wdata(deepfifo_axi_S.axi_wdata),    //input [511:0]
.deepfifo_axi_wlast(deepfifo_axi_S.axi_wlast),    //input 
.deepfifo_axi_wready(deepfifo_axi_S.axi_wready),    //output 
.deepfifo_axi_wstrb(deepfifo_axi_S.axi_wstrb),    //input [63:0]
.deepfifo_axi_wvalid(deepfifo_axi_S.axi_wvalid),    //input 
.mm2s_resetn_out(mm2s_resetn_out),    //output 
.pl_clk0(pl_clk0),    //output 
.pl_resetn0(pl_resetn0),    //output [0:0]
.pl_clk1(pl_clk1),    //output 
.pl_resetn1(pl_resetn1),    //output [0:0]
.s00_axis_tdata(s00_axis_tdata),    //input [255:0]
.s00_axis_tready(s00_axis_tready),    //output 
.s00_axis_tvalid(s00_axis_tvalid),    //input 
.s02_axis_tdata(s02_axis_tdata),    //input [255:0]
.s02_axis_tready(s02_axis_tready),    //output 
.s02_axis_tvalid(s02_axis_tvalid),    //input 
.s10_axis_tdata(s10_axis_tdata),    //input [255:0]
.s10_axis_tready(s10_axis_tready),    //output 
.s10_axis_tvalid(s10_axis_tvalid),    //input 
.s12_axis_tdata(s12_axis_tdata),    //input [255:0]
.s12_axis_tready(s12_axis_tready),    //output 
.s12_axis_tvalid(s12_axis_tvalid),    //input 
.s2mm_resetn_out(s2mm_resetn_out),    //output 
.sysref_in_diff_n(sysref_in_diff_n),    //input 
.sysref_in_diff_p(sysref_in_diff_p),    //input 
.user_sysref_adc(user_sysref_adc),    //input 
.user_sysref_dac(user_sysref_dac),    //input 
.useruart0_rx(useruart0_rx),    //input 
.useruart0_tx(useruart0_tx),    //output
.useruart1_rx(useruart1_rx),    //input 
.useruart1_tx(useruart1_tx),    //output
.clk_adc0(clk_adc0),       //output
.clk_adc1(clk_adc1),       //output
.clk_dac0(clk_dac0),       //output
.clk_dac1(clk_dac1),       //output
.vin0_01_v_n(vin0_01_v_n),    //input 
.vin0_01_v_p(vin0_01_v_p),    //input 
.vin0_23_v_n(vin0_23_v_n),    //input 
.vin0_23_v_p(vin0_23_v_p),    //input 
.vin1_01_v_n(vin1_01_v_n),    //input 
.vin1_01_v_p(vin1_01_v_p),    //input 
.vin1_23_v_n(vin1_23_v_n),    //input 
.vin1_23_v_p(vin1_23_v_p),    //input 
.vout00_v_n(vout00_v_n),    //output 
.vout00_v_p(vout00_v_p),    //output 
.vout02_v_n(vout02_v_n),    //output 
.vout02_v_p(vout02_v_p),    //output 
.vout10_v_n(vout10_v_n),    //output 
.vout10_v_p(vout10_v_p),    //output 
.vout12_v_n(vout12_v_n),    //output 
.vout12_v_p(vout12_v_p)    //output 
);

`else
reg clk100;
always begin
	clk100 = 0;
	#5;
	clk100 = 1;
	#5;
end
assign M_DMA_AXIS_tdata = 0;
assign M_DMA_AXIS_tkeep = 0;
assign M_DMA_AXIS_tlast = 0;
assign M_DMA_AXIS_tvalid = 0;
assign S_DMA_AXIS_tready = 0;
assign bram_addr = 0;
assign bram_clk = clk100;
assign bram_en = 0;
assign bram_rst = 0;
assign bram_we = 0;
assign bram_wrdata = 0;
assign mm2s_resetn_out = 1;
assign pl_clk0 = clk100;
assign pl_resetn0 = 1;
assign s2mm_resetn_out = 1;

blkmem1024x128 blkmem1024x128_ep (
  .s_aclk(pl_clk0),                // input wire s_aclk
  .s_aresetn(pl_resetn0),          // input wire s_aresetn
  .s_axi_awid(S_AXI_HPC1_awid),        // input wire [5 : 0] s_axi_awid
  .s_axi_awaddr(S_AXI_HPC1_awaddr&48'h03FFF),    // input wire [31 : 0] s_axi_awaddr
  .s_axi_awlen(S_AXI_HPC1_awlen),      // input wire [7 : 0] s_axi_awlen
  .s_axi_awsize(S_AXI_HPC1_awsize),    // input wire [2 : 0] s_axi_awsize
  .s_axi_awburst(S_AXI_HPC1_awburst),  // input wire [1 : 0] s_axi_awburst
  .s_axi_awvalid(S_AXI_HPC1_awvalid),  // input wire s_axi_awvalid
  .s_axi_awready(S_AXI_HPC1_awready),  // output wire s_axi_awready
  .s_axi_wdata(S_AXI_HPC1_wdata),      // input wire [127 : 0] s_axi_wdata
  .s_axi_wstrb(S_AXI_HPC1_wstrb),      // input wire [15 : 0] s_axi_wstrb
  .s_axi_wlast(S_AXI_HPC1_wlast),      // input wire s_axi_wlast
  .s_axi_wvalid(S_AXI_HPC1_wvalid),    // input wire s_axi_wvalid
  .s_axi_wready(S_AXI_HPC1_wready),    // output wire s_axi_wready
  .s_axi_bid(S_AXI_HPC1_bid),          // output wire [5 : 0] s_axi_bid
  .s_axi_bresp(S_AXI_HPC1_bresp),      // output wire [1 : 0] s_axi_bresp
  .s_axi_bvalid(S_AXI_HPC1_bvalid),    // output wire s_axi_bvalid
  .s_axi_bready(S_AXI_HPC1_bready),    // input wire s_axi_bready
  .s_axi_arid(S_AXI_HPC1_arid),        // input wire [5 : 0] s_axi_arid
  .s_axi_araddr(S_AXI_HPC1_araddr&48'h03FFF),    // input wire [31 : 0] s_axi_araddr
  .s_axi_arlen(S_AXI_HPC1_arlen),      // input wire [7 : 0] s_axi_arlen
  .s_axi_arsize(S_AXI_HPC1_arsize),    // input wire [2 : 0] s_axi_arsize
  .s_axi_arburst(S_AXI_HPC1_arburst),  // input wire [1 : 0] s_axi_arburst
  .s_axi_arvalid(S_AXI_HPC1_arvalid),  // input wire s_axi_arvalid
  .s_axi_arready(S_AXI_HPC1_arready),  // output wire s_axi_arready
  .s_axi_rid(S_AXI_HPC1_rid),          // output wire [5 : 0] s_axi_rid
  .s_axi_rdata(S_AXI_HPC1_rdata),      // output wire [127 : 0] s_axi_rdata
  .s_axi_rresp(S_AXI_HPC1_rresp),      // output wire [1 : 0] s_axi_rresp
  .s_axi_rlast(S_AXI_HPC1_rlast),      // output wire s_axi_rlast
  .s_axi_rvalid(S_AXI_HPC1_rvalid),    // output wire s_axi_rvalid
  .s_axi_rready(S_AXI_HPC1_rready)    // input wire s_axi_rready
);

assign app_lite_araddr = 0;
assign app_lite_arprot = 0;
assign app_lite_arvalid = 0;
assign app_lite_awaddr = 0;
assign app_lite_awprot = 0;
assign app_lite_awvalid = 0;
assign app_lite_bready = 0;
assign app_lite_rready = 0;
assign app_lite_wdata = 0;
assign app_lite_wstrb = 0;
assign app_lite_wvalid = 0;
assign app_param0 = 0;
assign app_param1 = 0;
assign app_param2 = 0;
assign app_param3 = 0;
assign app_param4 = 0;
assign app_param5 = 0;
assign app_param6 = 0;
assign app_param7 = 0;
assign clk_out100 = clk100;
assign init_calib_complete = 1;
assign m00_axis_tdata = 128'h8000_7000_6000_5000_4000_3000_2000_1000;
assign m00_axis_tvalid = 0;
assign m01_axis_tdata = 128'h0800_0700_0600_0500_0400_0300_0200_0100;
assign m01_axis_tvalid = 0;
assign m02_axis_tdata = 128'h8000_7000_6000_5000_4000_3000_2000_1000;
assign m02_axis_tvalid = 0;
assign m03_axis_tdata = 128'h0800_0700_0600_0500_0400_0300_0200_0100;
assign m03_axis_tvalid = 0;
assign m10_axis_tdata = 128'h8000_7000_6000_5000_4000_3000_2000_1000;
assign m10_axis_tvalid = 0;
assign m11_axis_tdata = 128'h0800_0700_0600_0500_0400_0300_0200_0100;
assign m11_axis_tvalid = 0;
assign m12_axis_tdata = 128'h8000_7000_6000_5000_4000_3000_2000_1000;
assign m12_axis_tvalid = 0;
assign m13_axis_tdata = 128'h0800_0700_0600_0500_0400_0300_0200_0100;
assign m13_axis_tvalid = 0;
assign mem_axi_arready = 0;
assign mem_axi_awready = 0;
assign mem_axi_bresp = 0;
assign mem_axi_bvalid = 0;
assign mem_axi_rdata = 0;
assign mem_axi_rlast = 0;
assign mem_axi_rresp = 0;
assign mem_axi_rvalid = 0;
assign mem_axi_wready = 0;
`endif
// dma part
wire dma_clk;
assign dma_clk = pl_clk1;
reg dma_start;
reg dma_loopback;
reg [3:0] dma_axcache;
reg [2:0] dma_axprot;
always@(posedge dma_clk)dma_start <= app_param2[0];
always@(posedge dma_clk)dma_axcache <= app_param2[11:8];
always@(posedge dma_clk)dma_axprot <= app_param2[7:5];
always@(posedge dma_clk)dma_loopback <= app_param2[4];
assign axcache = dma_axcache;
assign axprot = dma_axprot;
wire  m_axis_aclk;
reg  m_axis_reset;
reg [31:0] m_axis_frmlen;
wire  m_axis_tvalid;
wire  m_axis_tready;
wire [127 : 0] m_axis_tdata;
wire [15 : 0] m_axis_tkeep;
wire m_axis_tlast;
assign m_axis_aclk = dma_clk;
reg [15:0] reset_r;
always@(posedge dma_clk)reset_r[15:0] <= {reset_r[14:0], (~s2mm_resetn_out) | (~pl_resetn1)};
always@(posedge dma_clk)m_axis_reset <= (|reset_r);
always@(posedge dma_clk)m_axis_frmlen <= app_param1;

reg [127:0] adcmux_data;
reg  adcmux_valid = 0;
reg  adcmux_start = 0;
reg  adcmux_last = 0;
wire  adcmux_ready;
wire [31:0] m_axis_lastlen;
wire [31:0] m_axis_recvcnt;
wire  m_axis_alert;
wire  m_axis_cmpl;
adc2axis adc2axis_EP0(
.adc_clk(adc_clk),    //input 
.adc_data(adcmux_data),    //input [127:0]
.adc_valid(adcmux_valid),    //input 
.adc_ready(adcmux_ready),    //output 
.adc_last(adcmux_last),    //input 

.m_axis_aclk(m_axis_aclk),    //input 
.m_axis_reset(m_axis_reset),    //input 
.m_axis_frmlen(m_axis_frmlen),    //input [31:0]
.m_axis_lastlen(m_axis_lastlen),    //output [31:0]
.m_axis_recvcnt(m_axis_recvcnt),    //output [31:0]
.m_axis_alert(m_axis_alert),    //output 
.m_axis_cmpl(m_axis_cmpl),    //output 

.m_axis_tvalid(m_axis_tvalid),    //output 
.m_axis_tready(m_axis_tready),    //input 
.m_axis_tdata(m_axis_tdata),    //output [127 : 0]
.m_axis_tkeep(m_axis_tkeep),    //output [15 : 0]
.m_axis_tlast(m_axis_tlast)    //output 
);
assign app_status0 = m_axis_lastlen;
assign app_status1 = {16'hFFFF, 11'h0, m_axis_alert, 3'h0, m_axis_cmpl};
assign app_status2 = m_axis_recvcnt;
assign app_status3 = 0;
//assign app_status4 = 0;
assign app_status5 = 0;
assign app_status6 = 0;
assign app_status7 = 0;

assign S_DMA_AXIS_tdata = dma_loopback?M_DMA_AXIS_tdata:m_axis_tdata;
assign S_DMA_AXIS_tkeep = dma_loopback?M_DMA_AXIS_tkeep:m_axis_tkeep;
assign S_DMA_AXIS_tlast = dma_loopback?M_DMA_AXIS_tlast:m_axis_tlast;
assign S_DMA_AXIS_tvalid = dma_loopback?M_DMA_AXIS_tvalid:m_axis_tvalid;  
assign M_DMA_AXIS_tready = dma_loopback?S_DMA_AXIS_tready:1'b0;
assign m_axis_tready = dma_loopback?1'b0:S_DMA_AXIS_tready;
reg [31:0] mcounter;
// `ifndef BYPASS_ALLSCOPE
// ila_dma ila_dma_ep0(
// .clk(dma_clk),
// .probe0(S_DMA_AXIS_tdata),
// .probe1(S_DMA_AXIS_tkeep),
// .probe2(S_DMA_AXIS_tlast),
// .probe3(S_DMA_AXIS_tready),
// .probe4(S_DMA_AXIS_tvalid),
// .probe5(s2mm_resetn_out),
// .probe6(mm2s_resetn_out),
// .probe7(dma_start),
// .probe8(dma_loopback),
// .probe9(mcounter),
// .probe10(m_axis_reset)
// );
// `endif
always@(posedge dma_clk)begin
	if(m_axis_reset)mcounter <= 0;
	else begin
		if(S_DMA_AXIS_tready&S_DMA_AXIS_tvalid)mcounter <= mcounter + 1;
	end
end

// adc simu
reg [127:0] adcsim_data;
reg  adcsim_valid;
reg  adcsim_last;
reg  adcsim_ready;
reg adcsim_enable;
always@(posedge adc_clk)adc_start <= app_param2[0];
always@(posedge adc_clk)adcsim_enable <= app_param2[1];
genvar kk;
reg [31:0] pcounter;
reg [31:0] total_size;
always@(posedge adc_clk)total_size <= app_param3;

localparam STEP = DWIDTH/32;
always@(posedge adc_clk)begin
	if(adc_start)begin
		if(adcsim_ready & (pcounter<total_size))pcounter <= pcounter + STEP;
	end
	else begin
		pcounter <= 0;
	end
end
generate
for(kk=0;kk<4;kk=kk+1)begin:adc
	always@(posedge adc_clk)begin
		if(adc_start)begin
			if(adcsim_ready)adcsim_data[32*kk+31:32*kk] <= pcounter + kk;
			adcsim_valid <= adcsim_ready & (pcounter<total_size);
			adcsim_last <= (pcounter==(total_size-STEP));
		end
		else begin
			adcsim_data[32*kk+31:32*kk] <= 0;
			adcsim_valid <= 0;
			adcsim_last <= 0;
		end
	end
end
endgenerate
// `ifndef BYPASS_ALLSCOPE
// ila_adc ila_adc_ep0(
// .clk(adc_clk),
// .probe0(adcmux_start),
// .probe1(adcmux_ready),
// .probe2(adcmux_valid),
// .probe3(adcmux_data[31:0]),
// .probe4(pcounter)
// );
// `endif
always@(posedge adc_clk)begin
	adcmux_start <= adc_start;
	if(adcsim_enable)begin
		adcmux_valid <= adcsim_valid & adc_start;
		adcsim_ready <= adcmux_ready & adc_start;
		adcmux_data <= adcsim_data;
		adcmux_last <= adcsim_last & adc_start;
		adc_ready <= 0;		
	end
	else begin
		adcmux_valid <= adc_valid & adc_start;
		adc_ready <= adcmux_ready & adc_start;	
		adcmux_data <= adc_data;
		adcmux_last <= adc_last & adc_start;
		adcsim_ready <= 0;
	end
end

endmodule