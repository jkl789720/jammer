`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/12/21 19:12:35
// Design Name: 
// Module Name: fifo_reset_delay
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


module fifo_reset_delay(
    input wr_clk,
    input rd_clk,
    input rst_in,
    input wr_rst_busyin,
	input rd_rst_busyin,
	
	output reg	rst_out,
    output reg	wr_rst_busyout,
	output reg	rd_rst_busyout
    );
reg  		rst_in_r2,rst_in_r3;
reg [15:0]	rst_in_r1;
reg [63:0]	wr_rst_busyin_r1;
reg [63:0]	rd_rst_busyin_r1;
always@(posedge wr_clk)begin
	rst_in_r2	<= rst_in;
	rst_in_r3	<= rst_in_r2;
	rst_in_r1 	<= {rst_in_r1[14:0],rst_in_r3};
	rst_out 	<= |rst_in_r1;
	
	wr_rst_busyin_r1 	<= {wr_rst_busyin_r1[62:0],wr_rst_busyin};
	wr_rst_busyout 		<= |wr_rst_busyin_r1;
end	

always@(posedge rd_clk)begin
	rd_rst_busyin_r1 	<= {rd_rst_busyin_r1[62:0],rd_rst_busyin};
	rd_rst_busyin_r1 		<= |rd_rst_busyin_r1;
end	
endmodule
