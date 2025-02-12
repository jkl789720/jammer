
// July 19, 2018. 
// 1. Add rddata_addr_lock to lock addr at reset. Fixing the bug in repeat mode.
// 2. Change To. m_axi_rready = 1;
// 3. When init_done_r1 asserted, go back to reset if in WAIT state. Fixing unexpected ending of timing_logic
// 4. Ignore rdfifo_empty in FINISH state
// May 16, 2018. First Version. Support both prf/frame format and continuous data.one fifo and one memory region. With 4KB boundary check.

`define OKAY 		2'b00
`define EXOKAY 		2'b01
`define SLVERR 		2'b10
`define DECERR 		2'b11
module mem2da
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

input [CFG_AWIDTH-1:0] tl_DA_base,
input [CFG_AWIDTH-1:0] tl_DA_rnum,
input tl_DA_repeat,
input tl_DA_reset,
output [31:0] tl_DA_status,

// control, must be in fifo_clk domain 
input fifo_clk,
input fifo_rst,

input mfifo_rd_clr,	// active high, only one cycle
input mfifo_rd_valid,
input mfifo_rd_enable,
output [DIN_WIDTH-1:0] mfifo_rd_data,

// axi4 read
input mem_init_done,
output reg [AWIDTH-1 : 0] 	m_axi_araddr,
output reg [LWIDTH-1 : 0] 	m_axi_arlen,
output reg [2 : 0]        	m_axi_arsize,
output reg                	m_axi_arvalid,
input                     	m_axi_arready,
input  [DOUT_WIDTH-1 : 0]  	m_axi_rdata,
input  [1 : 0]            	m_axi_rresp,
input                     	m_axi_rlast,
input                     	m_axi_rvalid,
output                  	m_axi_rready,
output  [1 : 0]           	m_axi_arburst,
output  [2 : 0]           	m_axi_arprot,
output                    	m_axi_arlock,
output  [3 : 0]           	m_axi_arcache
);
assign m_axi_arburst = 2'b01;     // INCR
assign m_axi_arprot = 3'b000;    // Unprivileged access, Non-secure access, Data access
assign m_axi_arcache = 4'b0011; // 0011 value recommended. Xilinx IP generally ignores (as slaves) or generates (as masters) transactions with Normal, Non-cacheable, Modifiable, and Bufferable
assign m_axi_arlock = 1'b0;     // Normal access
// data fifo
localparam DATA_LEN = 32;
localparam PAGE_ALIGN_MASK = 12'h7FF;	// 64*32=2048
localparam BURST_NUM = 8;
localparam prog_full_thresh = 512 - BURST_NUM*DATA_LEN - DATA_LEN;
localparam DEPTH_WIDTH = 9;
reg fifo_wr;
reg [DOUT_WIDTH-1:0] fifo_din;
wire [DEPTH_WIDTH-1:0] wr_data_count;
reg fifo_prog_full;
always@(posedge mem_clk)begin
	if(mem_rst)fifo_prog_full <= 0;
	else fifo_prog_full <= (wr_data_count>prog_full_thresh);
end
wire wr_rst_busy;
wire rd_rst_busy;
wire fifo_empty;
wire fifo_full;
generate
if(DIN_WIDTH==64)begin:blk1
mem2da_dfifo mem2da_dfifo_ep0(
.rst(mfifo_rd_clr), 
  
.wr_clk(mem_clk),   
.wr_en(fifo_wr),    
.din(fifo_din),  
.wr_rst_busy(wr_rst_busy),
.wr_data_count(wr_data_count),
  
.rd_clk(fifo_clk),   
.rd_en(mfifo_rd_enable),    
.dout(mfifo_rd_data),
.rd_rst_busy(rd_rst_busy)
);
end
else if(DIN_WIDTH==128)begin:blk1
mem2da_dfifox128 mem2da_dfifo_ep0(
.rst(mfifo_rd_clr), 
  
.wr_clk(mem_clk),   
.wr_en(fifo_wr),    
.din(fifo_din),  
.wr_rst_busy(wr_rst_busy),
.wr_data_count(wr_data_count),
  
.rd_clk(fifo_clk),   
.rd_en(mfifo_rd_enable),    
.dout(mfifo_rd_data),
.rd_rst_busy(rd_rst_busy)
);
end
else if(DIN_WIDTH==256)begin:blk1
mem2da_dfifox256 mem2da_dfifo_ep0(
.rst(mfifo_rd_clr), 
  
.wr_clk(mem_clk),   
.wr_en(fifo_wr),    
.din(fifo_din),  
.full(fifo_full), 
.wr_rst_busy(wr_rst_busy),
.wr_data_count(wr_data_count),
  
.rd_clk(fifo_clk),   
.rd_en(mfifo_rd_enable),
.empty(fifo_empty),    
.dout(mfifo_rd_data),
.rd_rst_busy(rd_rst_busy)
);
end
else begin
//mem2da_dfifox32 x32 fifo not exist
mem2da_dfifo mem2da_dfifo_ep0(
.rst(mfifo_rd_clr), 
  
.wr_clk(mem_clk),   
.wr_en(fifo_wr),    
.din(fifo_din),  
.wr_rst_busy(wr_rst_busy),
.wr_data_count(wr_data_count),
  
.rd_clk(fifo_clk),   
.rd_en(mfifo_rd_enable),    
.dout(mfifo_rd_data),
.rd_rst_busy(rd_rst_busy)
);
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
assign rdfifo_rd_en = m_axi_rvalid&m_axi_rready&m_axi_rlast;
//assign m_axi_rready = ~rdfifo_empty; // why not change to 1 for more safty.
assign m_axi_rready = 1;

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
		init_done_r1 <= init_done_r0 & tl_DA_reset;
	end
end
localparam	
	IDLE   = 4'd0,
	RESET  = 4'd1,
	WAIT0  = 4'd2,
	RDDATA = 4'd3,
	RDRESP = 4'd4,
	FINISH = 4'd5;
reg [3:0] cstate;
reg [3:0] nstate;
reg [3:0] cmd_cnt;
reg [31:0] frame_cnt;
always@(*) begin
	nstate = IDLE;
	case(cstate)
	IDLE:begin
		if(init_done_r1)nstate = RESET;
		else nstate = IDLE;
	end
	RESET:begin
		if(cmd_cnt>0)nstate = RESET;
		else nstate = WAIT0;
	end
	WAIT0:begin
		if(init_done_r1)nstate = RESET;
		else if((frame_cnt==0) & (~tl_DA_repeat))nstate = FINISH;	// start=0, stop transfer
		else if(~fifo_prog_full & (frame_cnt>0))nstate = RDDATA;
		else nstate = WAIT0;
	end
	RDDATA:begin
		if(m_axi_arvalid&m_axi_arready)nstate = RDRESP;
		else nstate = RDDATA;
	end
	RDRESP:begin
		if(rdfifo_data_count<NON_RESP_CMD_COUNT)nstate = WAIT0;
		else nstate = RDRESP;
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
reg fibre_done;
reg [CFG_AWIDTH-1:0] rddata_addr;
reg [CFG_AWIDTH-1:0] rddata_addr_lock;
reg [CFG_AWIDTH-1:0] frame_cnt_lock;
always@(posedge mem_clk) begin
	if(mem_rst) begin
		cstate <= IDLE;
		rdfifo_srst <= 1;
		rdfifo_din <= 0;
		rdfifo_wr_en <= 0;
		m_axi_araddr <= 0;
		m_axi_arlen <= 0;
		m_axi_arsize <= 0;
		m_axi_arvalid <= 0;
		frame_cnt <= 'b0;
		cmd_cnt <= 0;
		fibre_done <= 1;
		rddata_addr <= 0;
		rddata_addr_lock <= 0;
		frame_cnt_lock <= 0;
	end
	else begin
		cstate <= nstate;
		case(cstate)
		IDLE:begin
			rdfifo_din <= 0;
			rdfifo_wr_en <= 0;
			m_axi_araddr <= 0;
			m_axi_arlen <= 0;
			m_axi_arsize <= 0;
			m_axi_arvalid <= 0;
			if(init_done_r1)begin
				rddata_addr_lock <= tl_DA_base;
				frame_cnt_lock <= tl_DA_rnum[CFG_AWIDTH-1:DATA_SIZE];
				cmd_cnt <= 15;
				rdfifo_srst <= 1;
				fibre_done <= 0;
			end
			else begin
				rddata_addr <= 0;
				frame_cnt <= 'b0;
				cmd_cnt <= 0;
				rdfifo_srst <= 0;
				fibre_done <= 1;
			end
		end
		RESET:begin
			if(cmd_cnt>0)cmd_cnt <= cmd_cnt - 1;
			rdfifo_srst <= 0;
			rddata_addr <= rddata_addr_lock;
			frame_cnt <= frame_cnt_lock;
		end
		WAIT0:begin
			rdfifo_din <= 0;
			rdfifo_wr_en <= 0;
			m_axi_araddr <= 0;
			m_axi_arlen <= 0;
			m_axi_arsize <= 0;
			m_axi_arvalid <= 0;			
			if(init_done_r1)begin
				rddata_addr_lock <= tl_DA_base;
				frame_cnt_lock <= tl_DA_rnum[CFG_AWIDTH-1:DATA_SIZE];
				cmd_cnt <= 15;
				rdfifo_srst <= 1;
				fibre_done <= 0;
			end
			else begin
				rdfifo_srst <= 0;

				// Logic for repeat scene
				if(tl_DA_repeat & (frame_cnt==0))begin
					rddata_addr <= rddata_addr_lock;
					frame_cnt <= frame_cnt_lock;
				end
			end
		end
		RDDATA:begin
			rdfifo_srst <= 0;
			if(m_axi_arready&m_axi_arvalid)begin
				m_axi_arvalid <= 0;
				// 4KB boundary check
				if((rddata_addr[11:0]&PAGE_ALIGN_MASK)==0)begin
					if(frame_cnt>=DATA_LEN)begin
						rddata_addr <= rddata_addr + (2**DATA_SIZE)*DATA_LEN;    
						frame_cnt <= frame_cnt - DATA_LEN;
					end
					else begin
						rddata_addr <= rddata_addr + {frame_cnt, {DATA_SIZE{1'b0}}};    
						frame_cnt <= 0;
					end
				end
				else begin
					rddata_addr <= rddata_addr + (2**DATA_SIZE);   
					frame_cnt <= frame_cnt - 1;
				end
				rdfifo_wr_en <= 1;
				rdfifo_din <= m_axi_araddr;
			end
			else begin
			    // change following to wrap address on REC_MEM_WRAP
				m_axi_araddr <= rddata_addr;
				// 4KB boundary check
				if((rddata_addr[11:0]&PAGE_ALIGN_MASK)==0)begin
					if(frame_cnt>=DATA_LEN)m_axi_arlen <= DATA_LEN-1;
					else m_axi_arlen <= frame_cnt-1;
				end
				else m_axi_arlen <= 0;
				m_axi_arsize <= DATA_SIZE;
				m_axi_arvalid <= 1;    
				rdfifo_wr_en <= 0;
			end
		end
		RDRESP:begin
			rdfifo_srst <= 0;
			rdfifo_din <= 0;
			rdfifo_wr_en <= 0;
			m_axi_araddr <= 0;
			m_axi_arlen <= 0;
			m_axi_arsize <= 0;
			m_axi_arvalid <= 0;
		end
		FINISH:begin
			fibre_done <= rdfifo_empty;
		end
		default:begin
		end
		endcase
	end
end
//---------------------- mem read side ---------------------//
// data format
// MSB -> LSB by DIN_WIDTH
// -> 512bits: {Q31,... , Q24}, {Q23, ... , Q16}, {...}, {...}
// -> 512bits: {Q7,... , Q0}, {Q15, ... , Q8}, {...}, {...}
wire [DOUT_WIDTH-1:0] m_axi_rdata_reorder;
localparam REORDER_RATE = DOUT_WIDTH/DIN_WIDTH;
genvar kk;
generate
for(kk=0;kk<REORDER_RATE;kk=kk+1)begin:reorder_block
	assign
		m_axi_rdata_reorder[DIN_WIDTH*(REORDER_RATE-kk-1)+DIN_WIDTH-1:DIN_WIDTH*(REORDER_RATE-kk-1)] 
		= m_axi_rdata[DIN_WIDTH*kk+DIN_WIDTH-1:DIN_WIDTH*kk];
end
endgenerate

reg rd_fail;
always@(posedge mem_clk) begin
	if(mem_rst) begin
		fifo_din <= 0;
		fifo_wr <= 0;
		rd_fail <= 0;
	end
	else begin
		if(rdfifo_srst)begin
			rd_fail <= 0;
			fifo_din <= 0;
			fifo_wr <= 0;			
		end
		else if(m_axi_rvalid&m_axi_rready)begin
			fifo_din <= m_axi_rdata_reorder;
			fifo_wr <= 1;
			if(m_axi_rresp != `OKAY)rd_fail <= 1;
		end
		else begin
			fifo_din <= 0;
			fifo_wr <= 0;
		end
	end
end

ila_mem2da ila_mem2da_ep0(
.clk(mem_clk),
.probe0(mem_rst  ),
.probe1(fifo_wr),
.probe2(tl_DA_rnum ),
.probe3(tl_DA_base ),
.probe4(frame_cnt),
.probe5(m_axi_arvalid),
.probe6(m_axi_araddr),
.probe7(m_axi_arready),
.probe8(frame_cnt_lock),
.probe9(fifo_empty),
.probe10(fifo_full),
.probe11(fifo_prog_full),
.probe12(wr_data_count),
.probe13(cstate),
.probe14(m_axi_rvalid),
.probe15(m_axi_rready),
.probe16(m_axi_rdata)
);

assign tl_DA_status[0] = fibre_done;
assign tl_DA_status[1] = rd_fail;
assign tl_DA_status[5:2] = cstate;
assign tl_DA_status[31:6] = 0;

endmodule
