`include "configure.vh"
`timescale 1ns / 1ps
module disturb_wrapper#(
    parameter   LOCAL_DWIDTH 	      = 256               ,
    parameter   WIDTH               = 16                  ,
    parameter   FFT_WIDTH           = 24                  ,
    parameter   LANE_NUM            = 8                   ,
    parameter   CHIRP_NUM           = 256                 ,
    parameter   CALCLT_DELAY        = 35                  ,
    parameter   DWIDTH_0            = 32                  ,
    parameter   SHIFT_RAM_DELAY     = (DWIDTH_0 >> 1) + 1 ,
    parameter   ADC_CLK_FREQ        = 156_250_000         ,
    parameter   RECO_DELAY          = 29 
)
(
input                             adc_clk           ,
input                             resetn            ,

output                            prf               ,

//adc
input [WIDTH*2*8-1:0]             adc_data0         ,//改端口
input [WIDTH*2*8-1:0]             adc_data1         ,//改端口

//ram_chip_fft
input                             chirp_fft_clka    ,
input                             chirp_fft_ena     ,
input   [0 : 0]                   chirp_fft_wea     ,
input   [13 : 0]                  chirp_fft_addra   ,
input   [31 : 0]                  chirp_fft_dina    ,
output  [31 : 0]                  chirp_fft_douta   ,

//ram_chirp
input                             chirp_in_clka     ,
input                             chirp_in_ena      ,
input  [0 : 0]                    chirp_in_wea      ,
input  [18 : 0]                   chirp_in_addra    ,
input  [31 : 0]                   chirp_in_dina     ,
output [31 : 0]                   chirp_in_douta    ,

//ddr
input [LOCAL_DWIDTH-1:0] 	        mfifo_rd_data     ,

input  [255:0]                    dac_data_o        ,
input                             dac_valid_o       ,


input   [31:0]                    app_param0        ,
input   [31:0]                    app_param1        ,
input   [31:0]                    app_param2        ,
input   [31:0]                    app_param3        ,
input   [31:0]                    app_param4        ,
input   [31:0]                    app_param5        ,
input   [31:0]                    app_param6        ,
input   [31:0]                    app_param7        ,
input   [31:0]                    app_param8        ,
input   [31:0]                    app_param9        ,
input   [31:0]                    app_param10       ,
input   [31:0]                    app_param11       ,
input   [31:0]                    app_param12       ,
input   [31:0]                    app_param13       ,
input   [31:0]                    app_param14       ,
input   [31:0]                    app_param15       ,
input   [31:0]                    app_param16       ,
input   [31:0]                    app_param17       ,
input   [31:0]                    app_param18       ,
input   [31:0]                    app_param19       ,
input   [31:0]                    app_param20       ,
input   [31:0]                    app_param21       ,
input   [31:0]                    app_param22       ,

//ddr_en
output 						                mfifo_rd_enable   ,

//dac数据输出
output [255:0]                    dac_data          ,
output                            dac_valid_whole   ,


//adc_valid 相关信号
output                            adc_valid_pre     ,
output                            adc_valid_expand  ,


output  [31:0]                    app_status0       ,
output  [31:0]                    app_status1       ,
output  [31:0]                    app_status2       ,
output  [31:0]                    app_status3       ,
output  [31:0]                    app_status4       ,
output  [31:0]                    app_status5       ,
output  [31:0]                    app_status6       ,
output  [31:0]                    app_status7       ,
output  [31:0]                    app_status8       ,
output  [31:0]                    app_status9       ,
output  [31:0]                    app_status10      ,
output  [31:0]                    app_status11      ,



//err_flag
output                            err_flag          ,
output                            fifo_overflow     ,
output                            fifo_underflow    ,

output                            rf_out            ,
output                            channel_sel       ,
output                            rf_close_flag     ,
output                            trt_close_flag    ,
output                            trr_close_flag

);

`ifdef JOINT_TEST

localparam  ADDR_TOP = 131072;

//ram
wire                           data_out_clka         ;
wire                           data_out_ena          ;
wire                           data_out_wea          ;
wire [15 : 0]                  data_out_addra        ;
wire [31 : 0]                  data_out_dina         ;
wire [31 : 0]                  data_out_douta        ;

wire                           chirp_clka         ;
wire                           chirp_ena          ;
wire [0 : 0]                   chirp_wea          ;
wire [16 : 0]                  chirp_addra        ;
wire [31 : 0]                  chirp_dina         ;
wire [31 : 0]                  chirp_douta        ;

wire [15:0]                    addr;

 assign addr = chirp_in_addra[17:2];
//chirp
assign chirp_clka  = chirp_in_clka;
assign chirp_ena   = addr < ADDR_TOP ? chirp_in_ena   : 0;
assign chirp_wea   = addr < ADDR_TOP ? chirp_in_wea   : 0;
assign chirp_addra = addr < ADDR_TOP ? chirp_in_addra : 0;
assign chirp_dina  = addr < ADDR_TOP ? chirp_in_dina  : 0;




//data_out
assign data_out_clka  = chirp_in_clka;
assign data_out_ena   = addr >= ADDR_TOP ? chirp_in_ena                       : 0;
assign data_out_wea   = addr >= ADDR_TOP ? chirp_in_wea                       : 0;
assign data_out_addra = addr >= ADDR_TOP ? chirp_in_addra - (ADDR_TOP << 2)   : 0;
assign data_out_dina  = addr >= ADDR_TOP ? chirp_in_dina                      : 0;

assign chirp_in_douta = addr < ADDR_TOP ? chirp_douta : data_out_douta;

`endif



//disturb
wire [31:0]                     chirp_length            ;
wire [31:0]                     proc_length             ;
wire [23:0]                     k_data                  ; 
wire [23:0]                     b_data                  ; 
wire [31:0]                     template_delay          ;
wire [31:0]                     distance_delay          ;
wire                            k_b_valid               ;
wire [12:0]                     fft_index_max_latch     ;
wire [WIDTH*4-1:0]              fft_value_left_latch    ;
wire [WIDTH*4-1:0]              fft_value_right_latch   ;
wire [WIDTH*4-1:0]              fft_value_max_latch     ;
wire                            fft_valid               ;
wire                            fft_valid_latch         ;

wire                            disturb_resetn          ;

wire                            adc_valid               ;
wire                            ddr_read_trig           ;

wire                            change_eq               ;

wire                            star_mode               ;

//threshold_detection
wire [31:0]                     adc_thshld              ;
wire [WIDTH*2*8-1:0]            adc_data                ;
wire [31:0]                     trig_num                ;
wire [31:0]                     trig_gap                ;
wire                            threshold_resetn        ;
wire                            trig_valid              ;
wire [31:0]                     adc_max_merge           ;
wire [31:0]                     adc_max0                ;
wire [31:0]                     adc_max1                ;
wire [31:0]                     trig_reg                ;


//mode_ctrl
wire [31:0]                     mode_value              ;
wire                            disturb_en              ;
wire                            detection_en            ;

//ctrl_sig_gen

wire [31:0]                     prf_period              ;
wire [31:0]                     prf_adc_delay           ;
wire [31:0]                     disturb_times           ;

wire                            prf_adjust_req          ;
wire [31:0]                     prf_cnt_offset          ;

wire [31:0]                     distance_delay_now      ;
wire [31:0]                     template_delay_now      ;
wire [23:0]                     k_data_now              ;
wire [23:0]                     b_data_now              ;

wire                            reco_trig               ;








// wire                            adc_valid_pre           ;
assign disturb_resetn    = (resetn & disturb_en  ) ;   
assign threshold_resetn  = (resetn & detection_en) ;      

//fft
wire [WIDTH*2-1:0] fft_value_max_latch_q;  
wire [WIDTH*2-1:0] fft_value_max_latch_i;  
wire [WIDTH*2-1:0] fft_value_left_latch_q; 
wire [WIDTH*2-1:0] fft_value_left_latch_i; 
wire [WIDTH*2-1:0] fft_value_right_latch_q;
wire [WIDTH*2-1:0] fft_value_right_latch_i;

assign fft_value_max_latch_q   = fft_value_max_latch[WIDTH*4-1:WIDTH*2]   ; 
assign fft_value_max_latch_i   = fft_value_max_latch[WIDTH*2-1:0]         ;   
assign fft_value_left_latch_q  = fft_value_left_latch[WIDTH*4-1:WIDTH*2]  ;  
assign fft_value_left_latch_i  = fft_value_left_latch[WIDTH*2-1:0]        ;
assign fft_value_right_latch_q = fft_value_right_latch[WIDTH*4-1:WIDTH*2] ;   
assign fft_value_right_latch_i = fft_value_right_latch[WIDTH*2-1:0]       ; 


disturb#(
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
u_disturb(
. adc_clk                   (adc_clk                ) ,
. resetn                    (resetn                 ) ,
. adc_data                  (adc_data               ) ,//需要拼接而来
. adc_valid                 (adc_valid              ) ,
. reco_trig                 (reco_trig              ) ,
. ddr_read_trig             (ddr_read_trig          ) ,

. chirp_clka                (chirp_clka             ) ,
. chirp_ena                 (chirp_ena              ) ,
. chirp_wea                 (chirp_wea              ) ,
. chirp_addra               (chirp_addra            ) ,
. chirp_dina                (chirp_dina             ) ,
. chirp_douta               (chirp_douta            ) ,

. chirp_fft_clka            (chirp_fft_clka         ) ,
. chirp_fft_ena             (chirp_fft_ena          ) ,
. chirp_fft_wea             (chirp_fft_wea          ) ,
. chirp_fft_addra           (chirp_fft_addra        ) ,
. chirp_fft_dina            (chirp_fft_dina         ) ,
. chirp_fft_douta           (chirp_fft_douta        ) ,

`ifdef JOINT_TEST
.   data_out_clka           (data_out_clka          ) ,
.   data_out_ena            (data_out_ena           ) ,
.   data_out_wea            (data_out_wea           ) ,
.   data_out_addra          (data_out_addra         ) ,
.   data_out_dina           (data_out_dina          ) ,
.   data_out_douta          (data_out_douta         ) ,
`endif

. chirp_length              (chirp_length           ) ,
. proc_length               (proc_length            ) ,
. k_data_now                (k_data_now             ) ,
. b_data_now                (b_data_now             ) ,
. template_delay_now        (template_delay_now     ) ,
. distance_delay_now        (distance_delay_now     ) ,
. k_b_valid                 (k_b_valid              ) ,
. change_eq                 (change_eq              ) ,
. fft_index_max_latch       (fft_index_max_latch    ) ,
. fft_value_left_latch      (fft_value_left_latch   ) ,
. fft_value_right_latch     (fft_value_right_latch  ) ,
. fft_value_max_latch       (fft_value_max_latch    ) ,
. fft_valid                 (fft_valid              ) ,
. fft_valid_latch           (fft_valid_latch        ) ,

. mfifo_rd_enable           (mfifo_rd_enable        ) ,
. mfifo_rd_data             (mfifo_rd_data          ) ,
. dac_data_o                (dac_data_o             ) ,
. dac_data                  (dac_data               ) ,
. dac_valid_whole           (dac_valid_whole        ) ,
. dac_valid_o               (dac_valid_o            ) ,
. star_mode                 (star_mode              ) ,
. err_flag                  (err_flag               ) ,
. fifo_overflow             (fifo_overflow          ) ,
. fifo_underflow            (fifo_underflow         ) 
    );

threshold_detection_merge#(
    . LOCAL_DWIDTH 	  (LOCAL_DWIDTH 	 ),
    . WIDTH           (WIDTH           ),
    . FFT_WIDTH       (FFT_WIDTH       ),
    . LANE_NUM        (LANE_NUM        ),
    . CHIRP_NUM       (CHIRP_NUM       ),
    . CALCLT_DELAY    (CALCLT_DELAY    ),
    . DWIDTH_0        (DWIDTH_0        ),
    . SHIFT_RAM_DELAY (SHIFT_RAM_DELAY ),
    . ADC_CLK_FREQ    (ADC_CLK_FREQ    ),
    . RECO_DELAY      (RECO_DELAY      )
)u_threshold_detection_merge(
. adc_clk       (adc_clk        ) ,
. resetn        (resetn         ) ,
. adc_data0     (adc_data0      ) ,
. adc_data1     (adc_data1      ) ,
. adc_thshld    (adc_thshld     ) ,
. trig_valid    (trig_valid     ) ,
. trig_num      (trig_num       ) ,
. trig_gap      (trig_gap       ) ,
. adc_max_merge (adc_max_merge  ) ,
. adc_max0      (adc_max0       ) ,
. adc_max1      (adc_max1       ) ,
. trig_reg      (trig_reg       ) 
);



ctrl_sig_gen#(
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
  ) u_ctrl_sig_gen(
. adc_clk                   (adc_clk             )  ,
. resetn                    (resetn              )  ,
. proc_length               (proc_length         )  ,
. mode_value                (mode_value          )  ,
. prf_period                (prf_period          )  ,
. prf_adc_delay             (prf_adc_delay       )  ,
. disturb_times             (disturb_times       )  ,
. trig_valid                (trig_valid          )  ,
. prf                       (prf                 )  ,
. adc_valid                 (adc_valid           )  ,
. dac_valid_o               (dac_valid_o         )  ,
. fft_valid_latch           (fft_valid_latch     )  ,
. fft_valid                 (fft_valid           )  ,
. reco_trig                 (reco_trig           )  ,
. ddr_read_trig             (ddr_read_trig       )  ,
. adc_valid_pre             (adc_valid_pre       )  ,
. adc_valid_expand          (adc_valid_expand    )  ,
. prf_adjust_req            (prf_adjust_req      )  ,
. prf_cnt_offset            (prf_cnt_offset      )  ,
. distance_delay            (distance_delay      )  ,
. chirp_length              (chirp_length        )  ,
. template_delay            (template_delay      )  ,
. star_mode                 (star_mode           )  ,
. k_b_valid                 (k_b_valid           )  ,
. k_data                    (k_data              )  ,
. b_data                    (b_data              )  ,
. distance_delay_now        (distance_delay_now  )  ,
. template_delay_now        (template_delay_now  )  ,
. k_data_now                (k_data_now          )  ,
. b_data_now                (b_data_now          )  ,
. rf_out                    (rf_out              )  ,
. fft_index_max_latch       (fft_index_max_latch )  ,
. rf_close_flag             (rf_close_flag       )  ,
. trt_close_flag            (trt_close_flag      )  ,
. trr_close_flag            (trr_close_flag      )
    );

wire resetn_sof;

wire recorde_mode;
wire [31:0] power_adjust_coe;

wire [31:0] data_record_period;


assign chirp_length             = app_param0              ;
assign proc_length              = app_param1              ;
assign k_data                   = app_param2[23:0]        ;
assign b_data                   = app_param3[23:0]        ;
assign template_delay           = app_param4              ;
assign distance_delay           = app_param5              ;
assign k_b_valid                = app_param6[0]           ;
assign adc_thshld               = app_param7              ;
assign mode_value               = app_param8              ;
assign prf_period               = app_param9              ;
assign prf_adc_delay            = app_param10             ;
assign disturb_times            = app_param11             ; 
assign resetn_sof               = app_param12[0]          ; 
assign prf_adjust_req           = app_param13[0]          ;
assign prf_cnt_offset           = app_param14             ;
assign change_eq                = app_param15[0]          ;
assign star_mode                = app_param16[0]          ;
assign recorde_mode             = app_param17[0]          ;
assign power_adjust_coe         = app_param18             ;
assign channel_sel              = app_param19[0]          ;
assign data_record_period       = app_param20             ;
assign trig_reg                 = app_param21             ;

assign app_status0              = fft_value_max_latch_q   ;
assign app_status1              = fft_value_max_latch_i   ;
assign app_status2              = fft_value_left_latch_q  ;
assign app_status3              = fft_value_left_latch_i  ;
assign app_status4              = fft_value_right_latch_q ;
assign app_status5              = fft_value_right_latch_i ;
assign app_status6              = fft_index_max_latch     ;
assign app_status7              = trig_num                ;
assign app_status8              = trig_gap                ;
assign app_status9              = {31'b0,fft_valid}       ;
assign app_status10             = adc_max_merge;

assign adc_data = channel_sel ? adc_data0 : adc_data1;

`ifdef DISTURB_DEBUG
vio_reg_write u_vio_reg_write (
  .clk          (adc_clk            ), 
  .probe_in0    (chirp_length       ), 
  .probe_in1    (proc_length        ), 
  .probe_in2    (k_data             ), 
  .probe_in3    (b_data             ), 
  .probe_in4    (template_delay     ), 
  .probe_in5    (distance_delay     ), 
  .probe_in6    (k_b_valid          ), 
  .probe_in7    (adc_thshld         ), 
  .probe_in8    (mode_value         ), 
  .probe_in9    (prf_period         ), 
  .probe_in10   (prf_adc_delay      ), 
  .probe_in11   (disturb_times      ), 
  .probe_in12   (resetn_sof         ), 
  .probe_in13   (prf_adjust_req     ), 
  .probe_in14   (prf_cnt_offset     ),  
  .probe_in15   (change_eq          ),  
  .probe_in16   (star_mode          ),  
  .probe_in17   (recorde_mode       ),  
  .probe_in18   (power_adjust_coe   ),  
  .probe_in19   (channel_sel        ), //1 
  .probe_in20   (data_record_period ), //32
  .probe_in21   (trig_reg           )  //32 
);

vio_reg_read u_vio_reg_read (
  .clk          (adc_clk                ), 
  .probe_in0    (fft_value_max_latch_q  ), 
  .probe_in1    (fft_value_max_latch_i  ), 
  .probe_in2    (fft_value_left_latch_q ), 
  .probe_in3    (fft_value_left_latch_i ), 
  .probe_in4    (fft_value_right_latch_q), 
  .probe_in5    (fft_value_right_latch_i), 
  .probe_in6    (fft_index_max_latch    ),
  .probe_in7    (trig_num               ),
  .probe_in8    (trig_gap               ),
  .probe_in9    (fft_valid              ),
  .probe_in10   (adc_max0               ),//32
  .probe_in11   (adc_max1               ) //32
);
`endif

endmodule
