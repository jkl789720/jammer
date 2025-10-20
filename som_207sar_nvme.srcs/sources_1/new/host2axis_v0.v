// Apr 28, 2020. Add support for DOUT_WIDTH 512. Add gen512_xxx fifo, modify wr_data_count.
// Jan 2, 2020. Add DIN_WIDTH support for 256. New fifo IP was added.
// Aug 29, 2019. Add rstcnt to support immediate response from axi bram
// Mar 11, 2019. cfg_size_sym is config by port. More flexibility for H2D.
// Feb 20, 2019. Add  | (~cfg_axi_active_r2) to reset data_recovery
// Feb 13, 2019. Change arcache to constant 0011 according to UG1037. Xilinx IP generally ignores (as slaves) or generates (as masters) transactions with Normal, Non-cacheable, Modifiable, and Bufferable.
// Nov 30, 2018. Change FIFO to more accurate data count set and increase wr/rd_data_count width
// Nov 30, 2018. Add support for non-burst length;
// Aug 7, 2018. Using counterfull to replace counter. Avoiding wrap when cross prfin
// Feb 23, 2018. First Version. Support both prf/frame format and continuous data.one fifo and one memory region. No 4KB boundary check.
`define OKAY 		2'b00
`define EXOKAY 		2'b01
`define SLVERR 		2'b10
`define DECERR 		2'b11
`define BYPASS_DATACORRECT

module host2axis_v0
#(
parameter DIN_WIDTH = 64,
parameter DOUT_WIDTH = 128,
parameter AWIDTH = 32,
parameter LWIDTH = 8,
parameter DATA_SIZE = 4,
parameter BLKRAM_WIDTH = DOUT_WIDTH,
parameter LAST_CNT_BIT = DATA_SIZE
)
(
input mem_clk,
input mem_rst,

// app
input [AWIDTH-1:0] cfg_addr_dma,
input [AWIDTH-1:0] cfg_size_dma,
input [31:0] cfg_burst_len, // must check following by driver, assume maximum burst length is 32
input [31:0] cfg_frame_len, // must be N x BurstSize x BurstLen
input [31:0] cfg_trans_len, // must be N x BurstSize x BurstLen
input cfg_axi_active, 
input cfg_axi_repeat,
input cfg_axi_bypass,
output cfg_trans_underflow,
output cfg_resp_error,
output [15:0] cfg_trans_maxdly,
output [15:0] cfg_trans_errcnt,

// control, must be in fifo_clk domain 
input fifo_clk,
input fifo_rst,
output [DIN_WIDTH-1:0]m_axis_data_tdata,
output m_axis_data_tvalid,
input m_axis_data_tready,
output m_axis_data_tlast,
input [BLKRAM_WIDTH-1:0] aux_status,

// axi4 read
output reg [AWIDTH-1 : 0] 	m_axi_araddr,
output reg [LWIDTH-1 : 0] 	m_axi_arlen,
output reg [2 : 0]        	m_axi_arsize,
output reg                	m_axi_arvalid,
input                     	m_axi_arready,

input  [DOUT_WIDTH-1 : 0]  	m_axi_rdata,
input  [1 : 0]            	m_axi_rresp,
input                     	m_axi_rlast,
input                     	m_axi_rvalid,
output reg                 	m_axi_rready,

output  [1 : 0]           	m_axi_arburst,
output  [2 : 0]           	m_axi_arprot,
output                    	m_axi_arlock,
output  [3 : 0]           	m_axi_arcache,

output reg ram_enb,
output reg [BLKRAM_WIDTH/8-1:0] ram_we,
output reg [31:0] ram_addr,
output reg [BLKRAM_WIDTH-1:0] ram_din,
input [BLKRAM_WIDTH-1:0] ram_dout
);
assign m_axi_arburst = 2'b01;     // INCR
assign m_axi_arprot = 3'b000;    // Unprivileged access, Non-secure access, Data access
assign m_axi_arlock = 1'b0;     // Normal access
assign m_axi_arcache = 4'b0011; // Device Bufferable

//assign m_axis_data_tlast = 0;
assign cfg_trans_underflow = 0;
/*-------------------------- Timing of fifo input ----------------------

fifo_clk		___|--|___|--|___|--|___|--|___|--|___|--|___|--|___|--|
fifo_clr		___|------|_____________________________________________
fifo_rd_valid	__________|----------------------------------|__________
fifo_rd_enable	__________|XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX|__________

----------------------------------------------------------------------*/
// fifo read
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
reg fifo_wr_enable_r1;
reg [DOUT_WIDTH-1:0] fifo_wr_data_r1;
reg [7:0] fifo_attr_r1;
wire active_pulse = cfg_axi_active_r1 & (~cfg_axi_active_r2);
reg [7:0] active_pulse_r;
always@(posedge fifo_clk)begin
	if(fifo_rst)active_pulse_r <= 0;
	else active_pulse_r <= {active_pulse_r[6:0], active_pulse};
end

always@(posedge fifo_clk)begin
	if(fifo_rst)begin
		fifo_clr_r1 <= 1;
	end
	else begin
		fifo_clr_r1 <= (|active_pulse_r);
	end
end

localparam Nb = DIN_WIDTH/DOUT_WIDTH;
localparam DOUT_PREFIX = 2;
localparam DOUT_WIDTH_FIX = DOUT_WIDTH+DOUT_PREFIX;

wire [12:0] wr_data_count;
wire fifo_full, fifo_empty;
wire [DIN_WIDTH+3:0] fifo_dout;
wire [DIN_WIDTH+3:0] fifo_dout_c;
wire fifo_rd;
genvar kk;
generate
for(kk=0;kk<Nb;kk=kk+1)begin:assign_block
	assign fifo_dout[DOUT_WIDTH*kk+DOUT_WIDTH-1:DOUT_WIDTH*kk] = fifo_dout_c[(Nb-kk-1)*DOUT_WIDTH_FIX+DOUT_WIDTH-1:(Nb-kk-1)*DOUT_WIDTH_FIX];
	assign fifo_dout[DIN_WIDTH+kk] = fifo_dout_c[(Nb-kk-1)*DOUT_WIDTH_FIX+DOUT_WIDTH];
end
endgenerate
generate
if(DIN_WIDTH==256)begin:blk1
	wire [11:0] rd_data_count;
	gen130_fifox260 gen_fifo0(
	.rst(fifo_clr_r1),     

	.wr_clk(mem_clk),   
	.wr_en(fifo_wr_enable_r1),    
	.din({fifo_attr_r1, fifo_wr_data_r1}), 
	.wr_data_count(wr_data_count),

	.rd_clk(fifo_clk),   
	.rd_en(fifo_rd),    
	.dout(fifo_dout_c),
	.rd_data_count(rd_data_count),

	.full(fifo_full),
	.empty(fifo_empty)
	);
end
else begin
	wire [12:0] rd_data_count;
	gen130_fifox130 gen_fifo0(
	.rst(fifo_clr_r1),     

	.wr_clk(mem_clk),   
	.wr_en(fifo_wr_enable_r1),    
	.din({fifo_attr_r1, fifo_wr_data_r1}), 
	.wr_data_count(wr_data_count),

	.rd_clk(fifo_clk),   
	.rd_en(fifo_rd),    
	.dout(fifo_dout_c),
	.rd_data_count(rd_data_count),

	.full(fifo_full),
	.empty(fifo_empty)
	);
end
endgenerate

assign m_axis_data_tdata = fifo_dout[DIN_WIDTH-1:0];
assign m_axis_data_tlast = (|fifo_dout[DIN_WIDTH+Nb-1:DIN_WIDTH]);
assign m_axis_data_tvalid = ~fifo_empty;
assign fifo_rd = m_axis_data_tvalid & m_axis_data_tready;

// following addr and size is set to match block ram in wrapper
localparam [AWIDTH-1:0] cfg_addr_sym = 0;
//localparam [AWIDTH-1:0] cfg_size_sym = 16384*4;
reg [AWIDTH-1:0] cfg_size_sym;
// timing app to mem
reg [AWIDTH-1:0] cfg_addr_dma_q1;
reg [AWIDTH-1:0] cfg_size_dma_q1;
reg [31:0] cfg_frame_len_q1;
reg [31:0] cfg_trans_len_q1;
reg [31:0] cfg_burst_len_q1;
reg cfg_axi_active_q1;
reg cfg_axi_active_q2;
reg cfg_axi_repeat_q1;
reg cfg_axi_bypass_q1;
always@(posedge mem_clk)begin
	if(mem_rst)begin
		cfg_axi_active_q1 <= 0;
		cfg_axi_active_q2 <= 0;
		cfg_axi_repeat_q1 <= 0;
		cfg_addr_dma_q1  <= 0;
		cfg_size_dma_q1  <= 0;
		cfg_burst_len_q1 <= 0;
		cfg_size_sym <= 0;
		cfg_frame_len_q1 <= 0;
		cfg_trans_len_q1 <= 0;
		cfg_axi_bypass_q1 <= 0;
	end
	else begin                
		cfg_axi_active_q1 <= cfg_axi_active;
		cfg_axi_active_q2 <= cfg_axi_active_q1;
		cfg_axi_repeat_q1 <= cfg_axi_repeat;
		cfg_addr_dma_q1  <= cfg_addr_dma;
		cfg_size_dma_q1  <= cfg_size_dma;
		cfg_burst_len_q1 <= {20'h00000, cfg_burst_len[11:00]};
		cfg_size_sym <= {12'h000, cfg_burst_len[31:12]};
		cfg_frame_len_q1 <= cfg_frame_len;
		cfg_trans_len_q1 <= cfg_trans_len;
		cfg_axi_bypass_q1 <= cfg_axi_bypass;
	end
end

// resp fifo
reg wrfifo_srst;
reg [63:0] wrfifo_din;
reg wrfifo_wr_en;
wire wrfifo_rd_en;
wire [63:0] wrfifo_dout;
wire [6:0] wrfifo_data_count;
wire wrfifo_empty;
wire wrfifo_full;
assign wrfifo_rd_en = m_axi_rvalid&m_axi_rready&m_axi_rlast;
always@(posedge mem_clk)begin
	if(mem_rst)begin
		m_axi_rready <= 0;
		fifo_wr_data_r1 <= 0;
        fifo_attr_r1 <= 0;
		fifo_wr_enable_r1 <= 0;
	end
	else begin
		m_axi_rready <= (~wrfifo_empty) | wrfifo_srst;
		fifo_wr_data_r1 <= m_axi_rdata;
        fifo_attr_r1 <= {7'h0, m_axi_rlast};
		fifo_wr_enable_r1 <= m_axi_rvalid&m_axi_rready;
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
/*
For a write transaction, a single response is signaled for the entire burst, and not for each data transfer within the burst.
In a read transaction, the slave can signal different responses for different transfers in a burst. 
*/
reg wr_fail;
assign cfg_resp_error = wr_fail;
always@(posedge mem_clk)begin
	if(mem_rst)begin
		wr_fail <= 0;
	end
	else begin
		if(wrfifo_srst)wr_fail <= 0;
		else if(m_axi_rvalid&m_axi_rready)begin
			if(m_axi_rresp != `OKAY)wr_fail <= 1;
		end
	end
end

reg [15:0] wr_data_count_q1;
reg [31:0] ram_dout_r1;
always@(posedge mem_clk)begin
	if(mem_rst)begin
		wr_data_count_q1 <= 0;
		ram_dout_r1 <= 0;
	end
	else begin
		wr_data_count_q1 <= wr_data_count;
		ram_dout_r1 <= ram_dout;
	end
end

reg [7:0] rstcnt = 0;
always@(posedge mem_clk)begin
	if(mem_rst)begin
        rstcnt <= 0;
	end
	else begin
        if(cfg_axi_active_q1)begin
            if(rstcnt<8'hFF)rstcnt <= rstcnt + 1;
        end
        else rstcnt <= 0;
	end
end

// fifo read state maching
localparam NON_RESP_CMD_COUNT = 10;
localparam MAX_BURST_LEN = 32;
wire [31:0] thresh_len;
assign thresh_len = 4096-MAX_BURST_LEN*(NON_RESP_CMD_COUNT+2); // assume maximum burst length is 32
reg [31:0] frame_cnt;
reg [31:0] trans_cnt;
localparam
IDLE = 1,
WAIT = 2,
FRAME_START = 3,
READSYM0 = 4,
READSYM1 = 5,
CLRSYM = 6,
RDADDR = 7,
RDRESP = 8;

localparam SYM_MASK = 32'hDAC0_FF00;
localparam END_MASK = 32'hDAC0_FF01;
reg [3:0] cstate;
reg [3:0] nstate;
reg [3:0] tcnt;
always@(*)begin
	nstate = IDLE;
	case(cstate)
		IDLE:begin
			if(cfg_axi_active_q1)nstate = WAIT;
			else nstate = IDLE;
		end
		WAIT:begin
			if(~cfg_axi_active_q1)nstate = IDLE;
			else if((wr_data_count_q1<thresh_len)&(rstcnt>32))nstate = FRAME_START;
			else nstate = WAIT;
		end
		FRAME_START:begin
			if(~cfg_axi_active_q1)nstate = IDLE;
			else if(ram_dout_r1[31:8]==SYM_MASK[31:8])nstate = CLRSYM;
			else nstate = FRAME_START;
		end
		CLRSYM:begin
			nstate = READSYM0;
		end
		READSYM0:begin
			nstate = READSYM1;
		end
		READSYM1:begin
			if(~cfg_axi_active_q1)nstate = IDLE;
			else if(frame_cnt==0)nstate = WAIT;
			else if(trans_cnt==0)nstate = FRAME_START;
			else if((tcnt==0) & cfg_axi_bypass_q1)nstate = FRAME_START;
			//else if(cfg_axi_bypass_q1)nstate = READSYM1;
			else if(wr_data_count_q1<thresh_len)nstate = RDADDR;
			else nstate = READSYM1;
		end
		RDADDR:begin
			if(m_axi_arvalid&m_axi_arready)nstate = RDRESP;
			else nstate = RDADDR;
		end
		RDRESP:begin
			if(wrfifo_data_count<NON_RESP_CMD_COUNT)nstate = READSYM1;
			else nstate = RDRESP;
		end
		default:begin
			nstate = IDLE;
		end
	endcase
end

reg [31:0] counterfull;
reg [BLKRAM_WIDTH-1:0] aux_status_r1;
always@(posedge mem_clk)begin
	if(mem_rst)begin
		counterfull <= 0;
        aux_status_r1 <= 0;
	end
	else begin
		counterfull <= counterfull + 1;
        aux_status_r1 <= aux_status;
	end
end

// data and addr
reg [AWIDTH-1:0] waddr0;
reg [AWIDTH-1:0] waddr1;
always@(posedge mem_clk)begin
	if(mem_rst)begin
		cstate <= IDLE;
		m_axi_araddr <= 0;
		m_axi_arlen <= 0;
		m_axi_arsize <= 0;
		m_axi_arvalid <= 0;
		waddr0 <= 0;
		waddr1 <= 0;
		frame_cnt <= 0;
		trans_cnt <= 0;
		wrfifo_srst <= 1;
		wrfifo_din <= 0;
		wrfifo_wr_en <= 0;
		tcnt <= 0;
		
		ram_enb <= 0;
		ram_we <= 0;
		ram_addr <= cfg_addr_sym;
		ram_din <= 0;
	end
	else begin
		cstate <= nstate;
		case(cstate)
			IDLE:begin
				m_axi_araddr <= 0;
				m_axi_arlen <= 0;
				m_axi_arsize <= 0;
				m_axi_arvalid <= 0;
				waddr0 <= 0;
				waddr1 <= 0;
				frame_cnt <= 0;
				trans_cnt <= 0;
				wrfifo_srst <= 1;
				wrfifo_din <= 0;
				wrfifo_wr_en <= 0;
				ram_enb <= 1;
				ram_we <= 0;
				ram_addr <= cfg_addr_sym;
				ram_din <= 0;
				tcnt <= 0;
			end
			WAIT:begin
				m_axi_araddr <= 0;
				m_axi_arlen <= 0;
				m_axi_arsize <= 0;
				m_axi_arvalid <= 0;
				if(cfg_axi_repeat_q1)waddr0 <= 0;
				if(cfg_axi_repeat_q1)ram_addr <= cfg_addr_sym;
				frame_cnt <= cfg_frame_len_q1[31:LAST_CNT_BIT];
				trans_cnt <= cfg_trans_len_q1[31:LAST_CNT_BIT];
				wrfifo_srst <= 0;
				wrfifo_din <= 0;
				wrfifo_wr_en <= 0;
				tcnt <= 0;
			end
			FRAME_START:begin
				m_axi_araddr <= 0;
				m_axi_arlen <= 0;
				m_axi_arsize <= 0;
				m_axi_arvalid <= 0;
				wrfifo_srst <= 0;
				wrfifo_din <= 0;
				wrfifo_wr_en <= 0;
				trans_cnt <= cfg_trans_len_q1[31:LAST_CNT_BIT];
			end
			CLRSYM:begin
				ram_we <= {(BLKRAM_WIDTH/8){1'b1}};
				ram_din <= {aux_status_r1, 32'h0};
			end
			READSYM0:begin
				ram_we <= 0;
				ram_addr <= ram_addr + BLKRAM_WIDTH/8;
				tcnt <= 8;
			end
			READSYM1:begin
				if(tcnt>0)tcnt <= tcnt - 1;
				if(ram_addr>=cfg_size_sym)ram_addr <= ram_addr - cfg_size_sym;
			end
			RDADDR:begin
				if(m_axi_arready&m_axi_arvalid)begin
					m_axi_arvalid <= 0;
					waddr0 <= waddr0 + {cfg_burst_len_q1, {LAST_CNT_BIT{1'b0}}};
					
					wrfifo_din <= {counterfull, m_axi_araddr};
					wrfifo_wr_en <= 1;
					
					if(frame_cnt>=cfg_burst_len_q1)frame_cnt <= frame_cnt - cfg_burst_len_q1;
					else frame_cnt <= 0;
					if(trans_cnt>=cfg_burst_len_q1)trans_cnt <= trans_cnt - cfg_burst_len_q1;
					else trans_cnt <= 0;
				end
				else begin
					m_axi_araddr <= cfg_addr_dma_q1 + waddr0;
					m_axi_arsize <= DATA_SIZE;
					m_axi_arlen <= cfg_burst_len_q1 - 1;
					m_axi_arvalid <= 1;
				end
			end
			RDRESP:begin
				wrfifo_wr_en <= 0;
				if(waddr0>=cfg_size_dma_q1)waddr0 <= waddr0 - cfg_size_dma_q1;
			end
			default:begin
			end
		endcase
	end
end

// calc max resp latency
reg [31:0] maxcnt0;
reg [31:0] maxdly;
always@(posedge mem_clk)begin
	if(mem_rst | fifo_clr_r1)begin
		maxcnt0 <= 0;
		maxdly <= 0;
	end
	else begin
		if(wrfifo_rd_en)begin
			maxdly <= {1'b1, counterfull} - wrfifo_dout[63:AWIDTH];
			if(maxcnt0<maxdly)maxcnt0 <= maxdly;
		end
	end
end

assign cfg_trans_maxdly = maxcnt0[15:0];
assign cfg_trans_errcnt = 0;

//`ifndef BYPASS_ALLSCOPE
ila_host2axi ila_axi2fifo_ep0(
.clk(mem_clk),
.probe0(m_axi_araddr  ),
.probe1(m_axi_arready ),
.probe2(m_axi_arvalid ),
.probe3(m_axi_rvalid ),
.probe4(m_axi_rlast),
.probe5(cfg_frame_len_q1), //cfg_trans_len  ),
.probe6(cfg_addr_dma_q1),
.probe7(ram_addr),
.probe8(cfg_size_dma_q1),  
.probe9(ram_dout_r1), 
.probe10(cfg_trans_underflow), 
.probe11(cfg_resp_error), 
.probe12(frame_cnt),
.probe13(trans_cnt),
.probe14(cstate),
.probe15(wr_data_count_q1),
.probe16(wrfifo_data_count),
.probe17(ram_enb),
.probe18(ram_we),
.probe19(cfg_axi_active_q1 ),
.probe20(ram_din ),
.probe21(m_axi_rdata ),
.probe22(m_axi_rresp )
);
//`endif
endmodule
