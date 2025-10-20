
################################################################
# This is a generated script based on design: cpu_subsys
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2020.2
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   catch {common::send_gid_msg -ssname BD::TCL -id 2041 -severity "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source cpu_subsys_script.tcl

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xczu47dr-ffve1156-2LVI-i
}


# CHANGE DESIGN NAME HERE
variable design_name
set design_name cpu_subsys

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      common::send_gid_msg -ssname BD::TCL -id 2001 -severity "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_gid_msg -ssname BD::TCL -id 2002 -severity "INFO" "Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   common::send_gid_msg -ssname BD::TCL -id 2003 -severity "INFO" "Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   common::send_gid_msg -ssname BD::TCL -id 2004 -severity "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

common::send_gid_msg -ssname BD::TCL -id 2005 -severity "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   catch {common::send_gid_msg -ssname BD::TCL -id 2006 -severity "ERROR" $errMsg}
   return $nRet
}

set bCheckIPsPassed 1
##################################################################
# CHECK IPs
##################################################################
set bCheckIPs 1
if { $bCheckIPs == 1 } {
   set list_check_ips "\ 
xilinx.com:ip:axi_bram_ctrl:4.1\
xilinx.com:ip:axi_dma:7.1\
xilinx.com:ip:axi_uart16550:2.0\
xilinx.com:user:axilite_slave:2.0\
xilinx.com:ip:blk_mem_gen:8.4\
xilinx.com:ip:proc_sys_reset:5.0\
xilinx.com:ip:usp_rf_data_converter:2.4\
xilinx.com:ip:smartconnect:1.0\
xilinx.com:ip:system_management_wiz:1.3\
xilinx.com:ip:xlconcat:2.1\
xilinx.com:ip:xlconstant:1.1\
xilinx.com:ip:zynq_ultra_ps_e:3.3\
xilinx.com:ip:axi_dwidth_converter:2.1\
xilinx.com:ip:axi_register_slice:2.1\
xilinx.com:ip:ddr4:2.2\
xilinx.com:ip:util_vector_logic:2.0\
"

   set list_ips_missing ""
   common::send_gid_msg -ssname BD::TCL -id 2011 -severity "INFO" "Checking if the following IPs exist in the project's IP catalog: $list_check_ips ."

   foreach ip_vlnv $list_check_ips {
      set ip_obj [get_ipdefs -all $ip_vlnv]
      if { $ip_obj eq "" } {
         lappend list_ips_missing $ip_vlnv
      }
   }

   if { $list_ips_missing ne "" } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2012 -severity "ERROR" "The following IPs are not found in the IP Catalog:\n  $list_ips_missing\n\nResolution: Please add the repository containing the IP(s) to the project." }
      set bCheckIPsPassed 0
   }

}

if { $bCheckIPsPassed != 1 } {
  common::send_gid_msg -ssname BD::TCL -id 2023 -severity "WARNING" "Will not continue with creation of design due to the error(s) above."
  return 3
}

##################################################################
# DESIGN PROCs
##################################################################


# Hierarchical cell: mem
proc create_hier_cell_mem { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_mem() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:ddr4_rtl:1.0 DDR4

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 deepfifo_axi

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 mem_axi

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 s_axi


  # Create pins
  create_bd_pin -dir I -type clk M01_ACLK
  create_bd_pin -dir I -type rst M01_ARESETN
  create_bd_pin -dir I -type clk c0_sys_clk_n
  create_bd_pin -dir I -type clk c0_sys_clk_p
  create_bd_pin -dir O -type clk clk_out1
  create_bd_pin -dir O init_calib_complete
  create_bd_pin -dir O -type clk mem_clk
  create_bd_pin -dir O -type rst mem_rst
  create_bd_pin -dir I -type clk s_axi_aclk
  create_bd_pin -dir I -type rst s_axi_aresetn
  create_bd_pin -dir I -type rst sys_rst

  # Create instance: axi_bram_ctrl_0, and set properties
  set axi_bram_ctrl_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.1 axi_bram_ctrl_0 ]
  set_property -dict [ list \
   CONFIG.DATA_WIDTH {512} \
   CONFIG.SINGLE_PORT_BRAM {1} \
 ] $axi_bram_ctrl_0

  # Create instance: axi_dwidth_converter_0, and set properties
  set axi_dwidth_converter_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_dwidth_converter:2.1 axi_dwidth_converter_0 ]
  set_property -dict [ list \
   CONFIG.MI_DATA_WIDTH {256} \
   CONFIG.SI_DATA_WIDTH {512} \
 ] $axi_dwidth_converter_0

  # Create instance: axi_register_slice_0, and set properties
  set axi_register_slice_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_register_slice:2.1 axi_register_slice_0 ]

  # Create instance: blk_mem_gen_0, and set properties
  set blk_mem_gen_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.4 blk_mem_gen_0 ]
  set_property -dict [ list \
   CONFIG.Memory_Type {Single_Port_RAM} \
   CONFIG.PRIM_type_to_Implement {URAM} \
   CONFIG.Port_A_Write_Rate {50} \
   CONFIG.Port_B_Clock {0} \
   CONFIG.Port_B_Enable_Rate {0} \
   CONFIG.Port_B_Write_Rate {0} \
 ] $blk_mem_gen_0

  # Create instance: ddr4_0, and set properties
  set ddr4_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:ddr4:2.2 ddr4_0 ]
  set_property -dict [ list \
   CONFIG.ADDN_UI_CLKOUT1_FREQ_HZ {100} \
   CONFIG.C0.BANK_GROUP_WIDTH {1} \
   CONFIG.C0.DDR4_AxiAddressWidth {31} \
   CONFIG.C0.DDR4_AxiDataWidth {256} \
   CONFIG.C0.DDR4_CasLatency {18} \
   CONFIG.C0.DDR4_CasWriteLatency {16} \
   CONFIG.C0.DDR4_DataWidth {32} \
   CONFIG.C0.DDR4_InputClockPeriod {3332} \
   CONFIG.C0.DDR4_MemoryPart {MT40A512M16HA-075E} \
   CONFIG.C0.DDR4_MemoryType {Components} \
   CONFIG.C0.DDR4_TimePeriod {833} \
   CONFIG.System_Clock {Differential} \
 ] $ddr4_0

  # Create instance: ddrrst_inv, and set properties
  set ddrrst_inv [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 ddrrst_inv ]
  set_property -dict [ list \
   CONFIG.C_OPERATION {not} \
   CONFIG.C_SIZE {1} \
 ] $ddrrst_inv

  # Create instance: membar, and set properties
  set membar [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 membar ]
  set_property -dict [ list \
   CONFIG.ENABLE_ADVANCED_OPTIONS {1} \
   CONFIG.M00_HAS_DATA_FIFO {2} \
   CONFIG.M00_HAS_REGSLICE {4} \
   CONFIG.M01_HAS_DATA_FIFO {1} \
   CONFIG.M01_HAS_REGSLICE {4} \
   CONFIG.NUM_MI {2} \
   CONFIG.NUM_SI {3} \
   CONFIG.S00_HAS_DATA_FIFO {2} \
   CONFIG.S00_HAS_REGSLICE {4} \
   CONFIG.S01_HAS_DATA_FIFO {2} \
   CONFIG.S01_HAS_REGSLICE {4} \
   CONFIG.S02_HAS_DATA_FIFO {2} \
   CONFIG.S02_HAS_REGSLICE {4} \
   CONFIG.STRATEGY {2} \
   CONFIG.SYNCHRONIZATION_STAGES {8} \
   CONFIG.XBAR_DATA_WIDTH {512} \
 ] $membar

  # Create interface connections
  connect_bd_intf_net -intf_net Conn1 [get_bd_intf_pins mem_axi] [get_bd_intf_pins membar/S01_AXI]
  connect_bd_intf_net -intf_net Conn2 [get_bd_intf_pins deepfifo_axi] [get_bd_intf_pins membar/S02_AXI]
  connect_bd_intf_net -intf_net S00_AXI_0_1 [get_bd_intf_pins s_axi] [get_bd_intf_pins membar/S00_AXI]
  connect_bd_intf_net -intf_net axi_bram_ctrl_0_BRAM_PORTA [get_bd_intf_pins axi_bram_ctrl_0/BRAM_PORTA] [get_bd_intf_pins blk_mem_gen_0/BRAM_PORTA]
  connect_bd_intf_net -intf_net axi_dwidth_converter_0_M_AXI [get_bd_intf_pins axi_dwidth_converter_0/M_AXI] [get_bd_intf_pins axi_register_slice_0/S_AXI]
  connect_bd_intf_net -intf_net axi_register_slice_0_M_AXI [get_bd_intf_pins axi_register_slice_0/M_AXI] [get_bd_intf_pins ddr4_0/C0_DDR4_S_AXI]
  connect_bd_intf_net -intf_net ddr4_0_C0_DDR4 [get_bd_intf_pins DDR4] [get_bd_intf_pins ddr4_0/C0_DDR4]
  connect_bd_intf_net -intf_net membar_M00_AXI [get_bd_intf_pins axi_dwidth_converter_0/S_AXI] [get_bd_intf_pins membar/M00_AXI]
  connect_bd_intf_net -intf_net membar_M01_AXI [get_bd_intf_pins axi_bram_ctrl_0/S_AXI] [get_bd_intf_pins membar/M01_AXI]

  # Create port connections
  connect_bd_net -net M01_ACLK_1 [get_bd_pins M01_ACLK] [get_bd_pins axi_bram_ctrl_0/s_axi_aclk] [get_bd_pins membar/ACLK] [get_bd_pins membar/M01_ACLK] [get_bd_pins membar/S01_ACLK] [get_bd_pins membar/S02_ACLK]
  connect_bd_net -net M01_ARESETN_1 [get_bd_pins M01_ARESETN] [get_bd_pins axi_bram_ctrl_0/s_axi_aresetn] [get_bd_pins membar/ARESETN] [get_bd_pins membar/M01_ARESETN] [get_bd_pins membar/S01_ARESETN] [get_bd_pins membar/S02_ARESETN]
  connect_bd_net -net S00_ACLK_1 [get_bd_pins s_axi_aclk] [get_bd_pins membar/S00_ACLK]
  connect_bd_net -net c0_sys_clk_n_1 [get_bd_pins c0_sys_clk_n] [get_bd_pins ddr4_0/c0_sys_clk_n]
  connect_bd_net -net c0_sys_clk_p_1 [get_bd_pins c0_sys_clk_p] [get_bd_pins ddr4_0/c0_sys_clk_p]
  connect_bd_net -net clk_inv_Res [get_bd_pins axi_dwidth_converter_0/s_axi_aresetn] [get_bd_pins axi_register_slice_0/aresetn] [get_bd_pins ddr4_0/c0_ddr4_aresetn] [get_bd_pins ddrrst_inv/Res] [get_bd_pins membar/M00_ARESETN]
  connect_bd_net -net ddr4_0_addn_ui_clkout1 [get_bd_pins clk_out1] [get_bd_pins ddr4_0/addn_ui_clkout1]
  connect_bd_net -net ddr4_0_c0_ddr4_ui_clk [get_bd_pins mem_clk] [get_bd_pins axi_dwidth_converter_0/s_axi_aclk] [get_bd_pins axi_register_slice_0/aclk] [get_bd_pins ddr4_0/c0_ddr4_ui_clk] [get_bd_pins membar/M00_ACLK]
  connect_bd_net -net ddr4_0_c0_ddr4_ui_clk_sync_rst [get_bd_pins mem_rst] [get_bd_pins ddr4_0/c0_ddr4_ui_clk_sync_rst] [get_bd_pins ddrrst_inv/Op1]
  connect_bd_net -net ddr4_0_c0_init_calib_complete [get_bd_pins init_calib_complete] [get_bd_pins ddr4_0/c0_init_calib_complete]
  connect_bd_net -net s_axi_aresetn_1 [get_bd_pins s_axi_aresetn] [get_bd_pins membar/S00_ARESETN]
  connect_bd_net -net sys_rst_1 [get_bd_pins sys_rst] [get_bd_pins ddr4_0/sys_rst]

  # Restore current instance
  current_bd_instance $oldCurInst
}


# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder
  variable design_name

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set AUXRAM [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:bram_rtl:1.0 AUXRAM ]
  set_property -dict [ list \
   CONFIG.MASTER_TYPE {BRAM_CTRL} \
   CONFIG.MEM_SIZE {65536} \
   CONFIG.MEM_WIDTH {128} \
   CONFIG.READ_WRITE_MODE {READ_WRITE} \
   ] $AUXRAM

  set DDR4 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:ddr4_rtl:1.0 DDR4 ]

  set M_DMA_AXIS [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 M_DMA_AXIS ]

  set PLUART [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:uart_rtl:1.0 PLUART ]

  set SPI0 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:spi_rtl:1.0 SPI0 ]

  set S_AXI_HPC1 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI_HPC1 ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {49} \
   CONFIG.ARUSER_WIDTH {1} \
   CONFIG.AWUSER_WIDTH {1} \
   CONFIG.BUSER_WIDTH {0} \
   CONFIG.DATA_WIDTH {128} \
   CONFIG.HAS_BRESP {1} \
   CONFIG.HAS_BURST {1} \
   CONFIG.HAS_CACHE {1} \
   CONFIG.HAS_LOCK {1} \
   CONFIG.HAS_PROT {1} \
   CONFIG.HAS_QOS {1} \
   CONFIG.HAS_REGION {0} \
   CONFIG.HAS_RRESP {1} \
   CONFIG.HAS_WSTRB {1} \
   CONFIG.ID_WIDTH {6} \
   CONFIG.MAX_BURST_LENGTH {256} \
   CONFIG.NUM_READ_OUTSTANDING {16} \
   CONFIG.NUM_READ_THREADS {1} \
   CONFIG.NUM_WRITE_OUTSTANDING {16} \
   CONFIG.NUM_WRITE_THREADS {1} \
   CONFIG.PROTOCOL {AXI4} \
   CONFIG.READ_WRITE_MODE {READ_WRITE} \
   CONFIG.RUSER_BITS_PER_BYTE {0} \
   CONFIG.RUSER_WIDTH {0} \
   CONFIG.SUPPORTS_NARROW_BURST {1} \
   CONFIG.WUSER_BITS_PER_BYTE {0} \
   CONFIG.WUSER_WIDTH {0} \
   ] $S_AXI_HPC1

  set S_DMA_AXIS [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 S_DMA_AXIS ]
  set_property -dict [ list \
   CONFIG.HAS_TKEEP {1} \
   CONFIG.HAS_TLAST {1} \
   CONFIG.HAS_TREADY {1} \
   CONFIG.HAS_TSTRB {0} \
   CONFIG.LAYERED_METADATA {undef} \
   CONFIG.TDATA_NUM_BYTES {16} \
   CONFIG.TDEST_WIDTH {0} \
   CONFIG.TID_WIDTH {0} \
   CONFIG.TUSER_WIDTH {0} \
   ] $S_DMA_AXIS

  set adc0_clk [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 adc0_clk ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {300000000.0} \
   ] $adc0_clk

  set adc0_dsa_rts [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:rfdc_dsa_rts_pins_rtl:1.0 adc0_dsa_rts ]

  set adc0_rts [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:rfdc_rts_pins_rtl:1.0 adc0_rts ]

  set adc1_clk [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 adc1_clk ]

  set adc1_dsa_rts [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:rfdc_dsa_rts_pins_rtl:1.0 adc1_dsa_rts ]

  set adc1_rts [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:rfdc_rts_pins_rtl:1.0 adc1_rts ]

  set app_lite [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 app_lite ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {40} \
   CONFIG.DATA_WIDTH {32} \
   CONFIG.NUM_READ_OUTSTANDING {2} \
   CONFIG.NUM_WRITE_OUTSTANDING {2} \
   CONFIG.PROTOCOL {AXI4LITE} \
   ] $app_lite

  set dac0_clk [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 dac0_clk ]

  set deepfifo_axi [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 deepfifo_axi ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {36} \
   CONFIG.ARUSER_WIDTH {0} \
   CONFIG.AWUSER_WIDTH {0} \
   CONFIG.BUSER_WIDTH {0} \
   CONFIG.DATA_WIDTH {512} \
   CONFIG.HAS_BRESP {1} \
   CONFIG.HAS_BURST {1} \
   CONFIG.HAS_CACHE {1} \
   CONFIG.HAS_LOCK {1} \
   CONFIG.HAS_PROT {1} \
   CONFIG.HAS_QOS {1} \
   CONFIG.HAS_REGION {1} \
   CONFIG.HAS_RRESP {1} \
   CONFIG.HAS_WSTRB {1} \
   CONFIG.ID_WIDTH {0} \
   CONFIG.MAX_BURST_LENGTH {256} \
   CONFIG.NUM_READ_OUTSTANDING {2} \
   CONFIG.NUM_READ_THREADS {1} \
   CONFIG.NUM_WRITE_OUTSTANDING {2} \
   CONFIG.NUM_WRITE_THREADS {1} \
   CONFIG.PROTOCOL {AXI4} \
   CONFIG.READ_WRITE_MODE {READ_WRITE} \
   CONFIG.RUSER_BITS_PER_BYTE {0} \
   CONFIG.RUSER_WIDTH {0} \
   CONFIG.SUPPORTS_NARROW_BURST {1} \
   CONFIG.WUSER_BITS_PER_BYTE {0} \
   CONFIG.WUSER_WIDTH {0} \
   ] $deepfifo_axi
  set_property APERTURES {{0x0 64G}} [get_bd_intf_ports deepfifo_axi]

  set m00_axis [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 m00_axis ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {150000000} \
   ] $m00_axis

  set m01_axis [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 m01_axis ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {150000000} \
   ] $m01_axis

  set m02_axis [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 m02_axis ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {150000000} \
   ] $m02_axis

  set m03_axis [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 m03_axis ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {150000000} \
   ] $m03_axis

  set m10_axis [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 m10_axis ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {150000000} \
   ] $m10_axis

  set m11_axis [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 m11_axis ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {150000000} \
   ] $m11_axis

  set m12_axis [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 m12_axis ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {150000000} \
   ] $m12_axis

  set m13_axis [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 m13_axis ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {150000000} \
   ] $m13_axis

  set mem_axi [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 mem_axi ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {36} \
   CONFIG.ARUSER_WIDTH {0} \
   CONFIG.AWUSER_WIDTH {0} \
   CONFIG.BUSER_WIDTH {0} \
   CONFIG.DATA_WIDTH {512} \
   CONFIG.HAS_BRESP {1} \
   CONFIG.HAS_BURST {1} \
   CONFIG.HAS_CACHE {1} \
   CONFIG.HAS_LOCK {1} \
   CONFIG.HAS_PROT {1} \
   CONFIG.HAS_QOS {1} \
   CONFIG.HAS_REGION {0} \
   CONFIG.HAS_RRESP {1} \
   CONFIG.HAS_WSTRB {1} \
   CONFIG.ID_WIDTH {0} \
   CONFIG.MAX_BURST_LENGTH {256} \
   CONFIG.NUM_READ_OUTSTANDING {2} \
   CONFIG.NUM_READ_THREADS {1} \
   CONFIG.NUM_WRITE_OUTSTANDING {2} \
   CONFIG.NUM_WRITE_THREADS {1} \
   CONFIG.PROTOCOL {AXI4} \
   CONFIG.READ_WRITE_MODE {READ_WRITE} \
   CONFIG.RUSER_BITS_PER_BYTE {0} \
   CONFIG.RUSER_WIDTH {0} \
   CONFIG.SUPPORTS_NARROW_BURST {1} \
   CONFIG.WUSER_BITS_PER_BYTE {0} \
   CONFIG.WUSER_WIDTH {0} \
   ] $mem_axi

  set pci0_clk [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 pci0_clk ]

  set pci1_clk [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 pci1_clk ]

  set pcie0_exp [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:pcie_7x_mgt_rtl:1.0 pcie0_exp ]

  set pcie1_exp [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:pcie_7x_mgt_rtl:1.0 pcie1_exp ]

  set s00_axis [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 s00_axis ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {150000000} \
   CONFIG.HAS_TKEEP {0} \
   CONFIG.HAS_TLAST {0} \
   CONFIG.HAS_TREADY {1} \
   CONFIG.HAS_TSTRB {0} \
   CONFIG.LAYERED_METADATA {undef} \
   CONFIG.TDATA_NUM_BYTES {32} \
   CONFIG.TDEST_WIDTH {0} \
   CONFIG.TID_WIDTH {0} \
   CONFIG.TUSER_WIDTH {0} \
   ] $s00_axis

  set s02_axis [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 s02_axis ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {150000000} \
   CONFIG.HAS_TKEEP {0} \
   CONFIG.HAS_TLAST {0} \
   CONFIG.HAS_TREADY {1} \
   CONFIG.HAS_TSTRB {0} \
   CONFIG.LAYERED_METADATA {undef} \
   CONFIG.TDATA_NUM_BYTES {32} \
   CONFIG.TDEST_WIDTH {0} \
   CONFIG.TID_WIDTH {0} \
   CONFIG.TUSER_WIDTH {0} \
   ] $s02_axis

  set s10_axis [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 s10_axis ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {150000000} \
   CONFIG.HAS_TKEEP {0} \
   CONFIG.HAS_TLAST {0} \
   CONFIG.HAS_TREADY {1} \
   CONFIG.HAS_TSTRB {0} \
   CONFIG.LAYERED_METADATA {undef} \
   CONFIG.TDATA_NUM_BYTES {32} \
   CONFIG.TDEST_WIDTH {0} \
   CONFIG.TID_WIDTH {0} \
   CONFIG.TUSER_WIDTH {0} \
   ] $s10_axis

  set s12_axis [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 s12_axis ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {150000000} \
   CONFIG.HAS_TKEEP {0} \
   CONFIG.HAS_TLAST {0} \
   CONFIG.HAS_TREADY {1} \
   CONFIG.HAS_TSTRB {0} \
   CONFIG.LAYERED_METADATA {undef} \
   CONFIG.TDATA_NUM_BYTES {32} \
   CONFIG.TDEST_WIDTH {0} \
   CONFIG.TID_WIDTH {0} \
   CONFIG.TUSER_WIDTH {0} \
   ] $s12_axis

  set sysref_in [ create_bd_intf_port -mode Slave -vlnv xilinx.com:display_usp_rf_data_converter:diff_pins_rtl:1.0 sysref_in ]

  set vin0_01 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_analog_io_rtl:1.0 vin0_01 ]

  set vin0_23 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_analog_io_rtl:1.0 vin0_23 ]

  set vin1_01 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_analog_io_rtl:1.0 vin1_01 ]

  set vin1_23 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_analog_io_rtl:1.0 vin1_23 ]

  set vout00 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:diff_analog_io_rtl:1.0 vout00 ]

  set vout02 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:diff_analog_io_rtl:1.0 vout02 ]

  set vout10 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:diff_analog_io_rtl:1.0 vout10 ]

  set vout12 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:diff_analog_io_rtl:1.0 vout12 ]


  # Create ports
  set RST_NVME_0_N [ create_bd_port -dir O -from 0 -to 0 -type rst RST_NVME_0_N ]
  set RST_NVME_1_N [ create_bd_port -dir O -from 0 -to 0 -type rst RST_NVME_1_N ]
  set adc_clk [ create_bd_port -dir I -type clk -freq_hz 150000000 adc_clk ]
  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {m00_axis:m01_axis:m02_axis:m03_axis:m10_axis:m11_axis:m12_axis:m13_axis} \
   CONFIG.ASSOCIATED_RESET {adc_rstn} \
 ] $adc_clk
  set adc_rstn [ create_bd_port -dir I -type rst adc_rstn ]
  set app_param0 [ create_bd_port -dir O -from 31 -to 0 app_param0 ]
  set app_param1 [ create_bd_port -dir O -from 31 -to 0 app_param1 ]
  set app_param2 [ create_bd_port -dir O -from 31 -to 0 app_param2 ]
  set app_param3 [ create_bd_port -dir O -from 31 -to 0 app_param3 ]
  set app_param4 [ create_bd_port -dir O -from 31 -to 0 app_param4 ]
  set app_param5 [ create_bd_port -dir O -from 31 -to 0 app_param5 ]
  set app_param6 [ create_bd_port -dir O -from 31 -to 0 app_param6 ]
  set app_param7 [ create_bd_port -dir O -from 31 -to 0 app_param7 ]
  set app_status0 [ create_bd_port -dir I -from 31 -to 0 app_status0 ]
  set app_status1 [ create_bd_port -dir I -from 31 -to 0 app_status1 ]
  set app_status2 [ create_bd_port -dir I -from 31 -to 0 app_status2 ]
  set app_status3 [ create_bd_port -dir I -from 31 -to 0 app_status3 ]
  set app_status4 [ create_bd_port -dir I -from 31 -to 0 app_status4 ]
  set app_status5 [ create_bd_port -dir I -from 31 -to 0 app_status5 ]
  set app_status6 [ create_bd_port -dir I -from 31 -to 0 app_status6 ]
  set app_status7 [ create_bd_port -dir I -from 31 -to 0 app_status7 ]
  set axcache [ create_bd_port -dir I -from 3 -to 0 axcache ]
  set axprot [ create_bd_port -dir I -from 2 -to 0 axprot ]
  set bram_addr [ create_bd_port -dir O -from 23 -to 0 bram_addr ]
  set bram_clk [ create_bd_port -dir O -type clk bram_clk ]
  set_property -dict [ list \
   CONFIG.ASSOCIATED_RESET {bram_rst} \
 ] $bram_clk
  set bram_en [ create_bd_port -dir O bram_en ]
  set bram_rddata [ create_bd_port -dir I -from 31 -to 0 bram_rddata ]
  set bram_rst [ create_bd_port -dir O -type rst bram_rst ]
  set bram_we [ create_bd_port -dir O -from 3 -to 0 bram_we ]
  set bram_wrdata [ create_bd_port -dir O -from 31 -to 0 bram_wrdata ]
  set c0_sys_clk_n [ create_bd_port -dir I -type clk -freq_hz 300000000 c0_sys_clk_n ]
  set c0_sys_clk_p [ create_bd_port -dir I -type clk -freq_hz 300000000 c0_sys_clk_p ]
  set_property -dict [ list \
   CONFIG.ASSOCIATED_RESET {ddr_rst} \
 ] $c0_sys_clk_p
  set cfg_ltssm_state0 [ create_bd_port -dir O -from 5 -to 0 cfg_ltssm_state0 ]
  set cfg_ltssm_state1 [ create_bd_port -dir O -from 5 -to 0 cfg_ltssm_state1 ]
  set clk_adc0 [ create_bd_port -dir O -type clk clk_adc0 ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {156250000} \
 ] $clk_adc0
  set clk_adc1 [ create_bd_port -dir O -type clk clk_adc1 ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {156250000} \
 ] $clk_adc1
  set clk_dac0 [ create_bd_port -dir O -type clk clk_dac0 ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {156250000} \
 ] $clk_dac0
  set clk_dac1 [ create_bd_port -dir O -type clk clk_dac1 ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {156250000} \
 ] $clk_dac1
  set clk_out100 [ create_bd_port -dir O -type clk clk_out100 ]
  set dac_clk [ create_bd_port -dir I -type clk -freq_hz 150000000 dac_clk ]
  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {s00_axis:s02_axis:s10_axis:s12_axis} \
   CONFIG.ASSOCIATED_RESET {dac_rstn} \
 ] $dac_clk
  set dac_rstn [ create_bd_port -dir I -type rst dac_rstn ]
  set ddr_rst [ create_bd_port -dir I -type rst ddr_rst ]
  set_property -dict [ list \
   CONFIG.POLARITY {ACTIVE_HIGH} \
 ] $ddr_rst
  set init_calib_complete [ create_bd_port -dir O init_calib_complete ]
  set mm2s_resetn_out [ create_bd_port -dir O -type rst mm2s_resetn_out ]
  set pcie_userclk0 [ create_bd_port -dir O -type clk pcie_userclk0 ]
  set pcie_userclk1 [ create_bd_port -dir O -type clk pcie_userclk1 ]
  set pl_clk0 [ create_bd_port -dir O -type clk pl_clk0 ]
  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {app_lite} \
 ] $pl_clk0
  set pl_clk1 [ create_bd_port -dir O -type clk pl_clk1 ]
  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {M_DMA_AXIS:S_DMA_AXIS:mem_axi:S_AXI_HPC1:deepfifo_axi} \
   CONFIG.ASSOCIATED_RESET {mm2s_resetn_out:s2mm_resetn_out:pl_resetn10:pl_resetn1} \
 ] $pl_clk1
  set pl_resetn0 [ create_bd_port -dir O -from 0 -to 0 -type rst pl_resetn0 ]
  set pl_resetn1 [ create_bd_port -dir O -from 0 -to 0 -type rst pl_resetn1 ]
  set s2mm_resetn_out [ create_bd_port -dir O -type rst s2mm_resetn_out ]
  set user_lnk_up0 [ create_bd_port -dir O user_lnk_up0 ]
  set user_lnk_up1 [ create_bd_port -dir O user_lnk_up1 ]
  set user_sysref_adc [ create_bd_port -dir I user_sysref_adc ]
  set user_sysref_dac [ create_bd_port -dir I user_sysref_dac ]
  set useruart0_rx [ create_bd_port -dir I useruart0_rx ]
  set useruart0_tx [ create_bd_port -dir O useruart0_tx ]
  set useruart1_rx [ create_bd_port -dir I useruart1_rx ]
  set useruart1_tx [ create_bd_port -dir O useruart1_tx ]

  # Create instance: axi_bram, and set properties
  set axi_bram [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.1 axi_bram ]
  set_property -dict [ list \
   CONFIG.PROTOCOL {AXI4LITE} \
   CONFIG.READ_LATENCY {4} \
   CONFIG.SINGLE_PORT_BRAM {1} \
 ] $axi_bram

  # Create instance: axi_dma_0, and set properties
  set axi_dma_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_dma:7.1 axi_dma_0 ]
  set_property -dict [ list \
   CONFIG.c_addr_width {64} \
   CONFIG.c_include_mm2s {1} \
   CONFIG.c_include_s2mm {1} \
   CONFIG.c_m_axi_mm2s_data_width {128} \
   CONFIG.c_m_axi_s2mm_data_width {128} \
   CONFIG.c_m_axis_mm2s_tdata_width {128} \
   CONFIG.c_mm2s_burst_size {256} \
   CONFIG.c_s2mm_burst_size {256} \
   CONFIG.c_s_axis_s2mm_tdata_width {128} \
   CONFIG.c_sg_include_stscntrl_strm {0} \
   CONFIG.c_sg_length_width {26} \
   CONFIG.c_single_interface {1} \
 ] $axi_dma_0

  # Create instance: axi_uart16550_0, and set properties
  set axi_uart16550_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_uart16550:2.0 axi_uart16550_0 ]

  # Create instance: axi_uart16550_1, and set properties
  set axi_uart16550_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_uart16550:2.0 axi_uart16550_1 ]

  # Create instance: axilite_dma, and set properties
  set axilite_dma [ create_bd_cell -type ip -vlnv xilinx.com:user:axilite_slave:2.0 axilite_dma ]

  # Create instance: blkmem0, and set properties
  set blkmem0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.4 blkmem0 ]
  set_property -dict [ list \
   CONFIG.Memory_Type {True_Dual_Port_RAM} \
   CONFIG.PRIM_type_to_Implement {URAM} \
   CONFIG.Port_B_Clock {100} \
   CONFIG.Port_B_Enable_Rate {100} \
   CONFIG.Port_B_Write_Rate {50} \
   CONFIG.Use_RSTB_Pin {true} \
 ] $blkmem0

  # Create instance: bram0, and set properties
  set bram0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.1 bram0 ]
  set_property -dict [ list \
   CONFIG.DATA_WIDTH {128} \
   CONFIG.SINGLE_PORT_BRAM {1} \
 ] $bram0

  # Create instance: fpm0inter, and set properties
  set fpm0inter [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 fpm0inter ]
  set_property -dict [ list \
   CONFIG.NUM_MI {3} \
 ] $fpm0inter

  # Create instance: hpm_inter, and set properties
  set hpm_inter [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 hpm_inter ]
  set_property -dict [ list \
   CONFIG.NUM_MI {9} \
   CONFIG.NUM_SI {1} \
 ] $hpm_inter

  # Create instance: mem
  create_hier_cell_mem [current_bd_instance .] mem

  # Create instance: proc_sys_reset_0, and set properties
  set proc_sys_reset_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 proc_sys_reset_0 ]

  # Create instance: proc_sys_reset_data, and set properties
  set proc_sys_reset_data [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 proc_sys_reset_data ]

  # Create instance: rfdc4x4, and set properties
  set rfdc4x4 [ create_bd_cell -type ip -vlnv xilinx.com:ip:usp_rf_data_converter:2.4 rfdc4x4 ]
  set_property -dict [ list \
   CONFIG.ADC0_Clock_Dist {0} \
   CONFIG.ADC0_Clock_Source {0} \
   CONFIG.ADC0_Multi_Tile_Sync {true} \
   CONFIG.ADC0_Outclk_Freq {156.250} \
   CONFIG.ADC0_PLL_Enable {true} \
   CONFIG.ADC0_Refclk_Freq {400.000} \
   CONFIG.ADC0_Sampling_Rate {5} \
   CONFIG.ADC1_Clock_Dist {1} \
   CONFIG.ADC1_Clock_Source {1} \
   CONFIG.ADC1_Multi_Tile_Sync {true} \
   CONFIG.ADC1_Outclk_Freq {156.250} \
   CONFIG.ADC1_PLL_Enable {true} \
   CONFIG.ADC1_Refclk_Freq {400.000} \
   CONFIG.ADC1_Sampling_Rate {5} \
   CONFIG.ADC2_Clock_Source {1} \
   CONFIG.ADC2_Multi_Tile_Sync {true} \
   CONFIG.ADC2_Outclk_Freq {156.250} \
   CONFIG.ADC2_PLL_Enable {true} \
   CONFIG.ADC2_Refclk_Freq {400.000} \
   CONFIG.ADC2_Sampling_Rate {5} \
   CONFIG.ADC3_Clock_Source {1} \
   CONFIG.ADC3_Multi_Tile_Sync {true} \
   CONFIG.ADC3_Outclk_Freq {156.250} \
   CONFIG.ADC3_PLL_Enable {true} \
   CONFIG.ADC3_Refclk_Freq {400.000} \
   CONFIG.ADC3_Sampling_Rate {5} \
   CONFIG.ADC_CalOpt_Mode00 {2} \
   CONFIG.ADC_CalOpt_Mode02 {2} \
   CONFIG.ADC_CalOpt_Mode10 {2} \
   CONFIG.ADC_CalOpt_Mode12 {2} \
   CONFIG.ADC_CalOpt_Mode20 {2} \
   CONFIG.ADC_CalOpt_Mode22 {2} \
   CONFIG.ADC_CalOpt_Mode30 {2} \
   CONFIG.ADC_CalOpt_Mode32 {2} \
   CONFIG.ADC_Coarse_Mixer_Freq00 {1} \
   CONFIG.ADC_Coarse_Mixer_Freq02 {1} \
   CONFIG.ADC_Coarse_Mixer_Freq10 {1} \
   CONFIG.ADC_Coarse_Mixer_Freq12 {1} \
   CONFIG.ADC_Coarse_Mixer_Freq20 {1} \
   CONFIG.ADC_Coarse_Mixer_Freq22 {1} \
   CONFIG.ADC_Coarse_Mixer_Freq30 {1} \
   CONFIG.ADC_Coarse_Mixer_Freq32 {1} \
   CONFIG.ADC_DSA_RTS {true} \
   CONFIG.ADC_Data_Type00 {1} \
   CONFIG.ADC_Data_Type02 {1} \
   CONFIG.ADC_Data_Type10 {1} \
   CONFIG.ADC_Data_Type12 {1} \
   CONFIG.ADC_Data_Type20 {1} \
   CONFIG.ADC_Data_Type22 {1} \
   CONFIG.ADC_Data_Type30 {1} \
   CONFIG.ADC_Data_Type32 {1} \
   CONFIG.ADC_Data_Width00 {8} \
   CONFIG.ADC_Data_Width02 {8} \
   CONFIG.ADC_Data_Width10 {8} \
   CONFIG.ADC_Data_Width12 {8} \
   CONFIG.ADC_Data_Width20 {8} \
   CONFIG.ADC_Data_Width22 {8} \
   CONFIG.ADC_Data_Width30 {8} \
   CONFIG.ADC_Data_Width32 {8} \
   CONFIG.ADC_Decimation_Mode00 {4} \
   CONFIG.ADC_Decimation_Mode02 {4} \
   CONFIG.ADC_Decimation_Mode10 {4} \
   CONFIG.ADC_Decimation_Mode12 {4} \
   CONFIG.ADC_Decimation_Mode20 {4} \
   CONFIG.ADC_Decimation_Mode22 {4} \
   CONFIG.ADC_Decimation_Mode30 {4} \
   CONFIG.ADC_Decimation_Mode32 {4} \
   CONFIG.ADC_Mixer_Mode00 {0} \
   CONFIG.ADC_Mixer_Mode02 {0} \
   CONFIG.ADC_Mixer_Mode10 {0} \
   CONFIG.ADC_Mixer_Mode12 {0} \
   CONFIG.ADC_Mixer_Mode20 {0} \
   CONFIG.ADC_Mixer_Mode22 {0} \
   CONFIG.ADC_Mixer_Mode30 {0} \
   CONFIG.ADC_Mixer_Mode32 {0} \
   CONFIG.ADC_Mixer_Type02 {1} \
   CONFIG.ADC_Mixer_Type03 {1} \
   CONFIG.ADC_Mixer_Type10 {1} \
   CONFIG.ADC_Mixer_Type11 {1} \
   CONFIG.ADC_Mixer_Type12 {1} \
   CONFIG.ADC_Mixer_Type13 {1} \
   CONFIG.ADC_Mixer_Type20 {1} \
   CONFIG.ADC_Mixer_Type21 {1} \
   CONFIG.ADC_Mixer_Type22 {1} \
   CONFIG.ADC_Mixer_Type23 {1} \
   CONFIG.ADC_Mixer_Type30 {1} \
   CONFIG.ADC_Mixer_Type31 {1} \
   CONFIG.ADC_Mixer_Type32 {1} \
   CONFIG.ADC_Mixer_Type33 {1} \
   CONFIG.ADC_Nyquist00 {1} \
   CONFIG.ADC_Nyquist02 {1} \
   CONFIG.ADC_Nyquist10 {1} \
   CONFIG.ADC_Nyquist12 {1} \
   CONFIG.ADC_Nyquist20 {1} \
   CONFIG.ADC_Nyquist22 {1} \
   CONFIG.ADC_Nyquist30 {1} \
   CONFIG.ADC_Nyquist32 {1} \
   CONFIG.ADC_OBS02 {false} \
   CONFIG.ADC_OBS12 {false} \
   CONFIG.ADC_OBS22 {false} \
   CONFIG.ADC_OBS32 {false} \
   CONFIG.ADC_RTS {true} \
   CONFIG.ADC_Slice02_Enable {true} \
   CONFIG.ADC_Slice10_Enable {true} \
   CONFIG.ADC_Slice12_Enable {true} \
   CONFIG.ADC_Slice20_Enable {true} \
   CONFIG.ADC_Slice22_Enable {true} \
   CONFIG.ADC_Slice30_Enable {true} \
   CONFIG.ADC_Slice32_Enable {true} \
   CONFIG.Axiclk_Freq {100} \
   CONFIG.DAC0_Clock_Dist {1} \
   CONFIG.DAC0_Multi_Tile_Sync {true} \
   CONFIG.DAC0_Outclk_Freq {156.250} \
   CONFIG.DAC0_PLL_Enable {true} \
   CONFIG.DAC0_Refclk_Freq {400.000} \
   CONFIG.DAC0_Sampling_Rate {5} \
   CONFIG.DAC1_Clock_Source {4} \
   CONFIG.DAC1_Multi_Tile_Sync {true} \
   CONFIG.DAC1_Outclk_Freq {156.250} \
   CONFIG.DAC1_PLL_Enable {true} \
   CONFIG.DAC1_Refclk_Freq {400.000} \
   CONFIG.DAC1_Sampling_Rate {5} \
   CONFIG.DAC_Coarse_Mixer_Freq00 {2} \
   CONFIG.DAC_Coarse_Mixer_Freq02 {2} \
   CONFIG.DAC_Coarse_Mixer_Freq10 {2} \
   CONFIG.DAC_Coarse_Mixer_Freq12 {2} \
   CONFIG.DAC_Interpolation_Mode00 {4} \
   CONFIG.DAC_Interpolation_Mode02 {4} \
   CONFIG.DAC_Interpolation_Mode10 {4} \
   CONFIG.DAC_Interpolation_Mode12 {4} \
   CONFIG.DAC_Mixer_Mode00 {0} \
   CONFIG.DAC_Mixer_Mode02 {0} \
   CONFIG.DAC_Mixer_Mode10 {0} \
   CONFIG.DAC_Mixer_Mode12 {0} \
   CONFIG.DAC_Mixer_Type00 {1} \
   CONFIG.DAC_Mixer_Type02 {1} \
   CONFIG.DAC_Mixer_Type10 {1} \
   CONFIG.DAC_Mixer_Type12 {1} \
   CONFIG.DAC_NCO_Freq00 {1.8} \
   CONFIG.DAC_NCO_Freq02 {1.8} \
   CONFIG.DAC_NCO_Freq10 {1.8} \
   CONFIG.DAC_NCO_Freq12 {1.8} \
   CONFIG.DAC_Nyquist00 {1} \
   CONFIG.DAC_Nyquist02 {1} \
   CONFIG.DAC_Nyquist10 {1} \
   CONFIG.DAC_Nyquist12 {1} \
   CONFIG.DAC_Slice00_Enable {true} \
   CONFIG.DAC_Slice02_Enable {true} \
   CONFIG.DAC_Slice10_Enable {true} \
   CONFIG.DAC_Slice12_Enable {true} \
   CONFIG.PL_Clock_Freq {156.25} \
   CONFIG.RF_Analyzer {1} \
 ] $rfdc4x4

  # Create instance: smartconnect_0, and set properties
  set smartconnect_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 smartconnect_0 ]
  set_property -dict [ list \
   CONFIG.NUM_CLKS {1} \
 ] $smartconnect_0

  # Create instance: sysmon, and set properties
  set sysmon [ create_bd_cell -type ip -vlnv xilinx.com:ip:system_management_wiz:1.3 sysmon ]

  # Create instance: xlconcat_0, and set properties
  set xlconcat_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 xlconcat_0 ]
  set_property -dict [ list \
   CONFIG.NUM_PORTS {8} \
 ] $xlconcat_0

  # Create instance: xlconcat_1, and set properties
  set xlconcat_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 xlconcat_1 ]
  set_property -dict [ list \
   CONFIG.NUM_PORTS {2} \
 ] $xlconcat_1

  # Create instance: xlconstant_0, and set properties
  set xlconstant_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_0 ]
  set_property -dict [ list \
   CONFIG.CONST_VAL {0} \
 ] $xlconstant_0

  # Create instance: zynq_ultra_ps_e_0, and set properties
  set zynq_ultra_ps_e_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:zynq_ultra_ps_e:3.3 zynq_ultra_ps_e_0 ]
  set_property -dict [ list \
   CONFIG.CAN0_BOARD_INTERFACE {custom} \
   CONFIG.CAN1_BOARD_INTERFACE {custom} \
   CONFIG.CSU_BOARD_INTERFACE {custom} \
   CONFIG.DP_BOARD_INTERFACE {custom} \
   CONFIG.GEM0_BOARD_INTERFACE {custom} \
   CONFIG.GEM1_BOARD_INTERFACE {custom} \
   CONFIG.GEM2_BOARD_INTERFACE {custom} \
   CONFIG.GEM3_BOARD_INTERFACE {custom} \
   CONFIG.GPIO_BOARD_INTERFACE {custom} \
   CONFIG.IIC0_BOARD_INTERFACE {custom} \
   CONFIG.IIC1_BOARD_INTERFACE {custom} \
   CONFIG.NAND_BOARD_INTERFACE {custom} \
   CONFIG.PCIE_BOARD_INTERFACE {custom} \
   CONFIG.PJTAG_BOARD_INTERFACE {custom} \
   CONFIG.PMU_BOARD_INTERFACE {custom} \
   CONFIG.PSU_BANK_0_IO_STANDARD {LVCMOS18} \
   CONFIG.PSU_BANK_1_IO_STANDARD {LVCMOS33} \
   CONFIG.PSU_BANK_2_IO_STANDARD {LVCMOS18} \
   CONFIG.PSU_BANK_3_IO_STANDARD {LVCMOS33} \
   CONFIG.PSU_DDR_RAM_HIGHADDR {0xFFFFFFFF} \
   CONFIG.PSU_DDR_RAM_HIGHADDR_OFFSET {0x800000000} \
   CONFIG.PSU_DDR_RAM_LOWADDR_OFFSET {0x80000000} \
   CONFIG.PSU_DYNAMIC_DDR_CONFIG_EN {0} \
   CONFIG.PSU_MIO_0_DIRECTION {out} \
   CONFIG.PSU_MIO_0_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_0_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_0_POLARITY {Default} \
   CONFIG.PSU_MIO_0_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_0_SLEW {fast} \
   CONFIG.PSU_MIO_10_DIRECTION {inout} \
   CONFIG.PSU_MIO_10_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_10_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_10_POLARITY {Default} \
   CONFIG.PSU_MIO_10_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_10_SLEW {fast} \
   CONFIG.PSU_MIO_11_DIRECTION {inout} \
   CONFIG.PSU_MIO_11_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_11_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_11_POLARITY {Default} \
   CONFIG.PSU_MIO_11_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_11_SLEW {fast} \
   CONFIG.PSU_MIO_12_DIRECTION {inout} \
   CONFIG.PSU_MIO_12_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_12_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_12_POLARITY {Default} \
   CONFIG.PSU_MIO_12_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_12_SLEW {fast} \
   CONFIG.PSU_MIO_13_DIRECTION {inout} \
   CONFIG.PSU_MIO_13_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_13_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_13_POLARITY {Default} \
   CONFIG.PSU_MIO_13_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_13_SLEW {fast} \
   CONFIG.PSU_MIO_14_DIRECTION {inout} \
   CONFIG.PSU_MIO_14_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_14_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_14_POLARITY {Default} \
   CONFIG.PSU_MIO_14_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_14_SLEW {fast} \
   CONFIG.PSU_MIO_15_DIRECTION {inout} \
   CONFIG.PSU_MIO_15_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_15_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_15_POLARITY {Default} \
   CONFIG.PSU_MIO_15_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_15_SLEW {fast} \
   CONFIG.PSU_MIO_16_DIRECTION {inout} \
   CONFIG.PSU_MIO_16_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_16_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_16_POLARITY {Default} \
   CONFIG.PSU_MIO_16_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_16_SLEW {fast} \
   CONFIG.PSU_MIO_17_DIRECTION {inout} \
   CONFIG.PSU_MIO_17_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_17_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_17_POLARITY {Default} \
   CONFIG.PSU_MIO_17_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_17_SLEW {fast} \
   CONFIG.PSU_MIO_18_DIRECTION {inout} \
   CONFIG.PSU_MIO_18_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_18_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_18_POLARITY {Default} \
   CONFIG.PSU_MIO_18_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_18_SLEW {fast} \
   CONFIG.PSU_MIO_19_DIRECTION {inout} \
   CONFIG.PSU_MIO_19_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_19_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_19_POLARITY {Default} \
   CONFIG.PSU_MIO_19_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_19_SLEW {fast} \
   CONFIG.PSU_MIO_1_DIRECTION {inout} \
   CONFIG.PSU_MIO_1_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_1_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_1_POLARITY {Default} \
   CONFIG.PSU_MIO_1_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_1_SLEW {fast} \
   CONFIG.PSU_MIO_20_DIRECTION {inout} \
   CONFIG.PSU_MIO_20_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_20_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_20_POLARITY {Default} \
   CONFIG.PSU_MIO_20_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_20_SLEW {fast} \
   CONFIG.PSU_MIO_21_DIRECTION {inout} \
   CONFIG.PSU_MIO_21_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_21_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_21_POLARITY {Default} \
   CONFIG.PSU_MIO_21_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_21_SLEW {fast} \
   CONFIG.PSU_MIO_22_DIRECTION {out} \
   CONFIG.PSU_MIO_22_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_22_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_22_POLARITY {Default} \
   CONFIG.PSU_MIO_22_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_22_SLEW {fast} \
   CONFIG.PSU_MIO_23_DIRECTION {out} \
   CONFIG.PSU_MIO_23_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_23_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_23_POLARITY {Default} \
   CONFIG.PSU_MIO_23_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_23_SLEW {fast} \
   CONFIG.PSU_MIO_24_DIRECTION {inout} \
   CONFIG.PSU_MIO_24_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_24_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_24_POLARITY {Default} \
   CONFIG.PSU_MIO_24_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_24_SLEW {fast} \
   CONFIG.PSU_MIO_25_DIRECTION {inout} \
   CONFIG.PSU_MIO_25_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_25_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_25_POLARITY {Default} \
   CONFIG.PSU_MIO_25_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_25_SLEW {fast} \
   CONFIG.PSU_MIO_26_DIRECTION {in} \
   CONFIG.PSU_MIO_26_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_26_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_26_POLARITY {Default} \
   CONFIG.PSU_MIO_26_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_26_SLEW {fast} \
   CONFIG.PSU_MIO_27_DIRECTION {out} \
   CONFIG.PSU_MIO_27_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_27_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_27_POLARITY {Default} \
   CONFIG.PSU_MIO_27_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_27_SLEW {fast} \
   CONFIG.PSU_MIO_28_DIRECTION {inout} \
   CONFIG.PSU_MIO_28_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_28_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_28_POLARITY {Default} \
   CONFIG.PSU_MIO_28_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_28_SLEW {fast} \
   CONFIG.PSU_MIO_29_DIRECTION {inout} \
   CONFIG.PSU_MIO_29_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_29_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_29_POLARITY {Default} \
   CONFIG.PSU_MIO_29_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_29_SLEW {fast} \
   CONFIG.PSU_MIO_2_DIRECTION {inout} \
   CONFIG.PSU_MIO_2_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_2_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_2_POLARITY {Default} \
   CONFIG.PSU_MIO_2_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_2_SLEW {fast} \
   CONFIG.PSU_MIO_30_DIRECTION {inout} \
   CONFIG.PSU_MIO_30_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_30_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_30_POLARITY {Default} \
   CONFIG.PSU_MIO_30_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_30_SLEW {fast} \
   CONFIG.PSU_MIO_31_DIRECTION {inout} \
   CONFIG.PSU_MIO_31_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_31_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_31_POLARITY {Default} \
   CONFIG.PSU_MIO_31_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_31_SLEW {fast} \
   CONFIG.PSU_MIO_32_DIRECTION {inout} \
   CONFIG.PSU_MIO_32_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_32_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_32_POLARITY {Default} \
   CONFIG.PSU_MIO_32_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_32_SLEW {fast} \
   CONFIG.PSU_MIO_33_DIRECTION {inout} \
   CONFIG.PSU_MIO_33_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_33_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_33_POLARITY {Default} \
   CONFIG.PSU_MIO_33_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_33_SLEW {fast} \
   CONFIG.PSU_MIO_34_DIRECTION {inout} \
   CONFIG.PSU_MIO_34_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_34_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_34_POLARITY {Default} \
   CONFIG.PSU_MIO_34_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_34_SLEW {fast} \
   CONFIG.PSU_MIO_35_DIRECTION {inout} \
   CONFIG.PSU_MIO_35_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_35_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_35_POLARITY {Default} \
   CONFIG.PSU_MIO_35_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_35_SLEW {fast} \
   CONFIG.PSU_MIO_36_DIRECTION {inout} \
   CONFIG.PSU_MIO_36_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_36_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_36_POLARITY {Default} \
   CONFIG.PSU_MIO_36_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_36_SLEW {fast} \
   CONFIG.PSU_MIO_37_DIRECTION {inout} \
   CONFIG.PSU_MIO_37_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_37_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_37_POLARITY {Default} \
   CONFIG.PSU_MIO_37_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_37_SLEW {fast} \
   CONFIG.PSU_MIO_38_DIRECTION {inout} \
   CONFIG.PSU_MIO_38_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_38_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_38_POLARITY {Default} \
   CONFIG.PSU_MIO_38_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_38_SLEW {fast} \
   CONFIG.PSU_MIO_39_DIRECTION {inout} \
   CONFIG.PSU_MIO_39_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_39_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_39_POLARITY {Default} \
   CONFIG.PSU_MIO_39_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_39_SLEW {fast} \
   CONFIG.PSU_MIO_3_DIRECTION {inout} \
   CONFIG.PSU_MIO_3_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_3_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_3_POLARITY {Default} \
   CONFIG.PSU_MIO_3_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_3_SLEW {fast} \
   CONFIG.PSU_MIO_40_DIRECTION {inout} \
   CONFIG.PSU_MIO_40_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_40_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_40_POLARITY {Default} \
   CONFIG.PSU_MIO_40_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_40_SLEW {fast} \
   CONFIG.PSU_MIO_41_DIRECTION {inout} \
   CONFIG.PSU_MIO_41_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_41_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_41_POLARITY {Default} \
   CONFIG.PSU_MIO_41_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_41_SLEW {fast} \
   CONFIG.PSU_MIO_42_DIRECTION {inout} \
   CONFIG.PSU_MIO_42_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_42_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_42_POLARITY {Default} \
   CONFIG.PSU_MIO_42_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_42_SLEW {fast} \
   CONFIG.PSU_MIO_43_DIRECTION {inout} \
   CONFIG.PSU_MIO_43_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_43_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_43_POLARITY {Default} \
   CONFIG.PSU_MIO_43_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_43_SLEW {fast} \
   CONFIG.PSU_MIO_44_DIRECTION {inout} \
   CONFIG.PSU_MIO_44_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_44_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_44_POLARITY {Default} \
   CONFIG.PSU_MIO_44_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_44_SLEW {fast} \
   CONFIG.PSU_MIO_45_DIRECTION {inout} \
   CONFIG.PSU_MIO_45_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_45_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_45_POLARITY {Default} \
   CONFIG.PSU_MIO_45_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_45_SLEW {fast} \
   CONFIG.PSU_MIO_46_DIRECTION {inout} \
   CONFIG.PSU_MIO_46_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_46_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_46_POLARITY {Default} \
   CONFIG.PSU_MIO_46_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_46_SLEW {fast} \
   CONFIG.PSU_MIO_47_DIRECTION {inout} \
   CONFIG.PSU_MIO_47_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_47_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_47_POLARITY {Default} \
   CONFIG.PSU_MIO_47_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_47_SLEW {fast} \
   CONFIG.PSU_MIO_48_DIRECTION {inout} \
   CONFIG.PSU_MIO_48_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_48_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_48_POLARITY {Default} \
   CONFIG.PSU_MIO_48_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_48_SLEW {fast} \
   CONFIG.PSU_MIO_49_DIRECTION {out} \
   CONFIG.PSU_MIO_49_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_49_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_49_POLARITY {Default} \
   CONFIG.PSU_MIO_49_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_49_SLEW {fast} \
   CONFIG.PSU_MIO_4_DIRECTION {inout} \
   CONFIG.PSU_MIO_4_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_4_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_4_POLARITY {Default} \
   CONFIG.PSU_MIO_4_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_4_SLEW {fast} \
   CONFIG.PSU_MIO_50_DIRECTION {inout} \
   CONFIG.PSU_MIO_50_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_50_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_50_POLARITY {Default} \
   CONFIG.PSU_MIO_50_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_50_SLEW {fast} \
   CONFIG.PSU_MIO_51_DIRECTION {inout} \
   CONFIG.PSU_MIO_51_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_51_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_51_POLARITY {Default} \
   CONFIG.PSU_MIO_51_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_51_SLEW {fast} \
   CONFIG.PSU_MIO_52_DIRECTION {in} \
   CONFIG.PSU_MIO_52_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_52_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_52_POLARITY {Default} \
   CONFIG.PSU_MIO_52_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_52_SLEW {fast} \
   CONFIG.PSU_MIO_53_DIRECTION {in} \
   CONFIG.PSU_MIO_53_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_53_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_53_POLARITY {Default} \
   CONFIG.PSU_MIO_53_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_53_SLEW {fast} \
   CONFIG.PSU_MIO_54_DIRECTION {inout} \
   CONFIG.PSU_MIO_54_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_54_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_54_POLARITY {Default} \
   CONFIG.PSU_MIO_54_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_54_SLEW {fast} \
   CONFIG.PSU_MIO_55_DIRECTION {in} \
   CONFIG.PSU_MIO_55_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_55_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_55_POLARITY {Default} \
   CONFIG.PSU_MIO_55_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_55_SLEW {fast} \
   CONFIG.PSU_MIO_56_DIRECTION {inout} \
   CONFIG.PSU_MIO_56_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_56_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_56_POLARITY {Default} \
   CONFIG.PSU_MIO_56_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_56_SLEW {fast} \
   CONFIG.PSU_MIO_57_DIRECTION {inout} \
   CONFIG.PSU_MIO_57_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_57_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_57_POLARITY {Default} \
   CONFIG.PSU_MIO_57_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_57_SLEW {fast} \
   CONFIG.PSU_MIO_58_DIRECTION {out} \
   CONFIG.PSU_MIO_58_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_58_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_58_POLARITY {Default} \
   CONFIG.PSU_MIO_58_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_58_SLEW {fast} \
   CONFIG.PSU_MIO_59_DIRECTION {inout} \
   CONFIG.PSU_MIO_59_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_59_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_59_POLARITY {Default} \
   CONFIG.PSU_MIO_59_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_59_SLEW {fast} \
   CONFIG.PSU_MIO_5_DIRECTION {out} \
   CONFIG.PSU_MIO_5_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_5_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_5_POLARITY {Default} \
   CONFIG.PSU_MIO_5_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_5_SLEW {fast} \
   CONFIG.PSU_MIO_60_DIRECTION {inout} \
   CONFIG.PSU_MIO_60_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_60_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_60_POLARITY {Default} \
   CONFIG.PSU_MIO_60_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_60_SLEW {fast} \
   CONFIG.PSU_MIO_61_DIRECTION {inout} \
   CONFIG.PSU_MIO_61_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_61_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_61_POLARITY {Default} \
   CONFIG.PSU_MIO_61_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_61_SLEW {fast} \
   CONFIG.PSU_MIO_62_DIRECTION {inout} \
   CONFIG.PSU_MIO_62_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_62_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_62_POLARITY {Default} \
   CONFIG.PSU_MIO_62_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_62_SLEW {fast} \
   CONFIG.PSU_MIO_63_DIRECTION {inout} \
   CONFIG.PSU_MIO_63_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_63_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_63_POLARITY {Default} \
   CONFIG.PSU_MIO_63_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_63_SLEW {fast} \
   CONFIG.PSU_MIO_64_DIRECTION {inout} \
   CONFIG.PSU_MIO_64_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_64_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_64_POLARITY {Default} \
   CONFIG.PSU_MIO_64_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_64_SLEW {fast} \
   CONFIG.PSU_MIO_65_DIRECTION {inout} \
   CONFIG.PSU_MIO_65_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_65_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_65_POLARITY {Default} \
   CONFIG.PSU_MIO_65_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_65_SLEW {fast} \
   CONFIG.PSU_MIO_66_DIRECTION {inout} \
   CONFIG.PSU_MIO_66_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_66_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_66_POLARITY {Default} \
   CONFIG.PSU_MIO_66_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_66_SLEW {fast} \
   CONFIG.PSU_MIO_67_DIRECTION {inout} \
   CONFIG.PSU_MIO_67_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_67_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_67_POLARITY {Default} \
   CONFIG.PSU_MIO_67_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_67_SLEW {fast} \
   CONFIG.PSU_MIO_68_DIRECTION {inout} \
   CONFIG.PSU_MIO_68_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_68_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_68_POLARITY {Default} \
   CONFIG.PSU_MIO_68_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_68_SLEW {fast} \
   CONFIG.PSU_MIO_69_DIRECTION {inout} \
   CONFIG.PSU_MIO_69_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_69_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_69_POLARITY {Default} \
   CONFIG.PSU_MIO_69_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_69_SLEW {fast} \
   CONFIG.PSU_MIO_6_DIRECTION {inout} \
   CONFIG.PSU_MIO_6_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_6_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_6_POLARITY {Default} \
   CONFIG.PSU_MIO_6_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_6_SLEW {fast} \
   CONFIG.PSU_MIO_70_DIRECTION {inout} \
   CONFIG.PSU_MIO_70_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_70_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_70_POLARITY {Default} \
   CONFIG.PSU_MIO_70_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_70_SLEW {fast} \
   CONFIG.PSU_MIO_71_DIRECTION {inout} \
   CONFIG.PSU_MIO_71_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_71_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_71_POLARITY {Default} \
   CONFIG.PSU_MIO_71_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_71_SLEW {fast} \
   CONFIG.PSU_MIO_72_DIRECTION {inout} \
   CONFIG.PSU_MIO_72_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_72_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_72_POLARITY {Default} \
   CONFIG.PSU_MIO_72_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_72_SLEW {fast} \
   CONFIG.PSU_MIO_73_DIRECTION {inout} \
   CONFIG.PSU_MIO_73_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_73_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_73_POLARITY {Default} \
   CONFIG.PSU_MIO_73_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_73_SLEW {fast} \
   CONFIG.PSU_MIO_74_DIRECTION {inout} \
   CONFIG.PSU_MIO_74_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_74_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_74_POLARITY {Default} \
   CONFIG.PSU_MIO_74_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_74_SLEW {fast} \
   CONFIG.PSU_MIO_75_DIRECTION {inout} \
   CONFIG.PSU_MIO_75_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_75_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_75_POLARITY {Default} \
   CONFIG.PSU_MIO_75_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_75_SLEW {fast} \
   CONFIG.PSU_MIO_76_DIRECTION {out} \
   CONFIG.PSU_MIO_76_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_76_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_76_POLARITY {Default} \
   CONFIG.PSU_MIO_76_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_76_SLEW {fast} \
   CONFIG.PSU_MIO_77_DIRECTION {inout} \
   CONFIG.PSU_MIO_77_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_77_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_77_POLARITY {Default} \
   CONFIG.PSU_MIO_77_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_77_SLEW {fast} \
   CONFIG.PSU_MIO_7_DIRECTION {inout} \
   CONFIG.PSU_MIO_7_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_7_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_7_POLARITY {Default} \
   CONFIG.PSU_MIO_7_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_7_SLEW {fast} \
   CONFIG.PSU_MIO_8_DIRECTION {inout} \
   CONFIG.PSU_MIO_8_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_8_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_8_POLARITY {Default} \
   CONFIG.PSU_MIO_8_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_8_SLEW {fast} \
   CONFIG.PSU_MIO_9_DIRECTION {inout} \
   CONFIG.PSU_MIO_9_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_9_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_9_POLARITY {Default} \
   CONFIG.PSU_MIO_9_PULLUPDOWN {pullup} \
   CONFIG.PSU_MIO_9_SLEW {fast} \
   CONFIG.PSU_MIO_TREE_PERIPHERALS { \
     0#GPIO0 MIO#GPIO0 \
     0#GPIO1 MIO#GPIO1 \
     0#GPIO1 MIO#GPIO1 \
     0#SD 0#SD \
     0#SD 0#SD \
     0#SD 0#SD \
     0#SD 0#SD \
     0#SD 0#SD \
     0#USB 0#GPIO2 \
     0#USB 0#GPIO2 \
     0#USB 0#GPIO2 \
     0#USB 0#GPIO2 \
     0#USB 0#GPIO2 \
     0#USB 0#GPIO2 \
     1#GPIO1 MIO#GPIO1 \
     3#MDIO 3 \
     Flash#GPIO0 MIO#GPIO0 \
     Flash#Quad SPI \
     Flash#Quad SPI \
     Flash#Quad SPI \
     Flash#Quad SPI \
     Flash#Quad SPI \
     MIO#GPIO0 MIO#SD \
     MIO#GPIO0 MIO#SD \
     MIO#GPIO0 MIO#SD \
     MIO#GPIO1 MIO#USB \
     MIO#GPIO1 MIO#USB \
     MIO#GPIO1 MIO#USB \
     MIO#GPIO1 MIO#USB \
     MIO#GPIO1 MIO#USB \
     MIO#GPIO1 MIO#USB \
     MIO#GPIO1 MIO#USB \
     MIO#GPIO2 MIO#MDIO \
     MIO#GPIO2 MIO#MDIO \
     MIO#GPIO2 MIO#MDIO \
     MIO#GPIO2 MIO#MDIO \
     MIO#GPIO2 MIO#MDIO \
     MIO#GPIO2 MIO#MDIO \
     MIO#I2C 1#I2C \
     MIO#I2C 1#I2C \
     MIO#UART 0#UART \
     Quad SPI \
   } \
   CONFIG.PSU_MIO_TREE_SIGNALS {sclk_out#miso_mo1#mo2#mo3#mosi_mi0#n_ss_out#gpio0[6]#gpio0[7]#gpio0[8]#gpio0[9]#gpio0[10]#gpio0[11]#gpio0[12]#sdio0_data_out[0]#sdio0_data_out[1]#sdio0_data_out[2]#sdio0_data_out[3]#sdio0_data_out[4]#sdio0_data_out[5]#sdio0_data_out[6]#sdio0_data_out[7]#sdio0_cmd_out#sdio0_clk_out#sdio0_bus_pow#gpio0[24]#gpio0[25]#rxd#txd#gpio1[28]#gpio1[29]#scl_out#sda_out#gpio1[32]#gpio1[33]#gpio1[34]#gpio1[35]#gpio1[36]#gpio1[37]#gpio1[38]#gpio1[39]#scl_out#sda_out#gpio1[42]#gpio1[43]#gpio1[44]#gpio1[45]#gpio1[46]#gpio1[47]#gpio1[48]#reset_n#gpio1[50]#gpio1[51]#ulpi_clk_in#ulpi_dir#ulpi_tx_data[2]#ulpi_nxt#ulpi_tx_data[0]#ulpi_tx_data[1]#ulpi_stp#ulpi_tx_data[3]#ulpi_tx_data[4]#ulpi_tx_data[5]#ulpi_tx_data[6]#ulpi_tx_data[7]#gpio2[64]#gpio2[65]#gpio2[66]#gpio2[67]#gpio2[68]#gpio2[69]#gpio2[70]#gpio2[71]#gpio2[72]#gpio2[73]#gpio2[74]#gpio2[75]#gem3_mdc#gem3_mdio_out} \
   CONFIG.PSU_SD0_INTERNAL_BUS_WIDTH {8} \
   CONFIG.PSU_SD1_INTERNAL_BUS_WIDTH {4} \
   CONFIG.PSU_SMC_CYCLE_T0 {NA} \
   CONFIG.PSU_SMC_CYCLE_T1 {NA} \
   CONFIG.PSU_SMC_CYCLE_T2 {NA} \
   CONFIG.PSU_SMC_CYCLE_T3 {NA} \
   CONFIG.PSU_SMC_CYCLE_T4 {NA} \
   CONFIG.PSU_SMC_CYCLE_T5 {NA} \
   CONFIG.PSU_SMC_CYCLE_T6 {NA} \
   CONFIG.PSU_USB3__DUAL_CLOCK_ENABLE {1} \
   CONFIG.PSU_VALUE_SILVERSION {3} \
   CONFIG.PSU__ACPU0__POWER__ON {1} \
   CONFIG.PSU__ACPU1__POWER__ON {1} \
   CONFIG.PSU__ACPU2__POWER__ON {1} \
   CONFIG.PSU__ACPU3__POWER__ON {1} \
   CONFIG.PSU__ACTUAL__IP {1} \
   CONFIG.PSU__ACT_DDR_FREQ_MHZ {1199.988037} \
   CONFIG.PSU__AFI0_COHERENCY {0} \
   CONFIG.PSU__AFI1_COHERENCY {0} \
   CONFIG.PSU__AUX_REF_CLK__FREQMHZ {33.333} \
   CONFIG.PSU__CAN0_LOOP_CAN1__ENABLE {0} \
   CONFIG.PSU__CAN0__GRP_CLK__ENABLE {0} \
   CONFIG.PSU__CAN0__PERIPHERAL__ENABLE {0} \
   CONFIG.PSU__CAN1__GRP_CLK__ENABLE {0} \
   CONFIG.PSU__CAN1__PERIPHERAL__ENABLE {0} \
   CONFIG.PSU__CRF_APB__ACPU_CTRL__ACT_FREQMHZ {1049.989502} \
   CONFIG.PSU__CRF_APB__ACPU_CTRL__DIVISOR0 {1} \
   CONFIG.PSU__CRF_APB__ACPU_CTRL__FREQMHZ {1200} \
   CONFIG.PSU__CRF_APB__ACPU_CTRL__SRCSEL {APLL} \
   CONFIG.PSU__CRF_APB__ACPU__FRAC_ENABLED {0} \
   CONFIG.PSU__CRF_APB__AFI0_REF_CTRL__ACT_FREQMHZ {667} \
   CONFIG.PSU__CRF_APB__AFI0_REF_CTRL__DIVISOR0 {2} \
   CONFIG.PSU__CRF_APB__AFI0_REF_CTRL__FREQMHZ {667} \
   CONFIG.PSU__CRF_APB__AFI0_REF_CTRL__SRCSEL {DPLL} \
   CONFIG.PSU__CRF_APB__AFI0_REF__ENABLE {0} \
   CONFIG.PSU__CRF_APB__AFI1_REF_CTRL__ACT_FREQMHZ {667} \
   CONFIG.PSU__CRF_APB__AFI1_REF_CTRL__DIVISOR0 {2} \
   CONFIG.PSU__CRF_APB__AFI1_REF_CTRL__FREQMHZ {667} \
   CONFIG.PSU__CRF_APB__AFI1_REF_CTRL__SRCSEL {DPLL} \
   CONFIG.PSU__CRF_APB__AFI1_REF__ENABLE {0} \
   CONFIG.PSU__CRF_APB__AFI2_REF_CTRL__ACT_FREQMHZ {667} \
   CONFIG.PSU__CRF_APB__AFI2_REF_CTRL__DIVISOR0 {2} \
   CONFIG.PSU__CRF_APB__AFI2_REF_CTRL__FREQMHZ {667} \
   CONFIG.PSU__CRF_APB__AFI2_REF_CTRL__SRCSEL {DPLL} \
   CONFIG.PSU__CRF_APB__AFI2_REF__ENABLE {0} \
   CONFIG.PSU__CRF_APB__AFI3_REF_CTRL__ACT_FREQMHZ {667} \
   CONFIG.PSU__CRF_APB__AFI3_REF_CTRL__DIVISOR0 {2} \
   CONFIG.PSU__CRF_APB__AFI3_REF_CTRL__FREQMHZ {667} \
   CONFIG.PSU__CRF_APB__AFI3_REF_CTRL__SRCSEL {DPLL} \
   CONFIG.PSU__CRF_APB__AFI3_REF__ENABLE {0} \
   CONFIG.PSU__CRF_APB__AFI4_REF_CTRL__ACT_FREQMHZ {667} \
   CONFIG.PSU__CRF_APB__AFI4_REF_CTRL__DIVISOR0 {2} \
   CONFIG.PSU__CRF_APB__AFI4_REF_CTRL__FREQMHZ {667} \
   CONFIG.PSU__CRF_APB__AFI4_REF_CTRL__SRCSEL {DPLL} \
   CONFIG.PSU__CRF_APB__AFI4_REF__ENABLE {0} \
   CONFIG.PSU__CRF_APB__AFI5_REF_CTRL__ACT_FREQMHZ {667} \
   CONFIG.PSU__CRF_APB__AFI5_REF_CTRL__DIVISOR0 {2} \
   CONFIG.PSU__CRF_APB__AFI5_REF_CTRL__FREQMHZ {667} \
   CONFIG.PSU__CRF_APB__AFI5_REF_CTRL__SRCSEL {DPLL} \
   CONFIG.PSU__CRF_APB__AFI5_REF__ENABLE {0} \
   CONFIG.PSU__CRF_APB__APLL_CTRL__DIV2 {1} \
   CONFIG.PSU__CRF_APB__APLL_CTRL__FBDIV {63} \
   CONFIG.PSU__CRF_APB__APLL_CTRL__FRACDATA {0.000000} \
   CONFIG.PSU__CRF_APB__APLL_CTRL__FRACFREQ {27.138} \
   CONFIG.PSU__CRF_APB__APLL_CTRL__SRCSEL {PSS_REF_CLK} \
   CONFIG.PSU__CRF_APB__APLL_FRAC_CFG__ENABLED {0} \
   CONFIG.PSU__CRF_APB__APLL_TO_LPD_CTRL__DIVISOR0 {2} \
   CONFIG.PSU__CRF_APB__APM_CTRL__ACT_FREQMHZ {1} \
   CONFIG.PSU__CRF_APB__APM_CTRL__DIVISOR0 {1} \
   CONFIG.PSU__CRF_APB__APM_CTRL__FREQMHZ {1} \
   CONFIG.PSU__CRF_APB__DBG_FPD_CTRL__ACT_FREQMHZ {249.997498} \
   CONFIG.PSU__CRF_APB__DBG_FPD_CTRL__DIVISOR0 {2} \
   CONFIG.PSU__CRF_APB__DBG_FPD_CTRL__FREQMHZ {250} \
   CONFIG.PSU__CRF_APB__DBG_FPD_CTRL__SRCSEL {IOPLL} \
   CONFIG.PSU__CRF_APB__DBG_TRACE_CTRL__ACT_FREQMHZ {250} \
   CONFIG.PSU__CRF_APB__DBG_TRACE_CTRL__DIVISOR0 {5} \
   CONFIG.PSU__CRF_APB__DBG_TRACE_CTRL__FREQMHZ {250} \
   CONFIG.PSU__CRF_APB__DBG_TRACE_CTRL__SRCSEL {IOPLL} \
   CONFIG.PSU__CRF_APB__DBG_TSTMP_CTRL__ACT_FREQMHZ {249.997498} \
   CONFIG.PSU__CRF_APB__DBG_TSTMP_CTRL__DIVISOR0 {2} \
   CONFIG.PSU__CRF_APB__DBG_TSTMP_CTRL__FREQMHZ {250} \
   CONFIG.PSU__CRF_APB__DBG_TSTMP_CTRL__SRCSEL {IOPLL} \
   CONFIG.PSU__CRF_APB__DDR_CTRL__ACT_FREQMHZ {599.994019} \
   CONFIG.PSU__CRF_APB__DDR_CTRL__DIVISOR0 {2} \
   CONFIG.PSU__CRF_APB__DDR_CTRL__FREQMHZ {1200} \
   CONFIG.PSU__CRF_APB__DDR_CTRL__SRCSEL {DPLL} \
   CONFIG.PSU__CRF_APB__DPDMA_REF_CTRL__ACT_FREQMHZ {599.994019} \
   CONFIG.PSU__CRF_APB__DPDMA_REF_CTRL__DIVISOR0 {2} \
   CONFIG.PSU__CRF_APB__DPDMA_REF_CTRL__FREQMHZ {600} \
   CONFIG.PSU__CRF_APB__DPDMA_REF_CTRL__SRCSEL {DPLL} \
   CONFIG.PSU__CRF_APB__DPLL_CTRL__DIV2 {1} \
   CONFIG.PSU__CRF_APB__DPLL_CTRL__FBDIV {72} \
   CONFIG.PSU__CRF_APB__DPLL_CTRL__FRACDATA {0.000000} \
   CONFIG.PSU__CRF_APB__DPLL_CTRL__FRACFREQ {27.138} \
   CONFIG.PSU__CRF_APB__DPLL_CTRL__SRCSEL {PSS_REF_CLK} \
   CONFIG.PSU__CRF_APB__DPLL_FRAC_CFG__ENABLED {0} \
   CONFIG.PSU__CRF_APB__DPLL_TO_LPD_CTRL__DIVISOR0 {3} \
   CONFIG.PSU__CRF_APB__DP_AUDIO_REF_CTRL__ACT_FREQMHZ {24.999750} \
   CONFIG.PSU__CRF_APB__DP_AUDIO_REF_CTRL__DIVISOR0 {63} \
   CONFIG.PSU__CRF_APB__DP_AUDIO_REF_CTRL__DIVISOR1 {1} \
   CONFIG.PSU__CRF_APB__DP_AUDIO_REF_CTRL__FREQMHZ {25} \
   CONFIG.PSU__CRF_APB__DP_AUDIO_REF_CTRL__SRCSEL {RPLL} \
   CONFIG.PSU__CRF_APB__DP_AUDIO__FRAC_ENABLED {0} \
   CONFIG.PSU__CRF_APB__DP_STC_REF_CTRL__ACT_FREQMHZ {26.666401} \
   CONFIG.PSU__CRF_APB__DP_STC_REF_CTRL__DIVISOR0 {6} \
   CONFIG.PSU__CRF_APB__DP_STC_REF_CTRL__DIVISOR1 {10} \
   CONFIG.PSU__CRF_APB__DP_STC_REF_CTRL__FREQMHZ {27} \
   CONFIG.PSU__CRF_APB__DP_STC_REF_CTRL__SRCSEL {RPLL} \
   CONFIG.PSU__CRF_APB__DP_VIDEO_REF_CTRL__ACT_FREQMHZ {299.997009} \
   CONFIG.PSU__CRF_APB__DP_VIDEO_REF_CTRL__DIVISOR0 {5} \
   CONFIG.PSU__CRF_APB__DP_VIDEO_REF_CTRL__DIVISOR1 {1} \
   CONFIG.PSU__CRF_APB__DP_VIDEO_REF_CTRL__FREQMHZ {300} \
   CONFIG.PSU__CRF_APB__DP_VIDEO_REF_CTRL__SRCSEL {VPLL} \
   CONFIG.PSU__CRF_APB__DP_VIDEO__FRAC_ENABLED {0} \
   CONFIG.PSU__CRF_APB__GDMA_REF_CTRL__ACT_FREQMHZ {599.994019} \
   CONFIG.PSU__CRF_APB__GDMA_REF_CTRL__DIVISOR0 {2} \
   CONFIG.PSU__CRF_APB__GDMA_REF_CTRL__FREQMHZ {600} \
   CONFIG.PSU__CRF_APB__GDMA_REF_CTRL__SRCSEL {DPLL} \
   CONFIG.PSU__CRF_APB__GPU_REF_CTRL__ACT_FREQMHZ {0} \
   CONFIG.PSU__CRF_APB__GPU_REF_CTRL__DIVISOR0 {3} \
   CONFIG.PSU__CRF_APB__GPU_REF_CTRL__FREQMHZ {600} \
   CONFIG.PSU__CRF_APB__GPU_REF_CTRL__SRCSEL {DPLL} \
   CONFIG.PSU__CRF_APB__GTGREF0_REF_CTRL__ACT_FREQMHZ {-1} \
   CONFIG.PSU__CRF_APB__GTGREF0_REF_CTRL__DIVISOR0 {-1} \
   CONFIG.PSU__CRF_APB__GTGREF0_REF_CTRL__FREQMHZ {-1} \
   CONFIG.PSU__CRF_APB__GTGREF0_REF_CTRL__SRCSEL {NA} \
   CONFIG.PSU__CRF_APB__GTGREF0__ENABLE {NA} \
   CONFIG.PSU__CRF_APB__PCIE_REF_CTRL__ACT_FREQMHZ {249.997498} \
   CONFIG.PSU__CRF_APB__PCIE_REF_CTRL__DIVISOR0 {2} \
   CONFIG.PSU__CRF_APB__PCIE_REF_CTRL__FREQMHZ {250} \
   CONFIG.PSU__CRF_APB__PCIE_REF_CTRL__SRCSEL {IOPLL} \
   CONFIG.PSU__CRF_APB__SATA_REF_CTRL__ACT_FREQMHZ {250} \
   CONFIG.PSU__CRF_APB__SATA_REF_CTRL__DIVISOR0 {5} \
   CONFIG.PSU__CRF_APB__SATA_REF_CTRL__FREQMHZ {250} \
   CONFIG.PSU__CRF_APB__SATA_REF_CTRL__SRCSEL {IOPLL} \
   CONFIG.PSU__CRF_APB__TOPSW_LSBUS_CTRL__ACT_FREQMHZ {99.999001} \
   CONFIG.PSU__CRF_APB__TOPSW_LSBUS_CTRL__DIVISOR0 {5} \
   CONFIG.PSU__CRF_APB__TOPSW_LSBUS_CTRL__FREQMHZ {100} \
   CONFIG.PSU__CRF_APB__TOPSW_LSBUS_CTRL__SRCSEL {IOPLL} \
   CONFIG.PSU__CRF_APB__TOPSW_MAIN_CTRL__ACT_FREQMHZ {524.994751} \
   CONFIG.PSU__CRF_APB__TOPSW_MAIN_CTRL__DIVISOR0 {2} \
   CONFIG.PSU__CRF_APB__TOPSW_MAIN_CTRL__FREQMHZ {533} \
   CONFIG.PSU__CRF_APB__TOPSW_MAIN_CTRL__SRCSEL {APLL} \
   CONFIG.PSU__CRF_APB__VPLL_CTRL__DIV2 {1} \
   CONFIG.PSU__CRF_APB__VPLL_CTRL__FBDIV {90} \
   CONFIG.PSU__CRF_APB__VPLL_CTRL__FRACDATA {0.000000} \
   CONFIG.PSU__CRF_APB__VPLL_CTRL__FRACFREQ {27.138} \
   CONFIG.PSU__CRF_APB__VPLL_CTRL__SRCSEL {PSS_REF_CLK} \
   CONFIG.PSU__CRF_APB__VPLL_FRAC_CFG__ENABLED {0} \
   CONFIG.PSU__CRF_APB__VPLL_TO_LPD_CTRL__DIVISOR0 {3} \
   CONFIG.PSU__CRL_APB__ADMA_REF_CTRL__ACT_FREQMHZ {499.994995} \
   CONFIG.PSU__CRL_APB__ADMA_REF_CTRL__DIVISOR0 {3} \
   CONFIG.PSU__CRL_APB__ADMA_REF_CTRL__FREQMHZ {500} \
   CONFIG.PSU__CRL_APB__ADMA_REF_CTRL__SRCSEL {IOPLL} \
   CONFIG.PSU__CRL_APB__AFI6_REF_CTRL__ACT_FREQMHZ {500} \
   CONFIG.PSU__CRL_APB__AFI6_REF_CTRL__DIVISOR0 {3} \
   CONFIG.PSU__CRL_APB__AFI6_REF_CTRL__FREQMHZ {500} \
   CONFIG.PSU__CRL_APB__AFI6_REF_CTRL__SRCSEL {IOPLL} \
   CONFIG.PSU__CRL_APB__AFI6__ENABLE {0} \
   CONFIG.PSU__CRL_APB__AMS_REF_CTRL__ACT_FREQMHZ {49.999500} \
   CONFIG.PSU__CRL_APB__AMS_REF_CTRL__DIVISOR0 {30} \
   CONFIG.PSU__CRL_APB__AMS_REF_CTRL__DIVISOR1 {1} \
   CONFIG.PSU__CRL_APB__AMS_REF_CTRL__FREQMHZ {50} \
   CONFIG.PSU__CRL_APB__AMS_REF_CTRL__SRCSEL {IOPLL} \
   CONFIG.PSU__CRL_APB__CAN0_REF_CTRL__ACT_FREQMHZ {99.999001} \
   CONFIG.PSU__CRL_APB__CAN0_REF_CTRL__DIVISOR0 {15} \
   CONFIG.PSU__CRL_APB__CAN0_REF_CTRL__DIVISOR1 {1} \
   CONFIG.PSU__CRL_APB__CAN0_REF_CTRL__FREQMHZ {100} \
   CONFIG.PSU__CRL_APB__CAN0_REF_CTRL__SRCSEL {IOPLL} \
   CONFIG.PSU__CRL_APB__CAN1_REF_CTRL__ACT_FREQMHZ {100} \
   CONFIG.PSU__CRL_APB__CAN1_REF_CTRL__DIVISOR0 {15} \
   CONFIG.PSU__CRL_APB__CAN1_REF_CTRL__DIVISOR1 {1} \
   CONFIG.PSU__CRL_APB__CAN1_REF_CTRL__FREQMHZ {100} \
   CONFIG.PSU__CRL_APB__CAN1_REF_CTRL__SRCSEL {IOPLL} \
   CONFIG.PSU__CRL_APB__CPU_R5_CTRL__ACT_FREQMHZ {499.994995} \
   CONFIG.PSU__CRL_APB__CPU_R5_CTRL__DIVISOR0 {3} \
   CONFIG.PSU__CRL_APB__CPU_R5_CTRL__FREQMHZ {500} \
   CONFIG.PSU__CRL_APB__CPU_R5_CTRL__SRCSEL {IOPLL} \
   CONFIG.PSU__CRL_APB__CSU_PLL_CTRL__ACT_FREQMHZ {180} \
   CONFIG.PSU__CRL_APB__CSU_PLL_CTRL__DIVISOR0 {3} \
   CONFIG.PSU__CRL_APB__CSU_PLL_CTRL__FREQMHZ {180} \
   CONFIG.PSU__CRL_APB__CSU_PLL_CTRL__SRCSEL {SysOsc} \
   CONFIG.PSU__CRL_APB__DBG_LPD_CTRL__ACT_FREQMHZ {249.997498} \
   CONFIG.PSU__CRL_APB__DBG_LPD_CTRL__DIVISOR0 {6} \
   CONFIG.PSU__CRL_APB__DBG_LPD_CTRL__FREQMHZ {250} \
   CONFIG.PSU__CRL_APB__DBG_LPD_CTRL__SRCSEL {IOPLL} \
   CONFIG.PSU__CRL_APB__DEBUG_R5_ATCLK_CTRL__ACT_FREQMHZ {1000} \
   CONFIG.PSU__CRL_APB__DEBUG_R5_ATCLK_CTRL__DIVISOR0 {6} \
   CONFIG.PSU__CRL_APB__DEBUG_R5_ATCLK_CTRL__FREQMHZ {1000} \
   CONFIG.PSU__CRL_APB__DEBUG_R5_ATCLK_CTRL__SRCSEL {RPLL} \
   CONFIG.PSU__CRL_APB__DLL_REF_CTRL__ACT_FREQMHZ {1499.984985} \
   CONFIG.PSU__CRL_APB__DLL_REF_CTRL__FREQMHZ {1500} \
   CONFIG.PSU__CRL_APB__DLL_REF_CTRL__SRCSEL {IOPLL} \
   CONFIG.PSU__CRL_APB__GEM0_REF_CTRL__ACT_FREQMHZ {125} \
   CONFIG.PSU__CRL_APB__GEM0_REF_CTRL__DIVISOR0 {12} \
   CONFIG.PSU__CRL_APB__GEM0_REF_CTRL__DIVISOR1 {1} \
   CONFIG.PSU__CRL_APB__GEM0_REF_CTRL__FREQMHZ {125} \
   CONFIG.PSU__CRL_APB__GEM0_REF_CTRL__SRCSEL {IOPLL} \
   CONFIG.PSU__CRL_APB__GEM1_REF_CTRL__ACT_FREQMHZ {125} \
   CONFIG.PSU__CRL_APB__GEM1_REF_CTRL__DIVISOR0 {12} \
   CONFIG.PSU__CRL_APB__GEM1_REF_CTRL__DIVISOR1 {1} \
   CONFIG.PSU__CRL_APB__GEM1_REF_CTRL__FREQMHZ {125} \
   CONFIG.PSU__CRL_APB__GEM1_REF_CTRL__SRCSEL {IOPLL} \
   CONFIG.PSU__CRL_APB__GEM2_REF_CTRL__ACT_FREQMHZ {125} \
   CONFIG.PSU__CRL_APB__GEM2_REF_CTRL__DIVISOR0 {12} \
   CONFIG.PSU__CRL_APB__GEM2_REF_CTRL__DIVISOR1 {1} \
   CONFIG.PSU__CRL_APB__GEM2_REF_CTRL__FREQMHZ {125} \
   CONFIG.PSU__CRL_APB__GEM2_REF_CTRL__SRCSEL {IOPLL} \
   CONFIG.PSU__CRL_APB__GEM3_REF_CTRL__ACT_FREQMHZ {124.998749} \
   CONFIG.PSU__CRL_APB__GEM3_REF_CTRL__DIVISOR0 {12} \
   CONFIG.PSU__CRL_APB__GEM3_REF_CTRL__DIVISOR1 {1} \
   CONFIG.PSU__CRL_APB__GEM3_REF_CTRL__FREQMHZ {125} \
   CONFIG.PSU__CRL_APB__GEM3_REF_CTRL__SRCSEL {IOPLL} \
   CONFIG.PSU__CRL_APB__GEM_TSU_REF_CTRL__ACT_FREQMHZ {249.997498} \
   CONFIG.PSU__CRL_APB__GEM_TSU_REF_CTRL__DIVISOR0 {6} \
   CONFIG.PSU__CRL_APB__GEM_TSU_REF_CTRL__DIVISOR1 {1} \
   CONFIG.PSU__CRL_APB__GEM_TSU_REF_CTRL__FREQMHZ {250} \
   CONFIG.PSU__CRL_APB__GEM_TSU_REF_CTRL__SRCSEL {IOPLL} \
   CONFIG.PSU__CRL_APB__I2C0_REF_CTRL__ACT_FREQMHZ {99.999001} \
   CONFIG.PSU__CRL_APB__I2C0_REF_CTRL__DIVISOR0 {15} \
   CONFIG.PSU__CRL_APB__I2C0_REF_CTRL__DIVISOR1 {1} \
   CONFIG.PSU__CRL_APB__I2C0_REF_CTRL__FREQMHZ {100} \
   CONFIG.PSU__CRL_APB__I2C0_REF_CTRL__SRCSEL {IOPLL} \
   CONFIG.PSU__CRL_APB__I2C1_REF_CTRL__ACT_FREQMHZ {99.999001} \
   CONFIG.PSU__CRL_APB__I2C1_REF_CTRL__DIVISOR0 {15} \
   CONFIG.PSU__CRL_APB__I2C1_REF_CTRL__DIVISOR1 {1} \
   CONFIG.PSU__CRL_APB__I2C1_REF_CTRL__FREQMHZ {100} \
   CONFIG.PSU__CRL_APB__I2C1_REF_CTRL__SRCSEL {IOPLL} \
   CONFIG.PSU__CRL_APB__IOPLL_CTRL__DIV2 {1} \
   CONFIG.PSU__CRL_APB__IOPLL_CTRL__FBDIV {90} \
   CONFIG.PSU__CRL_APB__IOPLL_CTRL__FRACDATA {0.000000} \
   CONFIG.PSU__CRL_APB__IOPLL_CTRL__FRACFREQ {27.138} \
   CONFIG.PSU__CRL_APB__IOPLL_CTRL__SRCSEL {PSS_REF_CLK} \
   CONFIG.PSU__CRL_APB__IOPLL_FRAC_CFG__ENABLED {0} \
   CONFIG.PSU__CRL_APB__IOPLL_TO_FPD_CTRL__DIVISOR0 {3} \
   CONFIG.PSU__CRL_APB__IOU_SWITCH_CTRL__ACT_FREQMHZ {249.997498} \
   CONFIG.PSU__CRL_APB__IOU_SWITCH_CTRL__DIVISOR0 {6} \
   CONFIG.PSU__CRL_APB__IOU_SWITCH_CTRL__FREQMHZ {250} \
   CONFIG.PSU__CRL_APB__IOU_SWITCH_CTRL__SRCSEL {IOPLL} \
   CONFIG.PSU__CRL_APB__LPD_LSBUS_CTRL__ACT_FREQMHZ {99.999001} \
   CONFIG.PSU__CRL_APB__LPD_LSBUS_CTRL__DIVISOR0 {15} \
   CONFIG.PSU__CRL_APB__LPD_LSBUS_CTRL__FREQMHZ {100} \
   CONFIG.PSU__CRL_APB__LPD_LSBUS_CTRL__SRCSEL {IOPLL} \
   CONFIG.PSU__CRL_APB__LPD_SWITCH_CTRL__ACT_FREQMHZ {499.994995} \
   CONFIG.PSU__CRL_APB__LPD_SWITCH_CTRL__DIVISOR0 {3} \
   CONFIG.PSU__CRL_APB__LPD_SWITCH_CTRL__FREQMHZ {500} \
   CONFIG.PSU__CRL_APB__LPD_SWITCH_CTRL__SRCSEL {IOPLL} \
   CONFIG.PSU__CRL_APB__NAND_REF_CTRL__ACT_FREQMHZ {100} \
   CONFIG.PSU__CRL_APB__NAND_REF_CTRL__DIVISOR0 {15} \
   CONFIG.PSU__CRL_APB__NAND_REF_CTRL__DIVISOR1 {1} \
   CONFIG.PSU__CRL_APB__NAND_REF_CTRL__FREQMHZ {100} \
   CONFIG.PSU__CRL_APB__NAND_REF_CTRL__SRCSEL {IOPLL} \
   CONFIG.PSU__CRL_APB__OCM_MAIN_CTRL__ACT_FREQMHZ {500} \
   CONFIG.PSU__CRL_APB__OCM_MAIN_CTRL__DIVISOR0 {3} \
   CONFIG.PSU__CRL_APB__OCM_MAIN_CTRL__FREQMHZ {500} \
   CONFIG.PSU__CRL_APB__OCM_MAIN_CTRL__SRCSEL {IOPLL} \
   CONFIG.PSU__CRL_APB__PCAP_CTRL__ACT_FREQMHZ {187.498123} \
   CONFIG.PSU__CRL_APB__PCAP_CTRL__DIVISOR0 {8} \
   CONFIG.PSU__CRL_APB__PCAP_CTRL__FREQMHZ {200} \
   CONFIG.PSU__CRL_APB__PCAP_CTRL__SRCSEL {IOPLL} \
   CONFIG.PSU__CRL_APB__PL0_REF_CTRL__ACT_FREQMHZ {99.999001} \
   CONFIG.PSU__CRL_APB__PL0_REF_CTRL__DIVISOR0 {15} \
   CONFIG.PSU__CRL_APB__PL0_REF_CTRL__DIVISOR1 {1} \
   CONFIG.PSU__CRL_APB__PL0_REF_CTRL__FREQMHZ {100} \
   CONFIG.PSU__CRL_APB__PL0_REF_CTRL__SRCSEL {IOPLL} \
   CONFIG.PSU__CRL_APB__PL1_REF_CTRL__ACT_FREQMHZ {199.998001} \
   CONFIG.PSU__CRL_APB__PL1_REF_CTRL__DIVISOR0 {7} \
   CONFIG.PSU__CRL_APB__PL1_REF_CTRL__DIVISOR1 {1} \
   CONFIG.PSU__CRL_APB__PL1_REF_CTRL__FREQMHZ {200} \
   CONFIG.PSU__CRL_APB__PL1_REF_CTRL__SRCSEL {RPLL} \
   CONFIG.PSU__CRL_APB__PL2_REF_CTRL__ACT_FREQMHZ {100} \
   CONFIG.PSU__CRL_APB__PL2_REF_CTRL__DIVISOR0 {4} \
   CONFIG.PSU__CRL_APB__PL2_REF_CTRL__DIVISOR1 {1} \
   CONFIG.PSU__CRL_APB__PL2_REF_CTRL__FREQMHZ {100} \
   CONFIG.PSU__CRL_APB__PL2_REF_CTRL__SRCSEL {RPLL} \
   CONFIG.PSU__CRL_APB__PL3_REF_CTRL__ACT_FREQMHZ {100} \
   CONFIG.PSU__CRL_APB__PL3_REF_CTRL__DIVISOR0 {4} \
   CONFIG.PSU__CRL_APB__PL3_REF_CTRL__DIVISOR1 {1} \
   CONFIG.PSU__CRL_APB__PL3_REF_CTRL__FREQMHZ {100} \
   CONFIG.PSU__CRL_APB__PL3_REF_CTRL__SRCSEL {RPLL} \
   CONFIG.PSU__CRL_APB__QSPI_REF_CTRL__ACT_FREQMHZ {124.998749} \
   CONFIG.PSU__CRL_APB__QSPI_REF_CTRL__DIVISOR0 {12} \
   CONFIG.PSU__CRL_APB__QSPI_REF_CTRL__DIVISOR1 {1} \
   CONFIG.PSU__CRL_APB__QSPI_REF_CTRL__FREQMHZ {125} \
   CONFIG.PSU__CRL_APB__QSPI_REF_CTRL__SRCSEL {IOPLL} \
   CONFIG.PSU__CRL_APB__RPLL_CTRL__DIV2 {1} \
   CONFIG.PSU__CRL_APB__RPLL_CTRL__FBDIV {84} \
   CONFIG.PSU__CRL_APB__RPLL_CTRL__FRACDATA {0.000000} \
   CONFIG.PSU__CRL_APB__RPLL_CTRL__FRACFREQ {27.138} \
   CONFIG.PSU__CRL_APB__RPLL_CTRL__SRCSEL {PSS_REF_CLK} \
   CONFIG.PSU__CRL_APB__RPLL_FRAC_CFG__ENABLED {0} \
   CONFIG.PSU__CRL_APB__RPLL_TO_FPD_CTRL__DIVISOR0 {3} \
   CONFIG.PSU__CRL_APB__SDIO0_REF_CTRL__ACT_FREQMHZ {187.498123} \
   CONFIG.PSU__CRL_APB__SDIO0_REF_CTRL__DIVISOR0 {8} \
   CONFIG.PSU__CRL_APB__SDIO0_REF_CTRL__DIVISOR1 {1} \
   CONFIG.PSU__CRL_APB__SDIO0_REF_CTRL__FREQMHZ {200} \
   CONFIG.PSU__CRL_APB__SDIO0_REF_CTRL__SRCSEL {IOPLL} \
   CONFIG.PSU__CRL_APB__SDIO1_REF_CTRL__ACT_FREQMHZ {187.498123} \
   CONFIG.PSU__CRL_APB__SDIO1_REF_CTRL__DIVISOR0 {7} \
   CONFIG.PSU__CRL_APB__SDIO1_REF_CTRL__DIVISOR1 {1} \
   CONFIG.PSU__CRL_APB__SDIO1_REF_CTRL__FREQMHZ {200} \
   CONFIG.PSU__CRL_APB__SDIO1_REF_CTRL__SRCSEL {IOPLL} \
   CONFIG.PSU__CRL_APB__SPI0_REF_CTRL__ACT_FREQMHZ {187.498123} \
   CONFIG.PSU__CRL_APB__SPI0_REF_CTRL__DIVISOR0 {8} \
   CONFIG.PSU__CRL_APB__SPI0_REF_CTRL__DIVISOR1 {1} \
   CONFIG.PSU__CRL_APB__SPI0_REF_CTRL__FREQMHZ {200} \
   CONFIG.PSU__CRL_APB__SPI0_REF_CTRL__SRCSEL {IOPLL} \
   CONFIG.PSU__CRL_APB__SPI1_REF_CTRL__ACT_FREQMHZ {187.498123} \
   CONFIG.PSU__CRL_APB__SPI1_REF_CTRL__DIVISOR0 {7} \
   CONFIG.PSU__CRL_APB__SPI1_REF_CTRL__DIVISOR1 {1} \
   CONFIG.PSU__CRL_APB__SPI1_REF_CTRL__FREQMHZ {200} \
   CONFIG.PSU__CRL_APB__SPI1_REF_CTRL__SRCSEL {IOPLL} \
   CONFIG.PSU__CRL_APB__TIMESTAMP_REF_CTRL__ACT_FREQMHZ {99.999001} \
   CONFIG.PSU__CRL_APB__TIMESTAMP_REF_CTRL__DIVISOR0 {15} \
   CONFIG.PSU__CRL_APB__TIMESTAMP_REF_CTRL__FREQMHZ {100} \
   CONFIG.PSU__CRL_APB__TIMESTAMP_REF_CTRL__SRCSEL {IOPLL} \
   CONFIG.PSU__CRL_APB__UART0_REF_CTRL__ACT_FREQMHZ {99.999001} \
   CONFIG.PSU__CRL_APB__UART0_REF_CTRL__DIVISOR0 {15} \
   CONFIG.PSU__CRL_APB__UART0_REF_CTRL__DIVISOR1 {1} \
   CONFIG.PSU__CRL_APB__UART0_REF_CTRL__FREQMHZ {100} \
   CONFIG.PSU__CRL_APB__UART0_REF_CTRL__SRCSEL {IOPLL} \
   CONFIG.PSU__CRL_APB__UART1_REF_CTRL__ACT_FREQMHZ {99.999001} \
   CONFIG.PSU__CRL_APB__UART1_REF_CTRL__DIVISOR0 {15} \
   CONFIG.PSU__CRL_APB__UART1_REF_CTRL__DIVISOR1 {1} \
   CONFIG.PSU__CRL_APB__UART1_REF_CTRL__FREQMHZ {100} \
   CONFIG.PSU__CRL_APB__UART1_REF_CTRL__SRCSEL {IOPLL} \
   CONFIG.PSU__CRL_APB__USB0_BUS_REF_CTRL__ACT_FREQMHZ {249.997498} \
   CONFIG.PSU__CRL_APB__USB0_BUS_REF_CTRL__DIVISOR0 {6} \
   CONFIG.PSU__CRL_APB__USB0_BUS_REF_CTRL__DIVISOR1 {1} \
   CONFIG.PSU__CRL_APB__USB0_BUS_REF_CTRL__FREQMHZ {250} \
   CONFIG.PSU__CRL_APB__USB0_BUS_REF_CTRL__SRCSEL {IOPLL} \
   CONFIG.PSU__CRL_APB__USB1_BUS_REF_CTRL__ACT_FREQMHZ {250} \
   CONFIG.PSU__CRL_APB__USB1_BUS_REF_CTRL__DIVISOR0 {6} \
   CONFIG.PSU__CRL_APB__USB1_BUS_REF_CTRL__DIVISOR1 {1} \
   CONFIG.PSU__CRL_APB__USB1_BUS_REF_CTRL__FREQMHZ {250} \
   CONFIG.PSU__CRL_APB__USB1_BUS_REF_CTRL__SRCSEL {IOPLL} \
   CONFIG.PSU__CRL_APB__USB3_DUAL_REF_CTRL__ACT_FREQMHZ {19.999800} \
   CONFIG.PSU__CRL_APB__USB3_DUAL_REF_CTRL__DIVISOR0 {25} \
   CONFIG.PSU__CRL_APB__USB3_DUAL_REF_CTRL__DIVISOR1 {3} \
   CONFIG.PSU__CRL_APB__USB3_DUAL_REF_CTRL__FREQMHZ {20} \
   CONFIG.PSU__CRL_APB__USB3_DUAL_REF_CTRL__SRCSEL {IOPLL} \
   CONFIG.PSU__CRL_APB__USB3__ENABLE {1} \
   CONFIG.PSU__CSUPMU__PERIPHERAL__VALID {0} \
   CONFIG.PSU__CSU_COHERENCY {0} \
   CONFIG.PSU__CSU__CSU_TAMPER_0__ENABLE {0} \
   CONFIG.PSU__CSU__CSU_TAMPER_0__ERASE_BBRAM {0} \
   CONFIG.PSU__CSU__CSU_TAMPER_10__ENABLE {0} \
   CONFIG.PSU__CSU__CSU_TAMPER_10__ERASE_BBRAM {0} \
   CONFIG.PSU__CSU__CSU_TAMPER_11__ENABLE {0} \
   CONFIG.PSU__CSU__CSU_TAMPER_11__ERASE_BBRAM {0} \
   CONFIG.PSU__CSU__CSU_TAMPER_12__ENABLE {0} \
   CONFIG.PSU__CSU__CSU_TAMPER_12__ERASE_BBRAM {0} \
   CONFIG.PSU__CSU__CSU_TAMPER_1__ENABLE {0} \
   CONFIG.PSU__CSU__CSU_TAMPER_1__ERASE_BBRAM {0} \
   CONFIG.PSU__CSU__CSU_TAMPER_2__ENABLE {0} \
   CONFIG.PSU__CSU__CSU_TAMPER_2__ERASE_BBRAM {0} \
   CONFIG.PSU__CSU__CSU_TAMPER_3__ENABLE {0} \
   CONFIG.PSU__CSU__CSU_TAMPER_3__ERASE_BBRAM {0} \
   CONFIG.PSU__CSU__CSU_TAMPER_4__ENABLE {0} \
   CONFIG.PSU__CSU__CSU_TAMPER_4__ERASE_BBRAM {0} \
   CONFIG.PSU__CSU__CSU_TAMPER_5__ENABLE {0} \
   CONFIG.PSU__CSU__CSU_TAMPER_5__ERASE_BBRAM {0} \
   CONFIG.PSU__CSU__CSU_TAMPER_6__ENABLE {0} \
   CONFIG.PSU__CSU__CSU_TAMPER_6__ERASE_BBRAM {0} \
   CONFIG.PSU__CSU__CSU_TAMPER_7__ENABLE {0} \
   CONFIG.PSU__CSU__CSU_TAMPER_7__ERASE_BBRAM {0} \
   CONFIG.PSU__CSU__CSU_TAMPER_8__ENABLE {0} \
   CONFIG.PSU__CSU__CSU_TAMPER_8__ERASE_BBRAM {0} \
   CONFIG.PSU__CSU__CSU_TAMPER_9__ENABLE {0} \
   CONFIG.PSU__CSU__CSU_TAMPER_9__ERASE_BBRAM {0} \
   CONFIG.PSU__CSU__PERIPHERAL__ENABLE {0} \
   CONFIG.PSU__DDRC__ADDR_MIRROR {0} \
   CONFIG.PSU__DDRC__AL {0} \
   CONFIG.PSU__DDRC__BANK_ADDR_COUNT {2} \
   CONFIG.PSU__DDRC__BG_ADDR_COUNT {1} \
   CONFIG.PSU__DDRC__BRC_MAPPING {ROW_BANK_COL} \
   CONFIG.PSU__DDRC__BUS_WIDTH {64 Bit} \
   CONFIG.PSU__DDRC__CL {18} \
   CONFIG.PSU__DDRC__CLOCK_STOP_EN {0} \
   CONFIG.PSU__DDRC__COL_ADDR_COUNT {10} \
   CONFIG.PSU__DDRC__COMPONENTS {Components} \
   CONFIG.PSU__DDRC__CWL {16} \
   CONFIG.PSU__DDRC__DDR3L_T_REF_RANGE {NA} \
   CONFIG.PSU__DDRC__DDR3_T_REF_RANGE {NA} \
   CONFIG.PSU__DDRC__DDR4_ADDR_MAPPING {0} \
   CONFIG.PSU__DDRC__DDR4_CAL_MODE_ENABLE {0} \
   CONFIG.PSU__DDRC__DDR4_CRC_CONTROL {0} \
   CONFIG.PSU__DDRC__DDR4_MAXPWR_SAVING_EN {0} \
   CONFIG.PSU__DDRC__DDR4_T_REF_MODE {0} \
   CONFIG.PSU__DDRC__DDR4_T_REF_RANGE {Normal (0-85)} \
   CONFIG.PSU__DDRC__DEEP_PWR_DOWN_EN {0} \
   CONFIG.PSU__DDRC__DEVICE_CAPACITY {8192 MBits} \
   CONFIG.PSU__DDRC__DIMM_ADDR_MIRROR {0} \
   CONFIG.PSU__DDRC__DM_DBI {DM_NO_DBI} \
   CONFIG.PSU__DDRC__DQMAP_0_3 {0} \
   CONFIG.PSU__DDRC__DQMAP_12_15 {0} \
   CONFIG.PSU__DDRC__DQMAP_16_19 {0} \
   CONFIG.PSU__DDRC__DQMAP_20_23 {0} \
   CONFIG.PSU__DDRC__DQMAP_24_27 {0} \
   CONFIG.PSU__DDRC__DQMAP_28_31 {0} \
   CONFIG.PSU__DDRC__DQMAP_32_35 {0} \
   CONFIG.PSU__DDRC__DQMAP_36_39 {0} \
   CONFIG.PSU__DDRC__DQMAP_40_43 {0} \
   CONFIG.PSU__DDRC__DQMAP_44_47 {0} \
   CONFIG.PSU__DDRC__DQMAP_48_51 {0} \
   CONFIG.PSU__DDRC__DQMAP_4_7 {0} \
   CONFIG.PSU__DDRC__DQMAP_52_55 {0} \
   CONFIG.PSU__DDRC__DQMAP_56_59 {0} \
   CONFIG.PSU__DDRC__DQMAP_60_63 {0} \
   CONFIG.PSU__DDRC__DQMAP_64_67 {0} \
   CONFIG.PSU__DDRC__DQMAP_68_71 {0} \
   CONFIG.PSU__DDRC__DQMAP_8_11 {0} \
   CONFIG.PSU__DDRC__DRAM_WIDTH {16 Bits} \
   CONFIG.PSU__DDRC__ECC {Disabled} \
   CONFIG.PSU__DDRC__ECC_SCRUB {0} \
   CONFIG.PSU__DDRC__ENABLE {1} \
   CONFIG.PSU__DDRC__ENABLE_2T_TIMING {0} \
   CONFIG.PSU__DDRC__ENABLE_DP_SWITCH {0} \
   CONFIG.PSU__DDRC__ENABLE_LP4_HAS_ECC_COMP {0} \
   CONFIG.PSU__DDRC__ENABLE_LP4_SLOWBOOT {0} \
   CONFIG.PSU__DDRC__EN_2ND_CLK {0} \
   CONFIG.PSU__DDRC__FGRM {1X} \
   CONFIG.PSU__DDRC__FREQ_MHZ {1} \
   CONFIG.PSU__DDRC__LPDDR3_DUALRANK_SDP {0} \
   CONFIG.PSU__DDRC__LPDDR3_T_REF_RANGE {NA} \
   CONFIG.PSU__DDRC__LPDDR4_T_REF_RANGE {NA} \
   CONFIG.PSU__DDRC__LP_ASR {manual normal} \
   CONFIG.PSU__DDRC__MEMORY_TYPE {DDR 4} \
   CONFIG.PSU__DDRC__PARITY_ENABLE {0} \
   CONFIG.PSU__DDRC__PER_BANK_REFRESH {0} \
   CONFIG.PSU__DDRC__PHY_DBI_MODE {0} \
   CONFIG.PSU__DDRC__PLL_BYPASS {0} \
   CONFIG.PSU__DDRC__PWR_DOWN_EN {0} \
   CONFIG.PSU__DDRC__RANK_ADDR_COUNT {0} \
   CONFIG.PSU__DDRC__RD_DQS_CENTER {0} \
   CONFIG.PSU__DDRC__ROW_ADDR_COUNT {16} \
   CONFIG.PSU__DDRC__SB_TARGET {15-15-15} \
   CONFIG.PSU__DDRC__SELF_REF_ABORT {0} \
   CONFIG.PSU__DDRC__SPEED_BIN {DDR4_2400P} \
   CONFIG.PSU__DDRC__STATIC_RD_MODE {0} \
   CONFIG.PSU__DDRC__TRAIN_DATA_EYE {1} \
   CONFIG.PSU__DDRC__TRAIN_READ_GATE {1} \
   CONFIG.PSU__DDRC__TRAIN_WRITE_LEVEL {1} \
   CONFIG.PSU__DDRC__T_FAW {30} \
   CONFIG.PSU__DDRC__T_RAS_MIN {32} \
   CONFIG.PSU__DDRC__T_RC {48} \
   CONFIG.PSU__DDRC__T_RCD {18} \
   CONFIG.PSU__DDRC__T_RP {18} \
   CONFIG.PSU__DDRC__VENDOR_PART {OTHERS} \
   CONFIG.PSU__DDRC__VIDEO_BUFFER_SIZE {0} \
   CONFIG.PSU__DDRC__VREF {1} \
   CONFIG.PSU__DDR_HIGH_ADDRESS_GUI_ENABLE {1} \
   CONFIG.PSU__DDR_QOS_ENABLE {0} \
   CONFIG.PSU__DDR_QOS_FIX_HP0_RDQOS {} \
   CONFIG.PSU__DDR_QOS_FIX_HP0_WRQOS {} \
   CONFIG.PSU__DDR_QOS_FIX_HP1_RDQOS {} \
   CONFIG.PSU__DDR_QOS_FIX_HP1_WRQOS {} \
   CONFIG.PSU__DDR_QOS_FIX_HP2_RDQOS {} \
   CONFIG.PSU__DDR_QOS_FIX_HP2_WRQOS {} \
   CONFIG.PSU__DDR_QOS_FIX_HP3_RDQOS {} \
   CONFIG.PSU__DDR_QOS_FIX_HP3_WRQOS {} \
   CONFIG.PSU__DDR_QOS_RD_HPR_THRSHLD {} \
   CONFIG.PSU__DDR_QOS_RD_LPR_THRSHLD {} \
   CONFIG.PSU__DDR_QOS_WR_THRSHLD {} \
   CONFIG.PSU__DDR_SW_REFRESH_ENABLED {1} \
   CONFIG.PSU__DDR__INTERFACE__FREQMHZ {600.000} \
   CONFIG.PSU__DEVICE_TYPE {RFSOC} \
   CONFIG.PSU__DISPLAYPORT__LANE0__ENABLE {0} \
   CONFIG.PSU__DISPLAYPORT__LANE1__ENABLE {0} \
   CONFIG.PSU__DISPLAYPORT__PERIPHERAL__ENABLE {0} \
   CONFIG.PSU__DLL__ISUSED {1} \
   CONFIG.PSU__DPAUX__PERIPHERAL__ENABLE {0} \
   CONFIG.PSU__ENABLE__DDR__REFRESH__SIGNALS {0} \
   CONFIG.PSU__ENET0__FIFO__ENABLE {0} \
   CONFIG.PSU__ENET0__GRP_MDIO__ENABLE {0} \
   CONFIG.PSU__ENET0__PERIPHERAL__ENABLE {0} \
   CONFIG.PSU__ENET0__PTP__ENABLE {0} \
   CONFIG.PSU__ENET0__TSU__ENABLE {0} \
   CONFIG.PSU__ENET1__FIFO__ENABLE {0} \
   CONFIG.PSU__ENET1__GRP_MDIO__ENABLE {0} \
   CONFIG.PSU__ENET1__PERIPHERAL__ENABLE {0} \
   CONFIG.PSU__ENET1__PTP__ENABLE {0} \
   CONFIG.PSU__ENET1__TSU__ENABLE {0} \
   CONFIG.PSU__ENET2__FIFO__ENABLE {0} \
   CONFIG.PSU__ENET2__GRP_MDIO__ENABLE {0} \
   CONFIG.PSU__ENET2__PERIPHERAL__ENABLE {0} \
   CONFIG.PSU__ENET2__PTP__ENABLE {0} \
   CONFIG.PSU__ENET2__TSU__ENABLE {0} \
   CONFIG.PSU__ENET3__FIFO__ENABLE {0} \
   CONFIG.PSU__ENET3__GRP_MDIO__ENABLE {1} \
   CONFIG.PSU__ENET3__GRP_MDIO__IO {MIO 76 .. 77} \
   CONFIG.PSU__ENET3__PERIPHERAL__ENABLE {1} \
   CONFIG.PSU__ENET3__PERIPHERAL__IO {GT Lane3} \
   CONFIG.PSU__ENET3__PTP__ENABLE {0} \
   CONFIG.PSU__ENET3__TSU__ENABLE {0} \
   CONFIG.PSU__EN_AXI_STATUS_PORTS {0} \
   CONFIG.PSU__EN_EMIO_TRACE {0} \
   CONFIG.PSU__EP__IP {0} \
   CONFIG.PSU__EXPAND__CORESIGHT {0} \
   CONFIG.PSU__EXPAND__FPD_SLAVES {0} \
   CONFIG.PSU__EXPAND__GIC {0} \
   CONFIG.PSU__EXPAND__LOWER_LPS_SLAVES {0} \
   CONFIG.PSU__EXPAND__UPPER_LPS_SLAVES {0} \
   CONFIG.PSU__FPDMASTERS_COHERENCY {0} \
   CONFIG.PSU__FPD_SLCR__WDT1__ACT_FREQMHZ {99.999001} \
   CONFIG.PSU__FPD_SLCR__WDT1__FREQMHZ {99.999001} \
   CONFIG.PSU__FPD_SLCR__WDT_CLK_SEL__SELECT {APB} \
   CONFIG.PSU__FPGA_PL0_ENABLE {1} \
   CONFIG.PSU__FPGA_PL1_ENABLE {1} \
   CONFIG.PSU__FPGA_PL2_ENABLE {0} \
   CONFIG.PSU__FPGA_PL3_ENABLE {0} \
   CONFIG.PSU__FP__POWER__ON {1} \
   CONFIG.PSU__FTM__CTI_IN_0 {0} \
   CONFIG.PSU__FTM__CTI_IN_1 {0} \
   CONFIG.PSU__FTM__CTI_IN_2 {0} \
   CONFIG.PSU__FTM__CTI_IN_3 {0} \
   CONFIG.PSU__FTM__CTI_OUT_0 {0} \
   CONFIG.PSU__FTM__CTI_OUT_1 {0} \
   CONFIG.PSU__FTM__CTI_OUT_2 {0} \
   CONFIG.PSU__FTM__CTI_OUT_3 {0} \
   CONFIG.PSU__FTM__GPI {0} \
   CONFIG.PSU__FTM__GPO {0} \
   CONFIG.PSU__GEM0_COHERENCY {0} \
   CONFIG.PSU__GEM0_ROUTE_THROUGH_FPD {0} \
   CONFIG.PSU__GEM1_COHERENCY {0} \
   CONFIG.PSU__GEM1_ROUTE_THROUGH_FPD {0} \
   CONFIG.PSU__GEM2_COHERENCY {0} \
   CONFIG.PSU__GEM2_ROUTE_THROUGH_FPD {0} \
   CONFIG.PSU__GEM3_COHERENCY {0} \
   CONFIG.PSU__GEM3_ROUTE_THROUGH_FPD {0} \
   CONFIG.PSU__GEM3__REF_CLK_FREQ {125} \
   CONFIG.PSU__GEM3__REF_CLK_SEL {Ref Clk3} \
   CONFIG.PSU__GEM__TSU__ENABLE {0} \
   CONFIG.PSU__GEN_IPI_0__MASTER {APU} \
   CONFIG.PSU__GEN_IPI_10__MASTER {NONE} \
   CONFIG.PSU__GEN_IPI_1__MASTER {RPU0} \
   CONFIG.PSU__GEN_IPI_2__MASTER {RPU1} \
   CONFIG.PSU__GEN_IPI_3__MASTER {PMU} \
   CONFIG.PSU__GEN_IPI_4__MASTER {PMU} \
   CONFIG.PSU__GEN_IPI_5__MASTER {PMU} \
   CONFIG.PSU__GEN_IPI_6__MASTER {PMU} \
   CONFIG.PSU__GEN_IPI_7__MASTER {NONE} \
   CONFIG.PSU__GEN_IPI_8__MASTER {NONE} \
   CONFIG.PSU__GEN_IPI_9__MASTER {NONE} \
   CONFIG.PSU__GPIO0_MIO__IO {MIO 0 .. 25} \
   CONFIG.PSU__GPIO0_MIO__PERIPHERAL__ENABLE {1} \
   CONFIG.PSU__GPIO1_MIO__IO {MIO 26 .. 51} \
   CONFIG.PSU__GPIO1_MIO__PERIPHERAL__ENABLE {1} \
   CONFIG.PSU__GPIO2_MIO__IO {MIO 52 .. 77} \
   CONFIG.PSU__GPIO2_MIO__PERIPHERAL__ENABLE {1} \
   CONFIG.PSU__GPIO_EMIO_WIDTH {1} \
   CONFIG.PSU__GPIO_EMIO__PERIPHERAL__ENABLE {0} \
   CONFIG.PSU__GPIO_EMIO__WIDTH {[93:0]} \
   CONFIG.PSU__GPU_PP0__POWER__ON {0} \
   CONFIG.PSU__GPU_PP1__POWER__ON {0} \
   CONFIG.PSU__GT_REF_CLK__FREQMHZ {33.333} \
   CONFIG.PSU__GT__PRE_EMPH_LVL_4 {} \
   CONFIG.PSU__GT__VLT_SWNG_LVL_4 {} \
   CONFIG.PSU__HIGH_ADDRESS__ENABLE {1} \
   CONFIG.PSU__HPM0_FPD__NUM_READ_THREADS {4} \
   CONFIG.PSU__HPM0_FPD__NUM_WRITE_THREADS {4} \
   CONFIG.PSU__HPM0_LPD__NUM_READ_THREADS {4} \
   CONFIG.PSU__HPM0_LPD__NUM_WRITE_THREADS {4} \
   CONFIG.PSU__HPM1_FPD__NUM_READ_THREADS {4} \
   CONFIG.PSU__HPM1_FPD__NUM_WRITE_THREADS {4} \
   CONFIG.PSU__I2C0_LOOP_I2C1__ENABLE {0} \
   CONFIG.PSU__I2C0__GRP_INT__ENABLE {0} \
   CONFIG.PSU__I2C0__PERIPHERAL__ENABLE {1} \
   CONFIG.PSU__I2C0__PERIPHERAL__IO {MIO 30 .. 31} \
   CONFIG.PSU__I2C1__GRP_INT__ENABLE {0} \
   CONFIG.PSU__I2C1__PERIPHERAL__ENABLE {1} \
   CONFIG.PSU__I2C1__PERIPHERAL__IO {MIO 40 .. 41} \
   CONFIG.PSU__IOU_SLCR__IOU_TTC_APB_CLK__TTC0_SEL {APB} \
   CONFIG.PSU__IOU_SLCR__IOU_TTC_APB_CLK__TTC1_SEL {APB} \
   CONFIG.PSU__IOU_SLCR__IOU_TTC_APB_CLK__TTC2_SEL {APB} \
   CONFIG.PSU__IOU_SLCR__IOU_TTC_APB_CLK__TTC3_SEL {APB} \
   CONFIG.PSU__IOU_SLCR__TTC0__ACT_FREQMHZ {100.000000} \
   CONFIG.PSU__IOU_SLCR__TTC0__FREQMHZ {100.000000} \
   CONFIG.PSU__IOU_SLCR__TTC1__ACT_FREQMHZ {100.000000} \
   CONFIG.PSU__IOU_SLCR__TTC1__FREQMHZ {100.000000} \
   CONFIG.PSU__IOU_SLCR__TTC2__ACT_FREQMHZ {100.000000} \
   CONFIG.PSU__IOU_SLCR__TTC2__FREQMHZ {100.000000} \
   CONFIG.PSU__IOU_SLCR__TTC3__ACT_FREQMHZ {100.000000} \
   CONFIG.PSU__IOU_SLCR__TTC3__FREQMHZ {100.000000} \
   CONFIG.PSU__IOU_SLCR__WDT0__ACT_FREQMHZ {99.999001} \
   CONFIG.PSU__IOU_SLCR__WDT0__FREQMHZ {99.999001} \
   CONFIG.PSU__IOU_SLCR__WDT_CLK_SEL__SELECT {APB} \
   CONFIG.PSU__IRQ_P2F_ADMA_CHAN__INT {0} \
   CONFIG.PSU__IRQ_P2F_AIB_AXI__INT {0} \
   CONFIG.PSU__IRQ_P2F_AMS__INT {0} \
   CONFIG.PSU__IRQ_P2F_APM_FPD__INT {0} \
   CONFIG.PSU__IRQ_P2F_APU_COMM__INT {0} \
   CONFIG.PSU__IRQ_P2F_APU_CPUMNT__INT {0} \
   CONFIG.PSU__IRQ_P2F_APU_CTI__INT {0} \
   CONFIG.PSU__IRQ_P2F_APU_EXTERR__INT {0} \
   CONFIG.PSU__IRQ_P2F_APU_IPI__INT {0} \
   CONFIG.PSU__IRQ_P2F_APU_L2ERR__INT {0} \
   CONFIG.PSU__IRQ_P2F_APU_PMU__INT {0} \
   CONFIG.PSU__IRQ_P2F_APU_REGS__INT {0} \
   CONFIG.PSU__IRQ_P2F_ATB_LPD__INT {0} \
   CONFIG.PSU__IRQ_P2F_CLKMON__INT {0} \
   CONFIG.PSU__IRQ_P2F_DDR_SS__INT {0} \
   CONFIG.PSU__IRQ_P2F_DPDMA__INT {0} \
   CONFIG.PSU__IRQ_P2F_EFUSE__INT {0} \
   CONFIG.PSU__IRQ_P2F_ENT3_WAKEUP__INT {0} \
   CONFIG.PSU__IRQ_P2F_ENT3__INT {0} \
   CONFIG.PSU__IRQ_P2F_FPD_APB__INT {0} \
   CONFIG.PSU__IRQ_P2F_FPD_ATB_ERR__INT {0} \
   CONFIG.PSU__IRQ_P2F_FP_WDT__INT {0} \
   CONFIG.PSU__IRQ_P2F_GDMA_CHAN__INT {0} \
   CONFIG.PSU__IRQ_P2F_GPIO__INT {0} \
   CONFIG.PSU__IRQ_P2F_GPU__INT {0} \
   CONFIG.PSU__IRQ_P2F_I2C0__INT {0} \
   CONFIG.PSU__IRQ_P2F_I2C1__INT {0} \
   CONFIG.PSU__IRQ_P2F_LPD_APB__INT {0} \
   CONFIG.PSU__IRQ_P2F_LPD_APM__INT {0} \
   CONFIG.PSU__IRQ_P2F_LP_WDT__INT {0} \
   CONFIG.PSU__IRQ_P2F_OCM_ERR__INT {0} \
   CONFIG.PSU__IRQ_P2F_PCIE_DMA__INT {0} \
   CONFIG.PSU__IRQ_P2F_PCIE_LEGACY__INT {0} \
   CONFIG.PSU__IRQ_P2F_PCIE_MSC__INT {0} \
   CONFIG.PSU__IRQ_P2F_PCIE_MSI__INT {0} \
   CONFIG.PSU__IRQ_P2F_PL_IPI__INT {0} \
   CONFIG.PSU__IRQ_P2F_QSPI__INT {0} \
   CONFIG.PSU__IRQ_P2F_R5_CORE0_ECC_ERR__INT {0} \
   CONFIG.PSU__IRQ_P2F_R5_CORE1_ECC_ERR__INT {0} \
   CONFIG.PSU__IRQ_P2F_RPU_IPI__INT {0} \
   CONFIG.PSU__IRQ_P2F_RPU_PERMON__INT {0} \
   CONFIG.PSU__IRQ_P2F_RTC_ALARM__INT {0} \
   CONFIG.PSU__IRQ_P2F_RTC_SECONDS__INT {0} \
   CONFIG.PSU__IRQ_P2F_SATA__INT {0} \
   CONFIG.PSU__IRQ_P2F_SDIO0_WAKE__INT {0} \
   CONFIG.PSU__IRQ_P2F_SDIO0__INT {0} \
   CONFIG.PSU__IRQ_P2F_SPI0__INT {0} \
   CONFIG.PSU__IRQ_P2F_TTC0__INT0 {0} \
   CONFIG.PSU__IRQ_P2F_TTC0__INT1 {0} \
   CONFIG.PSU__IRQ_P2F_TTC0__INT2 {0} \
   CONFIG.PSU__IRQ_P2F_TTC1__INT0 {0} \
   CONFIG.PSU__IRQ_P2F_TTC1__INT1 {0} \
   CONFIG.PSU__IRQ_P2F_TTC1__INT2 {0} \
   CONFIG.PSU__IRQ_P2F_TTC2__INT0 {0} \
   CONFIG.PSU__IRQ_P2F_TTC2__INT1 {0} \
   CONFIG.PSU__IRQ_P2F_TTC2__INT2 {0} \
   CONFIG.PSU__IRQ_P2F_TTC3__INT0 {0} \
   CONFIG.PSU__IRQ_P2F_TTC3__INT1 {0} \
   CONFIG.PSU__IRQ_P2F_TTC3__INT2 {0} \
   CONFIG.PSU__IRQ_P2F_UART0__INT {0} \
   CONFIG.PSU__IRQ_P2F_UART1__INT {0} \
   CONFIG.PSU__IRQ_P2F_USB3_ENDPOINT__INT0 {0} \
   CONFIG.PSU__IRQ_P2F_USB3_ENDPOINT__INT1 {0} \
   CONFIG.PSU__IRQ_P2F_USB3_OTG__INT0 {0} \
   CONFIG.PSU__IRQ_P2F_USB3_OTG__INT1 {0} \
   CONFIG.PSU__IRQ_P2F_USB3_PMU_WAKEUP__INT {0} \
   CONFIG.PSU__IRQ_P2F_XMPU_FPD__INT {0} \
   CONFIG.PSU__IRQ_P2F_XMPU_LPD__INT {0} \
   CONFIG.PSU__IRQ_P2F__INTF_FPD_SMMU__INT {0} \
   CONFIG.PSU__IRQ_P2F__INTF_PPD_CCI__INT {0} \
   CONFIG.PSU__L2_BANK0__POWER__ON {1} \
   CONFIG.PSU__LPDMA0_COHERENCY {0} \
   CONFIG.PSU__LPDMA1_COHERENCY {0} \
   CONFIG.PSU__LPDMA2_COHERENCY {0} \
   CONFIG.PSU__LPDMA3_COHERENCY {0} \
   CONFIG.PSU__LPDMA4_COHERENCY {0} \
   CONFIG.PSU__LPDMA5_COHERENCY {0} \
   CONFIG.PSU__LPDMA6_COHERENCY {0} \
   CONFIG.PSU__LPDMA7_COHERENCY {0} \
   CONFIG.PSU__LPD_SLCR__CSUPMU_WDT_CLK_SEL__SELECT {APB} \
   CONFIG.PSU__LPD_SLCR__CSUPMU__ACT_FREQMHZ {100} \
   CONFIG.PSU__LPD_SLCR__CSUPMU__FREQMHZ {100} \
   CONFIG.PSU__MAXIGP0__DATA_WIDTH {128} \
   CONFIG.PSU__MAXIGP1__DATA_WIDTH {128} \
   CONFIG.PSU__MAXIGP2__DATA_WIDTH {128} \
   CONFIG.PSU__M_AXI_GP0_SUPPORTS_NARROW_BURST {1} \
   CONFIG.PSU__M_AXI_GP1_SUPPORTS_NARROW_BURST {1} \
   CONFIG.PSU__M_AXI_GP2_SUPPORTS_NARROW_BURST {1} \
   CONFIG.PSU__NAND_COHERENCY {0} \
   CONFIG.PSU__NAND_ROUTE_THROUGH_FPD {0} \
   CONFIG.PSU__NAND__CHIP_ENABLE__ENABLE {0} \
   CONFIG.PSU__NAND__DATA_STROBE__ENABLE {0} \
   CONFIG.PSU__NAND__PERIPHERAL__ENABLE {0} \
   CONFIG.PSU__NAND__READY0_BUSY__ENABLE {0} \
   CONFIG.PSU__NAND__READY1_BUSY__ENABLE {0} \
   CONFIG.PSU__NAND__READY_BUSY__ENABLE {0} \
   CONFIG.PSU__NUM_FABRIC_RESETS {2} \
   CONFIG.PSU__OCM_BANK0__POWER__ON {1} \
   CONFIG.PSU__OCM_BANK1__POWER__ON {1} \
   CONFIG.PSU__OCM_BANK2__POWER__ON {1} \
   CONFIG.PSU__OCM_BANK3__POWER__ON {1} \
   CONFIG.PSU__OVERRIDE_HPX_QOS {0} \
   CONFIG.PSU__OVERRIDE__BASIC_CLOCK {0} \
   CONFIG.PSU__PCIE__ACS_VIOLAION {0} \
   CONFIG.PSU__PCIE__ACS_VIOLATION {0} \
   CONFIG.PSU__PCIE__AER_CAPABILITY {0} \
   CONFIG.PSU__PCIE__ATOMICOP_EGRESS_BLOCKED {0} \
   CONFIG.PSU__PCIE__BAR0_64BIT {0} \
   CONFIG.PSU__PCIE__BAR0_ENABLE {0} \
   CONFIG.PSU__PCIE__BAR0_PREFETCHABLE {0} \
   CONFIG.PSU__PCIE__BAR0_VAL {0x0} \
   CONFIG.PSU__PCIE__BAR1_64BIT {0} \
   CONFIG.PSU__PCIE__BAR1_ENABLE {0} \
   CONFIG.PSU__PCIE__BAR1_PREFETCHABLE {0} \
   CONFIG.PSU__PCIE__BAR1_VAL {0x0} \
   CONFIG.PSU__PCIE__BAR2_64BIT {0} \
   CONFIG.PSU__PCIE__BAR2_ENABLE {0} \
   CONFIG.PSU__PCIE__BAR2_PREFETCHABLE {0} \
   CONFIG.PSU__PCIE__BAR2_VAL {0x0} \
   CONFIG.PSU__PCIE__BAR3_64BIT {0} \
   CONFIG.PSU__PCIE__BAR3_ENABLE {0} \
   CONFIG.PSU__PCIE__BAR3_PREFETCHABLE {0} \
   CONFIG.PSU__PCIE__BAR3_VAL {0x0} \
   CONFIG.PSU__PCIE__BAR4_64BIT {0} \
   CONFIG.PSU__PCIE__BAR4_ENABLE {0} \
   CONFIG.PSU__PCIE__BAR4_PREFETCHABLE {0} \
   CONFIG.PSU__PCIE__BAR4_VAL {0x0} \
   CONFIG.PSU__PCIE__BAR5_64BIT {0} \
   CONFIG.PSU__PCIE__BAR5_ENABLE {0} \
   CONFIG.PSU__PCIE__BAR5_PREFETCHABLE {0} \
   CONFIG.PSU__PCIE__BAR5_VAL {0x0} \
   CONFIG.PSU__PCIE__CLASS_CODE_BASE {0x06} \
   CONFIG.PSU__PCIE__CLASS_CODE_INTERFACE {0x0} \
   CONFIG.PSU__PCIE__CLASS_CODE_SUB {0x04} \
   CONFIG.PSU__PCIE__CLASS_CODE_VALUE {0x60400} \
   CONFIG.PSU__PCIE__COMPLETER_ABORT {0} \
   CONFIG.PSU__PCIE__COMPLTION_TIMEOUT {0} \
   CONFIG.PSU__PCIE__CORRECTABLE_INT_ERR {0} \
   CONFIG.PSU__PCIE__CRS_SW_VISIBILITY {0} \
   CONFIG.PSU__PCIE__DEVICE_ID {0xD011} \
   CONFIG.PSU__PCIE__DEVICE_PORT_TYPE {Root Port} \
   CONFIG.PSU__PCIE__ECRC_CHECK {0} \
   CONFIG.PSU__PCIE__ECRC_ERR {0} \
   CONFIG.PSU__PCIE__ECRC_GEN {0} \
   CONFIG.PSU__PCIE__EROM_ENABLE {0} \
   CONFIG.PSU__PCIE__EROM_VAL {0x0} \
   CONFIG.PSU__PCIE__FLOW_CONTROL_ERR {0} \
   CONFIG.PSU__PCIE__FLOW_CONTROL_PROTOCOL_ERR {0} \
   CONFIG.PSU__PCIE__HEADER_LOG_OVERFLOW {0} \
   CONFIG.PSU__PCIE__INTX_GENERATION {0} \
   CONFIG.PSU__PCIE__LANE0__ENABLE {1} \
   CONFIG.PSU__PCIE__LANE0__IO {GT Lane0} \
   CONFIG.PSU__PCIE__LANE1__ENABLE {1} \
   CONFIG.PSU__PCIE__LANE1__IO {GT Lane1} \
   CONFIG.PSU__PCIE__LANE2__ENABLE {0} \
   CONFIG.PSU__PCIE__LANE3__ENABLE {0} \
   CONFIG.PSU__PCIE__LINK_SPEED {5.0 Gb/s} \
   CONFIG.PSU__PCIE__MAXIMUM_LINK_WIDTH {x2} \
   CONFIG.PSU__PCIE__MAX_PAYLOAD_SIZE {256 bytes} \
   CONFIG.PSU__PCIE__MC_BLOCKED_TLP {0} \
   CONFIG.PSU__PCIE__MSIX_BAR_INDICATOR {} \
   CONFIG.PSU__PCIE__MSIX_CAPABILITY {0} \
   CONFIG.PSU__PCIE__MSIX_PBA_BAR_INDICATOR {} \
   CONFIG.PSU__PCIE__MSIX_PBA_OFFSET {0} \
   CONFIG.PSU__PCIE__MSIX_TABLE_OFFSET {0} \
   CONFIG.PSU__PCIE__MSIX_TABLE_SIZE {0} \
   CONFIG.PSU__PCIE__MSI_64BIT_ADDR_CAPABLE {0} \
   CONFIG.PSU__PCIE__MSI_CAPABILITY {0} \
   CONFIG.PSU__PCIE__MULTIHEADER {0} \
   CONFIG.PSU__PCIE__PERIPHERAL__ENABLE {1} \
   CONFIG.PSU__PCIE__PERIPHERAL__ENDPOINT_ENABLE {0} \
   CONFIG.PSU__PCIE__PERIPHERAL__ROOTPORT_ENABLE {1} \
   CONFIG.PSU__PCIE__PERIPHERAL__ROOTPORT_IO {MIO 49} \
   CONFIG.PSU__PCIE__PERM_ROOT_ERR_UPDATE {0} \
   CONFIG.PSU__PCIE__RECEIVER_ERR {0} \
   CONFIG.PSU__PCIE__RECEIVER_OVERFLOW {0} \
   CONFIG.PSU__PCIE__REF_CLK_FREQ {100} \
   CONFIG.PSU__PCIE__REF_CLK_SEL {Ref Clk0} \
   CONFIG.PSU__PCIE__RESET__POLARITY {Active Low} \
   CONFIG.PSU__PCIE__REVISION_ID {0x0} \
   CONFIG.PSU__PCIE__SUBSYSTEM_ID {0x7} \
   CONFIG.PSU__PCIE__SUBSYSTEM_VENDOR_ID {0x10EE} \
   CONFIG.PSU__PCIE__SURPRISE_DOWN {0} \
   CONFIG.PSU__PCIE__TLP_PREFIX_BLOCKED {0} \
   CONFIG.PSU__PCIE__UNCORRECTABL_INT_ERR {0} \
   CONFIG.PSU__PCIE__VENDOR_ID {0x10EE} \
   CONFIG.PSU__PJTAG__PERIPHERAL__ENABLE {0} \
   CONFIG.PSU__PL_CLK0_BUF {TRUE} \
   CONFIG.PSU__PL_CLK1_BUF {TRUE} \
   CONFIG.PSU__PL_CLK2_BUF {FALSE} \
   CONFIG.PSU__PL_CLK3_BUF {FALSE} \
   CONFIG.PSU__PL__POWER__ON {1} \
   CONFIG.PSU__PMU_COHERENCY {0} \
   CONFIG.PSU__PMU__AIBACK__ENABLE {0} \
   CONFIG.PSU__PMU__EMIO_GPI__ENABLE {0} \
   CONFIG.PSU__PMU__EMIO_GPO__ENABLE {0} \
   CONFIG.PSU__PMU__GPI0__ENABLE {0} \
   CONFIG.PSU__PMU__GPI1__ENABLE {0} \
   CONFIG.PSU__PMU__GPI2__ENABLE {0} \
   CONFIG.PSU__PMU__GPI3__ENABLE {0} \
   CONFIG.PSU__PMU__GPI4__ENABLE {0} \
   CONFIG.PSU__PMU__GPI5__ENABLE {0} \
   CONFIG.PSU__PMU__GPO0__ENABLE {0} \
   CONFIG.PSU__PMU__GPO1__ENABLE {0} \
   CONFIG.PSU__PMU__GPO2__ENABLE {0} \
   CONFIG.PSU__PMU__GPO3__ENABLE {0} \
   CONFIG.PSU__PMU__GPO4__ENABLE {0} \
   CONFIG.PSU__PMU__GPO5__ENABLE {0} \
   CONFIG.PSU__PMU__PERIPHERAL__ENABLE {0} \
   CONFIG.PSU__PMU__PLERROR__ENABLE {0} \
   CONFIG.PSU__PRESET_APPLIED {0} \
   CONFIG.PSU__PROTECTION__DDR_SEGMENTS {NONE} \
   CONFIG.PSU__PROTECTION__DEBUG {0} \
   CONFIG.PSU__PROTECTION__ENABLE {0} \
   CONFIG.PSU__PROTECTION__FPD_SEGMENTS {SA:0xFD1A0000; SIZE:1280; UNIT:KB; RegionTZ:Secure; WrAllowed:Read/Write; subsystemId:PMU Firmware| SA:0xFD000000; SIZE:64; UNIT:KB; RegionTZ:Secure; WrAllowed:Read/Write; subsystemId:PMU Firmware| SA:0xFD010000; SIZE:64; UNIT:KB; RegionTZ:Secure; WrAllowed:Read/Write; subsystemId:PMU Firmware| SA:0xFD020000; SIZE:64; UNIT:KB; RegionTZ:Secure; WrAllowed:Read/Write; subsystemId:PMU Firmware| SA:0xFD030000; SIZE:64; UNIT:KB; RegionTZ:Secure; WrAllowed:Read/Write; subsystemId:PMU Firmware| SA:0xFD040000; SIZE:64; UNIT:KB; RegionTZ:Secure; WrAllowed:Read/Write; subsystemId:PMU Firmware| SA:0xFD050000; SIZE:64; UNIT:KB; RegionTZ:Secure; WrAllowed:Read/Write; subsystemId:PMU Firmware| SA:0xFD610000; SIZE:512; UNIT:KB; RegionTZ:Secure; WrAllowed:Read/Write; subsystemId:PMU Firmware| SA:0xFD5D0000; SIZE:64; UNIT:KB; RegionTZ:Secure; WrAllowed:Read/Write; subsystemId:PMU Firmware|SA:0xFD1A0000 ; SIZE:1280; UNIT:KB; RegionTZ:Secure ; WrAllowed:Read/Write; subsystemId:Secure Subsystem} \
   CONFIG.PSU__PROTECTION__LOCK_UNUSED_SEGMENTS {0} \
   CONFIG.PSU__PROTECTION__LPD_SEGMENTS {SA:0xFF980000; SIZE:64; UNIT:KB; RegionTZ:Secure; WrAllowed:Read/Write; subsystemId:PMU Firmware| SA:0xFF5E0000; SIZE:2560; UNIT:KB; RegionTZ:Secure; WrAllowed:Read/Write; subsystemId:PMU Firmware| SA:0xFFCC0000; SIZE:64; UNIT:KB; RegionTZ:Secure; WrAllowed:Read/Write; subsystemId:PMU Firmware| SA:0xFF180000; SIZE:768; UNIT:KB; RegionTZ:Secure; WrAllowed:Read/Write; subsystemId:PMU Firmware| SA:0xFF410000; SIZE:640; UNIT:KB; RegionTZ:Secure; WrAllowed:Read/Write; subsystemId:PMU Firmware| SA:0xFFA70000; SIZE:64; UNIT:KB; RegionTZ:Secure; WrAllowed:Read/Write; subsystemId:PMU Firmware| SA:0xFF9A0000; SIZE:64; UNIT:KB; RegionTZ:Secure; WrAllowed:Read/Write; subsystemId:PMU Firmware|SA:0xFF5E0000 ; SIZE:2560; UNIT:KB; RegionTZ:Secure ; WrAllowed:Read/Write; subsystemId:Secure Subsystem|SA:0xFFCC0000 ; SIZE:64; UNIT:KB; RegionTZ:Secure ; WrAllowed:Read/Write; subsystemId:Secure Subsystem|SA:0xFF180000 ; SIZE:768; UNIT:KB; RegionTZ:Secure ; WrAllowed:Read/Write; subsystemId:Secure Subsystem|SA:0xFF9A0000 ; SIZE:64; UNIT:KB; RegionTZ:Secure ; WrAllowed:Read/Write; subsystemId:Secure Subsystem} \
   CONFIG.PSU__PROTECTION__MASTERS {USB1:NonSecure;0|USB0:NonSecure;1|S_AXI_LPD:NA;0|S_AXI_HPC1_FPD:NA;1|S_AXI_HPC0_FPD:NA;1|S_AXI_HP3_FPD:NA;0|S_AXI_HP2_FPD:NA;0|S_AXI_HP1_FPD:NA;0|S_AXI_HP0_FPD:NA;0|S_AXI_ACP:NA;0|S_AXI_ACE:NA;0|SD1:NonSecure;0|SD0:NonSecure;1|SATA1:NonSecure;0|SATA0:NonSecure;0|RPU1:Secure;1|RPU0:Secure;1|QSPI:NonSecure;1|PMU:NA;1|PCIe:NonSecure;1|NAND:NonSecure;0|LDMA:NonSecure;1|GPU:NonSecure;1|GEM3:NonSecure;1|GEM2:NonSecure;0|GEM1:NonSecure;0|GEM0:NonSecure;0|FDMA:NonSecure;1|DP:NonSecure;0|DAP:NA;1|Coresight:NA;1|CSU:NA;1|APU:NA;1} \
   CONFIG.PSU__PROTECTION__MASTERS_TZ {GEM0:NonSecure|SD1:NonSecure|GEM2:NonSecure|GEM1:NonSecure|GEM3:NonSecure|PCIe:NonSecure|DP:NonSecure|NAND:NonSecure|GPU:NonSecure|USB1:NonSecure|USB0:NonSecure|LDMA:NonSecure|FDMA:NonSecure|QSPI:NonSecure|SD0:NonSecure} \
   CONFIG.PSU__PROTECTION__OCM_SEGMENTS {NONE} \
   CONFIG.PSU__PROTECTION__PRESUBSYSTEMS {NONE} \
   CONFIG.PSU__PROTECTION__SLAVES { \
     LPD;USB3_1_XHCI;FE300000;FE3FFFFF;0|LPD;USB3_1;FF9E0000;FF9EFFFF;0|LPD;USB3_0_XHCI;FE200000;FE2FFFFF;1|LPD;USB3_0;FF9D0000;FF9DFFFF;1|LPD;UART1;FF010000;FF01FFFF;1|LPD;UART0;FF000000;FF00FFFF;1|LPD;TTC3;FF140000;FF14FFFF;1|LPD;TTC2;FF130000;FF13FFFF;1|LPD;TTC1;FF120000;FF12FFFF;1|LPD;TTC0;FF110000;FF11FFFF;1|FPD;SWDT1;FD4D0000;FD4DFFFF;1|LPD;SWDT0;FF150000;FF15FFFF;1|LPD;SPI1;FF050000;FF05FFFF;0|LPD;SPI0;FF040000;FF04FFFF;1|FPD;SMMU_REG;FD5F0000;FD5FFFFF;1|FPD;SMMU;FD800000;FDFFFFFF;1|FPD;SIOU;FD3D0000;FD3DFFFF;1|FPD;SERDES;FD400000;FD47FFFF;1|LPD;SD1;FF170000;FF17FFFF;0|LPD;SD0;FF160000;FF16FFFF;1|FPD;SATA;FD0C0000;FD0CFFFF;0|LPD;RTC;FFA60000;FFA6FFFF;1|LPD;RSA_CORE;FFCE0000;FFCEFFFF;1|LPD;RPU;FF9A0000;FF9AFFFF;1|LPD;R5_TCM_RAM_GLOBAL;FFE00000;FFE3FFFF;1|LPD;R5_1_Instruction_Cache;FFEC0000;FFECFFFF;1|LPD;R5_1_Data_Cache;FFED0000;FFEDFFFF;1|LPD;R5_1_BTCM_GLOBAL;FFEB0000;FFEBFFFF;1|LPD;R5_1_ATCM_GLOBAL;FFE90000;FFE9FFFF;1|LPD;R5_0_Instruction_Cache;FFE40000;FFE4FFFF;1|LPD;R5_0_Data_Cache;FFE50000;FFE5FFFF;1|LPD;R5_0_BTCM_GLOBAL;FFE20000;FFE2FFFF;1|LPD;R5_0_ATCM_GLOBAL;FFE00000;FFE0FFFF;1|LPD;QSPI_Linear_Address;C0000000;DFFFFFFF;1|LPD;QSPI;FF0F0000;FF0FFFFF;1|LPD;PMU_RAM;FFDC0000;FFDDFFFF;1|LPD;PMU_GLOBAL;FFD80000;FFDBFFFF;1|FPD;PCIE_MAIN;FD0E0000;FD0EFFFF;1|FPD;PCIE_LOW;E0000000;EFFFFFFF;1|FPD;PCIE_HIGH2;8000000000;BFFFFFFFFF;1|FPD;PCIE_HIGH1;600000000;7FFFFFFFF;1|FPD;PCIE_DMA;FD0F0000;FD0FFFFF;1|FPD;PCIE_ATTRIB;FD480000;FD48FFFF;1|LPD;OCM_XMPU_CFG;FFA70000;FFA7FFFF;1|LPD;OCM_SLCR;FF960000;FF96FFFF;1|OCM;OCM;FFFC0000;FFFFFFFF;1|LPD;NAND;FF100000;FF10FFFF;0|LPD;MBISTJTAG;FFCF0000;FFCFFFFF;1|LPD;LPD_XPPU_SINK;FF9C0000;FF9CFFFF;1|LPD;LPD_XPPU;FF980000;FF98FFFF;1|LPD;LPD_SLCR_SECURE;FF4B0000;FF4DFFFF;1|LPD;LPD_SLCR;FF410000;FF4AFFFF;1|LPD;LPD_GPV;FE100000;FE1FFFFF;1|LPD;LPD_DMA_7;FFAF0000;FFAFFFFF;1|LPD;LPD_DMA_6;FFAE0000;FFAEFFFF;1|LPD;LPD_DMA_5;FFAD0000;FFADFFFF;1|LPD;LPD_DMA_4;FFAC0000;FFACFFFF;1|LPD;LPD_DMA_3;FFAB0000;FFABFFFF;1|LPD;LPD_DMA_2;FFAA0000;FFAAFFFF;1|LPD;LPD_DMA_1;FFA90000;FFA9FFFF;1|LPD;LPD_DMA_0;FFA80000;FFA8FFFF;1|LPD;IPI_CTRL;FF380000;FF3FFFFF;1|LPD;IOU_SLCR;FF180000;FF23FFFF;1|LPD;IOU_SECURE_SLCR;FF240000;FF24FFFF;1|LPD;IOU_SCNTRS;FF260000;FF26FFFF;1|LPD;IOU_SCNTR;FF250000;FF25FFFF;1|LPD;IOU_GPV;FE000000;FE0FFFFF;1|LPD;I2C1;FF030000;FF03FFFF;1|LPD;I2C0;FF020000;FF02FFFF;1|FPD;GPU;FD4B0000;FD4BFFFF;0|LPD;GPIO;FF0A0000;FF0AFFFF;1|LPD;GEM3;FF0E0000;FF0EFFFF;1|LPD;GEM2;FF0D0000;FF0DFFFF;0|LPD;GEM1;FF0C0000;FF0CFFFF;0|LPD;GEM0;FF0B0000;FF0BFFFF;0|FPD;FPD_XMPU_SINK;FD4F0000;FD4FFFFF;1|FPD;FPD_XMPU_CFG;FD5D0000;FD5DFFFF;1|FPD;FPD_SLCR_SECURE;FD690000;FD6CFFFF;1|FPD;FPD_SLCR;FD610000;FD68FFFF;1|FPD;FPD_DMA_CH7;FD570000;FD57FFFF;1|FPD;FPD_DMA_CH6;FD560000;FD56FFFF;1|FPD;FPD_DMA_CH5;FD550000;FD55FFFF;1|FPD;FPD_DMA_CH4;FD540000;FD54FFFF;1|FPD;FPD_DMA_CH3;FD530000;FD53FFFF;1|FPD;FPD_DMA_CH2;FD520000;FD52FFFF;1|FPD;FPD_DMA_CH1;FD510000;FD51FFFF;1|FPD;FPD_DMA_CH0;FD500000;FD50FFFF;1|LPD;EFUSE;FFCC0000;FFCCFFFF;1|FPD;Display Port;FD4A0000;FD4AFFFF;0|FPD;DPDMA;FD4C0000;FD4CFFFF;0|FPD;DDR_XMPU5_CFG;FD050000;FD05FFFF;1|FPD;DDR_XMPU4_CFG;FD040000;FD04FFFF;1|FPD;DDR_XMPU3_CFG;FD030000;FD03FFFF;1|FPD;DDR_XMPU2_CFG;FD020000;FD02FFFF;1|FPD;DDR_XMPU1_CFG;FD010000;FD01FFFF;1|FPD;DDR_XMPU0_CFG;FD000000;FD00FFFF;1|FPD;DDR_QOS_CTRL;FD090000;FD09FFFF;1|FPD;DDR_PHY;FD080000;FD08FFFF;1|DDR;DDR_LOW;0;7FFFFFFF;1|DDR;DDR_HIGH;800000000;87FFFFFFF;1|FPD;DDDR_CTRL;FD070000;FD070FFF;1|LPD;Coresight;FE800000;FEFFFFFF;1|LPD;CSU_DMA;FFC80000;FFC9FFFF;1|LPD;CSU;FFCA0000;FFCAFFFF;1|LPD;CRL_APB;FF5E0000;FF85FFFF;1|FPD;CRF_APB;FD1A0000;FD2DFFFF;1|FPD;CCI_REG;FD5E0000;FD5EFFFF;1|LPD;CAN1;FF070000;FF07FFFF;0|LPD;CAN0;FF060000;FF06FFFF;0|FPD;APU;FD5C0000;FD5CFFFF;1|LPD;APM_INTC_IOU;FFA20000;FFA2FFFF;1|LPD;APM_FPD_LPD;FFA30000;FFA3FFFF;1|FPD;APM_5;FD490000;FD49FFFF;1|FPD;APM_0;FD0B0000;FD0BFFFF;1|LPD;APM2;FFA10000;FFA1FFFF;1|LPD;APM1;FFA00000;FFA0FFFF;1|LPD;AMS;FFA50000;FFA5FFFF;1|FPD;AFI_5;FD3B0000;FD3BFFFF;1|FPD;AFI_4;FD3A0000;FD3AFFFF;1|FPD;AFI_3;FD390000;FD39FFFF;1|FPD;AFI_2;FD380000;FD38FFFF;1|FPD;AFI_1;FD370000;FD37FFFF;1|FPD;AFI_0;FD360000;FD36FFFF;1|LPD;AFIFM6;FF9B0000;FF9BFFFF;1|FPD;ACPU_GIC;F9010000;F907FFFF;1 \
   } \
   CONFIG.PSU__PROTECTION__SUBSYSTEMS {PMU Firmware:PMU|Secure Subsystem:} \
   CONFIG.PSU__PSS_ALT_REF_CLK__ENABLE {0} \
   CONFIG.PSU__PSS_ALT_REF_CLK__FREQMHZ {33.333} \
   CONFIG.PSU__PSS_REF_CLK__FREQMHZ {33.333} \
   CONFIG.PSU__QSPI_COHERENCY {0} \
   CONFIG.PSU__QSPI_ROUTE_THROUGH_FPD {0} \
   CONFIG.PSU__QSPI__GRP_FBCLK__ENABLE {0} \
   CONFIG.PSU__QSPI__PERIPHERAL__DATA_MODE {x4} \
   CONFIG.PSU__QSPI__PERIPHERAL__ENABLE {1} \
   CONFIG.PSU__QSPI__PERIPHERAL__IO {MIO 0 .. 5} \
   CONFIG.PSU__QSPI__PERIPHERAL__MODE {Single} \
   CONFIG.PSU__REPORT__DBGLOG {0} \
   CONFIG.PSU__RPU_COHERENCY {0} \
   CONFIG.PSU__RPU__POWER__ON {1} \
   CONFIG.PSU__SATA__LANE0__ENABLE {0} \
   CONFIG.PSU__SATA__LANE1__ENABLE {0} \
   CONFIG.PSU__SATA__PERIPHERAL__ENABLE {0} \
   CONFIG.PSU__SAXIGP0__DATA_WIDTH {128} \
   CONFIG.PSU__SAXIGP1__DATA_WIDTH {128} \
   CONFIG.PSU__SD0_COHERENCY {0} \
   CONFIG.PSU__SD0_ROUTE_THROUGH_FPD {0} \
   CONFIG.PSU__SD0__DATA_TRANSFER_MODE {8Bit} \
   CONFIG.PSU__SD0__GRP_CD__ENABLE {0} \
   CONFIG.PSU__SD0__GRP_POW__ENABLE {1} \
   CONFIG.PSU__SD0__GRP_POW__IO {MIO 23} \
   CONFIG.PSU__SD0__GRP_WP__ENABLE {0} \
   CONFIG.PSU__SD0__PERIPHERAL__ENABLE {1} \
   CONFIG.PSU__SD0__PERIPHERAL__IO {MIO 13 .. 22} \
   CONFIG.PSU__SD0__RESET__ENABLE {1} \
   CONFIG.PSU__SD0__SLOT_TYPE {eMMC} \
   CONFIG.PSU__SD1_COHERENCY {0} \
   CONFIG.PSU__SD1_ROUTE_THROUGH_FPD {0} \
   CONFIG.PSU__SD1__GRP_CD__ENABLE {0} \
   CONFIG.PSU__SD1__GRP_POW__ENABLE {0} \
   CONFIG.PSU__SD1__GRP_WP__ENABLE {0} \
   CONFIG.PSU__SD1__PERIPHERAL__ENABLE {0} \
   CONFIG.PSU__SD1__RESET__ENABLE {0} \
   CONFIG.PSU__SPI0_LOOP_SPI1__ENABLE {0} \
   CONFIG.PSU__SPI0__GRP_SS0__ENABLE {1} \
   CONFIG.PSU__SPI0__GRP_SS0__IO {EMIO} \
   CONFIG.PSU__SPI0__GRP_SS1__ENABLE {0} \
   CONFIG.PSU__SPI0__GRP_SS2__ENABLE {0} \
   CONFIG.PSU__SPI0__PERIPHERAL__ENABLE {1} \
   CONFIG.PSU__SPI0__PERIPHERAL__IO {EMIO} \
   CONFIG.PSU__SPI1__GRP_SS0__ENABLE {0} \
   CONFIG.PSU__SPI1__GRP_SS1__ENABLE {0} \
   CONFIG.PSU__SPI1__GRP_SS2__ENABLE {0} \
   CONFIG.PSU__SPI1__PERIPHERAL__ENABLE {0} \
   CONFIG.PSU__SWDT0__CLOCK__ENABLE {0} \
   CONFIG.PSU__SWDT0__PERIPHERAL__ENABLE {1} \
   CONFIG.PSU__SWDT0__PERIPHERAL__IO {NA} \
   CONFIG.PSU__SWDT0__RESET__ENABLE {0} \
   CONFIG.PSU__SWDT1__CLOCK__ENABLE {0} \
   CONFIG.PSU__SWDT1__PERIPHERAL__ENABLE {1} \
   CONFIG.PSU__SWDT1__PERIPHERAL__IO {NA} \
   CONFIG.PSU__SWDT1__RESET__ENABLE {0} \
   CONFIG.PSU__TCM0A__POWER__ON {1} \
   CONFIG.PSU__TCM0B__POWER__ON {1} \
   CONFIG.PSU__TCM1A__POWER__ON {1} \
   CONFIG.PSU__TCM1B__POWER__ON {1} \
   CONFIG.PSU__TESTSCAN__PERIPHERAL__ENABLE {0} \
   CONFIG.PSU__TRACE__INTERNAL_WIDTH {32} \
   CONFIG.PSU__TRACE__PERIPHERAL__ENABLE {0} \
   CONFIG.PSU__TRISTATE__INVERTED {1} \
   CONFIG.PSU__TSU__BUFG_PORT_PAIR {0} \
   CONFIG.PSU__TTC0__CLOCK__ENABLE {0} \
   CONFIG.PSU__TTC0__PERIPHERAL__ENABLE {1} \
   CONFIG.PSU__TTC0__PERIPHERAL__IO {NA} \
   CONFIG.PSU__TTC0__WAVEOUT__ENABLE {0} \
   CONFIG.PSU__TTC1__CLOCK__ENABLE {0} \
   CONFIG.PSU__TTC1__PERIPHERAL__ENABLE {1} \
   CONFIG.PSU__TTC1__PERIPHERAL__IO {NA} \
   CONFIG.PSU__TTC1__WAVEOUT__ENABLE {0} \
   CONFIG.PSU__TTC2__CLOCK__ENABLE {0} \
   CONFIG.PSU__TTC2__PERIPHERAL__ENABLE {1} \
   CONFIG.PSU__TTC2__PERIPHERAL__IO {NA} \
   CONFIG.PSU__TTC2__WAVEOUT__ENABLE {0} \
   CONFIG.PSU__TTC3__CLOCK__ENABLE {0} \
   CONFIG.PSU__TTC3__PERIPHERAL__ENABLE {1} \
   CONFIG.PSU__TTC3__PERIPHERAL__IO {NA} \
   CONFIG.PSU__TTC3__WAVEOUT__ENABLE {0} \
   CONFIG.PSU__UART0_LOOP_UART1__ENABLE {0} \
   CONFIG.PSU__UART0__BAUD_RATE {115200} \
   CONFIG.PSU__UART0__MODEM__ENABLE {0} \
   CONFIG.PSU__UART0__PERIPHERAL__ENABLE {1} \
   CONFIG.PSU__UART0__PERIPHERAL__IO {MIO 26 .. 27} \
   CONFIG.PSU__UART1__BAUD_RATE {115200} \
   CONFIG.PSU__UART1__MODEM__ENABLE {0} \
   CONFIG.PSU__UART1__PERIPHERAL__ENABLE {1} \
   CONFIG.PSU__UART1__PERIPHERAL__IO {EMIO} \
   CONFIG.PSU__USB0_COHERENCY {0} \
   CONFIG.PSU__USB0__PERIPHERAL__ENABLE {1} \
   CONFIG.PSU__USB0__PERIPHERAL__IO {MIO 52 .. 63} \
   CONFIG.PSU__USB0__REF_CLK_FREQ {26} \
   CONFIG.PSU__USB0__REF_CLK_SEL {Ref Clk2} \
   CONFIG.PSU__USB0__RESET__ENABLE {0} \
   CONFIG.PSU__USB1_COHERENCY {0} \
   CONFIG.PSU__USB1__PERIPHERAL__ENABLE {0} \
   CONFIG.PSU__USB1__RESET__ENABLE {0} \
   CONFIG.PSU__USB2_0__EMIO__ENABLE {0} \
   CONFIG.PSU__USB2_1__EMIO__ENABLE {0} \
   CONFIG.PSU__USB3_0__EMIO__ENABLE {0} \
   CONFIG.PSU__USB3_0__PERIPHERAL__ENABLE {1} \
   CONFIG.PSU__USB3_0__PERIPHERAL__IO {GT Lane2} \
   CONFIG.PSU__USB3_1__EMIO__ENABLE {0} \
   CONFIG.PSU__USB3_1__PERIPHERAL__ENABLE {0} \
   CONFIG.PSU__USB__RESET__MODE {Boot Pin} \
   CONFIG.PSU__USB__RESET__POLARITY {Active Low} \
   CONFIG.PSU__USE_DIFF_RW_CLK_GP0 {0} \
   CONFIG.PSU__USE_DIFF_RW_CLK_GP1 {0} \
   CONFIG.PSU__USE__ADMA {0} \
   CONFIG.PSU__USE__APU_LEGACY_INTERRUPT {0} \
   CONFIG.PSU__USE__AUDIO {0} \
   CONFIG.PSU__USE__CLK {0} \
   CONFIG.PSU__USE__CLK0 {0} \
   CONFIG.PSU__USE__CLK1 {0} \
   CONFIG.PSU__USE__CLK2 {0} \
   CONFIG.PSU__USE__CLK3 {0} \
   CONFIG.PSU__USE__CROSS_TRIGGER {0} \
   CONFIG.PSU__USE__DDR_INTF_REQUESTED {0} \
   CONFIG.PSU__USE__DEBUG__TEST {0} \
   CONFIG.PSU__USE__EVENT_RPU {0} \
   CONFIG.PSU__USE__FABRIC__RST {1} \
   CONFIG.PSU__USE__FTM {0} \
   CONFIG.PSU__USE__GDMA {0} \
   CONFIG.PSU__USE__IRQ {0} \
   CONFIG.PSU__USE__IRQ0 {1} \
   CONFIG.PSU__USE__IRQ1 {1} \
   CONFIG.PSU__USE__M_AXI_GP0 {1} \
   CONFIG.PSU__USE__M_AXI_GP1 {1} \
   CONFIG.PSU__USE__M_AXI_GP2 {1} \
   CONFIG.PSU__USE__PROC_EVENT_BUS {0} \
   CONFIG.PSU__USE__RPU_LEGACY_INTERRUPT {0} \
   CONFIG.PSU__USE__RST0 {0} \
   CONFIG.PSU__USE__RST1 {0} \
   CONFIG.PSU__USE__RST2 {0} \
   CONFIG.PSU__USE__RST3 {0} \
   CONFIG.PSU__USE__RTC {0} \
   CONFIG.PSU__USE__STM {0} \
   CONFIG.PSU__USE__S_AXI_ACE {0} \
   CONFIG.PSU__USE__S_AXI_ACP {0} \
   CONFIG.PSU__USE__S_AXI_GP0 {1} \
   CONFIG.PSU__USE__S_AXI_GP1 {1} \
   CONFIG.PSU__USE__S_AXI_GP2 {0} \
   CONFIG.PSU__USE__S_AXI_GP3 {0} \
   CONFIG.PSU__USE__S_AXI_GP4 {0} \
   CONFIG.PSU__USE__S_AXI_GP5 {0} \
   CONFIG.PSU__USE__S_AXI_GP6 {0} \
   CONFIG.PSU__USE__USB3_0_HUB {0} \
   CONFIG.PSU__USE__USB3_1_HUB {0} \
   CONFIG.PSU__USE__VIDEO {0} \
   CONFIG.PSU__VIDEO_REF_CLK__ENABLE {0} \
   CONFIG.PSU__VIDEO_REF_CLK__FREQMHZ {33.333} \
   CONFIG.QSPI_BOARD_INTERFACE {custom} \
   CONFIG.SATA_BOARD_INTERFACE {custom} \
   CONFIG.SD0_BOARD_INTERFACE {custom} \
   CONFIG.SD1_BOARD_INTERFACE {custom} \
   CONFIG.SPI0_BOARD_INTERFACE {custom} \
   CONFIG.SPI1_BOARD_INTERFACE {custom} \
   CONFIG.SUBPRESET1 {Custom} \
   CONFIG.SUBPRESET2 {Custom} \
   CONFIG.SWDT0_BOARD_INTERFACE {custom} \
   CONFIG.SWDT1_BOARD_INTERFACE {custom} \
   CONFIG.TRACE_BOARD_INTERFACE {custom} \
   CONFIG.TTC0_BOARD_INTERFACE {custom} \
   CONFIG.TTC1_BOARD_INTERFACE {custom} \
   CONFIG.TTC2_BOARD_INTERFACE {custom} \
   CONFIG.TTC3_BOARD_INTERFACE {custom} \
   CONFIG.UART0_BOARD_INTERFACE {custom} \
   CONFIG.UART1_BOARD_INTERFACE {custom} \
   CONFIG.USB0_BOARD_INTERFACE {custom} \
   CONFIG.USB1_BOARD_INTERFACE {custom} \
   CONFIG.preset {None} \
 ] $zynq_ultra_ps_e_0

  # Create interface connections
  connect_bd_intf_net -intf_net BRAM_PORTB_0_1 [get_bd_intf_ports AUXRAM] [get_bd_intf_pins blkmem0/BRAM_PORTB]
  connect_bd_intf_net -intf_net S00_AXI_1 [get_bd_intf_pins hpm_inter/S00_AXI] [get_bd_intf_pins zynq_ultra_ps_e_0/M_AXI_HPM0_LPD]
  connect_bd_intf_net -intf_net S00_AXI_2 [get_bd_intf_pins fpm0inter/S00_AXI] [get_bd_intf_pins zynq_ultra_ps_e_0/M_AXI_HPM0_FPD]
  connect_bd_intf_net -intf_net S01_AXI_0_1 [get_bd_intf_ports mem_axi] [get_bd_intf_pins mem/mem_axi]
  connect_bd_intf_net -intf_net S02_AXI_0_1 [get_bd_intf_ports deepfifo_axi] [get_bd_intf_pins mem/deepfifo_axi]
  connect_bd_intf_net -intf_net S_AXIS_S2MM_0_1 [get_bd_intf_ports S_DMA_AXIS] [get_bd_intf_pins axi_dma_0/S_AXIS_S2MM]
  connect_bd_intf_net -intf_net S_AXI_HPC1_FPD_0_1 [get_bd_intf_ports S_AXI_HPC1] [get_bd_intf_pins zynq_ultra_ps_e_0/S_AXI_HPC1_FPD]
  connect_bd_intf_net -intf_net adc0_clk_1 [get_bd_intf_ports adc0_clk] [get_bd_intf_pins rfdc4x4/adc0_clk]
  connect_bd_intf_net -intf_net adc0_dsa_rts_0_1 [get_bd_intf_ports adc0_dsa_rts] [get_bd_intf_pins rfdc4x4/adc0_dsa_rts]
  connect_bd_intf_net -intf_net adc0_rts_0_1 [get_bd_intf_ports adc0_rts] [get_bd_intf_pins rfdc4x4/adc0_rts]
  connect_bd_intf_net -intf_net adc1_clk_0_1 [get_bd_intf_ports adc1_clk] [get_bd_intf_pins rfdc4x4/adc1_clk]
  connect_bd_intf_net -intf_net adc1_dsa_rts_0_1 [get_bd_intf_ports adc1_dsa_rts] [get_bd_intf_pins rfdc4x4/adc1_dsa_rts]
  connect_bd_intf_net -intf_net adc1_rts_0_1 [get_bd_intf_ports adc1_rts] [get_bd_intf_pins rfdc4x4/adc1_rts]
  connect_bd_intf_net -intf_net axi_bram_ctrl_0_BRAM_PORTA [get_bd_intf_pins blkmem0/BRAM_PORTA] [get_bd_intf_pins bram0/BRAM_PORTA]
  connect_bd_intf_net -intf_net axi_dma_0_M_AXI [get_bd_intf_pins axi_dma_0/M_AXI] [get_bd_intf_pins smartconnect_0/S01_AXI]
  connect_bd_intf_net -intf_net axi_dma_0_M_AXIS_MM2S [get_bd_intf_ports M_DMA_AXIS] [get_bd_intf_pins axi_dma_0/M_AXIS_MM2S]
  connect_bd_intf_net -intf_net axi_dma_0_M_AXI_SG [get_bd_intf_pins axi_dma_0/M_AXI_SG] [get_bd_intf_pins smartconnect_0/S00_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_0_M00_AXI [get_bd_intf_pins bram0/S_AXI] [get_bd_intf_pins hpm_inter/M00_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_0_M01_AXI [get_bd_intf_pins axi_dma_0/S_AXI_LITE] [get_bd_intf_pins hpm_inter/M01_AXI]
  connect_bd_intf_net -intf_net dac0_clk_0_1 [get_bd_intf_ports dac0_clk] [get_bd_intf_pins rfdc4x4/dac0_clk]
  connect_bd_intf_net -intf_net fpm0inter_M02_AXI [get_bd_intf_pins fpm0inter/M02_AXI] [get_bd_intf_pins mem/s_axi]
  connect_bd_intf_net -intf_net hpm_inter_M02_AXI [get_bd_intf_pins axilite_dma/S00_AXI] [get_bd_intf_pins hpm_inter/M02_AXI]
  connect_bd_intf_net -intf_net hpm_inter_M03_AXI [get_bd_intf_pins axi_bram/S_AXI] [get_bd_intf_pins hpm_inter/M03_AXI]
  connect_bd_intf_net -intf_net hpm_inter_M04_AXI [get_bd_intf_ports app_lite] [get_bd_intf_pins hpm_inter/M04_AXI]
  connect_bd_intf_net -intf_net hpm_inter_M05_AXI [get_bd_intf_pins hpm_inter/M05_AXI] [get_bd_intf_pins rfdc4x4/s_axi]
  connect_bd_intf_net -intf_net hpm_inter_M06_AXI [get_bd_intf_pins hpm_inter/M06_AXI] [get_bd_intf_pins sysmon/S_AXI_LITE]
  connect_bd_intf_net -intf_net hpm_inter_M07_AXI [get_bd_intf_pins axi_uart16550_0/S_AXI] [get_bd_intf_pins hpm_inter/M07_AXI]
  connect_bd_intf_net -intf_net hpm_inter_M08_AXI [get_bd_intf_pins axi_uart16550_1/S_AXI] [get_bd_intf_pins hpm_inter/M08_AXI]
  connect_bd_intf_net -intf_net mem_DDR4 [get_bd_intf_ports DDR4] [get_bd_intf_pins mem/DDR4]
  connect_bd_intf_net -intf_net rfdc4x4_m00_axis [get_bd_intf_ports m00_axis] [get_bd_intf_pins rfdc4x4/m00_axis]
  connect_bd_intf_net -intf_net rfdc4x4_m01_axis [get_bd_intf_ports m01_axis] [get_bd_intf_pins rfdc4x4/m01_axis]
  connect_bd_intf_net -intf_net rfdc4x4_m02_axis [get_bd_intf_ports m02_axis] [get_bd_intf_pins rfdc4x4/m02_axis]
  connect_bd_intf_net -intf_net rfdc4x4_m03_axis [get_bd_intf_ports m03_axis] [get_bd_intf_pins rfdc4x4/m03_axis]
  connect_bd_intf_net -intf_net rfdc4x4_m10_axis [get_bd_intf_ports m10_axis] [get_bd_intf_pins rfdc4x4/m10_axis]
  connect_bd_intf_net -intf_net rfdc4x4_m11_axis [get_bd_intf_ports m11_axis] [get_bd_intf_pins rfdc4x4/m11_axis]
  connect_bd_intf_net -intf_net rfdc4x4_m12_axis [get_bd_intf_ports m12_axis] [get_bd_intf_pins rfdc4x4/m12_axis]
  connect_bd_intf_net -intf_net rfdc4x4_m13_axis [get_bd_intf_ports m13_axis] [get_bd_intf_pins rfdc4x4/m13_axis]
  connect_bd_intf_net -intf_net rfdc4x4_vout00 [get_bd_intf_ports vout00] [get_bd_intf_pins rfdc4x4/vout00]
  connect_bd_intf_net -intf_net rfdc4x4_vout02 [get_bd_intf_ports vout02] [get_bd_intf_pins rfdc4x4/vout02]
  connect_bd_intf_net -intf_net rfdc4x4_vout10 [get_bd_intf_ports vout10] [get_bd_intf_pins rfdc4x4/vout10]
  connect_bd_intf_net -intf_net rfdc4x4_vout12 [get_bd_intf_ports vout12] [get_bd_intf_pins rfdc4x4/vout12]
  connect_bd_intf_net -intf_net s00_axis_0_1 [get_bd_intf_ports s00_axis] [get_bd_intf_pins rfdc4x4/s00_axis]
  connect_bd_intf_net -intf_net s02_axis_0_1 [get_bd_intf_ports s02_axis] [get_bd_intf_pins rfdc4x4/s02_axis]
  connect_bd_intf_net -intf_net s10_axis_0_1 [get_bd_intf_ports s10_axis] [get_bd_intf_pins rfdc4x4/s10_axis]
  connect_bd_intf_net -intf_net s12_axis_0_1 [get_bd_intf_ports s12_axis] [get_bd_intf_pins rfdc4x4/s12_axis]
  connect_bd_intf_net -intf_net smartconnect_0_M00_AXI [get_bd_intf_pins smartconnect_0/M00_AXI] [get_bd_intf_pins zynq_ultra_ps_e_0/S_AXI_HPC0_FPD]
  connect_bd_intf_net -intf_net sysref_in_0_1 [get_bd_intf_ports sysref_in] [get_bd_intf_pins rfdc4x4/sysref_in]
  connect_bd_intf_net -intf_net vin0_01_0_1 [get_bd_intf_ports vin0_01] [get_bd_intf_pins rfdc4x4/vin0_01]
  connect_bd_intf_net -intf_net vin0_23_0_1 [get_bd_intf_ports vin0_23] [get_bd_intf_pins rfdc4x4/vin0_23]
  connect_bd_intf_net -intf_net vin1_01_0_1 [get_bd_intf_ports vin1_01] [get_bd_intf_pins rfdc4x4/vin1_01]
  connect_bd_intf_net -intf_net vin1_23_0_1 [get_bd_intf_ports vin1_23] [get_bd_intf_pins rfdc4x4/vin1_23]
  connect_bd_intf_net -intf_net zynq_ultra_ps_e_0_SPI_0 [get_bd_intf_ports SPI0] [get_bd_intf_pins zynq_ultra_ps_e_0/SPI_0]
  connect_bd_intf_net -intf_net zynq_ultra_ps_e_0_UART_1 [get_bd_intf_ports PLUART] [get_bd_intf_pins zynq_ultra_ps_e_0/UART_1]

  # Create port connections
  connect_bd_net -net ARESETN_1 [get_bd_ports pl_resetn0] [get_bd_pins axi_bram/s_axi_aresetn] [get_bd_pins axi_uart16550_0/s_axi_aresetn] [get_bd_pins axi_uart16550_1/s_axi_aresetn] [get_bd_pins axilite_dma/s00_axi_aresetn] [get_bd_pins bram0/s_axi_aresetn] [get_bd_pins fpm0inter/ARESETN] [get_bd_pins fpm0inter/M00_ARESETN] [get_bd_pins fpm0inter/M01_ARESETN] [get_bd_pins fpm0inter/M02_ARESETN] [get_bd_pins fpm0inter/S00_ARESETN] [get_bd_pins hpm_inter/ARESETN] [get_bd_pins hpm_inter/M00_ARESETN] [get_bd_pins hpm_inter/M02_ARESETN] [get_bd_pins hpm_inter/M03_ARESETN] [get_bd_pins hpm_inter/M04_ARESETN] [get_bd_pins hpm_inter/M05_ARESETN] [get_bd_pins hpm_inter/M06_ARESETN] [get_bd_pins hpm_inter/M07_ARESETN] [get_bd_pins hpm_inter/M08_ARESETN] [get_bd_pins hpm_inter/S00_ARESETN] [get_bd_pins mem/s_axi_aresetn] [get_bd_pins proc_sys_reset_0/peripheral_aresetn] [get_bd_pins rfdc4x4/s_axi_aresetn] [get_bd_pins smartconnect_0/aresetn] [get_bd_pins sysmon/s_axi_aresetn]
  connect_bd_net -net acprot_1 [get_bd_ports axprot] [get_bd_pins zynq_ultra_ps_e_0/saxigp0_arprot] [get_bd_pins zynq_ultra_ps_e_0/saxigp0_awprot] [get_bd_pins zynq_ultra_ps_e_0/saxigp1_arprot] [get_bd_pins zynq_ultra_ps_e_0/saxigp1_awprot]
  connect_bd_net -net adc_clk_1 [get_bd_ports adc_clk] [get_bd_pins rfdc4x4/m0_axis_aclk] [get_bd_pins rfdc4x4/m1_axis_aclk] [get_bd_pins rfdc4x4/m2_axis_aclk] [get_bd_pins rfdc4x4/m3_axis_aclk]
  connect_bd_net -net adc_rstn_1 [get_bd_ports adc_rstn] [get_bd_pins rfdc4x4/m0_axis_aresetn] [get_bd_pins rfdc4x4/m1_axis_aresetn] [get_bd_pins rfdc4x4/m2_axis_aresetn] [get_bd_pins rfdc4x4/m3_axis_aresetn]
  connect_bd_net -net app_status0_0_1 [get_bd_ports app_status0] [get_bd_pins axilite_dma/app_status0]
  connect_bd_net -net app_status1_0_1 [get_bd_ports app_status1] [get_bd_pins axilite_dma/app_status1]
  connect_bd_net -net app_status2_0_1 [get_bd_ports app_status2] [get_bd_pins axilite_dma/app_status2]
  connect_bd_net -net app_status3_0_1 [get_bd_ports app_status3] [get_bd_pins axilite_dma/app_status3]
  connect_bd_net -net app_status4_0_1 [get_bd_ports app_status4] [get_bd_pins axilite_dma/app_status4]
  connect_bd_net -net app_status5_0_1 [get_bd_ports app_status5] [get_bd_pins axilite_dma/app_status5]
  connect_bd_net -net app_status6_0_1 [get_bd_ports app_status6] [get_bd_pins axilite_dma/app_status6]
  connect_bd_net -net app_status7_0_1 [get_bd_ports app_status7] [get_bd_pins axilite_dma/app_status7]
  connect_bd_net -net axcache_1 [get_bd_ports axcache] [get_bd_pins zynq_ultra_ps_e_0/saxigp0_arcache] [get_bd_pins zynq_ultra_ps_e_0/saxigp0_awcache] [get_bd_pins zynq_ultra_ps_e_0/saxigp1_arcache] [get_bd_pins zynq_ultra_ps_e_0/saxigp1_awcache]
  connect_bd_net -net axi_bram_ctrl_0_bram_addr_a [get_bd_ports bram_addr] [get_bd_pins axi_bram/bram_addr_a]
  connect_bd_net -net axi_bram_ctrl_0_bram_clk_a [get_bd_ports bram_clk] [get_bd_pins axi_bram/bram_clk_a]
  connect_bd_net -net axi_bram_ctrl_0_bram_en_a [get_bd_ports bram_en] [get_bd_pins axi_bram/bram_en_a]
  connect_bd_net -net axi_bram_ctrl_0_bram_rst_a [get_bd_ports bram_rst] [get_bd_pins axi_bram/bram_rst_a]
  connect_bd_net -net axi_bram_ctrl_0_bram_we_a [get_bd_ports bram_we] [get_bd_pins axi_bram/bram_we_a]
  connect_bd_net -net axi_bram_ctrl_0_bram_wrdata_a [get_bd_ports bram_wrdata] [get_bd_pins axi_bram/bram_wrdata_a]
  connect_bd_net -net axi_dma_0_mm2s_introut [get_bd_pins axi_dma_0/mm2s_introut] [get_bd_pins xlconcat_0/In6]
  connect_bd_net -net axi_dma_0_mm2s_prmry_reset_out_n [get_bd_ports mm2s_resetn_out] [get_bd_pins axi_dma_0/mm2s_prmry_reset_out_n]
  connect_bd_net -net axi_dma_0_s2mm_introut [get_bd_pins axi_dma_0/s2mm_introut] [get_bd_pins xlconcat_0/In7]
  connect_bd_net -net axi_dma_0_s2mm_prmry_reset_out_n [get_bd_ports s2mm_resetn_out] [get_bd_pins axi_dma_0/s2mm_prmry_reset_out_n]
  connect_bd_net -net axi_uart16550_0_ip2intc_irpt [get_bd_pins axi_uart16550_0/ip2intc_irpt] [get_bd_pins xlconcat_1/In0]
  connect_bd_net -net axi_uart16550_0_sout [get_bd_ports useruart0_tx] [get_bd_pins axi_uart16550_0/sout]
  connect_bd_net -net axi_uart16550_1_ip2intc_irpt [get_bd_pins axi_uart16550_1/ip2intc_irpt] [get_bd_pins xlconcat_1/In1]
  connect_bd_net -net axi_uart16550_1_sout [get_bd_ports useruart1_tx] [get_bd_pins axi_uart16550_1/sout]
  connect_bd_net -net axilite_slave_0_app_param0 [get_bd_ports app_param0] [get_bd_pins axilite_dma/app_param0]
  connect_bd_net -net axilite_slave_0_app_param1 [get_bd_ports app_param1] [get_bd_pins axilite_dma/app_param1]
  connect_bd_net -net axilite_slave_0_app_param2 [get_bd_ports app_param2] [get_bd_pins axilite_dma/app_param2]
  connect_bd_net -net axilite_slave_0_app_param3 [get_bd_ports app_param3] [get_bd_pins axilite_dma/app_param3]
  connect_bd_net -net axilite_slave_0_app_param4 [get_bd_ports app_param4] [get_bd_pins axilite_dma/app_param4]
  connect_bd_net -net axilite_slave_0_app_param5 [get_bd_ports app_param5] [get_bd_pins axilite_dma/app_param5]
  connect_bd_net -net axilite_slave_0_app_param6 [get_bd_ports app_param6] [get_bd_pins axilite_dma/app_param6]
  connect_bd_net -net axilite_slave_0_app_param7 [get_bd_ports app_param7] [get_bd_pins axilite_dma/app_param7]
  connect_bd_net -net bram_rddata_a_0_1 [get_bd_ports bram_rddata] [get_bd_pins axi_bram/bram_rddata_a]
  connect_bd_net -net c0_sys_clk_n_0_1 [get_bd_ports c0_sys_clk_n] [get_bd_pins mem/c0_sys_clk_n]
  connect_bd_net -net c0_sys_clk_p_0_1 [get_bd_ports c0_sys_clk_p] [get_bd_pins mem/c0_sys_clk_p]
  connect_bd_net -net dac_clk_1 [get_bd_ports dac_clk] [get_bd_pins rfdc4x4/s0_axis_aclk] [get_bd_pins rfdc4x4/s1_axis_aclk]
  connect_bd_net -net dac_rstn_1 [get_bd_ports dac_rstn] [get_bd_pins rfdc4x4/s0_axis_aresetn] [get_bd_pins rfdc4x4/s1_axis_aresetn]
  connect_bd_net -net mem_clk_out1 [get_bd_ports clk_out100] [get_bd_pins mem/clk_out1]
  connect_bd_net -net mem_init_calib_complete [get_bd_ports init_calib_complete] [get_bd_pins mem/init_calib_complete]
  connect_bd_net -net proc_sys_reset_data_peripheral_aresetn [get_bd_ports pl_resetn1] [get_bd_pins axi_dma_0/axi_resetn] [get_bd_pins hpm_inter/M01_ARESETN] [get_bd_pins mem/M01_ARESETN] [get_bd_pins proc_sys_reset_data/peripheral_aresetn]
  connect_bd_net -net rfdc4x4_clk_adc0 [get_bd_ports clk_adc0] [get_bd_pins rfdc4x4/clk_adc0]
  connect_bd_net -net rfdc4x4_clk_adc1 [get_bd_ports clk_adc1] [get_bd_pins rfdc4x4/clk_adc1]
  connect_bd_net -net rfdc4x4_clk_dac0 [get_bd_ports clk_dac0] [get_bd_pins rfdc4x4/clk_dac0]
  connect_bd_net -net rfdc4x4_clk_dac1 [get_bd_ports clk_dac1] [get_bd_pins rfdc4x4/clk_dac1]
  connect_bd_net -net sin_0_1 [get_bd_ports useruart0_rx] [get_bd_pins axi_uart16550_0/sin]
  connect_bd_net -net sin_1_1 [get_bd_ports useruart1_rx] [get_bd_pins axi_uart16550_1/sin]
  connect_bd_net -net sys_rst_0_1 [get_bd_ports ddr_rst] [get_bd_pins mem/sys_rst]
  connect_bd_net -net user_sysref_adc_1 [get_bd_ports user_sysref_adc] [get_bd_pins rfdc4x4/user_sysref_adc]
  connect_bd_net -net user_sysref_dac_1 [get_bd_ports user_sysref_dac] [get_bd_pins rfdc4x4/user_sysref_dac]
  connect_bd_net -net xlconcat_0_dout [get_bd_pins xlconcat_0/dout] [get_bd_pins zynq_ultra_ps_e_0/pl_ps_irq0]
  connect_bd_net -net xlconcat_1_dout [get_bd_pins xlconcat_1/dout] [get_bd_pins zynq_ultra_ps_e_0/pl_ps_irq1]
  connect_bd_net -net xlconstant_0_dout [get_bd_pins axi_uart16550_0/freeze] [get_bd_pins axi_uart16550_1/freeze] [get_bd_pins xlconstant_0/dout]
  connect_bd_net -net zynq_ultra_ps_e_0_pl_clk0 [get_bd_ports pl_clk0] [get_bd_pins axi_bram/s_axi_aclk] [get_bd_pins axi_uart16550_0/s_axi_aclk] [get_bd_pins axi_uart16550_1/s_axi_aclk] [get_bd_pins axilite_dma/s00_axi_aclk] [get_bd_pins bram0/s_axi_aclk] [get_bd_pins fpm0inter/ACLK] [get_bd_pins fpm0inter/M00_ACLK] [get_bd_pins fpm0inter/M01_ACLK] [get_bd_pins fpm0inter/M02_ACLK] [get_bd_pins fpm0inter/S00_ACLK] [get_bd_pins hpm_inter/ACLK] [get_bd_pins hpm_inter/M00_ACLK] [get_bd_pins hpm_inter/M02_ACLK] [get_bd_pins hpm_inter/M03_ACLK] [get_bd_pins hpm_inter/M04_ACLK] [get_bd_pins hpm_inter/M05_ACLK] [get_bd_pins hpm_inter/M06_ACLK] [get_bd_pins hpm_inter/M07_ACLK] [get_bd_pins hpm_inter/M08_ACLK] [get_bd_pins hpm_inter/S00_ACLK] [get_bd_pins mem/s_axi_aclk] [get_bd_pins proc_sys_reset_0/slowest_sync_clk] [get_bd_pins rfdc4x4/s_axi_aclk] [get_bd_pins sysmon/s_axi_aclk] [get_bd_pins zynq_ultra_ps_e_0/maxihpm0_fpd_aclk] [get_bd_pins zynq_ultra_ps_e_0/maxihpm0_lpd_aclk] [get_bd_pins zynq_ultra_ps_e_0/maxihpm1_fpd_aclk] [get_bd_pins zynq_ultra_ps_e_0/pl_clk0]
  connect_bd_net -net zynq_ultra_ps_e_0_pl_clk1 [get_bd_ports pl_clk1] [get_bd_pins axi_dma_0/m_axi_mm2s_aclk] [get_bd_pins axi_dma_0/m_axi_s2mm_aclk] [get_bd_pins axi_dma_0/m_axi_sg_aclk] [get_bd_pins axi_dma_0/s_axi_lite_aclk] [get_bd_pins hpm_inter/M01_ACLK] [get_bd_pins mem/M01_ACLK] [get_bd_pins proc_sys_reset_data/slowest_sync_clk] [get_bd_pins smartconnect_0/aclk] [get_bd_pins zynq_ultra_ps_e_0/pl_clk1] [get_bd_pins zynq_ultra_ps_e_0/saxihpc0_fpd_aclk] [get_bd_pins zynq_ultra_ps_e_0/saxihpc1_fpd_aclk]
  connect_bd_net -net zynq_ultra_ps_e_0_pl_resetn0 [get_bd_pins proc_sys_reset_0/ext_reset_in] [get_bd_pins proc_sys_reset_data/ext_reset_in] [get_bd_pins zynq_ultra_ps_e_0/pl_resetn0]

  # Create address segments
  assign_bd_address -offset 0x000800000000 -range 0x000800000000 -target_address_space [get_bd_addr_spaces axi_dma_0/Data_SG] [get_bd_addr_segs zynq_ultra_ps_e_0/SAXIGP0/HPC0_DDR_HIGH] -force
  assign_bd_address -offset 0x000800000000 -range 0x000800000000 -target_address_space [get_bd_addr_spaces axi_dma_0/Data] [get_bd_addr_segs zynq_ultra_ps_e_0/SAXIGP0/HPC0_DDR_HIGH] -force
  assign_bd_address -offset 0x00000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces axi_dma_0/Data_SG] [get_bd_addr_segs zynq_ultra_ps_e_0/SAXIGP0/HPC0_DDR_LOW] -force
  assign_bd_address -offset 0x00000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces axi_dma_0/Data] [get_bd_addr_segs zynq_ultra_ps_e_0/SAXIGP0/HPC0_DDR_LOW] -force
  assign_bd_address -offset 0xFF000000 -range 0x01000000 -target_address_space [get_bd_addr_spaces axi_dma_0/Data_SG] [get_bd_addr_segs zynq_ultra_ps_e_0/SAXIGP0/HPC0_LPS_OCM] -force
  assign_bd_address -offset 0xFF000000 -range 0x01000000 -target_address_space [get_bd_addr_spaces axi_dma_0/Data] [get_bd_addr_segs zynq_ultra_ps_e_0/SAXIGP0/HPC0_LPS_OCM] -force
  assign_bd_address -offset 0xE0000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces axi_dma_0/Data_SG] [get_bd_addr_segs zynq_ultra_ps_e_0/SAXIGP0/HPC0_PCIE_LOW] -force
  assign_bd_address -offset 0xE0000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces axi_dma_0/Data] [get_bd_addr_segs zynq_ultra_ps_e_0/SAXIGP0/HPC0_PCIE_LOW] -force
  assign_bd_address -offset 0xC0000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces axi_dma_0/Data_SG] [get_bd_addr_segs zynq_ultra_ps_e_0/SAXIGP0/HPC0_QSPI] -force
  assign_bd_address -offset 0xC0000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces axi_dma_0/Data] [get_bd_addr_segs zynq_ultra_ps_e_0/SAXIGP0/HPC0_QSPI] -force
  assign_bd_address -offset 0x81000000 -range 0x01000000 -target_address_space [get_bd_addr_spaces zynq_ultra_ps_e_0/Data] [get_bd_addr_segs app_lite/Reg] -force
  assign_bd_address -offset 0x82000000 -range 0x01000000 -target_address_space [get_bd_addr_spaces zynq_ultra_ps_e_0/Data] [get_bd_addr_segs axi_bram/S_AXI/Mem0] -force
  assign_bd_address -offset 0x000470000000 -range 0x00080000 -target_address_space [get_bd_addr_spaces zynq_ultra_ps_e_0/Data] [get_bd_addr_segs mem/axi_bram_ctrl_0/S_AXI/Mem0] -force
  assign_bd_address -offset 0x80020000 -range 0x00004000 -target_address_space [get_bd_addr_spaces zynq_ultra_ps_e_0/Data] [get_bd_addr_segs axi_dma_0/S_AXI_LITE/Reg] -force
  assign_bd_address -offset 0x80080000 -range 0x00010000 -target_address_space [get_bd_addr_spaces zynq_ultra_ps_e_0/Data] [get_bd_addr_segs axi_uart16550_0/S_AXI/Reg] -force
  assign_bd_address -offset 0x80090000 -range 0x00010000 -target_address_space [get_bd_addr_spaces zynq_ultra_ps_e_0/Data] [get_bd_addr_segs axi_uart16550_1/S_AXI/Reg] -force
  assign_bd_address -offset 0x80010000 -range 0x00004000 -target_address_space [get_bd_addr_spaces zynq_ultra_ps_e_0/Data] [get_bd_addr_segs axilite_dma/S00_AXI/S00_AXI_reg] -force
  assign_bd_address -offset 0x80000000 -range 0x00010000 -target_address_space [get_bd_addr_spaces zynq_ultra_ps_e_0/Data] [get_bd_addr_segs bram0/S_AXI/Mem0] -force
  assign_bd_address -offset 0x000480000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces zynq_ultra_ps_e_0/Data] [get_bd_addr_segs mem/ddr4_0/C0_DDR4_MEMORY_MAP/C0_DDR4_ADDRESS_BLOCK] -force
  assign_bd_address -offset 0x80040000 -range 0x00040000 -target_address_space [get_bd_addr_spaces zynq_ultra_ps_e_0/Data] [get_bd_addr_segs rfdc4x4/s_axi/Reg] -force
  assign_bd_address -offset 0x80030000 -range 0x00010000 -target_address_space [get_bd_addr_spaces zynq_ultra_ps_e_0/Data] [get_bd_addr_segs sysmon/S_AXI_LITE/Reg] -force
  assign_bd_address -offset 0x000470000000 -range 0x00080000 -target_address_space [get_bd_addr_spaces deepfifo_axi] [get_bd_addr_segs mem/axi_bram_ctrl_0/S_AXI/Mem0] -force
  assign_bd_address -offset 0x000470000000 -range 0x00080000 -target_address_space [get_bd_addr_spaces mem_axi] [get_bd_addr_segs mem/axi_bram_ctrl_0/S_AXI/Mem0] -force
  assign_bd_address -offset 0x000480000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces deepfifo_axi] [get_bd_addr_segs mem/ddr4_0/C0_DDR4_MEMORY_MAP/C0_DDR4_ADDRESS_BLOCK] -force
  assign_bd_address -offset 0x000480000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces mem_axi] [get_bd_addr_segs mem/ddr4_0/C0_DDR4_MEMORY_MAP/C0_DDR4_ADDRESS_BLOCK] -force
  assign_bd_address -offset 0x000800000000 -range 0x000800000000 -target_address_space [get_bd_addr_spaces S_AXI_HPC1] [get_bd_addr_segs zynq_ultra_ps_e_0/SAXIGP1/HPC1_DDR_HIGH] -force
  assign_bd_address -offset 0x00000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces S_AXI_HPC1] [get_bd_addr_segs zynq_ultra_ps_e_0/SAXIGP1/HPC1_DDR_LOW] -force

  # Exclude Address Segments
  exclude_bd_addr_seg -offset 0xFF000000 -range 0x01000000 -target_address_space [get_bd_addr_spaces S_AXI_HPC1] [get_bd_addr_segs zynq_ultra_ps_e_0/SAXIGP1/HPC1_LPS_OCM]
  exclude_bd_addr_seg -offset 0xE0000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces S_AXI_HPC1] [get_bd_addr_segs zynq_ultra_ps_e_0/SAXIGP1/HPC1_PCIE_LOW]
  exclude_bd_addr_seg -offset 0xC0000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces S_AXI_HPC1] [get_bd_addr_segs zynq_ultra_ps_e_0/SAXIGP1/HPC1_QSPI]


  # Restore current instance
  current_bd_instance $oldCurInst

  validate_bd_design
  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


