`timescale 1ns / 1ps
`include "configure.vh"
module wave_ctrl_sig_gen#(
    parameter LANE_BIT         = 20                              ,
    parameter FRAME_DATA_BIT   = 80                              ,
    parameter GROUP_CHIP_NUM   = 4                               ,
    parameter GROUP_NUM        = 16                              ,
    parameter DATA_BIT         = FRAME_DATA_BIT * GROUP_CHIP_NUM ,
    parameter SYSHZ            = 50_000_000                      ,
    parameter SCLHZ            = 1_875_000                       ,
    parameter READ_PORT_BYTES  = 16                              ,                
    parameter WRITE_PORT_BYTES = 4                               ,                
    parameter BEAM_BYTES       = GROUP_CHIP_NUM * GROUP_NUM * 16 ,
    parameter CMD_BIT          = 10                              ,
    parameter BEAM_NUM         = 1024
)
(
input  sys_clk       		,
input  reset       		    ,
input  prf_pin_in    		,
input  prf_start_in  		,
input  prf_mode_in   		,
output prf           		,//可选择 从io输入
input  ld_o					,
input  send_flag_in			,
input  single_lane			,
input  tr_mode				,
input  tr_en				,
output tr_o					,
output trt_o				,
output trr_o					
// output tr_in          //根据prf信号内部自己产生
    );

reg                        prf_gen      ;
//---------------------------生成prf信号----------------------------//
assign prf = prf_mode_in ? prf_pin_in : prf_gen;
reg prf_start;
localparam FREQ_MZ = 1000;
`ifndef TB_TEST
localparam CNT_NUM = SYSHZ / FREQ_MZ;
`else
localparam CNT_NUM = FREQ_MZ;
`endif
reg [$clog2(CNT_NUM)-1:0] cnt;
always@(posedge sys_clk)begin
	if(reset)	
		prf_start <= 0;
	else if(prf_start_in)
		prf_start <= 1;
end
always@(posedge sys_clk)begin
	if(reset)	
		cnt <= 0;
	else if(prf_start)begin
		if(cnt == CNT_NUM - 1)
			cnt <= 0;
		else 
			cnt <= cnt + 1;
	end
end

always@(posedge sys_clk)begin
	if(reset)	
		prf_gen <= 0;
	else if(prf_start)begin
		if(cnt == 0)
			prf_gen <= 1;
		else if(cnt == CNT_NUM/2-1)
			prf_gen <=0;
	end
end


//-----------------检测prf信号上升沿------------------//
reg [2:0] prf_r;//打两拍再检测上升沿
wire prf_pos;
always@(posedge sys_clk)begin
    if(reset)
        prf_r <= 0;
    else 
        prf_r <= {prf_r[1:0],prf};
end
assign prf_pos = ~prf_r[2] && prf_r[1];


//-----------------------------生成tr信号-----------------------
//----tr_other
wire tr_other;
wire [63:0] period0,cnt_tr_num0;
assign period0 = 900; 
// assign cnt_tr_num0 = (period0 * SYSHZ) / 1000_000;


wire [63:0] period1,cnt_tr_num1;
assign period1 = 100;
// assign cnt_tr_num1 = (period1 * SYSHZ) / 1000_000;
`ifdef SAR
	assign cnt_tr_num0 = 150_000;// 150_000 3ms ; 900 18us
`else
	assign cnt_tr_num0 = 900;// 150_000 3ms ; 900 18us
`endif
assign cnt_tr_num1 = 5000;

wire [31:0] cnt_tr_num;
assign cnt_tr_num = cnt_tr_num0 + cnt_tr_num1;

reg [31:0] cnt_tr;
always@(posedge sys_clk)begin
	if(reset)
		cnt_tr <= cnt_tr_num - 1;
	else if(prf_pos)
		cnt_tr <= 0;
	else if(cnt_tr == cnt_tr_num - 1)
		cnt_tr <= cnt_tr;
	else
		cnt_tr <= cnt_tr + 1;
end
assign tr_other = (cnt_tr >= cnt_tr_num0) && (cnt_tr < cnt_tr_num - 1) && send_flag_in;
// assign tr_other = (cnt_tr >= 200) && (cnt_tr < 700 - 1) && send_flag_in;
//----------tr_single----------//
wire tr_single;
reg single_flag_sync;
always@(posedge sys_clk)begin
    if(reset)
        single_flag_sync <= 0;
    else if(ld_o && single_lane)
        single_flag_sync <= 1;
    else if(ld_o && single_lane == 0)
        single_flag_sync <= 0;
end

assign tr_single   = send_flag_in && single_flag_sync;

reg data_valid;
always@(posedge sys_clk)begin
    if(reset)
        data_valid <= 0;
    else if(ld_o)
        data_valid <= 1;
end

// wire tr_o;
//单波位的单通道以及多波位都是脉冲 单波位单通道是长拉高
wire tr_o_local;
assign tr_o_local = data_valid && (single_lane ? tr_single : tr_other);
// assign tr_o = 1;

reg [2:0] tr_en_r;
wire tr_en_pos;
always@(posedge sys_clk)begin
    if(reset)
        tr_en_r <= 0;
    else
        tr_en_r <= {tr_en_r[1:0],tr_en};
end
assign tr_en_pos =  ~tr_en_r[2] && tr_en_r[1];

reg [31:0] cnt_close;
always@(posedge sys_clk)begin
    if(reset)
        cnt_close <= 5000;
    else if(tr_en_pos && (!single_lane))
        cnt_close <= 0;
    else if(cnt_close == 5000)
        cnt_close <= cnt_close;
    else
        cnt_close <= cnt_close + 1;
end

wire tr_input;
wire tr_max;
assign tr_max = (single_lane) ? 1 : (cnt_close <= 5000 - 1);
assign tr_o_input = tr_max && tr_en_r[1];

assign tr_o = tr_mode ? tr_o_input: tr_o_local;


localparam DWIDTH = 20;
reg [DWIDTH:0] CFGBC_OUTEN_r = 0;
always@(posedge sys_clk)begin
    if(reset)
        CFGBC_OUTEN_r <= 0;
    else
	    CFGBC_OUTEN_r <= {CFGBC_OUTEN_r[DWIDTH-1:0], tr_o};
end

assign trt_o = CFGBC_OUTEN_r[DWIDTH/2];
assign trr_o = |CFGBC_OUTEN_r;

endmodule
