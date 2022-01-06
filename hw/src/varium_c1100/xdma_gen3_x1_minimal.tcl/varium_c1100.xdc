# -- [Clock Hints] -------------------------------------------------------------
# shell clock
create_clock -period 10.000 -name PCIEREFCLK1 [get_ports "PCIE_REFCLK1_P"]
# hbm clock
create_clock -period 10.000 -name SYSCLK2 [get_ports "SYSCLK2_P"]
# user clock
create_clock -period 10.000 -name SYSCLK3 [get_ports "SYSCLK3_P"]
# ------------------------------------------------------------------------------

# -- [Clock Pins] --------------------------------------------------------------
set_property PACKAGE_PIN AR14 [get_ports "PCIE_REFCLK1_N"]
set_property PACKAGE_PIN AR15 [get_ports "PCIE_REFCLK1_P"]

set_property -dict {IOSTANDARD LVDS PACKAGE_PIN BL10} [get_ports "SYSCLK2_N"]
set_property -dict {IOSTANDARD LVDS PACKAGE_PIN BK10} [get_ports "SYSCLK2_P"]

set_property -dict {IOSTANDARD LVDS PACKAGE_PIN BK44} [get_ports "SYSCLK3_N"]
set_property -dict {IOSTANDARD LVDS PACKAGE_PIN BK43} [get_ports "SYSCLK3_P"]
# ------------------------------------------------------------------------------

# -- [PCIE Pins] ---------------------------------------------------------------
set_property -dict {IOSTANDARD LVCMOS18 PACKAGE_PIN BF41}     [get_ports "PCIE_PERST_LS_65"]
set_property PACKAGE_PIN AL1  [get_ports "PEX_RX0_N"]
set_property PACKAGE_PIN AL2  [get_ports "PEX_RX0_P"]
set_property PACKAGE_PIN AL10 [get_ports "PEX_TX0_N"]
set_property PACKAGE_PIN AL11 [get_ports "PEX_TX0_P"]
# ------------------------------------------------------------------------------

# -- [Satellite Controller Pins] -----------------------------------------------
set_property -dict {IOSTANDARD LVCMOS18 PACKAGE_PIN BE45} [get_ports "HBM_CATTRIP_LS"]
# ------------------------------------------------------------------------------
