`define BASE_AUXDATA_PARAM 16'h0000
module auxdata_format(
output [48*32-1:0] ctrl_data,
output [16*32-1:0] status_data,
output [24*32-1:0] param_data,
output [32*32-1:0] debug_data,

input [44*8-1:0] status_imu,
input [64*8-1:0] debug_imu,	// extend from 63 to 64


input 				cfg_clk,
input 				cfg_rst,
input  [11:0] 		cfg_wr_addr,
input  [31:0] 		cfg_wr_dat,
input 				cfg_wr_en,
input [11:0] 		cfg_rd_addr,
output reg [31:0] 	cfg_rd_dat,
input 				cfg_rd_en
);
reg [31:0] regfile_data [0:127];
(* max_fanout=50 *)reg [11:0] cfg_rd_addr_r1;
always@(posedge cfg_clk)cfg_rd_addr_r1 <= cfg_rd_addr;
(* max_fanout=100 *)reg cfg_rst_r1;
always@(posedge cfg_clk)cfg_rst_r1 <= cfg_rst;

reg  [11:0] 		cfg_wr_addr_r;
reg  [31:0] 		cfg_wr_dat_r;
reg 				cfg_wr_en_r;
always@(posedge cfg_clk)cfg_wr_addr_r <= cfg_wr_addr;
always@(posedge cfg_clk)cfg_wr_dat_r <= cfg_wr_dat;
always@(posedge cfg_clk)cfg_wr_en_r <= cfg_wr_en;


genvar kk;
generate
for(kk=0;kk<128;kk=kk+1)begin:blk1
	always@(posedge cfg_clk)begin
		if(cfg_rst)regfile_data[kk] <= 32'h0;
		else begin
			if(cfg_wr_en_r&(cfg_wr_addr_r==(`BASE_AUXDATA_PARAM+kk*4)))regfile_data[kk] <= cfg_wr_dat_r;
		end
	end
end
// ctrl_data
for(kk=0;kk<48;kk=kk+1)begin:blk2
	assign ctrl_data[kk*32+31:kk*32] = regfile_data[00+kk];
end
// status_data
//for(kk=0;kk<3;kk=kk+1)begin:blk31
//end	
assign status_data[0*32+31:0*32] = regfile_data[48+0];
assign status_data[1*32+31:1*32] = {debug_imu[39:32], regfile_data[48+1][23:0]};	// debug_imu[39:32] imu status
assign status_data[2*32+31:2*32] = regfile_data[48+2];

for(kk=3;kk<14;kk=kk+1)begin:blk32
	assign status_data[kk*32+31:kk*32] = status_imu[(kk-3)*32+31:(kk-3)*32];
end
for(kk=14;kk<16;kk=kk+1)begin:blk33
	assign status_data[kk*32+31:kk*32] = regfile_data[48+kk];
end
// param_data
for(kk=0;kk<24;kk=kk+1)begin:blk4
	assign param_data[kk*32+31:kk*32] = regfile_data[64+kk];
end
// debug_data
for(kk=0;kk<16;kk=kk+1)begin:blk51
	assign debug_data[kk*32+31:kk*32] = debug_imu[kk*32+31:kk*32];
end
for(kk=16;kk<32;kk=kk+1)begin:blk52
	assign debug_data[kk*32+31:kk*32] = regfile_data[88+kk];
end
endgenerate

reg [31:0] regfile_data_back [0:127];
always@(posedge cfg_clk)cfg_rd_dat <= regfile_data_back[cfg_rd_addr_r1[8:2]];
reg regfile_update;
reg update_r1, update_r2;
always@(posedge cfg_clk)begin
	update_r1 <= regfile_data[127][0];
	update_r2 <= update_r1;
	regfile_update <= (update_r1&(~update_r2));
end

generate
for(kk=0;kk<128;kk=kk+1)begin:blka
	if(kk<48)begin:blka1	// ctrl_data 0-47
		always@(posedge cfg_clk)begin
			if(regfile_update)regfile_data_back[kk] <= regfile_data[kk];
		end
	end
	else if(kk<64)begin:blka2	// status_data 48-63
		always@(posedge cfg_clk)begin
			if(regfile_update)regfile_data_back[kk] <= status_data[(kk-48)*32+31:(kk-48)*32];
		end
	end
	else if(kk<88)begin:blka3	// param_data 64-87
		always@(posedge cfg_clk)begin
			if(regfile_update)regfile_data_back[kk] <= regfile_data[kk];
		end
	end
	else if(kk<120)begin:blka4	// debug_data 88-119
		always@(posedge cfg_clk)begin
			if(regfile_update)regfile_data_back[kk] <= debug_data[(kk-88)*32+31:(kk-88)*32];	
		end
	end
	else begin:blka5	// resv_data 120-127
		always@(posedge cfg_clk)begin
			if(regfile_update)regfile_data_back[kk] <= regfile_data[kk];
		end
	end
end
endgenerate
endmodule