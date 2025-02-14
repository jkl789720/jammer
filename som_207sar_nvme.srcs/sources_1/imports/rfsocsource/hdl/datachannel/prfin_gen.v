module prfin_gen(
input clk,
input reset,
input [31:0] cfg_prftime,
input [31:0] cfg_pretime,
input cfg_prfext,	// 0:internal, 1: external
input cfg_prfval,	// 0:disable, 1: valid
input cfg_prfrst,
input cfg_prfpul,	// 1: generate only one pulse
input cfg_prfrestart,
input prfin_ex,
output prfmux,
input prffix,
output preprf,
output prfin,
output reg [31:0] prfcnt
);

localparam DEFAULT_PRF_TIME = 2048;
reg [31:0] cfg_prftime_r1;
reg [31:0] cfg_prftime_r2;
reg cfg_prfext_r1;
reg cfg_prfpul_r1;
reg [7:0] cfg_prfval_r1;
reg pulse_sync_r1;
reg pulse_sync_r1_start;
reg [31:0] count;
reg prfout;
reg clk_div;

reg cfg_prfrst_r1;
always@(posedge clk)cfg_prfrst_r1 <= cfg_prfrst;

reg prfrestart_r1, prfrestart_r2;
always@(posedge clk)prfrestart_r1 <= cfg_prfrestart;
always@(posedge clk)prfrestart_r2 <= prfrestart_r1;
wire prfrestart = prfrestart_r1 & (~prfrestart_r2);
// generate preprf
always@(posedge clk) begin
	if(reset | cfg_prfrst_r1)begin
		cfg_prftime_r1 <= DEFAULT_PRF_TIME;
		cfg_prftime_r2 <= DEFAULT_PRF_TIME;	
		cfg_prfval_r1 <= 0;
		cfg_prfext_r1 <= 0;
		pulse_sync_r1 <= 0;
		count <= 0;
		prfout <= 0;
		clk_div <= 0;
		cfg_prfpul_r1 <= 0;
	end
	else begin
		cfg_prftime_r1 <= cfg_prftime;
		cfg_prfpul_r1 <= cfg_prfpul;
		if(cfg_prftime_r1>0)cfg_prftime_r2 <= cfg_prftime_r1-1;
		else cfg_prftime_r2 <= 0;

		cfg_prfval_r1 <= {cfg_prfval_r1[6:0], cfg_prfval};
		cfg_prfext_r1 <= cfg_prfext;
		pulse_sync_r1 <= prfin_ex;
		
		if(prfrestart)count <= 'd0;
		else if(cfg_prfval_r1[7] & cfg_prfval_r1[0] & (count < cfg_prftime_r2))count <= count + 1'b1;	
		else if(~cfg_prfpul_r1)count <= 'd0;
		
		clk_div <= (count > {1'b0, cfg_prftime_r2[31:1]});
		prfout <= cfg_prfext_r1?(pulse_sync_r1&pulse_sync_r1_start):clk_div;
	end
end
always@(posedge clk) begin
    if(!cfg_prfext_r1)begin
        pulse_sync_r1_start <= 1'b0;
    end
    else begin
        if(pulse_sync_r1 == 1'b0 && pulse_sync_r1_start == 1'b0)
            pulse_sync_r1_start <= 1'b1;
    end
end
assign prfmux = prfout;

assign preprf = prffix;

// generate prfin
reg [31:0] tcnt0;
reg [31:0] tcnt1;
reg prfout_r1, prfout_r2;
reg [31:0] cfg_pretime_r1;
reg prfout2;
always@(posedge clk) begin
	if(reset | cfg_prfrst_r1) begin
		tcnt0 <= 0;
		tcnt1 <= 0;
		prfout_r1 <= 0;
		prfout_r2 <= 0;
		cfg_pretime_r1 <= 0;
		prfout2 <= 0;
	end
	else begin
		cfg_pretime_r1 <= cfg_pretime;
		prfout_r1 <= prffix;
		prfout_r2 <= prfout_r1;
		if(prfout_r1 & (~prfout_r2))begin
			if(cfg_pretime_r1>1)tcnt0 <= cfg_pretime_r1;
			else tcnt0 <= 1;
		end
		else if(tcnt0>0)tcnt0 <= tcnt0 - 1;
		
		if(prfout_r2 & (~prfout_r1))begin
			if(cfg_pretime_r1>1)tcnt1 <= cfg_pretime_r1;
			else tcnt1 <= 1;
		end
		else if(tcnt1>0)tcnt1 <= tcnt1 - 1;		
		
		if(cfg_prfval_r1!=8'hFF)prfout2 <= 0;
		else if(tcnt0==1)prfout2 <= 1;
		else if(tcnt1==1)prfout2 <= 0;
	end
end
assign prfin = prfout2;

// generate prfcnt
reg prfin_r1, prfin_r2;
always@(posedge clk) begin
	if(reset | cfg_prfrst_r1) begin
		prfcnt <= 0;
		prfin_r1 <= 0;
		prfin_r2 <= 0;
	end
	else begin
		prfin_r1 <= prfin;
		prfin_r2 <= prfin_r1;
		if(prfin_r1&(~prfin_r2))prfcnt <= prfcnt + 1;
	end
end

endmodule