
`include "configure.vh"
`timescale 1ns / 1ps
module complex_multi(
input               aclk                    ,
input               aresetn                 ,
input               s_axis_a_tvalid         ,
input               s_axis_a_tlast          ,    
input  [31 : 0]     s_axis_a_tdata          ,             
input               s_axis_b_tvalid         ,
input               s_axis_b_tlast          ,
input  [31 : 0]     s_axis_b_tdata          ,
output              m_axis_cmpy_dout_tvalid ,
output              m_axis_cmpy_dout_tlast  ,
output     [31:0]   m_axis_cmpy_dout_tdata  ,
output              err_flag
    );




wire            m_axis_dout_tvalid ;
wire            m_axis_dout_tlast  ;   
wire [79 : 0]   m_axis_dout_tdata  ;

assign m_axis_cmpy_dout_tvalid        = m_axis_dout_tvalid ;
assign m_axis_cmpy_dout_tlast         = m_axis_dout_tlast  ;


// assign m_axis_cmpy_dout_tdata[15:0]   = m_axis_dout_tdata[32:30] == 3'b001 || m_axis_dout_tdata[32:30] == 3'b110 ?  {m_axis_dout_tdata[32],m_axis_dout_tdata[30:16]} : {m_axis_dout_tdata[32],m_axis_dout_tdata[29:15]};
// assign m_axis_cmpy_dout_tdata[31:16]  = m_axis_dout_tdata[72:70] == 3'b001 || m_axis_dout_tdata[72:70] == 3'b110 ?  {m_axis_dout_tdata[72],m_axis_dout_tdata[70:56]} : {m_axis_dout_tdata[72],m_axis_dout_tdata[69:55]};

assign m_axis_cmpy_dout_tdata[15:0]   = ((m_axis_dout_tdata[32] == 0 && (|m_axis_dout_tdata[31:30])) || (m_axis_dout_tdata[32] == 1 
&& (~(&m_axis_dout_tdata[31:30])))) ?  {m_axis_dout_tdata[32],{15{~m_axis_dout_tdata[32]}}} : {m_axis_dout_tdata[32],m_axis_dout_tdata[29:15]};
assign m_axis_cmpy_dout_tdata[31:16]  = ((m_axis_dout_tdata[72] == 0 && (|m_axis_dout_tdata[71:70])) || (m_axis_dout_tdata[72] == 1 
&& (~(&m_axis_dout_tdata[71:70])))) ?  {m_axis_dout_tdata[72],{15{~m_axis_dout_tdata[72]}}} : {m_axis_dout_tdata[72],m_axis_dout_tdata[69:55]};

cmpy_0 u_cmpy_0 (
  .aclk                 (aclk               ),                              // input wire aclk
  .aresetn              (aresetn            ),                        // input wire aresetn
  .s_axis_a_tvalid      (s_axis_a_tvalid    ),        // input wire s_axis_a_tvalid
  .s_axis_a_tlast       (s_axis_a_tlast     ),          // input wire s_axis_a_tlast
  .s_axis_a_tdata       (s_axis_a_tdata     ),          // input wire [31 : 0] s_axis_a_tdata
  .s_axis_b_tvalid      (s_axis_b_tvalid    ),        // input wire s_axis_b_tvalid
  .s_axis_b_tlast       (s_axis_b_tlast     ),          // input wire s_axis_b_tlast
  .s_axis_b_tdata       (s_axis_b_tdata     ),          // input wire [31 : 0] s_axis_b_tdata
  .m_axis_dout_tvalid   (m_axis_dout_tvalid ),    // output wire m_axis_dout_tvalid
  .m_axis_dout_tlast    (m_axis_dout_tlast  ),    // output wire m_axis_dout_tlast
  .m_axis_dout_tdata    (m_axis_dout_tdata  )     // output wire [79 : 0] m_axis_dout_tdata
);

assign err_flag = m_axis_dout_tdata[32:31] == 2'b01 || m_axis_dout_tdata[32:31] == 2'b10 || m_axis_dout_tdata[72:71] == 2'b01 || m_axis_dout_tdata[72:71] == 2'b10;

wire overflow1,overflow2;

assign overflow1 = ((m_axis_dout_tdata[32] == 0 && (|m_axis_dout_tdata[31:30])) || (m_axis_dout_tdata[32] == 1 
&& (~(&m_axis_dout_tdata[31:30]))));

assign overflow2 = ((m_axis_dout_tdata[72] == 0 && (|m_axis_dout_tdata[71:70])) || (m_axis_dout_tdata[72] == 1 
&& (~(&m_axis_dout_tdata[71:70]))));

endmodule
