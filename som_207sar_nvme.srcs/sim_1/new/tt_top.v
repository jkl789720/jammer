`timescale 1ns / 1ps

module tt_top;
// wire list for top
wire  SYSREF_ANALOG_N;
wire  SYSREF_ANALOG_P;
wire [0:0] CLK_DAC_N;
wire [0:0] CLK_DAC_P;
wire [1:1] CLK_ADC_N;
wire [1:1] CLK_ADC_P;
wire  SYSREF_PL_N;
wire  SYSREF_PL_P;
wire  CLK_DCLK_PL_N;
wire  CLK_DCLK_PL_P;
wire [3:0] ADC_P;
wire [3:0] ADC_N;
wire [3:0] DAC_P;
wire [3:0] DAC_N;
wire  CLK_PL_SYS_N;
wire  CLK_PL_SYS_P;
wire  CLK_PL_DDR_N;
wire  CLK_PL_DDR_P;
wire  BC_A_CLK;
wire  BC_A_CS;
wire  BC_A_LATCH;
wire  BC_A_RXD;
wire  BC_A_RXEN;
wire [3:0] BC_A_TXD;
wire  BC_A_TXEN;
wire  BC_B_CLK;
wire  BC_B_CS;
wire  BC_B_LATCH;
wire  BC_B_RXD;
wire  BC_B_RXEN;
wire [3:0] BC_B_TXD;
wire  BC_B_TXEN;
wire  RF_A_LOCK;
wire  RF_A_RXCTL;
wire  RF_A_SWITCH;
wire  RF_A_TXEN;
wire  RF_A_UR_RX;
wire  RF_A_UR_TX;
wire  RF_B_LOCK;
wire  RF_B_RXCTL;
wire  RF_B_SWITCH;
wire  RF_B_TXEN;
wire  RF_B_UR_RX;
wire  RF_B_UR_TX;
wire  PL_SPI_SCK;
wire  PL_SPI_CS_N;
wire  PL_SPI_MOSI;
wire  PL_SPI_MISO;
wire  RST_GPS_N;
wire  GPS_EVENT;
wire  PPS_GPS_PL;
wire  UART_PL_GPS;
wire  UART_GPS_PL;
wire  DBG_UART_TX;
wire  DBG_UART_RX;
wire  DBG_PPSOUT;
wire  FPGA_SYNC;
wire  PL_DBG_LED;
reg UART_IMU_PL;
always begin
	UART_IMU_PL = 0;
	#20000;
	UART_IMU_PL = 1;
	#10000;
end

assign ADC_P = 0;
assign ADC_N = 0;
assign BC_A_RXD = 0;
assign BC_B_RXD = 0;
assign RF_A_LOCK = 0;
assign RF_A_UR_RX = 0;
assign RF_B_LOCK = 0;
assign RF_B_UR_RX = 0;
assign PL_SPI_MISO = 0;
//assign PPS_GPS_PL = 1;
assign UART_GPS_PL = 0;
assign DBG_UART_RX = 0;
assign FPGA_SYNC = 0;

top UUT(
.SYSREF_ANALOG_N(SYSREF_ANALOG_N),    //input 
.SYSREF_ANALOG_P(SYSREF_ANALOG_P),    //input 
.CLK_DAC_N(CLK_DAC_N),    //input [0:0]
.CLK_DAC_P(CLK_DAC_P),    //input [0:0]
.CLK_ADC_N(CLK_ADC_N),    //input [1:1]
.CLK_ADC_P(CLK_ADC_P),    //input [1:1]
.SYSREF_PL_N(SYSREF_PL_N),    //input 
.SYSREF_PL_P(SYSREF_PL_P),    //input 
.CLK_DCLK_PL_N(CLK_DCLK_PL_N),    //input 
.CLK_DCLK_PL_P(CLK_DCLK_PL_P),    //input 
.ADC_P(ADC_P),    //input [3:0]
.ADC_N(ADC_N),    //input [3:0]
.DAC_P(DAC_P),    //output [3:0]
.DAC_N(DAC_N),    //output [3:0]
.CLK_PL_SYS_N(CLK_PL_SYS_N),    //input 
.CLK_PL_SYS_P(CLK_PL_SYS_P),    //input 
.CLK_PL_DDR_N(CLK_PL_DDR_N),    //input 
.CLK_PL_DDR_P(CLK_PL_DDR_P),    //input 
.BC_A_CLK(BC_A_CLK),    //output 
.BC_A_CS(BC_A_CS),    //output 
.BC_A_LATCH(BC_A_LATCH),    //output 
.BC_A_RXD(BC_A_RXD),    //input 
.BC_A_RXEN(BC_A_RXEN),    //output 
.BC_A_TXD(BC_A_TXD),    //output [3:0]
.BC_A_TXEN(BC_A_TXEN),    //output 
// .BC_B_CLK(BC_B_CLK),    //output 
// .BC_B_CS(BC_B_CS),    //output 
// .BC_B_LATCH(BC_B_LATCH),    //output 
// .BC_B_RXD(BC_B_RXD),    //input 
// .BC_B_RXEN(BC_B_RXEN),    //output 
// .BC_B_TXD(BC_B_TXD),    //output [3:0]
// .BC_B_TXEN(BC_B_TXEN),    //output 
.RF_A_LOCK(RF_A_LOCK),    //input 
.RF_A_RXCTL(RF_A_RXCTL),    //output 
.RF_A_SWITCH(RF_A_SWITCH),    //output 
.RF_A_TXEN(RF_A_TXEN),    //output 
.RF_A_UR_RX(RF_A_UR_RX),    //input 
.RF_A_UR_TX(RF_A_UR_TX),    //output 
.RF_B_LOCK(RF_B_LOCK),    //input 
.RF_B_RXCTL(RF_B_RXCTL),    //output 
.RF_B_SWITCH(RF_B_SWITCH),    //output 
.RF_B_TXEN(RF_B_TXEN),    //output 
.RF_B_UR_RX(RF_B_UR_RX),    //input 
.RF_B_UR_TX(RF_B_UR_TX),    //output 
.PL_SPI_SCK(PL_SPI_SCK),    //output 
.PL_SPI_CS_N(PL_SPI_CS_N),    //output 
.PL_SPI_MOSI(PL_SPI_MOSI),    //output 
.PL_SPI_MISO(PL_SPI_MISO),    //input 
//.RST_GPS_N(RST_GPS_N),    //output 
//.GPS_EVENT(GPS_EVENT),    //output 
.PPS_GPS_PL(PPS_GPS_PL),    //input 
.UART_PL_GPS(UART_PL_GPS),    //output 
.UART_GPS_PL(UART_GPS_PL),    //input 
.UART_IMU_PL(UART_IMU_PL),    //input 
.DBG_UART_TX(DBG_UART_TX),    //output 
.DBG_UART_RX(DBG_UART_RX),    //input 
.DBG_PPSOUT(DBG_PPSOUT),    //output 
.FPGA_SYNC(FPGA_SYNC),    //input 
.PL_DBG_LED(PL_DBG_LED)    //output 
);

reg clk150m;
reg clk300m;
reg clkref;
reg clk1k;
always begin
	clk300m = 0;
	#1.6666;
	clk300m = 1;
	#1.6666;
end
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
always begin
	clk1k = 0;
	#500000;
	clk1k = 1;
	#500000;
end
assign SYSREF_ANALOG_P = clkref;
assign SYSREF_ANALOG_N = ~clkref;
assign CLK_DCLK_PL_N = clk150m;
assign CLK_DCLK_PL_P = ~clk150m;
assign SYSREF_PL_P = clkref;
assign SYSREF_PL_N = ~clkref;
assign CLK_ADC_P = clk300m;
assign CLK_ADC_N = ~clk300m;
assign CLK_DAC_P = clk300m;
assign CLK_DAC_N = ~clk300m;
assign CLK_PL_SYS_P = clk300m;
assign CLK_PL_SYS_N = ~clk300m;
assign CLK_PL_DDR_P = clk300m;
assign CLK_PL_DDR_N = ~clk300m;
assign prfin_ex = clk1k;
assign PL_UART_RX = 1;
reg PPS;
always begin
	PPS = 0;
	#20000;
	PPS = 1;
	#20000;
end
assign PPS_GPS_PL = PPS;
`include "functask.v"
initial begin
	force UUT.selchirp = 2'b00;
	force UUT.cfg_dev_adc_ctrl[18:16] = 3'b011;
	force UUT.cfg_dev_adc_iodelay[18:16] = 32'h00010040;
	force UUT.pl_resetn = 0;
	force UUT.bram_rst = 1;
	force UUT.multifunc_EP0.CFGMT_STATUS = 32'h00EF7152;
	cct_init;
	#1000;
	force UUT.pl_resetn = 1;
	force UUT.bram_rst = 0;
	#1000;
	force UUT.cfg_dev_adc_iodelay = 32'h000101F0;

	
	force UUT.multifunc_EP0.cfg_rd_addr = 12'h034;
	@(posedge UUT.multifunc_EP0.bram_clk);
	force UUT.multifunc_EP0.cfg_rd_en = 1;
	@(posedge UUT.multifunc_EP0.bram_clk);
	force UUT.multifunc_EP0.cfg_rd_en = 0;
	#1000;
	
	
	cct_start(32'h00700000, 32'h00000000, /*sel*/1, 1, /*rep*/0, 0, /*con*/ 0, 0, /*clr*/ 0, 0, /*div*/1, 1);
	#200000;
	cct_stop;
	#30000;
	
	// select active adc path
	force UUT.multifunc_EP0.cfg_adc_mode = 32'b0101;
	#10000;
	force UUT.multifunc_EP0.cfg_adc_mode = 32'b1010;
	#10000;

	
	force UUT.multifunc_EP0.cfg_auxdw_0 = 16;
	force UUT.multifunc_EP0.cfg_auxdw_1 = 32'h2;
	force UUT.multifunc_EP0.cfg_auxdw_3 = 32'h12345678;
	#100;
	force UUT.multifunc_EP0.cfg_auxdw_1 = 32'h3;
	#100;
	force UUT.multifunc_EP0.cfg_auxdw_1 = 32'h0;
	#1000;
	

	// 4th mode
	cct_start_host(32'h00700000, 32'h00800000, /*sel*/1, 1, /*rep*/0, 0, /*con*/ 0, 0, /*clr*/ 0, 0, /*div*/1, 1);
	#10000;
	prf_start(20480/4, 4000/4);
	#320000;
	prf_stop;
	#10000;
	cct_stop;
	#10000;
	// 
	// // 4th mode - 1
	// cct_start_mem(32'h00700000, 32'h00800000, /*sel*/1, 1, /*rep*/1, 1, /*con*/ 0, 0, /*clr*/ 0, 0, /*div*/1, 1);
	// #10000;
	// prf_start(20480/4, 4000/4);
	// #320000;
	// prf_stop;
	// #10000;
	// cct_stop;
	// #10000;
	// 
	// // 5th mode
	// cct_start_mem(32'h00900000, 32'h00A00000, /*sel*/1, 1, /*rep*/1, 1, /*con*/ 1, 1, /*clr*/ 1, 1, /*div*/1, 1);
	// #10000;
	// prf_start(20480/4, 4000/4);
	// #320000;
	// prf_stop;
	// #10000;
	// cct_stop;
	// #10000;
	// 
	// // 6th mode
	// cct_start_mem(32'h00900000, 32'h00A00000, /*sel*/1, 1, /*rep*/1, 1, /*con*/ 0, 0, /*clr*/ 1, 1, /*div*/1, 1);
	// #10000;
	// prf_start(20480/4, 4000/4);
	// #320000;
	// prf_stop;
	// #10000;
	// cct_stop;
	// #10000;
	#1000000;

	$stop;

end
endmodule
