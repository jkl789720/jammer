module BC_SPI_CTRL(
input clk,  // 100MHz
input reset,

input 			rama_clk,
input 			rama_rst,
input [3:0] 	rama_we,
input [31:0]	rama_addr,
input [31:0]	rama_din,
output [31:0]	rama_dout,

input [31:0] 	CFGBC_GRPNUM,
input [31:0] 	CFGBC_MODE,
input 			CFGBC_OUTEN,
input [31:0] 	CFGBC_DELAY,

output 			BC_CLK,
output [3:0] 	BC_TXD,
output 			BC_CS,
output 			BC_RXEN,
output 			BC_TXEN,
output 			BC_LATCH,
input 			BC_RXD
);
// config IF
wire ramb_clk;
wire ramb_rst;
wire [7:0]ramb_we;
reg [31:0]ramb_addr;
wire [63:0]ramb_din;
wire [63:0]ramb_dout;
assign ramb_clk = clk;
assign ramb_rst = reset;
assign ramb_we = 8'h0;
assign ramb_din = 64'h0;
blkram64x1024 bramep0 (
  .clka(rama_clk),    // input wire clka
  .rsta(rama_rst),    // input wire rsta
  .wea(rama_we),      // input wire [7 : 0] wea
  .addra(rama_addr),  // input wire [9 : 0] addra
  .dina(rama_din),    // input wire [63 : 0] dina
  .douta(rama_dout),  // output wire [63 : 0] douta
  .clkb(ramb_clk),    // input wire clkb
  .rstb(ramb_rst),    // input wire rstb
  .web(ramb_we),      // input wire [7 : 0] web
  .addrb(ramb_addr),  // input wire [9 : 0] addrb
  .dinb(ramb_din),    // input wire [63 : 0] dinb
  .doutb(ramb_dout)  // output wire [63 : 0] doutb
);

wire delay_start ;
wire cfg_start = CFGBC_MODE[0];
reg cfg_start_r1, cfg_start_r2;
wire cfg_active;
assign cfg_active = cfg_start_r1 & (~cfg_start_r2);
reg [7:0] grpnum = 0;
reg [31:0] delay = 0;
reg delay_start_flag = 0;
localparam DWIDTH = 20;
reg [DWIDTH:0] CFGBC_OUTEN_r = 0;
always@(posedge clk)begin
	cfg_start_r1 <= cfg_start;
	cfg_start_r2 <= cfg_start_r1;
	if(cfg_active)begin
		grpnum <= CFGBC_GRPNUM;
		delay_start_flag <= CFGBC_MODE[1];
		delay <= CFGBC_DELAY;
	end
	CFGBC_OUTEN_r <= {CFGBC_OUTEN_r[DWIDTH-1:0], CFGBC_OUTEN};
end

// 2 SPI slave mode
// select current active group
// data trnasfer: BC_CS=0 & BC_RXEN=0
// cmd trnasfer: BC_CS=1 & BC_RXEN=1
// error state, ignore : BC_CS=1 & BC_RXEN=0, BC_CS=0 & BC_RXEN=1
reg 			cfg_wr_en;
reg [511:0] 	cfg_wr_src;
wire [319:0] 	cfg_wr_dat;
wire	        cfg_done;
wire  SPI0_CS;
wire  SPI0_SCLK;
wire [3:0] SPI0_MOSI;
BC_CFG2SPI 
#(.DATA_WIDTH(80))
spidata(
.clk(clk),    //input 
.reset(reset),    //input 
.cfg_wr_en(cfg_wr_en),    //input 
.cfg_wr_dat(cfg_wr_dat),    //input [4*DATA_WIDTH-1:0]
.cfg_done(cfg_done),    //output 
.SPI_CS(SPI0_CS),    //output 
.SPI_SCLK(SPI0_SCLK),    //output 
.SPI_MOSI(SPI0_MOSI),    //output [3:0]
.SPI_MISO(BC_RXD)    //input 
);
genvar kk;
generate
for(kk=0;kk<16;kk=kk+1)begin:blk1
	assign cfg_wr_dat[20*kk+19:20*kk] = cfg_wr_src[32*kk+19:32*kk];
end
endgenerate
reg 			cmd_wr_en;
reg [39:0] 		cmd_wr_dat;
wire	        cmd_done;
wire  SPI1_CS;
wire  SPI1_SCLK;
wire [3:0] SPI1_MOSI;

BC_CFG2SPI 
#(.DATA_WIDTH(10))
spicmd(
.clk(clk),    //input 
.reset(reset),    //input 
.cfg_wr_en(cmd_wr_en),    //input 
.cfg_wr_dat(cmd_wr_dat),    //input [4*DATA_WIDTH-1:0]
.cfg_done(cmd_done),    //output 
.SPI_CS(SPI1_CS),    //output 
.SPI_SCLK(SPI1_SCLK),    //output 
.SPI_MOSI(SPI1_MOSI),    //output [3:0]
.SPI_MISO(BC_RXD)    //input 
);
reg latch_enable;
assign BC_LATCH = latch_enable;
reg cs_sel_cmd = 0;

assign BC_CLK = cs_sel_cmd?SPI1_SCLK:SPI0_SCLK;
assign BC_TXD = cs_sel_cmd?SPI1_MOSI:SPI0_MOSI;
assign BC_CS = cs_sel_cmd?1'b1:SPI0_CS;
assign BC_RXEN = cs_sel_cmd?(~SPI1_CS):1'b0;
//assign BC_RXEN = (|CFGBC_OUTEN_r);
//assign BC_TXEN = CFGBC_OUTEN_r[DWIDTH/2];
assign BC_TXEN = CFGBC_OUTEN;
// config state machine
reg [3:0] cstate;
localparam 
ST_IDLE = 0,
ST_GRP_SEL = 1,
ST_GRP_WAIT = 2,
ST_RD_RAM = 3,
ST_RD_WAIT = 4,
ST_CFG_CH = 5,
ST_CFG_WAIT = 6,
ST_LATCH_EN = 7,
ST_LATCH_WAIT = 8;

reg [7:0] grpcnt = 0;
reg [3:0] dlycnt = 0;
wire [9:0] 	cmd_data1 ;
wire [9:0] 	cmd_data2 ;
wire [9:0] 	cmd_data3 ;
wire [9:0] 	cmd_data4 ;
wire [39:0] cmd_data = {delay,{4{delay_start}},grpcnt[3:0]} ;
genvar i;
generate
	for(i=0;i<10;i=i+1)begin : labe1
		assign cmd_data1[i] = cmd_data[i*4] ;
		assign cmd_data2[i] = cmd_data[i*4+1] ;
		assign cmd_data3[i] = cmd_data[i*4+2] ;
		assign cmd_data4[i] = cmd_data[i*4+3] ;
	end
endgenerate
assign delay_start = (grpcnt == 0) ? delay_start_flag : 1'b0 ;
always@(posedge clk)begin
	if(reset)begin
		cstate <= 0;
		grpcnt <= 0;
		dlycnt <= 0;
		latch_enable <= 0;
		cs_sel_cmd <= 0;
		
		cfg_wr_en <= 0;
		cfg_wr_src <= 512'h0;
		cmd_wr_en <= 0;
		cmd_wr_dat <= 4'h0;
		ramb_addr <= 32'h0;
	end
	else begin
		case(cstate)
			ST_IDLE:begin
				if(cfg_active)cstate <= ST_GRP_SEL;
				else cstate <= ST_IDLE;
				grpcnt <= 0;
				dlycnt <= 0;
				latch_enable <= 0;
				cs_sel_cmd <= 0;
				
				cfg_wr_en <= 0;
				cfg_wr_src <= 512'h0;
				cmd_wr_en <= 0;
				cmd_wr_dat <= 4'h0;
				ramb_addr <= 32'h0;
			end
			ST_GRP_SEL:begin
				if(grpcnt<grpnum)cstate <= ST_GRP_WAIT;
				else cstate <= ST_LATCH_EN;
				if(grpcnt<grpnum)begin
					cstate <= ST_GRP_WAIT;
					cmd_wr_en <= 1;
					cmd_wr_dat <= {cmd_data4,cmd_data3,cmd_data2,cmd_data1};
					cs_sel_cmd <= 1;
				end
			end
			ST_GRP_WAIT:begin
				if(cmd_done)cstate <= ST_RD_RAM;
				else cstate <= ST_GRP_WAIT;
				cmd_wr_en <= 0;
			end
			ST_RD_RAM:begin
				cstate <= ST_RD_WAIT;
				dlycnt <= 12;
				grpcnt <= grpcnt + 1; 
				ramb_addr <= {grpcnt, 6'h0}; // each group use 128x4 bits
			end
			ST_RD_WAIT:begin
				// ramb_addr: 0		8	16	24	32	40	48	56
				// dlycnt:	  12	11	10	9	8	7	6	5	4	3	2	1
				// data(3 cycles delay):0	1	1	1	1	1	1	1	1	0
				if(dlycnt>0)cstate <= ST_RD_WAIT;
				else cstate <= ST_CFG_CH;
				if(dlycnt>0)dlycnt <= dlycnt - 1;
				ramb_addr <= ramb_addr + 8;
				if((dlycnt>1)&(dlycnt<10))begin
					cfg_wr_src[447:0] <= cfg_wr_src[511:64];
					cfg_wr_src[511:448] <= ramb_dout;
				end
			end
			ST_CFG_CH:begin
				cstate <= ST_CFG_WAIT;		
				cfg_wr_en <= 1;
				cs_sel_cmd <= 0;
			end
			ST_CFG_WAIT:begin
				if(cfg_done)cstate <= ST_GRP_SEL;
				else cstate <= ST_CFG_WAIT;
				cfg_wr_en <= 0;
			end
			ST_LATCH_EN:begin
				cstate <= ST_LATCH_WAIT;
				dlycnt <= 15;
				latch_enable <= 0;
			end
			ST_LATCH_WAIT:begin
				if(dlycnt>0)cstate <= ST_LATCH_WAIT;
				else cstate <= ST_IDLE;
				if(dlycnt>0)dlycnt <= dlycnt - 1;
				latch_enable <= 1;
			end
			default:begin
				cstate <= ST_IDLE;
				grpcnt <= 0;
				dlycnt <= 0;
				latch_enable <= 0;
				cs_sel_cmd <= 0;
				
				cfg_wr_en <= 0;
				cfg_wr_src <= 512'h0;
				cmd_wr_en <= 0;
				cmd_wr_dat <= 4'h0;
				ramb_addr <= 32'h0;
			end
		endcase
	end
end
`ifndef BYPASS_ALLSCOPE
ila_bcctrl  ila_bcctrl_ep(
.clk(clk),
.probe0(BC_CLK),
.probe1(BC_TXD),
.probe2(BC_CS),
.probe3(BC_RXEN),
.probe4(BC_TXEN),
.probe5(BC_LATCH),
.probe6(BC_RXD)
);
`endif
endmodule
