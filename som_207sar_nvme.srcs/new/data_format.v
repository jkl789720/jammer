// this module format data with AD/GPS/imu and desample rate

//`define DATA_FORMAT_ONE

module data_format(
input adc_clk,
input adc_rst,

//input preprf,
input prfin,
input fifo_wr_clr,
input fifo_wr_valid,
input fifo_wr_enable,
input [31:0] cfg_AD_rnum,
output reg fifo_overflow,

input [255:0] adc0_data,
input [255:0] adc1_data,
input [7:0] div_width,
input [7:0] div_pulse,
input [192*8-1:0] ctrl_data,
input [64*8-1:0] status_data,
input [96*8-1:0] param_data,
input [128*8-1:0] debug_data,

input adc_ready,
output adc_valid,
output [255:0] adc_data
);

// head data 32bytes
reg [32*8-1:0] head_data;
localparam FRM_HDR0 = 32'h11FFFF11;
localparam FRM_HDR1 = 32'h20230211;
localparam filler = 64'h4444333322221111;
reg prf_sync_p1, prf_sync_p2;
wire adc_new_prf = prf_sync_p1 & (~prf_sync_p2);
reg [63:0] adctimer;
reg [31:0] adccount;
reg [31:0] adclength;
wire adc_new_timer = 0;
wire fifo_full;
always@(posedge adc_clk)begin
	if(adc_rst)begin
		prf_sync_p1 <= 0;
		prf_sync_p2 <= 0;
		adctimer <= 64'h0;
		adccount <= 0;
		adclength <= 0;
		head_data <= 256'h0;
		fifo_overflow <= 0;
	end
	else begin
		if(fifo_wr_clr)begin
			prf_sync_p1 <= 0;
			prf_sync_p2 <= 0;
			adctimer <= 64'h0;
			adccount <= 0;		
			fifo_overflow <= 0;
		end
		else begin
			if(fifo_full)fifo_overflow <= 1;
			adclength <= cfg_AD_rnum;	// change back to 1 channel on 0817
			prf_sync_p1 <= prfin;
			prf_sync_p2 <= prf_sync_p1;
			if(adc_new_timer)adctimer <= 0;
			else if(adctimer<64'hFFFFFFFFFFFFFFFF)adctimer <= adctimer + 1;
			if(adc_new_timer)adccount <= 0;
			else if((adccount<32'hFFFFFFFF)&&adc_new_prf)adccount <= adccount + 1;
			head_data <= {filler, adclength, adccount, adctimer, FRM_HDR1, FRM_HDR0};
		end
	end
end
wire [511:0] fifo_wr_tdata;
genvar kk;
generate

// I0 Q0 I1 Q1 ...
for(kk=0;kk<8;kk=kk+1)begin:blk1
	assign fifo_wr_tdata[kk*64+31:kk*64+00] = adc0_data[kk*32+31:kk*32];
	assign fifo_wr_tdata[kk*64+63:kk*64+32] = adc1_data[kk*32+31:kk*32];
end
endgenerate
reg fifo_data_enable = 0;
reg fifo_head_enable = 0;
reg data_wr1 = 0;
reg [511:0] data_din1;


`ifndef DATA_FORMAT_ONE
// head data 32bytes
wire fifo_rd_en;
wire [255:0] fifo_dout;

wire fifo_empty;
reg [511:0] fifo_din;
reg [511:0] fifo_pipe;
wire [511:0] fifo_din_c;
reg fifo_wr_en;
dataform_fifo dataform_fifo_ep (
  .clk(adc_clk),                      // input wire clk
  .srst(fifo_wr_clr),                    // input wire srst
  .din(fifo_din_c),                      // input wire [511 : 0] din
  .wr_en(fifo_wr_en),                  // input wire wr_en
  .rd_en(fifo_rd_en),                  // input wire rd_en
  .dout(fifo_dout),                    // output wire [127 : 0] dout
  .full(fifo_full),                    // output wire full
  .empty(fifo_empty)                  // output wire empty
);
assign fifo_rd_en = adc_valid & adc_ready;
assign adc_valid = ~fifo_empty;
assign adc_data = fifo_dout;

reg [5:0] fifo_wcnt;


assign fifo_din_c[255:0] = fifo_din[511:256];
assign fifo_din_c[511:256] = fifo_din[255:0];


always@(posedge adc_clk)begin
	if(adc_rst)begin
		fifo_din <= 512'h0;
		fifo_pipe <= 512'h0;
		fifo_wr_en <= 0;
		fifo_wcnt <= 0;
		fifo_data_enable <= 0;
		fifo_head_enable <= 0;
	end
	else begin
		fifo_wr_en <= fifo_head_enable | data_wr1;
		fifo_din <= fifo_head_enable?fifo_pipe:data_din1;
		fifo_data_enable <= fifo_wr_enable & (fifo_wcnt>=8);
		fifo_head_enable <= fifo_wr_enable & (fifo_wcnt<8);
		if(fifo_wr_enable)begin
			if(fifo_wcnt<6'h3F)fifo_wcnt <= fifo_wcnt + 1;	
			case(fifo_wcnt)
				0: fifo_pipe <= {ctrl_data[255:0], head_data};
				1: fifo_pipe <= ctrl_data[256*3-1:256];
				2: fifo_pipe <= ctrl_data[256*5-1:256*3];
				3: fifo_pipe <= {status_data[255:0], ctrl_data[256*6-1:256*5]};
				4: fifo_pipe <= {param_data[255:0], status_data[511:256]};
				5: fifo_pipe <= param_data[256*3-1:256];
				6: fifo_pipe <= debug_data[511:0];
				7: fifo_pipe <= debug_data[1023:512];
				default:fifo_pipe <= data_din1;
			endcase
		end
		else begin
			fifo_pipe <= 0;
			fifo_wcnt <= 0;			
		end
	end
end
`else   //channel one 256
// head data 32bytes
wire fifo_rd_en;
wire [255:0] fifo_dout;

wire fifo_empty;
reg [255:0] fifo_din;
reg [255:0] fifo_pipe;

reg fifo_wr_en;
dataform_fifo_256 dataform_fifo_ep (
  .clk(adc_clk),                      // input wire clk
  .srst(fifo_wr_clr),                    // input wire srst
  .din(fifo_din),                      // input wire [255 : 0] din
  .wr_en(fifo_wr_en),                  // input wire wr_en
  .rd_en(fifo_rd_en),                  // input wire rd_en
  .dout(fifo_dout),                    // output wire [127 : 0] dout
  .full(fifo_full),                    // output wire full
  .empty(fifo_empty)                  // output wire empty
);
assign fifo_rd_en = adc_valid & adc_ready;
assign adc_valid = ~fifo_empty;
assign adc_data = fifo_dout;

reg [5:0] fifo_wcnt;

wire [255:0] fifo_wr_tdata;
wire [255:0] data_din1_r1;
generate
for(kk=0;kk<8;kk=kk+1)begin:blk2
	assign data_din1_r1[kk*32+31:kk*32+00] = data_din1[kk*63+31:kk*64];
end
endgenerate

always@(posedge adc_clk)begin
	if(adc_rst)begin
		fifo_din <= 256'h0;
		fifo_pipe <= 256'h0;
		fifo_wr_en <= 0;
		fifo_wcnt <= 0;
		fifo_data_enable <= 0;
		fifo_head_enable <= 0;
	end
	else begin
		fifo_wr_en <= fifo_head_enable | data_wr1;
		fifo_din <= fifo_head_enable?fifo_pipe:data_din1;
		fifo_data_enable <= fifo_wr_enable & (fifo_wcnt>=16);
		fifo_head_enable <= fifo_wr_enable & (fifo_wcnt<16);
		if(fifo_wr_enable)begin
			if(fifo_wcnt<6'h3F)fifo_wcnt <= fifo_wcnt + 1;	
			case(fifo_wcnt)
				0: fifo_pipe <= head_data;
				0: fifo_pipe <= ctrl_data[255:0];
				1: fifo_pipe <= ctrl_data[256*2-1:256];
				1: fifo_pipe <= ctrl_data[256*3-1:256*2];
				2: fifo_pipe <= ctrl_data[256*4-1:256*3];
				2: fifo_pipe <= ctrl_data[256*5-1:256*4];
				3: fifo_pipe <= ctrl_data[256*6-1:256*5];
				3: fifo_pipe <= status_data[255:0];
				4: fifo_pipe <=  status_data[511:256];
				4: fifo_pipe <= param_data[255:0];
				5: fifo_pipe <= param_data[256*2-1:256];
				5: fifo_pipe <= param_data[256*3-1:256*2];
				6: fifo_pipe <= debug_data[255:0];
				6: fifo_pipe <= debug_data[511:256];
				7: fifo_pipe <= debug_data[767:512];
				7: fifo_pipe <= debug_data[1023:768];
				default:fifo_pipe <= data_din1;
			endcase
		end
		else begin
			fifo_pipe <= 0;
			fifo_wcnt <= 0;			
		end
	end
end
`endif
`ifndef BYPASS_ALLSCOPE
ila_dataformat ila_ila_dataformat_EP0(
.clk(adc_clk),
.probe0(adc_valid),
.probe1(adc_ready),
//.probe2(post_fifo_full ),
.probe2(fifo_wr_clr),
.probe3(fifo_wr_en),
.probe4(data_wr1),
.probe5(fifo_wr_enable),
.probe6(fifo_wcnt),
.probe7(prfin)
);
`endif
// data width from 512 to 64; divide from 1 to 24
/*
闂佹彃娲﹂悧閬嶆晸閿燂拷?	div_width	濞达絽绉撮鏃堟晬閸繂钃熼梺顐ｅ哺娴滈箖鏁撻敓锟�?	闁绘劘顫夐弳锟�
1200	0			512				8
600		1			256				4
300		3			128				2
150		7			64				1

闂佹彃娲﹂悧閬嶆晸閿燂拷?	div_pulse	濞达絽绉撮鏃堟晬閸繂钃熼梺顐ｅ哺娴滈箖鏁撻敓锟�?	闁规儼濮ら悧閬嶅磹瀹ュ棙娈�
>=150	0			512				1
50		2			512				3
25		5			512				6
12.5	11			512				12
6.25	23			512				24

*/
reg [2:0] div_width_top;
reg [5:0] div_pulse_top;
reg [2:0] w1cnt;
reg [5:0] w2cnt;
reg data_wr2 = 0;
reg data_wr2_keep = 0;
reg [511:0] data_din2;
always@(posedge adc_clk)begin
	if(adc_rst)begin
		div_width_top <= 0;
		div_pulse_top <= 0;
		data_wr1 <= 0;
		data_wr2 <= 0;
		data_wr2_keep <= 0;
		w1cnt <= 0;
		w2cnt <= 0;
		data_din1 <= 512'h0;
		data_din2 <= 512'h0;
	end
	else begin
		// pulse count
		div_pulse_top <= div_pulse;	
		if(fifo_data_enable)begin
			if(w2cnt<div_pulse_top)w2cnt <= w2cnt + 1;
			else w2cnt <= 0;
		end
		else w2cnt <= 0;
		data_wr2 <= fifo_data_enable & (w2cnt==div_pulse_top);
		data_wr2_keep <= fifo_data_enable;
		data_din2 <= fifo_wr_tdata;
		
		// width count
		div_width_top <= div_width;
		if(data_wr2)begin
			if(w1cnt<div_width_top)w1cnt <= w1cnt + 1;
			else w1cnt <= 0;
		end
		else if(~data_wr2_keep)w1cnt <= 0;
		data_wr1 <= data_wr2 & (w1cnt==div_width_top);
		if(data_wr2)begin
			if(div_width_top<1)begin
				data_din1 <= data_din2;
			end
			else if(div_width_top<2)begin
				if(w1cnt==0)data_din1[255:0] <= {data_din2[447:384], data_din2[319:256], data_din2[191:128], data_din2[63:0]};
				else data_din1[511:256] <= {data_din2[447:384], data_din2[319:256], data_din2[191:128], data_din2[63:0]};
			end
			else if(div_width_top<4)begin
				if(w1cnt==0)data_din1[127:0] <= {data_din2[191:128], data_din2[63:0]};
				else if(w1cnt==1)data_din1[255:128] <= {data_din2[191:128], data_din2[63:0]};
				else if(w1cnt==2)data_din1[383:256] <= {data_din2[191:128], data_din2[63:0]};
				else data_din1[511:384] <= {data_din2[191:128], data_din2[63:0]};
			end
			else begin
				case(w1cnt)
					0:data_din1[063:000] <= data_din2[63:0];
					1:data_din1[127:064] <= data_din2[63:0];
					2:data_din1[191:128] <= data_din2[63:0];
					3:data_din1[255:192] <= data_din2[63:0];
					4:data_din1[319:256] <= data_din2[63:0];
					5:data_din1[383:320] <= data_din2[63:0];
					6:data_din1[447:384] <= data_din2[63:0];
					7:data_din1[511:448] <= data_din2[63:0];
					default:data_din1[63:0] <= data_din2[63:0];
				endcase		
			end
		end
	end
end
endmodule
