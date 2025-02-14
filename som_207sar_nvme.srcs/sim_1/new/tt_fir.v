`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/09 18:50:25
// Design Name: 
// Module Name: tt_fir
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


module tt_fir;
reg aresetn;
reg aclk;
reg bclk;
reg s_axis_data_tvalid;
wire s_axis_data_tready;
wire [127:0]s_axis_data_tdata;
wire m_axis_data_tvalid;
wire [127:0]m_axis_data_tdata;

fir02N40 fir_ep (
.aresetn(aresetn),                        // input wire aresetn
.aclk(aclk),                              // input wire aclk
.s_axis_data_tvalid(s_axis_data_tvalid),  // input wire s_axis_data_tvalid
.s_axis_data_tready(s_axis_data_tready),  // output wire s_axis_data_tready
.s_axis_data_tdata(s_axis_data_tdata),    // input wire [127 : 0] s_axis_data_tdata
.m_axis_data_tvalid(m_axis_data_tvalid),  // output wire m_axis_data_tvalid
.m_axis_data_tdata(m_axis_data_tdata)    // output wire [127 : 0] m_axis_data_tdata
);

reg fifo1_rd_en = 0;
wire [15:0]fifo1_dout;
wire [11:0]fifo1_rd_data_count;
fifo128to16 fifo_ep0 (
.rst(~aresetn),                      // input wire rst
.wr_clk(aclk),                // input wire wr_clk
.rd_clk(bclk),                // input wire rd_clk
.din(s_axis_data_tdata),                      // input wire [127 : 0] din
.wr_en(s_axis_data_tvalid),                  // input wire wr_en

.rd_en(fifo1_rd_en),                  // input wire rd_en
.dout(fifo1_dout),                    // output wire [15 : 0] dout
.full(),                    // output wire full
.empty(),                  // output wire empty
.rd_data_count(fifo1_rd_data_count),  // output wire [11 : 0] rd_data_count
.wr_data_count(),  // output wire [8 : 0] wr_data_count
.wr_rst_busy(),      // output wire wr_rst_busy
.rd_rst_busy()      // output wire rd_rst_busy
);
reg fifo2_rd_en = 0;
wire [15:0]fifo2_dout;
wire [11:0]fifo2_rd_data_count;
wire [127:0]tdata_out;

fifo128to16 fifo_ep1 (
.rst(~aresetn),                      // input wire rst
.wr_clk(aclk),                // input wire wr_clk
.rd_clk(bclk),                // input wire rd_clk
.din(tdata_out),                      // input wire [127 : 0] din
.wr_en(m_axis_data_tvalid),                  // input wire wr_en

.rd_en(fifo2_rd_en),                  // input wire rd_en
.dout(fifo2_dout),                    // output wire [15 : 0] dout
.full(),                    // output wire full
.empty(),                  // output wire empty
.rd_data_count(fifo2_rd_data_count),  // output wire [11 : 0] rd_data_count
.wr_data_count(),  // output wire [8 : 0] wr_data_count
.wr_rst_busy(),      // output wire wr_rst_busy
.rd_rst_busy()      // output wire rd_rst_busy
);
always@(posedge bclk)begin
	if(fifo1_rd_data_count>16)fifo1_rd_en <= 1;
	if(fifo2_rd_data_count>16)fifo2_rd_en <= 1;
end

always begin
	aclk = 0;
	#8;
	aclk = 1;
	#8;
end
always begin
	bclk = 0;
	#1;
	bclk = 1;
	#1;
end
localparam step = 500;
reg signed [15:0] count;
genvar kk;
generate
for(kk=0;kk<8;kk=kk+1)begin:blk
	assign s_axis_data_tdata[kk*16+15:kk*16] = count + step*(7-kk);
	assign tdata_out[kk*16+15:kk*16] = m_axis_data_tdata[(7-kk)*16+15:(7-kk)*16];
end
endgenerate
initial begin
	aresetn = 0;
	s_axis_data_tvalid = 0;
	count = 0;
	#1000;
	aresetn = 1;
	#1000;
	repeat(1000)begin
		@(posedge aclk);
		s_axis_data_tvalid = 1;
		count = count + step*8;
		if(count>=32000)count = -32000;
	end
	#1000;
	$stop;

end
endmodule
