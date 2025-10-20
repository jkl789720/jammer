module multifunc
#(
parameter LOCAL_DWIDTH 	= 256,
parameter BC_CHIP_NUM	= 16
)
(
input clk,
input reset,
//ADDA data pre process
input				adc_clk,
input				adc_rst,
input				dac_clk,
input				dac_rst,
	
input [127:0]		m00_axis_tdata,
input [127:0]   	m01_axis_tdata,
input [127:0]   	m02_axis_tdata,
input [127:0]   	m03_axis_tdata,
input [127:0]   	m10_axis_tdata,
input [127:0]   	m11_axis_tdata,
input [127:0]   	m12_axis_tdata,
input [127:0]   	m13_axis_tdata,
	
output [255:0]		s00_axis_tdata,
output [255:0]  	s02_axis_tdata,
output [255:0]  	s10_axis_tdata,
output [255:0]  	s12_axis_tdata,


//Control_time
input 						mfifo_wr_clr_ctrl,	// active high, only one cycle
input 						mfifo_wr_valid_ctrl,
input 						mfifo_wr_enable_ctrl,
input 						mfifo_rd_clr_ctrl,	// active high, only one cycle
input 						mfifo_rd_valid_ctrl,
input 						mfifo_rd_enable_ctrl,

input 						fifo_rd_clr_ctrl,	// active high, only one cycle
input 						fifo_rd_valid_ctrl,
input 						fifo_rd_enable_ctrl,
input 						fifo_wr_clr_ctrl,	// active high, only one cycle
input 						fifo_wr_valid_ctrl,
input 						fifo_wr_enable_ctrl,
//local_channel
//AD
output 						mfifo_wr_clr,	// active high, only one cycle
output 						mfifo_wr_valid,
output 						mfifo_wr_enable,
output [LOCAL_DWIDTH-1:0] 	mfifo_wr_data,

//DA
output 						mfifo_rd_clr,	// active high, only one cycle
output 						mfifo_rd_valid,
output 						mfifo_rd_enable,
input [LOCAL_DWIDTH-1:0] 	mfifo_rd_data,


/* input 				fifo_wr_clr,
//input 				fifo_wr_valid,
input 				fifo_wr_enable,
//input [31:0] 		cfg_adc_frmlen,
//input				DAC_VOUT,
input [LOCAL_DWIDTH-1:0] mfifo_rd_data, */

input [31:0]    	cfg_dev_adc_iodelay,
input [31:0]		cfg_dev_adc_ctrl,
output [1:0]		rec_fifo_overflow,
//host_channel
//AD dataout
output [255:0] 		m_axis_hostc_AD_tdata,
output  			m_axis_hostc_AD_tvalid,
input 				m_axis_hostc_AD_tready,
output  			m_axis_hostc_AD_tlast,
//DA datain	
input [255:0] 		m_axis_hostc_DA_tdata,
input 	 			m_axis_hostc_DA_tvalid,
output  			m_axis_hostc_DA_tready,
input  				m_axis_hostc_DA_tlast,

//adc dma	
output				adc_dma_valid,
output [127:0]		adc_dma_data,
output				adc_dma_last,
input				adc_dma_ready,
input				adc_dma_start,	
	
//vio data	
input [255:0]   	vio_dataout,
input [1:0]			vio_selchirp,
// motor
input  rs485_rx,
output rs485_tx, 
output rs485_en,


//input preprf,
//input prfin,
//input prfmux,
output prffix,
// input adc_valid,
// input dac_valid,
// output DAC_VOUT,

output PRFIN_IOSIMU,
// output [1:0] adc_sel,
// output [1:0] dac_sel,
// output [15:0] adc_div,
//output [31:0] cfg_adc_frmlen,



input 			bram_clk,
input 			bram_rst,
input 			bram_en,
input [23:0]	bram_addr,
input [3:0]		bram_we,
output [31:0]	bram_rddata,
input [31:0]	bram_wrdata,

// BC
// output BC_A_CLK,
// output BC_A_CS,
output BC_A_LATCH,//
input  BC_A_RXD,
output BC_A_RXEN,
// output [3:0] BC_A_TXD,
output BC_A_TXEN,//
// output BC_B_CLK,
// output BC_B_CS,
// output BC_B_LATCH,
// input  BC_B_RXD,
// output BC_B_RXEN,
// output [3:0] BC_B_TXD,
output BC_B_TXEN,//
input						BC_sys_clk,
input                       BC_sys_rst,

output                  	BC_scl_o    	,
output                  	BC_rst_o        ,
output                  	BC_sel_o        ,
output                  	BC_ld_o         ,
output                  	BC_dary_o       ,
output                  	BC_trt_o        ,
output                  	BC_trr_o        ,
output [BC_CHIP_NUM-1:0]    BC_sd_o         ,
// RF
input  RF_A_LOCK,
output RF_A_RXCTL,//
output RF_A_SWITCH,
output RF_A_TXEN,//
input  RF_A_UR_RX,
output RF_A_UR_TX,
input  RF_B_LOCK,
output RF_B_RXCTL,
output RF_B_SWITCH,
output RF_B_TXEN,
input  RF_B_UR_RX,
output RF_B_UR_TX,
// MISC
output RST_GPS_N,
output GPS_EVENT,
input PPS_GPS_PL,
output UART_PL_GPS,
input UART_GPS_PL,
input UART_IMU_PL,
output DBG_UART_TX,
input DBG_UART_RX,
input PL_RS422_3_RX,
output PL_RS422_3_TX,
output DBG_PPSOUT,

output useruart0_rx,
input useruart0_tx,
output useruart1_rx,
input useruart1_tx,
output rf_tx_en_v,
output rf_tx_en_h,
output trt_o_p_0,
output trr_o_p_0,	
output trt_o_p_1,	
output trr_o_p_1,	
output trt_o_p_2,	
output trr_o_p_2,	
output trt_o_p_3,	
output trr_o_p_3	,
output [31:0] cfg_multifuc_ctrl,
output adc_valid_expand
);
wire rf_out;
wire channel_sel;
wire bc_tx_en;
//wire adc_valid_expand;
wire zero_sel;
wire trt_close_flag;
wire trr_close_flag;

assign BC_A_TXEN = rf_out;

assign BC_A_RXEN = rf_out;

wire disturb_adc_valid;

assign BC_A_LATCH = disturb_adc_valid;

wire imu_rxdata;				
assign PL_RS422_3_TX = useruart1_tx;
//		sign useruart1_rx = PL_RS422_3_RX;
assign useruart1_rx = imu_rxdata;								 

assign useruart0_rx = UART_GPS_PL;
//assign DBG_UART_TX = UART_GPS_PL;
assign UART_PL_GPS = useruart0_tx;
assign DBG_PPSOUT = UART_IMU_PL;
//----------------------- GPS/IMU/COMM ------------------------
reg pwr_reset = 1;
reg [23:0] pwr_count = 0;	// 16M ~ 160ms 
always@(posedge clk)begin
	if(pwr_count<24'hFFFFFF)pwr_count <= pwr_count + 1;
	pwr_reset <= (pwr_count<24'hFFFFFF);
end

assign GPS_EVENT = 0;
assign RST_GPS_N = ~pwr_reset;

//assign UART_PL_GPS = DBG_UART_RX;
//assign DBG_UART_TX = UART_GPS_PL;
//assign DBG_PPSOUT = PPS_GPS_PL;
//assign DBG_PPSOUT = dac_valid;

//----------------------- GPS time reg ------------------------
reg pps_r1, pps_r2;
wire pps_pulse = pps_r1 & (~pps_r2);
reg [31:0] ppstimer;
reg [31:0] ppslength;
reg [31:0] gps_sec;
always@(posedge bram_clk)begin
    pps_r1 <= PPS_GPS_PL;
    pps_r2 <= pps_r1;
    if(pps_pulse)ppstimer <= 0;
    else ppstimer <= ppstimer + 1;
    
    if(pps_pulse)ppslength <= ppstimer;
	if(pps_pulse)gps_sec <= status_data[447:416];
end
//----------------------- GPS time reg end ------------------------


//----------------------- BRAM load start ------------------------
localparam BRAM1_BASE = 24'h000000;
//localparam BRAM2_BASE = 24'h008000;
localparam REGFILE_BASE = 24'h010000;
localparam BRAM1_TOP = 24'h010000;
//localparam BRAM2_TOP = 24'h010000;
localparam REGFILE_TOP = 24'h020000;
localparam AUXFILE_TOP = 24'h030000;
localparam BRAM2_BASE = 24'h100000;
localparam BRAM2_TOP = 24'h200000;
localparam BRAM3_TOP = 24'h040000;
localparam BRAMRPU_TOP = 24'h050000;


reg [11:0] cfg_wr_addr;
reg [31:0] cfg_wr_dat;
reg  cfg_wr_en;
reg [11:0] cfg_rd_addr;
wire [31:0] cfg_rd_dat;
reg [31:0] cfg_rd_dat_r;
reg  cfg_rd_en;

reg [11:0] aux_wr_addr;
reg [31:0] aux_wr_dat;
reg  aux_wr_en;
reg [11:0] aux_rd_addr;
wire [31:0] aux_rd_dat;
reg [31:0] aux_rd_dat_r;
reg  aux_rd_en;

reg [44*8-1:0] status_imu;
reg [63*8-1:0] debug_imu; 
auxdata_format auxdata_format_EP0(
.ctrl_data(ctrl_data),    //output [48*32-1:0]
.status_data(status_data),    //output [16*32-1:0]
.param_data(param_data),    //output [24*32-1:0]
.debug_data(debug_data),    //output [32*32-1:0]
.status_imu(status_imu),    //input [44*8-1:0]
.debug_imu(debug_imu),    //input [63*8-1:0]

.cfg_clk(bram_clk),    //input 
.cfg_rst(bram_rst),    //input 
.cfg_wr_addr(aux_wr_addr),    //input [11:0]
.cfg_wr_dat(aux_wr_dat),    //input [31:0]
.cfg_wr_en(aux_wr_en),    //input 
.cfg_rd_addr(aux_rd_addr),    //input [11:0]
.cfg_rd_dat(aux_rd_dat),    //output [31:0]
.cfg_rd_en(aux_rd_en)    //input 
);
// bram instance
//BC
wire [31:0] douta0;
reg [31:0] dina0;
reg [31:0] addra0;
reg [3:0] wea0;
wire [3:0] web0;
wire [31:0] dinb0;
wire [31:0] doutb0;
wire [31:0] addrb0;
//chip
wire [31:0] douta1;
reg [31:0] dina1;
reg [31:0] addra1;
reg [3:0] wea1;
wire [3:0] web1;
wire [31:0] dinb1;
wire [31:0] doutb1;
wire [31:0] addrb1;
//chip_fft
wire [31:0] douta2;
reg [31:0] dina2;
reg [31:0] addra2;
reg [3:0] wea2;
wire [3:0] web2;
wire [31:0] dinb2;
wire [31:0] doutb2;
wire [31:0] addrb2;
//RPU
wire [31:0] douta3;
reg [31:0] dina3;
reg [31:0] addra3;
reg [3:0] wea3;
wire [3:0] web3;
wire [31:0] dinb3;
wire [31:0] doutb3;
wire [31:0] addrb3;


reg [2:0] rdata_sel;
always@(posedge bram_clk)begin
	if(bram_rst)begin
		dina0 <= 0;
		wea0 <= 0;
		addra0 <= 0;	
		dina1 <= 0;
		wea1 <= 0;
		addra1 <= 0;	
		dina2 <= 0;
		wea2 <= 0;
		addra2 <= 0;
		dina3 <= 0;
		wea3 <= 0;
		addra3 <= 0;
		cfg_wr_addr <= 0;
		cfg_wr_dat <= 0;
		cfg_wr_en <= 0;
		cfg_rd_addr <= 0;
		cfg_rd_en <= 0;
		cfg_rd_dat_r <= 0;
		aux_wr_addr <= 0;
		aux_wr_dat <= 0;
		aux_wr_en <= 0;
		aux_rd_addr <= 0;
		aux_rd_en <= 0;
		aux_rd_dat_r <= 0;
		rdata_sel <= 0;
	end
	else begin
		cfg_rd_dat_r <= cfg_rd_dat;
		aux_rd_dat_r <= aux_rd_dat;
		if(bram_en)begin
			dina0 <= bram_wrdata;
			dina1 <= bram_wrdata;
			dina2 <= bram_wrdata;
			dina3 <= bram_wrdata;
			addra0 <= {8'h0, bram_addr};
			addra1 <= {8'h0, bram_addr};
			addra2 <= {8'h0, bram_addr};
			addra3 <= {8'h0, bram_addr};
			cfg_wr_addr <= bram_addr;
			cfg_wr_dat <= bram_wrdata;
			cfg_rd_addr <= bram_addr;		
			aux_wr_addr <= bram_addr;
			aux_wr_dat <= bram_wrdata;
			aux_rd_addr <= bram_addr;			
			if(bram_addr<BRAM1_TOP)begin
				wea0 <= bram_we;
				wea1 <= 4'h0;
				wea2 <= 4'h0;
				wea3 <= 4'h0;	
				cfg_wr_en <= 0;
				cfg_rd_en <= 0;
				aux_wr_en <= 0;
				aux_rd_en <= 0;
				rdata_sel <= 0;
			end
			// else if(bram_addr<BRAM2_TOP)begin
			// 	wea0 <= 4'h0;
			// 	wea1 <= bram_we;	
			// 	cfg_wr_en <= 0;
			// 	cfg_rd_en <= 0;	
			// 	aux_wr_en <= 0;
			// 	aux_rd_en <= 0;
			// 	rdata_sel <= 1;				
			// end
			else if(bram_addr<REGFILE_TOP)begin
				wea0 <= 4'h0;
				wea1 <= 4'h0;
				wea2 <= 4'h0;
				wea3 <= 4'h0;		
				cfg_wr_en <= (bram_we>0);
				cfg_rd_en <= (bram_we==0);
				aux_wr_en <= 0;
				aux_rd_en <= 0;
				rdata_sel <= 2;				
			end
			else if(bram_addr<AUXFILE_TOP)begin
				wea0 <= 4'h0;
				wea1 <= 4'h0;
				wea2 <= 4'h0;
				wea3 <= 4'h0;		
				cfg_wr_en <= 0;
				cfg_rd_en <= 0;	
				aux_wr_en <= (bram_we>0);
				aux_rd_en <= (bram_we==0);
				rdata_sel <= 3;				
			end
			else if(bram_addr<BRAM3_TOP)begin
				wea0 <= 4'h0;
				wea1 <=  4'h0;
				wea2 <= bram_we;
				wea3 <= 4'h0;	
				cfg_wr_en <= 0;
				cfg_rd_en <= 0;	
				aux_wr_en <= 0;
				aux_rd_en <= 0;
				rdata_sel <= 4;				
			end
			else if(bram_addr<BRAMRPU_TOP)begin
				wea0 <= 4'h0;
				wea1 <=  4'h0;
				wea2 <= 4'h0;
				wea3 <= bram_we;	
				cfg_wr_en <= 0;
				cfg_rd_en <= 0;	
				aux_wr_en <= 0;
				aux_rd_en <= 0;
				rdata_sel <= 5;				
			end
			else if(bram_addr>=BRAM2_BASE & bram_addr<BRAM2_TOP)begin
				wea0 <= 4'h0;
				wea1 <= bram_we;
				wea2 <= 4'h0;
				wea3 <= 4'h0;		
				cfg_wr_en <= 0;
				cfg_rd_en <= 0;	
				aux_wr_en <= 0;
				aux_rd_en <= 0;
				rdata_sel <= 1;				
			end
		end
		else begin
			wea0 <= 4'h0;
			wea1 <= 4'h0;
			wea2 <= 4'h0;
			cfg_wr_en <= 0;
			cfg_rd_en <= 0;
			aux_wr_en <= 0;
			aux_rd_en <= 0;
		end
	end
end
assign bram_rddata = rdata_sel[2]?(rdata_sel[0]?douta3:douta2):(rdata_sel[1]?(rdata_sel[0]?aux_rd_dat_r:cfg_rd_dat_r)
					:(rdata_sel[0]?douta1:douta0));

/*
bram32x1024 bram_dynamic (
  .clka(bram_clk),    // input wire clka
  .rsta(bram_rst),    // input wire clka
  .wea(wea0),      // input wire [3 : 0] wea0
  .addra(addra0),  // input wire [31 : 0] addra0
  .dina(dina0),    // input wire [31 : 0] dina0
  .douta(douta0),  // output wire [31 : 0] douta0
  
  .clkb(clk),    // input wire clkb
  .rstb(reset),    // input wire rstb
  .web(web0),      // input wire [3 : 0] web0
  .addrb(addrb0),  // input wire [31 : 0] addrb0
  .dinb(dinb0),    // input wire [31 : 0] dinb0
  .doutb(doutb0)  // output wire [31 : 0] doutb0
);
assign web0 = 4'h0;
assign dinb0 = 32'h0;

bram32x1024 bram_aux (
  .clka(bram_clk),    // input wire clka
  .rsta(bram_rst),    // input wire clka
  .wea(wea1),      // input wire [3 : 0] wea0
  .addra(addra1),  // input wire [31 : 0] addra0
  .dina(dina1),    // input wire [31 : 0] dina0
  .douta(douta1),  // output wire [31 : 0] douta0
  
  .clkb(clk),    // input wire clkb
  .rstb(reset),    // input wire rstb
  .web(web1),      // input wire [3 : 0] web0
  .addrb(addrb1),  // input wire [31 : 0] addrb0
  .dinb(dinb1),    // input wire [31 : 0] dinb0
  .doutb(doutb1)  // output wire [31 : 0] doutb0
);
assign web1 = 4'h0;
assign dinb1 = 32'h0;
*/

//`ifndef BYPASS_ALLSCOPE

ila_bram ila_bram_ep(
.clk(bram_clk), // input wire clk
.probe0(bram_rst), // input wire [0:0]  probe0  
.probe1(bram_en), // input wire [0:0]  probe1 
.probe2(bram_we), // input wire [3:0]  probe2 
.probe3(bram_addr), // input wire [22:0]  probe3 
.probe4(bram_wrdata), // input wire [31:0]  probe4 
.probe5(bram_rddata), // input wire [31:0]  probe   
.probe6(wea1), // input wire [31:0]  probe   
.probe7(dina1), // input wire [31:0]  probe   
.probe8(addra1), // input wire [31:0]  probe   
.probe9(cfg_wr_addr), // input wire [31:0]  probe   
.probe10(cfg_wr_dat), // input wire [31:0]  probe   
.probe11(cfg_wr_en), // input wire [31:0]  probe   
.probe12(cfg_rd_addr), // input wire [31:0]  probe   
.probe13(cfg_rd_dat), // input wire [31:0]  probe   
.probe14(cfg_rd_en), // input wire [31:0]  probe   
.probe15(aux_wr_addr), // input wire [31:0]  probe   
.probe16(aux_wr_dat), // input wire [31:0]  probe   
.probe17(aux_wr_en), // input wire [31:0]  probe   
.probe18(aux_rd_addr), // input wire [31:0]  probe   
.probe19(aux_rd_dat), // input wire [31:0]  probe   
.probe20(aux_rd_en) // input wire [31:0]  probe   
);

//`endif
wire [31:0] cfg_adc_frmlen;
wire [31:0] cfg_adc_mode;
wire [31:0] cfg_fmc_bccode;
wire [31:0] cfg_fmc_rfcode;
wire [31:0] cfg_fmc_rfcode2;
wire [31:0] cfg_prfgen_num;
wire [31:0] cfg_prfgen_high;
wire [31:0] cfg_prfgen_len;
wire [31:0] cfg_adda_mode;
wire [31:0] cfg_dev_status;
wire [31:0] cfg_dev_version;
wire [31:0] cfg_gpio_update;
// wire [31:0] cfg_multifuc_ctrl;
wire [31:0] cfg_auxdw_0;
wire [31:0] cfg_auxdw_1;
wire [31:0] cfg_auxdw_2;
wire [31:0] cfg_auxdw_3;
wire [31:0] cfg_auxdw_4;
wire [31:0] cfg_auxdw_5;
wire [31:0] cfg_auxdw_6;
wire [31:0] cfg_auxdw_7;
wire [31:0] cfg_auxdw_8;
wire [31:0] cfg_auxdw_9;
wire [31:0] cfg_auxdw_10;
wire [31:0] cfg_auxdw_11;
wire [31:0] cfg_auxdw_12;
wire [31:0] cfg_auxdw_13;
wire [31:0] cfg_auxdw_14;
wire [31:0] cfg_auxdw_15;
wire [31:0] cfg_auxdw_16;
wire [31:0] cfg_auxdw_17;
wire [31:0] cfg_auxdw_18;
wire [31:0] cfg_auxdw_19;
wire [31:0] cfg_auxdw_20;
wire [31:0] cfg_auxdw_21;
wire [31:0] cfg_auxdw_22;
wire [31:0] cfg_auxdw_23;
wire [31:0] cfg_auxdw_24;
wire [31:0] cfg_auxdw_25;
wire [31:0] cfg_auxdw_26;
wire [31:0] cfg_auxdw_27;
wire [31:0] cfg_auxdw_28;
wire [31:0] cfg_auxdw_29;
wire [31:0] cfg_auxdw_30;
wire [31:0] cfg_auxdw_31;

wire [31:0] cfg_BC_param0;
wire [31:0] cfg_BC_param1;
wire [31:0] cfg_BC_param2;

wire [31:0] cfg_INTERFERE_param0;
wire [31:0] cfg_INTERFERE_param1;
wire [31:0] cfg_INTERFERE_param2;
wire [31:0] cfg_INTERFERE_param3;
wire [31:0] cfg_INTERFERE_param4;
wire [31:0] cfg_INTERFERE_param5;

hwreg_set hwreg_set_EP0(
.cfg_adc_frmlen(cfg_adc_frmlen),    //output [31:0]
.cfg_adc_mode(cfg_adc_mode),    //output [31:0]
.cfg_fmc_bccode(cfg_fmc_bccode),    //output [31:0]
.cfg_fmc_rfcode(cfg_fmc_rfcode),    //output [31:0]
.cfg_prfgen_num(cfg_prfgen_num),    //output [31:0]
.cfg_prfgen_high(cfg_prfgen_high),    //output [31:0]
.cfg_prfgen_len(cfg_prfgen_len),    //output [31:0]
.cfg_dev_ctrl(cfg_adda_mode),    //output [31:0]
.cfg_dev_status(cfg_dev_status),    //input [31:0]
.cfg_dev_version(cfg_dev_version),    //input [31:0]
.cfg_gpio_update(cfg_gpio_update),    //output [31:0]
.cfg_multifuc_ctrl(cfg_multifuc_ctrl),    //output [31:0]
.gpsdev_time(gps_sec),
.gpsdev_count( ppstimer),
.cfg_fmc_rfcode2(cfg_fmc_rfcode2),
.cfg_auxdw_0(cfg_auxdw_0),    //output [31:0]
.cfg_auxdw_1(cfg_auxdw_1),    //output [31:0]
.cfg_auxdw_2(cfg_auxdw_2),    //output [31:0]
.cfg_auxdw_3(cfg_auxdw_3),    //output [31:0]
.cfg_auxdw_4(cfg_auxdw_4),    //output [31:0]
.cfg_auxdw_5(cfg_auxdw_5),    //output [31:0]
.cfg_auxdw_6(cfg_auxdw_6),    //output [31:0]
.cfg_auxdw_7(cfg_auxdw_7),    //output [31:0]
.cfg_auxdw_8(cfg_auxdw_8),    //output [31:0]
.cfg_auxdw_9(cfg_auxdw_9),    //output [31:0]
.cfg_auxdw_10(cfg_auxdw_10),    //output [31:0]
.cfg_auxdw_11(cfg_auxdw_11),    //output [31:0]
.cfg_auxdw_12(cfg_auxdw_12),    //output [31:0]
.cfg_auxdw_13(cfg_auxdw_13),    //output [31:0]
.cfg_auxdw_14(cfg_auxdw_14),    //output [31:0]
.cfg_auxdw_15(cfg_auxdw_15),    //output [31:0]
.cfg_auxdw_16(cfg_auxdw_16),    //output [31:0]
.cfg_auxdw_17(cfg_auxdw_17),    //output [31:0]
.cfg_auxdw_18(cfg_auxdw_18),    //output [31:0]
.cfg_auxdw_19(cfg_auxdw_19),    //output [31:0]
.cfg_auxdw_20(cfg_auxdw_20),    //output [31:0]
.cfg_auxdw_21(cfg_auxdw_21),    //output [31:0]
.cfg_auxdw_22(cfg_auxdw_22),    //output [31:0]
.cfg_auxdw_23(cfg_auxdw_23),    //output [31:0]
.cfg_auxdw_24(cfg_auxdw_24),    //output [31:0]
.cfg_auxdw_25(cfg_auxdw_25),    //output [31:0]
.cfg_auxdw_26(cfg_auxdw_26),    //output [31:0]
.cfg_auxdw_27(cfg_auxdw_27),    //output [31:0]
.cfg_auxdw_28(cfg_auxdw_28),    //output [31:0]
.cfg_auxdw_29(cfg_auxdw_29),    //output [31:0]
.cfg_auxdw_30(cfg_auxdw_30),    //output [31:0]
.cfg_auxdw_31(cfg_auxdw_31),    //output [31:0]
.cfg_BC_param0(cfg_BC_param0),
.cfg_BC_param1(cfg_BC_param1),
.cfg_BC_param2(cfg_BC_param2),
.cfg_INTERFERE_param0(cfg_INTERFERE_param0),
.cfg_INTERFERE_param1(cfg_INTERFERE_param1),
.cfg_INTERFERE_param2(cfg_INTERFERE_param2),
.cfg_INTERFERE_param3(cfg_INTERFERE_param3),
.cfg_INTERFERE_param4(cfg_INTERFERE_param4),
.cfg_INTERFERE_param5(cfg_INTERFERE_param5),

.cfg_clk(bram_clk),    //input 
.cfg_rst(bram_rst),    //input 
.cfg_wr_addr(cfg_wr_addr),    //input [11:0]
.cfg_wr_dat(cfg_wr_dat),    //input [31:0]
.cfg_wr_en(cfg_wr_en),    //input 
.cfg_rd_addr(cfg_rd_addr),    //input [11:0]
.cfg_rd_dat(cfg_rd_dat),    //output [31:0]
.cfg_rd_en(cfg_rd_en)    //input 
);
assign adc_sel = cfg_adda_mode[1:0];
assign dac_sel = cfg_adda_mode[3:2];
assign adc_div = cfg_adc_mode;

//----------------------- BRAM load end ------------------------


//----------------------- data pre-process start ------------------------
wire adc_valid;
wire dac_valid;
assign adc_valid = fifo_wr_valid_ctrl;
// assign dac_valid = mfifo_rd_enable_ctrl;//改动点
 
assign	mfifo_wr_clr = mfifo_wr_clr_ctrl;	
assign	mfifo_wr_valid = mfifo_wr_valid_ctrl;
assign	mfifo_wr_enable = mfifo_wr_enable_ctrl;

assign	mfifo_rd_clr = mfifo_rd_clr_ctrl;	
assign	mfifo_rd_valid = 1'b0;
//assign	mfifo_rd_enable = mfifo_rd_enable_ctrl;
  

wire [1:0] adc_sel;
wire [1:0] dac_sel;
wire [31:0] adc_div;

wire [48*32-1:0] ctrl_data;
wire [16*32-1:0] status_data;
wire [24*32-1:0] param_data;
wire [32*32-1:0] debug_data;
//wire			 DAC_VOUT;
wire dac_valid_adjust;
data_pre
#(
.LOCAL_DWIDTH(LOCAL_DWIDTH)
)data_pre_EP0
(
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


.prffix_inter(prffix),
.preprf_inter(preprf),
.prfin_inter(prfin),
.RF_TXEN_inter(RF_TXEN),
.BC_TXEN_inter(BC_TXEN),



.fifo_wr_clr(fifo_wr_clr_ctrl),
.fifo_wr_valid(adc_valid),
.fifo_wr_enable(fifo_wr_enable_ctrl),
.cfg_adc_frmlen(cfg_adc_frmlen),
.rec_fifo_overflow(rec_fifo_overflow),
.mfifo_rd_enable(mfifo_rd_enable),
.mfifo_rd_data(mfifo_rd_data),


.ctrl_data(ctrl_data),
.status_data(status_data),
.param_data(param_data),
.debug_data(debug_data),

.adc_sel(adc_sel),
.dac_sel(dac_sel),
.adc_div(adc_div),
.cfg_dev_adc_iodelay(cfg_dev_adc_iodelay),
.cfg_dev_adc_ctrl(cfg_dev_adc_ctrl),
// fft param
.ramrpu_clk  (bram_clk  ),
.ramrpu_en   (bram_en   ),
.ramrpu_we   (wea3   ),
.ramrpu_addr (addra3 ),
.ramrpu_din  (dina3  ),
.ramrpu_dout (douta3 ),
.ramrpu_rst  (bram_rst  ),


.rama_clk(bram_clk)         ,
.rama_en(bram_en)          ,
.rama_we(wea1)          ,
.rama_addr(addra1)        ,
.rama_din(dina1)         ,
.rama_dout(douta1)         ,
.rama_rst(bram_rst),


.ramb_clk(bram_clk)         ,
.ramb_en(bram_en)          ,
.ramb_we(wea2)          ,
.ramb_addr(addra2)        ,
.ramb_din(dina2)         ,
.ramb_dout(douta2)         ,
.ramb_rst(bram_rst),


.cfg_INTERFERE_param0(cfg_INTERFERE_param0),
.cfg_INTERFERE_param1(cfg_INTERFERE_param1),
.cfg_INTERFERE_param2(cfg_INTERFERE_param2),
.cfg_INTERFERE_param3(cfg_INTERFERE_param3),
.cfg_INTERFERE_param4(cfg_INTERFERE_param4),
.cfg_INTERFERE_param5(cfg_INTERFERE_param5),

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

//dma data
.adc_dma_valid(adc_dma_valid),
.adc_dma_data(adc_dma_data),
.adc_dma_last(adc_dma_last),
.adc_dma_ready(adc_dma_ready),
.adc_dma_start(adc_dma_start),	


.vio_dataout(vio_dataout),
.vio_selchirp(vio_selchirp),
.adc_valid(disturb_adc_valid),
.rf_out(rf_out),
.rf_tx_en_v(rf_tx_en_v),
.rf_tx_en_h(rf_tx_en_h),
.bc_tx_en	(bc_tx_en),
.channel_sel	(channel_sel),
.adc_valid_expand	(adc_valid_expand),
.zero_sel	(zero_sel),
.dac_valid_adjust	(dac_valid_adjust),
.trt_close_flag  (trt_close_flag),
.trr_close_flag  (trr_close_flag)
);


//----------------------- data pre-process end ------------------------


//----------------------- VIO assignment ------------------------
wire vio_sel;
(* keep="true" *)wire [1:0] vio_pl_in;

(* keep="true" *)wire vio_TX_EN, vio_RXCTL, vio_SWITCH;
(* keep="true" *)wire vio_BC_CS, vio_BC_CLK, vio_BC_TXD, vio_BC_RXD, vio_BC_LATCH, vio_BC_RXEN, vio_BC_TXEN;
wire [31:0] vio_rfcmd;
wire [31:0] vio_bccmd;
wire vio_uart, vio_rfen;
wire [15:0] vio_pulse_len;
wire [15:0] vio_pulse_num;	
wire [15:0] vio_pulse_high;

vio_rfctl vio_rfctl_ep(
.clk(clk),
.probe_in0(vio_pl_in),
.probe_out0({vio_TX_EN, vio_RXCTL, vio_SWITCH}),
.probe_out1(vio_sel),
.probe_out2(vio_uart),
.probe_out3(vio_rfen),
.probe_out4(vio_rfcmd),
.probe_out5(vio_bccmd),
.probe_out6(vio_pulse_num),
.probe_out7(vio_pulse_high),
.probe_out8(vio_pulse_len),
.probe_out9({vio_BC_CS, vio_BC_CLK, vio_BC_TXD, vio_BC_LATCH, vio_BC_RXEN, vio_BC_TXEN})
);

reg vio_rfen_r1, vio_rfen_r2;
reg  set_rfen;
reg  set_bcen;
reg [31:0] set_rfdat = 0;
reg [31:0] set_rfdat2 = 0;
reg [31:0] set_bcdat = 0;

reg [31:0] fmc_bccode_r1;
reg [31:0] fmc_rfcode_r1;
reg [31:0] fmc_rfcode2_r1;
reg [31:0] fmc_bccode_r2;
reg [31:0] fmc_rfcode_r2;
reg [31:0] fmc_rfcode2_r2;
always@(posedge clk)begin
	vio_rfen_r1 <= vio_rfen;
	vio_rfen_r2 <= vio_rfen_r1;
	fmc_bccode_r1 <= cfg_fmc_bccode;
	fmc_bccode_r2 <= fmc_bccode_r1;
	fmc_rfcode_r1 <= cfg_fmc_rfcode;
	fmc_rfcode_r2 <= fmc_rfcode_r1;
	fmc_rfcode2_r1 <= cfg_fmc_rfcode2;
	fmc_rfcode2_r2 <= fmc_rfcode2_r1;
	set_rfen <= (vio_rfen_r1 & (~vio_rfen_r2)) | (fmc_rfcode_r1[31] & (~fmc_rfcode_r2[31]));
	set_bcen <= (vio_rfen_r1 & (~vio_rfen_r2)) | (fmc_bccode_r1[31] & (~fmc_bccode_r2[31]));
	
	if(fmc_rfcode_r1[31] & (~fmc_rfcode_r2[31]))set_rfdat2 <= fmc_rfcode2_r1;
	if(vio_rfen_r1 & (~vio_rfen_r2))set_rfdat <= vio_rfcmd;
	else if(fmc_rfcode_r1[31] & (~fmc_rfcode_r2[31]))set_rfdat <= fmc_rfcode_r1;
	if(vio_rfen_r1 & (~vio_rfen_r2))set_bcdat <= vio_bccmd;
	else if(fmc_bccode_r1[31] & (~fmc_bccode_r2[31]))set_bcdat <= fmc_bccode_r1;
end
wire preprf;
wire RF_TXEN;
wire  BC_TXEN;
wire  BC_LATCH_IN;
wire  BC_DYNLAT;
wire  BC_LATCH_OUT;
//control_hub control_hub_EP0(
//.adc_clk(adc_clk),    //input 
//.adc_rst(adc_rst),    //input 
//.preprf(preprf),    //input 
//.prfin(prfin),    //input 
//.dac_valid(dac_valid),    //input 
//.adc_valid(adc_valid),    //input 
//.DAC_VOUT(mfifo_rd_enable),    //output 
//.RF_TXEN(RF_TXEN),    //output 
//.BC_TXEN(BC_TXEN),    //output 
//.BC_LATCH_IN(1'b0),    //input 
//.BC_DYNLAT(1'b0),    //input 
//.BC_LATCH_OUT()    //output 
//);

// `ifndef BYPASS_ALLSCOPE
// ila_prf ila_prf_ep(
// .clk(clk),
// .probe0(preprf),
// .probe1(prfin),
// .probe2(adc_valid),
// .probe3(dac_valid),
// .probe4(mfifo_rd_enable),
// .probe5(RF_TXEN),
// .probe6(BC_TXEN),
// .probe7(BC_LATCH_IN),
// .probe8(BC_LATCH_OUT),
// .probe9(BC_A_TXEN),
// .probe10(BC_B_TXEN),
// .probe11(PPS_GPS_PL)
// );
// `endif
//----------------------- RF control start ------------------------
// set_rfdat[7:0]: channel att
// set_rfdat[15:8]: calib att
// set_rfdat[16]: external refclk select
// set_rfdat[17]: RF_TX_EN static control select
// set_rfdat[18]: static RF_TX_EN
// set_rfdat[19]: static RF_RXCTL
// set_rfdat[20]: static RF_SWITCH

// set_rfdat[21]: RF_TX_EN2 static control select
// set_rfdat[22]: static RF_TX_EN2
// set_rfdat[23]: static RF_RXCTL2
// set_rfdat[24]: static RF_SWITCH2

// set_rfdat[28]: RF_TX_EN_FORCE1
// set_rfdat[29]: RF_TX_EN_FORCE2
wire  uart_tx;
send_rf_cmd send_rf_cmd_EP0(
.clk(clk),    //input 
.reset(reset),    //input 
.set_en(set_rfen),    //input 
.set_dat(set_rfdat),    //input [7:0]
.uart_tx(uart_tx)    //output 
);

ila_uart u_ila_uart (
	.clk(clk), // input wire clk


	.probe0(cfg_fmc_rfcode), // input wire [31:0]  probe0  
	.probe1(cfg_fmc_rfcode2), // input wire [31:0]  probe1 
	.probe2(set_rfen), // input wire [0:0]  probe2 
	.probe3(set_rfdat), // input wire [31:0]  probe3 
	.probe4(set_rfdat2), // input wire [31:0]  probe4 
	.probe5(uart_tx) // input wire [0:0]  probe5
);

wire [1:0] RF_LOCK;
wire RF_TX_EN;
wire RF_RXCTL;
wire RF_SWITCH;
// calibration: RF_SWITCH=1, RF_RXCTL=0, RF_TX_EN=0 
// normal TX: RF_SWITCH=0, RF_RXCTL=0, RF_TX_EN=1 
// normal RX: RF_SWITCH=0, RF_RXCTL=1, RF_TX_EN=0 
assign RF_TX_EN = set_rfdat[18]; //set_rfdat[17]?set_rfdat[18]:dac_valid;
assign RF_RXCTL = set_rfdat[19];
assign RF_SWITCH = set_rfdat[20];

wire RF_TX_EN2;
wire RF_RXCTL2;
wire RF_SWITCH2;
assign RF_TX_EN2 = set_rfdat[22]; //set_rfdat[21]?set_rfdat[22]:dac_valid;
assign RF_RXCTL2 = set_rfdat[23];
assign RF_SWITCH2 = set_rfdat[24];

wire RF_TX_EN_FORCE1;
wire RF_TX_EN_FORCE2;
assign RF_TX_EN_FORCE1 = set_rfdat[28];
assign RF_TX_EN_FORCE2 = set_rfdat[29];


// localparam DWIDTH = 20;//改动点
// reg [DWIDTH:0] CFGBC_OUTEN_r = 0;
// always@(posedge adc_clk)begin
// 	CFGBC_OUTEN_r <= {CFGBC_OUTEN_r[DWIDTH-1:0], dac_valid};
// end
// // output assign
// // assign RF_A_TXEN = vio_sel?vio_TX_EN:(RF_TX_EN_FORCE1?RF_TX_EN:(RF_TXEN&RF_TX_EN));//改动点
// assign RF_A_TXEN = |CFGBC_OUTEN_r;//改动点
assign RF_A_UR_TX = vio_uart?RF_A_UR_RX:uart_tx;
// assign RF_A_RXCTL = vio_sel?vio_RXCTL:RF_RXCTL;//改动点
assign RF_A_RXCTL = 1;//改动点
assign RF_A_SWITCH = vio_sel?vio_SWITCH:RF_SWITCH;
assign RF_LOCK[0] = RF_A_LOCK;

assign RF_B_TXEN = vio_sel?vio_TX_EN:(RF_TX_EN_FORCE2?RF_TX_EN2:(RF_TXEN&RF_TX_EN2));
assign RF_B_UR_TX = vio_uart?RF_B_UR_RX:uart_tx;
assign RF_B_RXCTL = 1;
assign RF_B_SWITCH = vio_sel?vio_SWITCH:RF_SWITCH2;
assign RF_LOCK[1] = RF_B_LOCK;

//assign UART_PL_GPS = DBG_UART_RX;
//assign DBG_UART_TX = vio_sel?RF_A_UR_RX:RF_A_UR_TX;


assign vio_pl_in = RF_LOCK;
//----------------------- RF control end ------------------------

//----------------------- BC control start ------------------------
wire	               	BC_clka         ;
wire	                BC_ena          ;
wire	[3 : 0]         BC_wea          ;
wire	[31 : 0]        BC_addra        ;
wire	[31 : 0]        BC_dina         ;
wire	[31 : 0]        BC_douta        ;
wire	                BC_rsta         ;


// ila_bcld ila_bcld_EP0
// (
// .clk(BC_sys_clk),
// .probe0(BC_ld_o),
// .probe1(BC_trt_o),
// .probe2(BC_trr_o),
// .probe3(preprf),
// .probe4(BC_TXEN)
// );

// bc_wrapper#(
// //.LANE_BIT(26),                        
// //.FRAME_DATA_BIT(106), 
// //.CHIP_NUM(BC_CHIP_NUM)
// )bc_wrapper_EP0
// (
// .sys_clk(BC_sys_clk) 	 ,
// .sys_rst(BC_sys_rst)      ,
// .prf_pin_in(preprf)   ,
// .tr_en(BC_TXEN),
// .scl_o_h(BC_scl_o)    	 ,
// .rst_o_h(BC_rst_o)        ,
// .sel_o_h(BC_sel_o)        ,
// .ld_o_h(BC_ld_o)         ,
// .dary_o_h(BC_dary_o)       ,
// .trt_o_h(BC_trt_o)        ,
// .trr_o_h(BC_trr_o)        ,
// .sd_o_h(BC_sd_o)         ,

			 
// .rama_clk(bram_clk)         ,
// .rama_en(1'b1)          ,
// .rama_we(wea0)          ,
// .rama_addr(addra0)        ,
// .rama_din(dina0)         ,
// .rama_dout(douta0)         ,
// .rama_rst(bram_rst),

// .app_param0(cfg_BC_param0)	 ,
// .app_param1(cfg_BC_param1)	 ,
// .app_param2(cfg_BC_param2)	 
// );
wire trt_tp_0;     	    
wire trr_tp_0;     	    
wire trt_tp_1;     	    
wire trr_tp_1;     	    
wire trt_tp_2;     	    
wire trr_tp_2;     	    
wire trt_tp_3;     	    
wire trr_tp_3;     

assign trt_o_p_0 =  !trt_close_flag & trt_tp_0;//
assign trr_o_p_0 =  !trr_close_flag & trr_tp_0;
assign trt_o_p_1 =  !trt_close_flag & trt_tp_1;
assign trr_o_p_1 =  !trr_close_flag & trr_tp_1;
assign trt_o_p_2 =  !trt_close_flag & trt_tp_2;
assign trr_o_p_2 =  !trr_close_flag & trr_tp_2;
assign trt_o_p_3 =  !trt_close_flag & trt_tp_3;
assign trr_o_p_3 =  !trr_close_flag & trr_tp_3;


bc_wrapper u_bc_wrapper
(
. sys_clk 	    (BC_sys_clk 	    ),
. sys_rst 	    (BC_sys_rst 	    ),
. prf_pin_in    (preprf    	        ),
. tr_en         (bc_tx_en         	),
. sel_o_p       (BC_sel_o       	),
. scl_o_p    	(BC_scl_o    	    ),
. sd_o_p        (BC_sd_o        	),
. ld_o_p        (BC_ld_o        	),
. dary_o_p      (BC_dary_o      	),
. trt_o_p_0     (trt_tp_0			),
. trr_o_p_0     (trr_tp_0			),
. trt_o_p_1     (trt_tp_1			),
. trr_o_p_1     (trr_tp_1			),
. trt_o_p_2     (trt_tp_2			),
. trr_o_p_2     (trr_tp_2			),
. trt_o_p_3     (trt_tp_3			),
. trr_o_p_3     (trr_tp_3			),
. rst_o_p       (BC_rst_o       	),

. rama_clk      (bram_clk      	    ),
. rama_en       (1'b1       	    ),
. rama_we       (wea0       	    ),
. rama_addr     (addra0     	    ),
. rama_din      (dina0      	    ),
. rama_dout     (douta0     	    ),
. rama_rst      (bram_rst      	    ),

. app_param0	(cfg_BC_param0      ),
. app_param1	(cfg_BC_param1      ),
. app_param2	(cfg_BC_param2      ),
. sel_param		(channel_sel      	)
); 



//set_bcdat[15:0]: CFGBC_CODE
//set_bcdat[27:16]: Dynamic load numbers
//set_bcdat[28]: channel 0 TX enable
//set_bcdat[29]: channel 1 TX enable
//set_bcdat[30]: dynamic control select
//set_bcdat[31]: posedge active

/* wire BC_TX_EN;
wire BC_TX_EN2;
assign BC_TX_EN = set_bcdat[28]; //set_rfdat[17]?set_rfdat[18]:dac_valid;
assign BC_TX_EN2 = set_bcdat[29]; //set_rfdat[21]?set_rfdat[22]:dac_valid;
assign BC_DYNLAT = set_bcdat[30];


wire [31:0] CFGBC_GRPNUM;
wire [31:0] CFGBC_MODE;
wire [31:0] CFGBC_DELAY;
wire CFGBC_OUTEN;
assign CFGBC_GRPNUM = cfg_auxdw_0;
assign CFGBC_MODE = cfg_auxdw_1;
assign CFGBC_DELAY = cfg_auxdw_3;
assign CFGBC_OUTEN = cfg_auxdw_2[0];
assign PRFIN_IOSIMU = cfg_auxdw_2[1];
wire BC_A_LATCH_OUT;
assign BC_LATCH_IN = BC_A_LATCH_OUT;
assign BC_A_LATCH = BC_LATCH_OUT;
assign BC_B_LATCH = BC_LATCH_OUT;

BC_SPI_CTRL BC_SPI_CTRL_EP0(
.clk(bram_clk),    //input 
.reset(bram_rst),    //input 
.rama_clk(bram_clk),    //input 
.rama_rst(bram_rst),    //input 
.rama_we(wea0),    //input [7 : 0]
.rama_addr(addra0),    //input [31:0]
.rama_din(dina0),    //input [63:0]
.rama_dout(douta0),    //output [63:0]
.CFGBC_GRPNUM(CFGBC_GRPNUM),    //input [31:0]
.CFGBC_MODE(CFGBC_MODE),    //input [31:0]
.CFGBC_OUTEN(BC_TXEN & BC_TX_EN),    //input 
.CFGBC_DELAY(CFGBC_DELAY),    //input [31:0]

.BC_CLK(BC_A_CLK),    //output 
.BC_TXD(BC_A_TXD),    //output [3:0]
.BC_CS(BC_A_CS),    //output 
.BC_RXEN(BC_A_RXEN),    //output 
.BC_TXEN(BC_A_TXEN),    //output 
.BC_LATCH(BC_A_LATCH_OUT),    //output 
.BC_RXD(BC_A_RXD)    //output 
);
BC_SPI_CTRL BC_SPI_CTRL_EP1(
.clk(bram_clk),    //input 
.reset(bram_rst),    //input 
.rama_clk(bram_clk),    //input 
.rama_rst(bram_rst),    //input 
.rama_we(wea1),    //input [7 : 0]
.rama_addr(addra1),    //input [31:0]
.rama_din(dina1),    //input [63:0]
.rama_dout(douta1),    //output [63:0]
.CFGBC_GRPNUM(CFGBC_GRPNUM),    //input [31:0]
.CFGBC_MODE(CFGBC_MODE),    //input [31:0]
.CFGBC_OUTEN(BC_TXEN & BC_TX_EN2),    //input 
.CFGBC_DELAY(CFGBC_DELAY),    //input [31:0]

.BC_CLK(BC_B_CLK),    //output 
.BC_TXD(BC_B_TXD),    //output [3:0]
.BC_CS(BC_B_CS),    //output 
.BC_RXEN(BC_B_RXEN),    //output 
.BC_TXEN(BC_B_TXEN),    //output 
.BC_LATCH(BC_B_LATCH_OUT),    //output 
.BC_RXD(BC_B_RXD)    //output 
); */
//----------------------- BC control end ------------------------

//assign prffix = prfmux; 	// directly pass through for TR test version


reg  set_addr;
reg  set_speed;
reg [31:0] set_data_1;
reg [1:0] set_data_2;
wire [71:0] feedback_all;
wire  feedback_en;
wire [31:0] status;
wire addr_set_over;
wire speed_set_over;

reg [31:0] CFGMT_MODE;
reg [31:0] CFGMT_ADDR;
reg [31:0] CFGMT_SPEED;
reg [31:0] CFGMT_STATUS;
ModbusRTUtop ModbusRTUtop_EP0(
.rs485_rx(rs485_rx),    //input 
.rs485_tx(rs485_tx),    //output 
.rs485_en(rs485_en),    //output 
.clk(clk),    //input 
.rst(reset),    //input 
.set_addr(set_addr),    //input 
.set_speed(set_speed),    //input 
.set_data_1(set_data_1),    //input [31:0]
.set_data_2(set_data_2),    //input [1:0]
.feedback_all(feedback_all),    //output [71:0]
.feedback_en(feedback_en),    //output 
.addr_set_over(addr_set_over),
.speed_set_over(speed_set_over),
.status(status)    //output [31:0]
);
reg feedback_en_r1, feedback_en_r2;
reg addr_set_done = 0;
reg speed_set_done = 0;
reg [31:0] status_r1;
always@(posedge bram_clk)begin
	feedback_en_r2 <= feedback_en_r1;
	if(bram_rst)CFGMT_STATUS <= 0;
	else if(feedback_en_r2)CFGMT_STATUS <= status_r1;
end
always@(posedge clk)begin
	feedback_en_r1 <= feedback_en;
	if(feedback_en)status_r1 <= status;
	
	if(set_addr)addr_set_done <= 0;
	else if(addr_set_over)addr_set_done <= 1;

	if(set_speed)speed_set_done <= 0;
	else if(speed_set_over)speed_set_done <= 1;
end
assign cfg_dev_status = CFGMT_STATUS;
assign cfg_dev_version = {16'h0715, {14'h00, speed_set_done, addr_set_done}};
reg [31:0] CFGMT_MODE_r;
always@(posedge clk)begin
	if(reset)begin
		CFGMT_MODE_r <= 0;
		CFGMT_MODE <= 0;
		CFGMT_ADDR <= 0;
		CFGMT_SPEED <= 0;	
		set_addr <= 0;
		set_speed <= 0;
		set_data_1 <= 0;
		set_data_2 <= 0;
	end
	else begin
		CFGMT_MODE_r <= CFGMT_MODE;
		CFGMT_MODE <= cfg_auxdw_4;
		CFGMT_ADDR <= cfg_auxdw_5;
		CFGMT_SPEED <= cfg_auxdw_6;	
		
		set_addr <= CFGMT_MODE[0] & (~CFGMT_MODE_r[0]);
		set_speed <= CFGMT_MODE[1] & (~CFGMT_MODE_r[1]);
		if(CFGMT_MODE[0] & (~CFGMT_MODE_r[0]))set_data_1 <= CFGMT_ADDR;
		if(CFGMT_MODE[1] & (~CFGMT_MODE_r[1]))set_data_2 <= CFGMT_SPEED[1:0];
	end
end
// `ifndef BYPASS_ALLSCOPE
// ila_motor ila_motor_ep(
// .clk(clk),
// .probe0(set_addr),
// .probe1(set_speed),
// .probe2(set_data_1),
// .probe3(set_data_2),
// .probe4(feedback_en),
// .probe5(status),
// .probe6(addr_set_over),
// .probe7(speed_set_over),
// .probe8(CFGMT_STATUS)
// );
// `endif
// GPS resolve
wire [44*8-1:0] msg_dat;
wire [2:0] msg_stat;
wire msg_en;
gps_wrap gps(
.clk(clk),    //input 
.reset(reset),    //input 
.uart_rx(UART_GPS_PL),    //input 
.msg_dat(msg_dat),    //output [MSG_LEN*8-1:0]
.msg_stat(msg_stat),    //output [2:0]
.msg_en(msg_en)    //output 
);

wire select_simu_imu;
assign select_simu_imu = cfg_auxdw_7[0];
assign imu_rxdata = select_simu_imu?BC_A_RXD:UART_IMU_PL;															  
// imu resolve
wire [107*8-1:0] imu_dat;
wire imu_stat;
wire imu_en;
imu_wrap imu(
.clk(clk),    //input 
.reset(reset),    //input 
.uart_rx(imu_rxdata),    //input 
.imu_dat(imu_dat),    //output [76*8-1:0]
.imu_stat(imu_stat),    //output 
.imu_en(imu_en)    //output 
);


reg imu_en_r1, imu_en_r2;
always@(posedge bram_clk)begin
	if(bram_rst)begin
		status_imu <= 0;
		debug_imu <= 0;
		imu_en_r1 <= 0;
		imu_en_r2 <= 0;
	end
	else begin
		imu_en_r1 <= imu_en;
		imu_en_r2 <= imu_en_r1;	
		if(imu_en_r1&(~imu_en_r2))status_imu <= {imu_dat[107*8-1:99*8], imu_dat[68*8-1:32*8]};
		if(imu_en_r1&(~imu_en_r2))debug_imu <= {imu_dat[99*8-1:68*8], imu_dat[32*8-1:0*8]};
	end
end

ila_zero_trt u_ila_zero_trt (
	.clk(adc_clk), // input wire clk


	.probe0(trt_o_p_0), // input wire [0:0]  probe0  
	.probe1(trr_o_p_0), // input wire [0:0]  probe1 
	.probe2(trt_o_p_1), // input wire [0:0]  probe2 
	.probe3(trr_o_p_1), // input wire [0:0]  probe3 
	.probe4(trt_o_p_2), // input wire [0:0]  probe4 
	.probe5(trr_o_p_2), // input wire [0:0]  probe5 
	.probe6(trt_o_p_3), // input wire [0:0]  probe6 
	.probe7(trr_o_p_3) // input wire [0:0]  probe7
);
wire [255:0]adc_data0,adc_data1;
genvar kk;
generate
	for(kk = 0;kk < 8;kk = kk + 1)begin:blk1
        assign adc_data0[(kk+1)*32-1:kk*32] =   {m02_axis_tdata[(kk+1)*16-1:kk*16],m03_axis_tdata[(kk+1)*16-1:kk*16]};
        assign adc_data1[(kk+1)*32-1:kk*32] =   {m00_axis_tdata[(kk+1)*16-1:kk*16],m01_axis_tdata[(kk+1)*16-1:kk*16]};
    end
endgenerate

ila_txrx_change u_ila_txrx_change (
	.clk(adc_clk), // input wire clk


	.probe0 (disturb_adc_valid	), // input wire [0:0]  probe0  
	.probe1 (adc_valid_expand	), // input wire [0:0]  probe1 
	.probe2 (dac_valid_adjust	), // input wire [0:0]  probe2 
	.probe3 (rf_tx_en_v			), // input wire [0:0]  probe3 
	.probe4 (rf_tx_en_h			), // input wire [0:0]  probe4 
	.probe5 ( trt_o_p_0    		), // input wire [0:0]  probe5 
	.probe6 ( trr_o_p_0    		), // input wire [0:0]  probe6 
	.probe7 ( trt_o_p_1    		), // input wire [0:0]  probe7 
	.probe8 ( trr_o_p_1    		), // input wire [0:0]  probe8 
	.probe9 ( trt_o_p_2    		), // input wire [0:0]  probe9 
	.probe10( trr_o_p_2    		), // input wire [0:0]  probe10 
	.probe11( trt_o_p_3    		), // input wire [0:0]  probe11 
	.probe12( trr_o_p_3    		), // input wire [0:0]  probe12
	.probe13(adc_data1[31:0]    ) // input wire [0:0]  probe12
);
endmodule
