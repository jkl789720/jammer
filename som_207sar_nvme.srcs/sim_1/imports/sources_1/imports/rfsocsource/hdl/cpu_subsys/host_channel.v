module host_channel
#(
parameter DIN_WIDTH = 256,
parameter DOUT_WIDTH = 128,
parameter AWIDTH = 32,
parameter LWIDTH = 8,
parameter DATA_SIZE = 4,
parameter BLKRAM_WIDTH = DOUT_WIDTH
)
(

input app_clk,
input app_rst,
// app
input [AWIDTH-1:0] cfg_H2D_addr_dma,
input [AWIDTH-1:0] cfg_H2D_size_dma,
input [31:0] cfg_H2D_burst_len, // must check following by driver, assume maximum burst length is 32
input [31:0] cfg_H2D_frame_len, // must be N x BurstSize x BurstLen
input [31:0] cfg_H2D_trans_len, // must be N x BurstSize x BurstLen
input [31:0] cfg_H2D_axi_ctrl,
output [31:0] cfg_H2D_axi_status,

input [AWIDTH-1:0] cfg_D2H_addr_dma,
input [AWIDTH-1:0] cfg_D2H_addr_sym,
input [AWIDTH-1:0] cfg_D2H_size_dma,
input [AWIDTH-1:0] cfg_D2H_size_sym,
input [31:0] cfg_D2H_burst_len, // must check following by driver
input [31:0] cfg_D2H_frame_len, // must be N x BurstSize x BurstLen
input [31:0] cfg_D2H_trans_len, // must be N x BurstSize x BurstLen
input [31:0] cfg_D2H_axi_ctrl,
output [31:0] cfg_D2H_axi_status,
input [31:0] cfg_D2H_ptr_sym,   // max value is cfg_D2H_size_sym

// control, must be in fifo_clk domain 
input adc_clk,
input adc_rst,
input [DIN_WIDTH-1:0]s_axis_data_tdata,
input s_axis_data_tvalid,
output s_axis_data_tready,
input s_axis_data_tlast,

input dac_clk,
input dac_rst,
output [DIN_WIDTH-1:0]m_axis_data_tdata,
output m_axis_data_tvalid,
input m_axis_data_tready,
output m_axis_data_tlast,

output cfg_axi_deepfifo_reset,

input mem_clk,
input mem_rst,
// better if in mem_clk domain
input [255:0] dac_aux_status,
input [255:0] adc_aux_status,
output ram_enb,
output [BLKRAM_WIDTH/8-1:0] ram_we,
output [31:0] ram_addr,
output [BLKRAM_WIDTH-1:0] ram_din,
input [BLKRAM_WIDTH-1:0] ram_dout,

// axi4 read
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

wire cfg_H2D_axi_active;
wire cfg_H2D_axi_repeat;
wire cfg_H2D_axi_bypass;
wire cfg_H2D_trans_underflow;
wire cfg_H2D_resp_error;
wire [15:0] cfg_H2D_trans_maxdly;
wire [15:0] cfg_H2D_trans_errcnt;
assign cfg_H2D_axi_active = cfg_H2D_axi_ctrl[0];
assign cfg_H2D_axi_repeat = cfg_H2D_axi_ctrl[1];
assign cfg_H2D_axi_bypass = cfg_H2D_axi_ctrl[2];
assign cfg_H2D_axi_status[0] = cfg_H2D_trans_underflow;
assign cfg_H2D_axi_status[1] = cfg_H2D_resp_error;
assign cfg_H2D_axi_status[15:4] = cfg_H2D_trans_errcnt[11:0];
assign cfg_H2D_axi_status[31:16] = cfg_H2D_trans_maxdly;

wire cfg_D2H_axi_active; 
wire cfg_D2H_axi_repeat;
wire cfg_D2H_trans_overflow;
wire cfg_D2H_resp_error;
wire cfg_D2H_axi_bypass;
wire [15:0] cfg_D2H_trans_maxdly;
wire [15:0] cfg_D2H_trans_errcnt;
assign cfg_D2H_axi_active = cfg_D2H_axi_ctrl[0];
assign cfg_D2H_axi_repeat = cfg_D2H_axi_ctrl[1];
assign cfg_D2H_axi_bypass = cfg_D2H_axi_ctrl[2];
assign cfg_D2H_axi_status[0] = cfg_D2H_trans_overflow;
assign cfg_D2H_axi_status[1] = cfg_D2H_resp_error;
assign cfg_D2H_axi_status[15:4] = cfg_D2H_trans_errcnt[15:4];
assign cfg_D2H_axi_status[31:16] = cfg_D2H_trans_maxdly;


host2axis_v0 #(
.DIN_WIDTH(DIN_WIDTH),
.DOUT_WIDTH(DOUT_WIDTH),
.AWIDTH(AWIDTH),
.LWIDTH(LWIDTH),
.DATA_SIZE(DATA_SIZE)
)
axi2fifo_v1_EP0(
.mem_clk(mem_clk),    //input 
.mem_rst(mem_rst),    //input 
.cfg_addr_dma(cfg_H2D_addr_dma),    //input [AWIDTH-1:0]
.cfg_size_dma(cfg_H2D_size_dma),    //input [AWIDTH-1:0]
.cfg_burst_len(cfg_H2D_burst_len),    //input [31:0]
.cfg_frame_len(cfg_H2D_frame_len),    //input [31:0]
.cfg_trans_len(cfg_H2D_trans_len),    //input [31:0]
.cfg_axi_active(cfg_H2D_axi_active),    //input 
.cfg_axi_repeat(cfg_H2D_axi_repeat),    //input 
.cfg_axi_bypass(cfg_H2D_axi_bypass),    //input 
.cfg_trans_underflow(cfg_H2D_trans_underflow),    //output 
.cfg_resp_error(cfg_H2D_resp_error),    //output 
.cfg_trans_errcnt(cfg_H2D_trans_errcnt),    //output 
.cfg_trans_maxdly(cfg_H2D_trans_maxdly),    //output 

.fifo_clk(dac_clk),    //input 
.fifo_rst(dac_rst),    //input 
.m_axis_data_tdata(m_axis_data_tdata),    //output [DIN_WIDTH-1:0]
.m_axis_data_tvalid(m_axis_data_tvalid),    //output 
.m_axis_data_tready(m_axis_data_tready),    //input 
.m_axis_data_tlast(m_axis_data_tlast),    //output 
.aux_status(dac_aux_status),

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
.m_axi_arcache(m_axi_arcache),    //output [3 : 0]
.ram_enb(ram_enb),    //output 
.ram_we(ram_we),    //output [3:0]
.ram_addr(ram_addr),    //output [31:0]
.ram_din(ram_din),    //output [31:0]
.ram_dout(ram_dout)    //input [31:0]
);

wire [31:0] cfg_ptr_sym;
dat_cross_clock_wrap 
#(.WIDTH(32))
dat_cross_clock_wrap_EP0(
.reset(app_rst),    //input 
.src_clk(app_clk),    //input 
.src_dat(cfg_D2H_ptr_sym),    //input [WIDTH-1:0]
.dst_clk(mem_clk),    //input 
.dst_dat(cfg_ptr_sym)    //output [WIDTH-1:0]
);

axis2host_v0 #(
.DIN_WIDTH(DIN_WIDTH),
.DOUT_WIDTH(DOUT_WIDTH),
.AWIDTH(AWIDTH),
.LWIDTH(LWIDTH),
.DATA_SIZE(DATA_SIZE)
) fifo2axi_v1_EP0(
.mem_clk(mem_clk),    //input 
.mem_rst(mem_rst),    //input 
.cfg_addr_dma(cfg_D2H_addr_dma),    //input [AWIDTH-1:0]
.cfg_addr_sym(cfg_D2H_addr_sym),    //input [AWIDTH-1:0]
.cfg_size_dma(cfg_D2H_size_dma),    //input [AWIDTH-1:0]
.cfg_size_sym(cfg_D2H_size_sym),    //input [AWIDTH-1:0]
.cfg_burst_len(cfg_D2H_burst_len),    //input [31:0]
.cfg_frame_len(cfg_D2H_frame_len),    //input [31:0]
.cfg_trans_len(cfg_D2H_trans_len),    //input [31:0]
.cfg_axi_active(cfg_D2H_axi_active),    //input 
.cfg_axi_repeat(cfg_D2H_axi_repeat),    //input 
.cfg_trans_overflow(cfg_D2H_trans_overflow),    //output 
.cfg_resp_error(cfg_D2H_resp_error),    //output 
.cfg_trans_errcnt(cfg_D2H_trans_errcnt),    //output 
.cfg_trans_maxdly(cfg_D2H_trans_maxdly),    //output 
.cfg_ptr_sym(cfg_ptr_sym),    //input [31:0]
.cfg_axi_deepfifo_reset(cfg_axi_deepfifo_reset),
.fifo_clk(adc_clk),    //input 
.fifo_rst(adc_rst),    //input 
.s_axis_data_tdata(s_axis_data_tdata),    //input [DIN_WIDTH-1:0]
.s_axis_data_tvalid(s_axis_data_tvalid),    //input 
.s_axis_data_tready(s_axis_data_tready),    //output 
.s_axis_data_tlast(s_axis_data_tlast),    //input 
.aux_status(adc_aux_status),
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