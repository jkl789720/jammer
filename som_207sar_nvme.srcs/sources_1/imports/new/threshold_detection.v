// `include "configure.vh"
`timescale 1ns / 1ps
module threshold_detection#(
    parameter   LOCAL_DWIDTH 	      = 256                 ,
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
input       [255:0]         adc_data        ,
input       [31:0]          adc_thshld      ,
output                      trig_valid      ,
output reg  [31:0]          trig_num        ,
output reg  [31:0]          trig_gap        ,
output reg  [31:0]          adc_avg_reg     

    );
    
    
localparam TIME_100US = ADC_CLK_FREQ/10_000;

// wire trig_valid;
wire detection_disen;
reg signed [19:0] sum_adc_data;
wire [31:0] sum_adc_data_cut;

//间隔计数器生成
reg [31:0] cnt_delay;//delay阶段不检测
reg add_flag;
wire end_flag;

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

//触发条件判断
// assign sum_adc_data = adc_data[31:0] + adc_data[63:32] + adc_data[95:64] + adc_data[127:96] + adc_data[159:128] + adc_data[191:160] + adc_data[223:192] + adc_data[255:224];
// genvar jj;
// generate
//     for (jj = 0;jj < 8 ;jj = jj + 1 ) begin
//         if(jj = 0)begin
//             always@(posedge adc_clk)begin

//             end

//         end
//     end
// endgenerate
reg signed [19:0] sum_adc_data_pre[7:0];
always@(posedge adc_clk)begin
    if(!resetn)begin
        sum_adc_data_pre[0] <= 0;
        sum_adc_data_pre[1] <= 0;
        sum_adc_data_pre[2] <= 0;
        sum_adc_data_pre[3] <= 0;
        sum_adc_data_pre[4] <= 0;
        sum_adc_data_pre[5] <= 0;
        sum_adc_data_pre[6] <= 0;
        sum_adc_data_pre[7] <= 0;
        sum_adc_data        <= 0;
    end
    else begin
        sum_adc_data_pre[0] <= ($signed(adc_data[15:0]) >= 0 ? $signed(adc_data[15:0]) : -$signed(adc_data[15:0])) + ( $signed(adc_data[31:16]) >=0 ? $signed(adc_data[31:16]): -$signed(adc_data[31:16]) );
        sum_adc_data_pre[1] <= $signed(sum_adc_data_pre[0]) + ( $signed(adc_data[47:32]  ) >= 0 ? $signed(adc_data[47:32]  ) : -$signed(adc_data[47:32]  ) ) + ( $signed(adc_data[63:48]   ) >= 0 ? $signed(adc_data[63:48]   )  : -$signed(adc_data[63:48]   ) );
        sum_adc_data_pre[2] <= $signed(sum_adc_data_pre[1]) + ( $signed(adc_data[79:64]  ) >= 0 ? $signed(adc_data[79:64]  ) : -$signed(adc_data[79:64]  ) ) + ( $signed(adc_data[95:80]   ) >= 0 ? $signed(adc_data[95:80]   )  : -$signed(adc_data[95:80]   ) );
        sum_adc_data_pre[3] <= $signed(sum_adc_data_pre[2]) + ( $signed(adc_data[111:96] ) >= 0 ? $signed(adc_data[111:96] ) : -$signed(adc_data[111:96] ) ) + ( $signed(adc_data[127:112] ) >= 0 ? $signed(adc_data[127:112] )  : -$signed(adc_data[127:112] ) );
        sum_adc_data_pre[4] <= $signed(sum_adc_data_pre[3]) + ( $signed(adc_data[143:128]) >= 0 ? $signed(adc_data[143:128]) : -$signed(adc_data[143:128]) ) + ( $signed(adc_data[159:144] ) >= 0 ? $signed(adc_data[159:144] )  : -$signed(adc_data[159:144] ) );
        sum_adc_data_pre[5] <= $signed(sum_adc_data_pre[4]) + ( $signed(adc_data[175:160]) >= 0 ? $signed(adc_data[175:160]) : -$signed(adc_data[175:160]) ) + ( $signed(adc_data[191:176] ) >= 0 ? $signed(adc_data[191:176] )  : -$signed(adc_data[191:176] ) );
        sum_adc_data_pre[6] <= $signed(sum_adc_data_pre[5]) + ( $signed(adc_data[207:192]) >= 0 ? $signed(adc_data[207:192]) : -$signed(adc_data[207:192]) ) + ( $signed(adc_data[223:208] ) >= 0 ? $signed(adc_data[223:208] )  : -$signed(adc_data[223:208] ) );
        sum_adc_data        <= $signed(sum_adc_data_pre[6]) + ( $signed(adc_data[239:224]) >= 0 ? $signed(adc_data[239:224]) : -$signed(adc_data[239:224]) ) + ( $signed(adc_data[255:240] ) >= 0 ? $signed(adc_data[255:240] )  : -$signed(adc_data[255:240] ) );
    end
end

// assign sum_adc_data_cut = sum_adc_data[32] == 1 ? 32'hffff_ffff : sum_adc_data[31:0];
reg s_axis_data_tvalid;
wire [15:0] avg_adc_data;
assign avg_adc_data = sum_adc_data[19:4];
wire        m_axis_data_tvalid;
wire [23:0] m_axis_data_tdata;
wire [15:0] avg_adc_data_filter;
always@(posedge adc_clk)begin
    if(!resetn)
        s_axis_data_tvalid <= 0;
    else
        s_axis_data_tvalid <= 1;
end
fir_compiler_0 u_fir_compiler_0 (
  .aresetn(resetn),                        // input wire aresetn
  .aclk(adc_clk),                              // input wire aclk
  .s_axis_data_tvalid(s_axis_data_tvalid),  // input wire s_axis_data_tvalid
  .s_axis_data_tready(s_axis_data_tready),  // output wire s_axis_data_tready
  .s_axis_data_tdata(avg_adc_data),    // input wire [15 : 0] s_axis_data_tdata
  .m_axis_data_tvalid(m_axis_data_tvalid),  // output wire m_axis_data_tvalid
  .m_axis_data_tdata(m_axis_data_tdata)    // output wire [23 : 0] m_axis_data_tdata
);

assign avg_adc_data_filter = m_axis_data_tdata[19:4];

reg [31:0] cnt_1s;
reg [31:0] avg_adc_data_filter_max;
always@(posedge adc_clk)begin
    if(!resetn)
        cnt_1s <= 0;
    else if(cnt_1s == 150_000_000 - 1)
        cnt_1s <= 0;
    else
        cnt_1s <= cnt_1s + 1;
end

always@(posedge adc_clk)begin
    if(!resetn)
        avg_adc_data_filter_max <= 0;
    else if(cnt_1s == 0)
        avg_adc_data_filter_max <= 0;
    else 
        avg_adc_data_filter_max <= avg_adc_data_filter >= avg_adc_data_filter_max ? avg_adc_data_filter : avg_adc_data_filter_max;
end


always@(posedge adc_clk)begin
    if(!resetn)
        adc_avg_reg <= 0;
    else if(cnt_1s == 150_000_000 - 1)
        adc_avg_reg <= avg_adc_data_filter_max;
end


wire trig_valid_temp;
// assign trig_valid_temp = (adc_thshld) < {2'b0,sum_adc_data[32:3]};

assign trig_valid = ~(!resetn || detection_disen) ? (adc_thshld) < avg_adc_data_filter : 0;

//触发次数
always@(posedge adc_clk)begin
    if(!resetn)
        trig_num <= 0;
    else if(trig_valid)
        trig_num <= trig_num + 1;
end

//gap计数
reg [31:0] trig_gap_temp;
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


`ifdef DISTURB_DEBUG
ila_threshold_check u_ila_threshold_check (
	.clk    (adc_clk                ), 
	.probe0 (avg_adc_data           ), //16
	.probe1 (avg_adc_data_filter    ), //16
	.probe2 (trig_valid             ), //1
	.probe3 (trig_num               ), //32
	.probe4 (trig_gap               )  //32
);
`endif

endmodule
