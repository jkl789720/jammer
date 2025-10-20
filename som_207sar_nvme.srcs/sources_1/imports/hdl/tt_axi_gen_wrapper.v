//Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2020.2 (win64) Build 3064766 Wed Nov 18 09:12:45 MST 2020
//Date        : Mon Apr  1 19:35:36 2024
//Host        : DESKTOP-LGKJH9K running 64-bit major release  (build 9200)
//Command     : generate_target tt_axi_gen_wrapper.bd
//Design      : tt_axi_gen_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module tt_axi_gen_wrapper
   (BRAM_PORTA_addr,
    BRAM_PORTA_clk,
    BRAM_PORTA_din,
    BRAM_PORTA_dout,
    BRAM_PORTA_en,
    BRAM_PORTA_rst,
    BRAM_PORTA_we,
    core_ext_start,
    irq_out,
    s_axi_aclk,
    s_axi_aresetn);
  output [23:0]BRAM_PORTA_addr;
  output BRAM_PORTA_clk;
  output [31:0]BRAM_PORTA_din;
  input [31:0]BRAM_PORTA_dout;
  output BRAM_PORTA_en;
  output BRAM_PORTA_rst;
  output [3:0]BRAM_PORTA_we;
  input core_ext_start;
  output irq_out;
  input s_axi_aclk;
  input s_axi_aresetn;

  wire [23:0]BRAM_PORTA_addr;
  wire BRAM_PORTA_clk;
  wire [31:0]BRAM_PORTA_din;
  wire [31:0]BRAM_PORTA_dout;
  wire BRAM_PORTA_en;
  wire BRAM_PORTA_rst;
  wire [3:0]BRAM_PORTA_we;
  wire core_ext_start;
  wire irq_out;
  wire s_axi_aclk;
  wire s_axi_aresetn;

  tt_axi_gen tt_axi_gen_i
       (.BRAM_PORTA_addr(BRAM_PORTA_addr),
        .BRAM_PORTA_clk(BRAM_PORTA_clk),
        .BRAM_PORTA_din(BRAM_PORTA_din),
        .BRAM_PORTA_dout(BRAM_PORTA_dout),
        .BRAM_PORTA_en(BRAM_PORTA_en),
        .BRAM_PORTA_rst(BRAM_PORTA_rst),
        .BRAM_PORTA_we(BRAM_PORTA_we),
        .core_ext_start(core_ext_start),
        .irq_out(irq_out),
        .s_axi_aclk(s_axi_aclk),
        .s_axi_aresetn(s_axi_aresetn));
endmodule
