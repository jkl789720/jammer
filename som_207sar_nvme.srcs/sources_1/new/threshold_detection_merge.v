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

input       [31:0]          trig_reg        ,

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

//参数打拍同步
reg [31:0] trig_reg_r[1:0];

//临时触发间隔
reg [31:0] trig_gap_temp;
wire  trig_start;
wire [15:0] trig_num_require;

reg [1:0] trig_start_r;
wire trig_start_pos;



always @(posedge adc_clk) begin
    if(!resetn)begin
        trig_reg_r[0] <= 0;
        trig_reg_r[1] <= 0;
    end
    else begin
        trig_reg_r[0] <= trig_reg;
        trig_reg_r[1] <= trig_reg_r[0];
    end
end


assign trig_start = trig_reg_r[1][31];
assign trig_num_require = trig_reg_r[1][15:0];

//--------------触发间隔---------------------//
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


//---------------------触发次数---------------------//
//上升沿检测
always @(posedge adc_clk) begin
    if(!resetn)
        trig_start_r <= 0;
    else 
        trig_start_r <= {trig_start_r[0],trig_start};
end

assign trig_start_pos = ~trig_start_r[1] && trig_start_r[0];

//触发次数
always@(posedge adc_clk)begin
    if(!resetn)
        trig_num <= 0;
    else if(trig_start_pos)
        trig_num <= 0;
    else if(trig_valid)
        trig_num <= trig_num + 1;
end

//触发检测禁用
assign detection_disen = add_flag | (trig_num == trig_num_require);//触发间隔和触发次数限制

//生成触发信号
assign trig_valid = ~(!resetn || detection_disen) ? trig_valid0 || trig_valid1 : 0;

//gap计数

always@(posedge adc_clk)begin
    if(!resetn)
        trig_gap_temp <= 0;
    else if(trig_start_pos)
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

ila_threshold_detection u_ila_threshold_detection (
	.clk(adc_clk), // input wire clk


	.probe0(trig_valid      ),//1  
	.probe1(trig_num        ),//32 
	.probe2(trig_gap        ),//32 
	.probe3(adc_max0        ),//32 
	.probe4(adc_max1        ),//32 
	.probe5(adc_data0       ),//255
	.probe6(adc_thshld      ),//32 
	.probe7(trig_start_pos  ),//1  
	.probe8(trig_num_require) //16 
);

endmodule
