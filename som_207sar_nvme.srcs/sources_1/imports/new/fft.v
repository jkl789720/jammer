`include "configure.vh"
`timescale 1ns / 1ps
module fft#(
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
)
(    
//
input                             adc_clk                   ,
input                             resetn                    ,
//adc
input [WIDTH*2*8-1:0]             adc_data                  ,//需要拼接而来
input                             adc_valid                 ,
input [31:0]                      proc_length               ,
input                             change_eq                 ,
//ram
`ifndef TEST
(* dont_touch="true" *) input [WIDTH*2*8-1 : 0]           read_data_fft             ,
output                            read_en_fft               ,
output [11 : 0]                   read_addr_fft             ,
`endif
output reg                        fft_valid_latch           ,
output reg [12:0]                 fft_index_max_latch       ,

output reg  [WIDTH*4-1:0]         fft_value_max_latch       ,
output reg  [WIDTH*4-1:0]         fft_value_left_latch      ,
output reg  [WIDTH*4-1:0]         fft_value_right_latch     ,
output                            fifo_overflow             ,
output                            fifo_underflow            ,
input       [255:0]               dac_data_o                ,
input                             dac_valid_o               ,
output      [255:0]               com_multi_data            ,
output                            com_multi_valid           
`ifdef TEST
,
output                            comp_multi_valid_test     ,
output      [255:0]               comp_multi_data_test 
`endif
    );

localparam DEALY_CYCLE = 19;
`ifdef TEST
  reg [255:0] data_in [1791:0];

  initial begin
    $readmemh("D:/code/complete/program_data/chirp_data_fft.txt",data_in);
  end

  wire [WIDTH*2*8-1 : 0]    read_data_fft  ;
  reg                       read_en_fft    ;
  reg  [11 : 0]             read_addr_fft  ;

  always @(posedge adc_clk) begin
    read_en_fft <= adc_valid;
  end

  always @(posedge adc_clk) begin
    if(!resetn)
        read_addr_fft <= 0;
    else if(read_en_fft)
      read_addr_fft <= read_addr_fft + 1;
    else
      read_addr_fft <= 0;
  end


  assign read_data_fft = data_in[read_addr_fft];
`endif

//complex_multiplier

wire                        s_axis_a_tlast                    ;
wire                        s_axis_b_tlast                    ;

wire                        m_axis_multi_dout_tvalid          ;
wire                        m_axis_multi_dout_tlast           ;

//fft
wire [WIDTH*4-1 : 0]        s_axis_fft_data_tdata             ;
wire [WIDTH*4-1 : 0]        m_axis_fft_data_tdata             ;
reg  [WIDTH*4-1:0]          fft_value_max                     ;
reg  [WIDTH*4-1:0]          fft_value_left                    ;
reg  [WIDTH*4-1:0]          fft_value_right                   ;
wire                        s_axis_fft_data_tvalid            ;
wire                        s_axis_fft_data_tready            ;
wire                        s_axis_fft_data_tlast             ;

wire                        s_axis_config_tready              ;
wire [23 : 0]               s_axis_config_tdata               ;
wire                        s_axis_config_tvalid              ; 

wire [15 : 0]               m_axis_fft_data_tuser             ;
wire                        m_axis_fft_data_tvalid            ;
wire                        m_axis_fft_data_tlast             ;
wire [12:0]                 index                             ;



assign index    = m_axis_fft_data_tuser[12:0];

//ram
reg  [13 : 0]           read_addr_offset    ;
wire [WIDTH*2*8-1 : 0]    read_data_conjugate ;


//----------------------取数据---------------------------//
// localparam BASE_ADDR = 5737;
`ifndef TEST
assign read_en_fft = adc_valid          ;

always@(posedge adc_clk)begin
  if(!resetn)
    read_addr_offset <= 0;
  else if(read_en_fft)begin
    if(read_addr_offset == (proc_length >> 3) - 1)
      read_addr_offset <= 0;
    else
      read_addr_offset <= read_addr_offset + 1;
  end
  else
     read_addr_offset <= 0;
end

assign read_addr_fft = read_addr_offset;
`endif
//fifo

wire fifo_wr_en     ;
wire full           ;
wire empty          ;
wire fifo_valid     ;

wire [WIDTH*2*8-1:0]  fifo_din;
wire [WIDTH*2-1:0]    fifo_dout;
wire                  fifo_rd_en;



reg [WIDTH*2*8-1:0] adc_data_r;
reg         adc_valid_r;
//----------------------------共轭-----------------------------//
genvar kk;
generate
  for(kk = 0;kk < 8;kk = kk + 1)begin:blk
    assign read_data_conjugate[WIDTH*2*(kk+1)-1:WIDTH*2*kk] = {(~read_data_fft[WIDTH*2*(kk+1)-1:WIDTH*2*kk+WIDTH])+1,read_data_fft[WIDTH*2*kk+WIDTH-1:WIDTH*2*kk]}; 
  end
endgenerate

//打拍对齐
always@(posedge adc_clk)begin
  if(!resetn)begin
    adc_data_r  <= 0;
    adc_valid_r <= 0;
  end
  else begin
    adc_data_r  <= adc_data;
    adc_valid_r <= adc_valid;
  end
end

reg [31:0] cnt;
always@(posedge adc_clk)begin
  if(!resetn)
    cnt <= 0;
  else if(adc_valid_r)begin
    if(cnt == (proc_length >> 3) - 1)
      cnt <= 0;
    else
      cnt <= cnt + 1;
  end
end

assign s_axis_a_tlast = adc_valid_r & cnt == (proc_length >> 3) - 1;
assign s_axis_b_tlast = adc_valid_r & cnt == (proc_length >> 3) - 1;
//-----------------------------做复数乘法-----------------------------//
wire [31:0] m_axis_multi_dout_tdata_buf[7:0];///需要改
wire m_axis_multi_dout_tlast_buf[7:0];
wire m_axis_multi_dout_tvalid_buf[7:0];
wire err_flag[7:0];
wire s_axis_multi_tvalid;
assign s_axis_multi_tvalid = adc_valid_r;
assign m_axis_multi_dout_tvalid = m_axis_multi_dout_tvalid_buf[0];
genvar ii;
generate
  for(ii = 0;ii < 8;ii = ii + 1)begin:blk1
    complex_multi u_complex_multi(
      .aclk                    (adc_clk                                           ),
      .aresetn                 (resetn                                            ),
      .s_axis_a_tvalid         (s_axis_multi_tvalid                               ),
      .s_axis_a_tlast          (s_axis_a_tlast                                    ),
      .s_axis_a_tdata          (adc_data_r[(ii+1)*WIDTH*2-1:ii*WIDTH*2]           ),
      .s_axis_b_tvalid         (s_axis_multi_tvalid                               ),
      .s_axis_b_tlast          (s_axis_b_tlast                                    ),
      .s_axis_b_tdata          (read_data_conjugate[(ii+1)*WIDTH*2-1:ii*WIDTH*2]  ),
      .m_axis_cmpy_dout_tvalid (m_axis_multi_dout_tvalid_buf[ii]                  ),
      .m_axis_cmpy_dout_tlast  (m_axis_multi_dout_tlast_buf[ii]                   ),
      .m_axis_cmpy_dout_tdata  (m_axis_multi_dout_tdata_buf[ii]                   ), 
      .err_flag                (err_flag[ii]                                      ) 
    );
  end
endgenerate

`ifdef TEST

assign comp_multi_valid_test = m_axis_multi_dout_tvalid_buf[0];
assign comp_multi_data_test  = {m_axis_multi_dout_tdata_buf[7],m_axis_multi_dout_tdata_buf[6],m_axis_multi_dout_tdata_buf[5],
                  m_axis_multi_dout_tdata_buf[4],m_axis_multi_dout_tdata_buf[3],m_axis_multi_dout_tdata_buf[2],m_axis_multi_dout_tdata_buf[1],m_axis_multi_dout_tdata_buf[0]};
`endif
//----------------------------fifo做位宽转换------------------------------------//

  wire [WIDTH-1:0] multi_out_high [7:0];
  wire [WIDTH-1:0] multi_out_low [7:0];

assign fifo_wr_en = m_axis_multi_dout_tvalid;
//0:64 72:136
///需要改
genvar jj;
generate
  for(jj = 0; jj < 8;jj = jj + 1)begin:blk2
    assign multi_out_high[jj] = m_axis_multi_dout_tdata_buf[jj][31:16];
    assign multi_out_low[jj]  = m_axis_multi_dout_tdata_buf[jj][15:0];
    assign fifo_din[(jj+1)*WIDTH*2-1:jj*WIDTH*2] =  {multi_out_high[7-jj],multi_out_low[7-jj]};
  end
endgenerate

fifo_fft u_fifo_fft (
  .clk          (adc_clk                  ), 
  .srst         (~resetn                  ), 
  .din          (fifo_din                 ), 
  .wr_en        (fifo_wr_en               ), 
  .rd_en        (fifo_rd_en               ), 
  .dout         (fifo_dout                ), 
  .full         (full                     ), 
  .overflow     (fifo_overflow            ), 
  .empty        (empty                    ), 
  .valid        (fifo_valid               ), 
  .underflow    (fifo_underflow           )
);

assign fifo_rd_en = fifo_valid && s_axis_fft_data_tready;
wire [15 : 0] s_axis_fixed2float_tdata_q ;
wire [15 : 0] s_axis_fixed2float_tdata_i ;
wire          s_axis_fixed2float_tvalid  ;
wire          m_axis_fixed2float_tvalid_q;
wire          m_axis_fixed2float_tvalid_i;
wire [31:0]   m_axis_fixed2float_tdata_q ;
wire [31:0]   m_axis_fixed2float_tdata_i ;

assign s_axis_fixed2float_tdata_q = fifo_dout[31:16];
assign s_axis_fixed2float_tdata_i = fifo_dout[15:0];
assign s_axis_fixed2float_tvalid  = fifo_rd_en;//只能是读使能


fixed2float u_fixed2float_q (
  .aclk                (adc_clk                         ),
  .aresetn             (resetn                          ),
  .s_axis_a_tvalid     (s_axis_fixed2float_tvalid       ),
  .s_axis_a_tdata      (s_axis_fixed2float_tdata_q      ),
  .m_axis_result_tvalid(m_axis_fixed2float_tvalid_q     ),
  .m_axis_result_tdata (m_axis_fixed2float_tdata_q      ) 
);

fixed2float u_fixed2float_i (
  .aclk                (adc_clk                         ),
  .aresetn             (resetn                          ),
  .s_axis_a_tvalid     (s_axis_fixed2float_tvalid       ),
  .s_axis_a_tdata      (s_axis_fixed2float_tdata_i      ),
  .m_axis_result_tvalid(m_axis_fixed2float_tvalid_i     ),
  .m_axis_result_tdata (m_axis_fixed2float_tdata_i      ) 
);

wire [63 : 0] fifo_buff_din             ;
wire          fifo_buff_wr_en           ;
wire          fifo_buff_rd_en           ;
wire [63 : 0] fifo_buff_dout            ;
wire          fifo_buff_full            ;
wire          fifo_buff_overflow        ;
wire          fifo_buff_empty           ;
wire          fifo_buff_valid           ;
wire          fifo_buff_underflow       ;
wire          fifo_buff_wr_rst_busy     ;
wire          fifo_buff_rd_rst_busy     ;

assign fifo_buff_wr_en = m_axis_fixed2float_tvalid_q;
assign fifo_buff_din   = {m_axis_fixed2float_tdata_q,m_axis_fixed2float_tdata_i};

fifo_buff u_fifo_buff (
  .clk                (adc_clk              ),
  .srst               (~resetn              ),
  .din                (fifo_buff_din        ),
  .wr_en              (fifo_buff_wr_en      ),
  .rd_en              (fifo_buff_rd_en      ),
  .dout               (fifo_buff_dout       ),
  .full               (fifo_buff_full       ),
  .overflow           (fifo_buff_overflow   ),
  .empty              (fifo_buff_empty      ),
  .valid              (fifo_buff_valid      ),
  .underflow          (fifo_buff_underflow  ),
  .wr_rst_busy        (fifo_buff_wr_rst_busy),
  .rd_rst_busy        (fifo_buff_rd_rst_busy) 
);

reg [31:0] cnt_fft_num;
always@(posedge adc_clk)begin
  if(!resetn)
    cnt_fft_num <= 0;
  else if(s_axis_fft_data_tvalid && s_axis_fft_data_tready)begin
    if(cnt_fft_num == (proc_length << 1) - 1)
      cnt_fft_num <= 0;
    else 
      cnt_fft_num <= cnt_fft_num + 1;
  end
end

reg [31:0] cnt_delay;
always@(posedge adc_clk)begin
  if(!resetn)
    cnt_delay <= 50;
  else if(s_axis_fft_data_tlast)
    cnt_delay <= 0;
  else if(cnt_delay == 50)
    cnt_delay <= 50;
  else 
    cnt_delay <= cnt_delay  +  1;
end

assign s_axis_fft_data_tvalid = cnt_fft_num < (proc_length ) ? (fifo_buff_valid && cnt_delay == 50) : 1;//有点冗余，后面可以更改
assign fifo_buff_rd_en = (s_axis_fft_data_tvalid && s_axis_fft_data_tready) && cnt_fft_num < (proc_length );
assign s_axis_fft_data_tdata  =  cnt_fft_num < (proc_length ) ? fifo_buff_dout : 0;
// assign s_axis_fft_data_tdata  =  cnt_fft_num < (proc_length ) ? ({$signed(fifo_dout[31:16]) >>> 3,$signed(fifo_dout[15:0]) >>> 3}) : 0;
assign s_axis_fft_data_tlast =  (s_axis_fft_data_tvalid && s_axis_fft_data_tready) && cnt_fft_num == (proc_length << 1) - 1;

fft_config u_fft_config(
    . adc_clk              (adc_clk             )  ,
    . resetn               (resetn              )  ,
    . change_eq            (change_eq           )  ,//添加到顶层
    . proc_length          (proc_length         )  ,
    . s_axis_config_tready (s_axis_config_tready)  ,
    . s_axis_config_tdata  (s_axis_config_tdata )  ,
    . s_axis_config_tvalid (s_axis_config_tvalid)  
    );



xfft_0 u_xfft_0 (   
  .aclk                         (adc_clk                     ),
  .aresetn                      (resetn                      ),
  .s_axis_config_tdata          (s_axis_config_tdata         ),
  .s_axis_config_tvalid         (s_axis_config_tvalid        ),
  .s_axis_config_tready         (s_axis_config_tready        ),
  .s_axis_data_tdata            (s_axis_fft_data_tdata       ),
  .s_axis_data_tvalid           (s_axis_fft_data_tvalid      ),
  .s_axis_data_tready           (s_axis_fft_data_tready      ),
  .s_axis_data_tlast            (s_axis_fft_data_tlast       ),

  .m_axis_data_tdata            (m_axis_fft_data_tdata       ),
  .m_axis_data_tuser            (m_axis_fft_data_tuser       ),
  .m_axis_data_tvalid           (m_axis_fft_data_tvalid      ),
  .m_axis_data_tlast            (m_axis_fft_data_tlast       ),

  .event_frame_started          (event_frame_started         ),
  .event_tlast_unexpected       (event_tlast_unexpected      ),
  .event_tlast_missing          (event_tlast_missing         ),
  .event_data_in_channel_halt   (event_data_in_channel_halt  ) 
);

wire            s_axis_cmy_q_tvalid  ;                         
wire [31 : 0]   s_axis_cmy_q_tdata   ;   

wire            s_axis_cmy_i_tvalid  ;                  
wire [31 : 0]   s_axis_cmy_i_tdata   ;                      
            
wire            m_axis_cmy_q_tvalid  ;  
wire [31 : 0]   m_axis_cmy_q_tdata   ;     
wire            m_axis_cmy_i_tvalid  ;                           
wire [31 : 0]   m_axis_cmy_i_tdata   ; 

assign s_axis_cmy_q_tdata  = m_axis_fft_data_tdata[63:32];
assign s_axis_cmy_q_tvalid = m_axis_fft_data_tvalid;
assign s_axis_cmy_i_tdata  = m_axis_fft_data_tdata[31:0];
assign s_axis_cmy_i_tvalid = m_axis_fft_data_tvalid;

floating_point_cmy u_floating_point_cmy_q (
  .aclk                   (adc_clk                 ),                               // input wire aclk
  .aresetn                (resetn                  ),                             // input wire aresetn
  .s_axis_a_tvalid        (s_axis_cmy_q_tvalid     ),            // input wire s_axis_a_tvalid
  .s_axis_a_tdata         (s_axis_cmy_q_tdata      ),              // input wire [31 : 0] s_axis_a_tdata
  .s_axis_b_tvalid        (s_axis_cmy_q_tvalid     ),            // input wire s_axis_b_tvalid
  .s_axis_b_tdata         (s_axis_cmy_q_tdata      ),              // input wire [31 : 0] s_axis_b_tdata
  .m_axis_result_tvalid   (m_axis_cmy_q_tvalid     ),  // output wire m_axis_result_tvalid
  .m_axis_result_tdata    (m_axis_cmy_q_tdata      )     // output wire [31 : 0] m_axis_result_tdata
);

floating_point_cmy u_floating_point_cmy_i (
  .aclk                   (adc_clk                 ),                               // input wire aclk
  .aresetn                (resetn                  ),                             // input wire aresetn
  .s_axis_a_tvalid        (s_axis_cmy_i_tvalid     ),            // input wire s_axis_a_tvalid
  .s_axis_a_tdata         (s_axis_cmy_i_tdata      ),              // input wire [31 : 0] s_axis_a_tdata
  .s_axis_b_tvalid        (s_axis_cmy_i_tvalid     ),            // input wire s_axis_b_tvalid
  .s_axis_b_tdata         (s_axis_cmy_i_tdata      ),              // input wire [31 : 0] s_axis_b_tdata
  .m_axis_result_tvalid   (m_axis_cmy_i_tvalid     ),  // output wire m_axis_result_tvalid
  .m_axis_result_tdata    (m_axis_cmy_i_tdata      )     // output wire [31 : 0] m_axis_result_tdata
);

wire            aclk                      ;
wire            aresetn                   ;
wire            s_axis_add_a_tvalid       ;
wire [31 : 0]   s_axis_add_a_tdata        ;
wire            s_axis_add_b_tvalid       ;
wire [31 : 0]   s_axis_add_b_tdata        ;
wire            m_axis_add_tvalid         ;
wire [31 : 0]   m_axis_add_tdata          ;

assign s_axis_add_a_tvalid = m_axis_cmy_q_tvalid  ;
assign s_axis_add_a_tdata  = m_axis_cmy_q_tdata   ;
assign s_axis_add_b_tvalid = m_axis_cmy_i_tvalid  ;
assign s_axis_add_b_tdata  = m_axis_cmy_i_tdata   ;

floating_point_add u_floating_point_add (
  .aclk                  (adc_clk                 ),                                  // input  wire aclk
  .aresetn               (resetn                  ),                            // input  wire aresetn
  .s_axis_a_tvalid       (s_axis_add_a_tvalid     ),            // input  wire s_axis_a_tvalid
  .s_axis_a_tdata        (s_axis_add_a_tdata      ),              // input  wire [31 : 0] s_axis_a_tdata
  .s_axis_b_tvalid       (s_axis_add_b_tvalid     ),            // input  wire s_axis_b_tvalid
  .s_axis_b_tdata        (s_axis_add_b_tdata      ),              // input  wire [31 : 0] s_axis_b_tdata
  .m_axis_result_tvalid  (m_axis_add_tvalid       ),  // output wire m_axis_result_tvalid
  .m_axis_result_tdata   (m_axis_add_tdata        )    // output  wire [31 : 0] m_axis_result_tdata
);

wire            s_axis_compare_a_tvalid   ;
wire [31 : 0]   s_axis_compare_a_tdata    ;
wire            s_axis_compare_a_tlast    ;//关注点***
wire            s_axis_compare_b_tvalid   ;
wire [31 : 0]   s_axis_compare_b_tdata    ;
wire            m_axis_compare_tvalid     ;
wire [7 : 0]    m_axis_compare_tdata      ;
wire            m_axis_compare_tlast      ;

reg [31:0] modulus_max_data;
reg [12:0] fft_index_max;
wire fft_valid_pre;

assign s_axis_compare_a_tvalid = m_axis_add_tvalid ;
assign s_axis_compare_a_tdata  = m_axis_add_tdata  ;
assign s_axis_compare_b_tvalid = m_axis_add_tvalid ; 
assign s_axis_compare_b_tdata  = modulus_max_data  ;

floating_point_compare u_floating_point_compare (                               // input  wire aclk
  .s_axis_a_tvalid      (s_axis_compare_a_tvalid),            // input  wire s_axis_a_tvalid
  .s_axis_a_tdata       (s_axis_compare_a_tdata ),              // input  wire [31 : 0] s_axis_a_tdata
  .s_axis_a_tlast       (s_axis_compare_a_tlast ),              // input  wire s_axis_a_tlast
  .s_axis_b_tvalid      (s_axis_compare_b_tvalid),            // input  wire s_axis_b_tvalid
  .s_axis_b_tdata       (s_axis_compare_b_tdata ),              // input  wire [31 : 0] s_axis_b_tdata
  .m_axis_result_tvalid (m_axis_compare_tvalid  ),  // output wire m_axis_result_tvalid
  .m_axis_result_tdata  (m_axis_compare_tdata   ),    // output wire [7 : 0] m_axis_result_tdata
  .m_axis_result_tlast  (m_axis_compare_tlast   )    // output  wire m_axis_result_tlast
);


//产生索引和fft数据的valid信号
reg [DEALY_CYCLE + 1:0] m_axis_fft_data_tlast_r;//这是正确的 19判断最大索引 20 latch目标索引 21 输出latch后的索引以及valid标志 
always@(posedge adc_clk)begin
    m_axis_fft_data_tlast_r <= {m_axis_fft_data_tlast_r[DEALY_CYCLE: 0],m_axis_fft_data_tlast};
end

//打拍获取相邻数据
wire [WIDTH*4-1:0] fft_data_delay_right;
reg  [WIDTH*4-1:0] fft_data_delay_max,fft_data_delay_left;//2 1 0
wire [5:0] delay_value;
assign delay_value = DEALY_CYCLE - 2;//delay_value + 1是拍数 r0是打1拍,r30是31拍

shift_ram_fft_data u_shift_ram_fft_data (
  .A    (delay_value            ),
  .D    (m_axis_fft_data_tdata  ),
  .CLK  (adc_clk                ),
  .Q    (fft_data_delay_right   ) 
);

always@(posedge adc_clk)begin
  if(!resetn)begin
    fft_data_delay_max <= 0;
    fft_data_delay_left <= 0;
  end
  else begin
    fft_data_delay_max <= fft_data_delay_right;
    fft_data_delay_left <= fft_data_delay_max;
  end
end

//寄存第一个和最后一个数据
reg [WIDTH*4-1:0] fft_first,fft_last;
always@(posedge adc_clk)begin
  if(!resetn)begin
    fft_first <= 0;
    fft_last  <= 0;
  end
  else if(index == 0 & m_axis_fft_data_tvalid)
    fft_first <= m_axis_fft_data_tdata;
  else if(index == (proc_length << 1) - 1 & m_axis_fft_data_tvalid)
    fft_last <= m_axis_fft_data_tdata;
end

wire [12:0] index_r;
wire [4 : 0] shift_value_index;

assign shift_value_index = DEALY_CYCLE - 1;
shift_ram_index u_shift_ram_index (
  .A    (shift_value_index  ),  
  .D    (index              ),  
  .CLK  (adc_clk            ),  
  .Q    (index_r            )   
);

//找出最大索引以及对应fft的值
always@(posedge adc_clk)begin
    if(!resetn)begin
        modulus_max_data  <= 0;

        fft_value_max     <= 0;
        fft_value_left    <= 0;
        fft_value_right   <= 0;

        fft_index_max     <= 0;
    end
    else if(m_axis_compare_tvalid)begin
        modulus_max_data  <= m_axis_compare_tdata[0] ? s_axis_compare_a_tdata : modulus_max_data;
        fft_value_left    <= m_axis_compare_tdata[0] ? fft_data_delay_left : fft_value_left;
        fft_value_max     <= m_axis_compare_tdata[0] ? fft_data_delay_max   : fft_value_max;    
        fft_value_right   <= m_axis_compare_tdata[0] ? fft_data_delay_right  : fft_value_right;
        fft_index_max     <= m_axis_compare_tdata[0] ? index_r : fft_index_max;
    end
    else if(fft_valid_pre)begin
        modulus_max_data     <= 0;
    end
end


reg [31:0] cnt_modulus;
always@(posedge adc_clk)begin
  if(!resetn)
    cnt_modulus <= 0;
  else if(m_axis_compare_tvalid)
    cnt_modulus <= cnt_modulus + 1;
  else
    cnt_modulus <= 0;
end

assign fft_valid_pre = cnt_modulus == (proc_length << 1);

//latch最大值并且处理(abs_left和abs_right溢出处理)
always@(posedge adc_clk) begin
  if(!resetn)begin
    fft_index_max_latch <= 0;
    fft_value_max_latch   <= 0;
    fft_value_left_latch  <= 0;  
    fft_value_right_latch <= 0;  
  end
  else if(m_axis_fft_data_tlast_r[DEALY_CYCLE])begin
    fft_index_max_latch   <= fft_index_max;
    fft_value_max_latch   <= fft_value_max;
    fft_value_left_latch  <= fft_index_max == 0 ? fft_last: fft_value_left;  
    fft_value_right_latch <= fft_index_max == (proc_length << 1) - 1 ? fft_first : fft_value_right;  

  end
end

//索引有效信号
always@(posedge adc_clk)begin
  if(!resetn)
    fft_valid_latch <= 0;
  else
    fft_valid_latch <= fft_valid_pre;
end 


//仿真调试用
assign com_multi_data = {m_axis_multi_dout_tdata_buf[7],m_axis_multi_dout_tdata_buf[6],m_axis_multi_dout_tdata_buf[5],m_axis_multi_dout_tdata_buf[4],m_axis_multi_dout_tdata_buf[3],
m_axis_multi_dout_tdata_buf[2],m_axis_multi_dout_tdata_buf[1],m_axis_multi_dout_tdata_buf[0]};
assign com_multi_valid = m_axis_multi_dout_tvalid;

`ifdef DISTURB_DEBUG

ila_fft u_ila_fft(
  .clk      (adc_clk                              ),
	.probe0   (adc_valid_r                          ),  //1
	.probe1   (adc_data_r                           ),  //256
	.probe2   (read_en_fft                          ),  //1
	.probe3   (read_data_fft                        ),  //256
	.probe4   (m_axis_fft_data_tvalid               ),  //1
	.probe5   (m_axis_fft_data_tdata                ),  //64
	.probe6   (fft_valid_latch                      ),  //1
	.probe7   (fft_value_left_latch                 ),  //64
	.probe8   (fft_value_max_latch                  ),  //64
	.probe9   (fft_value_right_latch                ),  //64
	.probe10  (fifo_overflow                        ),  //1
	.probe11  (fifo_underflow                       ),  //1
	.probe12  (s_axis_fft_data_tvalid               ),  //1
	.probe13  (s_axis_fft_data_tdata                )   //64
);

`endif

`ifdef TEST

  //adc_data
  integer fd_adc_out;
  initial begin
    fd_adc_out = $fopen("D:/code/complete/program_data/out_data/adc_out.txt","w");
    forever begin
      @(posedge adc_clk)begin
        if(adc_valid_r)begin
            $fwrite(fd_adc_out,"%d %d\n",$signed(adc_data_r[WIDTH*2-1:WIDTH]),$signed(adc_data_r[WIDTH-1:0]));
            $fwrite(fd_adc_out,"%d %d\n",$signed(adc_data_r[(WIDTH*2*2)-1:WIDTH+WIDTH*2*1]),$signed(adc_data_r[WIDTH-1+WIDTH*2*1:WIDTH*2*1]));
            $fwrite(fd_adc_out,"%d %d\n",$signed(adc_data_r[(WIDTH*2*3)-1:WIDTH+WIDTH*2*2]),$signed(adc_data_r[WIDTH-1+WIDTH*2*2:WIDTH*2*2]));
            $fwrite(fd_adc_out,"%d %d\n",$signed(adc_data_r[(WIDTH*2*4)-1:WIDTH+WIDTH*2*3]),$signed(adc_data_r[WIDTH-1+WIDTH*2*3:WIDTH*2*3]));
            $fwrite(fd_adc_out,"%d %d\n",$signed(adc_data_r[(WIDTH*2*5)-1:WIDTH+WIDTH*2*4]),$signed(adc_data_r[WIDTH-1+WIDTH*2*4:WIDTH*2*4]));
            $fwrite(fd_adc_out,"%d %d\n",$signed(adc_data_r[(WIDTH*2*6)-1:WIDTH+WIDTH*2*5]),$signed(adc_data_r[WIDTH-1+WIDTH*2*5:WIDTH*2*5]));
            $fwrite(fd_adc_out,"%d %d\n",$signed(adc_data_r[(WIDTH*2*7)-1:WIDTH+WIDTH*2*6]),$signed(adc_data_r[WIDTH-1+WIDTH*2*6:WIDTH*2*6]));
            $fwrite(fd_adc_out,"%d %d\n",$signed(adc_data_r[(WIDTH*2*8)-1:WIDTH+WIDTH*2*7]),$signed(adc_data_r[WIDTH-1+WIDTH*2*7:WIDTH*2*7]));
        end
      end
    end
  end
  //chirp_data
  integer fd_chirp_out;
  initial begin
    fd_chirp_out = $fopen("D:/code/complete/program_data/out_data/chirp_out.txt","w");
    forever begin
      @(posedge adc_clk)begin
        if(adc_valid_r)begin
            $fwrite(fd_chirp_out,"%d %d\n",$signed(read_data_fft[WIDTH*2-1:WIDTH]),$signed(read_data_fft[WIDTH-1:0]));
            $fwrite(fd_chirp_out,"%d %d\n",$signed(read_data_fft[(WIDTH*2*2)-1:WIDTH+WIDTH*2*1]),$signed(read_data_fft[WIDTH-1+WIDTH*2*1:WIDTH*2*1]));
            $fwrite(fd_chirp_out,"%d %d\n",$signed(read_data_fft[(WIDTH*2*3)-1:WIDTH+WIDTH*2*2]),$signed(read_data_fft[WIDTH-1+WIDTH*2*2:WIDTH*2*2]));
            $fwrite(fd_chirp_out,"%d %d\n",$signed(read_data_fft[(WIDTH*2*4)-1:WIDTH+WIDTH*2*3]),$signed(read_data_fft[WIDTH-1+WIDTH*2*3:WIDTH*2*3]));
            $fwrite(fd_chirp_out,"%d %d\n",$signed(read_data_fft[(WIDTH*2*5)-1:WIDTH+WIDTH*2*4]),$signed(read_data_fft[WIDTH-1+WIDTH*2*4:WIDTH*2*4]));
            $fwrite(fd_chirp_out,"%d %d\n",$signed(read_data_fft[(WIDTH*2*6)-1:WIDTH+WIDTH*2*5]),$signed(read_data_fft[WIDTH-1+WIDTH*2*5:WIDTH*2*5]));
            $fwrite(fd_chirp_out,"%d %d\n",$signed(read_data_fft[(WIDTH*2*7)-1:WIDTH+WIDTH*2*6]),$signed(read_data_fft[WIDTH-1+WIDTH*2*6:WIDTH*2*6]));
            $fwrite(fd_chirp_out,"%d %d\n",$signed(read_data_fft[(WIDTH*2*8)-1:WIDTH+WIDTH*2*7]),$signed(read_data_fft[WIDTH-1+WIDTH*2*7:WIDTH*2*7]));
        end
      end
    end
  end

  //conj_data
  integer fd_chirp_conj;
  initial begin
    fd_chirp_conj = $fopen("D:/code/complete/program_data/out_data/chirp_conj.txt","w");
    forever begin
      @(posedge adc_clk)begin
        if(adc_valid_r)begin
            $fwrite(fd_chirp_conj,"%d %d\n",$signed(read_data_conjugate[WIDTH*2-1:WIDTH]),$signed(read_data_conjugate[WIDTH-1:0]));
            $fwrite(fd_chirp_conj,"%d %d\n",$signed(read_data_conjugate[(WIDTH*2*2)-1:WIDTH+WIDTH*2*1]),$signed(read_data_conjugate[WIDTH-1+WIDTH*2*1:WIDTH*2*1]));
            $fwrite(fd_chirp_conj,"%d %d\n",$signed(read_data_conjugate[(WIDTH*2*3)-1:WIDTH+WIDTH*2*2]),$signed(read_data_conjugate[WIDTH-1+WIDTH*2*2:WIDTH*2*2]));
            $fwrite(fd_chirp_conj,"%d %d\n",$signed(read_data_conjugate[(WIDTH*2*4)-1:WIDTH+WIDTH*2*3]),$signed(read_data_conjugate[WIDTH-1+WIDTH*2*3:WIDTH*2*3]));
            $fwrite(fd_chirp_conj,"%d %d\n",$signed(read_data_conjugate[(WIDTH*2*5)-1:WIDTH+WIDTH*2*4]),$signed(read_data_conjugate[WIDTH-1+WIDTH*2*4:WIDTH*2*4]));
            $fwrite(fd_chirp_conj,"%d %d\n",$signed(read_data_conjugate[(WIDTH*2*6)-1:WIDTH+WIDTH*2*5]),$signed(read_data_conjugate[WIDTH-1+WIDTH*2*5:WIDTH*2*5]));
            $fwrite(fd_chirp_conj,"%d %d\n",$signed(read_data_conjugate[(WIDTH*2*7)-1:WIDTH+WIDTH*2*6]),$signed(read_data_conjugate[WIDTH-1+WIDTH*2*6:WIDTH*2*6]));
            $fwrite(fd_chirp_conj,"%d %d\n",$signed(read_data_conjugate[(WIDTH*2*8)-1:WIDTH+WIDTH*2*7]),$signed(read_data_conjugate[WIDTH-1+WIDTH*2*7:WIDTH*2*7]));
        end
      end
    end
  end
  
  //complex_multi
  integer fd_complex_multi;
  initial begin
    fd_complex_multi = $fopen("D:/code/complete/program_data/out_data/complex_multi.txt","w");
    forever begin
      @(posedge adc_clk)begin
        if(m_axis_multi_dout_tvalid_buf[0])begin
            $fwrite(fd_complex_multi,"%d %d\n",$signed(m_axis_multi_dout_tdata_buf[0][31:16]),$signed(m_axis_multi_dout_tdata_buf[0][15:0]));
            $fwrite(fd_complex_multi,"%d %d\n",$signed(m_axis_multi_dout_tdata_buf[1][31:16]),$signed(m_axis_multi_dout_tdata_buf[1][15:0]));
            $fwrite(fd_complex_multi,"%d %d\n",$signed(m_axis_multi_dout_tdata_buf[2][31:16]),$signed(m_axis_multi_dout_tdata_buf[2][15:0]));
            $fwrite(fd_complex_multi,"%d %d\n",$signed(m_axis_multi_dout_tdata_buf[3][31:16]),$signed(m_axis_multi_dout_tdata_buf[3][15:0]));
            $fwrite(fd_complex_multi,"%d %d\n",$signed(m_axis_multi_dout_tdata_buf[4][31:16]),$signed(m_axis_multi_dout_tdata_buf[4][15:0]));
            $fwrite(fd_complex_multi,"%d %d\n",$signed(m_axis_multi_dout_tdata_buf[5][31:16]),$signed(m_axis_multi_dout_tdata_buf[5][15:0]));
            $fwrite(fd_complex_multi,"%d %d\n",$signed(m_axis_multi_dout_tdata_buf[6][31:16]),$signed(m_axis_multi_dout_tdata_buf[6][15:0]));
            $fwrite(fd_complex_multi,"%d %d\n",$signed(m_axis_multi_dout_tdata_buf[7][31:16]),$signed(m_axis_multi_dout_tdata_buf[7][15:0]));

        end
      end
    end
  end

  //fft_in_data_data
  integer fd_fft_in_data;
  initial begin
    fd_fft_in_data = $fopen("D:/code/complete/program_data/out_data/fft_in_data.txt","w");
    forever begin
      @(posedge adc_clk)begin
        if(s_axis_fft_data_tvalid && s_axis_fft_data_tready)begin
            $fwrite(fd_fft_in_data,"%x\n",s_axis_fft_data_tdata[WIDTH*4-1:0]);
        end
      end
    end
  end

  //fft_out_data_data
  integer fd_fft_out_data;
  initial begin
    fd_fft_out_data = $fopen("D:/code/complete/program_data/out_data/fft_out_data.txt","w");
    forever begin
      @(posedge adc_clk)begin
        if(m_axis_fft_data_tvalid)begin
            $fwrite(fd_fft_out_data,"%x\n",m_axis_fft_data_tdata[WIDTH*4-1:0]);
        end
      end
    end
  end

//value_four
integer fd_fft_data_latch;
initial begin
  fd_fft_data_latch = $fopen("D:/code/complete/program_data/out_data/fft_data_latch.txt", "w");
  forever begin
    @(posedge adc_clk)
    begin
      if (fft_valid_latch)
      begin
        $fwrite(fd_fft_data_latch, "fft_index_max     : %d\n", fft_index_max_latch);
        $fwrite(fd_fft_data_latch, "fft_value_max_i  : %x, fft_value_max_q   : %x\n", fft_value_max_latch[WIDTH*2-1:0], fft_value_max_latch[WIDTH*2*2-1:WIDTH*2]);
        $fwrite(fd_fft_data_latch, "fft_value_left_i   : %x, fft_value_left_q  : %x\n", fft_value_left_latch[WIDTH*2-1:0], fft_value_left_latch[WIDTH*2*2-1:WIDTH*2]);
        $fwrite(fd_fft_data_latch, "fft_value_right_i : %x, fft_value_right_q : %x\n", fft_value_right_latch[WIDTH*2-1:0], fft_value_right_latch[WIDTH*2*2-1:WIDTH*2]);
      end
    end
  end
end


`endif

endmodule
