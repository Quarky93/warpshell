# Proc to create BD user
proc cr_bd_user { parentCell } {

  # CHANGE DESIGN NAME HERE
  set design_name user

  common::send_gid_msg -ssname BD::TCL -id 2010 -severity "INFO" "Currently there is no design <$design_name> in project, so creating one..."

  create_bd_design $design_name

  set bCheckIPsPassed 1
  ##################################################################
  # CHECK IPs
  ##################################################################
  set bCheckIPs 1
  if { $bCheckIPs == 1 } {
     set list_check_ips "\ 
  xilinx.com:ip:axi_apb_bridge:3.0\
  xilinx.com:ip:hbm:1.0\
  xilinx.com:ip:util_vector_logic:2.0\
  xilinx.com:ip:proc_sys_reset:5.0\
  xilinx.com:ip:smartconnect:1.0\
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

  variable script_folder

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
  set shell_axi_dma [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 shell_axi_dma ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {64} \
   CONFIG.ARUSER_WIDTH {0} \
   CONFIG.AWUSER_WIDTH {0} \
   CONFIG.BUSER_WIDTH {0} \
   CONFIG.DATA_WIDTH {256} \
   CONFIG.FREQ_HZ {250000000} \
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
   CONFIG.NUM_READ_OUTSTANDING {32} \
   CONFIG.NUM_READ_THREADS {1} \
   CONFIG.NUM_WRITE_OUTSTANDING {32} \
   CONFIG.NUM_WRITE_THREADS {1} \
   CONFIG.PROTOCOL {AXI4} \
   CONFIG.READ_WRITE_MODE {READ_WRITE} \
   CONFIG.RUSER_BITS_PER_BYTE {0} \
   CONFIG.RUSER_WIDTH {0} \
   CONFIG.SUPPORTS_NARROW_BURST {0} \
   CONFIG.WUSER_BITS_PER_BYTE {0} \
   CONFIG.WUSER_WIDTH {0} \
   ] $shell_axi_dma

  set shell_axil_ctrl [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 shell_axil_ctrl ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {32} \
   CONFIG.ARUSER_WIDTH {0} \
   CONFIG.AWUSER_WIDTH {0} \
   CONFIG.BUSER_WIDTH {0} \
   CONFIG.DATA_WIDTH {32} \
   CONFIG.FREQ_HZ {250000000} \
   CONFIG.HAS_BRESP {1} \
   CONFIG.HAS_BURST {0} \
   CONFIG.HAS_CACHE {0} \
   CONFIG.HAS_LOCK {0} \
   CONFIG.HAS_PROT {1} \
   CONFIG.HAS_QOS {0} \
   CONFIG.HAS_REGION {0} \
   CONFIG.HAS_RRESP {1} \
   CONFIG.HAS_WSTRB {1} \
   CONFIG.ID_WIDTH {0} \
   CONFIG.MAX_BURST_LENGTH {1} \
   CONFIG.NUM_READ_OUTSTANDING {1} \
   CONFIG.NUM_READ_THREADS {1} \
   CONFIG.NUM_WRITE_OUTSTANDING {1} \
   CONFIG.NUM_WRITE_THREADS {1} \
   CONFIG.PROTOCOL {AXI4LITE} \
   CONFIG.READ_WRITE_MODE {READ_WRITE} \
   CONFIG.RUSER_BITS_PER_BYTE {0} \
   CONFIG.RUSER_WIDTH {0} \
   CONFIG.SUPPORTS_NARROW_BURST {0} \
   CONFIG.WUSER_BITS_PER_BYTE {0} \
   CONFIG.WUSER_WIDTH {0} \
   ] $shell_axil_ctrl


  # Create ports
  set shell_axi_clk [ create_bd_port -dir I -type clk -freq_hz 250000000 shell_axi_clk ]
  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {shell_axi_dma:shell_axil_ctrl} \
   CONFIG.ASSOCIATED_RESET {shell_rstn} \
 ] $shell_axi_clk
  set shell_refclk_0 [ create_bd_port -dir I -type clk -freq_hz 100000000 shell_refclk_0 ]
  set shell_rstn [ create_bd_port -dir I -type rst shell_rstn ]
  set user_hbm_cattrip [ create_bd_port -dir O -from 0 -to 0 -type intr user_hbm_cattrip ]
  set user_hbm_temp_0 [ create_bd_port -dir O -from 6 -to 0 -type data user_hbm_temp_0 ]
  set user_hbm_temp_1 [ create_bd_port -dir O -from 6 -to 0 -type data user_hbm_temp_1 ]

  # Create instance: axi_apb_bridge, and set properties
  set axi_apb_bridge [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_apb_bridge:3.0 axi_apb_bridge ]
  set_property -dict [list \
    CONFIG.C_APB_NUM_SLAVES {2} \
    CONFIG.C_M_APB_PROTOCOL {apb4} \
  ] $axi_apb_bridge


  # Create instance: hbm, and set properties
  set hbm [ create_bd_cell -type ip -vlnv xilinx.com:ip:hbm:1.0 hbm ]
  set_property -dict [list \
    CONFIG.USER_HBM_DENSITY {8GB} \
    CONFIG.USER_SAXI_00 {false} \
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
    CONFIG.USER_SAXI_31 {true} \
  ] $hbm


  # Create instance: hbm_cattrip, and set properties
  set hbm_cattrip [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 hbm_cattrip ]
  set_property -dict [list \
    CONFIG.C_OPERATION {or} \
    CONFIG.C_SIZE {1} \
  ] $hbm_cattrip


  # Create instance: hbm_reset, and set properties
  set hbm_reset [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 hbm_reset ]

  # Create instance: smartconnect_ctrl, and set properties
  set smartconnect_ctrl [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 smartconnect_ctrl ]
  set_property -dict [list \
    CONFIG.NUM_CLKS {2} \
    CONFIG.NUM_SI {1} \
  ] $smartconnect_ctrl


  # Create instance: smartconnect_dma, and set properties
  set smartconnect_dma [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 smartconnect_dma ]
  set_property -dict [list \
    CONFIG.NUM_CLKS {1} \
    CONFIG.NUM_SI {1} \
  ] $smartconnect_dma


  # Create interface connections
  connect_bd_intf_net -intf_net axi_apb_bridge_APB_M [get_bd_intf_pins axi_apb_bridge/APB_M] [get_bd_intf_pins hbm/SAPB_0]
  connect_bd_intf_net -intf_net axi_apb_bridge_APB_M2 [get_bd_intf_pins axi_apb_bridge/APB_M2] [get_bd_intf_pins hbm/SAPB_1]
  connect_bd_intf_net -intf_net shell_axi_dma_1 [get_bd_intf_ports shell_axi_dma] [get_bd_intf_pins smartconnect_dma/S00_AXI]
  connect_bd_intf_net -intf_net shell_axil_ctrl_1 [get_bd_intf_ports shell_axil_ctrl] [get_bd_intf_pins smartconnect_ctrl/S00_AXI]
  connect_bd_intf_net -intf_net smartconnect_ctrl_M00_AXI [get_bd_intf_pins axi_apb_bridge/AXI4_LITE] [get_bd_intf_pins smartconnect_ctrl/M00_AXI]
  connect_bd_intf_net -intf_net smartconnect_dma_M00_AXI [get_bd_intf_pins hbm/SAXI_31] [get_bd_intf_pins smartconnect_dma/M00_AXI]

  # Create port connections
  connect_bd_net -net hbm_DRAM_0_STAT_CATTRIP [get_bd_pins hbm/DRAM_0_STAT_CATTRIP] [get_bd_pins hbm_cattrip/Op1]
  connect_bd_net -net hbm_DRAM_0_STAT_TEMP [get_bd_ports user_hbm_temp_0] [get_bd_pins hbm/DRAM_0_STAT_TEMP]
  connect_bd_net -net hbm_DRAM_1_STAT_CATTRIP [get_bd_pins hbm/DRAM_1_STAT_CATTRIP] [get_bd_pins hbm_cattrip/Op2]
  connect_bd_net -net hbm_DRAM_1_STAT_TEMP [get_bd_ports user_hbm_temp_1] [get_bd_pins hbm/DRAM_1_STAT_TEMP]
  connect_bd_net -net hbm_cattrip_Res [get_bd_ports user_hbm_cattrip] [get_bd_pins hbm_cattrip/Res]
  connect_bd_net -net hbm_refclk_buf_IBUF_OUT [get_bd_ports shell_refclk_0] [get_bd_pins axi_apb_bridge/s_axi_aclk] [get_bd_pins hbm/APB_0_PCLK] [get_bd_pins hbm/APB_1_PCLK] [get_bd_pins hbm/HBM_REF_CLK_0] [get_bd_pins hbm/HBM_REF_CLK_1] [get_bd_pins hbm_reset/slowest_sync_clk] [get_bd_pins smartconnect_ctrl/aclk1]
  connect_bd_net -net shell_axi_clk_1 [get_bd_ports shell_axi_clk] [get_bd_pins hbm/AXI_31_ACLK] [get_bd_pins smartconnect_ctrl/aclk] [get_bd_pins smartconnect_dma/aclk]
  connect_bd_net -net shell_rstn_1 [get_bd_ports shell_rstn] [get_bd_pins hbm_reset/ext_reset_in] [get_bd_pins smartconnect_ctrl/aresetn] [get_bd_pins smartconnect_dma/aresetn]
  connect_bd_net -net sys_reset_peripheral_aresetn [get_bd_pins axi_apb_bridge/s_axi_aresetn] [get_bd_pins hbm/APB_0_PRESET_N] [get_bd_pins hbm/APB_1_PRESET_N] [get_bd_pins hbm/AXI_31_ARESET_N] [get_bd_pins hbm_reset/peripheral_aresetn]

  # Create address segments
  assign_bd_address -offset 0x00000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces shell_axi_dma] [get_bd_addr_segs hbm/SAXI_31/HBM_MEM00] -force
  assign_bd_address -offset 0x10000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces shell_axi_dma] [get_bd_addr_segs hbm/SAXI_31/HBM_MEM01] -force
  assign_bd_address -offset 0x20000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces shell_axi_dma] [get_bd_addr_segs hbm/SAXI_31/HBM_MEM02] -force
  assign_bd_address -offset 0x30000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces shell_axi_dma] [get_bd_addr_segs hbm/SAXI_31/HBM_MEM03] -force
  assign_bd_address -offset 0x40000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces shell_axi_dma] [get_bd_addr_segs hbm/SAXI_31/HBM_MEM04] -force
  assign_bd_address -offset 0x50000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces shell_axi_dma] [get_bd_addr_segs hbm/SAXI_31/HBM_MEM05] -force
  assign_bd_address -offset 0x60000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces shell_axi_dma] [get_bd_addr_segs hbm/SAXI_31/HBM_MEM06] -force
  assign_bd_address -offset 0x70000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces shell_axi_dma] [get_bd_addr_segs hbm/SAXI_31/HBM_MEM07] -force
  assign_bd_address -offset 0x80000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces shell_axi_dma] [get_bd_addr_segs hbm/SAXI_31/HBM_MEM08] -force
  assign_bd_address -offset 0x90000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces shell_axi_dma] [get_bd_addr_segs hbm/SAXI_31/HBM_MEM09] -force
  assign_bd_address -offset 0xA0000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces shell_axi_dma] [get_bd_addr_segs hbm/SAXI_31/HBM_MEM10] -force
  assign_bd_address -offset 0xB0000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces shell_axi_dma] [get_bd_addr_segs hbm/SAXI_31/HBM_MEM11] -force
  assign_bd_address -offset 0xC0000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces shell_axi_dma] [get_bd_addr_segs hbm/SAXI_31/HBM_MEM12] -force
  assign_bd_address -offset 0xD0000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces shell_axi_dma] [get_bd_addr_segs hbm/SAXI_31/HBM_MEM13] -force
  assign_bd_address -offset 0xE0000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces shell_axi_dma] [get_bd_addr_segs hbm/SAXI_31/HBM_MEM14] -force
  assign_bd_address -offset 0xF0000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces shell_axi_dma] [get_bd_addr_segs hbm/SAXI_31/HBM_MEM15] -force
  assign_bd_address -offset 0x000100000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces shell_axi_dma] [get_bd_addr_segs hbm/SAXI_31/HBM_MEM16] -force
  assign_bd_address -offset 0x000110000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces shell_axi_dma] [get_bd_addr_segs hbm/SAXI_31/HBM_MEM17] -force
  assign_bd_address -offset 0x000120000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces shell_axi_dma] [get_bd_addr_segs hbm/SAXI_31/HBM_MEM18] -force
  assign_bd_address -offset 0x000130000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces shell_axi_dma] [get_bd_addr_segs hbm/SAXI_31/HBM_MEM19] -force
  assign_bd_address -offset 0x000140000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces shell_axi_dma] [get_bd_addr_segs hbm/SAXI_31/HBM_MEM20] -force
  assign_bd_address -offset 0x000150000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces shell_axi_dma] [get_bd_addr_segs hbm/SAXI_31/HBM_MEM21] -force
  assign_bd_address -offset 0x000160000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces shell_axi_dma] [get_bd_addr_segs hbm/SAXI_31/HBM_MEM22] -force
  assign_bd_address -offset 0x000170000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces shell_axi_dma] [get_bd_addr_segs hbm/SAXI_31/HBM_MEM23] -force
  assign_bd_address -offset 0x000180000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces shell_axi_dma] [get_bd_addr_segs hbm/SAXI_31/HBM_MEM24] -force
  assign_bd_address -offset 0x000190000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces shell_axi_dma] [get_bd_addr_segs hbm/SAXI_31/HBM_MEM25] -force
  assign_bd_address -offset 0x0001A0000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces shell_axi_dma] [get_bd_addr_segs hbm/SAXI_31/HBM_MEM26] -force
  assign_bd_address -offset 0x0001B0000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces shell_axi_dma] [get_bd_addr_segs hbm/SAXI_31/HBM_MEM27] -force
  assign_bd_address -offset 0x0001C0000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces shell_axi_dma] [get_bd_addr_segs hbm/SAXI_31/HBM_MEM28] -force
  assign_bd_address -offset 0x0001D0000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces shell_axi_dma] [get_bd_addr_segs hbm/SAXI_31/HBM_MEM29] -force
  assign_bd_address -offset 0x0001E0000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces shell_axi_dma] [get_bd_addr_segs hbm/SAXI_31/HBM_MEM30] -force
  assign_bd_address -offset 0x0001F0000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces shell_axi_dma] [get_bd_addr_segs hbm/SAXI_31/HBM_MEM31] -force
  assign_bd_address -offset 0x00000000 -range 0x00400000 -target_address_space [get_bd_addr_spaces shell_axil_ctrl] [get_bd_addr_segs hbm/SAPB_0/Reg] -force
  assign_bd_address -offset 0x00400000 -range 0x00400000 -target_address_space [get_bd_addr_spaces shell_axil_ctrl] [get_bd_addr_segs hbm/SAPB_1/Reg] -force


  # Restore current instance
  current_bd_instance $oldCurInst

  validate_bd_design
  save_bd_design
  close_bd_design $design_name 
}
# End of cr_bd_user()