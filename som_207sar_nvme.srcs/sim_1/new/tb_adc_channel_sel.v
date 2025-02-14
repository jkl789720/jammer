`timescale 1ns / 1ps

module tb_adc_channel_sel;

// 模块参数
parameter WIDTH          = 16;
parameter LOCAL_DWIDTH   = 256;
parameter ADC_CLK_FREQ   = 156_250_000;

// 输入信号
reg                      adc_clk;
reg                      resetn;
reg         [31:0]       adc_thshld;
reg  [WIDTH*2*8-1:0]    adc_data0;
reg  [WIDTH*2*8-1:0]    adc_data1;

// 输出信号
wire [WIDTH*2*8-1:0]    adc_data;
wire                    trig_valid;
wire        [31:0]      trig_num;
wire        [31:0]      trig_gap;
wire        [31:0]      adc_avg_reg;

// 时钟周期定义
localparam CLK_PERIOD = 1e9 / ADC_CLK_FREQ * 2; // 计算时钟周期（单位：ns）

// 实例化被测模块
adc_channel_sel #(
    .LOCAL_DWIDTH(LOCAL_DWIDTH),
    .WIDTH(WIDTH),
    .ADC_CLK_FREQ(ADC_CLK_FREQ)
) uut (
    .adc_clk(adc_clk),
    .resetn(resetn),
    .adc_thshld(adc_thshld),
    .adc_data0(adc_data0),
    .adc_data1(adc_data1),
    .adc_data(adc_data),
    .trig_valid(trig_valid),
    .trig_num(trig_num),
    .trig_gap(trig_gap),
    .adc_avg_reg(adc_avg_reg)
);

// 生成时钟
always #(CLK_PERIOD/2) adc_clk = ~adc_clk;

// 测试激励
initial begin
    // 初始化信号
    adc_clk = 0;
    resetn = 0;
    adc_thshld = 32'h1000; // 设置阈值为4096
    adc_data0 = 0;
    adc_data1 = 0;

    // 复位过程
    #100 resetn = 1;
    #100;

    // 测试场景1：通道0触发且幅值更大
    // 构造通道0数据：第3个lane的I=5000 (>阈值)
    adc_data0 = {16{16'h5000}}; // 设置第3个lane的I值
    adc_data1 = {16{16'h4000}};
    #200;

    // 测试场景2：通道1触发且幅值更大
    adc_data0[16*2*3 +: 16] = 16'h3000; // 通道0幅值3000
    adc_data1[16*2*5 +: 16] = 16'h6000; // 通道1幅值6000
    #200;

    // 测试场景3：同时触发且幅值相等
    adc_data0[16*2*3 +: 16] = 16'h5000;
    adc_data1[16*2*5 +: 16] = 16'h5000;
    #200;

    $finish;
end

// 监控关键信号
always @(posedge adc_clk) begin
    if(resetn) begin
        $display("Time=%t | ADC_SEL=%b | TrigValid=%b | TrigNum=%d | ADC_DATA=%h",
                 $time, uut.adc_sel, trig_valid, trig_num, adc_data);
    end
end

// 波形记录
initial begin
    $dumpfile("tb_adc_channel_sel.vcd");
    $dumpvars(0, tb_adc_channel_sel);
end

endmodule