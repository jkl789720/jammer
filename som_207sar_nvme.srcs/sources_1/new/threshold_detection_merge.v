`timescale 1ns / 1ps
module threshold_detection_merge#(
    parameter   LOCAL_DWIDTH 	    = 256                 ,
    parameter   WIDTH               = 16                  ,
    parameter   FFT_WIDTH           = 24                  ,
    parameter   LANE_NUM            = 8                   ,
    parameter   CHIRP_NUM           = 256                 ,
    parameter   CALCLT_DELAY        = 35                  ,
    parameter   DWIDTH_0            = 32                  ,
    parameter   SHIFT_RAM_DELAY     = (DWIDTH_0 >> 1) + 1 ,
    parameter   ADC_CLK_FREQ        = 156_250_000         ,
    parameter   RECO_DELAY          = 29 
)(
input                       adc_clk         ,
input                       resetn          ,

input       [255:0]         adc_data0       ,
input       [255:0]         adc_data1       ,
input       [31:0]          adc_thshld      ,

output                      trig_valid      ,

output reg  [31:0]          trig_num        ,
output reg  [31:0]          trig_gap        ,

output      [31:0]          adc_max0        ,
output      [31:0]          adc_max1     
);

localparam TIME_100US = ADC_CLK_FREQ/10_000;

wire                 trig_valid0     ;
wire                 trig_valid1     ;

//触发保护计数器
reg [31:0] cnt_delay;//delay阶段不检测
reg add_flag;
wire end_flag;

//临时触发间隔
reg [31:0] trig_gap_temp;

threshold_detection_trig#(
    . LOCAL_DWIDTH 	      (LOCAL_DWIDTH     ) ,
    . WIDTH               (WIDTH            ) ,
    . FFT_WIDTH           (FFT_WIDTH        ) ,
    . LANE_NUM            (LANE_NUM         ) ,
    . CHIRP_NUM           (CHIRP_NUM        ) ,
    . CALCLT_DELAY        (CALCLT_DELAY     ) ,
    . DWIDTH_0            (DWIDTH_0         ) ,
    . SHIFT_RAM_DELAY     (SHIFT_RAM_DELAY  ) ,
    . ADC_CLK_FREQ        (ADC_CLK_FREQ     ) ,
    . RECO_DELAY          (RECO_DELAY       )
)
u_threshold_detection_trig0(
. adc_clk     (adc_clk    )     ,
. resetn      (resetn     )     ,
. adc_data    (adc_data0  )     ,
. adc_thshld  (adc_thshld )     ,
. trig_valid  (trig_valid0)     ,
. adc_max     (adc_max0   )
);

threshold_detection_trig#(
    . LOCAL_DWIDTH 	      (LOCAL_DWIDTH     ) ,
    . WIDTH               (WIDTH            ) ,
    . FFT_WIDTH           (FFT_WIDTH        ) ,
    . LANE_NUM            (LANE_NUM         ) ,
    . CHIRP_NUM           (CHIRP_NUM        ) ,
    . CALCLT_DELAY        (CALCLT_DELAY     ) ,
    . DWIDTH_0            (DWIDTH_0         ) ,
    . SHIFT_RAM_DELAY     (SHIFT_RAM_DELAY  ) ,
    . ADC_CLK_FREQ        (ADC_CLK_FREQ     ) ,
    . RECO_DELAY          (RECO_DELAY       )
)
u_threshold_detection_trig1(
. adc_clk     (adc_clk    )     ,
. resetn      (resetn     )     ,
. adc_data    (adc_data1  )     ,
. adc_thshld  (adc_thshld )     ,
. trig_valid  (trig_valid1)     ,
. adc_max     (adc_max1   )
);


//触发保护计数器生成
always@(posedge adc_clk)begin
    if(!resetn)
        add_flag <= 0;
    else if(trig_valid)
        add_flag <= 1;
    else if(end_flag)
        add_flag <= 0;
end

always@(posedge adc_clk)begin
    if(!resetn)
        cnt_delay <= 0;
    else if(add_flag)begin
        if(end_flag)
            cnt_delay <= 0;
        else
            cnt_delay <= cnt_delay + 1;
    end
    else
        cnt_delay <= 0;
end

assign end_flag = add_flag && cnt_delay == TIME_100US - 1;

//触发检测禁用
assign detection_disen = add_flag;

//生成触发信号
assign trig_valid = ~(!resetn || detection_disen) ? trig_valid0 || trig_valid1 : 0;

//触发次数
always@(posedge adc_clk)begin
    if(!resetn)
        trig_num <= 0;
    else if(trig_valid)
        trig_num <= trig_num + 1;
end

//gap计数

always@(posedge adc_clk)begin
    if(!resetn)
        trig_gap_temp <= 0;
    else if(trig_valid)
        trig_gap_temp <= 0;
    else
        trig_gap_temp <= trig_gap_temp + 1;
end

//锁存gap
always@(posedge adc_clk)begin
    if(!resetn)
        trig_gap <= 0;
    else if(trig_valid && (trig_num > 0))
        trig_gap <= trig_gap_temp;
end

endmodule
