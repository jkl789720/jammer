module adc2axis
#(
    parameter DWIDTH = 128,
    parameter KWIDTH = DWIDTH/8
)
(
input           		adc_clk,
input [DWIDTH-1:0]    	adc_data,
input           		adc_valid,
output reg				adc_ready,
input           		adc_last,
		
input           		m_axis_aclk,
input           		m_axis_reset,
input [31:0]    		m_axis_frmlen,
output [31:0]    		m_axis_lastlen,
output [31:0]    		m_axis_recvcnt,
output reg				m_axis_alert,
output reg				m_axis_cmpl,

output          		m_axis_tvalid,
input           		m_axis_tready,
output [DWIDTH-1 : 0] 	m_axis_tdata,
output [KWIDTH-1 : 0]  	m_axis_tkeep,
output          		m_axis_tlast
);

reg [DWIDTH:0] fifo_din;
reg fifo_wr_en;
reg fifo_reset;
wire [DWIDTH:0] fifo_dout;
wire fifo_rd_en;
wire fifo_full;
wire fifo_empty;
wire [10:0] wr_data_count;
wire [10:0] rd_data_count;
wire wr_rst_busy;
wire rd_rst_busy;
fifo_w136xd1024 fifo_ep (
  .rst(fifo_reset),        // input wire rst
  .wr_clk(adc_clk),  // input wire wr_clk
  .din(fifo_din),        // input wire [135 : 0] din
  .wr_en(fifo_wr_en),    // input wire wr_en
  .wr_data_count(wr_data_count),
  .wr_rst_busy(wr_rst_busy),
  
  .rd_clk(m_axis_aclk),  // input wire rd_clk
  .rd_en(fifo_rd_en),    // input wire rd_en
  .dout(fifo_dout),      // output wire [135 : 0] dout
  .rd_data_count(rd_data_count),
  .rd_rst_busy(rd_rst_busy),
  
  .full(fifo_full),      // output wire full
  .empty(fifo_empty)    // output wire empty
);

// write side
localparam FIFO_AFULL_THRESH = 1000;
reg adc_rst;
always@(posedge adc_clk)adc_rst <= m_axis_reset;
always@(posedge adc_clk)begin
    if(adc_rst)begin
        fifo_wr_en <= 0;
        fifo_din <= 0;
		adc_ready <= 0;
		m_axis_alert <= 0;
    end
    else begin
        fifo_din <= {adc_last, adc_data};
        fifo_wr_en <= adc_valid;// & adc_ready;
		adc_ready <= (~wr_rst_busy) & (wr_data_count<FIFO_AFULL_THRESH);
		if(fifo_full&fifo_wr_en)m_axis_alert <= 1;
    end
end

// read side
wire [DWIDTH-1:0] tdata;
wire tvalid;
wire tlast;
wire tready;
wire [KWIDTH-1:0] tkeep;
assign tkeep = {KWIDTH{1'b1}};

reg [31:0] tcnt;
reg [31:0] tlen;
assign fifo_rd_en = tvalid & tready;
assign tdata = fifo_dout[DWIDTH-1:0];
assign tvalid = (~fifo_empty) & (~rd_rst_busy);
assign tlast = (tcnt==tlen) | fifo_dout[DWIDTH];

always@(posedge m_axis_aclk)fifo_reset <= m_axis_reset;
always@(posedge m_axis_aclk)tlen <= m_axis_frmlen[31:4]-1;
always@(posedge m_axis_aclk)begin
    if(m_axis_reset)begin
        tcnt <= 0;
    end
    else begin
        if(tvalid&tready)begin
            if(tcnt==tlen)tcnt <= 0;
            else tcnt <= tcnt + 1;
        end
    end
end
reg [31:0] lastlen;
reg [31:0] lastcount;
reg [31:0] recvcount;
assign m_axis_lastlen = lastlen;
assign m_axis_recvcnt = recvcount;
always@(posedge m_axis_aclk)begin
    if(m_axis_reset)begin
        lastlen <= 0;
        lastcount <= 0;
		m_axis_cmpl <= 0;
		recvcount <= 0;
    end
	else begin
		if(m_axis_tvalid&m_axis_tready)begin
			if(m_axis_tlast)begin
				lastcount <= 0;
				lastlen <= lastcount + 1;
				recvcount <= recvcount + 1;
			end
			else lastcount <= lastcount + 1;
		end
		
		if(fifo_rd_en&fifo_dout[DWIDTH])m_axis_cmpl <= 1;
	end
end
    
// retiming
axisx128_register slice_0 (
  .aclk(m_axis_aclk),                    // input wire aclk
  .aresetn(~fifo_reset),              // input wire aresetn
  .s_axis_tvalid(tvalid),  // input wire s_axis_tvalid
  .s_axis_tready(tready),  // output wire s_axis_tready
  .s_axis_tdata (tdata),    // input wire [31 : 0] s_axis_tdata
  .s_axis_tkeep (tkeep),    // input wire [3 : 0] s_axis_tkeep
  .s_axis_tlast (tlast),    // input wire s_axis_tlast
  .m_axis_tvalid(m_axis_tvalid),  // output wire m_axis_tvalid
  .m_axis_tready(m_axis_tready),  // input wire m_axis_tready
  .m_axis_tdata(m_axis_tdata),    // output wire [31 : 0] m_axis_tdata
  .m_axis_tkeep(m_axis_tkeep),    // output wire [3 : 0] m_axis_tkeep
  .m_axis_tlast(m_axis_tlast)    // output wire m_axis_tlast
);
`ifndef BYPASS_ALLSCOPE
ila_adc2axis ila_adc2axis_ep0(
.clk(m_axis_aclk),
.probe0(fifo_reset),
.probe1(tlen ),
.probe2(m_axis_tvalid ),
.probe3(m_axis_tready ),
.probe4(m_axis_tdata),
.probe5(m_axis_tkeep), //cfg_trans_len  ),
.probe6(m_axis_tlast),
.probe7(tcnt),
.probe8(rd_rst_busy),
.probe9(wr_rst_busy),
.probe10(wr_data_count)
);
`endif
endmodule
