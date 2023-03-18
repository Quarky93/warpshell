# -- [Clocks] ------------------------------------------------------------------
# pcie refclock
create_clock -period 10.000 -name pcie_refclk [get_ports pcie_refclk_clk_p]
# sys refclock
create_clock -period 5.000 -name sys_refclk_0 [get_ports sys_refclk_0_clk_p]
# ------------------------------------------------------------------------------

# -- [Clock Pins] --------------------------------------------------------------
set_property PACKAGE_PIN F6 [get_ports {pcie_refclk_clk_p}]
set_property PACKAGE_PIN E6 [get_ports {pcie_refclk_clk_n}]

set_property -dict {IOSTANDARD DIFF_SSTL15 PACKAGE_PIN H19} [get_ports sys_refclk_0_clk_n]
set_property -dict {IOSTANDARD DIFF_SSTL15 PACKAGE_PIN J19} [get_ports sys_refclk_0_clk_p]
# ------------------------------------------------------------------------------

# -- [PCIE Pins] ---------------------------------------------------------------
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN J1} [get_ports pcie_rstn]

set_property PACKAGE_PIN C7  [get_ports { pcie_mgt_txn[3] }]
set_property PACKAGE_PIN D7  [get_ports { pcie_mgt_txp[3] }]
set_property PACKAGE_PIN C9  [get_ports { pcie_mgt_rxn[3] }]
set_property PACKAGE_PIN D9  [get_ports { pcie_mgt_rxp[3] }]
set_property PACKAGE_PIN A4  [get_ports { pcie_mgt_txn[1] }]
set_property PACKAGE_PIN B4  [get_ports { pcie_mgt_txp[1] }]
set_property PACKAGE_PIN A8  [get_ports { pcie_mgt_rxn[1] }]
set_property PACKAGE_PIN B8  [get_ports { pcie_mgt_rxp[1] }]
set_property PACKAGE_PIN A6  [get_ports { pcie_mgt_txn[0] }]
set_property PACKAGE_PIN B6  [get_ports { pcie_mgt_txp[0] }]
set_property PACKAGE_PIN A10 [get_ports { pcie_mgt_rxn[0] }]
set_property PACKAGE_PIN B10 [get_ports { pcie_mgt_rxp[0] }]
# ------------------------------------------------------------------------------
