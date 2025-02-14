`include "configure.vh"
`timescale 1ns / 1ps
//****注意cnt时间不对，应该是对应所有的chirp信号长度，而非fft长度
//可能需要流水线处理
//确认通道cnt对不对
module reco#(
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
input                   adc_clk         ,
input                   resetn          ,
input                   adc_valid       ,//添加到顶层
input                   k_b_valid       ,
input [31:0]            chirp_length    ,
input                   reco_trig       ,//

`ifdef TEST

output[255:0]           data_reco_single       ,
output                  data_reco_valid_single ,

`endif

//K、B
input [23:0]            k_data_now          ,
input [23:0]            b_data_now          ,
//ram
`ifndef TEST
input [WIDTH*2*8-1 : 0]   read_data_reco  ,
output                  read_en_reco    ,
output reg [13 : 0]     read_addr_reco  ,
`endif
//reco_data
output [WIDTH*2*8-1 : 0]  data_reco_out   ,
output                  data_reco_valid ,
output                  err_flag_reco   
    );



`ifndef TEST
wire [255:0]  data_reco_single   ;
wire          data_reco_valid_single ;
`endif
//生成技术条件
reg add_flag;
wire end_flag;
reg   [31:0] cnt;
always@(posedge adc_clk)begin
    if(!resetn)
        add_flag <= 0;
    else if(reco_trig)
        add_flag <= 1;
    else if(end_flag)
        add_flag <= 0;
end

always@(posedge adc_clk)begin
    if(~resetn)
        cnt <= 0;
    else if(add_flag)begin
        if(end_flag)
            cnt <= 0;
        else
            cnt <= cnt + 1;
    end
    else
        cnt <= 0;
end

assign end_flag = add_flag && cnt == (chirp_length >> 3) - 1;

// reg   [15:0] k_data = 16'sd389;
// reg   [15:0] b_data = 16'sd2538;

reg   [47:0] y1 [LANE_NUM-1:0];
wire  [23:0] y1_modulus [LANE_NUM-1:0];
reg   [24:0] y2 [LANE_NUM-1:0];

wire [15 : 0]   s_axis_phase_tdata [LANE_NUM-1:0];
wire            s_axis_phase_tvalid;
wire [31 : 0]   m_axis_dout_tdata [LANE_NUM-1:0];
wire            m_axis_dout_tvalid [LANE_NUM-1:0];



//因为插入了两个寄存器，所以需要打两拍再赋值到valid
reg [1:0] add_flag_r;

always@(posedge adc_clk)begin
  if(!resetn)begin
    add_flag_r[0] <=0;
    add_flag_r[1] <=0;
  end
  else begin
    add_flag_r[0] <=add_flag;
    add_flag_r[1] <=add_flag_r[0];
  end
  
end

assign s_axis_phase_tvalid = add_flag_r[1];

genvar kk;
generate
	for(kk = 0;kk < LANE_NUM;kk = kk + 1)begin:blk0
    //插入寄存器减小组合逻辑延时，但要增加两个时钟周期的延时
    always@(posedge adc_clk)begin
      if(!resetn)
        y1[kk] <= 0;
      else
        y1[kk] <= k_data_now * (((cnt << 3) + kk) << 21);
    end

		assign y1_modulus[kk] = {2'b00,y1[kk][42:21]};//取模

    always@(posedge adc_clk)begin
      if(!resetn)
        y2[kk] <= 0;
      else
        y2[kk] <= y1_modulus[kk] + b_data_now;//fix25_21
    end

		assign s_axis_phase_tdata[kk] = y2[kk][21] == 1 ? $signed({2'b0,y2[kk][21:8]}) - 16'sd16384 : $signed({2'b0,y2[kk][21:8]});//fix16_13

		cordic_sin u_cordic_sin (
		.aclk                 (adc_clk                  ),                                       // input wire aclk
		.aresetn              (resetn                   ),                                     // input wire aresetn
		.s_axis_phase_tvalid  (s_axis_phase_tvalid      ),      // input wire s_axis_phase_tvalid
		.s_axis_phase_tdata   (s_axis_phase_tdata[kk]   ),      // input wire [15 : 0] s_axis_phase_tdata
		.m_axis_dout_tvalid   (m_axis_dout_tvalid[kk]   ),      // output wire m_axis_dout_tvalid
		.m_axis_dout_tdata    (m_axis_dout_tdata[kk]    )       // output wire [31 : 0] m_axis_dout_tdata
		);
	end

endgenerate

assign data_reco_single = {m_axis_dout_tdata[7],m_axis_dout_tdata[6],m_axis_dout_tdata[5],m_axis_dout_tdata[4],m_axis_dout_tdata[3],m_axis_dout_tdata[2],m_axis_dout_tdata[1],m_axis_dout_tdata[0]};
assign data_reco_valid_single = m_axis_dout_tvalid[0];

//复数相乘

//ram
//----------------------取数据---------------------------//
`ifndef TEST
assign read_en_reco = data_reco_valid_single          ;
always@(posedge adc_clk)begin
  if(!resetn)
    read_addr_reco <= 0;
  else if(read_en_reco)
    read_addr_reco <= read_addr_reco + 1;
  else
     read_addr_reco <= 0;
end
`endif

//数据打拍对齐
reg [WIDTH*2*8-1:0] data_reco_single_r;
reg data_reco_valid_single_r;
always@(posedge adc_clk)begin
  if(!resetn)begin
    data_reco_single_r  <= 0;
    data_reco_valid_single_r <= 0;
  end
  else begin
    data_reco_single_r  <= data_reco_single;
    data_reco_valid_single_r <= data_reco_valid_single;
  end
end
//\\\\\\\\\\\\\\\\\\\\\\\\\
`ifdef TEST
//读chirp
  reg [255:0] data_in [1791:0];

  initial begin
    $readmemh("D:/code/complete/program_data/chirp_data.txt",data_in);
  end

  wire [WIDTH*8*2-1 : 0]             read_data_reco  ;
  wire                             read_en_reco    ;
  reg  [13 : 0]                     read_addr_reco  ;

assign read_en_reco = data_reco_valid_single;

  always @(posedge adc_clk) begin
    if(!resetn)
        read_addr_reco <= 0;
    else if(read_en_reco)
      read_addr_reco <= read_addr_reco + 1;
    else
      read_addr_reco <= 0;
  end


  assign read_data_reco = data_in[read_addr_reco];
  `endif

wire                  s_axis_a_tvalid         ;
wire [31 : 0]         s_axis_a_tdata          ;
wire                  s_axis_b_tvalid         ;
wire [31 : 0]         s_axis_b_tdata          ;
wire [LANE_NUM - 1:0] m_axis_cmpy_dout_tvalid ;
wire [LANE_NUM - 1:0] m_axis_cmpy_dout_tlast  ;
wire [31:0]           m_axis_cmpy_dout_tdata [LANE_NUM - 1 : 0] ;
wire [LANE_NUM - 1:0] err_flag;

assign s_axis_a_tvalid = data_reco_valid_single_r;
assign s_axis_b_tvalid = data_reco_valid_single_r;
assign s_axis_a_tdata  = data_reco_single_r;
assign s_axis_b_tdata  = read_data_reco;

assign data_reco_out   = {m_axis_cmpy_dout_tdata[7],m_axis_cmpy_dout_tdata[6],m_axis_cmpy_dout_tdata[5],m_axis_cmpy_dout_tdata[4],
                          m_axis_cmpy_dout_tdata[3],m_axis_cmpy_dout_tdata[2],m_axis_cmpy_dout_tdata[1],m_axis_cmpy_dout_tdata[0]};
assign data_reco_valid = m_axis_cmpy_dout_tvalid[0];

genvar jj;
generate
  for(jj = 0;jj < LANE_NUM;jj = jj + 1)begin:blk1
    complex_multi u_complex_multi(
    .  aclk                    (adc_clk                               ) ,
    .  aresetn                 (resetn                                ) ,
    .  s_axis_a_tvalid         (s_axis_a_tvalid                       ) ,
    .  s_axis_a_tlast          (s_axis_a_tlast                        ) ,    
    .  s_axis_a_tdata          (data_reco_single_r[(jj+1)*32-1:jj*32] ) ,             
    .  s_axis_b_tvalid         (s_axis_b_tvalid                       ) ,
    .  s_axis_b_tlast          (s_axis_b_tlast                        ) ,
    .  s_axis_b_tdata          (read_data_reco[(jj+1)*32-1:jj*32]     ) ,
    .  m_axis_cmpy_dout_tvalid (m_axis_cmpy_dout_tvalid[jj]           ) ,
    .  m_axis_cmpy_dout_tlast  (m_axis_cmpy_dout_tlast[jj]            ) ,
    .  m_axis_cmpy_dout_tdata  (m_axis_cmpy_dout_tdata[jj]            ) ,
    .  err_flag                (err_flag[jj]                          ) 
        );
  end
endgenerate
`ifdef DISTURB_DEBUG
// ila_reco u_ila_reco (
// 	.clk    (adc_clk                  ) ,
// 	.probe0 (data_reco_valid          ) ,//1
// 	.probe1 (data_reco_out            ) ,//256
// 	.probe2 (data_reco_valid_single   ) ,//1
// 	.probe3 (data_reco_single         ) ,//256
// 	.probe4 (read_en_reco             ) ,//1
// 	.probe5 (read_addr_reco           ) ,//14
// 	.probe6 (read_data_reco           )  //256
// );
`endif

assign err_flag_reco = |err_flag;

`ifdef TEST
  //fd_reco_single
  integer fd_reco_single;
  initial begin
    fd_reco_single = $fopen("D:/code/complete/program_data/out_data/reco_single.txt","w");
    forever begin
      @(posedge adc_clk)begin
        if(data_reco_valid_single)begin
            $fwrite(fd_reco_single,"%d %d\n",$signed(data_reco_single[WIDTH*2-1:WIDTH]),$signed(data_reco_single[WIDTH-1:0]));
            $fwrite(fd_reco_single,"%d %d\n",$signed(data_reco_single[(WIDTH*2*2)-1:WIDTH+WIDTH*2*1]),$signed(data_reco_single[WIDTH-1+WIDTH*2*1:WIDTH*2*1]));
            $fwrite(fd_reco_single,"%d %d\n",$signed(data_reco_single[(WIDTH*2*3)-1:WIDTH+WIDTH*2*2]),$signed(data_reco_single[WIDTH-1+WIDTH*2*2:WIDTH*2*2]));
            $fwrite(fd_reco_single,"%d %d\n",$signed(data_reco_single[(WIDTH*2*4)-1:WIDTH+WIDTH*2*3]),$signed(data_reco_single[WIDTH-1+WIDTH*2*3:WIDTH*2*3]));
            $fwrite(fd_reco_single,"%d %d\n",$signed(data_reco_single[(WIDTH*2*5)-1:WIDTH+WIDTH*2*4]),$signed(data_reco_single[WIDTH-1+WIDTH*2*4:WIDTH*2*4]));
            $fwrite(fd_reco_single,"%d %d\n",$signed(data_reco_single[(WIDTH*2*6)-1:WIDTH+WIDTH*2*5]),$signed(data_reco_single[WIDTH-1+WIDTH*2*5:WIDTH*2*5]));
            $fwrite(fd_reco_single,"%d %d\n",$signed(data_reco_single[(WIDTH*2*7)-1:WIDTH+WIDTH*2*6]),$signed(data_reco_single[WIDTH-1+WIDTH*2*6:WIDTH*2*6]));
            $fwrite(fd_reco_single,"%d %d\n",$signed(data_reco_single[(WIDTH*2*8)-1:WIDTH+WIDTH*2*7]),$signed(data_reco_single[WIDTH-1+WIDTH*2*7:WIDTH*2*7]));
        end
    end
  end
  end


  //fd_reco
  integer fd_reco;
  initial begin
    fd_reco = $fopen("D:/code/complete/program_data/out_data/reco.txt","w");
    forever begin
      @(posedge adc_clk)begin
        if(data_reco_valid)begin
            $fwrite(fd_reco,"%d %d\n",$signed(data_reco_out[WIDTH*2-1:WIDTH]),$signed(data_reco_out[WIDTH-1:0]));
            $fwrite(fd_reco,"%d %d\n",$signed(data_reco_out[(WIDTH*2*2)-1:WIDTH+WIDTH*2*1]),$signed(data_reco_out[WIDTH-1+WIDTH*2*1:WIDTH*2*1]));
            $fwrite(fd_reco,"%d %d\n",$signed(data_reco_out[(WIDTH*2*3)-1:WIDTH+WIDTH*2*2]),$signed(data_reco_out[WIDTH-1+WIDTH*2*2:WIDTH*2*2]));
            $fwrite(fd_reco,"%d %d\n",$signed(data_reco_out[(WIDTH*2*4)-1:WIDTH+WIDTH*2*3]),$signed(data_reco_out[WIDTH-1+WIDTH*2*3:WIDTH*2*3]));
            $fwrite(fd_reco,"%d %d\n",$signed(data_reco_out[(WIDTH*2*5)-1:WIDTH+WIDTH*2*4]),$signed(data_reco_out[WIDTH-1+WIDTH*2*4:WIDTH*2*4]));
            $fwrite(fd_reco,"%d %d\n",$signed(data_reco_out[(WIDTH*2*6)-1:WIDTH+WIDTH*2*5]),$signed(data_reco_out[WIDTH-1+WIDTH*2*5:WIDTH*2*5]));
            $fwrite(fd_reco,"%d %d\n",$signed(data_reco_out[(WIDTH*2*7)-1:WIDTH+WIDTH*2*6]),$signed(data_reco_out[WIDTH-1+WIDTH*2*6:WIDTH*2*6]));
            $fwrite(fd_reco,"%d %d\n",$signed(data_reco_out[(WIDTH*2*8)-1:WIDTH+WIDTH*2*7]),$signed(data_reco_out[WIDTH-1+WIDTH*2*7:WIDTH*2*7]));
        end
    end
  end
  end
`endif

endmodule
