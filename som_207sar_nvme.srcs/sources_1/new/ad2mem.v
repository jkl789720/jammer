
// July 19, 2018. 
// 1. When init_done_r1 asserted, go back to reset if in WAIT state. Fixing unexpected ending of timing_logic
// 2. Change To. m_axi_bready = 1;
// 3. Ignore rdfifo_empty in FINISH state

// May 16, 2018. First Version. Support both prf/frame format and continuous data.one fifo and one memory region. With 4KB boundary check.

`define OKAY 		2'b00
`define EXOKAY 		2'b01
`define SLVERR 		2'b10
`define DECERR 		2'b11
module ad2mem
#(
parameter DIN_WIDTH = 64,
parameter DOUT_WIDTH = 512,
parameter AWIDTH = 32,
parameter LWIDTH = 8,
parameter DATA_SIZE = 6,
parameter CFG_AWIDTH = 36
)(
input mem_clk,
input mem_rst,

input [CFG_AWIDTH-1:0] tl_AD_base,
input [CFG_AWIDTH-1:0] tl_AD_rnum,
input tl_AD_repeat,
input tl_AD_reset,
output [31:0] tl_AD_status,

// control, must be in fifo_clk domain 
input fifo_clk,
input fifo_rst,

input mfifo_wr_clr,	// active high, only one cycle
input mfifo_wr_valid,
input mfifo_wr_enable,
input [DIN_WIDTH-1:0] mfifo_wr_data,

// axi4 write
input mem_init_done,
output reg [AWIDTH-1 : 0]		m_axi_awaddr,
output reg [LWIDTH-1 : 0]		m_axi_awlen,
output reg [2 : 0]          	m_axi_awsize,
output reg                  	m_axi_awvalid,
input                       	m_axi_awready,
output     [DOUT_WIDTH-1 : 0]   m_axi_wdata,
output reg                  	m_axi_wlast,
output reg                  	m_axi_wvalid,
input                       	m_axi_wready,
output                      	m_axi_bready,
input  [1 : 0]              	m_axi_bresp,
input                       	m_axi_bvalid,

output [1 : 0]             		m_axi_awburst,
output [2 : 0]             		m_axi_awprot,
output                      	m_axi_awlock,
output [3 : 0]             		m_axi_awcache,
output [DOUT_WIDTH/8-1 : 0]		m_axi_wstrb
);
assign m_axi_awburst = 2'b01;     // INCR
assign m_axi_awprot = 3'b000;    // Unprivileged access, Non-secure access, Data access
assign m_axi_awcache = 4'b0011; // 0011 value recommended. Xilinx IP generally ignores (as slaves) or generates (as masters) transactions with Normal, Non-cacheable, Modifiable, and Bufferable
assign m_axi_awlock = 1'b0;     // Normal access
assign m_axi_wstrb = -1;        // All Byte Enable

// data fifo
localparam DATA_LEN = 32;
localparam PAGE_ALIGN_MASK = 12'h7FF;	// 64*32=2048
localparam BURST_NUM = 8;
localparam DEPTH_WIDTH = 9;
wire fifo_rd;
wire [DOUT_WIDTH-1:0] fifo_dout;
wire [DEPTH_WIDTH-1:0] rd_data_count;
reg fifo_prog_full;
always@(posedge mem_clk)begin
	if(mem_rst)fifo_prog_full <= 0;
	else fifo_prog_full <= (rd_data_count>=DATA_LEN);
end
wire wr_rst_busy;
wire rd_rst_busy;
wire fifo_empty;

generate
if(DIN_WIDTH==64)begin:blk1
ad2mem_dfifo ad2mem_dfifo_ep0(
.rst(mfifo_wr_clr), 
  
.wr_clk(fifo_clk),   
.wr_en(mfifo_wr_enable),    
.din(mfifo_wr_data),  
.wr_rst_busy(wr_rst_busy),
  
.rd_clk(mem_clk),   
.rd_en(fifo_rd),    
.dout(fifo_dout),
.rd_data_count(rd_data_count),
.empty(fifo_empty),
.rd_rst_busy(rd_rst_busy)
);
end
else if(DIN_WIDTH==128)begin
ad2mem_dfifox128 ad2mem_dfifo_ep0(
.rst(mfifo_wr_clr), 
  
.wr_clk(fifo_clk),   
.wr_en(mfifo_wr_enable),    
.din(mfifo_wr_data),  
.wr_rst_busy(wr_rst_busy),
  
.rd_clk(mem_clk),   
.rd_en(fifo_rd),    
.dout(fifo_dout),
.rd_data_count(rd_data_count),
.empty(fifo_empty),
.rd_rst_busy(rd_rst_busy)
);
end
else if(DIN_WIDTH==256)begin
ad2mem_dfifox256 ad2mem_dfifo_ep0(
.rst(mfifo_wr_clr), 
  
.wr_clk(fifo_clk),   
.wr_en(mfifo_wr_enable),    
.din(mfifo_wr_data),  
.wr_rst_busy(wr_rst_busy),
  
.rd_clk(mem_clk),   
.rd_en(fifo_rd),    
.dout(fifo_dout),
.rd_data_count(rd_data_count),
.empty(fifo_empty),
.rd_rst_busy(rd_rst_busy)
);
end
else begin
//ad2mem_dfifox32 x32 fifo not exist
ad2mem_dfifo ad2mem_dfifo_ep0(
.rst(mfifo_wr_clr), 
  
.wr_clk(fifo_clk),   
.wr_en(mfifo_wr_enable),    
.din(mfifo_wr_data),  
.wr_rst_busy(wr_rst_busy),
  
.rd_clk(mem_clk),   
.rd_en(fifo_rd),    
.dout(fifo_dout),
.rd_data_count(rd_data_count),
.empty(fifo_empty),
.rd_rst_busy(rd_rst_busy)
);
end
endgenerate

// data format
// MSB -> LSB by DIN_WIDTH
// -> 512bits: {Q31,... , Q24}, {Q23, ... , Q16}, {...}, {...}
// -> 512bits: {Q7,... , Q0}, {Q15, ... , Q8}, {...}, {...}
wire [DOUT_WIDTH-1:0] fifo_dout_reorder;
localparam REORDER_RATE = DOUT_WIDTH/DIN_WIDTH;
genvar kk;
generate
for(kk=0;kk<REORDER_RATE;kk=kk+1)begin:reorder_block
	assign
		fifo_dout_reorder[DIN_WIDTH*(REORDER_RATE-kk-1)+DIN_WIDTH-1:DIN_WIDTH*(REORDER_RATE-kk-1)] 
		= fifo_dout[DIN_WIDTH*kk+DIN_WIDTH-1:DIN_WIDTH*kk];
end
endgenerate

// ack fifo
reg rdfifo_srst;
reg [35:0] rdfifo_din;
reg rdfifo_wr_en;
wire rdfifo_rd_en;
wire [35:0] rdfifo_dout;
wire [6:0] rdfifo_data_count;
wire rdfifo_empty;
wire rdfifo_full;
ack_resp_fifo wrfifo (
.clk(mem_clk),                // input wire clk
.srst(rdfifo_srst),              // input wire srst
.din(rdfifo_din),                // input wire [31 : 0] din
.wr_en(rdfifo_wr_en),            // input wire wr_en
.rd_en(rdfifo_rd_en),            // input wire rd_en
.dout(rdfifo_dout),              // output wire [31 : 0] dout
.full(rdfifo_full),              // output wire full
.empty(rdfifo_empty),            // output wire empty
.data_count(rdfifo_data_count)  // output wire [7 : 0] data_count
);
assign rdfifo_rd_en = m_axi_bvalid&m_axi_bready;
//assign m_axi_bready = ~rdfifo_empty;  // why not change to 1 for more safty.
assign m_axi_bready = 1;

// state machine
parameter NON_RESP_CMD_COUNT = BURST_NUM-2;
reg init_done_r0;
reg init_done_r1;
always@(posedge mem_clk) begin
	if(mem_rst) begin
		init_done_r0 <= 0;
		init_done_r1 <= 0;
	end
	else begin
		init_done_r0 <= mem_init_done;
		init_done_r1 <= init_done_r0 & tl_AD_reset;
	end
end
reg writefifoen_r0;
reg writefifoen_r1;
reg [7:0] fifo_delay_cnt;	// delay cycles to make sure fifo is clean, in case of ongoing data at fifo's input
parameter DLYCYCLES_FOR_ONGOING_DATA = 32;
wire no_ongoing_data = (fifo_delay_cnt>DLYCYCLES_FOR_ONGOING_DATA);
always@(posedge mem_clk) begin
	if(mem_rst) begin
		writefifoen_r0 <= 0;
		writefifoen_r1 <= 0;
		fifo_delay_cnt <= 0;
	end
	else begin
		writefifoen_r0 <= mfifo_wr_valid;
		writefifoen_r1 <= writefifoen_r0;
		if(fifo_empty==0)fifo_delay_cnt <= 0;
		else if(~(&fifo_delay_cnt))fifo_delay_cnt <= fifo_delay_cnt + 1;
	end
end

localparam	
	IDLE   = 4'd0,
	RESET  = 4'd1,
	WAIT   = 4'h2,
	WRADDR = 4'h3,
	WRDATA = 4'h4,
	WRRESP = 4'h5,
	FINISH = 4'h6;
reg [3:0] cstate;
reg [3:0] nstate;
reg [3:0] cmd_cnt;
reg [CFG_AWIDTH-1:0] frame_cnt;
always@(*) begin
	nstate = IDLE;
	case(cstate)
	IDLE:begin
		if(init_done_r1)nstate = RESET;
		else nstate = IDLE;
	end
	RESET:begin
		if(cmd_cnt>0)nstate = RESET;
		else nstate = WAIT;
	end
	WAIT:begin
		if(init_done_r1)nstate = RESET;
		else if(frame_cnt==0)nstate = FINISH;
		else if(fifo_prog_full | ((~writefifoen_r1) & (~fifo_empty)))nstate = WRADDR;
		//else if(no_ongoing_data & (~writefifoen_r1))nstate = FINISH;
		else nstate = WAIT;
	end
	WRADDR:begin
		if(m_axi_awvalid&m_axi_awready)nstate = WRDATA;
		else nstate = WRADDR;
	end
	WRDATA:begin
		if(m_axi_wvalid&m_axi_wready&m_axi_wlast)nstate = WRRESP;
		else nstate = WRDATA;
	end
	WRRESP:begin
		if(rdfifo_data_count<NON_RESP_CMD_COUNT)begin
			if(fifo_prog_full)nstate = WRADDR;
			else nstate = WAIT;
		end
		else nstate = WRRESP;
	end
	FINISH:begin
		//if(rdfifo_empty)nstate = IDLE;
		//else nstate = FINISH;
		nstate = IDLE;
	end
	default:begin
		nstate = IDLE;
	end
	endcase
end

assign fifo_rd = m_axi_wvalid&m_axi_wready;
assign m_axi_wdata = fifo_dout_reorder;
reg fibre_done;
reg [CFG_AWIDTH-1:0] waddr;
reg [7:0] wrcnt;
always@(posedge mem_clk)begin
	if(mem_rst)begin
		cstate <= IDLE;
		rdfifo_srst <= 1;
		rdfifo_din <= 0;
		rdfifo_wr_en <= 0;		
		m_axi_awaddr <= 0;
		m_axi_awlen <= 0;
		m_axi_awsize <= 0;
		m_axi_awvalid <= 0;
		m_axi_wlast <= 0;
		m_axi_wvalid <= 0;
		cmd_cnt <= 0;
		waddr <= 0;
		wrcnt <= 0;
		fibre_done <= 1;
	end
	else begin
		cstate <= nstate;
		case(cstate)
		IDLE:begin
			m_axi_awaddr <= 0;
			m_axi_awlen <= 0;
			m_axi_awsize <= 0;
			m_axi_awvalid <= 0;
			m_axi_wlast <= 0;
			m_axi_wvalid <= 0;
			rdfifo_din <= 0;
			rdfifo_wr_en <= 0;
			if(init_done_r1)begin
				waddr <= tl_AD_base;
				frame_cnt <= tl_AD_rnum[CFG_AWIDTH-1:DATA_SIZE];
				rdfifo_srst <= 1;
				cmd_cnt <= 15;
				fibre_done <= 0;
			end
			else begin
				waddr <= 0;
				frame_cnt <= 'b0;
				rdfifo_srst <= 0;
				cmd_cnt <= 0;
				fibre_done <= 1;
			end
		end
		RESET:begin
			if(cmd_cnt>0)cmd_cnt <= cmd_cnt - 1;
			rdfifo_srst <= 0;
		end
		WAIT:begin
			m_axi_awaddr <= 0;
			m_axi_awlen <= 0;
			m_axi_awsize <= 0;
			m_axi_awvalid <= 0;
			m_axi_wlast <= 0;
			m_axi_wvalid <= 0;
			rdfifo_din <= 0;
			rdfifo_wr_en <= 0;
			wrcnt <= 0;
			if(init_done_r1)begin
				waddr <= tl_AD_base;
				frame_cnt <= tl_AD_rnum[CFG_AWIDTH-1:DATA_SIZE];
				rdfifo_srst <= 1;
				cmd_cnt <= 15;
				fibre_done <= 0;
			end
			else begin
				rdfifo_srst <= 0;
			end
		end
		WRADDR:begin
			rdfifo_srst <= 0;
			if(m_axi_awvalid&m_axi_awready)begin
				m_axi_awvalid <= 0;
				if(wrcnt>0)begin
					waddr <= waddr + (2**DATA_SIZE)*DATA_LEN;
					m_axi_wlast <= 0;
					if(frame_cnt>DATA_LEN)frame_cnt <= frame_cnt - DATA_LEN;
					else frame_cnt <= 0;
				end
				else begin
					waddr <= waddr + (2**DATA_SIZE)*1;
					m_axi_wlast <= 1;
					frame_cnt <= frame_cnt - 1;
				end
				m_axi_wvalid <= 1;
				rdfifo_din <= m_axi_awaddr;
				rdfifo_wr_en <= 1;
			end
			else begin
			    m_axi_awaddr <= waddr;
				if(fifo_prog_full && (waddr[11:0]&PAGE_ALIGN_MASK)==0)begin    // check 4KB boundary
					m_axi_awlen <= DATA_LEN-1;
					wrcnt <= DATA_LEN-1; 
				end
				else begin
					m_axi_awlen <= 0;
					wrcnt <= 0; 
				end
				m_axi_awsize <= DATA_SIZE;
				m_axi_awvalid <= 1;    
				rdfifo_wr_en <= 0;
			end
		end
		WRDATA:begin
			rdfifo_wr_en <= 0;
			if(m_axi_wvalid&m_axi_wready)begin
				if(~m_axi_wlast)begin
					if(wrcnt==1)m_axi_wlast <= 1;
					else m_axi_wlast <= 0;
					wrcnt <= wrcnt - 1;
					m_axi_wvalid <= 1;
				end
				else begin
					m_axi_wlast <= 0;
					m_axi_wvalid <= 0;    
				end
			end
		end
		WRRESP:begin
		end
		FINISH:begin
			fibre_done <= rdfifo_empty;
		end
		default:begin
		end
		endcase
	end
end
//---------------------- resp side ---------------------//
reg wr_fail;
always@(posedge mem_clk)begin
	if(mem_rst)begin
		wr_fail <= 0;
	end
	else begin
		if(rdfifo_srst)begin
			wr_fail <= 0;
		end
		else if(m_axi_bvalid&m_axi_bready)begin
			if(m_axi_bresp != `OKAY)wr_fail <= 1;
		end
	end
end
assign tl_AD_status[0] = fibre_done;
assign tl_AD_status[1] = wr_fail;
assign tl_AD_status[5:2] = cstate;
assign tl_AD_status[31:6] = 0;

endmodule
