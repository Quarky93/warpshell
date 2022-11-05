# Proc to create BD user_logic
proc cr_bd_user_logic { parentCell } {

  # CHANGE DESIGN NAME HERE
  set design_name user_logic

  common::send_gid_msg -ssname BD::TCL -id 2010 -severity "INFO" "Currently there is no design <$design_name> in project, so creating one..."

  create_bd_design $design_name

  set bCheckIPsPassed 1
  ##################################################################
  # CHECK IPs
  ##################################################################
  set bCheckIPs 1
  if { $bCheckIPs == 1 } {
     set list_check_ips "\ 
  xilinx.com:ip:axi_register_slice:2.1\
  xilinx.com:ip:axi_bram_ctrl:4.1\
  xilinx.com:ip:blk_mem_gen:8.4\
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
  set user_axi_ctrl [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 user_axi_ctrl ]
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
   ] $user_axi_ctrl

  set user_axi_dma [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 user_axi_dma ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {64} \
   CONFIG.ARUSER_WIDTH {0} \
   CONFIG.AWUSER_WIDTH {0} \
   CONFIG.BUSER_WIDTH {0} \
   CONFIG.DATA_WIDTH {256} \
   CONFIG.FREQ_HZ {250000000} \
   CONFIG.HAS_BRESP {1} \
   CONFIG.HAS_BURST {0} \
   CONFIG.HAS_CACHE {0} \
   CONFIG.HAS_LOCK {0} \
   CONFIG.HAS_PROT {0} \
   CONFIG.HAS_QOS {0} \
   CONFIG.HAS_REGION {0} \
   CONFIG.HAS_RRESP {1} \
   CONFIG.HAS_WSTRB {1} \
   CONFIG.ID_WIDTH {0} \
   CONFIG.MAX_BURST_LENGTH {256} \
   CONFIG.NUM_READ_OUTSTANDING {32} \
   CONFIG.NUM_READ_THREADS {1} \
   CONFIG.NUM_WRITE_OUTSTANDING {16} \
   CONFIG.NUM_WRITE_THREADS {1} \
   CONFIG.PROTOCOL {AXI4} \
   CONFIG.READ_WRITE_MODE {READ_WRITE} \
   CONFIG.RUSER_BITS_PER_BYTE {0} \
   CONFIG.RUSER_WIDTH {0} \
   CONFIG.SUPPORTS_NARROW_BURST {0} \
   CONFIG.WUSER_BITS_PER_BYTE {0} \
   CONFIG.WUSER_WIDTH {0} \
   ] $user_axi_dma

  set user_axi_hbm_s31 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 user_axi_hbm_s31 ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {33} \
   CONFIG.DATA_WIDTH {256} \
   CONFIG.FREQ_HZ {450000000} \
   CONFIG.HAS_CACHE {0} \
   CONFIG.HAS_LOCK {0} \
   CONFIG.HAS_PROT {0} \
   CONFIG.HAS_QOS {0} \
   CONFIG.HAS_REGION {0} \
   CONFIG.NUM_READ_OUTSTANDING {2} \
   CONFIG.NUM_WRITE_OUTSTANDING {2} \
   CONFIG.PROTOCOL {AXI3} \
   ] $user_axi_hbm_s31


  # Create ports
  set user_axi_clk [ create_bd_port -dir I -type clk -freq_hz 250000000 user_axi_clk ]
  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {user_axi_dma:user_axi_ctrl} \
   CONFIG.ASSOCIATED_RESET {user_axi_rstn} \
 ] $user_axi_clk
  set user_axi_hbm_clk [ create_bd_port -dir I -type clk -freq_hz 450000000 user_axi_hbm_clk ]
  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {user_axi_hbm_s31} \
 ] $user_axi_hbm_clk
  set user_axi_rstn [ create_bd_port -dir I -type rst user_axi_rstn ]

  # Create instance: ctrl_slice, and set properties
  set ctrl_slice [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_register_slice:2.1 ctrl_slice ]

  # Create instance: dma_pipe, and set properties
  set dma_pipe [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_register_slice:2.1 dma_pipe ]

  # Create instance: dummy_bram_controller, and set properties
  set dummy_bram_controller [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.1 dummy_bram_controller ]
  set_property CONFIG.PROTOCOL {AXI4LITE} $dummy_bram_controller


  # Create instance: dummy_bram_controller_bram, and set properties
  set dummy_bram_controller_bram [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.4 dummy_bram_controller_bram ]
  set_property CONFIG.Memory_Type {True_Dual_Port_RAM} $dummy_bram_controller_bram


  # Create instance: smartconnect_dma, and set properties
  set smartconnect_dma [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 smartconnect_dma ]
  set_property -dict [list \
    CONFIG.NUM_CLKS {2} \
    CONFIG.NUM_MI {1} \
    CONFIG.NUM_SI {1} \
  ] $smartconnect_dma


  # Create interface connections
  connect_bd_intf_net -intf_net ctrl_slice_M_AXI [get_bd_intf_pins ctrl_slice/M_AXI] [get_bd_intf_pins dummy_bram_controller/S_AXI]
  connect_bd_intf_net -intf_net dma_pipe_M_AXI [get_bd_intf_pins dma_pipe/M_AXI] [get_bd_intf_pins smartconnect_dma/S00_AXI]
  connect_bd_intf_net -intf_net dummy_bram_controller_BRAM_PORTA [get_bd_intf_pins dummy_bram_controller/BRAM_PORTA] [get_bd_intf_pins dummy_bram_controller_bram/BRAM_PORTA]
  connect_bd_intf_net -intf_net dummy_bram_controller_BRAM_PORTB [get_bd_intf_pins dummy_bram_controller/BRAM_PORTB] [get_bd_intf_pins dummy_bram_controller_bram/BRAM_PORTB]
  connect_bd_intf_net -intf_net smartconnect_dma_M00_AXI [get_bd_intf_ports user_axi_hbm_s31] [get_bd_intf_pins smartconnect_dma/M00_AXI]
  connect_bd_intf_net -intf_net user_axi_ctrl_1 [get_bd_intf_ports user_axi_ctrl] [get_bd_intf_pins ctrl_slice/S_AXI]
  connect_bd_intf_net -intf_net user_axi_dma_1 [get_bd_intf_ports user_axi_dma] [get_bd_intf_pins dma_pipe/S_AXI]

  # Create port connections
  connect_bd_net -net dma_reset_peripheral_aresetn [get_bd_ports user_axi_rstn] [get_bd_pins ctrl_slice/aresetn] [get_bd_pins dma_pipe/aresetn] [get_bd_pins dummy_bram_controller/s_axi_aresetn] [get_bd_pins smartconnect_dma/aresetn]
  connect_bd_net -net user_axi_clk_1 [get_bd_ports user_axi_clk] [get_bd_pins ctrl_slice/aclk] [get_bd_pins dma_pipe/aclk] [get_bd_pins dummy_bram_controller/s_axi_aclk] [get_bd_pins smartconnect_dma/aclk]
  connect_bd_net -net user_axi_hbm_clk_1 [get_bd_ports user_axi_hbm_clk] [get_bd_pins smartconnect_dma/aclk1]

  # Create address segments
  assign_bd_address -offset 0x01000000 -range 0x00008000 -target_address_space [get_bd_addr_spaces user_axi_ctrl] [get_bd_addr_segs dummy_bram_controller/S_AXI/Mem0] -force
  assign_bd_address -external -dict [list offset 0x00000000 range 0x40000000 offset 0x000100000000 range 0x000100000000 offset 0x40000000 range 0x20000000 offset 0x60000000 range 0x10000000 offset 0x70000000 range 0x10000000 offset 0x80000000 range 0x80000000] -target_address_space [get_bd_addr_spaces user_axi_dma] [get_bd_addr_segs user_axi_hbm_s31/Reg] -force

  set_property USAGE memory [get_bd_addr_segs user_axi_hbm_s31/Reg]


  # Restore current instance
  current_bd_instance $oldCurInst

  validate_bd_design
  save_bd_design
  close_bd_design $design_name 
}
# End of cr_bd_user_logic()