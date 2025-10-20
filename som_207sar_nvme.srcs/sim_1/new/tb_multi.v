`timescale 1ns / 1ps
module tb_multi();

reg bram_clk;
reg adc_clk ;
reg bram_rst;
reg bram_en ;
// wire [3:0] bram_we = 4'hf;
reg [23:0] bram_addr;
wire [31:0] bram_wrdata;
wire [31:0] bram_rddata;
// assign bram_addr = 24'h40000 + 8;
// assign bram_addr = 24'h40044;
assign bram_wrdata = 232;

initial begin
    bram_clk = 0;
    adc_clk  = 0;
    bram_rst = 1;
    bram_en  = 0;
    bram_addr = 0;
    #200
    bram_rst = 0;
    #45000
    @(posedge bram_clk)
    bram_en = 1;
    bram_addr = 24'h40058;
    #20
    bram_en  = 0;
    bram_addr = 0;

end

always #10 bram_clk = ~bram_clk;
always #3.3333333 adc_clk = ~adc_clk;

multifunc u_multifunc(
. adc_clk       (adc_clk    ) ,
. bram_clk      (bram_clk   ) ,
. bram_rst      (bram_rst   ) ,
. bram_en       (bram_en    ) ,
. bram_addr     (bram_addr  ) ,
. bram_we       (bram_we    ) ,
. bram_rddata   (bram_rddata) ,
. bram_wrdata   (bram_wrdata) 
);

endmodule
