`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/05/26 16:24:06
// Design Name: 
// Module Name: status_reg
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// status_reg and reset
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module status_reg
#(
    parameter PREFIFO_DIN_WIDTH = 512,
    parameter POSTFIFO_DOUT_WIDTH = 512
)
(
//    input clk_w,
    input clk_r,
    input clk_prefifo,    
    input clk_postfifo,
    input clk_ddr_sys,   //ddr3_sys_clk
    input clk_w_ddr,    //ddr3_ui_clk
    input reset,
    input reset_ddr,   //只复位DDR3

// blk_mem_interface
     output clka,    // input wire clka
//      .ena(en_w),      // input wire ena
    output reg wea,      // input wire [0 : 0] wea
    output reg[1:0] addr_w,  // input wire [1 : 0] addra
    output reg[63:0] data_w,    // input wire [63 : 0] dina

    output clkb,    // input wire clkb
//      .enb(en_r),      // input wire enb
    output reg[1:0] addr_r,  // input wire [1 : 0] addrb
    input[63:0]    data_r,  // output wire [63 : 0] doutb

//in_data_axi_Stream
    
    input [ PREFIFO_DIN_WIDTH-1:0]s_axis_data_tdata,
    input s_axis_data_tvalid,
    output s_axis_data_tready,
    input s_axis_data_tlast,

//out_data_axi_Stream
    output [POSTFIFO_DOUT_WIDTH-1:0]m_axis_data_tdata,
    output  m_axis_data_tvalid,
    input m_axis_data_tready,
    output  m_axis_data_tlast,

    
//clk_reset_output
       
    output reg reset_deepfifo_syn,
    output reg reset_ddr_syn,
//    output reg reset_ddr_axi_syn,    
 //   output clk_ddr3sys_out,

//内部prefifo写端口
    output           clk_prefifo_out,
    output reg [PREFIFO_DIN_WIDTH -1:0]    pre_fifo_dout,
    output reg           pre_fifo_wn,
    input            pre_fifo_full,
    input [$clog2(2048*512/PREFIFO_DIN_WIDTH) -1 :0]      pre_fifo_data_count,
    output reg      reset_prefifo_syn,
    
//内部postfifo读端口
    
    output           clk_postfifo_out,
    input[POSTFIFO_DOUT_WIDTH -1:0]     post_fifo_din,
    output            post_fifo_rn,
    input           post_fifo_empty,
    output reg       reset_postfifo_syn,
    
//status reg
    output reg [31:0] status,
    output reg [31:0] max_depth,
    output reg [64:0] nonbypass_data,
    output reg [64:0] total_data,
    
//reg_data
    input postfifo_wn,
    input do_from_ram,
    input [31:0] bursts_stored,
    input DDR3_mmcm_locked,
    input DDR3_init_calib_complete
    );
    localparam WRFULL_THRESH = 2000;
    //reset reg    
    reg [15:0]	reset_prefifo_syn1;
    reg [15:0]	reset_postfifo_syn1;
    reg [15:0]	reset_deepfifo_syn1;
    reg 		reset_ddr_syn1;
    reg 		reset_r_syn,reset_r_syn1;
//    reg reset_ddr_axi_syn1;
    
    //读出控制
//    wire addr_r_wire[1:0];
    reg  pre_fifo_afull;
    
    //写入控制

     reg [31:0] status_in;
     reg [31:0] max_depth_in;
     reg [64:0] nonbypass_data_in;
     reg [64:0] total_data_in;
    
//    assign  addr_r_wire = addr_r;
    assign clk_prefifo_out = clk_prefifo;
    assign clk_postfifo_out = clk_postfifo;
    
    assign clka = clk_w_ddr;
    assign clkb = clk_r;
  //  assign clk_ddr3sys_out = clk_ddr_sys;
    
    
//out_m_axi
    assign m_axis_data_tdata = post_fifo_din;
    assign m_axis_data_tvalid = ~post_fifo_empty;
    assign post_fifo_rn = m_axis_data_tvalid & m_axis_data_tready;
    assign m_axis_data_tlast = 0;

//in_s_axi
    always@(posedge clk_prefifo)begin
        if(reset_prefifo_syn)pre_fifo_afull <= 0;
        else pre_fifo_afull <= (pre_fifo_data_count>WRFULL_THRESH);
    end
    always@(posedge clk_prefifo)begin
        if(reset_prefifo_syn)begin
            pre_fifo_wn <= 0;
            pre_fifo_dout <= 0;
        end
        else begin
            pre_fifo_wn <= s_axis_data_tvalid&s_axis_data_tready;
            pre_fifo_dout <= s_axis_data_tdata;
        end
    end
    assign s_axis_data_tready = ~pre_fifo_afull;
    

//  reset syn
always @(posedge clk_w_ddr )       
begin
   
     
     reset_deepfifo_syn1 <= {reset_deepfifo_syn1[14:0],reset};
     reset_deepfifo_syn <= |reset_deepfifo_syn1;
end 

always @(posedge clk_ddr_sys )       
begin
     reset_ddr_syn1 <= ~reset_ddr;
     reset_ddr_syn <=  reset_ddr_syn1; //MIG是低有效  
    
 //   reset_ddr_axi_syn1 <= reset; 
//    reset_ddr_axi_syn <=reset_ddr_axi_syn1;
end 

always @(posedge clk_prefifo )       
begin
     reset_prefifo_syn1 <= {reset_prefifo_syn1[14:0],reset};
     reset_prefifo_syn <= |reset_prefifo_syn1;
end 

always @(posedge clk_postfifo )       
begin
     reset_postfifo_syn1 <= {reset_postfifo_syn1[14:0],reset};
     reset_postfifo_syn <= |reset_postfifo_syn1;
end 

always @(posedge clk_r )       
begin
     reset_r_syn1 <= reset;
     reset_r_syn <= reset_r_syn1;
end 
 
//  输出寄存器轮询锁定
always @(posedge clk_r )       
begin
    if(reset_r_syn)
        begin
            addr_r <= 2'b00;
            status <= 'b0;
            max_depth <= 'b0;
            nonbypass_data <= 'b0;
            total_data <= 'b0;
        end
    else   
        begin
            addr_r <= addr_r + 1; 
            case(addr_r)
                2'b11:
                    status <= data_r;
                2'b00:
                    max_depth <= data_r;
                2'b01:
                    nonbypass_data <= data_r;
                2'b10:
                   total_data <= data_r;
            endcase
        end 
end


//  输入寄存器轮询锁定
    reg[1:0] addr_w_r1;
    reg wea_r1;
    reg[63:0] data_w_r1;
always @(posedge clk_w_ddr)  
begin
    data_w <= data_w_r1;
    wea <= wea_r1;
    addr_w <= addr_w_r1;
end


ila_deepfifo_sta ila_deepfifoep_sta0(
.clk(clk_w_ddr),
.probe0(max_depth_in),
.probe1(nonbypass_data_in),
//.probe2(post_fifo_full ),
.probe2(total_data_in )
);

always @(posedge clk_w_ddr )       
begin
    if(reset_deepfifo_syn)
        begin
            addr_w_r1 <= 2'b00;
     
            wea_r1 <= 'b0;
            data_w_r1 <= 'b0;
        end
    else   
        begin
            addr_w_r1 <= addr_w_r1 + 1; 
            wea_r1 <= 'b1;
            case(addr_w_r1)
                2'b00:
                    data_w_r1[31:0] <= status_in;
                2'b01:
                    data_w_r1[31:0] <= max_depth_in;
                2'b10:
                    data_w_r1 <= nonbypass_data_in;
                2'b11:
                    data_w_r1 <= total_data_in;
            endcase
            
        end 
end

always @(posedge clk_w_ddr )       
begin
    if(reset_deepfifo_syn)
        begin
          
            status_in <= 'b0;
            max_depth_in <= 'b0;
            nonbypass_data_in <= 'b0;
            total_data_in <= 'b0;
         
        end
    else   
        begin
            status_in[0] <= DDR3_mmcm_locked;
            status_in[1] <= DDR3_init_calib_complete;
           
		    status_in[31:8] <= bursts_stored;
            
            //if( max_depth_in[31:8] >= bursts_stored)
            //     max_depth_in[31:8] <=  max_depth_in;
            //else
            //     max_depth_in[31:8] <= bursts_stored;
                 
            if( max_depth_in[31:8] < bursts_stored)max_depth_in[31:8] <= bursts_stored;
            
            if(do_from_ram)
                 nonbypass_data_in <= nonbypass_data_in + 'h4000;
                 
            if(postfifo_wn)
                total_data_in <= total_data_in + 'h40;
        end 
end

endmodule
