
// change cfg_wr_addr/cfg_wr_addr to 12bit for fitting 4KB range
`define BASE_BASE_DEVICE 16'h0000
`define BASE_AUX_PARAM 16'h0100
`define BASE_BC_PARAM 16'h0200
`define BASE_INTERFERE_PARAM 16'h0300

module hwreg_set(
output reg [31:0] cfg_adc_frmlen,
output reg [31:0] cfg_adc_mode,
output reg [31:0] cfg_fmc_bccode,
output reg [31:0] cfg_fmc_rfcode,
output reg [31:0] cfg_prfgen_num,
output reg [31:0] cfg_prfgen_high,
output reg [31:0] cfg_prfgen_len,
output reg [31:0] cfg_dev_ctrl,
input      [31:0] cfg_dev_status,
input      [31:0] cfg_dev_version,
output reg [31:0] cfg_gpio_update,
input      [31:0] gpsdev_time,
input      [31:0] gpsdev_count,
output reg [31:0] cfg_fmc_rfcode2,
output reg [31:0] cfg_auxdw_0,
output reg [31:0] cfg_auxdw_1,
output reg [31:0] cfg_auxdw_2,
output reg [31:0] cfg_auxdw_3,
output reg [31:0] cfg_auxdw_4,
output reg [31:0] cfg_auxdw_5,
output reg [31:0] cfg_auxdw_6,
output reg [31:0] cfg_auxdw_7,
output reg [31:0] cfg_auxdw_8,
output reg [31:0] cfg_auxdw_9,
output reg [31:0] cfg_auxdw_10,
output reg [31:0] cfg_auxdw_11,
output reg [31:0] cfg_auxdw_12,
output reg [31:0] cfg_auxdw_13,
output reg [31:0] cfg_auxdw_14,
output reg [31:0] cfg_auxdw_15,
output reg [31:0] cfg_auxdw_16,
output reg [31:0] cfg_auxdw_17,
output reg [31:0] cfg_auxdw_18,
output reg [31:0] cfg_auxdw_19,
output reg [31:0] cfg_auxdw_20,
output reg [31:0] cfg_auxdw_21,
output reg [31:0] cfg_auxdw_22,
output reg [31:0] cfg_auxdw_23,
output reg [31:0] cfg_auxdw_24,
output reg [31:0] cfg_auxdw_25,
output reg [31:0] cfg_auxdw_26,
output reg [31:0] cfg_auxdw_27,
output reg [31:0] cfg_auxdw_28,
output reg [31:0] cfg_auxdw_29,
output reg [31:0] cfg_auxdw_30,
output reg [31:0] cfg_auxdw_31,

output reg [31:0] cfg_BC_param0,
output reg [31:0] cfg_BC_param1,
output reg [31:0] cfg_BC_param2,


output reg [31:0] cfg_INTERFERE_param0,
output reg [31:0] cfg_INTERFERE_param1,
output reg [31:0] cfg_INTERFERE_param2,
output reg [31:0] cfg_INTERFERE_param3,
output reg [31:0] cfg_INTERFERE_param4,
output reg [31:0] cfg_INTERFERE_param5,


input 				cfg_clk,
input 				cfg_rst,
input  [11:0] 		cfg_wr_addr,
input  [31:0] 		cfg_wr_dat,
input 				cfg_wr_en,
input [11:0] 		cfg_rd_addr,
output reg [31:0] 	cfg_rd_dat,
input 				cfg_rd_en
);

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
reg [31:0] cfg_dev_status_r1;
reg [31:0] cfg_dev_version_r1;
reg [31:0] gpsdev_time_r1;
reg [31:0] gpsdev_count_r1;

always@(posedge cfg_clk)begin
	case(cfg_rd_addr_r1)
		`BASE_BASE_DEVICE+16'h00:cfg_rd_dat <= cfg_adc_frmlen;
		`BASE_BASE_DEVICE+16'h04:cfg_rd_dat <= cfg_adc_mode;
		`BASE_BASE_DEVICE+16'h10:cfg_rd_dat <= cfg_fmc_bccode;
		`BASE_BASE_DEVICE+16'h14:cfg_rd_dat <= cfg_fmc_rfcode;
		`BASE_BASE_DEVICE+16'h18:cfg_rd_dat <= cfg_prfgen_num;
		`BASE_BASE_DEVICE+16'h1C:cfg_rd_dat <= cfg_prfgen_high;
		`BASE_BASE_DEVICE+16'h20:cfg_rd_dat <= cfg_prfgen_len;
		`BASE_BASE_DEVICE+16'h30:cfg_rd_dat <= cfg_dev_ctrl;
		`BASE_BASE_DEVICE+16'h34:cfg_rd_dat <= cfg_dev_status_r1;
		`BASE_BASE_DEVICE+16'h38:cfg_rd_dat <= cfg_dev_version_r1;
		`BASE_BASE_DEVICE+16'h3C:cfg_rd_dat <= cfg_gpio_update;
		`BASE_BASE_DEVICE+16'h40:cfg_rd_dat <= gpsdev_time_r1;
		`BASE_BASE_DEVICE+16'h44:cfg_rd_dat <= gpsdev_count_r1;
		`BASE_BASE_DEVICE+16'h4C:cfg_rd_dat <= cfg_fmc_rfcode2;	
		`BASE_AUX_PARAM+16'h00:cfg_rd_dat <= cfg_auxdw_0;
		`BASE_AUX_PARAM+16'h04:cfg_rd_dat <= cfg_auxdw_1;
		`BASE_AUX_PARAM+16'h08:cfg_rd_dat <= cfg_auxdw_2;
		`BASE_AUX_PARAM+16'h0C:cfg_rd_dat <= cfg_auxdw_3;
		`BASE_AUX_PARAM+16'h10:cfg_rd_dat <= cfg_auxdw_4;
		`BASE_AUX_PARAM+16'h14:cfg_rd_dat <= cfg_auxdw_5;
		`BASE_AUX_PARAM+16'h18:cfg_rd_dat <= cfg_auxdw_6;
		`BASE_AUX_PARAM+16'h1C:cfg_rd_dat <= cfg_auxdw_7;
		`BASE_AUX_PARAM+16'h20:cfg_rd_dat <= cfg_auxdw_8;
		`BASE_AUX_PARAM+16'h24:cfg_rd_dat <= cfg_auxdw_9;
		`BASE_AUX_PARAM+16'h28:cfg_rd_dat <= cfg_auxdw_10;
		`BASE_AUX_PARAM+16'h2C:cfg_rd_dat <= cfg_auxdw_11;
		`BASE_AUX_PARAM+16'h30:cfg_rd_dat <= cfg_auxdw_12;
		`BASE_AUX_PARAM+16'h34:cfg_rd_dat <= cfg_auxdw_13;
		`BASE_AUX_PARAM+16'h38:cfg_rd_dat <= cfg_auxdw_14;
		`BASE_AUX_PARAM+16'h3C:cfg_rd_dat <= cfg_auxdw_15;
		`BASE_AUX_PARAM+16'h40:cfg_rd_dat <= cfg_auxdw_16;
		`BASE_AUX_PARAM+16'h44:cfg_rd_dat <= cfg_auxdw_17;
		`BASE_AUX_PARAM+16'h48:cfg_rd_dat <= cfg_auxdw_18;
		`BASE_AUX_PARAM+16'h4C:cfg_rd_dat <= cfg_auxdw_19;
		`BASE_AUX_PARAM+16'h50:cfg_rd_dat <= cfg_auxdw_20;
		`BASE_AUX_PARAM+16'h54:cfg_rd_dat <= cfg_auxdw_21;
		`BASE_AUX_PARAM+16'h58:cfg_rd_dat <= cfg_auxdw_22;
		`BASE_AUX_PARAM+16'h5C:cfg_rd_dat <= cfg_auxdw_23;
		`BASE_AUX_PARAM+16'h60:cfg_rd_dat <= cfg_auxdw_24;
		`BASE_AUX_PARAM+16'h64:cfg_rd_dat <= cfg_auxdw_25;
		`BASE_AUX_PARAM+16'h68:cfg_rd_dat <= cfg_auxdw_26;
		`BASE_AUX_PARAM+16'h6C:cfg_rd_dat <= cfg_auxdw_27;
		`BASE_AUX_PARAM+16'h70:cfg_rd_dat <= cfg_auxdw_28;
		`BASE_AUX_PARAM+16'h74:cfg_rd_dat <= cfg_auxdw_29;
		`BASE_AUX_PARAM+16'h78:cfg_rd_dat <= cfg_auxdw_30;
		`BASE_AUX_PARAM+16'h7C:cfg_rd_dat <= cfg_auxdw_31;

		`BASE_BC_PARAM+16'h00:cfg_rd_dat <= cfg_BC_param0;
		`BASE_BC_PARAM+16'h04:cfg_rd_dat <= cfg_BC_param1;
		`BASE_BC_PARAM+16'h08:cfg_rd_dat <= cfg_BC_param2;

		`BASE_INTERFERE_PARAM+16'h00:cfg_rd_dat <= cfg_INTERFERE_param0;
		`BASE_INTERFERE_PARAM+16'h04:cfg_rd_dat <= cfg_INTERFERE_param1;
		`BASE_INTERFERE_PARAM+16'h08:cfg_rd_dat <= cfg_INTERFERE_param2;
		`BASE_INTERFERE_PARAM+16'h0c:cfg_rd_dat <= cfg_INTERFERE_param3;
		`BASE_INTERFERE_PARAM+16'h10:cfg_rd_dat <= cfg_INTERFERE_param4;
		`BASE_INTERFERE_PARAM+16'h14:cfg_rd_dat <= cfg_INTERFERE_param5;
		default:cfg_rd_dat <= 32'h0A0A_0A0A;
    endcase
end

always@(posedge cfg_clk)begin
    if(cfg_rst_r1)begin
		cfg_adc_frmlen <= 0;
		cfg_adc_mode <= 0;
		cfg_fmc_bccode <= 0;
		cfg_fmc_rfcode <= 0;
		cfg_prfgen_num <= 0;
		cfg_prfgen_high <= 0;
		cfg_prfgen_len <= 0;
		cfg_dev_ctrl <= 0;
		//cfg_dev_status <= 0;
		//cfg_dev_version <= 0;
		cfg_gpio_update <= 0;
		cfg_fmc_rfcode2 <= 0;
		cfg_auxdw_0 <= 0;
		cfg_auxdw_1 <= 0;
		cfg_auxdw_2 <= 0;
		cfg_auxdw_3 <= 0;
		cfg_auxdw_4 <= 0;
		cfg_auxdw_5 <= 0;
		cfg_auxdw_6 <= 0;
		cfg_auxdw_7 <= 0;
		cfg_auxdw_8 <= 0;
		cfg_auxdw_9 <= 0;
		cfg_auxdw_10 <= 0;
		cfg_auxdw_11 <= 0;
		cfg_auxdw_12 <= 0;
		cfg_auxdw_13 <= 0;
		cfg_auxdw_14 <= 0;
		cfg_auxdw_15 <= 0;
		cfg_auxdw_16 <= 0;
		cfg_auxdw_17 <= 0;
		cfg_auxdw_18 <= 0;
		cfg_auxdw_19 <= 0;
		cfg_auxdw_20 <= 0;
		cfg_auxdw_21 <= 0;
		cfg_auxdw_22 <= 0;
		cfg_auxdw_23 <= 0;
		cfg_auxdw_24 <= 0;
		cfg_auxdw_25 <= 0;
		cfg_auxdw_26 <= 0;
		cfg_auxdw_27 <= 0;
		cfg_auxdw_28 <= 0;
		cfg_auxdw_29 <= 0;
		cfg_auxdw_30 <= 0;
		cfg_auxdw_31 <= 0;
		
		cfg_BC_param0<= 0;
		cfg_BC_param1<= 0;
		cfg_BC_param2<= 0;
    end
    else begin
        if (cfg_wr_en_r)begin
            case(cfg_wr_addr_r)
				`BASE_BASE_DEVICE+16'h00:cfg_adc_frmlen <= cfg_wr_dat_r;
				`BASE_BASE_DEVICE+16'h04:cfg_adc_mode <= cfg_wr_dat_r;
				`BASE_BASE_DEVICE+16'h10:cfg_fmc_bccode <= cfg_wr_dat_r;
				`BASE_BASE_DEVICE+16'h14:cfg_fmc_rfcode <= cfg_wr_dat_r;
				`BASE_BASE_DEVICE+16'h18:cfg_prfgen_num <= cfg_wr_dat_r;
				`BASE_BASE_DEVICE+16'h1C:cfg_prfgen_high <= cfg_wr_dat_r;
				`BASE_BASE_DEVICE+16'h20:cfg_prfgen_len <= cfg_wr_dat_r;
				`BASE_BASE_DEVICE+16'h30:cfg_dev_ctrl <= cfg_wr_dat_r;
				//`BASE_BASE_DEVICE+16'h34:cfg_dev_status <= cfg_wr_dat_r;
				//`BASE_BASE_DEVICE+16'h38:cfg_dev_version <= cfg_wr_dat_r;
				`BASE_BASE_DEVICE+16'h3C:cfg_gpio_update <= cfg_wr_dat_r;
				`BASE_BASE_DEVICE+16'h4C:cfg_fmc_rfcode2 <= cfg_wr_dat_r;
				`BASE_AUX_PARAM+16'h00:cfg_auxdw_0 <= cfg_wr_dat_r;
				`BASE_AUX_PARAM+16'h04:cfg_auxdw_1 <= cfg_wr_dat_r;
				`BASE_AUX_PARAM+16'h08:cfg_auxdw_2 <= cfg_wr_dat_r;
				`BASE_AUX_PARAM+16'h0C:cfg_auxdw_3 <= cfg_wr_dat_r;
				`BASE_AUX_PARAM+16'h10:cfg_auxdw_4 <= cfg_wr_dat_r;
				`BASE_AUX_PARAM+16'h14:cfg_auxdw_5 <= cfg_wr_dat_r;
				`BASE_AUX_PARAM+16'h18:cfg_auxdw_6 <= cfg_wr_dat_r;
				`BASE_AUX_PARAM+16'h1C:cfg_auxdw_7 <= cfg_wr_dat_r;
				`BASE_AUX_PARAM+16'h20:cfg_auxdw_8 <= cfg_wr_dat_r;
				`BASE_AUX_PARAM+16'h24:cfg_auxdw_9 <= cfg_wr_dat_r;
				`BASE_AUX_PARAM+16'h28:cfg_auxdw_10 <= cfg_wr_dat_r;
				`BASE_AUX_PARAM+16'h2C:cfg_auxdw_11 <= cfg_wr_dat_r;
				`BASE_AUX_PARAM+16'h30:cfg_auxdw_12 <= cfg_wr_dat_r;
				`BASE_AUX_PARAM+16'h34:cfg_auxdw_13 <= cfg_wr_dat_r;
				`BASE_AUX_PARAM+16'h38:cfg_auxdw_14 <= cfg_wr_dat_r;
				`BASE_AUX_PARAM+16'h3C:cfg_auxdw_15 <= cfg_wr_dat_r;
				`BASE_AUX_PARAM+16'h40:cfg_auxdw_16 <= cfg_wr_dat_r;
				`BASE_AUX_PARAM+16'h44:cfg_auxdw_17 <= cfg_wr_dat_r;
				`BASE_AUX_PARAM+16'h48:cfg_auxdw_18 <= cfg_wr_dat_r;
				`BASE_AUX_PARAM+16'h4C:cfg_auxdw_19 <= cfg_wr_dat_r;
				`BASE_AUX_PARAM+16'h50:cfg_auxdw_20 <= cfg_wr_dat_r;
				`BASE_AUX_PARAM+16'h54:cfg_auxdw_21 <= cfg_wr_dat_r;
				`BASE_AUX_PARAM+16'h58:cfg_auxdw_22 <= cfg_wr_dat_r;
				`BASE_AUX_PARAM+16'h5C:cfg_auxdw_23 <= cfg_wr_dat_r;
				`BASE_AUX_PARAM+16'h60:cfg_auxdw_24 <= cfg_wr_dat_r;
				`BASE_AUX_PARAM+16'h64:cfg_auxdw_25 <= cfg_wr_dat_r;
				`BASE_AUX_PARAM+16'h68:cfg_auxdw_26 <= cfg_wr_dat_r;
				`BASE_AUX_PARAM+16'h6C:cfg_auxdw_27 <= cfg_wr_dat_r;
				`BASE_AUX_PARAM+16'h70:cfg_auxdw_28 <= cfg_wr_dat_r;
				`BASE_AUX_PARAM+16'h74:cfg_auxdw_29 <= cfg_wr_dat_r;
				`BASE_AUX_PARAM+16'h78:cfg_auxdw_30 <= cfg_wr_dat_r;
				`BASE_AUX_PARAM+16'h7C:cfg_auxdw_31 <= cfg_wr_dat_r;
				
				`BASE_BC_PARAM+16'h00:cfg_BC_param0 <= cfg_wr_dat_r;
				`BASE_BC_PARAM+16'h04:cfg_BC_param1 <= cfg_wr_dat_r;
				`BASE_BC_PARAM+16'h08:cfg_BC_param2 <= cfg_wr_dat_r;


				`BASE_INTERFERE_PARAM+16'h00:cfg_INTERFERE_param0 <= cfg_wr_dat_r;
				`BASE_INTERFERE_PARAM+16'h04:cfg_INTERFERE_param1 <= cfg_wr_dat_r;
				`BASE_INTERFERE_PARAM+16'h08:cfg_INTERFERE_param2 <= cfg_wr_dat_r;
				`BASE_INTERFERE_PARAM+16'h0c:cfg_INTERFERE_param3 <= cfg_wr_dat_r;
				`BASE_INTERFERE_PARAM+16'h10:cfg_INTERFERE_param4 <= cfg_wr_dat_r;
				`BASE_INTERFERE_PARAM+16'h14:cfg_INTERFERE_param5 <= cfg_wr_dat_r;

		        default:begin
                end
            endcase
        end
    end
end


always@(posedge cfg_clk)begin
    if(cfg_rst_r1)begin
		 cfg_dev_status_r1 <= 0;
		 cfg_dev_version_r1 <= 0;
		 gpsdev_time_r1 <= 0;
		 gpsdev_count_r1 <= 0;

    end
    else begin
		 cfg_dev_status_r1 <= cfg_dev_status;
		 cfg_dev_version_r1 <= cfg_dev_version;
		 gpsdev_time_r1 <= gpsdev_time;
		 gpsdev_count_r1 <= gpsdev_count;

    end
end
endmodule
