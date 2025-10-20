/*
模块功能：根据各个通道触发时的幅值大小选择，选幅值大的通道，并输出相关通道的触发信息
*/
`timescale 1ns / 1ps
module adc_channel_sel#(
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
input                           adc_clk           ,
input                           resetn            ,
input    [31:0]                 adc_thshld        ,
input    [WIDTH*2*8-1:0]        adc_data0         ,//更改端口
input    [WIDTH*2*8-1:0]        adc_data1         ,//更改端口

output reg  [WIDTH*2*8-1:0]     adc_data          ,
output reg                      trig_valid        ,
output reg   [31:0]             trig_num          ,
output reg   [31:0]             trig_gap          ,
output reg   [31:0]             adc_avg_reg     
);

//ad0
wire                 trig_valid0     ;
wire [15:0]          trig_adc_value0 ;
wire [31:0]          trig_num0       ;
wire [31:0]          trig_gap0       ;
wire [31:0]          adc_avg_reg0    ;

//ad1
wire                 trig_valid1     ;
wire [15:0]          trig_adc_value1 ;
wire [31:0]          trig_num1       ;
wire [31:0]          trig_gap1       ;
wire [31:0]          adc_avg_reg1    ;

reg [15:0] trig_adc_value0_r;
reg [15:0] trig_adc_value1_r;

//分别标识adc0、adc1已经触发过一次
reg adc0_trig_data_valid;
reg adc1_trig_data_valid;
wire adc_trig_data_valid;//标识adc0和adc1都已经触发过一次

reg adc_sel;
reg adc_sel_done;

//锁存trig_adc_value0一次并表示数据有效
always @(posedge adc_clk) begin
    if(!resetn)begin
        trig_adc_value0_r <= 0;
        adc0_trig_data_valid <= 0;
    end
    else if(trig_valid0 && adc0_trig_data_valid == 0)begin
        trig_adc_value0_r <= trig_adc_value0;
        adc0_trig_data_valid <= 1;
    end
end
//锁存trig_adc_value0一次并表示数据有效
always @(posedge adc_clk) begin
    if(!resetn)begin
        trig_adc_value1_r <= 0;
        adc1_trig_data_valid <= 0;
    end
    else if(trig_valid1 && adc1_trig_data_valid == 0)begin
        trig_adc_value1_r <= trig_adc_value1;
        adc1_trig_data_valid <= 1;
    end
        
end

//adc0和adc1都已经触发过一次
assign adc_trig_data_valid = adc0_trig_data_valid && adc1_trig_data_valid;

//生成adc_sel信号，并且选择信号只生成一次
always @(posedge adc_clk) begin
    if(!resetn)begin
        adc_sel <= 0;
        adc_sel_done <= 0;
    end
    else if(adc_trig_data_valid && adc_sel_done == 0)begin
        adc_sel_done <= 1;
        if(trig_adc_value0_r >= trig_adc_value1_r)
            adc_sel <= 0;
        else
            adc_sel <= 1;
    end
end

//----------------根据sel信号选择对应通道数据------------------//
always@(posedge adc_clk)begin
    if(!resetn)begin
        adc_data <= 0;
    end
    else if(adc_sel_done)
        adc_data <= adc_sel ? adc_data1 : adc_data0;
end
  
always@(posedge adc_clk)begin
    if(!resetn)begin
        trig_valid <= 0;
    end
    else if(adc_sel_done)
        trig_valid   = adc_sel ? trig_valid1  : trig_valid0  ;
end
  
always@(posedge adc_clk)begin
    if(!resetn)begin
        trig_num <= 0;
    end
    else if(adc_sel_done)
        trig_num     = adc_sel ? trig_num1    : trig_num0    ;
end
  
always@(posedge adc_clk)begin
    if(!resetn)begin
        trig_gap <= 0;
    end
    else if(adc_sel_done)
        trig_gap     = adc_sel ? trig_gap1    : trig_gap0    ;
end
  
always@(posedge adc_clk)begin
    if(!resetn)begin
        adc_avg_reg <= 0;
    end
    else if(adc_sel_done)
        adc_avg_reg  = adc_sel ? adc_avg_reg1 : adc_avg_reg0 ;
end
  
  
threshold_detection#(
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
u_threshold_detection_ad0(
. adc_clk           (adc_clk            ) ,
. resetn            (resetn             ) ,
. adc_data          (adc_data0          ) ,
. adc_thshld        (adc_thshld         ) ,
. trig_valid        (trig_valid0        ) ,
. trig_adc_value    (trig_adc_value0    ) ,
. trig_num          (trig_num0          ) ,
. trig_gap          (trig_gap0          ) ,
. adc_avg_reg       (adc_avg_reg0       ) 
); 

threshold_detection#(
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
u_threshold_detection_ad1(
    . adc_clk           (adc_clk            ) ,
    . resetn            (resetn             ) ,
    . adc_data          (adc_data1          ) ,
    . adc_thshld        (adc_thshld         ) ,
    . trig_valid        (trig_valid1        ) ,
    . trig_adc_value    (trig_adc_value1    ) ,
    . trig_num          (trig_num1          ) ,
    . trig_gap          (trig_gap1          ) ,
    . adc_avg_reg       (adc_avg_reg1       ) 
); 

endmodule
