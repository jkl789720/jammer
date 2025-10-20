`timescale 1ns / 1ps
module delay_wrapper
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
input           adc_clk         ,
input           resetn          ,
input  [255:0]  adc_data        ,
input  [31:0]   adc_thshld      ,
input  [31:0]   receive_length  ,//就用proclengh
input  [31:0]   receive_delay   ,
output [255:0]  dac_data        ,
output          dac_valid       ,
output          rf_out          ,
//注debug：调试观测信号
output              trig_valid      ,
output reg [31:0]   cnt_delay   ,
output              fifo_wren       


);
// wire trig_valid;//注debug：调试观测信号

localparam TIME_100NS = 18; // 实际是115.2ns（156.25M）对应的时钟周期数
localparam DWIDTH = 34;

// reg [31:0] cnt_delay;//注debug：调试观测信号
// wire fifo_wren;//注debug：调试观测信号
wire fifo_rden;
wire [255:0] fifo_rddata;
wire fifo_valid;
wire fifo_overflow;
wire fifo_underflow;
reg [DWIDTH:0] CFGBC_OUTEN_r = 0;

//输入数据延时
always @(posedge adc_clk) begin
    if(!resetn)
        cnt_delay <= 32'hffff_ffff;
    else if(trig_valid)
        cnt_delay <= 0;
    else if(cnt_delay == receive_length + receive_delay | cnt_delay == 32'hffff_ffff)
        cnt_delay <= cnt_delay;
    else
        cnt_delay <= cnt_delay + 1;
end

assign fifo_wren = cnt_delay < receive_length;
assign fifo_rden = cnt_delay >= (receive_delay - TIME_100NS) && cnt_delay < (receive_delay - TIME_100NS) + receive_length;//再考虑

//--------------------射频延时--------------------//
shift_ram_delay u_shift_ram_delay (
  .D(fifo_rddata),      // input wire [255 : 0] D
  .CLK(adc_clk),  // input wire CLK
  .Q(dac_data)      // output wire [255 : 0] Q
);


always@(posedge adc_clk)begin
	CFGBC_OUTEN_r <= {CFGBC_OUTEN_r[DWIDTH-1:0], fifo_rden};
end
assign dac_valid = CFGBC_OUTEN_r[DWIDTH/2];//115.2ns

assign rf_out = |CFGBC_OUTEN_r;
fifo_delay256x2048 u_fifo_delay256x2048 (
  .clk        (adc_clk          ), // input wire clk
  .srst       (~resetn          ), // input wire srst
  .din        (adc_data         ), // input wire [255 : 0] din
  .wr_en      (fifo_wren        ), // input wire wr_en
  .rd_en      (fifo_rden        ), // input wire rd_en
  .dout       (fifo_rddata      ), // output wire [255 : 0] dout
  .full       (full             ), // output wire full
  .overflow   (fifo_overflow    ), // output wire overflow
  .empty      (empty            ), // output wire empty
  .valid      (fifo_valid       ), // output wire valid
  .underflow  (fifo_underflow   ), // output wire underflow
  .wr_rst_busy(wr_rst_busy      ), // output wire wr_rst_busy
  .rd_rst_busy(rd_rst_busy      )  // output wire rd_rst_busy
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
. adc_data      (adc_data  ) ,
. adc_thshld    (adc_thshld) ,
. trig_valid    (trig_valid) ,
. adc_max       (adc_max   ) //无用
);


`ifdef TEST
//-----------仿真测试------------------//
reg rd_clk=0;
always # 0.4  rd_clk = ~rd_clk;
wire [31:0] adc_data_32;
wire adc_data_32_valid;
wire [255:0] fifo_din_adc_data;

genvar ii;
generate
    for(ii = 0;ii < 8; ii = ii + 1)begin:blk0
        assign fifo_din_adc_data[(ii+1)*32-1:ii*32] = adc_data[(8-ii)*32-1:(7-ii)*32];
    end
endgenerate





fifo_test u_fifo_test_reco_single (
  .rst(),                  // input wire rst
  .wr_clk(adc_clk),            // input wire wr_clk
  .rd_clk(rd_clk),            // input wire rd_clk
  .din(fifo_din_adc_data),                  // input wire [255 : 0] din
  .wr_en(resetn),              // input wire wr_en
  .rd_en(1),              // input wire rd_en
  .dout(adc_data_32),                // output wire [31 : 0] dout
  .full(full),                // output wire full
  .empty(empty),              // output wire empty
  .wr_rst_busy(wr_rst_busy),  // output wire wr_rst_busy
  .valid(adc_data_32_valid),
  .rd_rst_busy(rd_rst_busy)  // output wire rd_rst_busy
);



`endif
endmodule
