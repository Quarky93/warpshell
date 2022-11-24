# Proc to create BD shell
proc cr_bd_shell { parentCell } {

  # CHANGE DESIGN NAME HERE
  set design_name shell

  common::send_gid_msg -ssname BD::TCL -id 2010 -severity "INFO" "Currently there is no design <$design_name> in project, so creating one..."

  create_bd_design $design_name

  set bCheckIPsPassed 1
  ##################################################################
  # CHECK IPs
  ##################################################################
  set bCheckIPs 1
  if { $bCheckIPs == 1 } {
     set list_check_ips "\ 
  xilinx.com:ip:cms_subsystem:4.0\
  xilinx.com:ip:axi_firewall:1.2\
  xilinx.com:ip:debug_bridge:3.0\
  xilinx.com:ip:dfx_decoupler:1.0\
  xilinx.com:ip:axi_hbicap:1.0\
  xilinx.com:ip:util_vector_logic:2.0\
  xilinx.com:ip:clk_wiz:6.0\
  xilinx.com:ip:axi_bram_ctrl:4.1\
  xilinx.com:ip:blk_mem_gen:8.4\
  xilinx.com:ip:util_ds_buf:2.2\
  xilinx.com:ip:axi_quad_spi:3.2\
  xilinx.com:ip:proc_sys_reset:5.0\
  xilinx.com:ip:smartconnect:1.0\
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
  set pcie_mgt [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:pcie_7x_mgt_rtl:1.0 pcie_mgt ]

  set pcie_refclk [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 pcie_refclk ]

  set satellite_uart [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:uart_rtl:1.0 satellite_uart ]

  set shell_axi_dma [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 shell_axi_dma ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {64} \
   CONFIG.DATA_WIDTH {256} \
   CONFIG.HAS_QOS {1} \
   CONFIG.HAS_REGION {0} \
   CONFIG.NUM_READ_OUTSTANDING {32} \
   CONFIG.NUM_WRITE_OUTSTANDING {32} \
   CONFIG.PROTOCOL {AXI4} \
   ] $shell_axi_dma

  set shell_axil_ctrl [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 shell_axil_ctrl ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {32} \
   CONFIG.DATA_WIDTH {32} \
   CONFIG.HAS_BRESP {1} \
   CONFIG.HAS_BURST {0} \
   CONFIG.HAS_CACHE {0} \
   CONFIG.HAS_LOCK {0} \
   CONFIG.HAS_PROT {1} \
   CONFIG.HAS_QOS {0} \
   CONFIG.HAS_REGION {0} \
   CONFIG.HAS_RRESP {1} \
   CONFIG.PROTOCOL {AXI4LITE} \
   ] $shell_axil_ctrl

  set sys_refclk_0 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 sys_refclk_0 ]


  # Create ports
  set pcie_rstn [ create_bd_port -dir I -type rst pcie_rstn ]
  set satellite_gpio [ create_bd_port -dir I -from 3 -to 0 -type intr satellite_gpio ]
  set_property -dict [ list \
   CONFIG.PortWidth {4} \
   CONFIG.SENSITIVITY {EDGE_RISING} \
 ] $satellite_gpio
  set shell_axi_clk [ create_bd_port -dir O -type clk shell_axi_clk ]
  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {shell_axi_dma:shell_axil_ctrl} \
   CONFIG.ASSOCIATED_RESET {shell_rstn} \
 ] $shell_axi_clk
  set shell_refclk_0 [ create_bd_port -dir O -from 0 -to 0 -type clk shell_refclk_0 ]
  set shell_rstn [ create_bd_port -dir O -from 0 -to 0 -type rst shell_rstn ]
  set user_hbm_cattrip [ create_bd_port -dir I -type intr user_hbm_cattrip ]
  set user_hbm_temp_0 [ create_bd_port -dir I -from 6 -to 0 user_hbm_temp_0 ]
  set user_hbm_temp_1 [ create_bd_port -dir I -from 6 -to 0 user_hbm_temp_1 ]

  # Create instance: cms, and set properties
  set cms [ create_bd_cell -type ip -vlnv xilinx.com:ip:cms_subsystem:4.0 cms ]

  # Create instance: ctrl_firewall, and set properties
  set ctrl_firewall [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_firewall:1.2 ctrl_firewall ]
  set_property -dict [list \
    CONFIG.ADDR_WIDTH {32} \
    CONFIG.DATA_WIDTH {32} \
    CONFIG.ENABLE_PRESCALER {0} \
    CONFIG.ENABLE_PROTOCOL_CHECKS {1} \
    CONFIG.FIREWALL_MODE {MI_SIDE} \
    CONFIG.HAS_ARESETN {1} \
    CONFIG.HAS_BRESP {1} \
    CONFIG.HAS_BURST {0} \
    CONFIG.HAS_CACHE {0} \
    CONFIG.HAS_LOCK {0} \
    CONFIG.HAS_PROT {1} \
    CONFIG.HAS_QOS {0} \
    CONFIG.HAS_REGION {0} \
    CONFIG.HAS_RRESP {1} \
    CONFIG.HAS_WSTRB {1} \
    CONFIG.PROTOCOL {AXI4LITE} \
    CONFIG.READ_WRITE_MODE {READ_WRITE} \
    CONFIG.SUPPORTS_NARROW {0} \
  ] $ctrl_firewall


  # Create instance: debug_bridge, and set properties
  set debug_bridge [ create_bd_cell -type ip -vlnv xilinx.com:ip:debug_bridge:3.0 debug_bridge ]
  set_property -dict [list \
    CONFIG.C_DEBUG_MODE {5} \
    CONFIG.C_DESIGN_TYPE {0} \
  ] $debug_bridge


  # Create instance: dfx_decoupler, and set properties
  set dfx_decoupler [ create_bd_cell -type ip -vlnv xilinx.com:ip:dfx_decoupler:1.0 dfx_decoupler ]
  set_property -dict [list \
    CONFIG.ALL_PARAMS {HAS_AXI_LITE 1 INTF {hbm_cattrip {ID 0 VLNV xilinx.com:signal:interrupt_rtl:1.0 SIGNALS {INTERRUPT {PRESENT 1 WIDTH 1}}} hbm_temp_0 {ID 1 VLNV xilinx.com:signal:data_rtl:1.0 SIGNALS\
{DATA {PRESENT 1 WIDTH 7}}} hbm_temp_1 {ID 2 VLNV xilinx.com:signal:data_rtl:1.0 SIGNALS {DATA {PRESENT 1 WIDTH 7}}}} HAS_SIGNAL_CONTROL 0 HAS_SIGNAL_STATUS 1 IPI_PROP_COUNT 0} \
    CONFIG.GUI_INTERFACE_NAME {hbm_cattrip} \
    CONFIG.GUI_SELECT_VLNV {xilinx.com:signal:interrupt_rtl:1.0} \
  ] $dfx_decoupler


  # Create instance: dma_firewall, and set properties
  set dma_firewall [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_firewall:1.2 dma_firewall ]
  set_property -dict [list \
    CONFIG.ADDR_WIDTH {64} \
    CONFIG.ARUSER_WIDTH {0} \
    CONFIG.AWUSER_WIDTH {0} \
    CONFIG.BUSER_WIDTH {0} \
    CONFIG.DATA_WIDTH {256} \
    CONFIG.ENABLE_PRESCALER {0} \
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
    CONFIG.NUM_READ_OUTSTANDING {32} \
    CONFIG.NUM_READ_THREADS {1} \
    CONFIG.NUM_WRITE_OUTSTANDING {32} \
    CONFIG.NUM_WRITE_THREADS {1} \
    CONFIG.PROTOCOL {AXI4} \
    CONFIG.READ_WRITE_MODE {READ_WRITE} \
    CONFIG.RUSER_WIDTH {0} \
    CONFIG.SUPPORTS_NARROW {0} \
    CONFIG.WUSER_WIDTH {0} \
  ] $dma_firewall


  # Create instance: hbicap, and set properties
  set hbicap [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_hbicap:1.0 hbicap ]
  set_property -dict [list \
    CONFIG.C_ICAP_EXTERNAL {0} \
    CONFIG.C_INCLUDE_STARTUP {0} \
    CONFIG.C_READ_PATH {0} \
    CONFIG.C_WRITE_FIFO_DEPTH {1024} \
  ] $hbicap


  # Create instance: inv_decouple_status, and set properties
  set inv_decouple_status [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 inv_decouple_status ]
  set_property -dict [list \
    CONFIG.C_OPERATION {not} \
    CONFIG.C_SIZE {1} \
  ] $inv_decouple_status


  # Create instance: mgmt_clk_wiz, and set properties
  set mgmt_clk_wiz [ create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:6.0 mgmt_clk_wiz ]
  set_property -dict [list \
    CONFIG.AXI_DRP {false} \
    CONFIG.CLKOUT1_JITTER {102.484} \
    CONFIG.CLKOUT1_PHASE_ERROR {79.008} \
    CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {100} \
    CONFIG.CLKOUT2_JITTER {98.122} \
    CONFIG.CLKOUT2_PHASE_ERROR {79.008} \
    CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {125} \
    CONFIG.CLKOUT2_USED {true} \
    CONFIG.CLK_OUT1_PORT {spi_clk} \
    CONFIG.CLK_OUT2_PORT {icap_clk} \
    CONFIG.MMCM_CLKFBOUT_MULT_F {5.000} \
    CONFIG.MMCM_CLKOUT0_DIVIDE_F {12.500} \
    CONFIG.MMCM_CLKOUT1_DIVIDE {10} \
    CONFIG.MMCM_DIVCLK_DIVIDE {1} \
    CONFIG.NUM_OUT_CLKS {2} \
    CONFIG.PHASE_DUTY_CONFIG {false} \
    CONFIG.RESET_PORT {resetn} \
    CONFIG.RESET_TYPE {ACTIVE_LOW} \
    CONFIG.USE_DYN_RECONFIG {false} \
  ] $mgmt_clk_wiz


  # Create instance: mgmt_ram, and set properties
  set mgmt_ram [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.1 mgmt_ram ]
  set_property -dict [list \
    CONFIG.PROTOCOL {AXI4LITE} \
    CONFIG.SINGLE_PORT_BRAM {1} \
  ] $mgmt_ram


  # Create instance: mgmt_ram_bram, and set properties
  set mgmt_ram_bram [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.4 mgmt_ram_bram ]

  # Create instance: pcie_refclk_buf, and set properties
  set pcie_refclk_buf [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_ds_buf:2.2 pcie_refclk_buf ]
  set_property CONFIG.C_BUF_TYPE {IBUFDSGTE} $pcie_refclk_buf


  # Create instance: qspi, and set properties
  set qspi [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_quad_spi:3.2 qspi ]
  set_property -dict [list \
    CONFIG.C_FIFO_DEPTH {256} \
    CONFIG.C_SPI_MEMORY {2} \
    CONFIG.C_SPI_MODE {2} \
    CONFIG.C_USE_STARTUP {1} \
    CONFIG.C_USE_STARTUP_INT {1} \
  ] $qspi


  # Create instance: shell_resetn, and set properties
  set shell_resetn [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 shell_resetn ]

  # Create instance: smartconnect_ctrl, and set properties
  set smartconnect_ctrl [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 smartconnect_ctrl ]
  set_property -dict [list \
    CONFIG.NUM_MI {8} \
    CONFIG.NUM_SI {1} \
  ] $smartconnect_ctrl


  # Create instance: smartconnect_dma, and set properties
  set smartconnect_dma [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 smartconnect_dma ]
  set_property -dict [list \
    CONFIG.NUM_MI {2} \
    CONFIG.NUM_SI {1} \
  ] $smartconnect_dma


  # Create instance: sys_refclk_0_buf, and set properties
  set sys_refclk_0_buf [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_ds_buf:2.2 sys_refclk_0_buf ]

  # Create instance: xdma, and set properties
  set xdma [ create_bd_cell -type ip -vlnv xilinx.com:ip:xdma:4.1 xdma ]
  set_property -dict [list \
    CONFIG.axi_data_width {256_bit} \
    CONFIG.axilite_master_en {true} \
    CONFIG.axilite_master_size {128} \
    CONFIG.cfg_ext_if {true} \
    CONFIG.cfg_mgmt_if {false} \
    CONFIG.pcie_blk_locn {PCIE4C_X1Y1} \
    CONFIG.pf0_Use_Class_Code_Lookup_Assistant {true} \
    CONFIG.pf0_base_class_menu {Processing_accelerators} \
    CONFIG.pl_link_cap_max_link_speed {8.0_GT/s} \
    CONFIG.pl_link_cap_max_link_width {X8} \
  ] $xdma


  # Create interface connections
  connect_bd_intf_net -intf_net CLK_IN_D_0_1 [get_bd_intf_ports pcie_refclk] [get_bd_intf_pins pcie_refclk_buf/CLK_IN_D]
  connect_bd_intf_net -intf_net cms_satellite_uart [get_bd_intf_ports satellite_uart] [get_bd_intf_pins cms/satellite_uart]
  connect_bd_intf_net -intf_net ctrl_firewall_M_AXI [get_bd_intf_ports shell_axil_ctrl] [get_bd_intf_pins ctrl_firewall/M_AXI]
  connect_bd_intf_net -intf_net dma_firewall_M_AXI [get_bd_intf_ports shell_axi_dma] [get_bd_intf_pins dma_firewall/M_AXI]
  connect_bd_intf_net -intf_net mgmt_ram_BRAM_PORTA [get_bd_intf_pins mgmt_ram/BRAM_PORTA] [get_bd_intf_pins mgmt_ram_bram/BRAM_PORTA]
  connect_bd_intf_net -intf_net smartconnect_ctrl_M00_AXI [get_bd_intf_pins cms/s_axi_ctrl] [get_bd_intf_pins smartconnect_ctrl/M00_AXI]
  connect_bd_intf_net -intf_net smartconnect_ctrl_M01_AXI [get_bd_intf_pins qspi/AXI_LITE] [get_bd_intf_pins smartconnect_ctrl/M01_AXI]
  connect_bd_intf_net -intf_net smartconnect_ctrl_M02_AXI [get_bd_intf_pins hbicap/S_AXI_CTRL] [get_bd_intf_pins smartconnect_ctrl/M02_AXI]
  connect_bd_intf_net -intf_net smartconnect_ctrl_M03_AXI [get_bd_intf_pins mgmt_ram/S_AXI] [get_bd_intf_pins smartconnect_ctrl/M03_AXI]
  connect_bd_intf_net -intf_net smartconnect_ctrl_M04_AXI [get_bd_intf_pins ctrl_firewall/S_AXI_CTL] [get_bd_intf_pins smartconnect_ctrl/M04_AXI]
  connect_bd_intf_net -intf_net smartconnect_ctrl_M05_AXI [get_bd_intf_pins dma_firewall/S_AXI_CTL] [get_bd_intf_pins smartconnect_ctrl/M05_AXI]
  connect_bd_intf_net -intf_net smartconnect_ctrl_M06_AXI [get_bd_intf_pins dfx_decoupler/s_axi_reg] [get_bd_intf_pins smartconnect_ctrl/M06_AXI]
  connect_bd_intf_net -intf_net smartconnect_ctrl_M07_AXI [get_bd_intf_pins ctrl_firewall/S_AXI] [get_bd_intf_pins smartconnect_ctrl/M07_AXI]
  connect_bd_intf_net -intf_net smartconnect_dma_M00_AXI [get_bd_intf_pins hbicap/S_AXI] [get_bd_intf_pins smartconnect_dma/M00_AXI]
  connect_bd_intf_net -intf_net smartconnect_dma_M01_AXI [get_bd_intf_pins dma_firewall/S_AXI] [get_bd_intf_pins smartconnect_dma/M01_AXI]
  connect_bd_intf_net -intf_net sys_refclk_0 [get_bd_intf_ports sys_refclk_0] [get_bd_intf_pins sys_refclk_0_buf/CLK_IN_D]
  connect_bd_intf_net -intf_net xdma_M_AXI [get_bd_intf_pins smartconnect_dma/S00_AXI] [get_bd_intf_pins xdma/M_AXI]
  connect_bd_intf_net -intf_net xdma_M_AXI_LITE [get_bd_intf_pins smartconnect_ctrl/S00_AXI] [get_bd_intf_pins xdma/M_AXI_LITE]
  connect_bd_intf_net -intf_net xdma_pcie_cfg_ext [get_bd_intf_pins debug_bridge/pcie3_cfg_ext] [get_bd_intf_pins xdma/pcie_cfg_ext]
  connect_bd_intf_net -intf_net xdma_pcie_mgt [get_bd_intf_ports pcie_mgt] [get_bd_intf_pins xdma/pcie_mgt]

  # Create port connections
  connect_bd_net -net decouple_status [get_bd_pins dfx_decoupler/decouple_status] [get_bd_pins inv_decouple_status/Op1]
  connect_bd_net -net eos [get_bd_pins hbicap/eos_in] [get_bd_pins qspi/eos]
  connect_bd_net -net hbm_cattrip [get_bd_pins cms/interrupt_hbm_cattrip] [get_bd_pins dfx_decoupler/s_hbm_cattrip_INTERRUPT]
  connect_bd_net -net hbm_temp_0 [get_bd_pins cms/hbm_temp_1] [get_bd_pins dfx_decoupler/s_hbm_temp_0_DATA]
  connect_bd_net -net hbm_temp_1 [get_bd_pins cms/hbm_temp_2] [get_bd_pins dfx_decoupler/s_hbm_temp_1_DATA]
  connect_bd_net -net icap_clk [get_bd_pins hbicap/icap_clk] [get_bd_pins mgmt_clk_wiz/icap_clk]
  connect_bd_net -net inv_decouple_status [get_bd_pins inv_decouple_status/Res] [get_bd_pins shell_resetn/ext_reset_in]
  connect_bd_net -net pcie_refclk_buf_IBUF_DS_ODIV2 [get_bd_pins pcie_refclk_buf/IBUF_DS_ODIV2] [get_bd_pins xdma/sys_clk]
  connect_bd_net -net pcie_refclk_buf_IBUF_OUT [get_bd_pins pcie_refclk_buf/IBUF_OUT] [get_bd_pins xdma/sys_clk_gt]
  connect_bd_net -net pcie_rstn [get_bd_ports pcie_rstn] [get_bd_pins xdma/sys_rst_n]
  connect_bd_net -net satellite_gpio [get_bd_ports satellite_gpio] [get_bd_pins cms/satellite_gpio]
  connect_bd_net -net shell_refclk_0 [get_bd_ports shell_refclk_0] [get_bd_pins sys_refclk_0_buf/IBUF_OUT]
  connect_bd_net -net shell_resetn_peripheral_aresetn [get_bd_ports shell_rstn] [get_bd_pins shell_resetn/peripheral_aresetn]
  connect_bd_net -net spi_clk [get_bd_pins mgmt_clk_wiz/spi_clk] [get_bd_pins qspi/ext_spi_clk]
  connect_bd_net -net user_hbm_cattrip [get_bd_ports user_hbm_cattrip] [get_bd_pins dfx_decoupler/rp_hbm_cattrip_INTERRUPT]
  connect_bd_net -net user_hbm_temp_0 [get_bd_ports user_hbm_temp_0] [get_bd_pins dfx_decoupler/rp_hbm_temp_0_DATA]
  connect_bd_net -net user_hbm_temp_1 [get_bd_ports user_hbm_temp_1] [get_bd_pins dfx_decoupler/rp_hbm_temp_1_DATA]
  connect_bd_net -net xdma_axi_aclk [get_bd_ports shell_axi_clk] [get_bd_pins cms/aclk_ctrl] [get_bd_pins ctrl_firewall/aclk] [get_bd_pins debug_bridge/clk] [get_bd_pins dfx_decoupler/aclk] [get_bd_pins dma_firewall/aclk] [get_bd_pins hbicap/s_axi_aclk] [get_bd_pins hbicap/s_axi_mm_aclk] [get_bd_pins mgmt_clk_wiz/clk_in1] [get_bd_pins mgmt_ram/s_axi_aclk] [get_bd_pins qspi/s_axi_aclk] [get_bd_pins shell_resetn/slowest_sync_clk] [get_bd_pins smartconnect_ctrl/aclk] [get_bd_pins smartconnect_dma/aclk] [get_bd_pins xdma/axi_aclk]
  connect_bd_net -net xdma_axi_aresetn [get_bd_pins cms/aresetn_ctrl] [get_bd_pins ctrl_firewall/aresetn] [get_bd_pins dfx_decoupler/s_axi_reg_aresetn] [get_bd_pins dma_firewall/aresetn] [get_bd_pins hbicap/s_axi_aresetn] [get_bd_pins hbicap/s_axi_mm_aresetn] [get_bd_pins mgmt_clk_wiz/resetn] [get_bd_pins mgmt_ram/s_axi_aresetn] [get_bd_pins qspi/s_axi_aresetn] [get_bd_pins smartconnect_ctrl/aresetn] [get_bd_pins smartconnect_dma/aresetn] [get_bd_pins xdma/axi_aresetn]

  # Create address segments
  assign_bd_address -offset 0x1000000000000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces xdma/M_AXI] [get_bd_addr_segs hbicap/S_AXI/Mem0] -force
  assign_bd_address -offset 0x00000000 -range 0x0001000000000000 -target_address_space [get_bd_addr_spaces xdma/M_AXI] [get_bd_addr_segs shell_axi_dma/Reg] -force
  assign_bd_address -offset 0x04000000 -range 0x00040000 -target_address_space [get_bd_addr_spaces xdma/M_AXI_LITE] [get_bd_addr_segs cms/s_axi_ctrl/Mem] -force
  assign_bd_address -offset 0x04070000 -range 0x00010000 -target_address_space [get_bd_addr_spaces xdma/M_AXI_LITE] [get_bd_addr_segs ctrl_firewall/S_AXI_CTL/Control] -force
  assign_bd_address -offset 0x04090000 -range 0x00010000 -target_address_space [get_bd_addr_spaces xdma/M_AXI_LITE] [get_bd_addr_segs dfx_decoupler/s_axi_reg/Reg] -force
  assign_bd_address -offset 0x04080000 -range 0x00010000 -target_address_space [get_bd_addr_spaces xdma/M_AXI_LITE] [get_bd_addr_segs dma_firewall/S_AXI_CTL/Control] -force
  assign_bd_address -offset 0x04050000 -range 0x00010000 -target_address_space [get_bd_addr_spaces xdma/M_AXI_LITE] [get_bd_addr_segs hbicap/S_AXI_CTRL/Reg0] -force
  assign_bd_address -offset 0x04060000 -range 0x00002000 -target_address_space [get_bd_addr_spaces xdma/M_AXI_LITE] [get_bd_addr_segs mgmt_ram/S_AXI/Mem0] -force
  assign_bd_address -offset 0x04040000 -range 0x00010000 -target_address_space [get_bd_addr_spaces xdma/M_AXI_LITE] [get_bd_addr_segs qspi/AXI_LITE/Reg] -force
  assign_bd_address -offset 0x00000000 -range 0x04000000 -target_address_space [get_bd_addr_spaces xdma/M_AXI_LITE] [get_bd_addr_segs shell_axil_ctrl/Reg] -force


  # Restore current instance
  current_bd_instance $oldCurInst

  validate_bd_design
  save_bd_design
  close_bd_design $design_name 
}
# End of cr_bd_shell()