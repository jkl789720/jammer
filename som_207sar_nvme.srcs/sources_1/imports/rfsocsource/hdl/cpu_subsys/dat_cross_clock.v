module dat_cross_clock #(
parameter WIDTH = 8
)
(
input reset,
input src_clk,
input src_en,
input [WIDTH-1:0] src_dat,
output reg src_ack,

input dst_clk,
output reg dst_en,
output reg [WIDTH-1:0] dst_dat
);
// src domain
reg src_req;
reg src_en_q;
reg [WIDTH-1:0] src_dat_q;
reg dst_req;
reg dst_req_q;
wire dst_ack;
always@(posedge src_clk)begin
	if(reset)begin
		src_req <= 0;
		src_en_q <= 0;
		src_dat_q <= 0;
        src_ack <= 0;
	end
	else begin
		src_en_q <= src_en;
		
		if(src_ack)src_req <= 1'b0;
		else if(src_en & (~src_en_q))src_req <= 1'b1;
		
		if(src_en & (~src_en_q))src_dat_q <= src_dat;
        
        src_ack <= dst_ack;
	end
end


// dest domain
reg reset1 = 0;
always@(posedge dst_clk)reset1 <= reset;

assign dst_ack = dst_req;
always@(posedge dst_clk)begin
	if(reset1)begin
		dst_dat <= 0;
		dst_req <= 0;
		dst_req_q <= 0;
		dst_en <= 0;
	end
	else begin
		dst_req <= src_req;
		dst_req_q <= dst_req;
		dst_dat <= src_dat_q;
		if(~dst_req_q & dst_req)dst_en <= 1;
		else dst_en <= 0;
	end
end
endmodule
