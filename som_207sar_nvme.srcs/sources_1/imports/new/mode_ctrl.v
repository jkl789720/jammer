`include "configure.vh"
`timescale 1ns / 1ps
module mode_ctrl(
input           adc_clk        ,
input           resetn         ,
input  [31:0]   mode_value     ,
output reg      disturb_en     ,
output reg      detection_en
    );

always@(posedge adc_clk)begin
    if(!resetn)begin
        disturb_en   <= 0;
        detection_en <= 0;
    end
    else begin
        case (mode_value)
            0:begin
                disturb_en   <= 0;
                detection_en <= 0;
            end 
            1:begin
                disturb_en   <= 0;
                detection_en <= 1;
            end  
            2:begin
                disturb_en   <= 1;
                detection_en <= 0;
            end  
            default:begin
                disturb_en   <= 0;
                detection_en <= 0;
            end  
        endcase
    end

end
endmodule
