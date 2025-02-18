##GROUP1
set_property PACKAGE_PIN E12 [get_ports {BC_sd_o[0]}]
set_property PACKAGE_PIN D12 [get_ports {BC_sd_o[1]}]
set_property PACKAGE_PIN G12 [get_ports {BC_sd_o[2]}]
set_property PACKAGE_PIN F12 [get_ports {BC_sd_o[3]}]
##GROUP2                                 
set_property PACKAGE_PIN K14 [get_ports {BC_sd_o[4]}]
set_property PACKAGE_PIN K15 [get_ports {BC_sd_o[5]}]
set_property PACKAGE_PIN J13 [get_ports {BC_sd_o[6]}]
set_property PACKAGE_PIN J14 [get_ports {BC_sd_o[7]}]
##GROUP3                                 
set_property PACKAGE_PIN B12 [get_ports {BC_sd_o[8]}]
set_property PACKAGE_PIN A13 [get_ports {BC_sd_o[9]}]
set_property PACKAGE_PIN A14 [get_ports {BC_sd_o[10]}]
set_property PACKAGE_PIN A12 [get_ports {BC_sd_o[11]}]
##GROUP4                                
set_property PACKAGE_PIN G13 [get_ports {BC_sd_o[12]}]
set_property PACKAGE_PIN H14 [get_ports {BC_sd_o[13]}]
set_property PACKAGE_PIN H13 [get_ports {BC_sd_o[14]}]
set_property PACKAGE_PIN H15 [get_ports {BC_sd_o[15]}]


#ctrl
set_property PACKAGE_PIN B13 [get_ports BC_scl_o]
set_property PACKAGE_PIN C14 [get_ports BC_ld_o]
set_property PACKAGE_PIN F14 [get_ports BC_dary_o]
set_property PACKAGE_PIN F13 [get_ports BC_sel_o]
set_property PACKAGE_PIN D13 [get_ports BC_rst_o]

##prf
# set_property PACKAGE_PIN E14 [get_ports prf_in]



set_property IOSTANDARD LVCMOS33 [get_ports {BC_sd_o[15]}]
set_property IOSTANDARD LVCMOS33 [get_ports {BC_sd_o[14]}]
set_property IOSTANDARD LVCMOS33 [get_ports {BC_sd_o[13]}]
set_property IOSTANDARD LVCMOS33 [get_ports {BC_sd_o[12]}]
set_property IOSTANDARD LVCMOS33 [get_ports {BC_sd_o[11]}]
set_property IOSTANDARD LVCMOS33 [get_ports {BC_sd_o[10]}]
set_property IOSTANDARD LVCMOS33 [get_ports {BC_sd_o[9]}]
set_property IOSTANDARD LVCMOS33 [get_ports {BC_sd_o[8]}]
set_property IOSTANDARD LVCMOS33 [get_ports {BC_sd_o[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {BC_sd_o[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {BC_sd_o[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {BC_sd_o[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {BC_sd_o[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {BC_sd_o[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {BC_sd_o[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {BC_sd_o[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports BC_ld_o]
set_property IOSTANDARD LVCMOS33 [get_ports BC_dary_o]
set_property IOSTANDARD LVCMOS33 [get_ports BC_rst_o]
set_property IOSTANDARD LVCMOS33 [get_ports BC_scl_o]
set_property IOSTANDARD LVCMOS33 [get_ports BC_sel_o]
# set_property IOSTANDARD LVCMOS33 [get_ports prf_in]




# set_property PULLDOWN true [get_ports {data_sending}]
# set_property PACKAGE_PIN F9 [get_ports {data_sending}]
# set_property IOSTANDARD LVTTL [get_ports {data_sending}]

set_false_path -from [get_clocks clk_pl_0] -to [get_clocks clk_out1_clk_wiz_0_1]
set_false_path -from [get_clocks clk_out1_clk_wiz_0_1] -to [get_clocks clk_pl_0]
set_false_path -from [get_pins -hier -filter {NAME=~ u_spi/u_vio_scl/inst/PROBE_OUT_ALL_INST/G_PROBE_OUT[0].PROBE_OUT0_INST/Probe_out_reg[*]/C}]
# set_false_path -from [get_pins -hier -filter {NAME=~ {u_spi/u_vio_scl/inst/PROBE_OUT_ALL_INST/G_PROBE_OUT[4].PROBE_OUT0_INST/Probe_out_reg[*]/C}]]

set_property IOSTANDARD LVCMOS33 [get_ports trt_o_p_0] 
set_property IOSTANDARD LVCMOS33 [get_ports trr_o_p_0] 
set_property IOSTANDARD LVCMOS33 [get_ports trt_o_p_1] 
set_property IOSTANDARD LVCMOS33 [get_ports trr_o_p_1] 
set_property IOSTANDARD LVCMOS33 [get_ports trt_o_p_2] 
set_property IOSTANDARD LVCMOS33 [get_ports trr_o_p_2] 
set_property IOSTANDARD LVCMOS33 [get_ports trt_o_p_3] 
set_property IOSTANDARD LVCMOS33 [get_ports trr_o_p_3] 

set_property PACKAGE_PIN H9  [get_ports trt_o_p_0]
set_property PACKAGE_PIN K10 [get_ports trr_o_p_0]
set_property PACKAGE_PIN D14 [get_ports trt_o_p_1]
set_property PACKAGE_PIN C13 [get_ports trr_o_p_1]
set_property PACKAGE_PIN J11 [get_ports trt_o_p_2]
set_property PACKAGE_PIN K11 [get_ports trr_o_p_2]
set_property PACKAGE_PIN H10 [get_ports trt_o_p_3]
set_property PACKAGE_PIN H11 [get_ports trr_o_p_3]