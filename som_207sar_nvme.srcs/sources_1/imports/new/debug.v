`include "configure.vh"
`timescale 1ns/1ns
`timescale 1ns / 1ps
module debug#(
    parameter LOCAL_DWIDTH 	= 256,
    parameter WIDTH         = 32  ,
    parameter LANE_NUM      = 8   ,
    parameter CHIRP_NUM     = 256
)
(
    input                             sys_clk_p       ,
    input                             sys_clk_n       ,
    `ifdef TEST
        input resetn                                  ,
    `endif
    output                            dac_valid
);

   wire err_flag; 
  clk_wiz_0 u_clk_wiz_0
   (
    .clk_out1   (adc_clk    ), 
    .reset      (0          ), 
    .locked     (locked     ), 
    .clk_in1_p  (sys_clk_p  ),    
    .clk_in1_n  (sys_clk_n  )
    );  

    wire fifo_overflow ;
    wire fifo_underflow;

    `ifndef TEST
        wire resetn;
    `endif
    `ifdef DISTURB_DEBUG
        vio_ctrl u_vio_ctrl (
        .clk            (adc_clk        ), 
        .probe_in0      (err_flag       ),
        .probe_in1      (fifo_overflow  ),
        .probe_in2      (fifo_underflow ),
        .probe_out0     (resetn         )  
        );
    `endif
//adc
wire rd_en;
wire adc_valid_pre;
reg [12 : 0] read_addr;
wire [WIDTH*8-1:0] adc_data;
// reg [31:0] cnt_ram;

// always@(posedge adc_clk)begin
//     if(!resetn)
//         cnt_ram <= 0;
//     else if(cnt_ram == 128 + 24900 + 128 + 20)
//         cnt_ram <= cnt_ram;
//     else
//         cnt_ram <= cnt_ram + 1;
// end

// always@(posedge adc_clk)begin
//     if(!resetn)
//         rd_en <= 0;
//     else if(cnt_ram < 128)
//         rd_en <= 1;
//     else if(cnt_ram < 128 + 24900)
//         rd_en <= 0;
//     else if(cnt_ram < 128 + 24900 + 128)
//         rd_en <= 1;
//     else if(cnt_ram < 128 + 24900 + 128 + 20)
//         rd_en <= 0;
//     // else if(cnt_ram < 424)
//     //     rd_en <= 1;
//     // else
//     //     rd_en <= 0;
// end

assign rd_en = adc_valid_pre ;

always @(posedge adc_clk) begin
    if(!resetn)
        read_addr <= 0;
    else if(rd_en)
        read_addr <= read_addr + 1;        
end



wire ena            ;    
wire [0 : 0] wea    ;        
wire [15 : 0] addra ;    
wire [31 : 0] dina  ;    
wire [31 : 0] douta ;    

bram_debug u_bram_debug (
  .clka    (adc_clk        ), 
  .ena     (0              ), 
  .wea     (0              ), 
  .addra   (0              ), 
  .dina    (0              ), 
  .douta   (douta          ), 
  .clkb    (adc_clk        ), 
  .enb     (rd_en          ), 
  .web     (0              ), 
  .addrb   (read_addr      ),
  .dinb    (dina           ), 
  .doutb   (adc_data       )  
);

wire [255:0]    mfifo_rd_data;
wire            mfifo_rd_enable;

`ifdef TEST
//fifo
reg [255:0] din;
reg [31:0] cnt_fifo;
always@(posedge adc_clk) begin
    if(!resetn)
        cnt_fifo <= 0;
    else if(cnt_fifo == 256)
        cnt_fifo <= cnt_fifo;
    else
        cnt_fifo <= cnt_fifo + 1;
end

assign wr_en = !resetn ? 0 : 0 < cnt_fifo && cnt_fifo < 257;

always@(posedge adc_clk)begin
    if(!resetn)
        din <= 0;
    else
        din <= {$random%2147483647,$random%2147483647,$random%2147483647,$random%2147483647,$random%2147483647,$random%2147483647,$random%2147483647,$random%2147483647};
end



fifo_debug u_fifo_debug (
  .clk          (adc_clk            )   ,  
  .srst         (0                  )   ,  
  .din          (din                )   ,  
  .wr_en        (wr_en              )   ,  
  .rd_en        (mfifo_rd_enable    )   ,  
  .dout         (mfifo_rd_data      )   ,  
  .full         (full               )   ,  
  .empty        (empty              )   ,  
  .wr_rst_busy  (wr_rst_busy        )   ,  
  .rd_rst_busy  (rd_rst_busy        )      
);
`endif
wire   [31:0]                    app_param0  ;
wire   [31:0]                    app_param1  ;
wire   [31:0]                    app_param2  ;
wire   [31:0]                    app_param3  ;
wire   [31:0]                    app_param4  ;
wire   [31:0]                    app_param5  ;
wire   [31:0]                    app_param6  ;
wire   [31:0]                    app_param7  ;
reg   [31:0]                     app_param8  ;
wire   [31:0]                    app_param9  ;
wire   [31:0]                    app_param10 ;
wire   [31:0]                    app_param11 ;

wire   [31:0]                    app_status0 ;
wire   [31:0]                    app_status1 ;
wire   [31:0]                    app_status2 ;
wire   [31:0]                    app_status3 ;
wire   [31:0]                    app_status4 ;
wire   [31:0]                    app_status5 ;
wire   [31:0]                    app_status6 ;

wire fft_valid;
assign fft_valid = app_status6[0];

assign app_param0 = 256*8;                  //chirp_num
assign app_param1 = 1024;                   //signal_num
assign app_param2 = 16'sd389;               //k_value
assign app_param3 = 16'sd2538;              //b_value
assign app_param4 = 28;                     //template_delay
assign app_param5 = 21;                     //distance_delay
assign app_param6 = {31'b0,fft_valid};      //kb_valid
assign app_param7 = 128*8;                  //adc_shreshold
// assign app_param8 = 2;                      //mode_value

assign app_param9  = 30000;                 //prf_period 200us
assign app_param10 = 300;                   //prf->adc延迟
assign app_param11 = 10;                    //disturb_times

initial begin
    app_param8 = 1;
    #100000
    app_param8 = 2;
end


disturb_wrapper#(
    . LOCAL_DWIDTH (LOCAL_DWIDTH) ,
    . WIDTH        (WIDTH       ) ,
    . LANE_NUM     (LANE_NUM    ) ,
    . CHIRP_NUM    (CHIRP_NUM   ) 
)
u_disturb_wrapper(
. adc_clk         (adc_clk        ) ,
. resetn          (resetn         ) ,

. app_param0      (app_param0     ) ,
. app_param1      (app_param1     ) ,
. app_param2      (app_param2     ) ,
. app_param3      (app_param3     ) ,
. app_param4      (app_param4     ) ,
. app_param5      (app_param5     ) ,
. app_param6      (app_param6     ) ,
. app_param7      (app_param7     ) ,
. app_param8      (app_param8     ) ,
. app_param9      (app_param9     ) ,
. app_param10     (app_param10    ) ,
. app_param11     (app_param11    ) ,

. app_status0     (app_status0    ) ,
. app_status1     (app_status1    ) ,
. app_status2     (app_status2    ) ,
. app_status3     (app_status3    ) ,
. app_status4     (app_status4    ) ,
. app_status5     (app_status5    ) ,
. app_status6     (app_status6    ) ,

. adc_data        (adc_data       ) ,//需要拼接而来
. adc_valid_pre   (adc_valid_pre  ) ,
. mfifo_rd_enable (mfifo_rd_enable) ,
. mfifo_rd_data   (mfifo_rd_data  ) ,
. dac_data        (dac_data       ) ,
. dac_valid       (dac_valid      ) ,
. err_flag        (err_flag       ) ,
. fifo_overflow   (fifo_overflow  ) ,
. fifo_underflow  (fifo_underflow ) 
    );


endmodule
