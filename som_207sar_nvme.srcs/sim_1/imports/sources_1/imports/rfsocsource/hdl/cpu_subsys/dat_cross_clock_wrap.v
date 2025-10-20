module dat_cross_clock_wrap #(
parameter WIDTH = 32
)
(
input reset,
input src_clk,
input [WIDTH-1:0] src_dat,

input dst_clk,
output reg [WIDTH-1:0] dst_dat
);

reg src_en = 0;
wire src_ack;
always@(posedge src_clk)begin
	if(reset)begin
        src_en <= 0;
    end
    else begin
        if(src_ack)src_en <= 0;
        else src_en <= 1;
    end
end    
wire dst_en;
wire [WIDTH-1:0] dst_dat_c;
dat_cross_clock 
#(
.WIDTH(WIDTH)
)
dat_cross_clock_EP0(
.reset(reset),    //input 
.src_clk(src_clk),    //input 
.src_en(src_en),    //input 
.src_dat(src_dat),    //input [WIDTH-1:0]
.src_ack(src_ack),    //output 
.dst_clk(dst_clk),    //input 
.dst_en(dst_en),    //output 
.dst_dat(dst_dat_c)    //output [WIDTH-1:0]
);

always@(posedge dst_clk)begin
    if(dst_en)dst_dat <= dst_dat_c;
end
endmodule
