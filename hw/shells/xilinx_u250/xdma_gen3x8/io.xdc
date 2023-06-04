# -- [Clocks] ------------------------------------------------------------------
# pcie refclock
create_clock -period 10.000 -name pcie_refclk [get_ports pcie_refclk_clk_p]
# ------------------------------------------------------------------------------

# -- [Clock Pins] --------------------------------------------------------------
set_property PACKAGE_PIN AM10 [get_ports pcie_refclk_clk_n]
set_property PACKAGE_PIN AM11 [get_ports pcie_refclk_clk_p]
# ------------------------------------------------------------------------------

# -- [PCIE Pins] ---------------------------------------------------------------
set_property -dict {IOSTANDARD LVCMOS12 PACKAGE_PIN BD21} [get_ports pcie_rstn]

set_property PACKAGE_PIN AN8 [get_ports { pcie_mgt_txn[7] }]
set_property PACKAGE_PIN AN9 [get_ports { pcie_mgt_txp[7] }]
set_property PACKAGE_PIN AN3 [get_ports { pcie_mgt_rxn[7] }]
set_property PACKAGE_PIN AN4 [get_ports { pcie_mgt_rxp[7] }]
set_property PACKAGE_PIN AM6 [get_ports { pcie_mgt_txn[6] }]
set_property PACKAGE_PIN AM7 [get_ports { pcie_mgt_txp[6] }]
set_property PACKAGE_PIN AM1 [get_ports { pcie_mgt_rxn[6] }]
set_property PACKAGE_PIN AM2 [get_ports { pcie_mgt_rxp[6] }]
set_property PACKAGE_PIN AL8 [get_ports { pcie_mgt_txn[5] }]
set_property PACKAGE_PIN AL9 [get_ports { pcie_mgt_txp[5] }]
set_property PACKAGE_PIN AL3 [get_ports { pcie_mgt_rxn[5] }]
set_property PACKAGE_PIN AL4 [get_ports { pcie_mgt_rxp[5] }]
set_property PACKAGE_PIN AK6 [get_ports { pcie_mgt_txn[4] }]
set_property PACKAGE_PIN AK7 [get_ports { pcie_mgt_txp[4] }]
set_property PACKAGE_PIN AK1 [get_ports { pcie_mgt_rxn[4] }]
set_property PACKAGE_PIN AK2 [get_ports { pcie_mgt_rxp[4] }]
set_property PACKAGE_PIN AJ8 [get_ports { pcie_mgt_txn[3] }]
set_property PACKAGE_PIN AJ9 [get_ports { pcie_mgt_txp[3] }]
set_property PACKAGE_PIN AJ3 [get_ports { pcie_mgt_rxn[3] }]
set_property PACKAGE_PIN AJ4 [get_ports { pcie_mgt_rxp[3] }]
set_property PACKAGE_PIN AH6 [get_ports { pcie_mgt_txn[2] }]
set_property PACKAGE_PIN AH7 [get_ports { pcie_mgt_txp[2] }]
set_property PACKAGE_PIN AH1 [get_ports { pcie_mgt_rxn[2] }]
set_property PACKAGE_PIN AH2 [get_ports { pcie_mgt_rxp[2] }]
set_property PACKAGE_PIN AG8 [get_ports { pcie_mgt_txn[1] }]
set_property PACKAGE_PIN AG9 [get_ports { pcie_mgt_txp[1] }]
set_property PACKAGE_PIN AG3 [get_ports { pcie_mgt_rxn[1] }]
set_property PACKAGE_PIN AG4 [get_ports { pcie_mgt_rxp[1] }]
set_property PACKAGE_PIN AF6 [get_ports { pcie_mgt_txn[0] }]
set_property PACKAGE_PIN AF7 [get_ports { pcie_mgt_txp[0] }]
set_property PACKAGE_PIN AF1 [get_ports { pcie_mgt_rxn[0] }]
set_property PACKAGE_PIN AF2 [get_ports { pcie_mgt_rxp[0] }]
# ------------------------------------------------------------------------------

# -- [Satellite Controller Pins] -----------------------------------------------
set_property -dict { IOSTANDARD LVCMOS12 PACKAGE_PIN AN21 } [get_ports { satellite_gpio[3] }]
set_property -dict { IOSTANDARD LVCMOS12 PACKAGE_PIN AM21 } [get_ports { satellite_gpio[2] }]
set_property -dict { IOSTANDARD LVCMOS12 PACKAGE_PIN AM20 } [get_ports { satellite_gpio[1] }]
set_property -dict { IOSTANDARD LVCMOS12 PACKAGE_PIN AR20 } [get_ports { satellite_gpio[0] }]
set_property -dict { IOSTANDARD LVCMOS12 PACKAGE_PIN BA19 } [get_ports satellite_uart_rxd]
set_property -dict { IOSTANDARD LVCMOS12 PACKAGE_PIN BB19 } [get_ports satellite_uart_txd]
# ------------------------------------------------------------------------------
