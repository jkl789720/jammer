`timescale 1ns / 1ps
module tb_delay_wrapper;

parameter   LOCAL_DWIDTH      = 256;
parameter   WIDTH             = 16;
parameter   FFT_WIDTH         = 24;
parameter   LANE_NUM          = 8;
parameter   CHIRP_NUM         = 256;
parameter   CALCLT_DELAY      = 35;
parameter   DWIDTH_0          = 32*4;
parameter   SHIFT_RAM_DELAY   = (DWIDTH_0 >> 1) + 1;
parameter   ADC_CLK_FREQ      = 156_250_000;
parameter   RECO_DELAY        = 29;

reg adc_clk;
reg resetn;
reg [31:0] cnt_data;

reg [255:0] adc_data [0:2047];     // 用于readmemh
wire [255:0] adc_data0;            // 当前输入数据

localparam [31:0] app_param7  = 128;//阈值
localparam [31:0] app_param20 = 782;//5us receive_length
localparam [31:0] app_param10 = 1564;//10us receive_delay

assign adc_data0 = adc_data[cnt_data];
wire trig_valid;
// 读取文件
initial begin
    $readmemh("D:/code/verilog/data/delay_jammer/lfm_signal.txt", adc_data);
end

// 时钟和复位
initial begin
    adc_clk = 0;
    resetn = 0;
    #100 resetn = 1;
end

always #3.2 adc_clk = ~adc_clk;

// 控制计数器
always @(posedge adc_clk) begin
    if (!resetn)
        cnt_data <= 0;
    else if(trig_valid)
        cnt_data <= 0;
    if (cnt_data < app_param20)
        cnt_data <= cnt_data + 1;
end

// 实例化被测模块
delay_wrapper #(
    .LOCAL_DWIDTH     (LOCAL_DWIDTH),
    .WIDTH            (WIDTH),
    .FFT_WIDTH        (FFT_WIDTH),
    .LANE_NUM         (LANE_NUM),
    .CHIRP_NUM        (CHIRP_NUM),
    .CALCLT_DELAY     (CALCLT_DELAY),
    .DWIDTH_0         (DWIDTH_0),
    .SHIFT_RAM_DELAY  (SHIFT_RAM_DELAY),
    .ADC_CLK_FREQ     (ADC_CLK_FREQ),
    .RECO_DELAY       (RECO_DELAY)
) u_delay_wrapper (
    .adc_clk         (adc_clk),
    .resetn          (resetn),
    .adc_data        (adc_data0),
    .adc_thshld      (app_param7),
    .receive_length  (app_param20),
    .receive_delay   (app_param10),
    .dac_data          (dac_data)
);

threshold_detection_trig#(
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
)u_threshold_detection_trig(
. adc_clk       (adc_clk   ) ,
. resetn        (resetn    ) ,
. adc_data      (adc_data0  ) ,
. adc_thshld    (app_param7) ,
. trig_valid    (trig_valid) ,
. adc_max       (adc_max   ) //无用
);

endmodule
