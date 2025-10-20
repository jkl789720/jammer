`timescale 1ns / 1ps
module data_delay#(
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
input [255:0]           data_in         ,
input                   data_valid      ,
input [7:0]             delay_cycle     ,
output reg [255:0]      data_out        ,
output                  data_out_valid  
    );

//整数部分
wire [255:0] data_delay_int;
reg [255:0] data_delay_int_r;

wire [4:0] delay_cycle_int;
assign delay_cycle_int = delay_cycle[7:3] - 1;


// // 1
// reg [255 : 0] data_shift [31:0];
// reg data_valid_shift [31:0];
// genvar kk;
// generate
//     for(kk = 0; kk < 32;kk = kk + 1)begin:blk
//         if(kk == 0)begin
//             always @(posedge adc_clk) begin
//                 if(!resetn)begin
//                     data_shift[kk] <= 0;
//                     data_valid_shift[kk] <= 0;
//                 end
//                 else begin
//                     data_shift[kk] <= data_in;
//                     data_valid_shift[kk] <= data_valid;
//                 end
//             end 
//         end
//         else begin
//             always @(posedge adc_clk) begin
//                 if(!resetn)begin
//                     data_shift[kk] <= 0;
//                     data_valid_shift[kk] <= 0;
//                 end
//                 else begin
//                     data_shift[kk] <= data_shift[kk - 1];
//                     data_valid_shift[kk] <= data_valid_shift[kk - 1];
//                 end
//             end 
//         end
//     end
// endgenerate

// assign data_delay_int = (delay_cycle[7:3] == 0)? data_in    : data_shift[delay_cycle_int]         ;
// assign data_out_valid = (delay_cycle[7:3] == 0)? data_valid : data_valid_shift[delay_cycle_int]   ;

//2
wire [255:0] data_delay_int_temp;
wire data_valid_r;
shift_delay_data u_shift_delay_data (
  .A    (delay_cycle_int    ), 
  .D    (data_in            ), 
  .CLK  (adc_clk            ), 
  .Q    (data_delay_int_temp     )  
);

shift_delay_valid u_shift_delay_valid (
  .A        (delay_cycle_int    ),  
  .D        (data_valid         ),  
  .CLK      (adc_clk            ),  
  .Q        (data_valid_r       )   
);

assign data_delay_int = (delay_cycle[7:3] == 0)? data_in    : data_delay_int_temp   ;
assign data_out_valid = (delay_cycle[7:3] == 0)? data_valid : data_valid_r          ;

//小数部分

always@(posedge adc_clk)begin
    if(!resetn)
        data_delay_int_r <= 0;
    else
        data_delay_int_r <= data_delay_int;
end

reg [31:0] cnt_delay;
always@(posedge adc_clk)begin
    if(!resetn)
        cnt_delay <= 0;
    else if(data_valid)
        cnt_delay <= cnt_delay + 1;
    else 
        cnt_delay <= 0;
end

always@(*)begin
    if(!resetn)
        data_out = 0;
    else 
        case (delay_cycle[2:0])
            0: begin
                if(cnt_delay < delay_cycle[7:3])
                    data_out = 0;
                else
                    data_out = data_delay_int;
            end    
            1 :begin
                if(cnt_delay < delay_cycle[7:3])
                    data_out = 0;
                else if(cnt_delay == delay_cycle[7:3])
                    data_out = {data_delay_int[(7*32)-1:0],32'b0};
                else
                    data_out = {data_delay_int[(7*32)-1:0],data_delay_int_r[8*32-1:7*32]};
            end
            2 :begin
                if(cnt_delay < delay_cycle[7:3])
                    data_out = 0;
                else if(cnt_delay == delay_cycle[7:3])
                    data_out = {data_delay_int[(6*32)-1:0],64'b0};
                else
                    data_out = {data_delay_int[(6*32)-1:0],data_delay_int_r[8*32-1:6*32]};
            end
            3 :begin
                if(cnt_delay < delay_cycle[7:3])
                    data_out = 0;
                else if(cnt_delay == delay_cycle[7:3])
                    data_out = {data_delay_int[(5*32)-1:0],96'b0};
                else
                    data_out = {data_delay_int[(5*32)-1:0],data_delay_int_r[8*32-1:5*32]};
            end
            4 :begin
                if(cnt_delay < delay_cycle[7:3])
                    data_out = 0;
                else if(cnt_delay == delay_cycle[7:3])
                    data_out = {data_delay_int[(4*32)-1:0],128'b0};
                else
                    data_out = {data_delay_int[(4*32)-1:0],data_delay_int_r[8*32-1:4*32]};
            end
            5 :begin
                if(cnt_delay < delay_cycle[7:3])
                    data_out = 0;
                else if(cnt_delay == delay_cycle[7:3])
                    data_out = {data_delay_int[(3*32)-1:0],160'b0};
                else
                    data_out = {data_delay_int[(3*32)-1:0],data_delay_int_r[8*32-1:3*32]};
            end
            6 :begin
                if(cnt_delay < delay_cycle[7:3])
                    data_out = 0;
                else if(cnt_delay == delay_cycle[7:3])
                    data_out = {data_delay_int[(2*32)-1:0],192'b0};
                else
                    data_out = {data_delay_int[(2*32)-1:0],data_delay_int_r[8*32-1:2*32]};
            end
            7 :begin
                if(cnt_delay < delay_cycle[7:3])
                    data_out = 0;
                else if(cnt_delay == delay_cycle[7:3])
                    data_out = {data_delay_int[(1*32)-1:0],224'b0};
                else
                    data_out = {data_delay_int[(1*32)-1:0],data_delay_int_r[8*32-1:1*32]};
            end
        endcase
    
end

// assign data_out_valid = data_valid;

endmodule
