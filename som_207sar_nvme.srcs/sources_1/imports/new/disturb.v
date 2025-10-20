`include "configure.vh"
`timescale 1ns / 1ps
module disturb#(
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
input                             adc_clk               ,
input                             resetn                ,
//adc
input [WIDTH*2*8-1:0]             adc_data              ,//需要拼接而来
input                             adc_valid             ,
input                             reco_trig             ,
input                             ddr_read_trig         ,

//ram_chirp
input                             chirp_clka            ,
input                             chirp_ena             ,
input  [0 : 0]                    chirp_wea             ,
input  [18 : 0]                   chirp_addra           ,
input  [31 : 0]                   chirp_dina            ,
output [31 : 0]                   chirp_douta           ,

//ram_chip_fft
input                             chirp_fft_clka        ,
input                             chirp_fft_ena         ,
input   [0 : 0]                   chirp_fft_wea         ,
input   [13 : 0]                  chirp_fft_addra       ,
input   [31 : 0]                  chirp_fft_dina        ,
output  [31 : 0]                  chirp_fft_douta       ,

//param
input   [31:0]                    chirp_length          ,
input   [31:0]                    proc_length           ,
input   [23:0]                    k_data_now            , 
input   [23:0]                    b_data_now            , 
input   [31:0]                    template_delay_now    ,
input   [31:0]                    distance_delay_now    ,
input                             k_b_valid             ,
input                             change_eq             ,
input                             star_mode             ,
output  [12:0]                    fft_index_max_latch   ,
output  [WIDTH*4-1:0]             fft_value_left_latch  ,
output  [WIDTH*4-1:0]             fft_value_right_latch ,
output  [WIDTH*4-1:0]             fft_value_max_latch   ,
output                            fft_valid_latch       ,
output  reg                       fft_valid             ,

`ifdef JOINT_TEST
input                             data_out_clka         ,
input                             data_out_ena          ,
input                             data_out_wea          ,
input  [15 : 0]                   data_out_addra        ,
input  [31 : 0]                   data_out_dina         ,
output [31 : 0]                   data_out_douta        ,
`endif

//fifo
output 						      mfifo_rd_enable       ,
input [LOCAL_DWIDTH-1:0] 	      mfifo_rd_data         ,

//dac
output [255:0]                    dac_data              ,
input [255:0]                     dac_data_o            ,
output                            dac_valid_whole       ,
input                             dac_valid_o           ,

output                            err_flag              ,
output                            fifo_overflow         ,
output                            fifo_underflow        
    );

//fft



wire [WIDTH*2*8-1 : 0]           read_data_fft              ;
wire                             read_en_fft                ;
wire [11 : 0]                    read_addr_fft              ;

wire [255:0]                     com_multi_data             ;
wire                             com_multi_valid            ;

//reco


wire [WIDTH*2*8-1 : 0]           read_data_reco             ;
wire                             read_en_reco               ;
wire  [13 : 0]                   read_addr_reco             ;

wire [WIDTH*2*8-1 : 0]           data_reco_out              ;
wire                             data_reco_valid            ; 

// wire                             fft_valid_latch            ;

wire                             err_flag_reco              ;

`ifdef TEST
wire [255:0]                     data_reco_single           ;
wire                             data_reco_valid_single     ;

`endif
//delay_multi


wire                             err_flag_demu              ;
wire                             dac_valid_temp             ;
wire [2:0]                       distance_delay_remain      ;


fft#(
    .LOCAL_DWIDTH 	   (LOCAL_DWIDTH 	 ),
    .WIDTH             (WIDTH          ),
    .FFT_WIDTH         (FFT_WIDTH      ),
    .LANE_NUM          (LANE_NUM       ),
    .CHIRP_NUM         (CHIRP_NUM      ),
    .CALCLT_DELAY      (CALCLT_DELAY   ),
    .DWIDTH_0          (DWIDTH_0       ),
    .SHIFT_RAM_DELAY   (SHIFT_RAM_DELAY),
    .ADC_CLK_FREQ      (ADC_CLK_FREQ   ),
    .RECO_DELAY        (RECO_DELAY     )
  )
u_fft(    
. adc_clk               (adc_clk                ) ,
. resetn                (resetn                 ) ,
. adc_data              (adc_data               ) ,//需要拼接而来
. adc_valid             (adc_valid              ) ,
. proc_length           (proc_length            ) ,
. change_eq             (change_eq              ) ,
`ifndef TEST
. read_data_fft         (read_data_fft          ) ,
. read_en_fft           (read_en_fft            ) ,
. read_addr_fft         (read_addr_fft          ) ,
`endif
. fft_valid_latch       (fft_valid_latch        ) ,
. fft_index_max_latch   (fft_index_max_latch    ) ,
. fft_value_max_latch   (fft_value_max_latch    ) ,  
. fft_value_left_latch  (fft_value_left_latch   ) ,  
. fft_value_right_latch (fft_value_right_latch  ) ,   
. com_multi_data        (com_multi_data         ) ,   
. com_multi_valid       (com_multi_valid        ) ,   
. fifo_overflow         (fifo_overflow          ) ,   
. fifo_underflow        (fifo_underflow         ) ,   
. dac_data_o            (dac_data_o             ) ,   
. dac_valid_o           (dac_valid_o            )    
    );

reco#(
    .LOCAL_DWIDTH 	   (LOCAL_DWIDTH 	 ),
    .WIDTH             (WIDTH          ),
    .FFT_WIDTH         (FFT_WIDTH      ),
    .LANE_NUM          (LANE_NUM       ),
    .CHIRP_NUM         (CHIRP_NUM      ),
    .CALCLT_DELAY      (CALCLT_DELAY   ),
    .DWIDTH_0          (DWIDTH_0       ),
    .SHIFT_RAM_DELAY   (SHIFT_RAM_DELAY),
    .ADC_CLK_FREQ      (ADC_CLK_FREQ   ),
    .RECO_DELAY        (RECO_DELAY     )
  )
u_reco(
.  adc_clk                  (adc_clk                ) ,
.  resetn                   (resetn                 ) ,
.  adc_valid                (adc_valid              ) ,
.  chirp_length             (chirp_length           ) ,
.  reco_trig                (reco_trig              ) ,
`ifdef TEST
.  data_reco_single         (data_reco_single       ) ,
.  data_reco_valid_single   (data_reco_valid_single ) ,  
`endif 
.  k_b_valid                (k_b_valid              ) ,
.  k_data_now               (k_data_now             ) ,
.  b_data_now               (b_data_now             ) ,
`ifndef TEST
.  read_data_reco           (read_data_reco         ) ,
.  read_en_reco             (read_en_reco           ) ,
.  read_addr_reco           (read_addr_reco         ) ,
`endif
.  data_reco_out            (data_reco_out          ) ,
.  data_reco_valid          (data_reco_valid        ) ,  
.  err_flag_reco            (err_flag_reco          )   
    );

delay_multi#(
    .LOCAL_DWIDTH 	   (LOCAL_DWIDTH 	 ),
    .WIDTH             (WIDTH          ),
    .FFT_WIDTH         (FFT_WIDTH      ),
    .LANE_NUM          (LANE_NUM       ),
    .CHIRP_NUM         (CHIRP_NUM      ),
    .CALCLT_DELAY      (CALCLT_DELAY   ),
    .DWIDTH_0          (DWIDTH_0       ),
    .SHIFT_RAM_DELAY   (SHIFT_RAM_DELAY),
    .ADC_CLK_FREQ      (ADC_CLK_FREQ   ),
    .RECO_DELAY        (RECO_DELAY     )
  )
u_delay_multi( 
.   adc_clk                 (adc_clk                ) ,
.   resetn                  (resetn                 ) ,
.   ddr_read_trig           (ddr_read_trig          ) ,
`ifdef JOINT_TEST
.   data_out_clka           (data_out_clka          ) ,
.   data_out_ena            (data_out_ena           ) ,
.   data_out_wea            (data_out_wea           ) ,
.   data_out_addra          (data_out_addra         ) ,
.   data_out_dina           (data_out_dina          ) ,
.   data_out_douta          (data_out_douta         ) ,
`endif
.   chirp_length            (chirp_length           ) ,
.   distance_delay_remain   (distance_delay_remain  ) ,
.   template_delay_now      (template_delay_now     ) ,
.   mfifo_rd_enable         (mfifo_rd_enable        ) ,
.   mfifo_rd_data           (mfifo_rd_data          ) ,
.   data_reco_out           (data_reco_out          ) ,
.   data_reco_valid         (data_reco_valid        ) ,
.   dac_data                (dac_data               ) ,
.   dac_valid               (dac_valid_whole        ) ,
.   star_mode               (star_mode              ) ,
.   err_flag_demu           (err_flag_demu          ) ,
.   dac_valid_temp          (dac_valid_temp         ) 
    );
    bram_chirp u_bram_chirp (
  .clka     (chirp_clka      ),
  .ena      (chirp_ena       ),
  .wea      (chirp_wea       ),
  .addra    (chirp_addra >>2 ),
  .dina     (chirp_dina      ),
  .douta    (chirp_douta     ),
  .clkb     (adc_clk         ),
  .enb      (read_en_reco    ),
  .web      (0               ),
  .addrb    (read_addr_reco  ),
  .dinb     (0               ),
  .doutb    (read_data_reco   ) 
);

`ifndef TEST
bram_chip_fft u_bram_chip_fft (
  .clka     (chirp_fft_clka     ), 
  .ena      (chirp_fft_ena      ), 
  .wea      (chirp_fft_wea      ), 
  .addra    (chirp_fft_addra >>2), 
  .dina     (chirp_fft_dina     ), 
  .douta    (chirp_fft_douta    ), 
  .clkb     (adc_clk            ), 
  .enb      (read_en_fft        ), 
  .web      (0                  ), 
  .addrb    (read_addr_fft      ), 
  .dinb     (0                  ), 
  .doutb    (read_data_fft      )  
);
`endif

reg [2:0] k_b_valid_r;
wire k_b_valid_pos;

always@(posedge adc_clk)begin
    if(!resetn)
        k_b_valid_r <= 0;
    else
        k_b_valid_r <= {k_b_valid_r[1:0],k_b_valid};
end

assign k_b_valid_pos = (~k_b_valid_r[2]) && k_b_valid_r[1];

always@(posedge adc_clk)begin
    if(!resetn)
        fft_valid <= 0;
    else if(fft_valid_latch)
        fft_valid <= 1;
    else if(k_b_valid_pos)
        fft_valid <= 0;
end

reg [31:0] cnt_fft_valid;
reg [31:0] cnt_fft_valid_max;
reg fft_valid_r;
wire fft_valid_neg;
always @(posedge adc_clk) begin
    if(!resetn)
        cnt_fft_valid <= 0;
    else if(fft_valid)
        cnt_fft_valid <= cnt_fft_valid + 1;
    else
        cnt_fft_valid <= 0;
end

always@(posedge adc_clk)begin
    if(!resetn)
        fft_valid_r <= 0;
    else
        fft_valid_r <= fft_valid;
end

assign fft_valid_neg = fft_valid_r && (~fft_valid);

always@(posedge adc_clk)begin
    if(!resetn)
        cnt_fft_valid_max <= 0;
    else if(fft_valid_neg)begin
        if(cnt_fft_valid >= cnt_fft_valid_max)
            cnt_fft_valid_max <= cnt_fft_valid;
        else
            cnt_fft_valid_max <= cnt_fft_valid_max;
    end
    else
        cnt_fft_valid_max <= cnt_fft_valid_max;
end

`ifdef DISTURB_DEBUG
ila_kb_valid u_ila_kb_valid (
        .clk(adc_clk), // input wire clk


        .probe0(fft_valid), // input wire [0:0]  probe0  
        .probe1(cnt_fft_valid), // input wire [7:0]  probe1
        .probe2(adc_valid), // input wire [7:0]  probe1
        .probe3(k_b_valid), // input wire [7:0]  probe1
        .probe4(cnt_fft_valid_max) // input wire [7:0]  probe1
    );
`endif

assign err_flag = err_flag_reco | err_flag_demu; 

//adc_valid上升沿
reg adc_valid_r;
wire adc_valid_pos;
always@(posedge adc_clk)adc_valid_r <= adc_valid;
assign adc_valid_pos = ~adc_valid_r && adc_valid;
//dac_valid_temp上升沿
reg dac_valid_temp_r;
wire dac_valid_temp_pos;
always@(posedge adc_clk)dac_valid_temp_r <= dac_valid_temp;
assign dac_valid_temp_pos = ~dac_valid_temp_r && dac_valid_temp;

assign distance_delay_remain = distance_delay_now[2:0];

`ifdef TEST

reg rd_clk=0;
always # 0.41666666625  rd_clk = ~rd_clk;

wire [31:0] reco_single_32;
wire reco_single_32_valid;
wire [255:0] fifo_din_reco_single;

wire wr_en;

genvar ii;
generate
    for(ii = 0;ii < 8; ii = ii + 1)begin:blk0
        assign fifo_din_reco_single[(ii+1)*32-1:ii*32] = data_reco_single[(8-ii)*32-1:(7-ii)*32];
    end
endgenerate

assign wr_en = data_reco_valid_single;




fifo_test u_fifo_test_reco_single (
  .rst(),                  // input wire rst
  .wr_clk(adc_clk),            // input wire wr_clk
  .rd_clk(rd_clk),            // input wire rd_clk
  .din(fifo_din_reco_single),                  // input wire [255 : 0] din
  .wr_en(wr_en),              // input wire wr_en
  .rd_en(1),              // input wire rd_en
  .dout(reco_single_32),                // output wire [31 : 0] dout
  .full(full),                // output wire full
  .empty(empty),              // output wire empty
  .wr_rst_busy(wr_rst_busy),  // output wire wr_rst_busy
  .valid(reco_single_32_valid),
  .rd_rst_busy(rd_rst_busy)  // output wire rd_rst_busy
);

wire [31:0] reco_32;
wire reco_32_valid;
wire [255:0] fifo_din_reco;

wire wr_en_reco;

genvar jj;
generate
    for(jj = 0;jj < 8; jj = jj + 1)begin:blk1
        assign fifo_din_reco[(jj+1)*32-1:jj*32] = data_reco_out[(8-jj)*32-1:(7-jj)*32];
    end
endgenerate

assign wr_en_reco = data_reco_valid;

fifo_test u_fifo_test_reco (
  .rst(),                  // input wire rst
  .wr_clk(adc_clk),            // input wire wr_clk
  .rd_clk(rd_clk),            // input wire rd_clk
  .din(fifo_din_reco),                  // input wire [255 : 0] din
  .wr_en(wr_en_reco),              // input wire wr_en_reco
  .rd_en(1),              // input wire rd_en
  .dout(reco_32),                // output wire [31 : 0] dout
  .full(full),                // output wire full
  .empty(empty),              // output wire empty
  .wr_rst_busy(wr_rst_busy),  // output wire wr_rst_busy
  .valid(reco_32_valid),
  .rd_rst_busy(rd_rst_busy)  // output wire rd_rst_busy
);

wire [31:0] dac_32;
wire dac_32_valid;
wire [255:0] fifo_din_dac;

wire wr_en_dac;

genvar kk;
generate
    for(kk = 0;kk < 8; kk = kk + 1)begin:blk2
        assign fifo_din_dac[(kk+1)*32-1:kk*32] = dac_data[(8-kk)*32-1:(7-kk)*32];
    end
endgenerate

assign wr_en_dac = dac_valid_whole;

fifo_test u_fifo_test_dac (
  .rst(),                  // input wire rst
  .wr_clk(adc_clk),            // input wire wr_clk
  .rd_clk(rd_clk),            // input wire rd_clk
  .din(fifo_din_dac),                  // input wire [255 : 0] din
  .wr_en(wr_en_dac),              // input wire wr_en_dac
  .rd_en(1),              // input wire rd_en
  .dout(dac_32),                // output wire [31 : 0] dout
  .full(full),                // output wire full
  .empty(empty),              // output wire empty
  .wr_rst_busy(wr_rst_busy),  // output wire wr_rst_busy
  .valid(dac_32_valid),
  .rd_rst_busy(rd_rst_busy)  // output wire rd_rst_busy
);

wire [31:0] com_multi_32;
wire com_multi_32_valid;
wire [255:0] fifo_din_com_multi;

wire wr_en_com_multi;

genvar ll;
generate
    for(ll = 0;ll < 8; ll = ll + 1)begin:blk3
        assign fifo_din_com_multi[(ll+1)*32-1:ll*32] = com_multi_data[(8-ll)*32-1:(7-ll)*32];
    end
endgenerate

assign wr_en_com_multi = com_multi_valid;

fifo_test u_fifo_test_com_multi (
  .rst(),                  // input wire rst
  .wr_clk(adc_clk),            // input wire wr_clk
  .rd_clk(rd_clk),            // input wire rd_clk
  .din(fifo_din_com_multi),                  // input wire [255 : 0] din
  .wr_en(wr_en_com_multi),              // input wire wr_en_com_multi
  .rd_en(1),              // input wire rd_en
  .dout(com_multi_32),                // output wire [31 : 0] dout
  .full(full),                // output wire full
  .empty(empty),              // output wire empty
  .wr_rst_busy(wr_rst_busy),  // output wire wr_rst_busy
  .valid(com_multi_32_valid),
  .rd_rst_busy(rd_rst_busy)  // output wire rd_rst_busy
);



wire [31:0] adc_32;
wire adc_32_valid;
wire [255:0] fifo_din_adc;

wire wr_en_adc;

reg [255:0] adc_data_r;

always@(posedge adc_clk)begin
    if(!resetn)begin
        adc_data_r  <= 0;
    end

    else begin
        adc_data_r  <= adc_data;
    end

end

genvar mm;
generate
    for(mm = 0;mm < 8; mm = mm + 1)begin:blk4s
        assign fifo_din_adc[(mm+1)*32-1:mm*32] = adc_data_r[(8-mm)*32-1:(7-mm)*32];
    end
endgenerate

assign wr_en_adc = adc_valid_r;

fifo_test u_fifo_test_adc (
  .rst(),                  // input wire rst
  .wr_clk(adc_clk),            // input wire wr_clk
  .rd_clk(rd_clk),            // input wire rd_clk
  .din(fifo_din_adc),                  // input wire [255 : 0] din
  .wr_en(wr_en_adc),              // input wire wr_en_adc
  .rd_en(1),              // input wire rd_en
  .dout(adc_32),                // output wire [31 : 0] dout
  .full(full),                // output wire fumm
  .empty(empty),              // output wire empty
  .wr_rst_busy(wr_rst_busy),  // output wire wr_rst_busy
  .valid(adc_32_valid),
  .rd_rst_busy(rd_rst_busy)  // output wire rd_rst_busy
);


`endif

endmodule
