module gps_module
#(
parameter MSG_LEN = 12+24+8
)(
input clk,
input reset, 

input       rx_valid,
input [7:0] rx_data,
output reg [MSG_LEN*8-1:0]  msg_dat,
output reg [2:0]            msg_stat,
output reg                  msg_en
);
localparam POSLEN = 24;
localparam TIMLEN = 12;
localparam HEDLEN = 8;
localparam MIN_REFRESH_TIME = 25000000; // 25ms
localparam LOCAL_CLK_CYCLE = 20; // 50MHz
localparam MIN_REFRESH_CYCLE = MIN_REFRESH_TIME/LOCAL_CLK_CYCLE;

wire [POSLEN*8-1:0] bestpos_dat;
reg [POSLEN*8-1:0] bestpos_dat_r;
wire  bestpos_en;
wire  bestpos_stat;
reg  bestpos_stat_r;
gps_resolve 
#(
.MSG_ID(16'h2A00),
.MSG_LEN(104),
.DAT_OFF(28+8),
.DAT_LEN(POSLEN)
) bestpos_ep(
.clk(clk),    //input 
.reset(reset),    //input 
.rx_valid(rx_valid),    //input 
.rx_data(rx_data),    //input [7:0]
.out_dat(bestpos_dat),    //output [DAT_LEN*8-1:0]
.out_en(bestpos_en),    //output 
.out_stat(bestpos_stat)    //output 
);

wire [TIMLEN*8-1:0] time_dat;
reg [TIMLEN*8-1:0] time_dat_r;
wire  time_en;
wire  time_stat;
reg  time_stat_r;
gps_resolve 
#(
.MSG_ID(16'h6500),
.MSG_LEN(76),
.DAT_OFF(28+28),
.DAT_LEN(TIMLEN)
) time_ep(
.clk(clk),    //input 
.reset(reset),    //input 
.rx_valid(rx_valid),    //input 
.rx_data(rx_data),    //input [7:0]
.out_dat(time_dat),    //output [DAT_LEN*8-1:0]
.out_en(time_en),    //output 
.out_stat(time_stat)    //output 
);

wire [HEDLEN*8-1:0] heading_dat;
reg [HEDLEN*8-1:0] heading_dat_r;
wire  heading_en;
wire  heading_stat;
reg  heading_stat_r;
gps_resolve 
#(
.MSG_ID(16'hCB03),
.MSG_LEN(76),
.DAT_OFF(28+8),
.DAT_LEN(HEDLEN)
) heading_ep(
.clk(clk),    //input 
.reset(reset),    //input 
.rx_valid(rx_valid),    //input 
.rx_data(rx_data),    //input [7:0]
.out_dat(heading_dat),    //output [DAT_LEN*8-1:0]
.out_en(heading_en),    //output 
.out_stat(heading_stat)    //output 
);

reg [2:0] allvalid;
reg [31:0] tcnt;
always@(posedge clk)begin
    if(reset)begin
        tcnt <= 0;
        allvalid <= 0;
        
        msg_en <= 0;
        msg_dat <= {MSG_LEN{8'h00}};
        msg_stat <= 3'b000;
        
        bestpos_dat_r <= {POSLEN{8'h0}};
        bestpos_stat_r <= 0;
        time_dat_r <= {POSLEN{8'h0}};
        time_stat_r <= 0;
        heading_dat_r <= {HEDLEN{8'h0}};
        heading_stat_r <= 0;        
    end
    else begin
        if(bestpos_en|time_en|heading_en)tcnt <= 0;
        else if(tcnt<32'hFFFFFFFF)tcnt <= tcnt + 1;
        
        if((tcnt>MIN_REFRESH_CYCLE)&(allvalid>0))allvalid <= 0;
        else begin
           if(heading_en)allvalid[0] <= 1;
           if(bestpos_en)allvalid[1] <= 1;
           if(time_en)allvalid[2] <= 1;
        end
        
        if(allvalid==3'b111)begin
            msg_en <= 1;
            msg_dat <= {time_dat, bestpos_dat, heading_dat};
            msg_stat <= {time_stat, bestpos_stat, heading_stat};
            allvalid <= 0;
        end
        else msg_en <= 0;
        
        if(bestpos_en)bestpos_dat_r <= bestpos_dat;
        if(bestpos_en)bestpos_stat_r <= bestpos_stat;
        if(time_en)time_dat_r <= time_dat;
        if(time_en)time_stat_r <= time_stat;
        if(heading_en)heading_dat_r <= heading_dat;
        if(heading_en)heading_stat_r <= heading_stat;
    end
end
endmodule
