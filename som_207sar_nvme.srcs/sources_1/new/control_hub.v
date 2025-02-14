// this module generate all control signals, including RF, BC
module control_hub(
input adc_clk,
input adc_rst,

input preprf,
input prfin,
input dac_valid,
input adc_valid,

output DAC_VOUT,
output RF_TXEN,	
output BC_TXEN,

input  BC_LATCH_IN,
input  BC_DYNLAT,
output BC_LATCH_OUT
);
// following requirement must meet
// 1: preprf to prfin >= 6us(for dynmaic latch)
// 2. dac_valid negedge to adc_valid posedge >= 200ns (for BC RX ready)
// 3. prfin posedge to dac_valid to dac_valid posedge >= 100ns (for RF ready)
// 4. prfin posedge to adc_valid to dac_valid posedge >= 200ns (for AUX write complete)

// RF_TXEN assert on posedge of PRFIN, dessert on posedge dac_valid

// BC_TXEN assert on posedge of PRFIN, dessert on posedge dac_valid

// BC_LATCH_OUT assert on posedge of preprf if dynamic mode is selected, dessert after 15 cycles
localparam DWIDTH = 10;
reg [DWIDTH:0] dac_valid_r;
always@(posedge adc_clk)dac_valid_r <= {dac_valid_r[DWIDTH-1:0], dac_valid};

// max pulse length cut to 100us
localparam MAX_PW = 150*100;
reg [15:0] txcnt;
reg tx_en_cmd, tx_en_cmd_r, tx_out;
always@(posedge adc_clk)tx_en_cmd <= dac_valid;
always@(posedge adc_clk)tx_en_cmd_r <= tx_en_cmd;
always@(posedge adc_clk)begin
	if(~dac_valid)txcnt <= 0;
	else if(txcnt<MAX_PW)txcnt <= txcnt + 1;	
	tx_out <= (txcnt<MAX_PW);
end

assign RF_TXEN = dac_valid_r[10];
assign DAC_VOUT = dac_valid_r[4];
assign BC_TXEN = tx_out & dac_valid_r[0];

reg BC_LATCH_r1, BC_LATCH_r2;
reg BC_LATCH_int = 0;
reg BC_LATCH_gen = 0;
reg BC_DYNLAT_r = 0;
always@(posedge adc_clk)begin
	if(adc_rst)begin
		BC_LATCH_int <= 0;
		BC_LATCH_gen <= 0;
		BC_LATCH_r1 <= 0;
		BC_LATCH_r2 <= 0;
		BC_DYNLAT_r <= 0;
	end
	else begin
		BC_LATCH_r1 <= BC_LATCH_IN;
		BC_LATCH_r2 <= BC_LATCH_r1;
		BC_DYNLAT_r <= BC_DYNLAT;
		if(BC_DYNLAT_r)begin
			if(BC_LATCH_r1&(~BC_LATCH_r2))BC_LATCH_int <= 1;
			else if(BC_LATCH_gen)BC_LATCH_int <= 0;
			
			if(BC_LATCH_int)BC_LATCH_gen <= preprf & (~prfin);
			else if(prfin)BC_LATCH_gen <= 0;
		end
		else begin
			BC_LATCH_gen <= BC_LATCH_IN;
		end
	end
end
assign BC_LATCH_OUT = BC_LATCH_gen;


endmodule
