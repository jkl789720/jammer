`include "configure.vh"
//还没加距离延时
`timescale 1ns / 1ps
module delay_multi#(
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
input                               adc_clk                 ,
input                               resetn                  ,
input                               ddr_read_trig           ,
`ifdef JOINT_TEST
input                               data_out_clka           ,
input                               data_out_ena            ,
input                               data_out_wea            ,
input  [15 : 0]                     data_out_addra          ,
input  [31 : 0]                     data_out_dina           ,
output [31 : 0]                     data_out_douta          ,
`endif
input [31:0]                        chirp_length            ,
input [31:0]                        template_delay_now      ,//
//距离延时
input [2:0]                         distance_delay_remain   ,
//fifo
output   						    mfifo_rd_enable         ,//
input [LOCAL_DWIDTH-1:0] 	        mfifo_rd_data           ,
//reco_data
input [WIDTH*2*8-1 : 0]             data_reco_out           ,
input                               data_reco_valid         ,
input                               star_mode               ,
//dac
output [255:0]                      dac_data                ,
output                              dac_valid               ,
output                              err_flag_demu           ,
output                              dac_valid_temp   
    );

//机载 ddr_read_en_generate
wire ddr_add_flag_plane;
reg [31:0] cnt_ddr_en_plane;
reg  add_flag_temp_plane;
wire ddr_end_flag_plane;
always @(posedge adc_clk) begin
    if(!resetn)
        add_flag_temp_plane <= 0;
    else if(ddr_read_trig)
        add_flag_temp_plane <= 1;
    else if(ddr_end_flag_plane)
        add_flag_temp_plane <= 0;
end
always @(posedge adc_clk) begin
    if(!resetn)
        cnt_ddr_en_plane <= 0;
    else if(ddr_add_flag_plane)begin
        if(ddr_end_flag_plane)
            cnt_ddr_en_plane <= 0;
        else
            cnt_ddr_en_plane <= cnt_ddr_en_plane + 1;
    end
        

end

assign ddr_add_flag_plane = add_flag_temp_plane || ddr_read_trig;
assign ddr_end_flag_plane = add_flag_temp_plane && cnt_ddr_en_plane == (chirp_length >> 3) - 1;//改动点


//星载模式
wire fifo_ddr_valid,fifo_ddr_overflow,fifo_ddr_underflow,fifo_ddr_rd_en;
wire [63:0] fifo_ddr_dout;
wire [255:0] fifo_ddr_din;
reg  [1:0] cnt_fifo_en;//

reg template_multi_flag;//标识模板相乘阶段
reg [31:0] cnt_ddr_en_star;//计数ddr读取次数，或者说是并行点数
wire ddr_add_flag_star;//ddr读取计数器加一的标志
wire ddr_end_flag_star;//ddr读取计数器结束的标志

assign ddr_add_flag_star = ddr_read_trig || (template_multi_flag && cnt_fifo_en == 1);//事先要用读一次数据放到fifo里面，这样后续逻辑才可以开始计数；之后取数据就按照cnt_fifo取。这样设计可以节省FIFO资源
//同时他也是星载模式下的ddr读使能

assign ddr_end_flag_star = ddr_add_flag_star && cnt_ddr_en_star == (chirp_length >> 5) - 1;//8路并行所以要除以8，一个点复制4次，所以要额外除以4

always@(posedge adc_clk)begin
    if(!resetn)
        template_multi_flag <= 0;
    else if(ddr_read_trig)
        template_multi_flag <= 1;
    else if(ddr_end_flag_star)
        template_multi_flag <= 0;
end

always@(posedge adc_clk)begin
    if(!resetn)
        cnt_ddr_en_star <= 0;
    else if(ddr_add_flag_star)begin
        if(ddr_end_flag_star)
            cnt_ddr_en_star <= 0;
        else
            cnt_ddr_en_star <= cnt_ddr_en_star + 1;
    end
end

//高低位颠倒
genvar ii;
generate
    for(ii = 0;ii < 8; ii = ii + 1)begin:blk0
        assign fifo_ddr_din[(ii+1)*32-1:ii*32] = mfifo_rd_data[(8-ii)*32-1:(7-ii)*32];
    end
endgenerate

fifo_ddr u_fifo_ddr (
  .clk          (adc_clk                ),                  // input wire clk
  .srst         (~resetn                ),                // input wire srst
  .din          (fifo_ddr_din           ),                  // input wire [255 : 0] din
  .wr_en        (mfifo_rd_enable        ),              // input wire wr_en
  .rd_en        (fifo_ddr_rd_en         ),              // input wire rd_en
  .dout         (fifo_ddr_dout          ),                // output wire [63 : 0] dout
  .full         (full                   ),                // output wire full
  .overflow     (fifo_ddr_overflow      ),        // output wire overflow
  .empty        (empty                  ),              // output wire empty
  .valid        (fifo_ddr_valid         ),              // output wire valid
  .underflow    (fifo_ddr_underflow     ),      // output wire underflow
  .wr_rst_busy  (wr_rst_busy            ),  // output wire wr_rst_busy
  .rd_rst_busy  (rd_rst_busy            )  // output wire rd_rst_busy
);

assign fifo_ddr_rd_en = fifo_ddr_valid;

//计数fifo中单点点数
always@(posedge adc_clk)begin
    if(!resetn)
        cnt_fifo_en <= 0;
    else if(fifo_ddr_valid)
        cnt_fifo_en <= cnt_fifo_en + 1;
    else
        cnt_fifo_en <= cnt_fifo_en;
end

assign mfifo_rd_enable = star_mode ? ddr_add_flag_star : ddr_add_flag_plane;//读使能也即是加一条件

wire data_sel;
`ifdef TEST
    assign data_sel = 1;
`endif

wire [255:0] mfifo_rd_data_test;

wire [15:0] ddr_vio;

vio_ddr_sel u_vio_ddr_sel (
  .clk          (adc_clk    ), 
  `ifndef TEST
  .probe_out0   (data_sel   ),  
  `endif
  .probe_out1   (ddr_vio    )  
);

//ddr的iq会不会跟adc一样需要处理
assign mfifo_rd_data_test = {16{ddr_vio}};

`ifdef JOINT_TEST
wire wr_en;
reg [12:0] wr_addr;
wire [255:0] wr_data;
`endif



    



`ifdef DISTURB_DEBUG

// ila_dac u_ila_dac (
// 	.clk        (adc_clk                ),
// 	.probe0     (dac_valid              ),//1
// 	.probe1     (dac_data               )//256
// );

ila_ddr u_ila_ddr (
	.clk        (adc_clk                ),
	.probe0     (fifo_ddr_valid         ),//1
	.probe1     (fifo_ddr_dout          ),//64
	.probe2     (ddr_add_flag_star      ),//1
	.probe3     (cnt_ddr_en_star        ),//32
	.probe4     (cnt_fifo_en            ),//2
	.probe5     (cnt_ddr_en_plane       ),//32
	.probe6     (ddr_add_flag_plane     ),//1
	.probe7     (mfifo_rd_data[31:0]    ) //32
);
`endif
//数据延时
reg [LOCAL_DWIDTH-1:0] template_data;

reg  [LOCAL_DWIDTH-1:0] 	        template_data_temp_r    ;
wire [LOCAL_DWIDTH-1:0]             template_data_temp      ;
wire [LOCAL_DWIDTH-1:0]             template_data_in        ;

wire template_data_valid;//星载模式和空载模式有所不同
reg template_data_valid_r;
wire template_data_valid_pos;

//data_generate
//{4{xxx}}这种格式才是一个数，才可以参与拼接，4{xxx}不行
assign template_data_in = star_mode ? {{4{fifo_ddr_dout[31:0]}},{4{fifo_ddr_dout[63:32]}}} : mfifo_rd_data;//根据不同模式选择模板数据

assign template_data_temp = template_data_in;//小数延时模块的输入

always@(posedge adc_clk) template_data_temp_r <= template_data_temp;

//valid_generate
always@(posedge adc_clk)begin
    if(!resetn)
        template_data_valid_r <= 0;
    else
        template_data_valid_r <= template_data_valid;
end

assign template_data_valid_pos = ~template_data_valid_r && template_data_valid;

assign template_data_valid = star_mode ? fifo_ddr_valid : mfifo_rd_enable;

wire [2:0] fraction_delay;//小数延时
assign fraction_delay = template_delay_now[31] == 0 ? template_delay_now[2:0] : 4'sd8 + $signed({template_delay_now[31],template_delay_now[2:0]});//正数延时正常逻辑延时就行，负数延时整数部分多左移延时一个周期，小数部分右移和8互补的位数

always@(*)begin
    if(!resetn)
        template_data = 0;
    else if(template_data_valid)begin
        case (fraction_delay)
            0: begin
                    template_data = template_data_temp;
            end    
            1 :begin
                if(template_data_valid_pos)
                    template_data = {template_data_temp[(7*32)-1:0],32'b0};
                else
                    template_data = {template_data_temp[(7*32)-1:0],template_data_temp_r[8*32-1:7*32]};
            end
            2 :begin
                if(template_data_valid_pos)
                    template_data = {template_data_temp[(6*32)-1:0],64'b0};
                else
                    template_data = {template_data_temp[(6*32)-1:0],template_data_temp_r[8*32-1:6*32]};
            end
            3 :begin
                if(template_data_valid_pos)
                    template_data = {template_data_temp[(5*32)-1:0],96'b0};
                else
                    template_data = {template_data_temp[(5*32)-1:0],template_data_temp_r[8*32-1:5*32]};
            end
            4 :begin
                if(template_data_valid_pos)
                    template_data = {template_data_temp[(4*32)-1:0],128'b0};
                else
                    template_data = {template_data_temp[(4*32)-1:0],template_data_temp_r[8*32-1:4*32]};
            end
            5 :begin
                if(template_data_valid_pos)
                    template_data = {template_data_temp[(3*32)-1:0],160'b0};
                else
                    template_data = {template_data_temp[(3*32)-1:0],template_data_temp_r[8*32-1:3*32]};
            end
            6 :begin
                if(template_data_valid_pos)
                    template_data = {template_data_temp[(2*32)-1:0],192'b0};
                else
                    template_data = {template_data_temp[(2*32)-1:0],template_data_temp_r[8*32-1:2*32]};
            end
            7 :begin
                if(template_data_valid_pos)
                    template_data = {template_data_temp[(1*32)-1:0],224'b0};
                else
                    template_data = {template_data_temp[(1*32)-1:0],template_data_temp_r[8*32-1:1*32]};
            end
        endcase
    end
    else begin
        template_data = 0;
    end
end

reg  [31:0]                 cnt_delay               ;
wire                        s_axis_a_tvalid         ;
wire                        s_axis_a_tlast          ;              
wire                        s_axis_b_tvalid         ;
wire                        s_axis_b_tlast          ;
wire [255:0]                s_axis_b_tdata          ;

wire [LANE_NUM - 1 : 0]     m_axis_cmpy_dout_tvalid ;
wire [LANE_NUM - 1 : 0]     m_axis_cmpy_dout_tlast  ;
wire [31:0]                 m_axis_cmpy_dout_tdata [LANE_NUM - 1 : 0] ;
wire [LANE_NUM - 1 : 0] err_flag;

assign s_axis_b_tdata = data_sel ? mfifo_rd_data_test : template_data;

always@(posedge adc_clk)begin
    if(!resetn)
        cnt_delay <= 0;
    else if(s_axis_a_tvalid)begin
        if(cnt_delay == (chirp_length >> 3) - 1)
            cnt_delay <= 0;
        else
            cnt_delay <= cnt_delay + 1;
    end
    else
        cnt_delay <= 0;
end

assign s_axis_a_tvalid = data_reco_valid;
assign s_axis_b_tvalid = data_reco_valid;
assign s_axis_a_tlast  = cnt_delay == (chirp_length >> 3) - 1;
assign s_axis_b_tlast  = cnt_delay == (chirp_length >> 3) - 1;




genvar kk;
generate
    for (kk = 0;kk < LANE_NUM ;kk = kk + 1 ) begin:blk
        complex_multi u_complex_multi(              
        .  aclk                     (adc_clk                            ) ,
        .  aresetn                  (resetn                             ) ,
        .  s_axis_a_tvalid          (s_axis_a_tvalid                    ) ,//
        .  s_axis_a_tlast           (s_axis_a_tlast                     ) ,//  
        .  s_axis_a_tdata           (data_reco_out[(kk+1)*32-1:kk*32]   ) ,             
        .  s_axis_b_tvalid          (s_axis_b_tvalid                    ) ,//
        .  s_axis_b_tlast           (s_axis_b_tlast                     ) ,//
        .  s_axis_b_tdata           (s_axis_b_tdata[(kk+1)*32-1:kk*32]   ) ,
        .  m_axis_cmpy_dout_tvalid  (m_axis_cmpy_dout_tvalid[kk]        ) ,
        .  m_axis_cmpy_dout_tlast   (m_axis_cmpy_dout_tlast[kk]         ) ,
        .  m_axis_cmpy_dout_tdata   (m_axis_cmpy_dout_tdata[kk]         ) ,
        .  err_flag                 (err_flag[kk]                       )
            );      
    end
endgenerate

wire [255:0] dac_data_temp;
// wire dac_valid_temp;//改动点

assign dac_data_temp  =  {m_axis_cmpy_dout_tdata[7],m_axis_cmpy_dout_tdata[6],m_axis_cmpy_dout_tdata[5],m_axis_cmpy_dout_tdata[4],m_axis_cmpy_dout_tdata[3],m_axis_cmpy_dout_tdata[2],m_axis_cmpy_dout_tdata[1],m_axis_cmpy_dout_tdata[0]};
assign dac_valid_temp =  m_axis_cmpy_dout_tvalid[0] ;

assign err_flag_demu = |err_flag;

reg         dac_valid_temp_r  ;
reg [255:0] dac_data_temp_r   ;

always@(posedge adc_clk)begin
    if(!resetn)begin
        dac_data_temp_r  <= 0;
        dac_valid_temp_r <= 0;
    end
    else begin
        dac_data_temp_r  <= dac_data_temp ;
        dac_valid_temp_r <= dac_valid_temp;
    end

end

data_delay u_data_delay(
.  adc_clk        (adc_clk          ) ,
.  resetn         (resetn           ) ,
.  data_in        (dac_data_temp    ) ,
.  data_valid     (dac_valid_temp   ) ,
.  delay_cycle    ({5'b0,distance_delay_remain}   ) ,
.  data_out       (dac_data         ) ,
.  data_out_valid (dac_valid        ) 
    );





`ifdef JOINT_TEST
//写端口
assign wr_en =      dac_valid_temp;
assign wr_data =    dac_data_temp;

always@(posedge adc_clk)begin
    if(!resetn)
        wr_addr <= 0;
    else if(wr_en)
        wr_addr <= wr_addr + 1;
    else
        wr_addr <= 0;
end

bram_out_data u_bram_out_data (
  .clka     (data_out_clka      ), 
  .ena      (data_out_ena       ), 
  .wea      (data_out_wea       ), 
  .addra    (data_out_addra >> 2), 
  .dina     (data_out_dina      ), 
  .douta    (data_out_douta     ), 
  .clkb     (adc_clk            ), 
  .enb      (1                  ), 
  .web      (wr_en              ), 
  .addrb    (wr_addr            ), 
  .dinb     (wr_data            ), 
  .doutb    (doutb              )  
);
`endif

`ifdef TEST

//dac_temp_data
  integer fd_dac_data_temp;
  initial begin
    fd_dac_data_temp = $fopen("D:/code/complete/program_data/out_data/dac_data_temp.txt","w");
    forever begin
      @(posedge adc_clk)begin
        if(dac_valid_temp)begin
            $fwrite(fd_dac_data_temp,"%d %d\n",$signed(dac_data_temp[WIDTH*2-1:WIDTH]),$signed(dac_data_temp[WIDTH-1:0]));
            $fwrite(fd_dac_data_temp,"%d %d\n",$signed(dac_data_temp[(WIDTH*2*2)-1:WIDTH+WIDTH*2*1]),$signed(dac_data_temp[WIDTH-1+WIDTH*2*1:WIDTH*2*1]));
            $fwrite(fd_dac_data_temp,"%d %d\n",$signed(dac_data_temp[(WIDTH*2*3)-1:WIDTH+WIDTH*2*2]),$signed(dac_data_temp[WIDTH-1+WIDTH*2*2:WIDTH*2*2]));
            $fwrite(fd_dac_data_temp,"%d %d\n",$signed(dac_data_temp[(WIDTH*2*4)-1:WIDTH+WIDTH*2*3]),$signed(dac_data_temp[WIDTH-1+WIDTH*2*3:WIDTH*2*3]));
            $fwrite(fd_dac_data_temp,"%d %d\n",$signed(dac_data_temp[(WIDTH*2*5)-1:WIDTH+WIDTH*2*4]),$signed(dac_data_temp[WIDTH-1+WIDTH*2*4:WIDTH*2*4]));
            $fwrite(fd_dac_data_temp,"%d %d\n",$signed(dac_data_temp[(WIDTH*2*6)-1:WIDTH+WIDTH*2*5]),$signed(dac_data_temp[WIDTH-1+WIDTH*2*5:WIDTH*2*5]));
            $fwrite(fd_dac_data_temp,"%d %d\n",$signed(dac_data_temp[(WIDTH*2*7)-1:WIDTH+WIDTH*2*6]),$signed(dac_data_temp[WIDTH-1+WIDTH*2*6:WIDTH*2*6]));
            $fwrite(fd_dac_data_temp,"%d %d\n",$signed(dac_data_temp[(WIDTH*2*8)-1:WIDTH+WIDTH*2*7]),$signed(dac_data_temp[WIDTH-1+WIDTH*2*7:WIDTH*2*7]));
        end
    end
  end
  end

//dac_data
  integer fd_dac_data;
  initial begin
    fd_dac_data = $fopen("D:/code/complete/program_data/out_data/dac_data.txt","w");
    forever begin
      @(posedge adc_clk)begin
        if(dac_valid)begin
            $fwrite(fd_dac_data,"%d %d\n",$signed(dac_data[WIDTH*2-1:WIDTH]),$signed(dac_data[WIDTH-1:0]));
            $fwrite(fd_dac_data,"%d %d\n",$signed(dac_data[(WIDTH*2*2)-1:WIDTH+WIDTH*2*1]),$signed(dac_data[WIDTH-1+WIDTH*2*1:WIDTH*2*1]));
            $fwrite(fd_dac_data,"%d %d\n",$signed(dac_data[(WIDTH*2*3)-1:WIDTH+WIDTH*2*2]),$signed(dac_data[WIDTH-1+WIDTH*2*2:WIDTH*2*2]));
            $fwrite(fd_dac_data,"%d %d\n",$signed(dac_data[(WIDTH*2*4)-1:WIDTH+WIDTH*2*3]),$signed(dac_data[WIDTH-1+WIDTH*2*3:WIDTH*2*3]));
            $fwrite(fd_dac_data,"%d %d\n",$signed(dac_data[(WIDTH*2*5)-1:WIDTH+WIDTH*2*4]),$signed(dac_data[WIDTH-1+WIDTH*2*4:WIDTH*2*4]));
            $fwrite(fd_dac_data,"%d %d\n",$signed(dac_data[(WIDTH*2*6)-1:WIDTH+WIDTH*2*5]),$signed(dac_data[WIDTH-1+WIDTH*2*5:WIDTH*2*5]));
            $fwrite(fd_dac_data,"%d %d\n",$signed(dac_data[(WIDTH*2*7)-1:WIDTH+WIDTH*2*6]),$signed(dac_data[WIDTH-1+WIDTH*2*6:WIDTH*2*6]));
            $fwrite(fd_dac_data,"%d %d\n",$signed(dac_data[(WIDTH*2*8)-1:WIDTH+WIDTH*2*7]),$signed(dac_data[WIDTH-1+WIDTH*2*7:WIDTH*2*7]));
        end
    end
  end
  end
`endif
endmodule
