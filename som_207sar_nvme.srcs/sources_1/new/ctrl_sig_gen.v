`include "configure.vh"
`timescale 1ns / 1ps
module ctrl_sig_gen#(
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
)(
input                     adc_clk             ,
input                     resetn              ,
input        [31:0]       proc_length         ,
input signed [31:0]       prf_period          ,
input signed [31:0]       prf_adc_delay       ,
input        [31:0]       disturb_times       ,
input        [31:0]       mode_value          ,
input                     trig_valid          ,

input                     prf_adjust_req      ,
input signed [31:0]       prf_cnt_offset      ,

input                     k_b_valid           ,
input        [31:0]       distance_delay      ,
input signed [31:0]       template_delay      ,
input        [23:0]       k_data              ,
input        [23:0]       b_data              ,

input        [31:0]       chirp_length        ,
input                     dac_valid_o         ,
input                     star_mode           ,

input                     fft_valid_latch     ,
input                     fft_valid           ,

output reg      [31:0]    distance_delay_now  ,  
output reg      [31:0]    template_delay_now  ,  
output reg      [23:0]    k_data_now          ,  
output reg      [23:0]    b_data_now          ,  

output                    prf                 ,
output                    adc_valid           ,
output reg                reco_trig           ,//提前一个生成
output reg                ddr_read_trig       ,//提前一个生成
output                    adc_valid_pre       ,
output                    adc_valid_expand    ,
output                    rf_out              ,
input           [13:0]    fft_index_max_latch
    );
    
localparam TIME_100NS = ADC_CLK_FREQ/(10_000_000);
localparam TIME_100US = ADC_CLK_FREQ/(10000);
localparam TIME_10US = ADC_CLK_FREQ/(100_000);
//-------prf矫正请求处理
reg [2:0] prf_adjust_req_r;
wire prf_adjust_req_pos;
wire prf_adjust_ready;
reg prf_adjust_req_keep;
wire prf_adjust_valid;

//adc_valid_gen
wire [31:0] adc_length;
reg add_flag;
wire end_flag;
reg [31:0] adc_times;
reg adc_valid_r;
wire adc_valid_neg;


//prf_gen
reg signed [31:0] cnt_prf1;
wire prf1;

//mode
wire [1:0] mode;


//prf_adjust generate
always@(posedge adc_clk)begin
    if(!resetn)
        prf_adjust_req_r <= 0;
    else 
        prf_adjust_req_r <= {prf_adjust_req_r[1:0],prf_adjust_req};
end
assign prf_adjust_req_pos = (~prf_adjust_req_r[2]) && prf_adjust_req_r[1];

assign prf_adjust_ready = mode_value == 2 && (adc_times <= disturb_times - 1) && (cnt_prf1 >= prf_adc_delay + $signed(adc_length) + $signed(adc_length)) ;
assign prf_adjust_valid = prf_adjust_req_keep && prf_adjust_ready;
always@(posedge adc_clk)begin
    if(!resetn)
        prf_adjust_req_keep <= 0;
    else if(prf_adjust_req_pos)
        prf_adjust_req_keep <= 1;
    else if(prf_adjust_valid)
        prf_adjust_req_keep <= 0;
end




//prf generate

always@(posedge adc_clk)begin
    if(!resetn)
        cnt_prf1 <= 0;

    else if(mode_value == 1)begin
        if(trig_valid)
            cnt_prf1 <= 0;
        else
            cnt_prf1 <= cnt_prf1 + 32'sd1;
    end

    else if(mode_value == 2)begin
        if(prf_adjust_valid)begin
            if(cnt_prf1 + prf_cnt_offset >= prf_period - 32'sd1)
                cnt_prf1 <= 0;
            else
                cnt_prf1 <= cnt_prf1 + prf_cnt_offset + 32'sd1;
        end
        else begin
            if(cnt_prf1 == prf_period - 32'sd1)
                cnt_prf1 <= 0;
            else
                cnt_prf1 <= cnt_prf1 + 32'sd1;
        end
    end

    else
        cnt_prf1 <= 0;
end

assign prf1 = cnt_prf1 < (TIME_100US - 32'sd1);


assign prf = prf1;


//adc_valid generate
reg wait_prf;
reg prf_r;
wire prf_pos;
always@(posedge adc_clk)begin
    if(!resetn)
        adc_valid_r <= 0;
    else
        adc_valid_r <= adc_valid;
end
assign adc_valid_neg = adc_valid_r && (~adc_valid);
assign adc_length = (proc_length >> 3);

always@(posedge adc_clk)begin
    if(!resetn)
        adc_times <= 0;
    else if(adc_valid_neg)begin
        if(adc_times == disturb_times)
            adc_times <= adc_times;
        else
            adc_times <= adc_times + 1;
    end
end

always@(posedge adc_clk)begin
    if(!resetn)
        prf_r <= 0;
    else
        prf_r <= prf;
end

assign prf_pos = ~prf_r && prf;

always@(posedge adc_clk)begin
    if(!resetn)
        wait_prf <= 0;
    else if(mode_value == 2 && prf_pos)
        wait_prf <= 1;
end
wire signed [15 : 0] dac_limit_value;
vio_dac_limit u_vio_dac_limit (
  .clk(adc_clk),                // input wire clk
  .probe_out0(dac_limit_value)  // output wire [15 : 0] probe_out0
);

assign adc_valid =  wait_prf && mode_value == 2 && (adc_times <= disturb_times - 1) && (cnt_prf1 >= prf_adc_delay) && (cnt_prf1 < (prf_adc_delay + adc_length));
assign adc_valid_pre = wait_prf && mode_value == 2 && (adc_times <= disturb_times - 1) && (cnt_prf1 >= prf_adc_delay - 1) && (cnt_prf1 < (prf_adc_delay + adc_length - 1));

assign adc_valid_expand = wait_prf && mode_value == 2 && (adc_times <= disturb_times - 1) && (cnt_prf1 >= prf_adc_delay - dac_limit_value) && (cnt_prf1 < (prf_adc_delay + adc_length));


//k、b distance_delay template_delay逻辑生成
reg [31:0]       distance_delay_r [3:0];
reg [31:0]       template_delay_r [3:0];
reg [23:0]       k_data_r         [3:0];
reg [23:0]       b_data_r         [3:0];
reg [2:0]        k_b_valid_r;
wire             k_b_valid_pos;


always@(posedge adc_clk)begin
    if(!resetn)begin
        k_b_valid_r[0] <= 0;
        k_b_valid_r[1] <= 0;
        k_b_valid_r[2] <= 0;
    end
    else begin
        k_b_valid_r[0] <= k_b_valid;
        k_b_valid_r[1] <= k_b_valid_r[0];
        k_b_valid_r[2] <= k_b_valid_r[1];
    end
end

assign k_b_valid_pos = (~k_b_valid_r[2]) && k_b_valid_r[1];

reg [1:0] cnt_kb;

always@(posedge adc_clk)begin
    if(!resetn)
        cnt_kb <= 0;
    else if(k_b_valid_pos)
        cnt_kb <= cnt_kb + 1;
end

assign mode = mode_value[1:0];

genvar yy;
generate 
    for(yy =0;yy < 4;yy = yy + 1)begin:blk
        always@(posedge adc_clk)begin
            if(!resetn)begin
                distance_delay_r[yy] <= 0;
                template_delay_r[yy] <= 0;
                k_data_r[yy]         <= 0;
                b_data_r[yy]         <= 0;
            end
            else if(k_b_valid_pos && cnt_kb == yy)begin
                distance_delay_r[yy] <= distance_delay ;
                template_delay_r[yy] <= template_delay ;
                k_data_r[yy]         <= k_data         ;
                b_data_r[yy]         <= b_data         ;
            end
        end
    end
endgenerate



//reco_trig_generate
//---------------------------延时生成---------------------------//
reg signed [28:0] reco_in_delay;
reg signed [28:0] reco_out_delay;
wire signed [28:0] template_delay_int; 
reg  signed [28:0] ddr_trig_delay;
reg signed [28:0] ddr_valid_delay;
reg  signed [31:0] cnt_delay_real;
wire signed [31:0] cnt_delay;
wire signed [28:0] max_value;

reg [31:0] cnt0,cnt1,cnt2,cnt3;//三个计数器
reg [1:0]  cnt_adc_valid;//标识adc_valid
reg [1:0]  cnt_dac_valid;//标识dac_valid

reg [31:0] cnt_delay_spec;//dac_valid下降沿在adc_valid上升沿之前这种特殊情况，避免使用无效的计数器
reg delay_add_flag;
wire delay_end_flag;
wire spec_flag;

wire adc_valid_pos;
wire dac_valid_neg;
reg  dac_valid_r;

reg valid_cnt;//延时值计数器有效的标志，如果为0表示计数器无效

reg param_valid_flag;

reg [31:0] cnt_kb_ovtime;
reg [31:0] cnt_da_ovtime;

always@(posedge adc_clk)begin
    if(!resetn)
        dac_valid_r <= 0;
    else
        dac_valid_r <= dac_valid_o;
end

assign dac_valid_neg = (~dac_valid_o) && dac_valid_r;

//adc_valid标识计数器生成 考虑到adc_valid的周期不是固定的，所以没有采用最大值清零这种逻辑
always@(posedge adc_clk)begin
    if(!resetn)
        cnt_adc_valid <= 0;
    else if(adc_valid_pos)
        cnt_adc_valid <= cnt_adc_valid + 1;
end

//dac_valid标识计数器生成
always@(posedge adc_clk)begin
    if(!resetn)
        cnt_dac_valid <= 0;
    else if(dac_valid_neg)
        cnt_dac_valid <= cnt_dac_valid + 1;
end

//cnt0生成
always@(posedge adc_clk)begin
    if(!resetn)
        cnt0 <= 0;
    else if(adc_valid_pos && cnt_adc_valid == 0)
        cnt0 <= 0;
    else
        cnt0 <= cnt0 + 1;
end

//cnt1生成
always@(posedge adc_clk)begin
    if(!resetn)
        cnt1 <= 0;
    else if(adc_valid_pos && cnt_adc_valid == 1)
        cnt1 <= 0;
    else
        cnt1 <= cnt1 + 1;
end

//cnt2生成
always@(posedge adc_clk)begin
    if(!resetn)
        cnt2 <= 0;
    else if(adc_valid_pos && cnt_adc_valid == 2)
        cnt2 <= 0;
    else
        cnt2 <= cnt2 + 1;
end

//cnt3生成
always@(posedge adc_clk)begin
    if(!resetn)
        cnt3 <= 0;
    else if(adc_valid_pos && cnt_adc_valid == 3)
        cnt3 <= 0;
    else
        cnt3 <= cnt3 + 1;
end

always@(posedge adc_clk)begin
    if(!resetn)
        valid_cnt <= 0;
    else if(adc_valid)
        valid_cnt <= 1;
end

always@(posedge adc_clk)begin
    if(!resetn)
        param_valid_flag <= 0;
    else if(k_b_valid_pos)
        param_valid_flag <= 1;
end


always@(posedge adc_clk)begin
  if(!resetn)
    delay_add_flag <= 0;
  else if(adc_valid_pos)
    delay_add_flag <= 1;
  else if(delay_end_flag)
    delay_add_flag <= 0;
end
assign delay_end_flag = delay_add_flag && cnt_delay_spec == distance_delay_now[31:3] - 1;

always@(posedge adc_clk)begin
  if(!resetn)
    cnt_delay_spec <= 0;
  else if(delay_add_flag || adc_valid_pos)begin
    if(delay_end_flag)
      cnt_delay_spec <= 0;
    else 
      cnt_delay_spec <= cnt_delay_spec + 1;
  end
  else 
    cnt_delay_spec <= 0;
end

assign spec_flag = (distance_delay_now[31:3] + (chirp_length >> 3)) <= prf_period;

always@(*)begin
    if(!resetn)
        cnt_delay_real = 0;
    else if(spec_flag)
        cnt_delay_real = cnt_delay_spec;
    else if(valid_cnt)begin
        case (cnt_dac_valid)
            0: cnt_delay_real = cnt0;
            1: cnt_delay_real = cnt1;
            2: cnt_delay_real = cnt2;
            3: cnt_delay_real = cnt3;
        endcase
    end
    else
        cnt_delay_real = 0;
end

// assign max_value = reco_in_delay > ddr_trig_delay ? reco_in_delay : ddr_trig_delay;


assign adc_valid_pos = ~adc_valid_r && adc_valid;

// assign distance_delay_now = distance_delay_r[cnt_dac_valid]    ;
// assign template_delay_now = template_delay_r[cnt_dac_valid]    ;
// assign k_data_now         = k_data_r[cnt_dac_valid]            ;
// assign b_data_now         = b_data_r[cnt_dac_valid]            ;

//采用寄存器打拍延时
always@(posedge adc_clk)begin
    if(!resetn)begin
        distance_delay_now <= 0;
        template_delay_now <= 0;
        k_data_now         <= 0;
        b_data_now         <= 0;
    end
    else begin
        distance_delay_now <= distance_delay_r[cnt_dac_valid];
        template_delay_now <= template_delay_r[cnt_dac_valid];
        k_data_now         <= k_data_r[cnt_dac_valid]        ;
        b_data_now         <= b_data_r[cnt_dac_valid]        ;
    end

end




// assign reco_in_delay        = $signed(distance_delay_now[31:3]) - $signed(CALCLT_DELAY) - $signed(SHIFT_RAM_DELAY);
// assign reco_out_delay       = reco_in_delay + RECO_DELAY;
// assign ddr_valid_delay      = reco_out_delay + template_delay_int;//需要ddr模板数据输出的时间

//计算参数并生成trig信号 (只计算参数，因此打拍不影响trig信号到输出)

assign template_delay_int   = template_delay_now[31] == 0 ? template_delay_now[31:3] : template_delay_now[31:3];

always@(posedge adc_clk)begin
    if(!resetn)
        reco_in_delay <= 0;
    else
        reco_in_delay  <= $signed(distance_delay_now[31:3]) - $signed(CALCLT_DELAY) - $signed(SHIFT_RAM_DELAY) - 1;//多减去1是因为dac_data_pre模块功率校准多打了一拍
end

always@(posedge adc_clk)begin
    if(!resetn)
        reco_out_delay <= 0;
    else
        reco_out_delay <= reco_in_delay + RECO_DELAY;
end

always@(posedge adc_clk)begin
    if(!resetn)
        ddr_valid_delay <= 0;
    else
        ddr_valid_delay <= reco_out_delay + template_delay_int;//需要ddr模板数据输出的时间
end

always@(posedge adc_clk)begin
    if(!resetn)
        ddr_trig_delay <= 0;
    else 
        ddr_trig_delay <= star_mode ? ddr_valid_delay - 3 : ddr_valid_delay;//星载减去3是因为ddr_trig比模板数据输出时间早3个周期
end

always@(posedge adc_clk)begin
    if(!resetn)
        ddr_read_trig <= 0;
    else
        ddr_read_trig <= param_valid_flag && (cnt_delay ==  ddr_trig_delay) && (cnt_da_ovtime < disturb_times);
end

always@(posedge adc_clk)begin
    if(!resetn)
        reco_trig <= 0;
    else
        reco_trig <= param_valid_flag && (cnt_delay == reco_in_delay) && (cnt_da_ovtime < disturb_times);
end

// assign reco_in_delay = $signed(distance_delay_now[31:3]) - $signed(CALCLT_DELAY) - $signed(SHIFT_RAM_DELAY);

// assign reco_out_delay = reco_in_delay + RECO_DELAY;

// assign ddr_valid_delay = reco_out_delay + template_delay_int;




assign cnt_delay = cnt_delay_real;

always@(posedge adc_clk)begin
    if(!resetn)
        cnt_kb_ovtime <= 0;
    else if(k_b_valid_pos )
        cnt_kb_ovtime <= cnt_kb_ovtime + 1;
end

always@(posedge adc_clk)begin
    if(!resetn)
        cnt_da_ovtime <= 0;
    else if(dac_valid_neg )
        cnt_da_ovtime <= cnt_da_ovtime + 1;
end

//fft_valid计数
reg [31:0] cnt_fft_valid;
reg [31:0] cnt_fft_valid_latch;

reg fft_valid_r;
wire fft_valid_pos;

always@(posedge adc_clk)begin
    if(!resetn)
        fft_valid_r <= 0;
    else
        fft_valid_r <= fft_valid;
end
assign fft_valid_pos = ~fft_valid_r && fft_valid;

always@(posedge adc_clk)begin
    if(!resetn)
        cnt_fft_valid       <= 0;
    else if(fft_valid_pos)
        cnt_fft_valid       <= cnt_fft_valid + 1;
end

always@(posedge adc_clk)begin
    if(!resetn)
        cnt_fft_valid_latch <= 0;
    else if(fft_valid_latch)
        cnt_fft_valid_latch <= cnt_fft_valid_latch + 1;
end

`ifdef DISTURB_DEBUG
ila_ctrl_sig_gen u_ila_ctrl_sig_gen (
	.clk         (adc_clk                       ),
	.probe0      (distance_delay_now            ), //32
	.probe1      (template_delay_now            ), //32
	.probe2      (k_data_now                    ), //24
	.probe3      (b_data_now                    ), //24
	.probe4      (k_b_valid_pos                 ), //1
    .probe5      (cnt_prf1                      ), //32
    .probe6      (distance_delay_r[3]           ), //32
    .probe7      (template_delay_r[3]           ), //32
    .probe8      (k_data_r[3]                   ), //24
    .probe9      (b_data_r[3]                   ), //24
    .probe10     (cnt_kb                        ), //2
    .probe11     (cnt_dac_valid                 ), //2
    .probe12     (k_data                        ), //24
    .probe13     (b_data                        ), //24
    .probe14     (cnt_kb_ovtime                 ), //32
    .probe15     (cnt_da_ovtime                 ), //32
    .probe16     (dac_valid_o                   ), //1
    .probe17     (adc_times                     ), //32
    .probe18     (cnt_fft_valid                 ), //32
    .probe19     (cnt_fft_valid_latch           ), //32
    .probe20     (prf_adjust_valid              ), //1
    .probe21     (prf_cnt_offset                ), //32
    .probe22     (cnt_prf1                      ), //32
    .probe23     (fft_index_max_latch           )  //13
);

`endif
reg rf_out_temp;
always@(posedge adc_clk)begin
    if(!resetn)
        rf_out_temp <= 0;
    else if(cnt_da_ovtime == disturb_times)
        rf_out_temp <= 0;
    else if(cnt_delay == (distance_delay_now[31:3] - TIME_10US - 1))
        rf_out_temp <= 1;
    else if(dac_valid_neg)
        rf_out_temp <= 0;
end
assign rf_out = ~rf_out_temp;
wire signed [31:0] value_in;
wire signed [31:0] test1;
wire signed [31:0] test2;
wire signed [28:0] test3;

assign value_in = -32'sd247;
assign test1 = value_in / 8;
assign test2 = value_in >>> 3;
assign test3 = value_in[2:0] == 3'b000 ? value_in[31:3] : $signed(value_in[31:3]) + 28'sd1;

endmodule
