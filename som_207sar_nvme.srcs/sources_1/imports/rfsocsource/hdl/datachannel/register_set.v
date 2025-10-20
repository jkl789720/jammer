
// change cfg_wr_addr/cfg_wr_addr to 12bit for fitting 4KB range
`define BASE_FAST_CHANNEL 16'h0000
`define BASE_SLOW_CHANNEL 16'h0040
`define BASE_ADC_DAC 16'h0080
`define BASE_DEVICE 16'h00C0
`define BASE_PARAM_SET 16'h0100
`define BASE_MEM_ADC_DAC 16'h0140
`define BASE_DEEP_FIFO 16'h0180

module register_set(
output reg [31:0] cfg_H2D_addr_dma,
output reg [31:0] cfg_H2D_size_dma,
output reg [31:0] cfg_H2D_burst_len,
output reg [31:0] cfg_H2D_frame_len,
output reg [31:0] cfg_H2D_trans_len,
output reg [31:0] cfg_H2D_axi_ctrl,
input      [31:0] cfg_H2D_axi_status,
output reg [31:0] cfg_D2H_addr_dma,
output reg [31:0] cfg_D2H_addr_sym,
output reg [31:0] cfg_D2H_size_dma,
output reg [31:0] cfg_D2H_size_sym,
output reg [31:0] cfg_D2H_burst_len,
output reg [31:0] cfg_D2H_frame_len,
output reg [31:0] cfg_D2H_trans_len,
output reg [31:0] cfg_D2H_axi_ctrl,
input      [31:0] cfg_D2H_axi_status,
output reg [31:0] aux_H2D_addr_dma,
output reg [31:0] aux_H2D_size_dma,
output reg [31:0] aux_H2D_burst_len,
output reg [31:0] aux_H2D_frame_len,
output reg [31:0] aux_H2D_axi_ctrl,
input      [31:0] aux_H2D_axi_status,
output reg [31:0] aux_D2H_addr_dma,
output reg [31:0] aux_D2H_size_dma,
output reg [31:0] aux_D2H_burst_len,
output reg [31:0] aux_D2H_frame_len,
output reg [31:0] aux_D2H_axi_ctrl,
input      [31:0] aux_D2H_axi_status,
output reg [31:0] cfg_AD_rnum,
output reg [31:0] cfg_AD_anum,
output reg [31:0] cfg_AD_delay,
output reg [31:0] cfg_AD_mode,
output reg [31:0] cfg_AD_base,
input      [31:0] cfg_AD_status,
output reg [31:0] cfg_DA_rnum,
output reg [31:0] cfg_DA_anum,
output reg [31:0] cfg_DA_delay,
output reg [31:0] cfg_DA_mode,
output reg [31:0] cfg_DA_base,
input      [31:0] cfg_DA_status,
output reg [31:0] cfg_prftime,
output reg [31:0] cfg_pretime,
output reg [31:0] cfg_prfmode,
output reg [31:0] cfg_mode_ctrl,
output reg [31:0] cfg_dev_adc_ctrl,
input      [31:0] cfg_dev_adc_ro,
output reg [31:0] cfg_dev_adc_filter,
output reg [31:0] cfg_dev_adc_iodelay,
output reg [31:0] cfg_dev_dac_ctrl,
input      [31:0] cfg_dev_dac_ro,
output reg [31:0] cfg_dev_dac_filter,
output reg [31:0] cfg_dev_dac_iodelay,
output reg [31:0] cfg_dev_ctrl,
input      [31:0] cfg_dev_status,
input      [31:0] cfg_dev_version,
output reg [31:0] cfg_dev_spisel,
output reg [31:0] cfg_param_mode,
output reg [31:0] cfg_param_addr,
output reg [31:0] cfg_param_size,
output reg [31:0] cfg_port_addr,
output reg [31:0] cfg_port_size,
input      [31:0] cfg_param_status,
output reg [31:0] cfg_param2_mode,
output reg [31:0] cfg_param2_addr,
output reg [31:0] cfg_param2_size,
input      [31:0] cfg_param2_status,
output reg [31:0] cfg_mAD_rnum,
output reg [31:0] cfg_mAD_anum,
output reg [31:0] cfg_mAD_delay,
output reg [31:0] cfg_mAD_mode,
output reg [31:0] cfg_mAD_base,
input      [31:0] cfg_mAD_status,
output reg [31:0] cfg_mDA_rnum,
output reg [31:0] cfg_mDA_anum,
output reg [31:0] cfg_mDA_delay,
output reg [31:0] cfg_mDA_mode,
output reg [31:0] cfg_mDA_base,
input      [31:0] cfg_mDA_status,
output reg [31:0] cfg_deepfifo_ctrl,
input      [31:0] cfg_deepfifo_status,
input      [31:0] cfg_deepfifo_max_depth,
input      [31:0] cfg_deepfifo_nonbypass_data_L,
input      [31:0] cfg_deepfifo_nonbypass_data_H,
input      [31:0] cfg_deepfifo_total_data_L,
input      [31:0] cfg_deepfifo_total_data_H,
input      [31:0] cfg_deepfifo_status7,
input      [31:0] cfg_deepfifo_status8,

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
reg [31:0] cfg_H2D_axi_status_r1;
reg [31:0] cfg_D2H_axi_status_r1;
reg [31:0] aux_H2D_axi_status_r1;
reg [31:0] aux_D2H_axi_status_r1;
reg [31:0] cfg_AD_status_r1;
reg [31:0] cfg_DA_status_r1;
reg [31:0] cfg_dev_adc_ro_r1;
reg [31:0] cfg_dev_dac_ro_r1;
reg [31:0] cfg_dev_status_r1;
reg [31:0] cfg_dev_version_r1;
reg [31:0] cfg_param_status_r1;
reg [31:0] cfg_param2_status_r1;
reg [31:0] cfg_mAD_status_r1;
reg [31:0] cfg_mDA_status_r1;
reg [31:0] cfg_deepfifo_status_r1;
reg [31:0] cfg_deepfifo_max_depth_r1;
reg [31:0] cfg_deepfifo_nonbypass_data_L_r1;
reg [31:0] cfg_deepfifo_nonbypass_data_H_r1;
reg [31:0] cfg_deepfifo_total_data_L_r1;
reg [31:0] cfg_deepfifo_total_data_H_r1;
reg [31:0] cfg_deepfifo_status7_r1;
reg [31:0] cfg_deepfifo_status8_r1;

always@(posedge cfg_clk)begin
	case(cfg_rd_addr_r1)
		`BASE_FAST_CHANNEL+16'h00:cfg_rd_dat <= cfg_H2D_addr_dma;
		`BASE_FAST_CHANNEL+16'h04:cfg_rd_dat <= cfg_H2D_size_dma;
		`BASE_FAST_CHANNEL+16'h08:cfg_rd_dat <= cfg_H2D_burst_len;
		`BASE_FAST_CHANNEL+16'h0C:cfg_rd_dat <= cfg_H2D_frame_len;
		`BASE_FAST_CHANNEL+16'h10:cfg_rd_dat <= cfg_H2D_trans_len;
		`BASE_FAST_CHANNEL+16'h14:cfg_rd_dat <= cfg_H2D_axi_ctrl;
		`BASE_FAST_CHANNEL+16'h18:cfg_rd_dat <= cfg_H2D_axi_status_r1;
		`BASE_FAST_CHANNEL+16'h1C:cfg_rd_dat <= cfg_D2H_addr_dma;
		`BASE_FAST_CHANNEL+16'h20:cfg_rd_dat <= cfg_D2H_addr_sym;
		`BASE_FAST_CHANNEL+16'h24:cfg_rd_dat <= cfg_D2H_size_dma;
		`BASE_FAST_CHANNEL+16'h28:cfg_rd_dat <= cfg_D2H_size_sym;
		`BASE_FAST_CHANNEL+16'h2C:cfg_rd_dat <= cfg_D2H_burst_len;
		`BASE_FAST_CHANNEL+16'h30:cfg_rd_dat <= cfg_D2H_frame_len;
		`BASE_FAST_CHANNEL+16'h34:cfg_rd_dat <= cfg_D2H_trans_len;
		`BASE_FAST_CHANNEL+16'h38:cfg_rd_dat <= cfg_D2H_axi_ctrl;
		`BASE_FAST_CHANNEL+16'h3C:cfg_rd_dat <= cfg_D2H_axi_status_r1;
		`BASE_SLOW_CHANNEL+16'h00:cfg_rd_dat <= aux_H2D_addr_dma;
		`BASE_SLOW_CHANNEL+16'h04:cfg_rd_dat <= aux_H2D_size_dma;
		`BASE_SLOW_CHANNEL+16'h08:cfg_rd_dat <= aux_H2D_burst_len;
		`BASE_SLOW_CHANNEL+16'h0C:cfg_rd_dat <= aux_H2D_frame_len;
		`BASE_SLOW_CHANNEL+16'h10:cfg_rd_dat <= aux_H2D_axi_ctrl;
		`BASE_SLOW_CHANNEL+16'h14:cfg_rd_dat <= aux_H2D_axi_status_r1;
		`BASE_SLOW_CHANNEL+16'h18:cfg_rd_dat <= aux_D2H_addr_dma;
		`BASE_SLOW_CHANNEL+16'h1C:cfg_rd_dat <= aux_D2H_size_dma;
		`BASE_SLOW_CHANNEL+16'h20:cfg_rd_dat <= aux_D2H_burst_len;
		`BASE_SLOW_CHANNEL+16'h24:cfg_rd_dat <= aux_D2H_frame_len;
		`BASE_SLOW_CHANNEL+16'h28:cfg_rd_dat <= aux_D2H_axi_ctrl;
		`BASE_SLOW_CHANNEL+16'h2C:cfg_rd_dat <= aux_D2H_axi_status_r1;
		`BASE_ADC_DAC+16'h00:cfg_rd_dat <= cfg_AD_rnum;
		`BASE_ADC_DAC+16'h04:cfg_rd_dat <= cfg_AD_anum;
		`BASE_ADC_DAC+16'h08:cfg_rd_dat <= cfg_AD_delay;
		`BASE_ADC_DAC+16'h0C:cfg_rd_dat <= cfg_AD_mode;
		`BASE_ADC_DAC+16'h10:cfg_rd_dat <= cfg_AD_base;
		`BASE_ADC_DAC+16'h14:cfg_rd_dat <= cfg_AD_status_r1;
		`BASE_ADC_DAC+16'h18:cfg_rd_dat <= cfg_DA_rnum;
		`BASE_ADC_DAC+16'h1C:cfg_rd_dat <= cfg_DA_anum;
		`BASE_ADC_DAC+16'h20:cfg_rd_dat <= cfg_DA_delay;
		`BASE_ADC_DAC+16'h24:cfg_rd_dat <= cfg_DA_mode;
		`BASE_ADC_DAC+16'h28:cfg_rd_dat <= cfg_DA_base;
		`BASE_ADC_DAC+16'h2C:cfg_rd_dat <= cfg_DA_status_r1;
		`BASE_DEVICE+16'h00:cfg_rd_dat <= cfg_prftime;
		`BASE_DEVICE+16'h04:cfg_rd_dat <= cfg_pretime;
		`BASE_DEVICE+16'h08:cfg_rd_dat <= cfg_prfmode;
		`BASE_DEVICE+16'h0C:cfg_rd_dat <= cfg_mode_ctrl;
		`BASE_DEVICE+16'h10:cfg_rd_dat <= cfg_dev_adc_ctrl;
		`BASE_DEVICE+16'h14:cfg_rd_dat <= cfg_dev_adc_ro_r1;
		`BASE_DEVICE+16'h18:cfg_rd_dat <= cfg_dev_adc_filter;
		`BASE_DEVICE+16'h1C:cfg_rd_dat <= cfg_dev_adc_iodelay;
		`BASE_DEVICE+16'h20:cfg_rd_dat <= cfg_dev_dac_ctrl;
		`BASE_DEVICE+16'h24:cfg_rd_dat <= cfg_dev_dac_ro_r1;
		`BASE_DEVICE+16'h28:cfg_rd_dat <= cfg_dev_dac_filter;
		`BASE_DEVICE+16'h2C:cfg_rd_dat <= cfg_dev_dac_iodelay;
		`BASE_DEVICE+16'h30:cfg_rd_dat <= cfg_dev_ctrl;
		`BASE_DEVICE+16'h34:cfg_rd_dat <= cfg_dev_status_r1;
		`BASE_DEVICE+16'h38:cfg_rd_dat <= cfg_dev_version_r1;
		`BASE_DEVICE+16'h3C:cfg_rd_dat <= cfg_dev_spisel;
		`BASE_PARAM_SET+16'h00:cfg_rd_dat <= cfg_param_mode;
		`BASE_PARAM_SET+16'h04:cfg_rd_dat <= cfg_param_addr;
		`BASE_PARAM_SET+16'h08:cfg_rd_dat <= cfg_param_size;
		`BASE_PARAM_SET+16'h0C:cfg_rd_dat <= cfg_port_addr;
		`BASE_PARAM_SET+16'h10:cfg_rd_dat <= cfg_port_size;
		`BASE_PARAM_SET+16'h14:cfg_rd_dat <= cfg_param_status_r1;
		`BASE_PARAM_SET+16'h18:cfg_rd_dat <= cfg_param2_mode;
		`BASE_PARAM_SET+16'h1C:cfg_rd_dat <= cfg_param2_addr;
		`BASE_PARAM_SET+16'h20:cfg_rd_dat <= cfg_param2_size;
		`BASE_PARAM_SET+16'h24:cfg_rd_dat <= cfg_param2_status_r1;
		`BASE_MEM_ADC_DAC+16'h00:cfg_rd_dat <= cfg_mAD_rnum;
		`BASE_MEM_ADC_DAC+16'h04:cfg_rd_dat <= cfg_mAD_anum;
		`BASE_MEM_ADC_DAC+16'h08:cfg_rd_dat <= cfg_mAD_delay;
		`BASE_MEM_ADC_DAC+16'h0C:cfg_rd_dat <= cfg_mAD_mode;
		`BASE_MEM_ADC_DAC+16'h10:cfg_rd_dat <= cfg_mAD_base;
		`BASE_MEM_ADC_DAC+16'h14:cfg_rd_dat <= cfg_mAD_status_r1;
		`BASE_MEM_ADC_DAC+16'h18:cfg_rd_dat <= cfg_mDA_rnum;
		`BASE_MEM_ADC_DAC+16'h1C:cfg_rd_dat <= cfg_mDA_anum;
		`BASE_MEM_ADC_DAC+16'h20:cfg_rd_dat <= cfg_mDA_delay;
		`BASE_MEM_ADC_DAC+16'h24:cfg_rd_dat <= cfg_mDA_mode;
		`BASE_MEM_ADC_DAC+16'h28:cfg_rd_dat <= cfg_mDA_base;
		`BASE_MEM_ADC_DAC+16'h2C:cfg_rd_dat <= cfg_mDA_status_r1;
		`BASE_DEEP_FIFO+16'h00:cfg_rd_dat <= cfg_deepfifo_ctrl;
		`BASE_DEEP_FIFO+16'h04:cfg_rd_dat <= cfg_deepfifo_status_r1;
		`BASE_DEEP_FIFO+16'h08:cfg_rd_dat <= cfg_deepfifo_max_depth_r1;
		`BASE_DEEP_FIFO+16'h0C:cfg_rd_dat <= cfg_deepfifo_nonbypass_data_L_r1;
		`BASE_DEEP_FIFO+16'h10:cfg_rd_dat <= cfg_deepfifo_nonbypass_data_H_r1;
		`BASE_DEEP_FIFO+16'h14:cfg_rd_dat <= cfg_deepfifo_total_data_L_r1;
		`BASE_DEEP_FIFO+16'h18:cfg_rd_dat <= cfg_deepfifo_total_data_H_r1;
		`BASE_DEEP_FIFO+16'h1C:cfg_rd_dat <= cfg_deepfifo_status7_r1;
		`BASE_DEEP_FIFO+16'h20:cfg_rd_dat <= cfg_deepfifo_status8_r1;
		default:cfg_rd_dat <= 32'h0A0A_0A0A;
    endcase
end

always@(posedge cfg_clk)begin
    if(cfg_rst_r1)begin
		cfg_H2D_addr_dma <= 0;
		cfg_H2D_size_dma <= 0;
		cfg_H2D_burst_len <= 0;
		cfg_H2D_frame_len <= 0;
		cfg_H2D_trans_len <= 0;
		cfg_H2D_axi_ctrl <= 0;
		//cfg_H2D_axi_status <= 0;
		cfg_D2H_addr_dma <= 0;
		cfg_D2H_addr_sym <= 0;
		cfg_D2H_size_dma <= 0;
		cfg_D2H_size_sym <= 0;
		cfg_D2H_burst_len <= 0;
		cfg_D2H_frame_len <= 0;
		cfg_D2H_trans_len <= 0;
		cfg_D2H_axi_ctrl <= 0;
		//cfg_D2H_axi_status <= 0;
		aux_H2D_addr_dma <= 0;
		aux_H2D_size_dma <= 0;
		aux_H2D_burst_len <= 0;
		aux_H2D_frame_len <= 0;
		aux_H2D_axi_ctrl <= 0;
		//aux_H2D_axi_status <= 0;
		aux_D2H_addr_dma <= 0;
		aux_D2H_size_dma <= 0;
		aux_D2H_burst_len <= 0;
		aux_D2H_frame_len <= 0;
		aux_D2H_axi_ctrl <= 0;
		//aux_D2H_axi_status <= 0;
		cfg_AD_rnum <= 0;
		cfg_AD_anum <= 0;
		cfg_AD_delay <= 0;
		cfg_AD_mode <= 0;
		cfg_AD_base <= 0;
		//cfg_AD_status <= 0;
		cfg_DA_rnum <= 0;
		cfg_DA_anum <= 0;
		cfg_DA_delay <= 0;
		cfg_DA_mode <= 0;
		cfg_DA_base <= 0;
		//cfg_DA_status <= 0;
		cfg_prftime <= 0;
		cfg_pretime <= 0;
		cfg_prfmode <= 0;
		cfg_mode_ctrl <= 0;
		cfg_dev_adc_ctrl <= 0;
		//cfg_dev_adc_ro <= 0;
		cfg_dev_adc_filter <= 0;
		cfg_dev_adc_iodelay <= 0;
		cfg_dev_dac_ctrl <= 0;
		//cfg_dev_dac_ro <= 0;
		cfg_dev_dac_filter <= 0;
		cfg_dev_dac_iodelay <= 0;
		cfg_dev_ctrl <= 0;
		//cfg_dev_status <= 0;
		//cfg_dev_version <= 0;
		cfg_dev_spisel <= 0;
		cfg_param_mode <= 0;
		cfg_param_addr <= 0;
		cfg_param_size <= 0;
		cfg_port_addr <= 0;
		cfg_port_size <= 0;
		//cfg_param_status <= 0;
		cfg_param2_mode <= 0;
		cfg_param2_addr <= 0;
		cfg_param2_size <= 0;
		//cfg_param2_status <= 0;
		cfg_mAD_rnum <= 0;
		cfg_mAD_anum <= 0;
		cfg_mAD_delay <= 0;
		cfg_mAD_mode <= 0;
		cfg_mAD_base <= 0;
		//cfg_mAD_status <= 0;
		cfg_mDA_rnum <= 0;
		cfg_mDA_anum <= 0;
		cfg_mDA_delay <= 0;
		cfg_mDA_mode <= 0;
		cfg_mDA_base <= 0;
		//cfg_mDA_status <= 0;
		cfg_deepfifo_ctrl <= 0;
		//cfg_deepfifo_status <= 0;
		//cfg_deepfifo_max_depth <= 0;
		//cfg_deepfifo_nonbypass_data_L <= 0;
		//cfg_deepfifo_nonbypass_data_H <= 0;
		//cfg_deepfifo_total_data_L <= 0;
		//cfg_deepfifo_total_data_H <= 0;
		//cfg_deepfifo_status7 <= 0;
		//cfg_deepfifo_status8 <= 0;
    end
    else begin
        if (cfg_wr_en)begin
            case(cfg_wr_addr)
				`BASE_FAST_CHANNEL+16'h00:cfg_H2D_addr_dma <= cfg_wr_dat;
				`BASE_FAST_CHANNEL+16'h04:cfg_H2D_size_dma <= cfg_wr_dat;
				`BASE_FAST_CHANNEL+16'h08:cfg_H2D_burst_len <= cfg_wr_dat;
				`BASE_FAST_CHANNEL+16'h0C:cfg_H2D_frame_len <= cfg_wr_dat;
				`BASE_FAST_CHANNEL+16'h10:cfg_H2D_trans_len <= cfg_wr_dat;
				`BASE_FAST_CHANNEL+16'h14:cfg_H2D_axi_ctrl <= cfg_wr_dat;
				//`BASE_FAST_CHANNEL+16'h18:cfg_H2D_axi_status <= cfg_wr_dat;
				`BASE_FAST_CHANNEL+16'h1C:cfg_D2H_addr_dma <= cfg_wr_dat;
				`BASE_FAST_CHANNEL+16'h20:cfg_D2H_addr_sym <= cfg_wr_dat;
				`BASE_FAST_CHANNEL+16'h24:cfg_D2H_size_dma <= cfg_wr_dat;
				`BASE_FAST_CHANNEL+16'h28:cfg_D2H_size_sym <= cfg_wr_dat;
				`BASE_FAST_CHANNEL+16'h2C:cfg_D2H_burst_len <= cfg_wr_dat;
				`BASE_FAST_CHANNEL+16'h30:cfg_D2H_frame_len <= cfg_wr_dat;
				`BASE_FAST_CHANNEL+16'h34:cfg_D2H_trans_len <= cfg_wr_dat;
				`BASE_FAST_CHANNEL+16'h38:cfg_D2H_axi_ctrl <= cfg_wr_dat;
				//`BASE_FAST_CHANNEL+16'h3C:cfg_D2H_axi_status <= cfg_wr_dat;
				`BASE_SLOW_CHANNEL+16'h00:aux_H2D_addr_dma <= cfg_wr_dat;
				`BASE_SLOW_CHANNEL+16'h04:aux_H2D_size_dma <= cfg_wr_dat;
				`BASE_SLOW_CHANNEL+16'h08:aux_H2D_burst_len <= cfg_wr_dat;
				`BASE_SLOW_CHANNEL+16'h0C:aux_H2D_frame_len <= cfg_wr_dat;
				`BASE_SLOW_CHANNEL+16'h10:aux_H2D_axi_ctrl <= cfg_wr_dat;
				//`BASE_SLOW_CHANNEL+16'h14:aux_H2D_axi_status <= cfg_wr_dat;
				`BASE_SLOW_CHANNEL+16'h18:aux_D2H_addr_dma <= cfg_wr_dat;
				`BASE_SLOW_CHANNEL+16'h1C:aux_D2H_size_dma <= cfg_wr_dat;
				`BASE_SLOW_CHANNEL+16'h20:aux_D2H_burst_len <= cfg_wr_dat;
				`BASE_SLOW_CHANNEL+16'h24:aux_D2H_frame_len <= cfg_wr_dat;
				`BASE_SLOW_CHANNEL+16'h28:aux_D2H_axi_ctrl <= cfg_wr_dat;
				//`BASE_SLOW_CHANNEL+16'h2C:aux_D2H_axi_status <= cfg_wr_dat;
				`BASE_ADC_DAC+16'h00:cfg_AD_rnum <= cfg_wr_dat;
				`BASE_ADC_DAC+16'h04:cfg_AD_anum <= cfg_wr_dat;
				`BASE_ADC_DAC+16'h08:cfg_AD_delay <= cfg_wr_dat;
				`BASE_ADC_DAC+16'h0C:cfg_AD_mode <= cfg_wr_dat;
				`BASE_ADC_DAC+16'h10:cfg_AD_base <= cfg_wr_dat;
				//`BASE_ADC_DAC+16'h14:cfg_AD_status <= cfg_wr_dat;
				`BASE_ADC_DAC+16'h18:cfg_DA_rnum <= cfg_wr_dat;
				`BASE_ADC_DAC+16'h1C:cfg_DA_anum <= cfg_wr_dat;
				`BASE_ADC_DAC+16'h20:cfg_DA_delay <= cfg_wr_dat;
				`BASE_ADC_DAC+16'h24:cfg_DA_mode <= cfg_wr_dat;
				`BASE_ADC_DAC+16'h28:cfg_DA_base <= cfg_wr_dat;
				//`BASE_ADC_DAC+16'h2C:cfg_DA_status <= cfg_wr_dat;
				`BASE_DEVICE+16'h00:cfg_prftime <= cfg_wr_dat;
				`BASE_DEVICE+16'h04:cfg_pretime <= cfg_wr_dat;
				`BASE_DEVICE+16'h08:cfg_prfmode <= cfg_wr_dat;
				`BASE_DEVICE+16'h0C:cfg_mode_ctrl <= cfg_wr_dat;
				`BASE_DEVICE+16'h10:cfg_dev_adc_ctrl <= cfg_wr_dat;
				//`BASE_DEVICE+16'h14:cfg_dev_adc_ro <= cfg_wr_dat;
				`BASE_DEVICE+16'h18:cfg_dev_adc_filter <= cfg_wr_dat;
				`BASE_DEVICE+16'h1C:cfg_dev_adc_iodelay <= cfg_wr_dat;
				`BASE_DEVICE+16'h20:cfg_dev_dac_ctrl <= cfg_wr_dat;
				//`BASE_DEVICE+16'h24:cfg_dev_dac_ro <= cfg_wr_dat;
				`BASE_DEVICE+16'h28:cfg_dev_dac_filter <= cfg_wr_dat;
				`BASE_DEVICE+16'h2C:cfg_dev_dac_iodelay <= cfg_wr_dat;
				`BASE_DEVICE+16'h30:cfg_dev_ctrl <= cfg_wr_dat;
				//`BASE_DEVICE+16'h34:cfg_dev_status <= cfg_wr_dat;
				//`BASE_DEVICE+16'h38:cfg_dev_version <= cfg_wr_dat;
				`BASE_DEVICE+16'h3C:cfg_dev_spisel <= cfg_wr_dat;
				`BASE_PARAM_SET+16'h00:cfg_param_mode <= cfg_wr_dat;
				`BASE_PARAM_SET+16'h04:cfg_param_addr <= cfg_wr_dat;
				`BASE_PARAM_SET+16'h08:cfg_param_size <= cfg_wr_dat;
				`BASE_PARAM_SET+16'h0C:cfg_port_addr <= cfg_wr_dat;
				`BASE_PARAM_SET+16'h10:cfg_port_size <= cfg_wr_dat;
				//`BASE_PARAM_SET+16'h14:cfg_param_status <= cfg_wr_dat;
				`BASE_PARAM_SET+16'h18:cfg_param2_mode <= cfg_wr_dat;
				`BASE_PARAM_SET+16'h1C:cfg_param2_addr <= cfg_wr_dat;
				`BASE_PARAM_SET+16'h20:cfg_param2_size <= cfg_wr_dat;
				//`BASE_PARAM_SET+16'h24:cfg_param2_status <= cfg_wr_dat;
				`BASE_MEM_ADC_DAC+16'h00:cfg_mAD_rnum <= cfg_wr_dat;
				`BASE_MEM_ADC_DAC+16'h04:cfg_mAD_anum <= cfg_wr_dat;
				`BASE_MEM_ADC_DAC+16'h08:cfg_mAD_delay <= cfg_wr_dat;
				`BASE_MEM_ADC_DAC+16'h0C:cfg_mAD_mode <= cfg_wr_dat;
				`BASE_MEM_ADC_DAC+16'h10:cfg_mAD_base <= cfg_wr_dat;
				//`BASE_MEM_ADC_DAC+16'h14:cfg_mAD_status <= cfg_wr_dat;
				`BASE_MEM_ADC_DAC+16'h18:cfg_mDA_rnum <= cfg_wr_dat;
				`BASE_MEM_ADC_DAC+16'h1C:cfg_mDA_anum <= cfg_wr_dat;
				`BASE_MEM_ADC_DAC+16'h20:cfg_mDA_delay <= cfg_wr_dat;
				`BASE_MEM_ADC_DAC+16'h24:cfg_mDA_mode <= cfg_wr_dat;
				`BASE_MEM_ADC_DAC+16'h28:cfg_mDA_base <= cfg_wr_dat;
				//`BASE_MEM_ADC_DAC+16'h2C:cfg_mDA_status <= cfg_wr_dat;
				`BASE_DEEP_FIFO+16'h00:cfg_deepfifo_ctrl <= cfg_wr_dat;
				//`BASE_DEEP_FIFO+16'h04:cfg_deepfifo_status <= cfg_wr_dat;
				//`BASE_DEEP_FIFO+16'h08:cfg_deepfifo_max_depth <= cfg_wr_dat;
				//`BASE_DEEP_FIFO+16'h0C:cfg_deepfifo_nonbypass_data_L <= cfg_wr_dat;
				//`BASE_DEEP_FIFO+16'h10:cfg_deepfifo_nonbypass_data_H <= cfg_wr_dat;
				//`BASE_DEEP_FIFO+16'h14:cfg_deepfifo_total_data_L <= cfg_wr_dat;
				//`BASE_DEEP_FIFO+16'h18:cfg_deepfifo_total_data_H <= cfg_wr_dat;
				//`BASE_DEEP_FIFO+16'h1C:cfg_deepfifo_status7 <= cfg_wr_dat;
				//`BASE_DEEP_FIFO+16'h20:cfg_deepfifo_status8 <= cfg_wr_dat;
		        default:begin
                end
            endcase
        end
    end
end


always@(posedge cfg_clk)begin
    if(cfg_rst_r1)begin
		 cfg_H2D_axi_status_r1 <= 0;
		 cfg_D2H_axi_status_r1 <= 0;
		 aux_H2D_axi_status_r1 <= 0;
		 aux_D2H_axi_status_r1 <= 0;
		 cfg_AD_status_r1 <= 0;
		 cfg_DA_status_r1 <= 0;
		 cfg_dev_adc_ro_r1 <= 0;
		 cfg_dev_dac_ro_r1 <= 0;
		 cfg_dev_status_r1 <= 0;
		 cfg_dev_version_r1 <= 0;
		 cfg_param_status_r1 <= 0;
		 cfg_param2_status_r1 <= 0;
		 cfg_mAD_status_r1 <= 0;
		 cfg_mDA_status_r1 <= 0;
		 cfg_deepfifo_status_r1 <= 0;
		 cfg_deepfifo_max_depth_r1 <= 0;
		 cfg_deepfifo_nonbypass_data_L_r1 <= 0;
		 cfg_deepfifo_nonbypass_data_H_r1 <= 0;
		 cfg_deepfifo_total_data_L_r1 <= 0;
		 cfg_deepfifo_total_data_H_r1 <= 0;
		 cfg_deepfifo_status7_r1 <= 0;
		 cfg_deepfifo_status8_r1 <= 0;

    end
    else begin
		 cfg_H2D_axi_status_r1 <= cfg_H2D_axi_status;
		 cfg_D2H_axi_status_r1 <= cfg_D2H_axi_status;
		 aux_H2D_axi_status_r1 <= aux_H2D_axi_status;
		 aux_D2H_axi_status_r1 <= aux_D2H_axi_status;
		 cfg_AD_status_r1 <= cfg_AD_status;
		 cfg_DA_status_r1 <= cfg_DA_status;
		 cfg_dev_adc_ro_r1 <= cfg_dev_adc_ro;
		 cfg_dev_dac_ro_r1 <= cfg_dev_dac_ro;
		 cfg_dev_status_r1 <= cfg_dev_status;
		 cfg_dev_version_r1 <= cfg_dev_version;
		 cfg_param_status_r1 <= cfg_param_status;
		 cfg_param2_status_r1 <= cfg_param2_status;
		 cfg_mAD_status_r1 <= cfg_mAD_status;
		 cfg_mDA_status_r1 <= cfg_mDA_status;
		 cfg_deepfifo_status_r1 <= cfg_deepfifo_status;
		 cfg_deepfifo_max_depth_r1 <= cfg_deepfifo_max_depth;
		 cfg_deepfifo_nonbypass_data_L_r1 <= cfg_deepfifo_nonbypass_data_L;
		 cfg_deepfifo_nonbypass_data_H_r1 <= cfg_deepfifo_nonbypass_data_H;
		 cfg_deepfifo_total_data_L_r1 <= cfg_deepfifo_total_data_L;
		 cfg_deepfifo_total_data_H_r1 <= cfg_deepfifo_total_data_H;
		 cfg_deepfifo_status7_r1 <= cfg_deepfifo_status7;
		 cfg_deepfifo_status8_r1 <= cfg_deepfifo_status8;

    end
end
endmodule
