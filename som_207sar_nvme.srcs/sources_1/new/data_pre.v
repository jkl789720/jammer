`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/01/10 18:48:32
// Design Name: 
// Module Name: data_pre
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


module data_pre
#(
parameter LOCAL_DWIDTH = 256
)
(
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
	
	
//input 				preprf,
//input 				prfin,
output				prffix_inter,
output				preprf_inter,
output				prfin_inter,
output				RF_TXEN_inter,
output				BC_TXEN_inter,

input 				fifo_wr_clr,
input 				fifo_wr_valid,
input 				fifo_wr_enable,
input [31:0] 		cfg_adc_frmlen,
output [1:0]		rec_fifo_overflow,

output				mfifo_rd_enable,
input [LOCAL_DWIDTH-1:0] mfifo_rd_data,


input [192*8-1:0] 	ctrl_data,
input [64*8-1:0] 	status_data,
input [96*8-1:0] 	param_data,
input [128*8-1:0] 	debug_data,


input [1:0] 		adc_sel,
input [1:0] 		dac_sel,
input [31:0] 		adc_div,
input [31:0]    	cfg_dev_adc_iodelay,
input [31:0]		cfg_dev_adc_ctrl,

//fft param

input [31:0] 					cfg_INTERFERE_param0,
input [31:0] 					cfg_INTERFERE_param1,
input [31:0] 					cfg_INTERFERE_param2,
input [31:0] 					cfg_INTERFERE_param3,
input [31:0] 					cfg_INTERFERE_param4,
input [31:0] 					cfg_INTERFERE_param5,

input                	        ramrpu_clk       ,
input                           ramrpu_en        ,
input   [3 : 0]                 ramrpu_we        ,
input   [31 : 0]                ramrpu_addr      ,
input   [31 : 0]                ramrpu_din       ,
output  [31 : 0]                ramrpu_dout      ,
input                           ramrpu_rst      ,

input                	          rama_clk       ,
input                             rama_en        ,
input   [3 : 0]                   rama_we        ,
input   [31 : 0]                  rama_addr      ,
input   [31 : 0]                  rama_din       ,
output  [31 : 0]                  rama_dout      ,
input                             rama_rst       ,


input                	          ramb_clk       ,
input                             ramb_en        ,
input   [3 : 0]                   ramb_we        ,
input   [31 : 0]                  ramb_addr      ,
input   [31 : 0]                  ramb_din       ,
output  [31 : 0]                  ramb_dout      ,
input                             ramb_rst       ,

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
//input           	vio_forceready,
//input           	vio_forceloopback,
input [255:0]   	vio_dataout,
input [1:0]			vio_selchirp,
output   			adc_valid,
output 				rf_out,
output 				rf_tx_en_v,
output 				rf_tx_en_h,
output 				bc_tx_en,
output 				channel_sel,
output              adc_valid_expand   ,        
output              zero_sel      ,     
output              dac_valid_adjust  ,
output                          trt_close_flag            ,
output                          trr_close_flag                
);
	
//------------------------------- DAC data -------------------------------         
//wire 			dac_valid_adjust;
wire [255:0] 	dac_data_adjust	;
wire 			data_record_mode;
wire  			record_en		; 
wire [1:0]      mode_value		;     
wire [255:0] adc0_data;
wire [255:0] adc1_data;
dac_data_pre dac_data_pre_Ep0
(
.dac_clk(dac_clk),
.dac_rst(dac_rst),
.adc_clk(adc_clk),
.adc_rst(adc_rst),

.prffix_inter(prffix_inter),
.preprf_inter(preprf_inter),
.prfin_inter(prfin_inter),
.RF_TXEN_inter(RF_TXEN_inter),
.BC_TXEN_inter(BC_TXEN_inter),
//AD			
.m00_axis_tdata(m00_axis_tdata),
.m01_axis_tdata(m01_axis_tdata),
.m02_axis_tdata(m02_axis_tdata),
.m03_axis_tdata(m03_axis_tdata),
//DA			
.s00_axis_tdata(s00_axis_tdata),

//ddr datat
.mfifo_rd_enable(mfifo_rd_enable),
.mfifo_rd_data(mfifo_rd_data),

//fft param



.ramrpu_clk  (ramrpu_clk  ),
.ramrpu_en   (ramrpu_en   ),
.ramrpu_we   (ramrpu_we   ),
.ramrpu_addr (ramrpu_addr ),
.ramrpu_din  (ramrpu_din  ),
.ramrpu_dout (ramrpu_dout ),
.ramrpu_rst  (ramrpu_rst  ),



.rama_clk(rama_clk)       ,
.rama_en(rama_en)        ,
.rama_we(rama_we)        ,
.rama_addr(rama_addr)      ,
.rama_din(rama_din)       ,
.rama_dout(rama_dout)      ,
.rama_rst(rama_rst)       ,

.ramb_clk(ramb_clk)       ,
.ramb_en(ramb_en)        ,
.ramb_we(ramb_we)        ,
.ramb_addr(ramb_addr)      ,
.ramb_din(ramb_din)       ,
.ramb_dout(ramb_dout)      ,
.ramb_rst(ramb_rst)    ,
.adc_valid(adc_valid)    ,
.dac_valid_adjust(dac_valid_adjust),    
.dac_data_adjust(dac_data_adjust),    
.data_record_mode (data_record_mode),    
.rf_out (rf_out),    
.record_en (record_en),
.rf_tx_en_v (rf_tx_en_v ),
.rf_tx_en_h (rf_tx_en_h ),
.bc_tx_en	(bc_tx_en	),
.channel_sel	(channel_sel	),
.adc_valid_expand	(adc_valid_expand	),
.mode_value	(mode_value	),
.zero_sel	(zero_sel	),
.adc_data0	(adc0_data	),
.adc_data1	(adc1_data	),
.trt_close_flag	(trt_close_flag),
.trr_close_flag	(trr_close_flag)

//debug
//.vio_dataout(vio_dataout),
//.vio_selchirp(vio_selchirp)
);

// fast_channel
wire [255:0] dac_aux_status;
wire [255:0] adc_aux_status;
assign dac_aux_status = 256'h0;
assign adc_aux_status = 256'h0;
//deepfifo wire
wire cfg_axi_dinfifo_reset;


//`ifndef BYPASS_ALLSCOPE

// ADC monitor
ila_rfdc ila_rfdc_ep0(
.clk(adc_clk),
.probe0(m00_axis_tdata),
.probe1(m01_axis_tdata)
);
//`endif
//------------------------------- DAC data end -------------------------------

//------------------------------- ADC data -------------------------------
// add low pass filter and multi, use cfg_dev_adc_ctrl to select
// [16]: 1:enable low pass, 0: bypass
// [17]: 1:enable multi, 0: bypass
// [18]: 1:invert I/Q, 0: bypass

reg select_enFilter = 0;
reg select_invIQ = 0;
reg select_enMulti = 0;
always@(posedge adc_clk)begin
	select_enFilter <= cfg_dev_adc_ctrl[16];
	select_enMulti <= cfg_dev_adc_ctrl[17];
	select_invIQ <= cfg_dev_adc_ctrl[18];
end
wire s_axis_data_tready;
reg s_axis_data_tvalid;
reg [15:0] fir_valid = 0;
reg [127:0] s00_axis_data_tdata;
reg [127:0] s01_axis_data_tdata;
reg [127:0] s02_axis_data_tdata;
reg [127:0] s03_axis_data_tdata;
always@(posedge adc_clk)begin
	if(adc_rst)fir_valid <= 0;
	else fir_valid <= {fir_valid[14:0], s_axis_data_tready};

	if(adc_rst)s_axis_data_tvalid = 0;
	else if(&fir_valid)s_axis_data_tvalid = 1;
	
	s00_axis_data_tdata <= m00_axis_tdata;
	s01_axis_data_tdata <= m01_axis_tdata;
	s02_axis_data_tdata <= m02_axis_tdata;
	s03_axis_data_tdata <= m03_axis_tdata;
end
 
wire m00_axis_data_tvalid;
wire m01_axis_data_tvalid;
wire m02_axis_data_tvalid;
wire m03_axis_data_tvalid;
wire [127:0] m00_axis_data_tdata;
wire [127:0] m01_axis_data_tdata;
wire [127:0] m02_axis_data_tdata;
wire [127:0] m03_axis_data_tdata;
`ifndef BYPASS_FILETR
fir02N40 fir_ep0 (
.aresetn(~adc_rst),                        // input wire aresetn
.aclk(adc_clk),                            // input wire aclk
.s_axis_data_tvalid(s_axis_data_tvalid),  		// input wire s_axis_data_tvalid
.s_axis_data_tready(s_axis_data_tready),  // output wire s_axis_data_tready
.s_axis_data_tdata (s00_axis_data_tdata),    		// input wire [127 : 0] s_axis_data_tdata
.m_axis_data_tvalid(m00_axis_data_tvalid),  // output wire m_axis_data_tvalid
.m_axis_data_tdata (m00_axis_data_tdata)    // output wire [127 : 0] m_axis_data_tdata
);

fir02N40 fir_ep1 (
.aresetn(~adc_rst),                        // input wire aresetn
.aclk(adc_clk),                            // input wire aclk
.s_axis_data_tvalid(s_axis_data_tvalid),  		// input wire s_axis_data_tvalid
.s_axis_data_tready(),  					// output wire s_axis_data_tready
.s_axis_data_tdata (s01_axis_data_tdata),    		// input wire [127 : 0] s_axis_data_tdata
.m_axis_data_tvalid(m01_axis_data_tvalid),  // output wire m_axis_data_tvalid
.m_axis_data_tdata (m01_axis_data_tdata)    // output wire [127 : 0] m_axis_data_tdata
);

fir02N40 fir_ep2 (
.aresetn(~adc_rst),                        // input wire aresetn
.aclk(adc_clk),                            // input wire aclk
.s_axis_data_tvalid(s_axis_data_tvalid),  		// input wire s_axis_data_tvalid
.s_axis_data_tready(),  					// output wire s_axis_data_tready
.s_axis_data_tdata (s02_axis_data_tdata),    		// input wire [127 : 0] s_axis_data_tdata
.m_axis_data_tvalid(m02_axis_data_tvalid),  // output wire m_axis_data_tvalid
.m_axis_data_tdata (m02_axis_data_tdata)    // output wire [127 : 0] m_axis_data_tdata
);

fir02N40 fir_ep3 (
.aresetn(~adc_rst),                        // input wire aresetn
.aclk(adc_clk),                            // input wire aclk
.s_axis_data_tvalid(s_axis_data_tvalid),  		// input wire s_axis_data_tvalid
.s_axis_data_tready(),  					// output wire s_axis_data_tready
.s_axis_data_tdata (s03_axis_data_tdata),    		// input wire [127 : 0] s_axis_data_tdata
.m_axis_data_tvalid(m03_axis_data_tvalid),  // output wire m_axis_data_tvalid
.m_axis_data_tdata (m03_axis_data_tdata)    // output wire [127 : 0] m_axis_data_tdata
);
`else
assign m00_axis_data_tdata = s00_axis_data_tdata;
assign m01_axis_data_tdata = s01_axis_data_tdata;
assign m02_axis_data_tdata = s02_axis_data_tdata;
assign m03_axis_data_tdata = s03_axis_data_tdata;
`endif


//reg [255:0] adc0_data;
//reg [255:0] adc1_data;

//wire [192*8-1:0] ctrl_data;
//wire [64*8-1:0] status_data;
//wire [96*8-1:0] param_data;
//wire [128*8-1:0] debug_data;

//assign ctrl_data = 	{6{256'hAAAAAAAA00000000}};
//assign status_data = 	{2{256'hBBBBBBBB11111111}};
//assign param_data = 	{3{256'hCCCCCCCC22222222}};
//assign debug_data = 	{4{256'hDDDDDDDD33333333}};

wire [127:0] m02_axis_tdata_temp;
wire [127:0] m03_axis_tdata_temp;

assign m02_axis_tdata_temp = adc_valid ? m02_axis_tdata : 0;
assign m03_axis_tdata_temp = adc_valid ? m03_axis_tdata : 0;

wire [255:0] s00_axis_tdata_temp;
assign s00_axis_tdata_temp = dac_valid_adjust ? dac_data_adjust : 0;

wire [255:0] adc0_data_buff;
wire [255:0] adc1_data_buff;
//-----------------2025/02/12 22:51改动--------------------//
//ad0和ad1接反，从而实现ad0接h通道，ad1接v通道；射频模块那块反了一层，因此这里软件再反一次反回来
genvar kk;
//generate
//for(kk=0;kk<8;kk=kk+1)begin:blk1
//	// always@(posedge adc_clk)adc0_data[32*kk+15:32*kk+00] <= m02_axis_tdata_temp[16*kk+15:16*kk+00];
//	// always@(posedge adc_clk)adc0_data[32*kk+31:32*kk+16] <= m03_axis_tdata_temp[16*kk+15:16*kk+00];
//	// always@(posedge adc_clk)adc1_data[32*kk+15:32*kk+00] <= s00_axis_tdata_temp[32*kk+15:32*kk+00];
//	// always@(posedge adc_clk)adc1_data[32*kk+31:32*kk+16] <= s00_axis_tdata_temp[32*kk+31:32*kk+16];
//	always@(posedge adc_clk)adc0_data[32*kk+15:32*kk+00] <= m02_axis_tdata[16*kk+15:16*kk+00];
//	always@(posedge adc_clk)adc0_data[32*kk+31:32*kk+16] <= m03_axis_tdata[16*kk+15:16*kk+00];
//	always@(posedge adc_clk)adc1_data[32*kk+15:32*kk+00] <= m00_axis_tdata[16*kk+15:16*kk+00];
//	always@(posedge adc_clk)adc1_data[32*kk+31:32*kk+16] <= m01_axis_tdata[16*kk+15:16*kk+00];

//end
//endgenerate

adc_buff u_adc0_buff (
  .D(adc0_data),      // input wire [255 : 0] D
  .CLK(adc_clk),  // input wire CLK
  .Q(adc0_data_buff)      // output wire [255 : 0] Q
);

adc_buff u_adc1_buff (
  .D(adc1_data),      // input wire [255 : 0] D
  .CLK(adc_clk),  // input wire CLK
  .Q(adc1_data_buff)      // output wire [255 : 0] Q
);

// system dma, fir data
//assign adc_dma_valid = 0;
//assign adc_dma_data = 128'h0;
assign adc_dma_last = 0;

//----------------------------- add following for simulator start -----------------------------------
wire [255:0] sfifo_dout;
reg [255:0] sfifo_din;
reg sfifo_wr_srst;
reg sfifo_wr_en;
reg sfifo_rd_en;
simu_fifo simu_fifo_ep (	// max depth 1024
  .clk(adc_clk),                      // input wire clk
  .srst(sfifo_wr_srst),                    // input wire srst
  .din(sfifo_din),                      // input wire [255 : 0] din
  .wr_en(sfifo_wr_en),                  // input wire wr_en
  .rd_en(sfifo_rd_en),                  // input wire rd_en
  .dout(sfifo_dout),                    // output wire [255 : 0] dout
  .full(),                    // output wire full
  .empty()                  // output wire empty
);
reg [9:0] scount;
reg [9:0] sdelay;
reg select_StartSimu = 0;	
// cfg_dev_adc_ctrl
// [9:0]: simulator delay value, 1 is 6.666ns, minimum value is 50, max value is 1000
// [16]: 1:Enable simulator, 0: disable
generate
for(kk=0;kk<8;kk=kk+1)begin:sfifo_blk
	always@(posedge adc_clk)sfifo_din[32*kk+15:32*kk+00] <= adc0_data[32*kk+31:32*kk+16];
	always@(posedge adc_clk)sfifo_din[32*kk+31:32*kk+16] <= adc0_data[32*kk+15:32*kk+00];
end
endgenerate
always@(posedge adc_clk)begin
	select_StartSimu <= cfg_dev_adc_iodelay[16];
	sdelay <= cfg_dev_adc_iodelay[9:0];
	if(select_StartSimu)begin
		if(scount<10'h3FF)scount <= scount + 1;
		sfifo_wr_srst <= (scount<16);
		sfifo_wr_en <= (scount>32);
		sfifo_rd_en <= (scount>48) & (scount>sdelay);
	end
	else begin
		sfifo_wr_srst <= 1;
		sfifo_wr_en <= 0;
		sfifo_rd_en <= 0;
		scount <= 0;
	end
end
assign s02_axis_tdata = sfifo_dout;
assign s10_axis_tdata = sfifo_dout;
assign s12_axis_tdata = sfifo_dout;

//----------------------------- add following for simulator stop -----------------------------------

wire [7:0] div_width1;
wire [7:0] div_pulse1;
wire [7:0] div_width2;
wire [7:0] div_pulse2;

assign div_width1 = adc_div[7:0];
assign div_pulse1 = adc_div[15:8];
assign div_width2 = adc_div[23:16];
assign div_pulse2 = adc_div[31:24];

wire data_valid;
wire [255:0] data0;
wire [255:0] data1;

assign data_valid = mode_value == 2 ? adc_valid : record_en;
assign data0      = mode_value == 2 ? adc0_data : adc0_data_buff;
assign data1      = mode_value == 2 ? adc1_data : adc1_data_buff;

data_format data_format_EP0(
.adc_clk(adc_clk),    //input 
.adc_rst(adc_rst),    //input 
//.preprf(preprf),    //input 
.prfin(prffix_inter),    //input 
.fifo_wr_clr(fifo_wr_clr),    //input 
.fifo_wr_valid(fifo_wr_valid),    //input 
.fifo_wr_enable(data_valid),    //input 
.cfg_AD_rnum(cfg_adc_frmlen),    //input [31:0]
.fifo_overflow(rec_fifo_overflow[0]),	// output
.adc0_data(data0),    //input [255:0]
.adc1_data(data1),    //input [255:0]adc1_data_buff
.div_width(div_width1),    //input [7:0]
.div_pulse(div_pulse1),    //input [7:0]
.ctrl_data(ctrl_data),    //input [192*8-1:0]
.status_data(status_data),    //input [64*8-1:0]
.param_data(param_data),    //input [96*8-1:0]
.debug_data(debug_data),    //input [128*8-1:0]
.adc_ready(m_axis_hostc_AD_tready),    //input 
.adc_valid(m_axis_hostc_AD_tvalid),    //output 
.adc_data(m_axis_hostc_AD_tdata)    //output [255:0]
);
assign m_axis_hostc_AD_tlast = 0;




data_format data_format_EP1(
.adc_clk(adc_clk),    //input 
.adc_rst(adc_rst),    //input 
//.preprf(preprf),    //input 
.prfin(prffix_inter),    //input 
.fifo_wr_clr(fifo_wr_clr),    //input 
.fifo_wr_valid(fifo_wr_valid),    //input 
.fifo_wr_enable(data_valid),    //input 
.cfg_AD_rnum(cfg_adc_frmlen),    //input [31:0]
.fifo_overflow(rec_fifo_overflow[1]),	// output
.adc0_data(adc0_data),    //input [255:0]
.adc1_data(adc1_data),    //input [255:0]
.div_width(div_width2),    //input [7:0]
.div_pulse(div_pulse2),    //input [7:0]
.ctrl_data(ctrl_data),    //input [192*8-1:0]
.status_data(status_data),    //input [64*8-1:0]
.param_data(param_data),    //input [96*8-1:0]
.debug_data(debug_data),    //input [128*8-1:0]
.adc_ready(adc_dma_ready),    //input 
.adc_valid(adc_dma_valid),    //output 
.adc_data(adc_dma_data)    //output [255:0]
);

// vio_valid u_vio_valid(
//   .clk			(adc_clk		) , 
//   .probe_in0	(adc_valid		) , 
//   .probe_in1	(dac_valid_adjust	)   
// );

ila_valid u_ila_valid (
	.clk(adc_clk), // input wire clk


	.probe0(adc_valid), // input wire [0:0]  probe0  
	.probe1(dac_valid_adjust) // input wire [0:0]  probe1
);

always@(posedge adc_clk)begin
/*
	adc_sel_r <= adc_sel;
*/	
//	dac_sel_r <= dac_sel;
end	
	
endmodule
