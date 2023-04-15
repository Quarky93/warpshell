# -- [Clocks] ------------------------------------------------------------------
# pcie refclock
create_clock -period 10.000 -name pcie_refclk [get_ports pcie_refclk_clk_p]
# sys refclock
create_clock -period 10.000 -name sys_refclk_0 [get_ports sys_refclk_0_clk_p]
# ------------------------------------------------------------------------------

# -- [Clock Pins] --------------------------------------------------------------
set_property PACKAGE_PIN AR14 [get_ports pcie_refclk_clk_n]
set_property PACKAGE_PIN AR15 [get_ports pcie_refclk_clk_p]

set_property -dict {IOSTANDARD LVDS PACKAGE_PIN BK44} [get_ports sys_refclk_0_clk_n]
set_property -dict {IOSTANDARD LVDS PACKAGE_PIN BK43} [get_ports sys_refclk_0_clk_p]
# ------------------------------------------------------------------------------

# -- [PCIE Pins] ---------------------------------------------------------------
set_property -dict {IOSTANDARD LVCMOS18 PACKAGE_PIN BF41} [get_ports pcie_rstn]

set_property PACKAGE_PIN AP8  [get_ports { pcie_mgt_txn[3] }]
set_property PACKAGE_PIN AP9  [get_ports { pcie_mgt_txp[3] }]
set_property PACKAGE_PIN AN1  [get_ports { pcie_mgt_rxn[3] }]
set_property PACKAGE_PIN AN2  [get_ports { pcie_mgt_rxp[3] }]
set_property PACKAGE_PIN AN10 [get_ports { pcie_mgt_txn[2] }]
set_property PACKAGE_PIN AN11 [get_ports { pcie_mgt_txp[2] }]
set_property PACKAGE_PIN AN5  [get_ports { pcie_mgt_rxn[2] }]
set_property PACKAGE_PIN AN6  [get_ports { pcie_mgt_rxp[2] }]
set_property PACKAGE_PIN AM8  [get_ports { pcie_mgt_txn[1] }]
set_property PACKAGE_PIN AM9  [get_ports { pcie_mgt_txp[1] }]
set_property PACKAGE_PIN AM3  [get_ports { pcie_mgt_rxn[1] }]
set_property PACKAGE_PIN AM4  [get_ports { pcie_mgt_rxp[1] }]
set_property PACKAGE_PIN AL10 [get_ports { pcie_mgt_txn[0] }]
set_property PACKAGE_PIN AL11 [get_ports { pcie_mgt_txp[0] }]
set_property PACKAGE_PIN AL1  [get_ports { pcie_mgt_rxn[0] }]
set_property PACKAGE_PIN AL2  [get_ports { pcie_mgt_rxp[0] }]
# ------------------------------------------------------------------------------

# -- [Satellite Controller Pins] -----------------------------------------------
set_property -dict { IOSTANDARD LVCMOS18 PACKAGE_PIN BE46 } [get_ports { satellite_gpio[0] }]
set_property -dict { IOSTANDARD LVCMOS18 PACKAGE_PIN BF46 } [get_ports { satellite_gpio[3] }]
set_property -dict { IOSTANDARD LVCMOS18 PACKAGE_PIN BF45 } [get_ports { satellite_gpio[2] }]
set_property -dict { IOSTANDARD LVCMOS18 PACKAGE_PIN BH46 } [get_ports { satellite_gpio[1] }]
set_property -dict { IOSTANDARD LVCMOS18 PACKAGE_PIN BJ42 } [get_ports satellite_uart_rxd]
set_property -dict { IOSTANDARD LVCMOS18 PACKAGE_PIN BH42 } [get_ports satellite_uart_txd]
# ------------------------------------------------------------------------------
