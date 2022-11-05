# Proc to create BD shell
proc cr_bd_shell { parentCell } {
# The design that will be created by this Tcl proc contains the following 
# block design container source references:
# user_logic



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
  xilinx.com:ip:proc_sys_reset:5.0\
  xilinx.com:ip:axi_apb_bridge:3.0\
  xilinx.com:ip:util_vector_logic:2.0\
  xilinx.com:ip:cms_subsystem:4.0\
  xilinx.com:ip:clk_wiz:6.0\
  xilinx.com:ip:axi_firewall:1.2\
  xilinx.com:ip:debug_bridge:3.0\
  xilinx.com:ip:dfx_decoupler:1.0\
  xilinx.com:ip:axi_hbicap:1.0\
  xilinx.com:ip:hbm:1.0\
  xilinx.com:ip:util_ds_buf:2.2\
  xilinx.com:ip:axi_bram_ctrl:4.1\
  xilinx.com:ip:blk_mem_gen:8.4\
  xilinx.com:ip:axi_quad_spi:3.2\
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

  ##################################################################
  # CHECK Block Design Container Sources
  ##################################################################
  set bCheckSources 1
  set list_bdc_active "user_logic"

  array set map_bdc_missing {}
  set map_bdc_missing(ACTIVE) ""
  set map_bdc_missing(BDC) ""

  if { $bCheckSources == 1 } {
     set list_check_srcs "\ 
  user_logic \
  "

   common::send_gid_msg -ssname BD::TCL -id 2056 -severity "INFO" "Checking if the following sources for block design container exist in the project: $list_check_srcs .\n\n"

   foreach src $list_check_srcs {
      if { [can_resolve_reference $src] == 0 } {
         if { [lsearch $list_bdc_active $src] != -1 } {
            set map_bdc_missing(ACTIVE) "$map_bdc_missing(ACTIVE) $src"
         } else {
            set map_bdc_missing(BDC) "$map_bdc_missing(BDC) $src"
         }
      }
   }

   if { [llength $map_bdc_missing(ACTIVE)] > 0 } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2057 -severity "ERROR" "The following source(s) of Active variants are not found in the project: $map_bdc_missing(ACTIVE)" }
      common::send_gid_msg -ssname BD::TCL -id 2060 -severity "INFO" "Please add source files for the missing source(s) above."
      set bCheckIPsPassed 0
   }
   if { [llength $map_bdc_missing(BDC)] > 0 } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2059 -severity "WARNING" "The following source(s) of variants are not found in the project: $map_bdc_missing(BDC)" }
      common::send_gid_msg -ssname BD::TCL -id 2060 -severity "INFO" "Please add source files for the missing source(s) above."
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
  set hbm_refclk [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 hbm_refclk ]

  set pcie_mgt [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:pcie_7x_mgt_rtl:1.0 pcie_mgt ]

  set pcie_refclk [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 pcie_refclk ]

  set satellite_uart [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:uart_rtl:1.0 satellite_uart ]


  # Create ports
  set pcie_rstn [ create_bd_port -dir I -type rst pcie_rstn ]
  set satellite_gpio [ create_bd_port -dir I -from 3 -to 0 -type intr satellite_gpio ]
  set_property -dict [ list \
   CONFIG.PortWidth {4} \
   CONFIG.SENSITIVITY {EDGE_RISING} \
 ] $satellite_gpio

  # Create instance: apb_reset, and set properties
  set apb_reset [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 apb_reset ]

  # Create instance: axi_apb_bridge, and set properties
  set axi_apb_bridge [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_apb_bridge:3.0 axi_apb_bridge ]
  set_property CONFIG.C_APB_NUM_SLAVES {2} $axi_apb_bridge


  # Create instance: cattrip, and set properties
  set cattrip [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 cattrip ]
  set_property -dict [list \
    CONFIG.C_OPERATION {or} \
    CONFIG.C_SIZE {2} \
  ] $cattrip


  # Create instance: cms, and set properties
  set cms [ create_bd_cell -type ip -vlnv xilinx.com:ip:cms_subsystem:4.0 cms ]

  # Create instance: core_clk_wiz, and set properties
  set core_clk_wiz [ create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:6.0 core_clk_wiz ]
  set_property -dict [list \
    CONFIG.CLKOUT1_JITTER {104.289} \
    CONFIG.CLKOUT1_PHASE_ERROR {153.873} \
    CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {450} \
    CONFIG.CLK_OUT1_PORT {hbm_clk} \
    CONFIG.MMCM_CLKFBOUT_MULT_F {23.625} \
    CONFIG.MMCM_CLKOUT0_DIVIDE_F {2.625} \
    CONFIG.MMCM_DIVCLK_DIVIDE {5} \
    CONFIG.PRIM_SOURCE {Global_buffer} \
    CONFIG.RESET_PORT {reset} \
    CONFIG.RESET_TYPE {ACTIVE_HIGH} \
    CONFIG.USE_DYN_RECONFIG {true} \
  ] $core_clk_wiz


  # Create instance: ctrl_firewall, and set properties
  set ctrl_firewall [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_firewall:1.2 ctrl_firewall ]
  set_property -dict [list \
    CONFIG.ADDR_WIDTH {32} \
    CONFIG.DATA_WIDTH {32} \
    CONFIG.ENABLE_PRESCALER {0} \
    CONFIG.HAS_ARESETN {1} \
    CONFIG.HAS_BRESP {1} \
    CONFIG.HAS_BURST {0} \
    CONFIG.HAS_CACHE {0} \
    CONFIG.HAS_LOCK {0} \
    CONFIG.HAS_PROT {0} \
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
    CONFIG.ALL_PARAMS {HAS_AXI_LITE 1 HAS_SIGNAL_CONTROL 0 HAS_SIGNAL_STATUS 1 ALWAYS_HAVE_AXI_CLK 1 INTF {ctrl {ID 0 MODE slave VLNV xilinx.com:interface:aximm_rtl:1.0 PROTOCOL AXI4LITE SIGNALS {ARVALID\
{PRESENT 1 WIDTH 1} ARREADY {PRESENT 1 WIDTH 1} AWVALID {PRESENT 1 WIDTH 1} AWREADY {PRESENT 1 WIDTH 1} BVALID {PRESENT 1 WIDTH 1} BREADY {PRESENT 1 WIDTH 1} RVALID {PRESENT 1 WIDTH 1} RREADY {PRESENT\
1 WIDTH 1} WVALID {PRESENT 1 WIDTH 1} WREADY {PRESENT 1 WIDTH 1} AWADDR {PRESENT 1 WIDTH 32} AWLEN {PRESENT 0 WIDTH 8} AWSIZE {PRESENT 0 WIDTH 3} AWBURST {PRESENT 0 WIDTH 2} AWLOCK {PRESENT 0 WIDTH 1}\
AWCACHE {PRESENT 0 WIDTH 4} AWPROT {PRESENT 0 WIDTH 3} WDATA {PRESENT 1 WIDTH 32} WSTRB {PRESENT 1 WIDTH 4} WLAST {PRESENT 0 WIDTH 1} BRESP {PRESENT 1 WIDTH 2} ARADDR {PRESENT 1 WIDTH 32} ARLEN {PRESENT\
0 WIDTH 8} ARSIZE {PRESENT 0 WIDTH 3} ARBURST {PRESENT 0 WIDTH 2} ARLOCK {PRESENT 0 WIDTH 1} ARCACHE {PRESENT 0 WIDTH 4} ARPROT {PRESENT 0 WIDTH 3} RDATA {PRESENT 1 WIDTH 32} RRESP {PRESENT 1 WIDTH 2}\
RLAST {PRESENT 0 WIDTH 1} AWID {WIDTH 0 PRESENT 0} AWREGION {WIDTH 4 PRESENT 0} AWQOS {WIDTH 4 PRESENT 0} AWUSER {WIDTH 0 PRESENT 0} WID {WIDTH 0 PRESENT 0} WUSER {WIDTH 0 PRESENT 0} BID {WIDTH 0 PRESENT\
0} BUSER {WIDTH 0 PRESENT 0} ARID {WIDTH 0 PRESENT 0} ARREGION {WIDTH 4 PRESENT 0} ARQOS {WIDTH 4 PRESENT 0} ARUSER {WIDTH 0 PRESENT 0} RID {WIDTH 0 PRESENT 0} RUSER {WIDTH 0 PRESENT 0}} REGISTER 1} dma\
{ID 1 MODE slave VLNV xilinx.com:interface:aximm_rtl:1.0 PROTOCOL AXI4 SIGNALS {ARVALID {WIDTH 1 PRESENT 1} ARREADY {WIDTH 1 PRESENT 1} AWVALID {WIDTH 1 PRESENT 1} AWREADY {WIDTH 1 PRESENT 1} BVALID {WIDTH\
1 PRESENT 1} BREADY {WIDTH 1 PRESENT 1} RVALID {WIDTH 1 PRESENT 1} RREADY {WIDTH 1 PRESENT 1} WVALID {WIDTH 1 PRESENT 1} WREADY {WIDTH 1 PRESENT 1} AWID {WIDTH 0 PRESENT 0} AWADDR {WIDTH 64 PRESENT 1}\
AWLEN {WIDTH 8 PRESENT 1} AWSIZE {WIDTH 3 PRESENT 1} AWBURST {WIDTH 2 PRESENT 0} AWLOCK {WIDTH 1 PRESENT 0} AWCACHE {WIDTH 4 PRESENT 0} AWPROT {WIDTH 3 PRESENT 0} AWREGION {WIDTH 4 PRESENT 0} AWQOS {WIDTH\
4 PRESENT 0} AWUSER {WIDTH 0 PRESENT 0} WID {WIDTH 0 PRESENT 0} WDATA {WIDTH 256 PRESENT 1} WSTRB {WIDTH 32 PRESENT 1} WLAST {WIDTH 1 PRESENT 1} WUSER {WIDTH 0 PRESENT 0} BID {WIDTH 0 PRESENT 0} BRESP\
{WIDTH 2 PRESENT 1} BUSER {WIDTH 0 PRESENT 0} ARID {WIDTH 0 PRESENT 0} ARADDR {WIDTH 64 PRESENT 1} ARLEN {WIDTH 8 PRESENT 1} ARSIZE {WIDTH 3 PRESENT 1} ARBURST {WIDTH 2 PRESENT 0} ARLOCK {WIDTH 1 PRESENT\
0} ARCACHE {WIDTH 4 PRESENT 0} ARPROT {WIDTH 3 PRESENT 0} ARREGION {WIDTH 4 PRESENT 0} ARQOS {WIDTH 4 PRESENT 0} ARUSER {WIDTH 0 PRESENT 0} RID {WIDTH 0 PRESENT 0} RDATA {WIDTH 256 PRESENT 1} RRESP {WIDTH\
2 PRESENT 1} RLAST {WIDTH 1 PRESENT 1} RUSER {WIDTH 0 PRESENT 0}} REGISTER 1}} IPI_PROP_COUNT 7} \
    CONFIG.GUI_INTERFACE_NAME {ctrl} \
    CONFIG.GUI_SELECT_INTERFACE {0} \
    CONFIG.GUI_SELECT_MODE {slave} \
    CONFIG.GUI_SELECT_VLNV {xilinx.com:interface:aximm_rtl:1.0} \
  ] $dfx_decoupler


  # Create instance: dma_firewall, and set properties
  set dma_firewall [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_firewall:1.2 dma_firewall ]
  set_property -dict [list \
    CONFIG.ADDR_WIDTH {64} \
    CONFIG.ARUSER_WIDTH {0} \
    CONFIG.AWUSER_WIDTH {0} \
    CONFIG.BUSER_WIDTH {0} \
    CONFIG.DATA_WIDTH {256} \
    CONFIG.ENABLE_INITIAL_DELAY {1} \
    CONFIG.ENABLE_PRESCALER {0} \
    CONFIG.ENABLE_PROTOCOL_CHECKS {1} \
    CONFIG.HAS_ARESETN {1} \
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
    CONFIG.PROTOCOL {AXI4} \
    CONFIG.READ_WRITE_MODE {READ_WRITE} \
    CONFIG.RUSER_WIDTH {0} \
    CONFIG.SUPPORTS_NARROW {0} \
    CONFIG.WUSER_WIDTH {0} \
  ] $dma_firewall


  # Create instance: hbicap, and set properties
  set hbicap [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_hbicap:1.0 hbicap ]
  set_property -dict [list \
    CONFIG.C_READ_PATH {0} \
    CONFIG.C_WRITE_FIFO_DEPTH {1024} \
  ] $hbicap


  # Create instance: hbm, and set properties
  set hbm [ create_bd_cell -type ip -vlnv xilinx.com:ip:hbm:1.0 hbm ]
  set_property -dict [list \
    CONFIG.USER_APB_EN {true} \
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


  # Create instance: hbm_refclk_buf, and set properties
  set hbm_refclk_buf [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_ds_buf:2.2 hbm_refclk_buf ]

  # Create instance: mgmt_bram_ctrl, and set properties
  set mgmt_bram_ctrl [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.1 mgmt_bram_ctrl ]
  set_property -dict [list \
    CONFIG.PROTOCOL {AXI4LITE} \
    CONFIG.SINGLE_PORT_BRAM {1} \
  ] $mgmt_bram_ctrl


  # Create instance: mgmt_bram_ctrl_bram, and set properties
  set mgmt_bram_ctrl_bram [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.4 mgmt_bram_ctrl_bram ]

  # Create instance: mgmt_clk_wiz, and set properties
  set mgmt_clk_wiz [ create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:6.0 mgmt_clk_wiz ]
  set_property -dict [list \
    CONFIG.AUTO_PRIMITIVE {MMCM} \
    CONFIG.CLKOUT1_DRIVES {Buffer} \
    CONFIG.CLKOUT1_JITTER {102.531} \
    CONFIG.CLKOUT1_PHASE_ERROR {85.928} \
    CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {125} \
    CONFIG.CLKOUT2_DRIVES {Buffer} \
    CONFIG.CLKOUT2_JITTER {107.111} \
    CONFIG.CLKOUT2_PHASE_ERROR {85.928} \
    CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {100} \
    CONFIG.CLKOUT2_USED {true} \
    CONFIG.CLKOUT3_DRIVES {Buffer} \
    CONFIG.CLKOUT4_DRIVES {Buffer} \
    CONFIG.CLKOUT5_DRIVES {Buffer} \
    CONFIG.CLKOUT6_DRIVES {Buffer} \
    CONFIG.CLKOUT7_DRIVES {Buffer} \
    CONFIG.CLK_OUT1_PORT {icap_clk} \
    CONFIG.CLK_OUT2_PORT {apb_clk} \
    CONFIG.FEEDBACK_SOURCE {FDBK_AUTO} \
    CONFIG.MMCM_BANDWIDTH {OPTIMIZED} \
    CONFIG.MMCM_CLKFBOUT_MULT_F {4.000} \
    CONFIG.MMCM_CLKOUT0_DIVIDE_F {8.000} \
    CONFIG.MMCM_CLKOUT1_DIVIDE {10} \
    CONFIG.MMCM_COMPENSATION {AUTO} \
    CONFIG.MMCM_DIVCLK_DIVIDE {1} \
    CONFIG.NUM_OUT_CLKS {2} \
    CONFIG.OPTIMIZE_CLOCKING_STRUCTURE_EN {false} \
    CONFIG.PRIMITIVE {MMCM} \
    CONFIG.PRIM_SOURCE {Global_buffer} \
    CONFIG.RESET_PORT {reset} \
    CONFIG.RESET_TYPE {ACTIVE_HIGH} \
    CONFIG.USE_DYN_RECONFIG {true} \
    CONFIG.USE_LOCKED {true} \
    CONFIG.USE_RESET {true} \
  ] $mgmt_clk_wiz


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


  # Create instance: smartconnect_ctrl, and set properties
  set smartconnect_ctrl [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 smartconnect_ctrl ]
  set_property -dict [list \
    CONFIG.HAS_ARESETN {1} \
    CONFIG.NUM_CLKS {2} \
    CONFIG.NUM_MI {11} \
    CONFIG.NUM_SI {1} \
  ] $smartconnect_ctrl


  # Create instance: smartconnect_dma, and set properties
  set smartconnect_dma [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 smartconnect_dma ]
  set_property -dict [list \
    CONFIG.HAS_ARESETN {1} \
    CONFIG.NUM_MI {2} \
    CONFIG.NUM_SI {1} \
  ] $smartconnect_dma


  # Create instance: user_axi_hbm_reset, and set properties
  set user_axi_hbm_reset [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 user_axi_hbm_reset ]

  # Create instance: user_axi_reset, and set properties
  set user_axi_reset [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 user_axi_reset ]
  set_property CONFIG.C_EXT_RST_WIDTH {4} $user_axi_reset


  # Create instance: user_axi_reset_inverter, and set properties
  set user_axi_reset_inverter [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 user_axi_reset_inverter ]
  set_property -dict [list \
    CONFIG.C_OPERATION {not} \
    CONFIG.C_SIZE {1} \
  ] $user_axi_reset_inverter


  # Create instance: user_logic, and set properties
  set user_logic [ create_bd_cell -type container -reference user_logic user_logic ]
  set_property -dict [list \
    CONFIG.ACTIVE_SIM_BD {user_logic.bd} \
    CONFIG.ACTIVE_SYNTH_BD {user_logic.bd} \
    CONFIG.ENABLE_DFX {0} \
    CONFIG.LIST_SIM_BD {user_logic.bd} \
    CONFIG.LIST_SYNTH_BD {user_logic.bd} \
    CONFIG.LOCK_PROPAGATE {0} \
  ] $user_logic

  set_property APERTURES {{0x100_0000 64M}} [get_bd_intf_pins /user_logic/user_axi_ctrl]
  set_property APERTURES {{0x0 16T}} [get_bd_intf_pins /user_logic/user_axi_dma]

  # Create instance: xdma, and set properties
  set xdma [ create_bd_cell -type ip -vlnv xilinx.com:ip:xdma:4.1 xdma ]
  set_property -dict [list \
    CONFIG.axilite_master_en {true} \
    CONFIG.axilite_master_size {128} \
    CONFIG.cfg_ext_if {true} \
    CONFIG.cfg_mgmt_if {false} \
    CONFIG.ext_xvc_vsec_enable {false} \
    CONFIG.pcie_blk_locn {PCIE4C_X1Y1} \
    CONFIG.pf0_Use_Class_Code_Lookup_Assistant {true} \
    CONFIG.pf0_base_class_menu {Processing_accelerators} \
    CONFIG.pl_link_cap_max_link_speed {8.0_GT/s} \
    CONFIG.pl_link_cap_max_link_width {X8} \
    CONFIG.xdma_rnum_chnl {2} \
    CONFIG.xdma_wnum_chnl {2} \
  ] $xdma


  # Create interface connections
  connect_bd_intf_net -intf_net CLK_IN_D_0_1 [get_bd_intf_ports pcie_refclk] [get_bd_intf_pins pcie_refclk_buf/CLK_IN_D]
  connect_bd_intf_net -intf_net CLK_IN_D_0_2 [get_bd_intf_ports hbm_refclk] [get_bd_intf_pins hbm_refclk_buf/CLK_IN_D]
  connect_bd_intf_net -intf_net axi_apb_bridge_APB_M [get_bd_intf_pins axi_apb_bridge/APB_M] [get_bd_intf_pins hbm/SAPB_0]
  connect_bd_intf_net -intf_net axi_apb_bridge_APB_M2 [get_bd_intf_pins axi_apb_bridge/APB_M2] [get_bd_intf_pins hbm/SAPB_1]
  connect_bd_intf_net -intf_net cms_satellite_uart [get_bd_intf_ports satellite_uart] [get_bd_intf_pins cms/satellite_uart]
  connect_bd_intf_net -intf_net ctrl_firewall_M_AXI [get_bd_intf_pins ctrl_firewall/M_AXI] [get_bd_intf_pins dfx_decoupler/s_ctrl]
  connect_bd_intf_net -intf_net dma_firewall_M_AXI [get_bd_intf_pins dfx_decoupler/s_dma] [get_bd_intf_pins dma_firewall/M_AXI]
  connect_bd_intf_net -intf_net mgmt_bram_ctrl_BRAM_PORTA [get_bd_intf_pins mgmt_bram_ctrl/BRAM_PORTA] [get_bd_intf_pins mgmt_bram_ctrl_bram/BRAM_PORTA]
  connect_bd_intf_net -intf_net smartconnect_ctrl_M00_AXI [get_bd_intf_pins cms/s_axi_ctrl] [get_bd_intf_pins smartconnect_ctrl/M00_AXI]
  connect_bd_intf_net -intf_net smartconnect_ctrl_M01_AXI [get_bd_intf_pins qspi/AXI_LITE] [get_bd_intf_pins smartconnect_ctrl/M01_AXI]
  connect_bd_intf_net -intf_net smartconnect_ctrl_M02_AXI [get_bd_intf_pins hbicap/S_AXI_CTRL] [get_bd_intf_pins smartconnect_ctrl/M02_AXI]
  connect_bd_intf_net -intf_net smartconnect_ctrl_M03_AXI [get_bd_intf_pins mgmt_clk_wiz/s_axi_lite] [get_bd_intf_pins smartconnect_ctrl/M03_AXI]
  connect_bd_intf_net -intf_net smartconnect_ctrl_M04_AXI [get_bd_intf_pins mgmt_bram_ctrl/S_AXI] [get_bd_intf_pins smartconnect_ctrl/M04_AXI]
  connect_bd_intf_net -intf_net smartconnect_ctrl_M05_AXI [get_bd_intf_pins ctrl_firewall/S_AXI_CTL] [get_bd_intf_pins smartconnect_ctrl/M05_AXI]
  connect_bd_intf_net -intf_net smartconnect_ctrl_M06_AXI [get_bd_intf_pins dma_firewall/S_AXI_CTL] [get_bd_intf_pins smartconnect_ctrl/M06_AXI]
  connect_bd_intf_net -intf_net smartconnect_ctrl_M07_AXI [get_bd_intf_pins ctrl_firewall/S_AXI] [get_bd_intf_pins smartconnect_ctrl/M07_AXI]
  connect_bd_intf_net -intf_net smartconnect_ctrl_M08_AXI [get_bd_intf_pins dfx_decoupler/s_axi_reg] [get_bd_intf_pins smartconnect_ctrl/M08_AXI]
  connect_bd_intf_net -intf_net smartconnect_ctrl_M09_AXI [get_bd_intf_pins core_clk_wiz/s_axi_lite] [get_bd_intf_pins smartconnect_ctrl/M09_AXI]
  connect_bd_intf_net -intf_net smartconnect_ctrl_M10_AXI [get_bd_intf_pins axi_apb_bridge/AXI4_LITE] [get_bd_intf_pins smartconnect_ctrl/M10_AXI]
  connect_bd_intf_net -intf_net smartconnect_dma_M00_AXI [get_bd_intf_pins hbicap/S_AXI] [get_bd_intf_pins smartconnect_dma/M00_AXI]
  connect_bd_intf_net -intf_net smartconnect_dma_M01_AXI [get_bd_intf_pins dma_firewall/S_AXI] [get_bd_intf_pins smartconnect_dma/M01_AXI]
  connect_bd_intf_net -intf_net user_axi_ctrl_1 [get_bd_intf_pins dfx_decoupler/rp_ctrl] [get_bd_intf_pins user_logic/user_axi_ctrl]
  connect_bd_intf_net -intf_net user_axi_dma_1 [get_bd_intf_pins dfx_decoupler/rp_dma] [get_bd_intf_pins user_logic/user_axi_dma]
  connect_bd_intf_net -intf_net user_logic_user_axi_hbm_s31 [get_bd_intf_pins hbm/SAXI_31] [get_bd_intf_pins user_logic/user_axi_hbm_s31]
  connect_bd_intf_net -intf_net xdma_M_AXI [get_bd_intf_pins smartconnect_dma/S00_AXI] [get_bd_intf_pins xdma/M_AXI]
  connect_bd_intf_net -intf_net xdma_M_AXI_LITE [get_bd_intf_pins smartconnect_ctrl/S00_AXI] [get_bd_intf_pins xdma/M_AXI_LITE]
  connect_bd_intf_net -intf_net xdma_pcie_cfg_ext [get_bd_intf_pins debug_bridge/pcie3_cfg_ext] [get_bd_intf_pins xdma/pcie_cfg_ext]
  connect_bd_intf_net -intf_net xdma_pcie_mgt [get_bd_intf_ports pcie_mgt] [get_bd_intf_pins xdma/pcie_mgt]

  # Create port connections
  connect_bd_net -net apb_reset_peripheral_aresetn [get_bd_pins apb_reset/peripheral_aresetn] [get_bd_pins axi_apb_bridge/s_axi_aresetn] [get_bd_pins hbm/APB_0_PRESET_N] [get_bd_pins hbm/APB_1_PRESET_N]
  connect_bd_net -net cattrip_Res [get_bd_pins cattrip/Res] [get_bd_pins cms/interrupt_hbm_cattrip]
  connect_bd_net -net core_clk_wiz_hbm_clk [get_bd_pins core_clk_wiz/hbm_clk] [get_bd_pins hbm/AXI_31_ACLK] [get_bd_pins user_axi_hbm_reset/slowest_sync_clk] [get_bd_pins user_logic/user_axi_hbm_clk]
  connect_bd_net -net core_clk_wiz_locked [get_bd_pins core_clk_wiz/locked] [get_bd_pins user_axi_hbm_reset/dcm_locked]
  connect_bd_net -net dfx_decoupler_decouple_status [get_bd_pins dfx_decoupler/decouple_status] [get_bd_pins user_axi_hbm_reset/ext_reset_in] [get_bd_pins user_axi_reset_inverter/Op1]
  connect_bd_net -net hbm_DRAM_0_STAT_CATTRIP [get_bd_pins cattrip/Op1] [get_bd_pins hbm/DRAM_0_STAT_CATTRIP]
  connect_bd_net -net hbm_DRAM_0_STAT_TEMP [get_bd_pins cms/hbm_temp_1] [get_bd_pins hbm/DRAM_0_STAT_TEMP]
  connect_bd_net -net hbm_DRAM_1_STAT_CATTRIP [get_bd_pins cattrip/Op2] [get_bd_pins hbm/DRAM_1_STAT_CATTRIP]
  connect_bd_net -net hbm_DRAM_1_STAT_TEMP [get_bd_pins cms/hbm_temp_2] [get_bd_pins hbm/DRAM_1_STAT_TEMP]
  connect_bd_net -net hbm_refclk_buf_IBUF_OUT [get_bd_pins hbm/HBM_REF_CLK_0] [get_bd_pins hbm/HBM_REF_CLK_1] [get_bd_pins hbm_refclk_buf/IBUF_OUT]
  connect_bd_net -net hbm_reset_peripheral_aresetn [get_bd_pins hbm/AXI_31_ARESET_N] [get_bd_pins user_axi_hbm_reset/peripheral_aresetn]
  connect_bd_net -net mgmt_clk_wiz_apb_clk [get_bd_pins apb_reset/slowest_sync_clk] [get_bd_pins axi_apb_bridge/s_axi_aclk] [get_bd_pins hbm/APB_0_PCLK] [get_bd_pins hbm/APB_1_PCLK] [get_bd_pins mgmt_clk_wiz/apb_clk] [get_bd_pins smartconnect_ctrl/aclk1]
  connect_bd_net -net mgmt_clk_wiz_icap_clk [get_bd_pins hbicap/icap_clk] [get_bd_pins mgmt_clk_wiz/icap_clk]
  connect_bd_net -net mgmt_clk_wiz_locked [get_bd_pins apb_reset/dcm_locked] [get_bd_pins mgmt_clk_wiz/locked]
  connect_bd_net -net pcie_refclk_buf_IBUF_DS_ODIV2 [get_bd_pins pcie_refclk_buf/IBUF_DS_ODIV2] [get_bd_pins xdma/sys_clk]
  connect_bd_net -net pcie_refclk_buf_IBUF_OUT [get_bd_pins pcie_refclk_buf/IBUF_OUT] [get_bd_pins xdma/sys_clk_gt]
  connect_bd_net -net pcie_rstn_1 [get_bd_ports pcie_rstn] [get_bd_pins xdma/sys_rst_n]
  connect_bd_net -net qspi_eos [get_bd_pins hbicap/eos_in] [get_bd_pins qspi/eos]
  connect_bd_net -net satellite_gpio_0_1 [get_bd_ports satellite_gpio] [get_bd_pins cms/satellite_gpio]
  connect_bd_net -net user_axi_rstn_1 [get_bd_pins user_axi_reset/peripheral_aresetn] [get_bd_pins user_logic/user_axi_rstn]
  connect_bd_net -net user_reset_inverter_Res [get_bd_pins user_axi_reset/ext_reset_in] [get_bd_pins user_axi_reset_inverter/Res]
  connect_bd_net -net xdma_axi_aclk [get_bd_pins cms/aclk_ctrl] [get_bd_pins core_clk_wiz/clk_in1] [get_bd_pins core_clk_wiz/s_axi_aclk] [get_bd_pins ctrl_firewall/aclk] [get_bd_pins debug_bridge/clk] [get_bd_pins dfx_decoupler/aclk] [get_bd_pins dfx_decoupler/ctrl_aclk] [get_bd_pins dfx_decoupler/dma_aclk] [get_bd_pins dma_firewall/aclk] [get_bd_pins hbicap/s_axi_aclk] [get_bd_pins hbicap/s_axi_mm_aclk] [get_bd_pins mgmt_bram_ctrl/s_axi_aclk] [get_bd_pins mgmt_clk_wiz/clk_in1] [get_bd_pins mgmt_clk_wiz/s_axi_aclk] [get_bd_pins qspi/ext_spi_clk] [get_bd_pins qspi/s_axi_aclk] [get_bd_pins smartconnect_ctrl/aclk] [get_bd_pins smartconnect_dma/aclk] [get_bd_pins user_axi_reset/slowest_sync_clk] [get_bd_pins user_logic/user_axi_clk] [get_bd_pins xdma/axi_aclk]
  connect_bd_net -net xdma_axi_aresetn [get_bd_pins apb_reset/ext_reset_in] [get_bd_pins cms/aresetn_ctrl] [get_bd_pins core_clk_wiz/s_axi_aresetn] [get_bd_pins ctrl_firewall/aresetn] [get_bd_pins dfx_decoupler/ctrl_arstn] [get_bd_pins dfx_decoupler/dma_arstn] [get_bd_pins dfx_decoupler/s_axi_reg_aresetn] [get_bd_pins dma_firewall/aresetn] [get_bd_pins hbicap/s_axi_aresetn] [get_bd_pins hbicap/s_axi_mm_aresetn] [get_bd_pins mgmt_bram_ctrl/s_axi_aresetn] [get_bd_pins mgmt_clk_wiz/s_axi_aresetn] [get_bd_pins qspi/s_axi_aresetn] [get_bd_pins smartconnect_ctrl/aresetn] [get_bd_pins smartconnect_dma/aresetn] [get_bd_pins xdma/axi_aresetn]

  # Create address segments
  assign_bd_address -offset 0xF000000000000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces xdma/M_AXI] [get_bd_addr_segs hbicap/S_AXI/Mem0] -force
  assign_bd_address -offset 0x00000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces xdma/M_AXI] [get_bd_addr_segs hbm/SAXI_31/HBM_MEM00] -force
  assign_bd_address -offset 0x10000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces xdma/M_AXI] [get_bd_addr_segs hbm/SAXI_31/HBM_MEM01] -force
  assign_bd_address -offset 0x20000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces xdma/M_AXI] [get_bd_addr_segs hbm/SAXI_31/HBM_MEM02] -force
  assign_bd_address -offset 0x30000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces xdma/M_AXI] [get_bd_addr_segs hbm/SAXI_31/HBM_MEM03] -force
  assign_bd_address -offset 0x40000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces xdma/M_AXI] [get_bd_addr_segs hbm/SAXI_31/HBM_MEM04] -force
  assign_bd_address -offset 0x50000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces xdma/M_AXI] [get_bd_addr_segs hbm/SAXI_31/HBM_MEM05] -force
  assign_bd_address -offset 0x60000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces xdma/M_AXI] [get_bd_addr_segs hbm/SAXI_31/HBM_MEM06] -force
  assign_bd_address -offset 0x70000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces xdma/M_AXI] [get_bd_addr_segs hbm/SAXI_31/HBM_MEM07] -force
  assign_bd_address -offset 0x80000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces xdma/M_AXI] [get_bd_addr_segs hbm/SAXI_31/HBM_MEM08] -force
  assign_bd_address -offset 0x90000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces xdma/M_AXI] [get_bd_addr_segs hbm/SAXI_31/HBM_MEM09] -force
  assign_bd_address -offset 0xA0000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces xdma/M_AXI] [get_bd_addr_segs hbm/SAXI_31/HBM_MEM10] -force
  assign_bd_address -offset 0xB0000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces xdma/M_AXI] [get_bd_addr_segs hbm/SAXI_31/HBM_MEM11] -force
  assign_bd_address -offset 0xC0000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces xdma/M_AXI] [get_bd_addr_segs hbm/SAXI_31/HBM_MEM12] -force
  assign_bd_address -offset 0xD0000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces xdma/M_AXI] [get_bd_addr_segs hbm/SAXI_31/HBM_MEM13] -force
  assign_bd_address -offset 0xE0000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces xdma/M_AXI] [get_bd_addr_segs hbm/SAXI_31/HBM_MEM14] -force
  assign_bd_address -offset 0xF0000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces xdma/M_AXI] [get_bd_addr_segs hbm/SAXI_31/HBM_MEM15] -force
  assign_bd_address -offset 0x000100000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces xdma/M_AXI] [get_bd_addr_segs hbm/SAXI_31/HBM_MEM16] -force
  assign_bd_address -offset 0x000110000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces xdma/M_AXI] [get_bd_addr_segs hbm/SAXI_31/HBM_MEM17] -force
  assign_bd_address -offset 0x000120000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces xdma/M_AXI] [get_bd_addr_segs hbm/SAXI_31/HBM_MEM18] -force
  assign_bd_address -offset 0x000130000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces xdma/M_AXI] [get_bd_addr_segs hbm/SAXI_31/HBM_MEM19] -force
  assign_bd_address -offset 0x000140000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces xdma/M_AXI] [get_bd_addr_segs hbm/SAXI_31/HBM_MEM20] -force
  assign_bd_address -offset 0x000150000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces xdma/M_AXI] [get_bd_addr_segs hbm/SAXI_31/HBM_MEM21] -force
  assign_bd_address -offset 0x000160000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces xdma/M_AXI] [get_bd_addr_segs hbm/SAXI_31/HBM_MEM22] -force
  assign_bd_address -offset 0x000170000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces xdma/M_AXI] [get_bd_addr_segs hbm/SAXI_31/HBM_MEM23] -force
  assign_bd_address -offset 0x000180000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces xdma/M_AXI] [get_bd_addr_segs hbm/SAXI_31/HBM_MEM24] -force
  assign_bd_address -offset 0x000190000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces xdma/M_AXI] [get_bd_addr_segs hbm/SAXI_31/HBM_MEM25] -force
  assign_bd_address -offset 0x0001A0000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces xdma/M_AXI] [get_bd_addr_segs hbm/SAXI_31/HBM_MEM26] -force
  assign_bd_address -offset 0x0001B0000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces xdma/M_AXI] [get_bd_addr_segs hbm/SAXI_31/HBM_MEM27] -force
  assign_bd_address -offset 0x0001C0000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces xdma/M_AXI] [get_bd_addr_segs hbm/SAXI_31/HBM_MEM28] -force
  assign_bd_address -offset 0x0001D0000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces xdma/M_AXI] [get_bd_addr_segs hbm/SAXI_31/HBM_MEM29] -force
  assign_bd_address -offset 0x0001E0000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces xdma/M_AXI] [get_bd_addr_segs hbm/SAXI_31/HBM_MEM30] -force
  assign_bd_address -offset 0x0001F0000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces xdma/M_AXI] [get_bd_addr_segs hbm/SAXI_31/HBM_MEM31] -force
  assign_bd_address -offset 0x00000000 -range 0x00040000 -target_address_space [get_bd_addr_spaces xdma/M_AXI_LITE] [get_bd_addr_segs cms/s_axi_ctrl/Mem] -force
  assign_bd_address -offset 0x00070000 -range 0x00010000 -target_address_space [get_bd_addr_spaces xdma/M_AXI_LITE] [get_bd_addr_segs core_clk_wiz/s_axi_lite/Reg] -force
  assign_bd_address -offset 0x00090000 -range 0x00010000 -target_address_space [get_bd_addr_spaces xdma/M_AXI_LITE] [get_bd_addr_segs ctrl_firewall/S_AXI_CTL/Control] -force
  assign_bd_address -offset 0x000B0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces xdma/M_AXI_LITE] [get_bd_addr_segs dfx_decoupler/s_axi_reg/Reg] -force
  assign_bd_address -offset 0x000A0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces xdma/M_AXI_LITE] [get_bd_addr_segs dma_firewall/S_AXI_CTL/Control] -force
  assign_bd_address -offset 0x01000000 -range 0x00002000 -target_address_space [get_bd_addr_spaces xdma/M_AXI_LITE] [get_bd_addr_segs user_logic/dummy_bram_controller/S_AXI/Mem0] -force
  assign_bd_address -offset 0x00080000 -range 0x00010000 -target_address_space [get_bd_addr_spaces xdma/M_AXI_LITE] [get_bd_addr_segs hbicap/S_AXI_CTRL/Reg0] -force
  assign_bd_address -offset 0x00400000 -range 0x00400000 -target_address_space [get_bd_addr_spaces xdma/M_AXI_LITE] [get_bd_addr_segs hbm/SAPB_0/Reg] -force
  assign_bd_address -offset 0x00800000 -range 0x00400000 -target_address_space [get_bd_addr_spaces xdma/M_AXI_LITE] [get_bd_addr_segs hbm/SAPB_1/Reg] -force
  assign_bd_address -offset 0x00060000 -range 0x00010000 -target_address_space [get_bd_addr_spaces xdma/M_AXI_LITE] [get_bd_addr_segs mgmt_clk_wiz/s_axi_lite/Reg] -force
  assign_bd_address -offset 0x00050000 -range 0x00010000 -target_address_space [get_bd_addr_spaces xdma/M_AXI_LITE] [get_bd_addr_segs qspi/AXI_LITE/Reg] -force
  assign_bd_address -offset 0x00040000 -range 0x00001000 -target_address_space [get_bd_addr_spaces xdma/M_AXI_LITE] [get_bd_addr_segs mgmt_bram_ctrl/S_AXI/Mem0] -force


  # Restore current instance
  current_bd_instance $oldCurInst

  validate_bd_design
  save_bd_design
  close_bd_design $design_name 
}
# End of cr_bd_shell()