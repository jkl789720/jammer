// Aug 1, 2018. Add mask cfg and mask logic for both AD and DA
// July 19, 2018. Chaneg to DA_repeat <= DA_repeat_r1 & (~DA_multiclr_r1); from 0. For non-multiclr case in repeat mode
// May 15, 2018, Chaneg fifo_clr action. Reason in pg057: To avoid such situations, it is always recommended to have the asynchronous reset asserted for at least 3 slowest clock cycles.
// May 14, 2018, First version
module timing_logic
#(
parameter BUS_SAMPLE_ALIGN_BITS = 2,
parameter BUS_WAVEGEN_ALIGN_BITS = 2
)
(
input cfg_clk,
input cfg_rst,
// cfg info
input [31:0] cfg_AD_base,
input [31:0] cfg_AD_rnum,
input [31:0] cfg_AD_anum,
input [31:0] cfg_AD_delay,
input [3:0]  cfg_AD_div,	// 1-8
input		 cfg_AD_repeat,
output [31:0] cfg_AD_status,	// not used
input		 cfg_AD_continu,
input		 cfg_AD_multiclr,
input 		 cfg_AD_start,
input 		 cfg_AD_masken,

input [31:0] cfg_DA_base,
input [31:0] cfg_DA_rnum,
input [31:0] cfg_DA_anum,
input [31:0] cfg_DA_delay,
input [3:0]  cfg_DA_div,
input		 cfg_DA_repeat,
output [31:0] cfg_DA_status,
input		 cfg_DA_continu,
input		 cfg_DA_multiclr,
input 		 cfg_DA_start,
input 		 cfg_DA_masken,

input 		 cfg_mode_auxen,
input 		 cfg_mode_selda,	// 1:pcie
input 		 cfg_mode_selad,	// 1:pcie

// control IF
input mem_clk,
input mem_rst,
output reg [31:0] tl_AD_base,
output reg [31:0] tl_AD_rnum,
output reg tl_AD_repeat,
output reg tl_AD_reset,
input [31:0] tl_AD_status,
output reg [31:0] tl_DA_base,
output reg [31:0] tl_DA_rnum,
output reg tl_DA_repeat,
output reg tl_DA_reset,
input [31:0] tl_DA_status,

input adc_clk,
input adc_rst,
input dac_clk,
input dac_rst,
input preprf,
input prfin,
input adc_mask,
input dac_mask,

output reg mfifo_rd_clr,	// active high, only one cycle
output reg mfifo_rd_valid,
output reg mfifo_rd_enable,
output reg mfifo_wr_clr,	// active high, only one cycle
output reg mfifo_wr_valid,
output reg mfifo_wr_enable,

output reg fifo_rd_clr,	// active high, only one cycle
output reg fifo_rd_valid,
output reg fifo_rd_enable,
output reg fifo_wr_clr,	// active high, only one cycle
output reg fifo_wr_valid,
output reg fifo_wr_enable
);


// timing for prfin
/*-----------------------------------------------------
preprf          __________|--------|_____________________________
prf             _______________________|--------|________________

aux update      ___________|---|_________________________________
data prefetch   ___________|-------------------------------------
------------------------------------------------------*/

// timing for sample
/*-----------------------------------------------------
pcie as dest:
	fifo_wr_clr once
	
	cfg_AD_continu=1:
		cfg_mode_auxen=1:
			sample param can't dynamic change
		cfg_mode_auxen=0:
			cfg_AD_repeat=1:
				repeat untill manual stop
			cfg_AD_repeat=0:
				repeat cfg_AD_anum pulse
			generate fifo_xxxx
	
	cfg_AD_continu=0:
		cfg_mode_auxen=1:
			update AD_delay @(posedge prf)
			generate fifo_xxxx
		cfg_mode_auxen=0:
			cfg_AD_repeat=1:
				repeat untill manual stop
			cfg_AD_repeat=0:
				repeat cfg_AD_anum pulse
			generate fifo_xxxx

ddr as dest:
	cfg_AD_repeat must be 0 in this mode
	cfg_AD_continu=1:
		fifo_wr_clr once
		cfg_mode_auxen=1:
			sample param can't dynamic change
		cfg_mode_auxen=0:
			//cfg_AD_repeat=1:
				//can't use repeat in this mode
			cfg_AD_repeat=0:
				repeat cfg_AD_anum pulse
	
	cfg_AD_continu=0:
		cfg_mode_auxen=1:
			update AD_delay @(posedge prf)
			generate fifo_xxxx
		cfg_mode_auxen=0:
			fifo_wr_clr  @(posedge prf) 
			//cfg_AD_repeat=1:
				//can't use repeat in this mode
			cfg_AD_repeat=0:
				repeat cfg_AD_anum pulse
------------------------------------------------------*/

// timing for wave gen
/*-----------------------------------------------------
pcie as source:
	fifo_rd_clr once
	
	cfg_DA_continu=1:
		cfg_mode_auxen=1:
			sample param can't dynamic change
		cfg_mode_auxen=0:
			cfg_DA_repeat=1:
				repeat untill manual stop
			cfg_AD_repeat=0:
				repeat cfg_AD_anum pulse
			generate fifo_xxxx
	
	cfg_DA_continu=0:
		cfg_mode_auxen=1:
			update DA_delay @(posedge prf)
			generate fifo_xxxx
		cfg_mode_auxen=0:
			cfg_DA_repeat=1:
				repeat untill manual stop
			cfg_DA_repeat=0:
				repeat cfg_AD_anum pulse
			generate fifo_xxxx

ddr as source:
	cfg_DA_continu=1:
		fifo_rd_clr once
		cfg_mode_auxen=1:
			sample param can't dynamic change
		cfg_mode_auxen=0:
			cfg_DA_repeat=1:
				repeat untill manual stop
				address increase by cfg_DA_anum x cfg_DA_rnum
			cfg_DA_repeat=0:
				repeat cfg_AD_anum pulse
	
	cfg_DA_continu=0:
		cfg_mode_auxen=1:
			update DA_delay @(posedge prf)
			generate fifo_xxxx
		cfg_mode_auxen=0:
			fifo_rd_clr  @(posedge prf) 
			cfg_DA_repeat=1:
				repeat untill manual stop
				address increase by cfg_DA_anum x cfg_DA_rnum
			cfg_DA_repeat=0:
				repeat cfg_DA_anum pulse

------------------------------------------------------*/
// adc part
reg [31:0] AD_base_r1;
reg [31:0] AD_rnum_r1;
reg [31:0] AD_anum_r1;
reg [31:0] AD_delay_r1;
reg [3:0]  AD_div_r1;
reg		   AD_repeat_r1;
reg		   AD_continu_r1;
reg        AD_multiclr_r1;
reg        AD_start_r1;
reg        mode_selad_r1;
reg        AD_masken_r1;
reg 	   adc_mask_r1;
always@(posedge adc_clk)begin
	if(adc_rst)begin
		AD_base_r1 <= 0;
		AD_rnum_r1 <= 0;
		AD_anum_r1 <= 0;
		AD_delay_r1 <= 0;
		AD_div_r1 <= 0;
		AD_repeat_r1 <= 0;
		AD_continu_r1 <= 0;
		AD_multiclr_r1 <= 0;
		mode_selad_r1 <= 0;
		AD_start_r1 <= 0;
		AD_masken_r1 <= 0;
		adc_mask_r1 <= 0;
	end
	else begin
		AD_base_r1 <= cfg_AD_base;
		AD_rnum_r1 <= cfg_AD_rnum;
		AD_anum_r1 <= cfg_AD_anum;
		AD_delay_r1 <= cfg_AD_delay;
		AD_div_r1 <= cfg_AD_div;
		AD_repeat_r1 <= cfg_AD_repeat;
		AD_continu_r1 <= cfg_AD_continu;
		AD_multiclr_r1 <= cfg_AD_multiclr;
		AD_start_r1 <= cfg_AD_start;
		mode_selad_r1 <= cfg_mode_selad;
		AD_masken_r1 <= cfg_AD_masken;
		adc_mask_r1 <= adc_mask;
	end
end

reg preprf_r1, preprf_r2;
reg prfin_r1, prfin_r2;
wire preprf_adcedge = (~(adc_mask_r1&AD_masken_r1)) & preprf_r1 & (~preprf_r2);
wire prfin_adcedge = (~(adc_mask_r1&AD_masken_r1)) & prfin_r1 & (~prfin_r2);
always@(posedge adc_clk)begin
	if(adc_rst)begin
		preprf_r1 <= 0;
		preprf_r2 <= 0;
		prfin_r1 <= 0;
		prfin_r2 <= 0;
	end
	else begin
		preprf_r1 <= preprf;
		preprf_r2 <= preprf_r1;
		prfin_r1 <= prfin;
		prfin_r2 <= prfin_r1;		
	end
end		

reg [31:0] ad_rcnt;
reg [31:0] ad_dcnt;
reg [31:0] ad_acnt;
reg ad_firstprf;
reg ad_prfready;
reg ad_fifo;
reg [3:0] ad_vcnt;
reg [31:0] AD_rnum_full_r1;
wire [31:0] AD_rnum_full_c1;
mult_32x32 mult_32x32_ep0(
.CLK(adc_clk),
.A(AD_rnum_r1),
.B({28'h0,AD_div_r1}),
.P(AD_rnum_full_c1)
);
reg [3:0] ad_ccnt;
reg [1:0] ad_done;
always@(posedge adc_clk)begin
	if(adc_rst | (~AD_start_r1))begin // deassert AD_start_r1 will stop function immediately
        fifo_wr_clr <= 0;
        fifo_wr_valid <= 0;
        fifo_wr_enable <= 0;

        mfifo_wr_clr <= 0;
        mfifo_wr_valid <= 0;
        mfifo_wr_enable <= 0;
		
		ad_prfready <= 0;
		ad_firstprf <= 1;
		ad_fifo <= 0;
		ad_acnt <= 0;
		ad_dcnt <= 0;
		ad_rcnt <= 0;
		ad_vcnt <= 0;
		AD_rnum_full_r1 <= 0;
		ad_ccnt <= 0;
		ad_done <= 0;
	end
	else begin
		AD_rnum_full_r1 <= AD_rnum_full_c1;
		if(preprf_adcedge)ad_prfready <= 1;
		else if(prfin_adcedge)ad_prfready <= 0;
		if(prfin_adcedge & ad_prfready)ad_firstprf <= 0;

		if(prfin_adcedge & ad_prfready)begin
			if(ad_firstprf)ad_acnt <= AD_anum_r1;
			else if(ad_acnt>0)ad_acnt <= ad_acnt - 1;
			if(AD_delay_r1>1)ad_dcnt <= AD_delay_r1;
			else ad_dcnt <= 1;
			
			if(ad_firstprf)ad_done[0] <= 1;
			if(ad_acnt==1)ad_done[1] <= 1;
		end
		else begin
			if(ad_dcnt>0)ad_dcnt <= ad_dcnt - 1;
		
			if(ad_dcnt==1)ad_rcnt <= AD_rnum_full_r1[31:BUS_SAMPLE_ALIGN_BITS];
			//else if((ad_rcnt>0)&(~AD_continu_r1))ad_rcnt <= ad_rcnt - 1;
			else if(ad_rcnt>0)ad_rcnt <= ad_rcnt - 1;
		end	
		
		if(ad_fifo)begin
			if(ad_vcnt<(AD_div_r1-1))ad_vcnt <= ad_vcnt + 1;
			else ad_vcnt <= 0;
		end
		else ad_vcnt <= 0;
		
		fifo_wr_valid <= ad_fifo & mode_selad_r1;
		fifo_wr_enable <= ad_fifo & (ad_vcnt==0) & mode_selad_r1;
		
		mfifo_wr_valid <= ad_fifo & (~mode_selad_r1);
		mfifo_wr_enable <= ad_fifo & (ad_vcnt==0) & (~mode_selad_r1);
		
		if(AD_continu_r1)begin
			if(preprf_adcedge & (~ad_prfready) & ad_firstprf)ad_ccnt <= 8;
			else if(ad_ccnt>0)ad_ccnt <= ad_ccnt - 1;
			if(mode_selad_r1)begin
				fifo_wr_clr <= (ad_ccnt>0);
				ad_fifo <= ((AD_repeat_r1&(~ad_firstprf)) | (ad_acnt>0));
				//ad_fifo <= (ad_rcnt>0) & (AD_repeat_r1 | (ad_acnt>0));
			end
			else begin
				mfifo_wr_clr <= (ad_ccnt>0);
				ad_fifo <= (ad_acnt>0);
				//ad_fifo <= (ad_rcnt>0) & (ad_acnt>0);
			end
		end
		else begin
			if(preprf_adcedge & (~ad_prfready) & (ad_firstprf | AD_multiclr_r1))ad_ccnt <= 8;
			else if(ad_ccnt>0)ad_ccnt <= ad_ccnt - 1;
			if(mode_selad_r1)begin
				fifo_wr_clr <= (ad_ccnt>0);
				ad_fifo <= (ad_rcnt>0) & (AD_repeat_r1 | (ad_acnt>0));
			end
			else begin
				mfifo_wr_clr <= (ad_ccnt>0);
				ad_fifo <= (ad_rcnt>0) & (ad_acnt>0);
			end
		end
	end
end


// dac part
reg [31:0] DA_base_r1;
reg [31:0] DA_rnum_r1;
reg [31:0] DA_anum_r1;
reg [31:0] DA_delay_r1;
reg [3:0]  DA_div_r1;
reg		   DA_repeat_r1;
reg        DA_continu_r1;
reg        DA_multiclr_r1;
reg        DA_start_r1;
reg        mode_selda_r1;
reg        DA_masken_r1;
reg 	   dac_mask_r1;
always@(posedge dac_clk)begin
	if(dac_rst)begin
		DA_base_r1 <= 0;
		DA_rnum_r1 <= 0;
		DA_anum_r1 <= 0;
		DA_delay_r1 <= 0;
		DA_div_r1 <= 0;
		DA_repeat_r1 <= 0;
		DA_continu_r1 <= 0;
		DA_multiclr_r1 <= 0;
		mode_selda_r1 <= 0;
		DA_start_r1 <= 0;
		DA_masken_r1 <= 0;
		dac_mask_r1 <= 0;
	end
	else begin
		DA_base_r1 <= cfg_DA_base;
		DA_rnum_r1 <= cfg_DA_rnum;
		DA_anum_r1 <= cfg_DA_anum;
		DA_delay_r1 <= cfg_DA_delay;
		DA_div_r1 <= cfg_DA_div;
		DA_repeat_r1 <= cfg_DA_repeat;
		DA_continu_r1 <= cfg_DA_continu;
		DA_multiclr_r1 <= cfg_DA_multiclr;
		mode_selda_r1 <= cfg_mode_selda;
		DA_start_r1 <= cfg_DA_start;
		DA_masken_r1 <= cfg_DA_masken;
		dac_mask_r1 <=  dac_mask;
	end
end
reg preprf_q1, preprf_q2;
reg prfin_q1, prfin_q2;
wire preprf_dacedge = (~(dac_mask_r1&DA_masken_r1)) & preprf_q1 & (~preprf_q2);
wire prfin_dacedge = (~(dac_mask_r1&DA_masken_r1)) & prfin_q1 & (~prfin_q2);
always@(posedge dac_clk)begin
	if(dac_rst)begin
		preprf_q1 <= 0;
		preprf_q2 <= 0;
		prfin_q1 <= 0;
		prfin_q2 <= 0;
	end
	else begin
		preprf_q1 <= preprf;
		preprf_q2 <= preprf_q1;
		prfin_q1 <= prfin;
		prfin_q2 <= prfin_q1;		
	end
end	


reg [31:0] da_rcnt;
reg [31:0] da_dcnt;
reg [31:0] da_acnt;
reg da_firstprf;
reg da_prfready;
reg da_fifo;
reg [2:0] da_vcnt;
reg [31:0] DA_rnum_full_r1;
wire [31:0] DA_rnum_full_c1;
mult_32x32 mult_32x32_ep1(
.CLK(dac_clk),
.A(DA_rnum_r1),
.B({28'h0,DA_div_r1}),
.P(DA_rnum_full_c1)
);
reg [3:0] da_ccnt;
reg [1:0] da_done;
always@(posedge dac_clk)begin
	if(dac_rst | (~DA_start_r1))begin // deassert DA_start_r1 will stop function immediately
		fifo_rd_clr <= 0;
        fifo_rd_valid <= 0;
        fifo_rd_enable <= 0;

		mfifo_rd_clr <= 0;
        mfifo_rd_valid <= 0;
        mfifo_rd_enable <= 0;
		
		da_prfready <= 0;
		da_firstprf <= 1;
		da_fifo <= 0;
		da_acnt <= 0;
		da_rcnt <= 0;
		da_dcnt <= 0;
		da_vcnt <= 0;
		DA_rnum_full_r1 <= 0;
		da_ccnt <= 0;
		da_done <= 0;
	end
	else begin
		DA_rnum_full_r1 <= DA_rnum_full_c1;
		if(preprf_dacedge)da_prfready <= 1;
		else if(prfin_dacedge)da_prfready <= 0;
		if(prfin_dacedge & da_prfready)da_firstprf <= 0;

		if(prfin_dacedge & da_prfready)begin
			if(da_firstprf)da_acnt <= DA_anum_r1;
			else if(DA_repeat_r1 & (da_acnt==1))da_acnt <= DA_anum_r1;
			else if(da_acnt>0)da_acnt <= da_acnt - 1;
			if(DA_delay_r1>1)da_dcnt <= DA_delay_r1;
			else da_dcnt <= 1;
			
			if(da_firstprf)da_done[0] <= 1;
			if(da_acnt==1)da_done[1] <= 1;
		end
		else begin
			if(da_dcnt>0)da_dcnt <= da_dcnt - 1;
		
			if(da_dcnt==1)da_rcnt <= DA_rnum_full_r1[31:BUS_WAVEGEN_ALIGN_BITS];
			//else if((da_rcnt>0) & (~DA_continu_r1))da_rcnt <= da_rcnt - 1;
			else if(da_rcnt>0)da_rcnt <= da_rcnt - 1;
		end	
		
		if(da_fifo)begin
			if(da_vcnt<(DA_div_r1-1))da_vcnt <= da_vcnt + 1;
			else da_vcnt <= 0;
		end
		else da_vcnt <= 0;
		
		fifo_rd_valid <= da_fifo & mode_selda_r1;
		fifo_rd_enable <= da_fifo & (da_vcnt==0) & mode_selda_r1;
		
		mfifo_rd_valid <= da_fifo & (~mode_selda_r1);
		mfifo_rd_enable <= da_fifo & (da_vcnt==0) & (~mode_selda_r1);
		
		if(DA_continu_r1)begin
			da_fifo <= ((DA_repeat_r1&(~da_firstprf)) | (da_acnt>0)); // to avoid da_fifo start immediately after DA_start_r1 asserted, by adding (~da_firstprf)
			//da_fifo <= (da_rcnt>0) & (DA_repeat_r1 | (da_acnt>0));
			
			if(mode_selda_r1)begin
				da_ccnt <= 0;
				fifo_rd_clr <= (da_ccnt>0);
			end
			else begin
				if(preprf_dacedge & (~da_prfready) & da_firstprf)da_ccnt <= 8;
				else if(da_ccnt>0)da_ccnt <= da_ccnt - 1;			
				mfifo_rd_clr <= (da_ccnt>0);
			end
		end
		else begin
			da_fifo <= (da_rcnt>0) & (DA_repeat_r1 | (da_acnt>0));
			//if(preprf_dacedge & (da_firstprf | (DA_multiclr_r1&((da_acnt==1)|(~DA_repeat_r1)))))da_ccnt <= 8;

			if(mode_selda_r1)begin
				if(preprf_dacedge & (~da_prfready) & (DA_multiclr_r1))da_ccnt <= 8;
				else if(da_ccnt>0)da_ccnt <= da_ccnt - 1;				
				fifo_rd_clr <= (da_ccnt>0);
			end
			else begin
				if(preprf_dacedge & (~da_prfready) & (da_firstprf | DA_multiclr_r1))da_ccnt <= 8;
				else if(da_ccnt>0)da_ccnt <= da_ccnt - 1;	
				mfifo_rd_clr <= (da_ccnt>0);
			end
		end
	end
end

// to mem domain
// adc part
reg AD_tlrdy;
reg [1:0]  AD_tlrdy_r1;
reg [31:0] AD_base;
reg [31:0] AD_addr;
reg [31:0] AD_rnum;
reg AD_repeat;
reg AD_reset;
wire [31:0] AD_rnum_c1;
mult_32x32 mult_32x32_ep2(
.CLK(adc_clk),
.A(AD_rnum_r1),
.B(AD_anum_r1),
.P(AD_rnum_c1)
);
always@(posedge adc_clk)begin
	if(adc_rst | (~AD_start_r1))begin
		AD_base <= 0;
		AD_rnum <= 0;
		AD_repeat <= 0;
		AD_reset <= 0;
		AD_addr <= 0;
		AD_tlrdy <= 0;
		AD_tlrdy_r1 <= 0;
	end
	else begin
		AD_tlrdy_r1 <= {AD_tlrdy_r1[0],AD_tlrdy};
		if(preprf_adcedge)begin
			AD_tlrdy <= 1;
			if(ad_firstprf)begin
				AD_base <= AD_base_r1;
				AD_addr <= AD_base_r1;
			end
			else begin
				AD_base <= AD_addr;
			end
			if(AD_continu_r1)begin
				AD_rnum <= AD_rnum_c1;
				AD_repeat <= 0;
				//AD_reset <= ad_firstprf & (~mode_selad_r1);
			end
			else begin
				if(AD_multiclr_r1)AD_rnum <= AD_rnum_r1;
				else AD_rnum <= AD_rnum_c1;
				AD_repeat <= 0;
				//AD_reset <= (ad_firstprf | AD_multiclr_r1) & (~mode_selad_r1);
			end
		end
		else if(prfin_adcedge & ad_prfready)begin
			AD_addr <= AD_addr + AD_rnum_r1;
			AD_tlrdy <= 0;
			//AD_reset <= 0;
		end
		AD_reset <= mfifo_wr_clr & (ad_firstprf | (ad_acnt>1)); // | AD_repeat_r1 

	end
end

// dac part
reg DA_tlrdy;
reg [1:0]  DA_tlrdy_r1;
reg [31:0] DA_base;
reg [31:0] DA_addr;
reg [31:0] DA_rnum;
reg DA_repeat;
reg DA_reset;
wire [31:0] DA_rnum_c1;
mult_32x32 mult_32x32_ep3(
.CLK(dac_clk),
.A(DA_rnum_r1),
.B(DA_anum_r1),
.P(DA_rnum_c1)
);
reg prfin_dacedge_r1;
always@(posedge dac_clk)begin
	if(dac_rst | (~DA_start_r1))begin
		DA_base <= 0;
		DA_rnum <= 0;
		DA_repeat <= 0;
		DA_reset <= 0;
		DA_addr <= 0;
		DA_tlrdy <= 0;
		prfin_dacedge_r1 <= 0;
		DA_tlrdy_r1 <= 0;
	end
	else begin
		prfin_dacedge_r1 <= prfin_dacedge & da_prfready;
		DA_tlrdy_r1      <= {DA_tlrdy_r1[0],DA_tlrdy};
		if(preprf_dacedge)begin
			DA_tlrdy <= 1;
			if(da_firstprf)begin
				DA_base <= DA_base_r1;
				DA_addr <= DA_base_r1;
			end
			else begin
				DA_base <= DA_addr;
			end
			
			if(DA_continu_r1)begin
				DA_rnum <= DA_rnum_c1;
				DA_repeat <= DA_repeat_r1;
				//DA_reset <= da_firstprf & (~mode_selda_r1);
			end
			else begin
				if(~DA_multiclr_r1)DA_rnum <= DA_rnum_c1;
				else DA_rnum <= DA_rnum_r1;
				DA_repeat <= DA_repeat_r1 & (~DA_multiclr_r1);
				//DA_reset <= (da_firstprf | (DA_multiclr_r1&((da_acnt==1)|(~DA_repeat_r1)))) & (~mode_selda_r1);
			end
		end
		else if(prfin_dacedge_r1)begin
			if(da_acnt==1)DA_addr <= DA_base_r1;
			else DA_addr <= DA_addr + DA_rnum_r1;
			DA_tlrdy <= 0;
			//DA_reset <= 0;
		end
		DA_reset <= mfifo_rd_clr & (da_firstprf | DA_repeat_r1 | (da_acnt>1));
	end
end

reg [3:0] ad_pipe_rdy;
reg [3:0] da_pipe_rdy;
always@(posedge mem_clk)begin
	if(mem_rst)begin
		tl_AD_base <= 0;
		tl_AD_rnum <= 0;
		tl_AD_repeat <= 0;
		tl_AD_reset <= 0;
		tl_DA_base <= 0;
		tl_DA_rnum <= 0;
		tl_DA_repeat <= 0;
		tl_DA_reset <= 0;
		ad_pipe_rdy <= 0;
		da_pipe_rdy <= 0;
	end
	else begin
		ad_pipe_rdy <= {ad_pipe_rdy[2:0], AD_tlrdy_r1[1]};
		da_pipe_rdy <= {da_pipe_rdy[2:0], DA_tlrdy_r1[1]};
		if(ad_pipe_rdy[2]&(~ad_pipe_rdy[3]))begin
			tl_AD_base <= AD_base;
			tl_AD_rnum <= AD_rnum;
			tl_AD_repeat <= AD_repeat;
			tl_AD_reset <= AD_reset;
		end
		else tl_AD_reset <= 0;
		if(da_pipe_rdy[2]&(~da_pipe_rdy[3]))begin
			tl_DA_base <= DA_base;
			tl_DA_rnum <= DA_rnum;
			tl_DA_repeat <= DA_repeat;
			tl_DA_reset <= DA_reset;
		end
		else tl_DA_reset <= 0;
	end
end


ila_time ila_time_ep0(
.clk(dac_clk),
.probe0(DA_reset  ),
.probe1(mfifo_rd_clr ),
.probe2(da_firstprf ),
.probe3(DA_repeat_r1 ),
.probe4(da_acnt),
.probe5(mfifo_rd_enable),
.probe6(da_fifo),
.probe7(mode_selda_r1),
.probe8(da_vcnt),
.probe9(da_rcnt),
.probe10(da_dcnt),
.probe11(DA_continu_r1)
);


`ifndef BYPASS_ALLSCOPE
ila_time ila_time_ep1(
.clk(mem_clk),
.probe0(tl_DA_reset  ),
.probe1(DA_reset ),
.probe2(DA_tlrdy ),
.probe3(AD_tlrdy ),
.probe4(da_pipe_rdy)
);

ila_tim_mem ila_tim_mem_ep0(
.clk(mem_clk),
.probe0(mem_rst  ),
.probe1(tl_AD_base ),
.probe2(tl_AD_rnum ),
.probe3(tl_AD_repeat ),
.probe4(tl_AD_reset),
.probe5(tl_DA_base  ),
.probe6(tl_DA_rnum  ),
.probe7(tl_DA_repeat),
.probe8(tl_DA_reset),  
.probe9(preprf_r1), 
.probe10(prfin_r1)
);

ila_tim_adc ila_tim_adc_ep0(
.clk(dac_clk),
.probe0(dac_rst  ),
.probe1(mfifo_rd_clr ),
.probe2(mfifo_rd_valid ),
.probe3(mfifo_rd_enable ),
.probe4(mfifo_wr_clr),
.probe5(mfifo_wr_valid  ),
.probe6(mfifo_wr_enable  ),
.probe7(fifo_rd_clr),
.probe8(fifo_rd_valid),  
.probe9(fifo_rd_enable), 
.probe10(fifo_wr_clr), 
.probe11(fifo_wr_valid), 
.probe12(fifo_wr_enable),
.probe13(preprf_q1),
.probe14(prfin_q1),
.probe15(AD_start_r1),
.probe16(DA_start_r1),
.probe17(adc_mask_r1),
.probe18(dac_mask_r1)
);
`endif
assign cfg_AD_status[15:0] = tl_AD_status[15:0];
assign cfg_AD_status[17:16] = ad_done;
assign cfg_AD_status[31:18] = 0;
assign cfg_DA_status[15:0] = tl_DA_status[15:0];
assign cfg_DA_status[17:16] = da_done;
assign cfg_DA_status[31:18] = 0;
endmodule
