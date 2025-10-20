`timescale 1ns / 1ps

module tb_data_dac_pre();

// dac_data_pre Parameters
parameter LOCAL_DWIDTH     = 256            ;
parameter WIDTH            = 16             ;
parameter FFT_WIDTH        = 24             ;
parameter LANE_NUM         = 8              ;
parameter CHIRP_NUM        = 256            ;
parameter CALCLT_DELAY     = 35             ;
parameter DWIDTH_0         = 32             ;
parameter SHIFT_RAM_DELAY  = (DWIDTH_0 >> 1);
parameter ADC_CLK_FREQ     = 156_250_000    ;
parameter RECO_DELAY       = 29             ;

// dac_data_pre Inputs
reg   dac_clk;
reg   dac_rst;

reg   adc_clk;
reg   adc_rst;

wire  ramrpu_clk;
wire  ramrpu_en =1;
reg   [3 : 0 ]  ramrpu_we;
reg   [31 : 0]  ramrpu_addr;
reg   [31 : 0]  ramrpu_din;
reg   ramrpu_rst;
reg   [127:0]  m00_axis_tdata;
reg   [127:0]  m01_axis_tdata;
reg   [127:0]  m02_axis_tdata;
reg   [127:0]  m03_axis_tdata;

reg   ramb_clk;
reg   ramb_en;
reg   [3 : 0 ]  ramb_we;
reg   [31 : 0]  ramb_addr;
reg   [31 : 0]  ramb_din;
reg   ramb_rst;
reg   rama_clk;
reg   rama_en;
reg   [3 : 0 ]  rama_we;
reg   [31 : 0]  rama_addr;
reg   [31 : 0]  rama_din;
reg   rama_rst;

reg   [LOCAL_DWIDTH-1:0]  mfifo_rd_data;

// dac_data_pre Outputs
wire  [31 : 0]  ramrpu_dout;
wire  [31 : 0]  ramb_dout;
wire  [31 : 0]  rama_dout;
wire  mfifo_rd_enable;
wire  [255:0]  s00_axis_tdata;
wire  adc_valid;
wire  dac_valid_adjust;
wire  [255:0]  dac_data_adjust;
wire  data_record_mode;
wire  rf_out;
wire  RF_A_TXEN;
wire  bc_tx_en;
wire  record_en;
wire  prffix_inter;
wire  preprf_inter;
wire  prfin_inter;
wire  RF_TXEN_inter;
wire  BC_TXEN_inter;

assign ramrpu_clk = adc_clk;

localparam CLK_PERIOD = 6.4;

initial begin
    dac_clk = 0;
    adc_clk = 0;
    ramrpu_we = 4'h0;
end

always #(CLK_PERIOD/2.0) dac_clk = ~dac_clk;
always #(CLK_PERIOD/2.0) adc_clk = ~adc_clk;

initial begin
    write_ctrl_reg();
    repeat(5) begin
        m00_axis_tdata = {8{16'h50}};
        m01_axis_tdata = {8{16'h50}};
        m02_axis_tdata = {8{16'h10}};
        m03_axis_tdata = {8{16'h10}};
        #(CLK_PERIOD*4)
        m00_axis_tdata = {8{16'h50}};
        m01_axis_tdata = {8{16'h50}};
        m02_axis_tdata = {8{16'h40}};
        m03_axis_tdata = {8{16'h40}};
        #(CLK_PERIOD*4)
        m00_axis_tdata = 0;
        m01_axis_tdata = 0;
        m02_axis_tdata = 0;
        m03_axis_tdata = 0;
        #(CLK_PERIOD*2000);
    end
end


task write_ctrl_reg;
begin
    // 初始化参数写入
    write_register(0, 6016, 4'hf);         // param0: chirp_num = 6016
    write_register(4, 1024, 4'hf);         // param1: proc_num = 1024
    write_register(8, 0, 4'hf);            // param2: k_value = 0
    write_register(12, 0, 4'hf);           // param3: b_value = 0
    write_register(16, -32'sd245, 4'hf);   // param4: template_delay = -245
    write_register(20, 746280, 4'hf);      // param5: distance_delay = 746280
    write_register(24, 0, 4'hf);           // param6: kb_valid = 0
    write_register(28, 1024, 4'hf);        // param7: adc_threshold = 1024
    write_register(32, 1, 4'hf);           // param8: mode_value = 1
    write_register(36, 31095, 4'hf);       // param9: prf_period = 31095
    write_register(40, 200, 4'hf);         // param10: prf->adc延迟 = 200
    write_register(44, 10, 4'hf);          // param11: disturb_times = 10
    write_register(48, 1, 4'hf);           // param12: resetn(software) = 1
    write_register(52, 0, 4'hf);           // param13: prf_adjust_req = 0
    write_register(56, -32'sd5, 4'hf);     // param14: prf_cnt_offset = -5
    write_register(60, -32'sd0, 4'hf);     // param15: change_req = 0
    write_register(64, 1, 4'hf);           // param16: star_mode = 1
    write_register(68, 0, 4'hf);           // param17: record_mode = 0
    write_register(72, 32'sd32767, 4'hf);  // param18: 功率系数 = 32767
    write_register(76, 0, 4'hf);           // param19: adc_channel_sel = 0
    write_register(80, 500, 4'hf);         // param20: data_record_period = 500
end
endtask

task write_register;
    input [31:0] addr;  // 寄存器地址
    input [31:0] data;  // 要写入的数据
    input [3:0] we;     // 写使能信号
begin
    ramrpu_addr = addr;    // 设置寄存器地址
    ramrpu_din = data;     // 设置要写入的数据
    ramrpu_we = we;        // 设置写使能信号
    #(CLK_PERIOD * 2);     // 写操作延迟
    ramrpu_we = 4'h0;      // 清除写使能信号
    #(CLK_PERIOD * 2);     // 等待下一个周期
end
endtask



dac_data_pre #(
    .LOCAL_DWIDTH    (LOCAL_DWIDTH    ),
    .WIDTH           (WIDTH           ),
    .FFT_WIDTH       (FFT_WIDTH       ),
    .LANE_NUM        (LANE_NUM        ),
    .CHIRP_NUM       (CHIRP_NUM       ),
    .CALCLT_DELAY    (CALCLT_DELAY    ),
    .DWIDTH_0        (DWIDTH_0        ),
    .SHIFT_RAM_DELAY (SHIFT_RAM_DELAY ),
    .ADC_CLK_FREQ    (ADC_CLK_FREQ    ),
    .RECO_DELAY      (RECO_DELAY      )
)
 u_dac_data_pre (
    .dac_clk                 ( dac_clk            ),
    .dac_rst                 ( dac_rst            ),
    .adc_clk                 ( adc_clk            ),
    .adc_rst                 ( adc_rst            ),
    .ramrpu_clk              ( ramrpu_clk         ),
    .ramrpu_en               ( ramrpu_en          ),
    .ramrpu_we               ( ramrpu_we          ),
    .ramrpu_addr             ( ramrpu_addr        ),
    .ramrpu_din              ( ramrpu_din         ),
    .ramrpu_rst              ( ramrpu_rst         ),
    .m00_axis_tdata          ( m00_axis_tdata     ),
    .m01_axis_tdata          ( m01_axis_tdata     ),
    .m02_axis_tdata          ( m02_axis_tdata     ),
    .m03_axis_tdata          ( m03_axis_tdata     ),
    .ramb_clk                ( ramb_clk           ),
    .ramb_en                 ( ramb_en            ),
    .ramb_we                 ( ramb_we            ),
    .ramb_addr               ( ramb_addr          ),
    .ramb_din                ( ramb_din           ),
    .ramb_rst                ( ramb_rst           ),
    .rama_clk                ( rama_clk           ),
    .rama_en                 ( rama_en            ),
    .rama_we                 ( rama_we            ),
    .rama_addr               ( rama_addr          ),
    .rama_din                ( rama_din           ),
    .rama_rst                ( rama_rst           ),
    .mfifo_rd_data           ( mfifo_rd_data      ),

    .ramrpu_dout             ( ramrpu_dout        ),
    .ramb_dout               ( ramb_dout          ),
    .rama_dout               ( rama_dout          ),
    .mfifo_rd_enable         ( mfifo_rd_enable    ),
    .s00_axis_tdata          ( s00_axis_tdata     ),
    .adc_valid               ( adc_valid          ),
    .dac_valid_adjust        ( dac_valid_adjust   ),
    .dac_data_adjust         ( dac_data_adjust    ),
    .data_record_mode        ( data_record_mode   ),
    .rf_out                  ( rf_out             ),
    .bc_tx_en                ( bc_tx_en           ),
    .record_en               ( record_en          ),
    .prffix_inter            ( prffix_inter       ),
    .preprf_inter            ( preprf_inter       ),
    .prfin_inter             ( prfin_inter        ),
    .RF_TXEN_inter           ( RF_TXEN_inter      ),
    .BC_TXEN_inter           ( BC_TXEN_inter      )
);
endmodule
