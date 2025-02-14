`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/08/28 00:02:39
// Design Name: 
// Module Name: tt_control_hub
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tt_control_hub;
reg  adc_clk;
reg  adc_rst;
reg  preprf;
reg  prfin;
wire  dac_valid;
wire  adc_valid;
wire  DAC_VOUT;
wire  RF_TXEN;
wire  BC_TXEN;
reg  BC_LATCH_IN;
reg  BC_DYNLAT;
wire  BC_LATCH_OUT;

always begin
	adc_clk = 0;
	#3;
	adc_clk = 1;
	#3;	
end
always begin
	preprf = 0;
	prfin = 0;
	#10000;
	preprf = 1;
	#1000;
	prfin = 1;
	#10000;
	preprf = 0;
	#1000;
	prfin = 0;	
	#10000;
end

assign dac_valid = prfin;
assign adc_valid = prfin;

initial begin
	adc_rst = 1;
	BC_DYNLAT = 0;
	BC_LATCH_IN = 0;
	#1000;
	adc_rst = 0;
	#1000;	
	
	repeat(4)begin
		BC_LATCH_IN = 1;
		#1000;
		BC_LATCH_IN = 0;
		#80000;		
	end
	
	#80000;
	BC_DYNLAT = 1;
	#10000;
	repeat(4)begin
		BC_LATCH_IN = 1;
		#1000;
		BC_LATCH_IN = 0;
		#80000;		
	end
	
	#80000;
	repeat(4)begin
		BC_LATCH_IN = 1;
		#1000;
		BC_LATCH_IN = 1;
		#80000;		
	end
	
	#80000;
	repeat(4)begin
		BC_LATCH_IN = 0;
		#1000;
		BC_LATCH_IN = 0;
		#80000;		
	end
	#100000;
	$stop;
end

control_hub control_hub_EP0(
.adc_clk(adc_clk),    //input 
.adc_rst(adc_rst),    //input 
.preprf(preprf),    //input 
.prfin(prfin),    //input 
.dac_valid(dac_valid),    //input 
.adc_valid(adc_valid),    //input 
.DAC_VOUT(DAC_VOUT),    //output 
.RF_TXEN(RF_TXEN),    //output 
.BC_TXEN(BC_TXEN),    //output 
.BC_LATCH_IN(BC_LATCH_IN),    //input 
.BC_DYNLAT(BC_DYNLAT),    //input 
.BC_LATCH_OUT(BC_LATCH_OUT)    //output 
);
endmodule
