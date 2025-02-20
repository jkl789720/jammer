`timescale 1ns / 1ps

`define MINI_SAR
`include "axi_interface.svh" 
//`include "version.vh" 
//`define BYPASS_FILETR
module top(
input SYSREF_ANALOG_N,
input SYSREF_ANALOG_P,
input [0:0] CLK_DAC_N,
input [0:0] CLK_DAC_P,
input [1:0] CLK_ADC_N,
input [1:0] CLK_ADC_P,
input SYSREF_PL_N,
input SYSREF_PL_P,
input CLK_DCLK_PL_N,
input CLK_DCLK_PL_P,  

input [3:0] ADC_P,
input [3:0] ADC_N,
output [3:0] DAC_P,
output [3:0] DAC_N,

input CLK_PL_SYS_N,
input CLK_PL_SYS_P,

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
input DDR4_ALERT_N,
output DDR4_PAR,

// PCIe
//output RST_NVME_0_N,
//output RST_NVME_1_N,
//input pci0_clk_clk_n,
//input pci0_clk_clk_p,
//input pci1_clk_clk_n,
//input pci1_clk_clk_p,
//input [3:0]pcie0_exp_rxn,
//input [3:0]pcie0_exp_rxp,
//output [3:0]pcie0_exp_txn,
//output [3:0]pcie0_exp_txp,
//input [3:0]pcie1_exp_rxn,
//input [3:0]pcie1_exp_rxp,
//output [3:0]pcie1_exp_txn,
//output [3:0]pcie1_exp_txp,
// output BC_A_TXEN,//2025/02/13注掉
// output BC_B_TXEN,
// output BC_A_RXEN,//2025/02/13注掉
`endif
input CLK_PL_DDR_N,
input CLK_PL_DDR_P,
// BC
/* output BC_A_CLK,
output BC_A_CS,
output BC_A_LATCH,
input  BC_A_RXD,
output BC_A_RXEN,
output [3:0] BC_A_TXD,
output BC_A_TXEN,
`ifndef MINI_SAR
output BC_B_CLK,
output BC_B_CS,
output BC_B_LATCH,
input  BC_B_RXD,
output BC_B_RXEN,
output [3:0] BC_B_TXD,
output BC_B_TXEN,
`endif */
// output BC_A_LATCH,//2025/02/13注掉
// output[0:0] 	BC_A_TXD,//2025/02/13注掉
// input 	BC_A_RXD,//2025/02/13注掉


output                  	BC_scl_o    	,
output                  	BC_rst_o        ,
output                  	BC_sel_o        ,
output                  	BC_ld_o         ,
output                  	BC_dary_o       ,
// output                  	BC_trt_o        ,
// output                  	BC_trr_o        ,
output [BC_CHIP_NUM-1:0]    BC_sd_o         ,
// RF
input  RF_A_LOCK,
output RF_A_RXCTL,
output RF_A_SWITCH,
output [3:0] RF_TXEN_OUT,
input  RF_A_UR_RX,
output RF_A_UR_TX,
// input  RF_B_LOCK,
// output RF_B_RXCTL,
// output RF_B_SWITCH,
// output RF_B_TXEN,
// input  RF_B_UR_RX,
// output RF_B_UR_TX,
// SPI
output PL_SPI_SCK, 
output PL_SPI_CS_N, 
output PL_SPI_MOSI, 
input PL_SPI_MISO,
// remote ctrl/status/gps
`ifndef MINI_SAR
output PL_RS422_1_TX,
input PL_RS422_1_RX,
input PL_RS422_2_RX,	// GPS
input PL_RS422_3_RX,	// EXT IMU
output PL_RS422_3_TX,	// EXT IMU
// sync data
output PL_RS422_SAR_1_TXD,
output PL_RS422_SAR_1_TXC,
output PL_RS422_SAR_2_TXD,
output PL_RS422_SAR_2_TXC,

// motor
output PL_RS485_M_TX,
output PL_RS485_M_DE_REN,
input PL_RS485_M_RX,
output PL_RS485_M_PO_0,
output PL_RS485_M_PO_1,

output RST_GPS_N,
//output GPS_EVENT, 
`endif
input PPS_GPS_PL,
output UART_PL_GPS,
input UART_GPS_PL,
input UART_IMU_PL,
// output DBG_UART_TX,
// input DBG_UART_RX,
output DBG_PPSOUT,
output FPGA_SYNC,
output PL_DBG_LED,
output trt_o_p_0,
output trr_o_p_0,	
output trt_o_p_1,	
output trr_o_p_1,	
output trt_o_p_2,	
output trr_o_p_2,	
output trt_o_p_3,	
output trr_o_p_3	
);

localparam LOCAL_DWIDTH = 256;
localparam BC_CHIP_NUM = 16;
`ifndef MINI_SAR
assign UART_PL_GPS = 1;	
`endif
// sys clock
wire locked, clk100, clk50, clk150,clk300;
clk_sys clk_ep0(
.clk_in1_p(CLK_PL_SYS_P),
.clk_in1_n(CLK_PL_SYS_N),
.reset(0),
.clk_out1(clk100),
.clk_out2(clk50),
.clk_out3(clk150),
.locked(locked)
);
  

wire [127:0] 	adc_data;
wire  			adc_valid;
wire  			adc_ready;
wire  			adc_start;
wire  			adc_last;

wire  			bram_clk;
wire  			bram_rst;
wire  			bram_en;
wire [23:0] 	bram_addr;
wire [3:0] 		bram_we;
wire [31:0] bram_rddata;
wire [31:0] bram_wrdata;

wire [127:0] m00_axis_tdata;
wire [127:0] m01_axis_tdata;
wire [127:0] m02_axis_tdata;
wire [127:0] m03_axis_tdata;
wire [127:0] m10_axis_tdata;
wire [127:0] m11_axis_tdata;
wire [127:0] m12_axis_tdata;
wire [127:0] m13_axis_tdata;
wire [255:0] s00_axis_tdata;
wire [255:0] s02_axis_tdata;
wire [255:0] s10_axis_tdata;
wire [255:0] s12_axis_tdata;
wire clk_out100;
wire init_calib_complete;

wire [255:0] vio_dataout;
wire [255:0] rom_dataout;
wire [1:0] vio_selchirp;
wire vio_forceready;
wire vio_forceloopback;
reg vio_reset_pcie0;
reg vio_reset_pcie1;
wire  fifo_wr_valid;
wire  fifo_wr_enable;
wire  fifo_wr_clr;
wire  preprf;
wire  prfin;
wire  prffix; 
wire  prfmux;
wire  PRFIN_IOSIMU; 

//AXI interface
axi4  #(.ndata(32),.naddr(39),.nid(0),.nregion(0),.nuser(0))    app_lite();

axi4  #(.ndata(128),.naddr(49),.nid(6),.nregion(0),.nuser(1))   HPC1_axi();
axi4  #(.ndata(512),.naddr(64),.nid(0),.nregion(4),.nuser(0))   mem_axi();
axi4  #(.ndata(512),.naddr(64),.nid(1),.nregion(4),.nuser(0))   deepfifo_axi();

//锟斤拷要锟狡筹拷锟斤拷mutilfunc锟斤拷募拇锟斤拷锟?
wire [31:0] cfg_dev_adc_ctrl;
wire [31:0] cfg_dev_adc_iodelay;
wire [1:0] rec_fifo_overflow;

//--------------------------- global clk and reset start

wire pl_clk0;
wire [0:0]pl_resetn0;
wire pl_clk1;
wire [0:0]pl_resetn1;
wire core_clk;
reg core_rst = 0;
assign core_clk = pl_clk1;
always@(posedge core_clk)core_rst <= ~pl_resetn1;
reg core_rstn = 1;
always@(posedge core_clk)core_rstn <= pl_resetn1;

wire axi_aresetn =pl_resetn0;
wire axi_aclk = pl_clk0;
// mem domain
wire mem_clk;
wire mem_rst;
assign mem_clk = core_clk;
assign mem_rst = core_rst;
// adda domain
wire  clk_adc_out;
wire  clk_dac_out;
wire adc_clk;
wire dac_clk;
assign adc_clk = clk_adc_out;
assign dac_clk = clk_dac_out;
//assign adc_clk = clk150;
//assign dac_clk = clk150;
reg adc_rst = 0;
always@(posedge adc_clk)adc_rst <= core_rst;
reg dac_rst = 0;
always@(posedge dac_clk)dac_rst <= core_rst;

// system clock moniter
reg [31:0] counter = 0;
reg rst100;
always@(posedge clk100)rst100 <= core_rst;
reg rst50;
always@(posedge clk50)rst50 <= core_rst;

always@(posedge clk100)counter <= counter + 1;
assign PL_DBG_LED = counter[26];
//--------------------------- global clk and reset end
wire clk_adc0;
wire clk_adc1;
wire clk_dac0;
wire clk_dac1;
wire CLK_DCLK_LOCK;


wire AUXRAM_clk;
wire AUXRAM_rst;
wire AUXRAM_en;
wire [15:0]AUXRAM_we;
wire [31:0]AUXRAM_addr;
wire [127:0]AUXRAM_din;
wire [127:0]AUXRAM_dout;
assign AUXRAM_clk = core_clk;
assign AUXRAM_rst = core_rst;
wire [3:0] over_range;
wire [3:0] over_voltage;
wire [3:0] clear_or;
wire [3:0] clear_ov;
wire PLUART_rxd;
wire PLUART_txd;
wire useruart0_rx;
wire useruart0_tx;
wire useruart1_rx;
wire useruart1_tx;
wire [5:0]cfg_ltssm_state0;
wire [5:0]cfg_ltssm_state1;
wire user_lnk_up0;
wire user_lnk_up1;
wire pcie_userclk0;
wire pcie_userclk1;
wire RST_NVME_0_out;
wire RST_NVME_1_out;
wire vio_pcie_reset;

assign RST_NVME_0_N = vio_pcie_reset?vio_reset_pcie0:RST_NVME_0_out;
assign RST_NVME_1_N = vio_pcie_reset?vio_reset_pcie1:RST_NVME_1_out;
cpu_rfdc_wrap cpu_ep(
.AUXRAM_addr(AUXRAM_addr),
.AUXRAM_clk(AUXRAM_clk),
.AUXRAM_din(AUXRAM_din),
.AUXRAM_dout(AUXRAM_dout),
.AUXRAM_en(AUXRAM_en),
.AUXRAM_rst(AUXRAM_rst),
.AUXRAM_we(AUXRAM_we),
.over_range(over_range),
.over_voltage(over_voltage),
.clear_or(clear_or),
.clear_ov(clear_ov),
.PLUART_rxd(PLUART_rxd),
.PLUART_txd(PLUART_txd),
.useruart0_rx(useruart0_rx),    //input 
.useruart0_tx(useruart0_tx),    //output
.useruart1_rx(useruart1_rx),    //input 
.useruart1_tx(useruart1_tx),    //output

.PL_SPI_SCK(PL_SPI_SCK),    //output 
.PL_SPI_CS_N(PL_SPI_CS_N),    //output 
.PL_SPI_MOSI(PL_SPI_MOSI),    //output 
.PL_SPI_MISO(PL_SPI_MISO),    //input 
.pl_clk0(pl_clk0),    //output 
.pl_resetn0(pl_resetn0),    //output [0:0]
.pl_clk1(pl_clk1),    //output 
.pl_resetn1(pl_resetn1),    //output [0:0]
`ifndef SIMULATION
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

//.RST_NVME_0_N(RST_NVME_0_out),
//.RST_NVME_1_N(RST_NVME_1_out),
//.pci0_clk_clk_n(pci0_clk_clk_n),
//.pci0_clk_clk_p(pci0_clk_clk_p),
//.pci1_clk_clk_n(pci1_clk_clk_n),
//.pci1_clk_clk_p(pci1_clk_clk_p),
//.pcie0_exp_rxn(pcie0_exp_rxn),
//.pcie0_exp_rxp(pcie0_exp_rxp),
//.pcie0_exp_txn(pcie0_exp_txn),
//.pcie0_exp_txp(pcie0_exp_txp),
//.pcie1_exp_rxn(pcie1_exp_rxn),
//.pcie1_exp_rxp(pcie1_exp_rxp),
//.pcie1_exp_txn(pcie1_exp_txn),
//.pcie1_exp_txp(pcie1_exp_txp),
//.pcie_userclk0(pcie_userclk0),
//.pcie_userclk1(pcie_userclk1),
//.user_lnk_up0(user_lnk_up0),
//.user_lnk_up1(user_lnk_up1),
//.cfg_ltssm_state0(cfg_ltssm_state0),
//.cfg_ltssm_state1(cfg_ltssm_state1),

`endif
.c0_sys_clk_n(CLK_PL_DDR_N),	//input
.c0_sys_clk_p(CLK_PL_DDR_P),	//input
.clk_out100(clk_out100),    //output 
.init_calib_complete(init_calib_complete),    //output 

.mem_axi_S(mem_axi),
.HPC1_axi_S(HPC1_axi),
.deepfifo_axi_S(deepfifo_axi),
.app_lite_S(app_lite),

.adc_clk(adc_clk),    //input 
.adc_data(adc_data),    //input [DWIDTH-1:0]
.adc_valid(adc_valid),    //input 
.adc_ready(adc_ready),    //output 
.adc_start(adc_start),    //output 
.adc_last(adc_last),    //input 
.bram_clk(bram_clk),    //output 
.bram_rst(bram_rst),    //output 
.bram_en(bram_en),    //output 
.bram_addr(bram_addr),    //output [23:0]
.bram_we(bram_we),    //output [3:0]
.bram_rddata(bram_rddata),    //input [31:0]
.bram_wrdata(bram_wrdata),    //output [31:0]
.clk_adc_out(clk_adc_out),    //output 
.m00_axis_tdata(m00_axis_tdata),    //output [127:0]
.m01_axis_tdata(m01_axis_tdata),    //output [127:0]
.m02_axis_tdata(m02_axis_tdata),    //output [127:0]
.m03_axis_tdata(m03_axis_tdata),    //output [127:0]
.m10_axis_tdata(m10_axis_tdata),    //output [127:0]
.m11_axis_tdata(m11_axis_tdata),    //output [127:0]
.m12_axis_tdata(m12_axis_tdata),    //output [127:0]
.m13_axis_tdata(m13_axis_tdata),    //output [127:0]
.clk_dac_out(clk_dac_out),    //output 
.s00_axis_tdata(s00_axis_tdata),    //input [255:0]
.s02_axis_tdata(s02_axis_tdata),    //input [255:0]
.s10_axis_tdata(s10_axis_tdata),    //input [255:0]
.s12_axis_tdata(s12_axis_tdata),    //input [255:0]
.sysref_in_diff_n(SYSREF_ANALOG_N),    //input 
.sysref_in_diff_p(SYSREF_ANALOG_P),    //input 
.dac0_clk_clk_n(CLK_DAC_N[0]),    //input 
.dac0_clk_clk_p(CLK_DAC_P[0]),    //input 
.adc0_clk_clk_n(CLK_ADC_N[0]),    //input 
.adc0_clk_clk_p(CLK_ADC_P[0]),    //input 
.adc1_clk_clk_n(CLK_ADC_N[1]),    //input 
.adc1_clk_clk_p(CLK_ADC_P[1]),    //input 
.SYSREF_PL_N(SYSREF_PL_N),    //input 
.SYSREF_PL_P(SYSREF_PL_P),    //input 
.CLK_DCLK_PL_N(CLK_DCLK_PL_N),    //input 
.CLK_DCLK_PL_P(CLK_DCLK_PL_P),    //input 
.CLK_DCLK_LOCK(CLK_DCLK_LOCK),	  //output
.clk_adc0(clk_adc0),       
.clk_adc1(clk_adc1),       //output
.clk_dac0(clk_dac0),       //output
.clk_dac1(clk_dac1),       //output
.vin0_01_v_n(ADC_N[0]),    //input 
.vin0_01_v_p(ADC_P[0]),    //input 
.vin0_23_v_n(ADC_N[1]),    //input 
.vin0_23_v_p(ADC_P[1]),    //input 
.vin1_01_v_n(ADC_N[2]),    //input 
.vin1_01_v_p(ADC_P[2]),    //input 
.vin1_23_v_n(ADC_N[3]),    //input 
.vin1_23_v_p(ADC_P[3]),    //input 
.vout00_v_n(DAC_N[0]),    //output 
.vout00_v_p(DAC_P[0]),    //output 
.vout02_v_n(DAC_N[1]),    //output 
.vout02_v_p(DAC_P[1]),    //output 
.vout10_v_n(DAC_N[2]),    //output 
.vout10_v_p(DAC_P[2]),    //output 
.vout12_v_n(DAC_N[3]),    //output 
.vout12_v_p(DAC_P[3])    //output 
);

wire vio_reset;
reg [31:0] counter0;
always@(posedge clk100)begin
	if(vio_reset)counter0 <= 0;
	else counter0 <= counter0 + 1;
end
reg [31:0] counter1;
reg vio_reset_r1;
always@(posedge adc_clk)vio_reset_r1 <= vio_reset;
always@(posedge adc_clk)begin
	if(vio_reset_r1)counter1 <= 0;
	else counter1 <= counter1 + 1;
end
reg [31:0] counter2;
reg vio_reset_r2;
always@(posedge clk_out100)vio_reset_r2 <= vio_reset;
always@(posedge clk_out100)begin
	if(vio_reset_r2)counter2 <= 0;
	else counter2 <= counter2 + 1;
end

reg [31:0] counter_adc0;
reg vio_reset_adc0;
always@(posedge clk_adc0)vio_reset_adc0 <= vio_reset;
always@(posedge clk_adc0)begin
	if(vio_reset_adc0)counter_adc0 <= 0;
	else counter_adc0 <= counter_adc0 + 1;
end
reg [31:0] counter_adc1;
reg vio_reset_adc1;
always@(posedge clk_adc1)vio_reset_adc1 <= vio_reset;
always@(posedge clk_adc1)begin
	if(vio_reset_adc1)counter_adc1 <= 0;
	else counter_adc1 <= counter_adc1 + 1;
end
reg [31:0] counter_dac0;
reg vio_reset_dac0;
always@(posedge clk_dac0)vio_reset_dac0 <= vio_reset;
always@(posedge clk_dac0)begin
	if(vio_reset_dac0)counter_dac0 <= 0;
	else counter_dac0 <= counter_dac0 + 1;
end
reg [31:0] counter_dac1;
reg vio_reset_dac1;
always@(posedge clk_dac1)vio_reset_dac1 <= vio_reset;
always@(posedge clk_dac1)begin
	if(vio_reset_dac1)counter_dac1 <= 0;
	else counter_dac1 <= counter_dac1 + 1;
end

reg [31:0] counter_pcie0;

always@(posedge pcie_userclk0)vio_reset_pcie0 <= vio_reset;
always@(posedge pcie_userclk0)begin
	if(vio_reset_pcie0)counter_pcie0 <= 0;
	else counter_pcie0 <= counter_pcie0 + 1;
end

reg [31:0] counter_pcie1;

always@(posedge pcie_userclk1)vio_reset_pcie1 <= vio_reset;
always@(posedge pcie_userclk1)begin
	if(vio_reset_pcie1)counter_pcie1 <= 0;
	else counter_pcie1 <= counter_pcie1 + 1;
end

vio_rfdc vio_rfdc_ep0(
.clk(clk100),
.probe_in0({cfg_ltssm_state1, cfg_ltssm_state0, RST_NVME_1_N, RST_NVME_0_N, user_lnk_up1, user_lnk_up0, CLK_DCLK_LOCK, init_calib_complete}),
.probe_in1(counter0),
.probe_in2(counter1),
.probe_in3(counter2),
.probe_in4(counter_adc0),
.probe_in5(counter_adc1),
.probe_in6(counter_dac0),
.probe_in7(counter_dac1),
.probe_in8(counter_pcie0),
.probe_in9(counter_pcie1),
.probe_in10({over_range,over_voltage}),
.probe_out0(vio_dataout),
.probe_out1(vio_selchirp),
.probe_out2(vio_reset),
.probe_out3(vio_forceready),
.probe_out4(vio_forceloopback),
.probe_out5({clear_or,clear_ov}),
.probe_out6(vio_pcie_reset)
);
reg host_ready = 0;
reg host_loopsel = 0;
always@(posedge adc_clk)host_ready <= vio_forceready;
always@(posedge adc_clk)host_loopsel <= vio_forceloopback;

//----------------------------- data channel start -----------------------------------
wire [255:0] m_axis_hostc_DA_tdata;
wire  m_axis_hostc_DA_tvalid;
wire  m_axis_hostc_DA_tready;
wire  m_axis_hostc_DA_tlast;

wire [255:0] m_axis_hostc_AD_tdata;
wire  m_axis_hostc_AD_tvalid;
wire  m_axis_hostc_AD_tready;
wire  m_axis_hostc_AD_tlast;


//Control_time
wire						mfifo_wr_clr_ctrl;	// active high; only one cycle
wire						mfifo_wr_valid_ctrl;
wire						mfifo_wr_enable_ctrl;
wire						mfifo_rd_clr_ctrl;	// active high; only one cycle
wire						mfifo_rd_valid_ctrl;
wire						mfifo_rd_enable_ctrl;
				
wire						fifo_rd_clr_ctrl;	// active high; only one cycle
wire						fifo_rd_valid_ctrl;
wire						fifo_rd_enable_ctrl;
wire						fifo_wr_clr_ctrl;	// active high; only one cycle
wire						fifo_wr_valid_ctrl;
wire						fifo_wr_enable_ctrl;
//local_channel
//AD
wire 						mfifo_wr_clr;	// active high; only one cycle
wire 						mfifo_wr_valid;
wire 						mfifo_wr_enable;
wire [LOCAL_DWIDTH-1:0] 	mfifo_wr_data;

//DA
wire						mfifo_rd_clr;	// active high; only one cycle
wire						mfifo_rd_valid;
wire						mfifo_rd_enable;
wire [LOCAL_DWIDTH-1:0] 	mfifo_rd_data;

datachannel_wrap #(
.LOCAL_DWIDTH(LOCAL_DWIDTH)
)
datachannel_wrap_EP0
(
//system
.adc_clk(adc_clk),
.adc_rst(adc_rst),
.dac_clk(dac_clk),
.dac_rst(dac_rst),
.PPS_GPS_PL(PPS_GPS_PL),
//.preprf(preprf),
//.prfin(prfin),
.prffix(prffix),    //output 
//.prfmux(prfmux),    //input 
.prfin_ex(PRFIN_IOSIMU),
// .fifo_wr_clr(fifo_wr_clr),
// .fifo_wr_valid(fifo_wr_valid),
// .fifo_wr_enable(fifo_wr_enable),
.host_loopsel(host_loopsel),
.host_ready(host_ready),

.rec_fifo_overflow(rec_fifo_overflow),
.cfg_dev_adc_ctrl(cfg_dev_adc_ctrl),
.cfg_dev_adc_iodelay(cfg_dev_adc_iodelay),
.init_calib_complete(init_calib_complete),
//mem axi4
.mem_clk(mem_clk),
.mem_rst(mem_rst),
.mem_axi_M(mem_axi),
.HPC1_axi_M(HPC1_axi),
.deepfifo_axi_M(deepfifo_axi),

//Control_time
.mfifo_wr_clr_ctrl(mfifo_wr_clr_ctrl),	// active high, only one cycle
.mfifo_wr_valid_ctrl(mfifo_wr_valid_ctrl),
.mfifo_wr_enable_ctrl(mfifo_wr_enable_ctrl),
.mfifo_rd_clr_ctrl(mfifo_rd_clr_ctrl),	// active high, only one cycle
.mfifo_rd_valid_ctrl(mfifo_rd_valid_ctrl),
.mfifo_rd_enable_ctrl(mfifo_rd_enable_ctrl),

.fifo_rd_clr_ctrl(fifo_rd_clr_ctrl),	// active high, only one cycle
.fifo_rd_valid_ctrl(fifo_rd_valid_ctrl),
.fifo_rd_enable_ctrl(fifo_rd_enable_ctrl),
.fifo_wr_clr_ctrl(fifo_wr_clr_ctrl),	// active high, only one cycle
.fifo_wr_valid_ctrl(fifo_wr_valid_ctrl),
.fifo_wr_enable_ctrl(fifo_wr_enable_ctrl),
//local_channel
//AD
.mfifo_wr_clr(mfifo_wr_clr),	// active high, only one cycle
.mfifo_wr_valid(mfifo_wr_valid),
.mfifo_wr_enable(mfifo_wr_enable),
.mfifo_wr_data(mfifo_wr_data),

//DA
.mfifo_rd_clr(mfifo_rd_clr),	// active high, only one cycle
.mfifo_rd_valid(mfifo_rd_valid),
.mfifo_rd_enable(mfifo_rd_enable),
.mfifo_rd_data(mfifo_rd_data),



/* //local_channel
//AD
.mfifo_wr_data(mfifo_wr_data),
//DA
.mfifo_rd_enable(mfifo_rd_enable),
.mfifo_rd_data(mfifo_rd_data),
.DAC_VOUT(DAC_VOUT), */

//AD datain
.m_axis_hostc_AD_tdata(m_axis_hostc_AD_tdata),
.m_axis_hostc_AD_tvalid(m_axis_hostc_AD_tvalid),
.m_axis_hostc_AD_tready(m_axis_hostc_AD_tready),
.m_axis_hostc_AD_tlast(m_axis_hostc_AD_tlast),
//DA dataout
.m_axis_hostc_DA_tdata(m_axis_hostc_DA_tdata),
.m_axis_hostc_DA_tvalid(m_axis_hostc_DA_tvalid),
.m_axis_hostc_DA_tready(m_axis_hostc_DA_tready),
.m_axis_hostc_DA_tlast(m_axis_hostc_DA_tlast),


.AUXRAM_en(AUXRAM_en),
.AUXRAM_we(AUXRAM_we),
.AUXRAM_addr(AUXRAM_addr),
.AUXRAM_din(AUXRAM_din),
.AUXRAM_dout(AUXRAM_dout),

//app axi_lite 
.axi_aresetn(axi_aresetn),    //input 
.axi_aclk(axi_aclk),    //input 
.core_clk(core_clk),
//.core_rstn(core_rstn),
.core_rst(core_rst),
.app_lite_S(app_lite)
);


//----------------------------- data channel stop -----------------------------------

//----------------------------- multifunc start ----------------------------------


reg BC_sys_rst = 0;
always@(posedge clk50)BC_sys_rst <= core_rst;
multifunc multifunc_EP0(
.clk(clk50),    //input 
.reset(rst50),    //input 

.rs485_rx(PL_RS485_M_RX),    //input 
.rs485_tx(PL_RS485_M_TX),    //output 
.rs485_en(PL_RS485_M_DE_REN),    //output 

// .adc_sel(adc_sel),
// .dac_sel(dac_sel),
// .adc_div(adc_div),
//.cfg_adc_frmlen(cfg_adc_frmlen),
// .ctrl_data(ctrl_data),    //output [48*32-1:0]
// .status_data(status_data),    //output [16*32-1:0]
// .param_data(param_data),    //output [24*32-1:0]
// .debug_data(debug_data),    //output [32*32-1:0]


.adc_clk(adc_clk),
.adc_rst(adc_rst),
.dac_clk(dac_clk),
.dac_rst(dac_rst),

.m00_axis_tdata(m00_axis_tdata),
.m01_axis_tdata(m01_axis_tdata),
.m02_axis_tdata(m02_axis_tdata),
.m03_axis_tdata(m03_axis_tdata),
.m10_axis_tdata(m10_axis_tdata),
.m11_axis_tdata(m11_axis_tdata),
.m12_axis_tdata(m12_axis_tdata),
.m13_axis_tdata(m13_axis_tdata),

.s00_axis_tdata(s00_axis_tdata),
.s02_axis_tdata(s02_axis_tdata),
.s10_axis_tdata(s10_axis_tdata),
.s12_axis_tdata(s12_axis_tdata),


//Control_time
.mfifo_wr_clr_ctrl(mfifo_wr_clr_ctrl),	// active high, only one cycle
.mfifo_wr_valid_ctrl(mfifo_wr_valid_ctrl),
.mfifo_wr_enable_ctrl(mfifo_wr_enable_ctrl),
.mfifo_rd_clr_ctrl(mfifo_rd_clr_ctrl),	// active high, only one cycle
.mfifo_rd_valid_ctrl(mfifo_rd_valid_ctrl),
.mfifo_rd_enable_ctrl(mfifo_rd_enable_ctrl),

.fifo_rd_clr_ctrl(fifo_rd_clr_ctrl),	// active high, only one cycle
.fifo_rd_valid_ctrl(fifo_rd_valid_ctrl),
.fifo_rd_enable_ctrl(fifo_rd_enable_ctrl),
.fifo_wr_clr_ctrl(fifo_wr_clr_ctrl),	// active high, only one cycle
.fifo_wr_valid_ctrl(fifo_wr_valid_ctrl),
.fifo_wr_enable_ctrl(fifo_wr_enable_ctrl),
//local_channel
//AD
.mfifo_wr_clr(mfifo_wr_clr),	// active high, only one cycle
.mfifo_wr_valid(mfifo_wr_valid),
.mfifo_wr_enable(mfifo_wr_enable),
.mfifo_wr_data(mfifo_wr_data),

//DA
.mfifo_rd_clr(mfifo_rd_clr),	// active high, only one cycle
.mfifo_rd_valid(mfifo_rd_valid),
.mfifo_rd_enable(mfifo_rd_enable),
.mfifo_rd_data(mfifo_rd_data),



.rec_fifo_overflow(rec_fifo_overflow),

/* .fifo_wr_clr(fifo_wr_clr),
//.fifo_wr_valid(fifo_wr_valid),
.fifo_wr_enable(fifo_wr_enable),

.DAC_VOUT(DAC_VOUT), */

.cfg_dev_adc_iodelay(cfg_dev_adc_iodelay),
.cfg_dev_adc_ctrl(cfg_dev_adc_ctrl),

.adc_dma_valid(adc_valid),
.adc_dma_data(adc_data),
.adc_dma_last(adc_last),
.adc_dma_ready(adc_ready),
.adc_dma_start(adc_start),	

.vio_dataout(vio_dataout),
.vio_selchirp(vio_selchirp),

//.adc_clk(adc_clk),    //input 
//.adc_rst(adc_rst),    //input 

//.preprf(preprf),    //input 
//.prfin(prfin),    //input 
.prffix(prffix),    //output 
//.prfmux(prfmux),    //input 

/* .adc_valid(fifo_wr_valid),    //input 
.dac_valid(mfifo_rd_enable),    //input 
.mfifo_rd_data(mfifo_rd_data), */

//AD dataout   host_channnel
.m_axis_hostc_AD_tdata(m_axis_hostc_AD_tdata),
.m_axis_hostc_AD_tvalid(m_axis_hostc_AD_tvalid),
.m_axis_hostc_AD_tready(m_axis_hostc_AD_tready),
.m_axis_hostc_AD_tlast(m_axis_hostc_AD_tlast),
//DA datain    host_channnel
.m_axis_hostc_DA_tdata(m_axis_hostc_DA_tdata),
.m_axis_hostc_DA_tvalid(m_axis_hostc_DA_tvalid),
.m_axis_hostc_DA_tready(m_axis_hostc_DA_tready),
.m_axis_hostc_DA_tlast(m_axis_hostc_DA_tlast),


.PRFIN_IOSIMU(PRFIN_IOSIMU),     //output 

//bram
.bram_clk(bram_clk),    //input 
.bram_rst(bram_rst),    //input 
.bram_en(bram_en),    //input 
.bram_addr(bram_addr),    //input [23:0]
.bram_we(bram_we),    //input [3:0]
.bram_rddata(bram_rddata),    //output [31:0]
.bram_wrdata(bram_wrdata),    //input [31:0]


//锟斤拷锟斤拷
//.BC_A_CLK(BC_A_CLK),    //output 
//.BC_A_CS(BC_A_CS),    //output 
.BC_A_LATCH(BC_A_LATCH),    //output 
.BC_A_RXD(BC_A_RXD),    //input 
.BC_A_RXEN(BC_A_RXEN),    //output 
//.BC_A_TXD(BC_A_TXD),    //output [3:0]
.BC_A_TXEN(BC_A_TXEN),    //output 
//.BC_B_CLK(BC_B_CLK),    //output 
//.BC_B_CS(BC_B_CS),    //output 
//.BC_B_LATCH(BC_B_LATCH),    //output 
//.BC_B_RXD(BC_B_RXD),    //input 
//.BC_B_RXEN(BC_B_RXEN),    //output 
//.BC_B_TXD(BC_B_TXD),    //output [3:0]
.BC_B_TXEN(BC_B_TXEN),    //output
.BC_sys_clk(clk50),
.BC_sys_rst(BC_sys_rst),
  
.BC_scl_o(BC_scl_o),    	
.BC_rst_o(BC_rst_o),        
.BC_sel_o(BC_sel_o),        
.BC_ld_o(BC_ld_o),         
.BC_dary_o(BC_dary_o),       
.BC_trt_o(BC_trt_o),        
.BC_trr_o(BC_trr_o),        
.BC_sd_o(BC_sd_o),         
 
.RF_A_LOCK(RF_A_LOCK),    //input 
.RF_A_RXCTL(RF_A_RXCTL),    //output 
.RF_A_SWITCH(RF_A_SWITCH),    //output 
.RF_A_TXEN(),    //output 
.RF_A_UR_RX(RF_A_UR_RX),    //input 
.RF_A_UR_TX(RF_A_UR_TX),    //output 
.RF_B_LOCK(RF_B_LOCK),    //input 
.RF_B_RXCTL(RF_B_RXCTL),    //output 
.RF_B_SWITCH(RF_B_SWITCH),    //output 
.RF_B_TXEN(),    //output 
.RF_B_UR_RX(RF_B_UR_RX),    //input 
.RF_B_UR_TX(RF_B_UR_TX),    //output 
.RST_GPS_N(RST_GPS_N),    //output 
.GPS_EVENT(GPS_EVENT),    //output 
.PPS_GPS_PL(PPS_GPS_PL),    //input 

.useruart0_rx(useruart0_rx),    //output 
.useruart0_tx(useruart0_tx),    //input
.useruart1_rx(useruart1_rx),    //output 
.useruart1_tx(useruart1_tx),    //input
.UART_PL_GPS(UART_PL_GPS),    //output 
.UART_GPS_PL(UART_GPS_PL),    //input 
.UART_IMU_PL(UART_IMU_PL),    //input 
//.DBG_UART_TX(DBG_UART_TX),    //output 
//.DBG_UART_RX(DBG_UART_RX),    //input 
.PL_RS422_3_TX(PL_RS422_3_TX),    //output 
.PL_RS422_3_RX(PL_RS422_3_RX),    //input 
.DBG_PPSOUT(DBG_PPSOUT),    //output 
.rf_tx_en_v	(RF_TXEN_OUT[0]	)	,//output 
.rf_tx_en_h	(RF_TXEN_OUT[1]	)	,//output 
.trt_o_p_0	(trt_o_p_0	)	,//output 
.trr_o_p_0	(trr_o_p_0	)	,//output 	
.trt_o_p_1	(trt_o_p_1	)	,//output 	
.trr_o_p_1	(trr_o_p_1	)	,//output 	
.trt_o_p_2	(trt_o_p_2	)	,//output 	
.trr_o_p_2	(trr_o_p_2	)	,//output 	
.trt_o_p_3	(trt_o_p_3	)	,//output 	
.trr_o_p_3	(trr_o_p_3	)	
);

// ila_rxtx ila_rxtx_ep(
// .clk(clk50),
// .probe0(useruart0_rx),
// .probe1(useruart0_tx),
// .probe2(useruart1_rx),
// .probe3(useruart1_tx),
// .probe4(UART_PL_GPS),
// .probe5(UART_GPS_PL),
// .probe6(UART_IMU_PL),
// .probe7(PL_RS422_3_TX),
// .probe8(PL_RS422_3_RX),
// .probe9(DBG_PPSOUT)
// );


`ifndef MINI_SAR
assign PLUART_rxd = PL_RS422_1_RX;
assign PL_RS422_1_TX = PLUART_txd;
`else
assign PLUART_rxd = BC_A_RXD;
// assign BC_A_TXD[0] = PLUART_txd;
`endif

assign FPGA_SYNC = prffix;
assign PL_RS485_M_PO_0 = fifo_wr_enable_ctrl;
assign PL_RS485_M_PO_1 = mfifo_rd_enable;

//----------------------------- multifunc stop -----------------------------------
endmodule
