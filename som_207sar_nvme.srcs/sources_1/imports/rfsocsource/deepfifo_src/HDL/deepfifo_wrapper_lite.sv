/********************************************************************************
 * Date: 2017/10/12
 * Function: convert axi4 lite content to register
 * 1. if awvalid and arvalid assert at the same time, write process has higher priority
 * 2. awready and arready will not assert unless awvalid or arvalid is high
 * 3. ignore the write strobes and treat all write accesses as being the full data bus width
 * 4. ignore app_awprot
 * 5. write and read response 
 ********************************************************************************/
 `define OKAY 		2'b00
 `define EXOKAY 	2'b01
 `define SLVERR		2'b10
 `define DECERR 	2'b11
 
 `include "axi_interface.svh" 
 
 
module deepfifo_wrapper_lite
#(
    parameter HIGH_END = 32'h0002_0000,
    parameter LOW_END = 32'h0001_F000
)
(
// Write address, data and response
input [31:0]				app_awaddr,
input [2:0]					app_awprot,
output reg					app_awready,
input 						app_awvalid,
input [31:0]				app_wdata,
output reg 					app_wready,
input [3:0]					app_wstrb,
input 						app_wvalid,	
input 						app_bready,
output reg [1:0]			app_bresp,
output reg					app_bvalid,

// Read address and data
input [31:0]				app_araddr,
input [2:0]					app_arprot,
output reg					app_arready,
input 						app_arvalid,	
output reg [31:0]			app_rdata,
input 						app_rready,
output reg [1:0]			app_rresp,
output reg					app_rvalid, 
//axi4.AXI_Lite_S app_lite_S,
// Control signals
input						axi_aresetn,
input						axi_aclk,

// reg IF
output reg [31:0] cfg_deepfifo_ctrl,
input      [31:0] cfg_deepfifo_status,
input      [31:0] cfg_deepfifo_max_depth,
input      [31:0] cfg_deepfifo_nonbypass_data_L,
input      [31:0] cfg_deepfifo_nonbypass_data_H,
input      [31:0] cfg_deepfifo_total_data_L,
input      [31:0] cfg_deepfifo_total_data_H,
input      [31:0] cfg_deepfifo_status7,
input      [31:0] cfg_deepfifo_status8
   
);

reg [31:0] cfg_wr_addr;
reg [31:0] cfg_wr_dat;
reg  cfg_wr_en;
reg [31:0] cfg_rd_addr;
wire [31:0] cfg_rd_dat;
reg  cfg_rd_en;

wire cfg_clk = axi_aclk;
reg cfg_rst;



//wire  [31:0] cfg_deepfifo_ctrl;
//wire  [31:0] cfg_deepfifo_status;
//wire  [31:0] cfg_deepfifo_max_depth;
//wire  [31:0] cfg_deepfifo_nonbypass_data_L;
//wire  [31:0] cfg_deepfifo_nonbypass_data_H;
//wire  [31:0] cfg_deepfifo_total_data_L;
//wire  [31:0] cfg_deepfifo_total_data_H;
//wire  [31:0] cfg_deepfifo_status7;
//wire  [31:0] cfg_deepfifo_status;
always@(posedge cfg_clk)cfg_rst <= ~axi_aresetn;
register_set_deepfifo register_set_deepfifo_EP0(
.cfg_deepfifo_ctrl(cfg_deepfifo_ctrl),
.cfg_deepfifo_status(cfg_deepfifo_status),
.cfg_deepfifo_max_depth(cfg_deepfifo_max_depth),
.cfg_deepfifo_nonbypass_data_L(cfg_deepfifo_nonbypass_data_L),
.cfg_deepfifo_nonbypass_data_H(cfg_deepfifo_nonbypass_data_H),
.cfg_deepfifo_total_data_L(cfg_deepfifo_total_data_L),
.cfg_deepfifo_total_data_H(cfg_deepfifo_total_data_H),
.cfg_deepfifo_status7(cfg_deepfifo_status7),
.cfg_deepfifo_status8(cfg_deepfifo_status8),

.cfg_clk(cfg_clk),    //input 
.cfg_rst(cfg_rst),    //input 
.cfg_wr_addr(cfg_wr_addr),    //input [11:0]
.cfg_wr_dat(cfg_wr_dat),    //input [31:0]
.cfg_wr_en(cfg_wr_en),    //input 
.cfg_rd_addr(cfg_rd_addr),    //input [11:0]
.cfg_rd_dat(cfg_rd_dat),    //output [31:0]
.cfg_rd_en(cfg_rd_en)    //input 
);

localparam IDLE = 4'h0;
localparam WRADDR = 4'h1;
localparam WRDATA = 4'h2;
localparam WRWAIT = 4'h7;
localparam WRRESP = 4'h3;
localparam RDADDR = 4'h4;
localparam RDWAIT = 4'h5;
localparam RDDATA = 4'h6;
reg [3:0] nstate;
reg [3:0] cstate;
reg [3:0] cmdcnt;
wire cfg_wr_done = 1;
wire cfg_rd_done = 1;
always@(*)begin
	nstate = IDLE;
	case(cstate)
		IDLE:begin
			if(app_awvalid)nstate = WRADDR;
			else if(app_arvalid)nstate = RDADDR;
			else nstate = IDLE;
		end
		WRADDR:begin
			if(app_awvalid&app_awready)nstate = WRDATA;
			else nstate = WRADDR;
		end
		WRDATA:begin
			if(app_wvalid&app_wready)nstate = WRWAIT;
			else nstate = WRDATA;
		end
		WRWAIT:begin
			if((cmdcnt>3)&&cfg_wr_done)nstate = WRRESP;
			else nstate = WRWAIT;
		end
		WRRESP:begin
			if(app_bready&app_bvalid)nstate = IDLE;
			else nstate = WRRESP;
		end
		RDADDR:begin
			if(app_arvalid&app_arready)nstate = RDWAIT;
			else nstate = RDADDR;
		end
		RDWAIT:begin
			if((cmdcnt>3)&&cfg_rd_done)nstate = RDDATA;
			else nstate = RDWAIT;
		end
		RDDATA:begin
			if(app_rvalid&app_rready)nstate = IDLE;
			else nstate = RDDATA;
		end
		default:begin
			nstate = IDLE;
		end
	endcase
end

always@(posedge axi_aclk)begin
	if(~axi_aresetn)begin
		cstate <= IDLE;
		app_arready <= 0;
		app_rdata <= 0;
		app_rresp <= 0;
		app_rvalid <= 0;
		app_awready <= 0;
		app_wready <= 0;
		app_bresp <= 0;
		app_bvalid <= 0;
		cfg_wr_addr <= 0;
		cfg_wr_dat <= 0;
		cfg_rd_addr <= 0;
		cfg_wr_en <= 0;
		cfg_rd_en <= 0;

		cmdcnt <= 0;
	end
	else begin
		cstate <= nstate;
		case(cstate)
			IDLE:begin
				if(app_awvalid)app_awready <= 1;
				else if(app_arvalid)app_arready <= 1;
				else begin
					app_arready <= 0;
					app_rdata <= 0;
					app_rresp <= 0;
					app_rvalid <= 0;
					app_awready <= 0;
					app_wready <= 0;
					app_bresp <= 0;
					app_bvalid <= 0;
					cfg_wr_addr <= 0;
					cfg_wr_dat <= 0;
					cfg_wr_en <= 0;
					cfg_rd_addr <= 0;
					cfg_rd_en <= 0;
					cmdcnt <= 0;
				end
			end
			WRADDR:begin
				if(app_awvalid&app_awready)begin
					app_awready <= 0;
					app_wready <= 1;
					cfg_wr_addr <= app_awaddr;
				end
			end
			WRDATA:begin
				if(app_wvalid&app_wready)begin
					app_wready <= 0;
					app_bvalid <= 0;
					if(cfg_wr_addr>=HIGH_END || cfg_wr_addr<LOW_END)begin
					   app_bresp <= `SLVERR;
					   cfg_wr_dat <= 0;
                       cfg_wr_en <= 0;
                    end
					else begin
					   app_bresp <= `OKAY;
					   cfg_wr_dat <= app_wdata;
					   cfg_wr_en <= 1;
					end
				end
				cmdcnt <= 0;
			end
			WRWAIT:begin
				if(cmdcnt<4)cmdcnt <= cmdcnt + 1;
				cfg_wr_en <= 0;
			end
			WRRESP:begin
				if(app_bready&app_bvalid)begin
					app_bvalid <= 0;
					app_bresp <= 0;
				end
				else app_bvalid <= 1;
			end
			RDADDR:begin
				if(app_arvalid&app_arready)begin
					app_arready <= 0;
					cfg_rd_addr <= app_araddr;
					if(app_araddr>=HIGH_END || app_araddr<LOW_END)cfg_rd_en <= 0;
					else cfg_rd_en <= 1;
				end
				cmdcnt <= 0;
			end
			RDWAIT:begin		
				cfg_rd_en <= 0;
				if(cmdcnt<4)cmdcnt <= cmdcnt + 1;
			end
			RDDATA:begin
				if(app_rvalid&app_rready)begin
					app_rvalid <= 0;
					app_rresp <= 0;
				end
				else begin
					app_rvalid <= 1;
					if(cfg_rd_addr>=HIGH_END || cfg_rd_addr<LOW_END)begin
					   app_rresp <= `SLVERR;
					   app_rdata <= -1;
					end
					else begin
					   app_rresp <= `OKAY;
					   app_rdata <= cfg_rd_dat;
					end	 
				end
			end
			default:begin
			end			
		endcase
	end
end

endmodule
