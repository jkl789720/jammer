`include "configure.vh"
`timescale 1ns / 1ps
module tb_index#(
    parameter LOCAL_DWIDTH 	= 256,
    parameter FFT_NUM       = 2048
)();
reg                       adc_clk      ;
reg                       resetn       ;
wire  [255:0]             adc_data     ;//需要拼接而来
wire                      adc_valid    ;

reg                       clka         ;
reg                       ena        =1;
wire   [0 : 0]            wea          ;
wire   [15 : 0]           addra        ;
wire   [31 : 0]           dina         ;
wire   [31 : 0]           douta        ;

reg  ram_wr_en;

reg [31:0] data_in [1023:0];
reg [31:0] data_in_ram [1023:0];

wire  						      mfifo_rd_enable ;
wire [LOCAL_DWIDTH-1:0] 	      mfifo_rd_data   ;
wire  wr_en;
reg [255:0] din;

initial begin
    adc_clk     <= 0;
    resetn      <= 0;
    ram_wr_en   <= 0;
    #200
    resetn      <= 1;
    #200
    ram_wr_en   <= 1;
end

always #3.3333333 adc_clk=~adc_clk;



initial begin
    $readmemh("D:/code/complete/s0_partial.coe",data_in,0,1023);
    $readmemh("D:/code/complete/sRef.coe",data_in_ram,0,1023);
end



reg [31:0] cnt;
always@(posedge adc_clk)begin
    if(!resetn)
        cnt <= 0;
    else if(cnt == 10000000)
        cnt <= cnt;
    else
        cnt <= cnt + 1;
end

assign  adc_valid = 1000 <= cnt && cnt <= 1127;
assign  adc_data  = {data_in[(cnt-1000)*8+7],data_in[(cnt-1000)*8+6],data_in[(cnt-1000)*8+5],data_in[(cnt-1000)*8+4],
                        data_in[(cnt-1000)*8+3],data_in[(cnt-1000)*8+2],data_in[(cnt-1000)*8+1],data_in[(cnt-1000)*8+0]};
// assign  adc_data  = data_in[0];
// reg ram_wr_en_r;
// wire ram_wr_en_pos;
// always@(posedge adc_clk)begin
//     if(!resetn)
//         ram_wr_en_r <= 0;
//     else 
//         ram_wr_en_r <= ram_wr_en;
// end

// assign ram_wr_en_pos = ~ram_wr_en_r && ram_wr_en;


// reg [31:0]  cnt_ram;
// reg         add_cnt_ram;
// wire        end_cnt_ram;

// always@(posedge adc_clk)begin
//     if(!resetn)
//         add_cnt_ram <= 0;
//     else if(ram_wr_en_pos)
//         add_cnt_ram <= 1;
//     else if(end_cnt_ram)
//         add_cnt_ram <= 0;
// end

// always@(posedge adc_clk)begin
//     if(!resetn)
//         cnt_ram <= 0;
//     else if(add_cnt_ram)begin
//         if(end_cnt_ram)
//             cnt_ram <= 0;
//         else
//             cnt_ram <= cnt_ram + 1;
//     end
// end
// assign end_cnt_ram = add_cnt_ram && cnt_ram == 1024 - 1;
// assign wea    = add_cnt_ram;
// assign addra  = cnt_ram;
// assign dina   = data_in_ram[cnt_ram];



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

top1#(
    . LOCAL_DWIDTH 	(LOCAL_DWIDTH )  ,
    . FFT_NUM       (FFT_NUM      )
)
u_top(    
.   clka            (adc_clk        )    ,
.   ena             (ena            )    ,
.   wea             (wea            )    ,
.   addra           (addra          )    ,
.   dina            (dina           )    ,
.   douta           (douta          )    ,
.   adc_clk         (adc_clk        )    ,
.   resetn          (resetn         )    ,
.   adc_data        (adc_data       )    ,//需要拼接而来
.   adc_valid       (adc_valid      )    ,
.	mfifo_rd_enable (mfifo_rd_enable)    ,
.	mfifo_rd_data   (mfifo_rd_data  )    
    );

fifo_debug u_fifo_debug (
  .clk          (adc_clk        )   ,  
  .srst         (0              )   ,  
  .din          (din            )   ,  
  .wr_en        (wr_en          )   ,  
  .rd_en        (mfifo_rd_enable          )   ,  
  .dout         (mfifo_rd_data           )   ,  
  .full         (full           )   ,  
  .empty        (empty          )   ,  
  .wr_rst_busy  (wr_rst_busy    )   ,  
  .rd_rst_busy  (rd_rst_busy    )      
);

endmodule
