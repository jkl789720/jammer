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
    forever begin
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



// //param

//   localparam PRF_PERIOD = 31095;
//   assign app_param0 = 6016;                    //chirp_num
//   assign app_param1 = 1024;                    //proc_num
//   assign app_param2 = k_vlaue;                 //k_value
//   assign app_param3 = b_vlaue;                 //b_value
//   assign app_param4 = -32'sd245;               //template_delay
//   assign app_param5 = PRF_PERIOD*3*8;          //distance_delay 30000*8-200*12 + 7 (30000/2)*8
//   assign app_param6 = app_status9[0];          //kb_valid 暂时无效，通过正确的延时来确立的k、b信号有效
//   assign app_param7 = 128*8;                   //adc_shreshold
//   assign app_param8 = 1;                       //mode_value

//   assign app_param9  = PRF_PERIOD;             //prf_period 200us
//   assign app_param10 = 200;                    //prf->adc延迟
//   assign app_param11 = 10;                     //disturb_times
//   assign app_param12 = 1;                      //resetn(software)
//   assign app_param13 = 0;                      //prf_adjust_req
//   assign app_param14 = -32'sd5;                //prf_cnt_offset
//   assign app_param16 = 1;                      //star_mode
//   assign app_param17 = 0;                      //record_mode
//   assign app_param18 = 32'sd32767;             //功率系数
//   assign app_param19 = 0;                      //adc_channel_sel
//   assign app_param20 = 500;                    //data_record_period

  // initial begin
  //   #1000
  //   app_param15 = 0;//fft点数change_req
  //   #1000
  //   app_param15 = 1;
  // end


task write_ctrl_reg;
begin
// 初始化参数写入
  // param0: chirp_num = 6016
    ramrpu_addr = 0;
    ramrpu_din = 6016;
    ramrpu_we = 4'hf;
    #(CLK_PERIOD*2);
    ramrpu_we = 4'h0;
    #(CLK_PERIOD*2);
  
    // param1: proc_num = 1024
    ramrpu_addr = 4;
    ramrpu_din = 1024;
    ramrpu_we = 4'hf;
    #(CLK_PERIOD*2);
    ramrpu_we = 4'h0;
    #(CLK_PERIOD*2);
  
    // param2: k_value = k_vlaue
    ramrpu_addr = 8;
    ramrpu_din = 0;
    ramrpu_we = 4'hf;
    #(CLK_PERIOD*2);
    ramrpu_we = 4'h0;
    #(CLK_PERIOD*2);
  
    // param3: b_value = b_vlaue
    ramrpu_addr = 12;
    ramrpu_din = 0;
    ramrpu_we = 4'hf;
    #(CLK_PERIOD*2);
    ramrpu_we = 4'h0;
    #(CLK_PERIOD*2);
  
    // param4: template_delay = -245
    ramrpu_addr = 16;
    ramrpu_din = -32'sd245;
    ramrpu_we = 4'hf;
    #(CLK_PERIOD*2);
    ramrpu_we = 4'h0;
    #(CLK_PERIOD*2);
  
    // param5: distance_delay = 31095*3*8 = 746280
    ramrpu_addr = 20;
    ramrpu_din = 746280;
    ramrpu_we = 4'hf;
    #(CLK_PERIOD*2);
    ramrpu_we = 4'h0;
    #(CLK_PERIOD*2);
  
    // param6: kb_valid = app_status9[0]（假设初始值为 0）
    ramrpu_addr = 24;
    ramrpu_din = 0;
    ramrpu_we = 4'hf;
    #(CLK_PERIOD*2);
    ramrpu_we = 4'h0;
    #(CLK_PERIOD*2);
  
    // param7: adc_threshold = 128*8 = 1024
    ramrpu_addr = 28;
    ramrpu_din = 1024;
    ramrpu_we = 4'hf;
    #(CLK_PERIOD*2);
    ramrpu_we = 4'h0;
    #(CLK_PERIOD*2);
  
    // param8: mode_value = 1
    ramrpu_addr = 32;
    ramrpu_din = 1;
    ramrpu_we = 4'hf;
    #(CLK_PERIOD*2);
    ramrpu_we = 4'h0;
    #(CLK_PERIOD*2);
  
    // param9: prf_period = 31095
    ramrpu_addr = 36;
    ramrpu_din = 31095;
    ramrpu_we = 4'hf;
    #(CLK_PERIOD*2);
    ramrpu_we = 4'h0;
    #(CLK_PERIOD*2);
  
    // param10: prf->adc延迟 = 200
    ramrpu_addr = 40;
    ramrpu_din = 200;
    ramrpu_we = 4'hf;
    #(CLK_PERIOD*2);
    ramrpu_we = 4'h0;
    #(CLK_PERIOD*2);
  
    // param11: disturb_times = 10
    ramrpu_addr = 44;
    ramrpu_din = 10;
    ramrpu_we = 4'hf;
    #(CLK_PERIOD*2);
    ramrpu_we = 4'h0;
    #(CLK_PERIOD*2);
  
    // param12: resetn(software) = 1
    ramrpu_addr = 48;
    ramrpu_din = 1;
    ramrpu_we = 4'hf;
    #(CLK_PERIOD*2);
    ramrpu_we = 4'h0;
    #(CLK_PERIOD*2);
  
    // param13: prf_adjust_req = 0
    ramrpu_addr = 52;
    ramrpu_din = 0;
    ramrpu_we = 4'hf;
    #(CLK_PERIOD*2);
    ramrpu_we = 4'h0;
    #(CLK_PERIOD*2);
  
    // param14: prf_cnt_offset = -5
    ramrpu_addr = 56;
    ramrpu_din = -32'sd5;
    ramrpu_we = 4'hf;
    #(CLK_PERIOD*2);
    ramrpu_we = 4'h0;
    #(CLK_PERIOD*2);
  
    // // param15: fft点数change_req（后续单独处理）
    // // 初始块中延后写入
    // #1000;
    // ramrpu_addr = 60;
    // ramrpu_din = 0;
    // ramrpu_we = 4'hf;
    // #(CLK_PERIOD*2);
    // ramrpu_we = 4'h0;
    // #(CLK_PERIOD*2);
    // #1000;
    // ramrpu_addr = 60;
    // ramrpu_din = 1;
    // ramrpu_we = 4'hf;
    // #(CLK_PERIOD*2);
    // ramrpu_we = 4'h0;
    // #(CLK_PERIOD*2);
  
    // param16: star_mode = 1
    ramrpu_addr = 64;
    ramrpu_din = 1;
    ramrpu_we = 4'hf;
    #(CLK_PERIOD*2);
    ramrpu_we = 4'h0;
    #(CLK_PERIOD*2);
  
    // param17: record_mode = 0
    ramrpu_addr = 68;
    ramrpu_din = 0;
    ramrpu_we = 4'hf;
    #(CLK_PERIOD*2);
    ramrpu_we = 4'h0;
    #(CLK_PERIOD*2);
  
    // param18: 功率系数 = 32767
    ramrpu_addr = 72;
    ramrpu_din = 32'sd32767;
    ramrpu_we = 4'hf;
    #(CLK_PERIOD*2);
    ramrpu_we = 4'h0;
    #(CLK_PERIOD*2);
  
    // param19: adc_channel_sel = 0
    ramrpu_addr = 76;
    ramrpu_din = 0;
    ramrpu_we = 4'hf;
    #(CLK_PERIOD*2);
    ramrpu_we = 4'h0;
    #(CLK_PERIOD*2);
  
    // param20: data_record_period = 500
    ramrpu_addr = 80;
    ramrpu_din = 500;
    ramrpu_we = 4'hf;
    #(CLK_PERIOD*2);
    ramrpu_we = 4'h0;
    #(CLK_PERIOD*2);
end    
endtask

initial begin
    forever begin
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
    .RF_A_TXEN               ( RF_A_TXEN          ),
    .bc_tx_en                ( bc_tx_en           ),
    .record_en               ( record_en          ),
    .prffix_inter            ( prffix_inter       ),
    .preprf_inter            ( preprf_inter       ),
    .prfin_inter             ( prfin_inter        ),
    .RF_TXEN_inter           ( RF_TXEN_inter      ),
    .BC_TXEN_inter           ( BC_TXEN_inter      )
);
endmodule
