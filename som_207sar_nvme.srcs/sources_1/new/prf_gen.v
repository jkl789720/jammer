`timescale 1ns / 1ps
module prf_gen(
input                   adc_clk     ,
input                   resetn      ,
input      [31:0]       prf_period  ,
input      [31:0]       mode_value  ,
input                   trig_valid  ,
output                  prf         
    );

reg [31:0] cnt_prf1;
reg [31:0] cnt_prf2;
wire prf1;
wire prf2;
always@(posedge adc_clk)begin
    if(!resetn)
        cnt_prf1 <= 0;
    else if(mode_value == 1)begin
        if((cnt_prf1 == prf_period - 1) || trig_valid)
            cnt_prf1 <= 0;
        else
            cnt_prf1 <= cnt_prf1 + 1;
    end
    else
        cnt_prf1 <= 0;
end

assign prf1 = cnt_prf1 < (prf_period >> 1) - 1;

always@(posedge adc_clk)begin
    if(!resetn)
        cnt_prf2 <= 0;
    else if(mode_value == 1)begin
        if(cnt_prf2 == prf_period - 1)
            cnt_prf2 <= 0;
        else
            cnt_prf2 <= cnt_prf2 + 1;
    end
    else
        cnt_prf2 <= 0;
end

assign prf2 = cnt_prf2 < (prf_period >> 1) - 1;

assign prf = mode_value == 1 ? prf1 : mode_value == 2 && prf2;

endmodule
