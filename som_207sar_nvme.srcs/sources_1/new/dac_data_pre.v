`include "configure.vh"
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/03/18 11:34:06
// Design Name: 
// Module Name: dac_data_pre
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

module dac_data_pre
#(
    parameter   LOCAL_DWIDTH 	      = 256                 ,
    parameter   WIDTH               = 16                  ,
    parameter   FFT_WIDTH           = 24                  ,
    parameter   LANE_NUM            = 8                   ,
    parameter   CHIRP_NUM           = 256                 ,
    parameter   CALCLT_DELAY        = 35                  ,
    parameter   DWIDTH_0            = 32*4               ,
    parameter   SHIFT_RAM_DELAY     = (DWIDTH_0 >> 1) + 1 ,
    parameter   ADC_CLK_FREQ        = 156_250_000         ,
    parameter   RECO_DELAY          = 29 
)(

input							              dac_clk			              ,
input							              dac_rst			              ,

input							              adc_clk			              ,
input							              adc_rst			              ,
  


//rpu   ctrl_reg
input                	          ramrpu_clk     	          ,
input                           ramrpu_en      	          ,
input     [3 : 0 ]              ramrpu_we      	          ,
input     [31 : 0]              ramrpu_addr    	          ,
input     [31 : 0]              ramrpu_din     	          ,
output    [31 : 0]              ramrpu_dout    	          ,
input                           ramrpu_rst     	          ,


//AD
input     [127:0]					      m00_axis_tdata	          ,
input     [127:0]   				    m01_axis_tdata	          ,
input     [127:0]   				    m02_axis_tdata	          ,
input     [127:0]   				    m03_axis_tdata	          ,

//小chirp            
input                	          ramb_clk       	          ,
input                           ramb_en        	          ,
input     [3 : 0 ]              ramb_we        	          ,
input     [31 : 0]              ramb_addr      	          ,
input     [31 : 0]              ramb_din       	          ,
output    [31 : 0]              ramb_dout      	          ,
input                           ramb_rst                  ,

//大chirp
input                	          rama_clk       	          ,
input                           rama_en        	          ,
input     [3 : 0 ]              rama_we        	          ,
input     [31 : 0]              rama_addr      	          ,
input     [31 : 0]              rama_din       	          ,
output    [31 : 0]              rama_dout      	          ,
input                           rama_rst       	          ,


//ddr data
output							            mfifo_rd_enable	          ,
input     [LOCAL_DWIDTH-1:0] 		mfifo_rd_data	            ,

//DA
output    [255:0]	 			        s00_axis_tdata	          ,

//data_record
output reg                      adc_valid                 ,
output reg                      dac_valid_adjust          ,
output reg [255:0]              dac_data_adjust           ,
output                          data_record_mode          ,

output                          rf_out                    ,


output                          record_en                 ,

output	   						          prffix_inter	            ,//**
output	reg						          preprf_inter	            ,
output	reg						          prfin_inter		            ,
output              			      RF_TXEN_inter	            ,//**
output              			      BC_TXEN_inter	            , //**
output                          rf_tx_en_v                ,
output                          rf_tx_en_h                ,
output                          bc_tx_en                  ,
output                          channel_sel               ,
output                          adc_valid_expand          ,
output [1:0]                    mode_value                ,
output                          zero_sel                  ,
output  [255:0]                 adc_data0                 ,
output  [255:0]                 adc_data1                 ,
output                          trt_close_flag            ,
output                          trr_close_flag            
                       
);

wire rf_close_flag;
/*
注design：
*/

wire real_imag_swap;

wire [255:0]	 			        s00_axis_tdata_tmp;

/*
干扰机：0 1
延时线：0 0
*/
wire [1:0] ad_sel;//注debug：0是选正常ad1，1是选择激励
wire da_sel;//注debug： 0时延时直出，为1时出干扰信号

wire rf_out_jammer;
wire rf_tx_en_delay;
wire rf_tx_en_h_jammer;
wire rf_tx_en_v_jammer;
wire dac_valid;
//adc_valid需要自己生成

wire   [31:0]                    app_param0      ;
wire   [31:0]                    app_param1      ;
wire   [31:0]                    app_param2      ;
wire   [31:0]                    app_param3      ;
wire   [31:0]                    app_param4      ;
wire   [31:0]                    app_param5      ;
wire   [31:0]                    app_param6      ;
wire   [31:0]                    app_param7      ;
wire   [31:0]                    app_param8      ;
wire   [31:0]                    app_param9      ;
wire   [31:0]                    app_param10     ;
wire   [31:0]                    app_param11     ;
wire   [31:0]                    app_param12     ;
wire   [31:0]                    app_param13     ;
wire   [31:0]                    app_param14     ;
wire   [31:0]                    app_param15     ;
wire   [31:0]                    app_param16     ;
wire   [31:0]                    app_param17     ;
wire   [31:0]                    app_param18     ;
wire   [31:0]                    app_param19     ;
wire   [31:0]                    app_param20     ;
wire   [31:0]                    app_param21     ;
wire   [31:0]                    app_param22     ;

wire   [31:0]                    app_status0     ;
wire   [31:0]                    app_status1     ;
wire   [31:0]                    app_status2     ;
wire   [31:0]                    app_status3     ;
wire   [31:0]                    app_status4     ;
wire   [31:0]                    app_status5     ;
wire   [31:0]                    app_status6     ;
wire   [31:0]                    app_status7     ;
wire   [31:0]                    app_status8     ;
wire   [31:0]                    app_status9     ;
wire   [31:0]                    app_status10    ;
wire   [31:0]                    app_status11    ;

wire   [255:0]                    dac_data       ;
wire                              dac_valid_whole ;
wire   [255:0]                    delay_dac_data  ;
wire [255:0] dac_data_o;
wire         dac_valid_o;

reg    [WIDTH*2*8-1:0]              adc_data       ;//需要拼接而来

wire                              prf            ;


wire resetn_vio;

wire rf_tx_en;

reg   [31:0]                    app_param0_r [1:0]      ;
reg   [31:0]                    app_param1_r [1:0]      ;
reg   [31:0]                    app_param2_r [1:0]      ;
reg   [31:0]                    app_param3_r [1:0]      ;
reg   [31:0]                    app_param4_r [1:0]      ;
reg   [31:0]                    app_param5_r [1:0]      ;
reg   [31:0]                    app_param6_r [1:0]      ;
reg   [31:0]                    app_param7_r [1:0]      ;
reg   [31:0]                    app_param8_r [1:0]      ;
reg   [31:0]                    app_param9_r [1:0]      ;
reg   [31:0]                    app_param10_r[1:0]      ;
reg   [31:0]                    app_param11_r[1:0]      ;
reg   [31:0]                    app_param12_r[1:0]      ;
reg   [31:0]                    app_param13_r[1:0]      ;
reg   [31:0]                    app_param14_r[1:0]      ;
reg   [31:0]                    app_param15_r[1:0]      ;
reg   [31:0]                    app_param16_r[1:0]      ;
reg   [31:0]                    app_param17_r[1:0]      ;
reg   [31:0]                    app_param18_r[1:0]      ;
reg   [31:0]                    app_param19_r[1:0]      ;
reg   [31:0]                    app_param20_r[1:0]      ;
reg   [31:0]                    app_param21_r[1:0]      ;
reg   [31:0]                    app_param22_r[1:0]      ;


always @(posedge adc_clk) begin
  app_param0_r[0]  <=  app_param0  ;
  app_param1_r[0]  <=  app_param1  ;
  app_param2_r[0]  <=  app_param2  ;
  app_param3_r[0]  <=  app_param3  ;
  app_param4_r[0]  <=  app_param4  ;
  app_param5_r[0]  <=  app_param5  ;
  app_param6_r[0]  <=  app_param6  ;
  app_param7_r[0]  <=  app_param7  ;
  app_param8_r[0]  <=  app_param8  ;
  app_param9_r[0]  <=  app_param9  ;
  app_param10_r[0] <=  app_param10 ;
  app_param11_r[0] <=  app_param11 ;
  app_param12_r[0] <=  app_param12 ;
  app_param13_r[0] <=  app_param13 ;
  app_param14_r[0] <=  app_param14 ;
  app_param15_r[0] <=  app_param15 ;
  app_param16_r[0] <=  app_param16 ;
  app_param17_r[0] <=  app_param17 ;
  app_param18_r[0] <=  app_param18 ;
  app_param19_r[0] <=  app_param19 ;
  app_param20_r[0] <=  app_param20 ;
  app_param21_r[0] <=  app_param21 ;
  app_param22_r[0] <=  app_param22 ;
end

always @(posedge adc_clk) begin
  app_param0_r[1]  <=  app_param0_r[0]  ;
  app_param1_r[1]  <=  app_param1_r[0]  ;
  app_param2_r[1]  <=  app_param2_r[0]  ;
  app_param3_r[1]  <=  app_param3_r[0]  ;
  app_param4_r[1]  <=  app_param4_r[0]  ;
  app_param5_r[1]  <=  app_param5_r[0]  ;
  app_param6_r[1]  <=  app_param6_r[0]  ;
  app_param7_r[1]  <=  app_param7_r[0]  ;
  app_param8_r[1]  <=  app_param8_r[0]  ;
  app_param9_r[1]  <=  app_param9_r[0]  ;
  app_param10_r[1] <=  app_param10_r[0] ;
  app_param11_r[1] <=  app_param11_r[0] ;
  app_param12_r[1] <=  app_param12_r[0] ;
  app_param13_r[1] <=  app_param13_r[0] ;
  app_param14_r[1] <=  app_param14_r[0] ;
  app_param15_r[1] <=  app_param15_r[0] ;
  app_param16_r[1] <=  app_param16_r[0] ;
  app_param17_r[1] <=  app_param17_r[0] ;
  app_param18_r[1] <=  app_param18_r[0] ;
  app_param19_r[1] <=  app_param19_r[0] ;
  app_param20_r[1] <=  app_param20_r[0] ;
  app_param21_r[1] <=  app_param21_r[0] ;
  app_param22_r[1] <=  app_param22_r[0] ;
end

//注debug：调试用
// assign da_sel = app_param22_r[1][0];
// assign real_imag_swap = app_param22_r[1][1];
// assign zero_sel = app_param22_r[1][2];

 assign da_sel = 1;
 assign real_imag_swap = 1;
 assign zero_sel = 1;

`ifdef TEST
reg [7:0] cnt_reset = 0;
always@(posedge adc_clk)begin
  if(cnt_reset == 50)
    cnt_reset <= 50;
  else
    cnt_reset <= cnt_reset + 1;
end
assign resetn_vio = ~(cnt_reset < 50);
`endif


`ifdef TEST

assign ad_sel = 1;
assign da_sel = 0;
`endif

//adc
wire rd_en;
wire adc_valid_pre;
// wire adc_valid_expand;
reg [11 : 0] read_addr;

// reg adc_valid;

wire resetn;

always @(posedge adc_clk) begin
  if(!resetn)
    adc_valid <= 0;
  else
    adc_valid <= adc_valid_pre;
end

assign rd_en = adc_valid_pre ;

always @(posedge adc_clk) begin
    if(!resetn)
        read_addr <= 0;
    else if(rd_en)
        read_addr <= read_addr + 1;        
    else
        read_addr <= 0;
end




reg [255:0] data_in [1791:0];

initial begin
  $readmemh("D:/code/complete/program_data/adc_data.txt",data_in);
end

wire rd_en_txt;
reg [12 : 0] read_addr_txt;
wire [WIDTH*2*8-1:0] adc_data_txt;


// assign rd_en_txt = mode_value == 2 ? adc_valid : 1;

always @(posedge adc_clk) begin
    if(!resetn)
        read_addr_txt <= 0;
    else if(rd_en_txt)
        read_addr_txt <= read_addr_txt + 1;
end

assign adc_data_txt = data_in[read_addr_txt];
//-----------------2025/02/12 22:51改动--------------------//
//ad0和ad1接反，从而实现ad0接h通道，ad1接v通道；射频模块那块反了一层，因此这里软件再反一次反回来 
//wire [255:0] adc_data0;
//wire [255:0] adc_data1;
genvar kk;
generate
	for(kk = 0;kk < 8;kk = kk + 1)begin:blk1
        assign adc_data0[(kk+1)*32-1:kk*32] = real_imag_swap ? {m02_axis_tdata[(kk+1)*16-1:kk*16],m03_axis_tdata[(kk+1)*16-1:kk*16]} : {m03_axis_tdata[(kk+1)*16-1:kk*16],m02_axis_tdata[(kk+1)*16-1:kk*16]};
        assign adc_data1[(kk+1)*32-1:kk*32] = real_imag_swap ? {m00_axis_tdata[(kk+1)*16-1:kk*16],m01_axis_tdata[(kk+1)*16-1:kk*16]} : {m01_axis_tdata[(kk+1)*16-1:kk*16],m00_axis_tdata[(kk+1)*16-1:kk*16]};
    assign s00_axis_tdata[(kk+1)*32-1:kk*32] = real_imag_swap ?   {s00_axis_tdata_tmp[kk*32+15:kk*32],s00_axis_tdata_tmp[kk*32+31:kk*32+16 ]} : s00_axis_tdata_tmp[(kk+1)*32-1:kk*32];
	end
endgenerate

//注sim：改 2025/06/09 测试用
/*
200us 5khz  31250   : 仿真用
5ms   200hz 781250  : 上板用
*/
localparam PRF_PERIOD = 781250; // 仿真200us
localparam SIGNAL_WIDTH = 782; // 信号时宽5us
localparam FRAME_NUM = 2;     // 信号帧数
wire [255:0] adc_data_delay;
reg [255:0] adc_data_delay_stim;
reg [255:0] adc_data_delay_stims [0:SIGNAL_WIDTH*FRAME_NUM-1];
initial begin
    $readmemh("D:/code/verilog/data/delay_jammer/lfm_signal.txt", adc_data_delay_stims);//512 有效，两份
end
reg [31:0] cnt_prf;//生成prf
reg prf_is_odd;//计算prf的奇偶
reg [31:0] cnt_data;//计数产生数据
wire prf_delay;
reg prf_delay_r;
wire prf_delay_pos;
//生成prf信号
always @(posedge adc_clk) begin
    if(!resetn)
        cnt_prf <= 0;
    else if(cnt_prf == PRF_PERIOD)
        cnt_prf <= 0;
    else
        cnt_prf <= cnt_prf + 1;
end
assign prf_delay = cnt_prf <= 100;
//检测prf信号上升沿
always @(posedge adc_clk) begin
    if(!resetn)
        prf_delay_r <= 0;
    else
        prf_delay_r <= prf_delay;
end
assign prf_delay_pos = prf_delay && !prf_delay_r;

//计数prf的奇偶
always @(posedge adc_clk) begin
    if(!resetn)
        prf_is_odd <= 0;
    else if(prf_delay_pos)
        prf_is_odd <= prf_is_odd + 1;
end
//生成造的激励数据，奇偶帧前512数据不同
always@(*)begin
    if(!resetn)
      adc_data_delay_stim = 0;
    else if(cnt_prf < SIGNAL_WIDTH)begin
      if(prf_is_odd)begin
        adc_data_delay_stim = adc_data_delay_stims[cnt_prf];
      end
      else begin
        adc_data_delay_stim = adc_data_delay_stims[cnt_prf + SIGNAL_WIDTH];
      end
    end
    else begin
      adc_data_delay_stim = 0;
    end
end

assign adc_data_delay = ad_sel ? adc_data_delay_stim : adc_data1;//注debug：0是选正常ad1，1是选择激励


  vio_rst u_vio_rst (
  .clk			  (adc_clk	  ), 
  .probe_in0	(probe_in0	), 
  .probe_in1	(probe_in1	), 
  .probe_in2	(probe_in2	)
`ifndef TEST
  ,
  .probe_out0	(resetn_vio         ),  
  .probe_out1	(ad_sel  	          ),  
  .probe_out2	(         	  )
`endif

);
   
   

`ifdef TEST

//kb_data_gen
//读kb_data_gen
  reg [23:0] data_in_k [1791:0];
  reg [23:0] data_in_b [1791:0];

  wire [23:0] k_vlaue;
  wire [23:0] b_vlaue;

  initial begin
    $readmemh("D:/code/complete/program_data/k_data.txt",data_in_k);
    $readmemh("D:/code/complete/program_data/b_data.txt",data_in_b);
  end

  reg [31 : 0] cnt_kb;

  wire add_kb;
  reg kb_valid_r;
  always@(posedge adc_clk)begin
    if(!resetn)
      kb_valid_r <= 0;
    else
      kb_valid_r <= app_param6[0];
  end

  assign add_kb = ~kb_valid_r && app_param6[0];

  always @(posedge adc_clk) begin
    if(!resetn)
        cnt_kb <= 0;
    else if(add_kb)
      cnt_kb <= cnt_kb + 1;
  end

  assign k_vlaue = data_in_k[cnt_kb - 1];
  assign b_vlaue = data_in_b[cnt_kb - 1];
  

`endif

hwreg_set_new u_hwreg_set_new(
. app_status0  (app_status0	    ) ,
. app_status1  (app_status1	    ) ,
. app_status2  (app_status2	    ) ,
. app_status3  (app_status3	    ) ,
. app_status4  (app_status4	    ) ,
. app_status5  (app_status5	    ) ,
. app_status6  (app_status6	    ) ,
. app_status7  (app_status7	    ) ,
. app_status8  (app_status8	    ) ,
. app_status9  (app_status9	    ) ,
. app_status10 (app_status10    ) ,
. app_status11 (app_status11    ) ,
. app_param0  (app_param0       ) ,
. app_param1  (app_param1       ) ,
. app_param2  (app_param2       ) ,
. app_param3  (app_param3       ) ,
. app_param4  (app_param4       ) ,
. app_param5  (app_param5       ) ,
. app_param6  (app_param6       ) ,
. app_param7  (app_param7       ) ,
. app_param8  (app_param8       ) ,
. app_param9  (app_param9       ) ,
. app_param10 (app_param10      ) ,
. app_param11 (app_param11      ) ,
. app_param12 (app_param12      ) ,
. app_param13 (app_param13      ) ,
. app_param14 (app_param14      ) ,
. app_param15 (app_param15      ) ,
. app_param16 (app_param16      ) ,
. app_param17 (app_param17      ) ,
. app_param18 (app_param18      ) ,
. app_param19 (app_param19      ) ,
. app_param20 (app_param20      ) ,
. app_param21 (app_param21      ) ,
. app_param22 (app_param22      ) ,
. cfg_clk     (ramrpu_clk       ) ,
. cfg_rd_en   (ramrpu_en        ) ,
. cfg_wr_en   (ramrpu_we        ) ,
. cfg_wr_addr (ramrpu_addr      ) ,
. cfg_rd_addr (ramrpu_addr      ) ,
. cfg_wr_dat  (ramrpu_din       ) ,
. cfg_rd_dat  (ramrpu_dout      ) ,
. cfg_rst     (ramrpu_rst       )
);

disturb_wrapper#(
  .LOCAL_DWIDTH 	   (LOCAL_DWIDTH 	 ),
  .WIDTH             (WIDTH          ),
  .FFT_WIDTH         (FFT_WIDTH      ),
  .LANE_NUM          (LANE_NUM       ),
  .CHIRP_NUM         (CHIRP_NUM      ),
  .CALCLT_DELAY      (CALCLT_DELAY   ),
  .DWIDTH_0          (DWIDTH_0       ),
  .SHIFT_RAM_DELAY   (SHIFT_RAM_DELAY),
  .ADC_CLK_FREQ      (ADC_CLK_FREQ   ),
  .RECO_DELAY        (RECO_DELAY     )
)
u_disturb_wrapper(
. adc_clk           (adc_clk          ) ,
. resetn            (resetn           ) ,
. prf               (prf              ) ,
. adc_data0         (adc_data0        ) ,//需要拼接而来
. adc_data1         (adc_data1        ) ,//需要拼接而来
. adc_valid_pre     (adc_valid_pre    ) ,//需要拼接而来
. adc_valid_expand  (adc_valid_expand ) ,//需要拼接而来
. rf_out            (rf_out_jammer    ) ,
. chirp_in_clka     (rama_clk         ) ,
. chirp_in_ena      (1                ) ,
. chirp_in_wea      (rama_we          ) ,
. chirp_in_addra    (rama_addr        ) ,
. chirp_in_dina     (rama_din         ) ,
. chirp_in_douta    (rama_dout        ) ,

. chirp_fft_clka    (ramb_clk    	    ) ,
. chirp_fft_ena     (1          	    ) ,
. chirp_fft_wea     (ramb_we     	    ) ,
. chirp_fft_addra   (ramb_addr   	    ) ,
. chirp_fft_dina    (ramb_din    	    ) ,
. chirp_fft_douta   (ramb_dout   	    ) ,

. app_param0        (app_param0_r[1]  ) ,
. app_param1        (app_param1_r[1]  ) ,
. app_param2        (app_param2_r[1]  ) ,
. app_param3        (app_param3_r[1]  ) ,
. app_param4        (app_param4_r[1]  ) ,
. app_param5        (app_param5_r[1]  ) ,
. app_param6        (app_param6_r[1]  ) ,
. app_param7        (app_param7_r[1]  ) ,
. app_param8        (app_param8_r[1]  ) ,
. app_param9        (app_param9_r[1]  ) ,
. app_param10       (app_param10_r[1] ) ,
. app_param11       (app_param11_r[1] ) ,
. app_param12       (app_param12_r[1] ) ,
. app_param13       (app_param13_r[1] ) ,
. app_param14       (app_param14_r[1] ) ,
. app_param15       (app_param15_r[1] ) ,
. app_param16       (app_param16_r[1] ) ,
. app_param17       (app_param17_r[1] ) ,
. app_param18       (app_param18_r[1] ) ,
. app_param19       (app_param19_r[1] ) ,
. app_param20       (app_param20_r[1] ) ,
. app_param21       (app_param21_r[1] ) ,
. app_param22       (app_param22_r[1] ) ,

. app_status0       (app_status0      ) ,
. app_status1       (app_status1      ) ,
. app_status2       (app_status2      ) ,
. app_status3       (app_status3      ) ,
. app_status4       (app_status4      ) ,
. app_status5       (app_status5      ) ,
. app_status6       (app_status6      ) ,
. app_status7       (app_status7      ) ,
. app_status8       (app_status8      ) ,
. app_status9       (app_status9      ) ,
. app_status10      (app_status10     ) ,
. app_status11      (app_status11     ) ,

. mfifo_rd_enable   (mfifo_rd_enable  ) ,
. mfifo_rd_data     (mfifo_rd_data    ) ,
. dac_data          (dac_data         ) ,
. dac_data_o        (dac_data_o       ) ,
. dac_valid_whole   (dac_valid_whole  ) ,
. dac_valid_o       (dac_valid_o      ) ,
. err_flag          (err_flag         ) ,
. fifo_overflow     (fifo_overflow    ) ,
. fifo_underflow    (fifo_underflow   ) ,
. channel_sel       (channel_sel      ) ,
. rf_close_flag     (rf_close_flag    ) ,
. trt_close_flag    (trt_close_flag   ) ,
. trr_close_flag    (trr_close_flag   )
);
//注debug：调试用
wire [31:0] receive_delay;
wire [31:0] receive_length;
wire trig_valid;
wire [31:0] cnt_delay;
wire fifo_wren;


delay_wrapper#(
    .  LOCAL_DWIDTH 	  (LOCAL_DWIDTH 	)  ,
    .  WIDTH            (WIDTH          )  ,
    .  FFT_WIDTH        (FFT_WIDTH      )  ,
    .  LANE_NUM         (LANE_NUM       )  ,
    .  CHIRP_NUM        (CHIRP_NUM      )  ,
    .  CALCLT_DELAY     (CALCLT_DELAY   )  ,
    .  DWIDTH_0         (DWIDTH_0       )  ,
    .  SHIFT_RAM_DELAY  (SHIFT_RAM_DELAY)  ,
    .  ADC_CLK_FREQ     (ADC_CLK_FREQ   )  ,
    .  RECO_DELAY       (RECO_DELAY     )  
)u_delay_wrapper(
. adc_clk        (adc_clk       )  ,
. resetn         (resetn        )  ,
. adc_data       (adc_data_delay     )  ,
. adc_thshld     (app_param7    )  ,//adc_thshld            注sim：仿真测试固定了 应该为：app_param7 
. receive_length (receive_length   )  ,//data_record_period    注sim：仿真测试固定了 应该为：app_param20
. receive_delay  (receive_delay   )  ,//adc_delay             注sim：仿真测试固定了 应该为：app_param10
. dac_data       (delay_dac_data ) , 
. dac_valid       (dac_valid_delay ),
. rf_out          (rf_tx_en_delay    ), 
. trig_valid          (trig_valid    ), 
. cnt_delay           (cnt_delay     ), 
. fifo_wren           (fifo_wren     ) 
);
  

//注debug：调试用
vio_delay_ctrl u_vio_delay_ctrl (
  .clk(adc_clk), 
  .probe_out0(receive_length), // data_record_period
  .probe_out1(receive_delay) // adc_delay
);


ila_delay u_ila_delay (
	.clk(adc_clk), // input wire clk
	.probe0(trig_valid      ), // 1
	.probe1(fifo_wren       ), // 1
	.probe2(adc_data_delay  ), // 32
	.probe3(dac_valid_delay       ), // 1
	.probe4(s00_axis_tdata  ), // 32
	.probe5(rf_tx_en_v          ), // 1
	.probe6(cnt_delay       ) // 32
);


shift_ram_dac u_shift_ram_dac (
  .D(dac_data),      // input wire [255 : 0] D
  .CLK(adc_clk),  // input wire CLK
  .Q(dac_data_o)      // output wire [255 : 0] Q
);




// assign resetn = resetn_vio;//注sim：仿真测试时复位逻辑进行了修改
assign resetn = app_param12_r[1][0] && resetn_vio;//注sim：仿真/测试时复位逻辑进行了修改
assign dac_valid = dac_valid_whole;


reg [DWIDTH_0:0] CFGBC_OUTEN_r = 0;
always@(posedge adc_clk)begin
	CFGBC_OUTEN_r <= {CFGBC_OUTEN_r[DWIDTH_0-1:0], dac_valid};
end


wire RF_A_TXEN_TEMP;
assign dac_valid_o = CFGBC_OUTEN_r[DWIDTH_0/2];//改动点
assign RF_A_TXEN_TEMP = (|CFGBC_OUTEN_r);
// assign RF_A_TXEN = RF_A_TXEN_TEMP && (~adc_valid_expand) ;

//打拍生成BC_TX_EN
reg [DWIDTH_0/2:0] CFGBC_OUTEN_r_BC = 0;
always@(posedge adc_clk)begin
	CFGBC_OUTEN_r_BC <= {CFGBC_OUTEN_r_BC[(DWIDTH_0/2)-1:0], RF_A_TXEN_TEMP};
end

assign rf_tx_en = CFGBC_OUTEN_r_BC[DWIDTH_0/4] && !rf_close_flag;//改动点
assign bc_tx_en = CFGBC_OUTEN_r_BC[DWIDTH_0/4] ;//改动点

wire signed [15:0] power_adjust_coe;
assign power_adjust_coe = app_param18_r[1][15:0];
wire [WIDTH*2*LANE_NUM*2-1:0] dac_data_adjust_pre;
genvar yy;
generate
  for (yy = 0; yy < 2*LANE_NUM ;yy = yy + 1 ) begin
    assign dac_data_adjust_pre[WIDTH*2*(yy+1)-1:WIDTH*2*yy] = ($signed(dac_data_o[WIDTH*(yy+1)-1 : WIDTH*yy]) * $signed(power_adjust_coe));
    always @(posedge adc_clk) begin
      if(!resetn)
        dac_data_adjust[WIDTH*(yy+1)-1 : WIDTH*yy] <= 0;
      else
        dac_data_adjust[WIDTH*(yy+1)-1 : WIDTH*yy] <= {dac_data_adjust_pre[WIDTH*2*(yy+1)-1],dac_data_adjust_pre[WIDTH*2*(yy+1)-3:WIDTH*2*yy+15]};
    end
  end
endgenerate

//使用时序逻辑打拍，跟s00_axis_tdata_temp1同步
always@(posedge adc_clk)begin
  if(!resetn)
    dac_valid_adjust <= 0;
  else
    dac_valid_adjust <= dac_valid_o;
end

wire dac_valid_o_zero;
assign dac_valid_o_zero = (dac_valid_adjust == 1) && (adc_valid_expand == 0);





assign s00_axis_tdata_tmp = da_sel ? (dac_valid_adjust ? dac_data_adjust : 0) :  (dac_valid_delay ? delay_dac_data : 0);//注sim： 2025/06/09 da_sel 为 0时延时直出，为1时出干扰信号
assign rf_tx_en_v = da_sel ? rf_tx_en_v_jammer : rf_tx_en_delay;//注sim： 2025/06/09 da_sel 为 0时延时直出，为1时出干扰信号
assign rf_tx_en_h = da_sel ? rf_tx_en_h_jammer : rf_tx_en_delay;//注sim： 2025/06/09 da_sel 为 0时延时直出，为1时出干扰信号

ila_dac_adjust u_ila_dac_adjust (
	.clk(adc_clk            ), // input wire clk


	.probe0(adc_valid       ), // input wire [0:0]  probe0  
	.probe1(adc_valid_expand), // input wire [0:0]  probe1 
	.probe2(dac_valid_adjust), // input wire [0:0]  probe2 
	.probe3(dac_valid_o_zero) // input wire [0:0]  probe3
);


//------------------------------- DAC datagen end-------------------------------


//--------------------------------------RF txen and BC txen------------------------
// following requirement must meet
// 1: preprf to prfin >= 6us(for dynmaic latch)
// 2. dac_valid negedge to adc_valid posedge >= 200ns (for BC RX ready)
// 3. prfin posedge to dac_valid to dac_valid posedge >= 100ns (for RF ready)
// 4. prfin posedge to adc_valid to dac_valid posedge >= 200ns (for AUX write complete)

// RF_TXEN assert on posedge of PRFIN, dessert on posedge dac_valid

// BC_TXEN assert on posedge of PRFIN, dessert on posedge dac_valid

// BC_LATCH_OUT assert on posedge of preprf if dynamic mode is selected, dessert after 15 cycles
localparam DWIDTH = 10;
reg [DWIDTH:0] dac_valid_r;
always@(posedge adc_clk)dac_valid_r <= {dac_valid_r[DWIDTH-1:0], dac_valid_adjust};

// max pulse length cut to 100us
localparam MAX_PW = 150*100;
reg [15:0] txcnt;
reg tx_en_cmd, tx_en_cmd_r, tx_out;
always@(posedge adc_clk)tx_en_cmd <= dac_valid_adjust;
always@(posedge adc_clk)tx_en_cmd_r <= tx_en_cmd;
always@(posedge adc_clk)begin
	if(~dac_valid_adjust)txcnt <= 0;
	else if(txcnt<MAX_PW)txcnt <= txcnt + 1;	
	tx_out <= (txcnt<MAX_PW);
end

assign RF_TXEN = dac_valid_r[10];
assign DAC_VOUT = dac_valid_r[4];
assign BC_TXEN = tx_out &  dac_valid_r[0];

reg BC_LATCH_r1, BC_LATCH_r2;
reg BC_LATCH_int = 0;
reg BC_LATCH_gen = 0;
reg BC_DYNLAT_r = 0;


assign RF_TXEN_inter = RF_TXEN ;
assign BC_TXEN_inter = BC_TXEN ;

//--------------------------------------RF txen and BC txen   end------------------------

assign prffix_inter = prf;
//----------------------------数据记录模式值打拍寄存------------------------------------//
assign data_record_mode = app_param17_r[1][0];

//-----------------------数据记录周期---------------------------//
wire [31:0] data_record_period;
assign data_record_period = app_param20_r[1];

//-----------------------数据记录信号的生成----------------------------//
// wire [1:0] mode_value;
assign mode_value = app_param8_r[1];
reg [31:0] cnt_record;
reg add_flag;
wire end_flag;
reg prf_r;
wire prf_pos;

always@(posedge adc_clk)begin
  if(!resetn)
    prf_r <= 0;
  else
    prf_r <= prf;
end

assign prf_pos = ~prf_r && prf;
always@(posedge adc_clk)begin
  if(!resetn)
    add_flag <= 0;
  else if(prf_pos)
    add_flag <= 1;
  else if(end_flag)
    add_flag <= 0;
end

assign end_flag = add_flag && cnt_record == data_record_period - 1;

always @(posedge adc_clk) begin
  if(!resetn)
    cnt_record <= 0;
  else if(add_flag)begin
    if(end_flag)
      cnt_record <= 0;
    else
      cnt_record <= cnt_record + 1;
  end
end

assign record_en = add_flag;

//-----------------射频模块使能生成----------------------//
rf_mode u_rf_mode(
. adc_clk     (adc_clk    ) ,
. resetn      (resetn     ) ,
. rf_tx_en    (rf_tx_en   ) ,
. channel_sel (channel_sel) ,  
. rf_tx_en_h  (rf_tx_en_h_jammer) ,
. rf_tx_en_v  (rf_tx_en_v_jammer)
);

ila_record u_ila_record (
	.clk(adc_clk), // input wire clk


	.probe0(prf), // input wire [0:0]  probe0  
	.probe1(data_record_period), // input wire [31:0]  probe1 
	.probe2(record_en), // input wire [0:0]  probe2
	.probe3(cnt_record), // input wire [31:0]  probe3
	.probe4(add_flag), // input wire [0:0]  probe3
	.probe5(end_flag), // input wire [0:0]  probe3
	.probe6(prf_pos) // input wire [0:0]  probe3
);

endmodule
