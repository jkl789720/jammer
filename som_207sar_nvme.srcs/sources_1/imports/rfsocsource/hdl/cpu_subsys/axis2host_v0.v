// AUg 17, 2020. change fifo_clr_r1 to (~cfg_axi_active_r2); Fix bug in repeat data acquization.
// Apr 28, 2020. Add support for DOUT_WIDTH 512. Add rec512_xxx fifo, modify rd_data_count.
// Jan 2, 2020. Add DIN_WIDTH support for 256. New fifo IP was added.
// May 9, 2019. change IP config of rec_fifox32. Reset state of full is 0, or cfg_trans_overflow will always be high
// Mar 1, 2019. Add fifo_prerd <= 0; in IDLE&WAIT state
// Feb 20, 2019. Add  | (~cfg_axi_active_r2) to reset data_recovery
// Feb 13, 2019. Add line to fix burst==1 bug
// Feb 13, 2019. Change awcache to constant 0011 according to UG1037. Xilinx IP generally ignores (as slaves) or generates (as masters) transactions with Normal, Non-cacheable, Modifiable, and Bufferable.
// Jan 24, 2019. Modify fifo_clr_r1 logic to enable spurious from PR region
// Nov 30, 2018. Change FIFO to more accurate data count set and increase wr/rd_data_count width
// Nov 28, 2018. Add support for non-burst length; Add cfg_ptr_sym for software to limit the data throughput
// Feb 11, 2018. Change to one fifo and one memory region. No 4KB boundary check.
// Feb 10, 2018. First Version. Support both prf/frame format and continuous data.
`define OKAY 		2'b00
`define EXOKAY 		2'b01
`define SLVERR 		2'b10
`define DECERR 		2'b11
`define BYPASS_DATACORRECT
module axis2host_v0
#(
parameter DIN_WIDTH = 64,
parameter DOUT_WIDTH = 128,
parameter AWIDTH = 32,
parameter LWIDTH = 8,
parameter DATA_SIZE = 4,
parameter LAST_CNT_BIT = DATA_SIZE
)
(
input mem_clk,
input mem_rst,

// app
input [AWIDTH-1:0] cfg_addr_dma,
input [AWIDTH-1:0] cfg_addr_sym,
input [AWIDTH-1:0] cfg_size_dma,
input [AWIDTH-1:0] cfg_size_sym,
input [31:0] cfg_burst_len, // must check following by driver
input [31:0] cfg_frame_len, // must be N x BurstSize x BurstLen
input [31:0] cfg_trans_len, // must be N x BurstSize x BurstLen
input cfg_axi_active, 
input cfg_axi_repeat,
output cfg_trans_overflow,
output cfg_resp_error,
output [15:0] cfg_trans_maxdly,
output [15:0] cfg_trans_errcnt,

// control, must be in fifo_clk domain 
input fifo_clk,
input fifo_rst,

//reset deepfifo
output cfg_axi_deepfifo_reset,

input [DIN_WIDTH-1:0]s_axis_data_tdata,
input s_axis_data_tvalid,
output s_axis_data_tready,
input s_axis_data_tlast,

input [255:0] aux_status,
input [31:0] cfg_ptr_sym,
// axi4 write
output reg [AWIDTH-1 : 0]		m_axi_awaddr,
output reg [LWIDTH-1 : 0]		m_axi_awlen,
output reg [2 : 0]          	m_axi_awsize,
output reg                  	m_axi_awvalid,
input                       	m_axi_awready,
output reg [DOUT_WIDTH-1 : 0]   m_axi_wdata,
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
assign m_axi_awcache = 4'b0011; // Device Bufferable
assign m_axi_awlock = 1'b0;     // Normal access
assign m_axi_wstrb = -1;        // All Byte Enable

assign cfg_trans_overflow = 0;
// fifo write
reg cfg_axi_active_r1;
reg cfg_axi_active_r2;
//reg fifo_rst;
//always@(posedge fifo_clk)fifo_rst <= mem_rst;
always@(posedge fifo_clk)begin
	if(fifo_rst)begin
		cfg_axi_active_r1 <= 0;
		cfg_axi_active_r2 <= 0;
	end
	else begin
		cfg_axi_active_r1 <= cfg_axi_active;
		cfg_axi_active_r2 <= cfg_axi_active_r1;
	end
end

reg fifo_clr_r1;
wire active_pulse = cfg_axi_active_r1 & (~cfg_axi_active_r2);
reg [7:0] active_pulse_r;
assign cfg_axi_deepfifo_reset = fifo_clr_r1;

always@(posedge fifo_clk)begin
	if(fifo_rst)active_pulse_r <= 0;
	else active_pulse_r <= {active_pulse_r[6:0], active_pulse};
end

reg fifo_data_ready = 0;
always@(posedge fifo_clk)begin
	if(fifo_rst)begin
		//fifo_clr_r1 <= 0;	// Change to following on Jan 24, 2019
		fifo_clr_r1 <= 1;
		fifo_data_ready <= 0;
	end
	else begin
		fifo_clr_r1 <= (~cfg_axi_active_r2); //(|active_pulse_r);
		fifo_data_ready <= (~(|active_pulse_r))&cfg_axi_active_r2;
	end
end

wire fifo_rd;
wire [DOUT_WIDTH-1:0] fifo_dout;
localparam Nb = DIN_WIDTH/DOUT_WIDTH;


wire [12:0] rd_data_count;
wire fifo_full, fifo_empty;
wire fifo_wr;
wire [DIN_WIDTH-1:0] fifo_din;
wire [DIN_WIDTH-1:0] fifo_din_c;
wire fifo_afull;
localparam WRFULL_THRESH = 4000*DOUT_WIDTH/DIN_WIDTH;
genvar kk;
generate
for(kk=0;kk<Nb;kk=kk+1)begin:assign_block
	assign fifo_din_c[kk*DOUT_WIDTH+DOUT_WIDTH-1:kk*DOUT_WIDTH] = fifo_din[(Nb-kk-1)*DOUT_WIDTH+DOUT_WIDTH-1:(Nb-kk-1)*DOUT_WIDTH];

end
endgenerate

generate
if(DIN_WIDTH==256)begin:blk1
	wire [11:0] wr_data_count;
	assign fifo_afull = (wr_data_count>WRFULL_THRESH);
	rec128_fifox256 rec_fifo0(
	.rst(fifo_clr_r1),     

	.wr_clk(fifo_clk),   
	.wr_en(fifo_wr),    
	.din(fifo_din_c), 
	.wr_data_count(wr_data_count),

	.rd_clk(mem_clk),   
	.rd_en(fifo_rd),    
	.dout(fifo_dout),
	.rd_data_count(rd_data_count),

	.full(fifo_full),
	.empty(fifo_empty)
	);
end
else begin
	wire [12:0] wr_data_count;
	assign fifo_afull = (wr_data_count>WRFULL_THRESH);
	rec128_fifox128 rec_fifo0(
	.rst(fifo_clr_r1),     

	.wr_clk(fifo_clk),   
	.wr_en(fifo_wr),    
	.din(fifo_din_c), 
	.wr_data_count(wr_data_count),

	.rd_clk(mem_clk),   
	.rd_en(fifo_rd),    
	.dout(fifo_dout),
	.rd_data_count(rd_data_count),

	.full(fifo_full),
	.empty(fifo_empty)
	);
end
endgenerate

assign s_axis_data_tready = ~fifo_afull;
assign fifo_din = s_axis_data_tdata;
assign fifo_wr = s_axis_data_tvalid&s_axis_data_tready;
// obsolete s_axis_data_tlast,
 

reg [255:0] aux_status_r1;
always@(posedge mem_clk)begin
	if(mem_rst)begin
        aux_status_r1 <= 0;
    end
    else begin
        aux_status_r1 <= aux_status;
    end
end

// timing app to mem
reg [AWIDTH-1:0] cfg_addr_dma_q1;
reg [AWIDTH-1:0] cfg_addr_sym_q1;
reg [AWIDTH-1:0] cfg_size_dma_q1;
reg [AWIDTH-1:0] cfg_size_sym_q1;
reg [31:0] cfg_frame_len_q1;
reg [31:0] cfg_trans_len_q1;
reg [31:0] cfg_burst_len_q1;
reg [31:0] cfg_ptr_sym_q1;
reg cfg_axi_active_q1;
reg cfg_axi_active_q2;
reg cfg_axi_repeat_q1;
always@(posedge mem_clk)begin
	if(mem_rst)begin
		cfg_axi_active_q1 <= 0;
		cfg_axi_active_q2 <= 0;
		cfg_axi_repeat_q1 <= 0;
		cfg_addr_dma_q1  <= 0;
		cfg_addr_sym_q1  <= 0;
		cfg_size_dma_q1  <= 0;
		cfg_size_sym_q1  <= 0;
		cfg_burst_len_q1 <= 0;
		cfg_ptr_sym_q1 <= 0;
		cfg_frame_len_q1 <= 0;
		cfg_trans_len_q1 <= 0;
	end
	else begin                
		cfg_axi_active_q1 <= cfg_axi_active;
		cfg_axi_active_q2 <= cfg_axi_active_q1;
		cfg_axi_repeat_q1 <= cfg_axi_repeat;
		cfg_addr_dma_q1  <= cfg_addr_dma;
		cfg_addr_sym_q1  <= cfg_addr_sym;
		cfg_size_dma_q1  <= cfg_size_dma;
		cfg_size_sym_q1  <= cfg_size_sym;
		cfg_burst_len_q1 <= cfg_burst_len;
		cfg_ptr_sym_q1 <= cfg_ptr_sym;
		cfg_frame_len_q1 <= cfg_frame_len;
		cfg_trans_len_q1 <= cfg_trans_len;
	end
end

reg [15:0] rd_data_count_q1;
reg fifo_data_ready_q1;
always@(posedge mem_clk)begin
	if(mem_rst)begin
		rd_data_count_q1 <= 0;
		fifo_data_ready_q1 <= 0;
	end
	else begin
		rd_data_count_q1 <= rd_data_count;
		fifo_data_ready_q1 <= fifo_data_ready;
	end
end

wire [31:0] thresh_len;
assign thresh_len = cfg_burst_len_q1;
reg [31:0] frame_cnt;
reg [31:0] trans_cnt;
// fifo read state maching
localparam
IDLE = 1,
WAIT = 2,
FRAME_START = 3,
WRADDR = 4,
WRDATA = 5,
WRRESP = 6,
WRITE_SYM0 = 7,
WRITE_SYM1 = 8,
WRITE_END0 = 9,
WRITE_END1 = 10;
localparam NON_RESP_CMD_COUNT = 32;
localparam SYM_MASK = 32'hDAC0_FF00;
localparam END_MASK = 32'hDAC0_FF01;
// resp fifo
reg wrfifo_srst;
reg [AWIDTH-1:0] wrfifo_din;
reg wrfifo_wr_en;
wire wrfifo_rd_en;
wire [AWIDTH-1:0] wrfifo_dout;
wire [6:0] wrfifo_data_count;
wire wrfifo_empty;
wire wrfifo_full;
assign wrfifo_rd_en = m_axi_bvalid&m_axi_bready;
assign m_axi_bready = (~wrfifo_empty) | wrfifo_srst;
reg wr_fail;
assign cfg_resp_error = wr_fail;
always@(posedge mem_clk)begin
	if(mem_rst)begin
		wr_fail <= 0;
	end
	else begin
		if(wrfifo_srst)wr_fail <= 0;
		else if(m_axi_bvalid&m_axi_bready)begin
			if(m_axi_bresp != `OKAY)wr_fail <= 1;
		end
	end
end
ack_resp_fifo wrfifo (
.clk(mem_clk),                // input wire clk
.srst(wrfifo_srst),              // input wire srst
.din(wrfifo_din),                // input wire [31 : 0] din
.wr_en(wrfifo_wr_en),            // input wire wr_en
.rd_en(wrfifo_rd_en),            // input wire rd_en
.dout(wrfifo_dout),              // output wire [31 : 0] dout
.full(wrfifo_full),              // output wire full
.empty(wrfifo_empty),            // output wire empty
.data_count(wrfifo_data_count)  // output wire [7 : 0] data_count
);

reg [3:0] cstate;
reg [3:0] nstate;
reg [AWIDTH-1:0] waddr0;
reg [AWIDTH-1:0] waddr1;
wire data_ready = fifo_data_ready_q1 & (thresh_len<=rd_data_count_q1) | (frame_cnt<=rd_data_count_q1);
always@(*)begin
	nstate = IDLE;
	case(cstate)
		IDLE:begin
			if(cfg_axi_active_q1)nstate = WAIT;
			else nstate = IDLE;
		end
		WAIT:begin
			if(~cfg_axi_active_q1)nstate = IDLE;
			else if((cfg_ptr_sym_q1!=waddr1))nstate = FRAME_START;	// how to solve cross clock issue
			else nstate = WAIT;
		end
		FRAME_START:begin
			if(~cfg_axi_active_q1)nstate = IDLE;
			else if(frame_cnt==0)nstate = WRITE_END0;
			else if(trans_cnt==0)nstate = WRITE_SYM0;
			else if(data_ready)nstate = WRADDR;
			//else if((~fifo_wr_valid_q1) & (thresh_len[31:1]<=rd_data_count_q1))nstate = WRADDR;
			else nstate = FRAME_START;
		end
		// write data
		WRADDR:begin
			if(m_axi_awvalid&m_axi_awready)nstate = WRDATA;
			else nstate = WRADDR;
		end
		WRDATA:begin
			if(m_axi_wvalid&m_axi_wready&m_axi_wlast)nstate = WRRESP;
			else nstate = WRDATA;
		end
		WRRESP:begin
			if(wrfifo_data_count<NON_RESP_CMD_COUNT)nstate = FRAME_START;
			else nstate = WRRESP;
		end
		// write trans symbol
		WRITE_SYM0:begin
			if(m_axi_awvalid&m_axi_awready)nstate = WRITE_SYM1;
			else nstate = WRITE_SYM0;
		end
		WRITE_SYM1:begin
			if(m_axi_wvalid&m_axi_wready&m_axi_wlast)nstate = FRAME_START;
			else nstate = WRITE_SYM1;
		end
		// write frame end
		WRITE_END0:begin
			if(m_axi_awvalid&m_axi_awready)nstate = WRITE_END1;
			else nstate = WRITE_END0;
		end
		WRITE_END1:begin
			if(m_axi_wvalid&m_axi_wready&m_axi_wlast)nstate = WAIT;
			else nstate = WRITE_END1;
		end
		default:begin
			nstate = IDLE;
		end
	endcase
end
// data and addr

reg [7:0] wrcnt;
reg fifo_prerd; 
assign fifo_rd = fifo_prerd | (m_axi_wvalid&m_axi_wready&(~m_axi_wlast));
reg [7:0] burst_cnt; // debug purpose


// add following for calculating burst length
reg [15:0] LinesToWrite;
reg [15:0] AddrToWrite;
localparam BYTES_TO_ALIGN = 4096;
localparam HIGHBIT_TO_ALIGN = 11;
localparam DATALINE_BYTES = 2**DATA_SIZE;
localparam UPPER_TO_ALIGN = BYTES_TO_ALIGN/DATALINE_BYTES-1;
localparam LINES_TO_ALIGN = BYTES_TO_ALIGN/DATALINE_BYTES;

always@(posedge mem_clk)begin
	if(mem_rst)begin
		cstate <= IDLE;
		m_axi_awaddr <= 0;
		m_axi_awlen <= 0;
		m_axi_awsize <= 0;
		m_axi_awvalid <= 0;
		m_axi_wdata <= 0;
		m_axi_wlast <= 0;
		m_axi_wvalid <= 0;
		waddr0 <= 0;
		waddr1 <= 0;
		wrcnt <= 0;
		frame_cnt <= 0;
		trans_cnt <= 0;
		wrfifo_srst <= 1;
		wrfifo_din <= 0;
		wrfifo_wr_en <= 0;
		fifo_prerd <= 0;
		burst_cnt <= 0;
		
		LinesToWrite <= 0;
		AddrToWrite <= 0;
	end
	else begin
		cstate <= nstate;
		case(cstate)
			IDLE:begin
				m_axi_awaddr <= 0;
				m_axi_awlen <= 0;
				m_axi_awsize <= 0;
				m_axi_awvalid <= 0;
				m_axi_wdata <= 0;
				m_axi_wlast <= 0;
				m_axi_wvalid <= 0;
				waddr0 <= 0;
				waddr1 <= 0;
				wrcnt <= 0;
				frame_cnt <= 0;
				trans_cnt <= 0;
				wrfifo_srst <= 1;
				wrfifo_din <= 0;
				wrfifo_wr_en <= 0;
				fifo_prerd <= 0;
				burst_cnt <= 0;
				
				LinesToWrite <= 0;
				AddrToWrite <= 0;
			end
			WAIT:begin
				m_axi_awaddr <= 0;
				m_axi_awlen <= 0;
				m_axi_awsize <= 0;
				m_axi_awvalid <= 0;
				m_axi_wdata <= 0;
				m_axi_wlast <= 0;
				m_axi_wvalid <= 0;
				if(cfg_axi_repeat_q1)waddr0 <= 0;
				if(cfg_axi_repeat_q1)waddr1 <= 0;
				wrcnt <= 0;
				frame_cnt <= cfg_frame_len_q1[31:LAST_CNT_BIT];
				trans_cnt <= cfg_trans_len_q1[31:LAST_CNT_BIT];
				wrfifo_srst <= 0;
				wrfifo_din <= 0;
				wrfifo_wr_en <= 0;
				fifo_prerd <= 0;
				burst_cnt <= 0;
				
				LinesToWrite <= 0;
				AddrToWrite <= 0;
			end
			FRAME_START:begin
				m_axi_awvalid <= 0;
				m_axi_wvalid <= 0;
				m_axi_wlast <= 0;
				wrfifo_wr_en <= 0;
				//burst_cnt <= 0;
				
				if((thresh_len<=rd_data_count_q1)&(thresh_len<=frame_cnt))begin
					LinesToWrite <= thresh_len;
					AddrToWrite <= thresh_len + waddr0[HIGHBIT_TO_ALIGN:LAST_CNT_BIT];
				end
				else begin
					LinesToWrite <= frame_cnt;
					AddrToWrite <= frame_cnt + waddr0[HIGHBIT_TO_ALIGN:LAST_CNT_BIT];
				end
			end
			WRADDR:begin
				if(m_axi_awvalid&m_axi_awready)begin
					m_axi_awvalid <= 0;
					waddr0 <= waddr0 + {16'h0000, LinesToWrite, {LAST_CNT_BIT{1'b0}}};
					
					wrfifo_din <= m_axi_awaddr;
					wrfifo_wr_en <= 1;
					fifo_prerd <= 1;
					m_axi_wdata <= fifo_dout;
					m_axi_wvalid <= 0;
					
					//if(frame_cnt>=cfg_burst_len_q1)frame_cnt <= frame_cnt - cfg_burst_len_q1;
					//else frame_cnt <= 0;
					//if(trans_cnt>=cfg_burst_len_q1)trans_cnt <= trans_cnt - cfg_burst_len_q1;
					//else trans_cnt <= 0;
					//wrcnt <= cfg_burst_len_q1-1;
					frame_cnt <= frame_cnt - LinesToWrite;
					trans_cnt <= trans_cnt - LinesToWrite;
					wrcnt <= LinesToWrite - 1;
				end
				else begin
					m_axi_awaddr <= cfg_addr_dma_q1 + waddr0;
					//m_axi_awlen <= cfg_burst_len_q1-1;
					m_axi_awsize <= DATA_SIZE;
					m_axi_awvalid <= 1;
					if(AddrToWrite>LINES_TO_ALIGN)begin
						m_axi_awlen <= UPPER_TO_ALIGN - waddr0[HIGHBIT_TO_ALIGN:LAST_CNT_BIT];
						LinesToWrite <= LINES_TO_ALIGN - waddr0[HIGHBIT_TO_ALIGN:LAST_CNT_BIT];
					end
					else begin
						m_axi_awlen <= LinesToWrite - 1;
					end
				end
			end
			WRDATA:begin
				wrfifo_wr_en <= 0;
				fifo_prerd <= 0;
				if(waddr0>=cfg_size_dma_q1)waddr0 <= waddr0 - cfg_size_dma_q1;
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
					m_axi_wdata <= fifo_dout;
				end
				else begin
					m_axi_wvalid <= 1;
					if(wrcnt==0)m_axi_wlast <= 1;	// add to fix burst==1 bug
				end
			end
			WRRESP:begin
				
			end
			WRITE_SYM0:begin
				if(m_axi_awvalid&m_axi_awready)begin
					m_axi_awvalid <= 0;
					waddr1 <= waddr1 + {1'b1, {LAST_CNT_BIT{1'b0}}};
					
					wrfifo_din <= m_axi_awaddr;
					wrfifo_wr_en <= 1;
					burst_cnt <= burst_cnt + 1;
				end
				else begin
					m_axi_awaddr <= cfg_addr_sym_q1 + waddr1;
					m_axi_awlen <= 0;
					m_axi_awsize <= DATA_SIZE;
					m_axi_awvalid <= 1;
				end
			end
			WRITE_SYM1:begin
				wrfifo_wr_en <= 0;
				if(waddr1>=cfg_size_sym_q1)waddr1 <= waddr1 - cfg_size_sym_q1;
				if(m_axi_wvalid&m_axi_wready)begin
					m_axi_wlast <= 0;
					m_axi_wvalid <= 0;   
					m_axi_wlast <= 0;
				end
				else begin
					m_axi_wvalid <= 1;
					m_axi_wdata <= {aux_status_r1, SYM_MASK};
					m_axi_wlast <= 1;
				end
				trans_cnt <= cfg_trans_len_q1[31:LAST_CNT_BIT];
			end
			WRITE_END0:begin
				if(m_axi_awvalid&m_axi_awready)begin
					m_axi_awvalid <= 0;
					waddr1 <= waddr1 + {1'b1, {LAST_CNT_BIT{1'b0}}};
					
					wrfifo_din <= m_axi_awaddr;
					wrfifo_wr_en <= 1;
					burst_cnt <= burst_cnt + 1;
				end
				else begin
					m_axi_awaddr <= cfg_addr_sym_q1 + waddr1;
					m_axi_awlen <= 0;
					m_axi_awsize <= DATA_SIZE;
					m_axi_awvalid <= 1;
				end
			end
			WRITE_END1:begin
				wrfifo_wr_en <= 0;
				if(waddr1>=cfg_size_sym_q1)waddr1 <= waddr1 - cfg_size_sym_q1;
				if(m_axi_wvalid&m_axi_wready)begin
					m_axi_wlast <= 0;
					m_axi_wvalid <= 0;   
					m_axi_wlast <= 0;
				end
				else begin
					m_axi_wvalid <= 1;
					m_axi_wdata <= {aux_status_r1, m_axi_awaddr, END_MASK};
					m_axi_wlast <= 1;
				end
			end
			default:begin
			end
		endcase
	end
end

assign cfg_trans_maxdly = 0;
assign cfg_trans_errcnt = 0;
//`ifndef BYPASS_ALLSCOPE
ila_axi2host ila_axi2host_ep0(
.clk(mem_clk),
.probe0(m_axi_awaddr  ),
.probe1(m_axi_awready ),
.probe2(m_axi_awvalid ),
.probe3(m_axi_wvalid ),
.probe4(m_axi_wlast),
.probe5(cfg_frame_len_q1), //cfg_trans_len  ),
.probe6(cfg_addr_dma_q1),
.probe7(cfg_addr_sym_q1),
.probe8(cfg_size_dma_q1),  
.probe9(cfg_size_sym_q1), 
.probe10(cfg_trans_overflow), 
.probe11(cfg_resp_error), 
.probe12(frame_cnt),
.probe13(trans_cnt),
.probe14(cstate),
.probe15(cfg_ptr_sym_q1),
.probe16(waddr1),
.probe17(s_axis_data_tvalid),
.probe18(s_axis_data_tready),
.probe19(cfg_axi_active_q1 ),
.probe20(s_axis_data_tlast),
.probe21(m_axi_wdata ),
.probe22(fifo_clr_r1 )
);
//`endif
endmodule
