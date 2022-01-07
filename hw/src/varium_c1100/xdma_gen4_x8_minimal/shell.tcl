
################################################################
# This is a generated script based on design: shell
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
set scripts_vivado_version 2021.2
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
# source shell_script.tcl

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xcu55n-fsvh2892-2L-e
}


# CHANGE DESIGN NAME HERE
variable design_name
set design_name shell

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
xilinx.com:ip:proc_sys_reset:5.0\
xilinx.com:ip:util_vector_logic:2.0\
xilinx.com:ip:cms_subsystem:4.0\
xilinx.com:ip:smartconnect:1.0\
xilinx.com:ip:axi_hbicap:1.0\
xilinx.com:ip:hbm:1.0\
xilinx.com:ip:axi_intc:4.1\
xilinx.com:ip:util_ds_buf:2.2\
xilinx.com:ip:clk_wiz:6.0\
xilinx.com:ip:xdma:4.1\
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
  set pcie_clk [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 pcie_clk ]

  set pcie_mgt [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:pcie_7x_mgt_rtl:1.0 pcie_mgt ]

  set satellite_uart [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:uart_rtl:1.0 satellite_uart ]

  set shell_clk [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 shell_clk ]


  # Create ports
  set pcie_rstn [ create_bd_port -dir I -type rst pcie_rstn ]
  set satellite_gpio [ create_bd_port -dir I -from 3 -to 0 -type intr satellite_gpio ]
  set_property -dict [ list \
   CONFIG.PortWidth {4} \
   CONFIG.SENSITIVITY {EDGE_RISING} \
 ] $satellite_gpio

  # Create instance: apb_icap_reset, and set properties
  set apb_icap_reset [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 apb_icap_reset ]

  # Create instance: cattrip_util, and set properties
  set cattrip_util [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 cattrip_util ]
  set_property -dict [ list \
   CONFIG.C_OPERATION {or} \
   CONFIG.C_SIZE {1} \
   CONFIG.LOGO_FILE {data/sym_orgate.png} \
 ] $cattrip_util

  # Create instance: cms, and set properties
  set cms [ create_bd_cell -type ip -vlnv xilinx.com:ip:cms_subsystem:4.0 cms ]

  # Create instance: dma_smartconnect, and set properties
  set dma_smartconnect [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 dma_smartconnect ]
  set_property -dict [ list \
   CONFIG.HAS_ARESETN {1} \
   CONFIG.NUM_MI {2} \
   CONFIG.NUM_SI {1} \
 ] $dma_smartconnect

  # Create instance: hbicap, and set properties
  set hbicap [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_hbicap:1.0 hbicap ]
  set_property -dict [ list \
   CONFIG.C_INCLUDE_STARTUP {1} \
 ] $hbicap

  # Create instance: hbm, and set properties
  set hbm [ create_bd_cell -type ip -vlnv xilinx.com:ip:hbm:1.0 hbm ]
  set_property -dict [ list \
   CONFIG.USER_APB_EN {false} \
   CONFIG.USER_CLK_SEL_LIST0 {AXI_00_ACLK} \
   CONFIG.USER_CLK_SEL_LIST1 {AXI_16_ACLK} \
   CONFIG.USER_HBM_CP_1 {6} \
   CONFIG.USER_HBM_DENSITY {8GB} \
   CONFIG.USER_HBM_FBDIV_0 {36} \
   CONFIG.USER_HBM_FBDIV_1 {36} \
   CONFIG.USER_HBM_HEX_CP_RES_0 {0x0000A600} \
   CONFIG.USER_HBM_HEX_CP_RES_1 {0x0000A600} \
   CONFIG.USER_HBM_HEX_FBDIV_CLKOUTDIV_0 {0x00000902} \
   CONFIG.USER_HBM_HEX_FBDIV_CLKOUTDIV_1 {0x00000902} \
   CONFIG.USER_HBM_HEX_LOCK_FB_REF_DLY_0 {0x00001f1f} \
   CONFIG.USER_HBM_HEX_LOCK_FB_REF_DLY_1 {0x00001f1f} \
   CONFIG.USER_HBM_LOCK_FB_DLY_0 {31} \
   CONFIG.USER_HBM_LOCK_FB_DLY_1 {31} \
   CONFIG.USER_HBM_LOCK_REF_DLY_0 {31} \
   CONFIG.USER_HBM_LOCK_REF_DLY_1 {31} \
   CONFIG.USER_HBM_REF_CLK_0 {100} \
   CONFIG.USER_HBM_REF_CLK_1 {100} \
   CONFIG.USER_HBM_REF_CLK_PS_0 {5000.00} \
   CONFIG.USER_HBM_REF_CLK_PS_1 {5000.00} \
   CONFIG.USER_HBM_REF_CLK_XDC_0 {10.00} \
   CONFIG.USER_HBM_REF_CLK_XDC_1 {10.00} \
   CONFIG.USER_HBM_RES_0 {10} \
   CONFIG.USER_HBM_RES_1 {10} \
   CONFIG.USER_HBM_STACK {2} \
   CONFIG.USER_MC_ENABLE_08 {TRUE} \
   CONFIG.USER_MC_ENABLE_09 {TRUE} \
   CONFIG.USER_MC_ENABLE_10 {TRUE} \
   CONFIG.USER_MC_ENABLE_11 {TRUE} \
   CONFIG.USER_MC_ENABLE_12 {TRUE} \
   CONFIG.USER_MC_ENABLE_13 {TRUE} \
   CONFIG.USER_MC_ENABLE_14 {TRUE} \
   CONFIG.USER_MC_ENABLE_15 {TRUE} \
   CONFIG.USER_MC_ENABLE_APB_01 {TRUE} \
   CONFIG.USER_MEMORY_DISPLAY {8192} \
   CONFIG.USER_PHY_ENABLE_08 {TRUE} \
   CONFIG.USER_PHY_ENABLE_09 {TRUE} \
   CONFIG.USER_PHY_ENABLE_10 {TRUE} \
   CONFIG.USER_PHY_ENABLE_11 {TRUE} \
   CONFIG.USER_PHY_ENABLE_12 {TRUE} \
   CONFIG.USER_PHY_ENABLE_13 {TRUE} \
   CONFIG.USER_PHY_ENABLE_14 {TRUE} \
   CONFIG.USER_PHY_ENABLE_15 {TRUE} \
   CONFIG.USER_SAXI_01 {false} \
   CONFIG.USER_SAXI_02 {false} \
   CONFIG.USER_SAXI_03 {false} \
   CONFIG.USER_SAXI_04 {false} \
   CONFIG.USER_SAXI_05 {false} \
   CONFIG.USER_SAXI_06 {false} \
   CONFIG.USER_SAXI_07 {false} \
   CONFIG.USER_SAXI_08 {false} \
   CONFIG.USER_SAXI_09 {false} \
   CONFIG.USER_SAXI_10 {false} \
   CONFIG.USER_SAXI_11 {false} \
   CONFIG.USER_SAXI_12 {false} \
   CONFIG.USER_SAXI_13 {false} \
   CONFIG.USER_SAXI_14 {false} \
   CONFIG.USER_SAXI_15 {false} \
   CONFIG.USER_SAXI_16 {false} \
   CONFIG.USER_SAXI_17 {false} \
   CONFIG.USER_SAXI_18 {false} \
   CONFIG.USER_SAXI_19 {false} \
   CONFIG.USER_SAXI_20 {false} \
   CONFIG.USER_SAXI_21 {false} \
   CONFIG.USER_SAXI_22 {false} \
   CONFIG.USER_SAXI_23 {false} \
   CONFIG.USER_SAXI_24 {false} \
   CONFIG.USER_SAXI_25 {false} \
   CONFIG.USER_SAXI_26 {false} \
   CONFIG.USER_SAXI_27 {false} \
   CONFIG.USER_SAXI_28 {false} \
   CONFIG.USER_SAXI_29 {false} \
   CONFIG.USER_SAXI_30 {false} \
   CONFIG.USER_SAXI_31 {false} \
   CONFIG.USER_SWITCH_ENABLE_01 {TRUE} \
   CONFIG.USER_XSDB_INTF_EN {TRUE} \
 ] $hbm

  # Create instance: intc, and set properties
  set intc [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_intc:4.1 intc ]
  set_property -dict [ list \
   CONFIG.C_HAS_FAST {0} \
   CONFIG.C_IRQ_CONNECTION {1} \
   CONFIG.C_PROCESSOR_CLK_FREQ_MHZ {250} \
   CONFIG.C_S_AXI_ACLK_FREQ_MHZ {250} \
 ] $intc

  # Create instance: pcie_clk_buf, and set properties
  set pcie_clk_buf [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_ds_buf:2.2 pcie_clk_buf ]
  set_property -dict [ list \
   CONFIG.C_BUF_TYPE {IBUFDSGTE} \
 ] $pcie_clk_buf

  # Create instance: shell_clk_buffer, and set properties
  set shell_clk_buffer [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_ds_buf:2.2 shell_clk_buffer ]
  set_property -dict [ list \
   CONFIG.C_BUF_TYPE {IBUFDS} \
 ] $shell_clk_buffer

  # Create instance: shell_clk_wiz, and set properties
  set shell_clk_wiz [ create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:6.0 shell_clk_wiz ]
  set_property -dict [ list \
   CONFIG.CLKOUT1_JITTER {111.970} \
   CONFIG.CLKOUT1_PHASE_ERROR {84.520} \
   CONFIG.CLKOUT2_JITTER {107.502} \
   CONFIG.CLKOUT2_PHASE_ERROR {84.520} \
   CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {125.000} \
   CONFIG.CLKOUT2_USED {true} \
   CONFIG.CLK_OUT1_PORT {apb_clk} \
   CONFIG.CLK_OUT2_PORT {icap_clk} \
   CONFIG.MMCM_CLKFBOUT_MULT_F {12.500} \
   CONFIG.MMCM_CLKOUT0_DIVIDE_F {12.500} \
   CONFIG.MMCM_CLKOUT1_DIVIDE {10} \
   CONFIG.NUM_OUT_CLKS {2} \
   CONFIG.OPTIMIZE_CLOCKING_STRUCTURE_EN {true} \
   CONFIG.PRIM_SOURCE {No_buffer} \
   CONFIG.RESET_PORT {resetn} \
   CONFIG.RESET_TYPE {ACTIVE_LOW} \
 ] $shell_clk_wiz

  # Create instance: shell_smartconnect, and set properties
  set shell_smartconnect [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 shell_smartconnect ]
  set_property -dict [ list \
   CONFIG.NUM_MI {3} \
   CONFIG.NUM_SI {1} \
 ] $shell_smartconnect

  # Create instance: xdma, and set properties
  set xdma [ create_bd_cell -type ip -vlnv xilinx.com:ip:xdma:4.1 xdma ]
  set_property -dict [ list \
   CONFIG.PF0_DEVICE_ID_mqdma {9038} \
   CONFIG.PF0_SRIOV_VF_DEVICE_ID {A038} \
   CONFIG.PF1_SRIOV_VF_DEVICE_ID {A138} \
   CONFIG.PF2_DEVICE_ID_mqdma {9238} \
   CONFIG.PF2_SRIOV_VF_DEVICE_ID {A238} \
   CONFIG.PF3_DEVICE_ID_mqdma {9338} \
   CONFIG.PF3_SRIOV_VF_DEVICE_ID {A338} \
   CONFIG.axi_data_width {256_bit} \
   CONFIG.axilite_master_en {true} \
   CONFIG.axilite_master_size {64} \
   CONFIG.axisten_freq {250} \
   CONFIG.cfg_mgmt_if {false} \
   CONFIG.coreclk_freq {500} \
   CONFIG.pf0_Use_Class_Code_Lookup_Assistant {true} \
   CONFIG.pf0_base_class_menu {Processing_accelerators} \
   CONFIG.pf0_class_code {120000} \
   CONFIG.pf0_class_code_base {12} \
   CONFIG.pf0_class_code_interface {00} \
   CONFIG.pf0_device_id {9038} \
   CONFIG.pf0_msix_cap_pba_bir {BAR_1} \
   CONFIG.pf0_msix_cap_table_bir {BAR_1} \
   CONFIG.pf0_sub_class_interface_menu {Unknown} \
   CONFIG.pl_link_cap_max_link_speed {8.0_GT/s} \
   CONFIG.pl_link_cap_max_link_width {X8} \
   CONFIG.plltype {QPLL1} \
 ] $xdma

  # Create interface connections
  connect_bd_intf_net -intf_net cms_satellite_uart [get_bd_intf_ports satellite_uart] [get_bd_intf_pins cms/satellite_uart]
  connect_bd_intf_net -intf_net dma_smartconnect_M00_AXI [get_bd_intf_pins dma_smartconnect/M00_AXI] [get_bd_intf_pins hbm/SAXI_00]
  connect_bd_intf_net -intf_net dma_smartconnect_M01_AXI [get_bd_intf_pins dma_smartconnect/M01_AXI] [get_bd_intf_pins hbicap/S_AXI]
  connect_bd_intf_net -intf_net pcie_clk_1 [get_bd_intf_ports pcie_clk] [get_bd_intf_pins pcie_clk_buf/CLK_IN_D]
  connect_bd_intf_net -intf_net shell_clk_1 [get_bd_intf_ports shell_clk] [get_bd_intf_pins shell_clk_buffer/CLK_IN_D]
  connect_bd_intf_net -intf_net shell_smartconnect_M00_AXI [get_bd_intf_pins cms/s_axi_ctrl] [get_bd_intf_pins shell_smartconnect/M00_AXI]
  connect_bd_intf_net -intf_net shell_smartconnect_M01_AXI [get_bd_intf_pins intc/s_axi] [get_bd_intf_pins shell_smartconnect/M01_AXI]
  connect_bd_intf_net -intf_net shell_smartconnect_M02_AXI [get_bd_intf_pins hbicap/S_AXI_CTRL] [get_bd_intf_pins shell_smartconnect/M02_AXI]
  connect_bd_intf_net -intf_net xdma_M_AXI [get_bd_intf_pins dma_smartconnect/S00_AXI] [get_bd_intf_pins xdma/M_AXI]
  connect_bd_intf_net -intf_net xdma_M_AXI_LITE [get_bd_intf_pins shell_smartconnect/S00_AXI] [get_bd_intf_pins xdma/M_AXI_LITE]
  connect_bd_intf_net -intf_net xdma_pcie_mgt [get_bd_intf_ports pcie_mgt] [get_bd_intf_pins xdma/pcie_mgt]

  # Create port connections
  connect_bd_net -net apb_icap_reset_peripheral_aresetn [get_bd_pins apb_icap_reset/peripheral_aresetn] [get_bd_pins hbm/APB_0_PRESET_N] [get_bd_pins hbm/APB_1_PRESET_N]
  connect_bd_net -net cattrip_util_Res [get_bd_pins cattrip_util/Res] [get_bd_pins cms/interrupt_hbm_cattrip]
  connect_bd_net -net cms_interrupt_host [get_bd_pins cms/interrupt_host] [get_bd_pins intc/intr]
  connect_bd_net -net hbm_DRAM_0_STAT_CATTRIP [get_bd_pins cattrip_util/Op1] [get_bd_pins hbm/DRAM_0_STAT_CATTRIP]
  connect_bd_net -net hbm_DRAM_0_STAT_TEMP [get_bd_pins cms/hbm_temp_1] [get_bd_pins hbm/DRAM_0_STAT_TEMP]
  connect_bd_net -net hbm_DRAM_1_STAT_CATTRIP [get_bd_pins cattrip_util/Op2] [get_bd_pins hbm/DRAM_1_STAT_CATTRIP]
  connect_bd_net -net hbm_DRAM_1_STAT_TEMP [get_bd_pins cms/hbm_temp_2] [get_bd_pins hbm/DRAM_1_STAT_TEMP]
  connect_bd_net -net intc_irq [get_bd_pins intc/irq] [get_bd_pins xdma/usr_irq_req]
  connect_bd_net -net pcie_clk_buf_IBUF_DS_ODIV2 [get_bd_pins pcie_clk_buf/IBUF_DS_ODIV2] [get_bd_pins xdma/sys_clk]
  connect_bd_net -net pcie_clk_buf_IBUF_OUT [get_bd_pins pcie_clk_buf/IBUF_OUT] [get_bd_pins xdma/sys_clk_gt]
  connect_bd_net -net pcie_rstn_1 [get_bd_ports pcie_rstn] [get_bd_pins apb_icap_reset/ext_reset_in] [get_bd_pins shell_clk_wiz/resetn] [get_bd_pins xdma/sys_rst_n]
  connect_bd_net -net satellite_gpio_0_1 [get_bd_ports satellite_gpio] [get_bd_pins cms/satellite_gpio]
  connect_bd_net -net shell_clk_buffer_IBUF_OUT [get_bd_pins hbm/HBM_REF_CLK_0] [get_bd_pins hbm/HBM_REF_CLK_1] [get_bd_pins shell_clk_buffer/IBUF_OUT] [get_bd_pins shell_clk_wiz/clk_in1]
  connect_bd_net -net shell_clk_wiz_apb_clk [get_bd_pins apb_icap_reset/slowest_sync_clk] [get_bd_pins hbm/APB_0_PCLK] [get_bd_pins hbm/APB_1_PCLK] [get_bd_pins shell_clk_wiz/apb_clk]
  connect_bd_net -net shell_clk_wiz_icap_clk [get_bd_pins hbicap/icap_clk] [get_bd_pins shell_clk_wiz/icap_clk]
  connect_bd_net -net shell_clk_wiz_locked [get_bd_pins apb_icap_reset/dcm_locked] [get_bd_pins shell_clk_wiz/locked]
  connect_bd_net -net xdma_axi_aclk [get_bd_pins cms/aclk_ctrl] [get_bd_pins dma_smartconnect/aclk] [get_bd_pins hbicap/s_axi_aclk] [get_bd_pins hbicap/s_axi_mm_aclk] [get_bd_pins hbm/AXI_00_ACLK] [get_bd_pins intc/s_axi_aclk] [get_bd_pins shell_smartconnect/aclk] [get_bd_pins xdma/axi_aclk]
  connect_bd_net -net xdma_axi_aresetn [get_bd_pins cms/aresetn_ctrl] [get_bd_pins dma_smartconnect/aresetn] [get_bd_pins hbicap/s_axi_aresetn] [get_bd_pins hbicap/s_axi_mm_aresetn] [get_bd_pins hbm/AXI_00_ARESET_N] [get_bd_pins intc/s_axi_aresetn] [get_bd_pins shell_smartconnect/aresetn] [get_bd_pins xdma/axi_aresetn]

  # Create address segments
  assign_bd_address -offset 0x00000000 -range 0x00040000 -target_address_space [get_bd_addr_spaces xdma/M_AXI_LITE] [get_bd_addr_segs cms/s_axi_ctrl/Mem0] -force
  assign_bd_address -offset 0x1000000000000000 -range 0x00010000 -target_address_space [get_bd_addr_spaces xdma/M_AXI] [get_bd_addr_segs hbicap/S_AXI/Mem0] -force
  assign_bd_address -offset 0x00100000 -range 0x00010000 -target_address_space [get_bd_addr_spaces xdma/M_AXI_LITE] [get_bd_addr_segs hbicap/S_AXI_CTRL/Reg0] -force
  assign_bd_address -offset 0x00000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces xdma/M_AXI] [get_bd_addr_segs hbm/SAXI_00/HBM_MEM00] -force
  assign_bd_address -offset 0x10000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces xdma/M_AXI] [get_bd_addr_segs hbm/SAXI_00/HBM_MEM01] -force
  assign_bd_address -offset 0x20000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces xdma/M_AXI] [get_bd_addr_segs hbm/SAXI_00/HBM_MEM02] -force
  assign_bd_address -offset 0x30000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces xdma/M_AXI] [get_bd_addr_segs hbm/SAXI_00/HBM_MEM03] -force
  assign_bd_address -offset 0x40000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces xdma/M_AXI] [get_bd_addr_segs hbm/SAXI_00/HBM_MEM04] -force
  assign_bd_address -offset 0x50000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces xdma/M_AXI] [get_bd_addr_segs hbm/SAXI_00/HBM_MEM05] -force
  assign_bd_address -offset 0x60000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces xdma/M_AXI] [get_bd_addr_segs hbm/SAXI_00/HBM_MEM06] -force
  assign_bd_address -offset 0x70000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces xdma/M_AXI] [get_bd_addr_segs hbm/SAXI_00/HBM_MEM07] -force
  assign_bd_address -offset 0x80000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces xdma/M_AXI] [get_bd_addr_segs hbm/SAXI_00/HBM_MEM08] -force
  assign_bd_address -offset 0x90000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces xdma/M_AXI] [get_bd_addr_segs hbm/SAXI_00/HBM_MEM09] -force
  assign_bd_address -offset 0xA0000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces xdma/M_AXI] [get_bd_addr_segs hbm/SAXI_00/HBM_MEM10] -force
  assign_bd_address -offset 0xB0000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces xdma/M_AXI] [get_bd_addr_segs hbm/SAXI_00/HBM_MEM11] -force
  assign_bd_address -offset 0xC0000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces xdma/M_AXI] [get_bd_addr_segs hbm/SAXI_00/HBM_MEM12] -force
  assign_bd_address -offset 0xD0000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces xdma/M_AXI] [get_bd_addr_segs hbm/SAXI_00/HBM_MEM13] -force
  assign_bd_address -offset 0xE0000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces xdma/M_AXI] [get_bd_addr_segs hbm/SAXI_00/HBM_MEM14] -force
  assign_bd_address -offset 0xF0000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces xdma/M_AXI] [get_bd_addr_segs hbm/SAXI_00/HBM_MEM15] -force
  assign_bd_address -offset 0x000100000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces xdma/M_AXI] [get_bd_addr_segs hbm/SAXI_00/HBM_MEM16] -force
  assign_bd_address -offset 0x000110000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces xdma/M_AXI] [get_bd_addr_segs hbm/SAXI_00/HBM_MEM17] -force
  assign_bd_address -offset 0x000120000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces xdma/M_AXI] [get_bd_addr_segs hbm/SAXI_00/HBM_MEM18] -force
  assign_bd_address -offset 0x000130000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces xdma/M_AXI] [get_bd_addr_segs hbm/SAXI_00/HBM_MEM19] -force
  assign_bd_address -offset 0x000140000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces xdma/M_AXI] [get_bd_addr_segs hbm/SAXI_00/HBM_MEM20] -force
  assign_bd_address -offset 0x000150000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces xdma/M_AXI] [get_bd_addr_segs hbm/SAXI_00/HBM_MEM21] -force
  assign_bd_address -offset 0x000160000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces xdma/M_AXI] [get_bd_addr_segs hbm/SAXI_00/HBM_MEM22] -force
  assign_bd_address -offset 0x000170000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces xdma/M_AXI] [get_bd_addr_segs hbm/SAXI_00/HBM_MEM23] -force
  assign_bd_address -offset 0x000180000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces xdma/M_AXI] [get_bd_addr_segs hbm/SAXI_00/HBM_MEM24] -force
  assign_bd_address -offset 0x000190000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces xdma/M_AXI] [get_bd_addr_segs hbm/SAXI_00/HBM_MEM25] -force
  assign_bd_address -offset 0x0001A0000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces xdma/M_AXI] [get_bd_addr_segs hbm/SAXI_00/HBM_MEM26] -force
  assign_bd_address -offset 0x0001B0000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces xdma/M_AXI] [get_bd_addr_segs hbm/SAXI_00/HBM_MEM27] -force
  assign_bd_address -offset 0x0001C0000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces xdma/M_AXI] [get_bd_addr_segs hbm/SAXI_00/HBM_MEM28] -force
  assign_bd_address -offset 0x0001D0000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces xdma/M_AXI] [get_bd_addr_segs hbm/SAXI_00/HBM_MEM29] -force
  assign_bd_address -offset 0x0001E0000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces xdma/M_AXI] [get_bd_addr_segs hbm/SAXI_00/HBM_MEM30] -force
  assign_bd_address -offset 0x0001F0000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces xdma/M_AXI] [get_bd_addr_segs hbm/SAXI_00/HBM_MEM31] -force
  assign_bd_address -offset 0x00040000 -range 0x00010000 -target_address_space [get_bd_addr_spaces xdma/M_AXI_LITE] [get_bd_addr_segs intc/S_AXI/Reg] -force


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


