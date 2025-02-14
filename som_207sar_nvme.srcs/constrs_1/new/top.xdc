set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design] 

create_clock -name clk_pl_0 -period "6.666" [get_pins "PS8_i/PLCLK[0]"]
create_clock -name clk_pl_1 -period "20" [get_pins "PS8_i/PLCLK[1]"]

set_false_path -from [get_clocks mmcm_clkout0] -to [get_clocks clk_pl_0]
#set_false_path -from [get_clocks xdma_0_axi_aclk] -to [get_clocks clk_pl_0]
#set_false_path -from [get_clocks xdma_1_axi_aclk] -to [get_clocks clk_pl_0]
#set_false_path -from [get_clocks clk_pl_0] -to [get_clocks xdma_0_axi_aclk]
#set_false_path -from [get_clocks clk_pl_0] -to [get_clocks xdma_1_axi_aclk]
#set_false_path -from [get_clocks xdma_0_axi_aclk] -to [get_clocks clk_out1_clk_wiz]
#set_false_path -from [get_clocks xdma_1_axi_aclk] -to [get_clocks clk_out1_clk_wiz]


set_false_path -from [get_clocks pcie_userclk0] -to [get_clocks clk_out1_clk_sys]
set_false_path -from [get_clocks clk_out1_clk_sys] -to [get_clocks pcie_userclk0]
set_false_path -from [get_clocks pcie_userclk1] -to [get_clocks clk_out1_clk_sys]
set_false_path -from [get_clocks clk_out1_clk_sys] -to [get_clocks pcie_userclk1]
set_false_path -from [get_clocks pcie_userclk0] -to [get_clocks clk_pl_0]
set_false_path -from [get_clocks clk_pl_0] -to [get_clocks pcie_userclk0]
set_false_path -from [get_clocks pcie_userclk1] -to [get_clocks clk_pl_0]
set_false_path -from [get_clocks clk_pl_0] -to [get_clocks pcie_userclk1]

#set_false_path -from [get_clocks CLK_DCLK_PL_P] -to [get_clocks clk_pl_0]
#set_false_path -from [get_clocks clk_pl_0] -to [get_clocks CLK_DCLK_PL_P]
#set_false_path -from [get_clocks CLK_DCLK_PL_P] -to [get_clocks clk_out1_clk_sys]
#set_false_path -from [get_clocks clk_out1_clk_sys] -to [get_clocks CLK_DCLK_PL_P]
#set_false_path -from [get_clocks CLK_DCLK_PL_P] -to [get_clocks clk_out2_clk_sys]
#set_false_path -from [get_clocks clk_out2_clk_sys] -to [get_clocks CLK_DCLK_PL_P]
#set_false_path -from [get_clocks CLK_DCLK_PL_P] -to [get_clocks clk_out3_clk_sys]
#set_false_path -from [get_clocks clk_out3_clk_sys] -to [get_clocks CLK_DCLK_PL_P]

set_false_path -from [get_clocks clk_out1_clk_dclk] -to [get_clocks clk_pl_0]
set_false_path -from [get_clocks clk_pl_0] -to [get_clocks clk_out1_clk_dclk]
set_false_path -from [get_clocks clk_out1_clk_dclk] -to [get_clocks clk_out1_clk_sys]
set_false_path -from [get_clocks clk_out1_clk_sys] -to [get_clocks clk_out1_clk_dclk]
set_false_path -from [get_clocks clk_out1_clk_dclk] -to [get_clocks clk_out2_clk_sys]
set_false_path -from [get_clocks clk_out2_clk_sys] -to [get_clocks clk_out1_clk_dclk]


set_false_path -from [get_clocks RFADC0_CLK] -to [get_clocks clk_out1_clk_sys]
set_false_path -from [get_clocks RFADC1_CLK] -to [get_clocks clk_out1_clk_sys]
set_false_path -from [get_clocks RFDAC0_CLK] -to [get_clocks clk_out1_clk_sys]
set_false_path -from [get_clocks RFDAC1_CLK] -to [get_clocks clk_out1_clk_sys]
set_false_path -from [get_clocks clk_out1_clk_sys] -to [get_clocks RFADC0_CLK]
set_false_path -from [get_clocks clk_out1_clk_sys] -to [get_clocks RFADC1_CLK]
set_false_path -from [get_clocks clk_out1_clk_sys] -to [get_clocks RFDAC0_CLK]
set_false_path -from [get_clocks clk_out1_clk_sys] -to [get_clocks RFDAC1_CLK]

set_false_path -from [get_clocks clk_pl_0] -to [get_clocks clk_out3_clk_sys]
set_false_path -from [get_clocks clk_out3_clk_sys] -to [get_clocks clk_pl_0]
set_false_path -from [get_clocks clk_pl_0] -to [get_clocks clk_out2_clk_sys]
set_false_path -from [get_clocks clk_out2_clk_sys] -to [get_clocks clk_pl_0]
set_false_path -from [get_clocks clk_pl_0] -to [get_clocks clk_out1_clk_sys]
set_false_path -from [get_clocks clk_out1_clk_sys] -to [get_clocks clk_pl_0]
set_false_path -from [get_clocks clk_out3_clk_sys] -to [get_clocks clk_out1_clk_sys]
set_false_path -from [get_clocks clk_out1_clk_sys] -to [get_clocks clk_out3_clk_sys]
set_false_path -from [get_clocks clk_out3_clk_sys] -to [get_clocks clk_out2_clk_sys]
set_false_path -from [get_clocks clk_out2_clk_sys] -to [get_clocks clk_out3_clk_sys]

set_false_path -from [get_clocks clk_pl_0] -to [get_clocks -of_objects [get_pins cpu_ep/cpu_subsys_EP0/xdma_0/inst/pcie4c_ip_i/inst/cpu_subsys_xdma_0_0_pcie4c_ip_gt_top_i/diablo_gt.diablo_gt_phy_wrapper/phy_clk_i/bufg_gt_userclk/O]]
set_false_path -from [get_clocks clk_pl_0] -to [get_clocks -of_objects [get_pins cpu_ep/cpu_subsys_EP0/xdma_1/inst/pcie4c_ip_i/inst/cpu_subsys_xdma_1_0_pcie4c_ip_gt_top_i/diablo_gt.diablo_gt_phy_wrapper/phy_clk_i/bufg_gt_userclk/O]]
set_false_path -from [get_clocks clk_pl_0] -to [get_clocks {cpu_ep/cpu_subsys_EP0/xdma_0/inst/pcie4c_ip_i/inst/cpu_subsys_xdma_0_0_pcie4c_ip_gt_top_i/diablo_gt.diablo_gt_phy_wrapper/gt_wizard.gtwizard_top_i/cpu_subsys_xdma_0_0_pcie4c_ip_gt_i/inst/gen_gtwizard_gtye4_top.cpu_subsys_xdma_0_0_pcie4c_ip_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[2].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[3].GTYE4_CHANNEL_PRIM_INST/TXOUTCLK}]
set_false_path -from [get_clocks clk_pl_0] -to [get_clocks {cpu_ep/cpu_subsys_EP0/xdma_1/inst/pcie4c_ip_i/inst/cpu_subsys_xdma_1_0_pcie4c_ip_gt_top_i/diablo_gt.diablo_gt_phy_wrapper/gt_wizard.gtwizard_top_i/cpu_subsys_xdma_1_0_pcie4c_ip_gt_i/inst/gen_gtwizard_gtye4_top.cpu_subsys_xdma_1_0_pcie4c_ip_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[2].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[3].GTYE4_CHANNEL_PRIM_INST/TXOUTCLK}]
set_false_path -from [get_clocks -of_objects [get_pins cpu_ep/cpu_subsys_EP0/xdma_0/inst/pcie4c_ip_i/inst/cpu_subsys_xdma_0_0_pcie4c_ip_gt_top_i/diablo_gt.diablo_gt_phy_wrapper/phy_clk_i/bufg_gt_userclk/O]] -to [get_clocks -of_objects [get_pins clk_ep0/inst/mmcme4_adv_inst/CLKOUT0]]
set_false_path -from [get_clocks -of_objects [get_pins cpu_ep/cpu_subsys_EP0/xdma_1/inst/pcie4c_ip_i/inst/cpu_subsys_xdma_1_0_pcie4c_ip_gt_top_i/diablo_gt.diablo_gt_phy_wrapper/phy_clk_i/bufg_gt_userclk/O]] -to [get_clocks -of_objects [get_pins clk_ep0/inst/mmcme4_adv_inst/CLKOUT0]]



set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks {clk_pl_0}] \
							   -group [get_clocks -include_generated_clocks {clk_pl_1}] \
							   -group [get_clocks -include_generated_clocks {pci0_clk_clk_p}] \
							   -group [get_clocks -include_generated_clocks {pci1_clk_clk_p}] \
							   -group [get_clocks -include_generated_clocks {clk_out1_clk_sys}] \
							   -group [get_clocks -include_generated_clocks {clk_out2_clk_sys}] \
							   -group [get_clocks -include_generated_clocks {clk_out3_clk_sys}] \
							   -group [get_clocks -include_generated_clocks {clk_out4_clk_sys}] \
							   -group [get_clocks -include_generated_clocks {xdma_0_axi_aclk}] \
							   -group [get_clocks -include_generated_clocks {xdma_1_axi_aclk}] \
							   -group [get_clocks -include_generated_clocks {clk_out1_clk_dclk}] \
							   -group [get_clocks -include_generated_clocks {pcie_userclk0}] \
							   -group [get_clocks -include_generated_clocks {pcie_userclk1}] \
							   -group [get_clocks -include_generated_clocks {CLK_PL_DDR_P}]
					