`timescale 1ns / 1ps
module rf_mode(
input       adc_clk     ,
input       resetn      ,

input       rf_tx_en    ,
input       channel_sel ,  
output reg  rf_tx_en_h  ,
output reg  rf_tx_en_v 
    );

//这个模块放到dac_data_pre里面

always@(posedge adc_clk)begin
    if(!resetn)begin
        rf_tx_en_h <= 0;
        rf_tx_en_v <= 0;
    end
    else begin
        if(channel_sel)begin
            rf_tx_en_h <= 0;
            rf_tx_en_v <= rf_tx_en;
        end
        else begin
            rf_tx_en_h <= rf_tx_en;
            rf_tx_en_v <= 0;
        end
    end
end



endmodule
