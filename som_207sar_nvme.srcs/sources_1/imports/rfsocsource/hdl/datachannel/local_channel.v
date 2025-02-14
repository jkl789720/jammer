module local_channel
#(
parameter DIN_WIDTH = 64,
parameter DOUT_WIDTH = 512,
parameter AWIDTH = 36,
parameter LWIDTH = 8,
parameter DATA_SIZE = 6,
parameter CFG_AWIDTH = 36
)
(
input mem_clk,
input ad_mem_rst,
input da_mem_rst,

input [CFG_AWIDTH-1:0] tl_AD_base,
input [CFG_AWIDTH-1:0] tl_AD_rnum,
input tl_AD_repeat,
input tl_AD_reset,
output [31:0] tl_AD_status,

input [CFG_AWIDTH-1:0] tl_DA_base,
input [CFG_AWIDTH-1:0] tl_DA_rnum,
input tl_DA_repeat,
input tl_DA_reset,
output [31:0] tl_DA_status,


// control, must be in fifo_clk domain 
input adc_clk,
input adc_rst,
input dac_clk,
input dac_rst,

input mfifo_rd_clr,	// active high, only one cycle
input mfifo_rd_valid,
input mfifo_rd_enable,
output [DIN_WIDTH-1:0] mfifo_rd_data,
input mfifo_wr_clr,	// active high, only one cycle
input mfifo_wr_valid,
input mfifo_wr_enable,
input [DIN_WIDTH-1:0] mfifo_wr_data,

// axi4 read
input mem_init_done,

output 	 [AWIDTH-1 : 0] 	m_axi_araddr,
output 	 [LWIDTH-1 : 0] 	m_axi_arlen,
output 	 [2 : 0]        	m_axi_arsize,
output 	                	m_axi_arvalid,
input                     	m_axi_arready,
input  [DOUT_WIDTH-1 : 0]  	m_axi_rdata,
input  [1 : 0]            	m_axi_rresp,
input                     	m_axi_rlast,
input                     	m_axi_rvalid,
output 	                 	m_axi_rready,
output  [1 : 0]           	m_axi_arburst,
output  [2 : 0]           	m_axi_arprot,
output                    	m_axi_arlock,
output  [3 : 0]           	m_axi_arcache,
// axi4 write
output 	 [AWIDTH-1 : 0]		m_axi_awaddr,
output 	 [LWIDTH-1 : 0]		m_axi_awlen,
output 	 [2 : 0]          	m_axi_awsize,
output 	                  	m_axi_awvalid,
input  	                  	m_axi_awready,
output 	 [DOUT_WIDTH-1 : 0] m_axi_wdata,
output 	                  	m_axi_wlast,
output 	                  	m_axi_wvalid,
input                       m_axi_wready,
output                      m_axi_bready,
input  [1 : 0]              m_axi_bresp,
input                       m_axi_bvalid,

output [1 : 0]             	m_axi_awburst,
output [2 : 0]             	m_axi_awprot,
output                      m_axi_awlock,
output [3 : 0]             	m_axi_awcache,
output [DOUT_WIDTH/8-1 : 0]	m_axi_wstrb
);
mem2da 
#(
.DIN_WIDTH(DIN_WIDTH),
.DOUT_WIDTH(DOUT_WIDTH),
.AWIDTH(AWIDTH),
.LWIDTH(LWIDTH),
.DATA_SIZE(DATA_SIZE),
.CFG_AWIDTH(CFG_AWIDTH)
) mem2da_EP0(
.mem_clk(mem_clk),    //input 
.mem_rst(da_mem_rst),    //input 
.tl_DA_base(tl_DA_base),    //input [31:0]
.tl_DA_rnum(tl_DA_rnum),    //input [31:0]
.tl_DA_repeat(tl_DA_repeat),    //input 
.tl_DA_reset(tl_DA_reset),    //input 
.tl_DA_status(tl_DA_status),    //output 
.fifo_clk(dac_clk),    //input 
.fifo_rst(dac_rst),    //input 
.mfifo_rd_clr(mfifo_rd_clr),    //input 
.mfifo_rd_valid(mfifo_rd_valid),    //input 
.mfifo_rd_enable(mfifo_rd_enable),    //input 
.mfifo_rd_data(mfifo_rd_data),    //output [DIN_WIDTH-1:0]
.mem_init_done(mem_init_done),    //input 
.m_axi_araddr(m_axi_araddr),    //output [AWIDTH-1 : 0]
.m_axi_arlen(m_axi_arlen),    //output [LWIDTH-1 : 0]
.m_axi_arsize(m_axi_arsize),    //output [2 : 0]
.m_axi_arvalid(m_axi_arvalid),    //output 
.m_axi_arready(m_axi_arready),    //input 
.m_axi_rdata(m_axi_rdata),    //input [DOUT_WIDTH-1 : 0]
.m_axi_rresp(m_axi_rresp),    //input [1 : 0]
.m_axi_rlast(m_axi_rlast),    //input 
.m_axi_rvalid(m_axi_rvalid),    //input 
.m_axi_rready(m_axi_rready),    //output 
.m_axi_arburst(m_axi_arburst),    //output [1 : 0]
.m_axi_arprot(m_axi_arprot),    //output [2 : 0]
.m_axi_arlock(m_axi_arlock),    //output 
.m_axi_arcache(m_axi_arcache)    //output [3 : 0]
);
ad2mem 
#(
.DIN_WIDTH(DIN_WIDTH),
.DOUT_WIDTH(DOUT_WIDTH),
.AWIDTH(AWIDTH),
.LWIDTH(LWIDTH),
.DATA_SIZE(DATA_SIZE),
.CFG_AWIDTH(CFG_AWIDTH)
) ad2mem_EP0(
.mem_clk(mem_clk),    //input 
.mem_rst(ad_mem_rst),    //input 
.tl_AD_base(tl_AD_base),    //input [31:0]
.tl_AD_rnum(tl_AD_rnum),    //input [31:0]
.tl_AD_repeat(tl_AD_repeat),    //input 
.tl_AD_reset(tl_AD_reset),    //input 
.tl_AD_status(tl_AD_status),    //output 
.fifo_clk(adc_clk),    //input 
.fifo_rst(adc_rst),    //input 
.mfifo_wr_clr(mfifo_wr_clr),    //input 
.mfifo_wr_valid(mfifo_wr_valid),    //input 
.mfifo_wr_enable(mfifo_wr_enable),    //input 
.mfifo_wr_data(mfifo_wr_data),    //input [DIN_WIDTH-1:0]
.mem_init_done(mem_init_done),    //input 
.m_axi_awaddr(m_axi_awaddr),    //output [AWIDTH-1 : 0]
.m_axi_awlen(m_axi_awlen),    //output [LWIDTH-1 : 0]
.m_axi_awsize(m_axi_awsize),    //output [2 : 0]
.m_axi_awvalid(m_axi_awvalid),    //output 
.m_axi_awready(m_axi_awready),    //input 
.m_axi_wdata(m_axi_wdata),    //output [DOUT_WIDTH-1 : 0]
.m_axi_wlast(m_axi_wlast),    //output 
.m_axi_wvalid(m_axi_wvalid),    //output 
.m_axi_wready(m_axi_wready),    //input 
.m_axi_bready(m_axi_bready),    //output 
.m_axi_bresp(m_axi_bresp),    //input [1 : 0]
.m_axi_bvalid(m_axi_bvalid),    //input 
.m_axi_awburst(m_axi_awburst),    //output [1 : 0]
.m_axi_awprot(m_axi_awprot),    //output [2 : 0]
.m_axi_awlock(m_axi_awlock),    //output 
.m_axi_awcache(m_axi_awcache),    //output [3 : 0]
.m_axi_wstrb(m_axi_wstrb)    //output [DOUT_WIDTH/8-1 : 0]
);
endmodule
