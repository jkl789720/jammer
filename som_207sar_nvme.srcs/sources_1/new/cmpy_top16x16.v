`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/06/16 10:55:57
// Design Name: 
// Module Name: cmpy_top16x16
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module cmpy_top16x16(
input 				aclk,
input 				s_axis_a_tvalid,
input [31:0]		s_axis_a_tdata,
input 				s_axis_b_tvalid,
input [31:0]		s_axis_b_tdata,
output		   		m_axis_dout_tvalid,
output reg [31:0]	m_axis_dout_tdata
    );
wire [31:0] outcr;
wire [35:0] outcr_r1;
assign outcr_r1 = {outcr[31:16],2'b00,outcr[15:0],2'b00};
cmpy16x16 ep0 (
  .aclk(aclk),                              // input wire aclk
  .s_axis_a_tvalid(s_axis_a_tvalid),        // input wire s_axis_a_tvalid
  .s_axis_a_tdata(s_axis_a_tdata),          // input wire [31 : 0] s_axis_a_tdata
  .s_axis_b_tvalid(s_axis_b_tvalid),        // input wire s_axis_b_tvalid
  .s_axis_b_tdata(s_axis_b_tdata),          // input wire [31 : 0] s_axis_b_tdata
  .m_axis_dout_tvalid(),  // output wire m_axis_dout_tvalid
  .m_axis_dout_tdata(outcr)    // output wire [31 : 0] 
);
genvar kk;
generate
for(kk=0;kk<2;kk=kk+1)begin
	always@(posedge aclk)begin
		if(outcr_r1[18*kk+17:18*kk+15]==3'b000||outcr_r1[18*kk+17:18*kk+15]==3'b111)m_axis_dout_tdata[16*kk+15:16*kk+0]<={outcr_r1[18*kk+17],outcr_r1[18*kk+14:18*kk+0]};
		else begin
			if(outcr_r1[18*kk+17])m_axis_dout_tdata[16*kk+15:16*kk+0]<={outcr_r1[18*kk+17],15'h0000};
			else m_axis_dout_tdata[16*kk+15:16*kk+0]<={outcr_r1[18*kk+17],15'h7FFF};
		end
	end
end
endgenerate	
endmodule
