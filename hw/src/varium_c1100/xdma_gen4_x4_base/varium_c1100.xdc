# -- [Clock Sources] ---------------------------------------------------------------------------------------------------
create_clock -name pcie_refclk_0 -period 10.0 [get_ports pcie_refclk_0_p]
# create_clock -name pcie_refclk_1 -period 10.0 [get_ports pcie_refclk_1_p]
# create_clock -name pcie_sysclk_0 -period 10.0 [get_ports pcie_sysclk_0_p]
# create_clock -name pcie_sysclk_1 -period 10.0 [get_ports pcie_sysclk_1_p]
# create_clock -name sysclk_0 -period 10.0 [get_ports sysclk_0_p]
# create_clock -name sysclk_1 -period 10.0 [get_ports sysclk_1_p]
# create_clock -name qsfp28_clk_0 -period 6.206 [get_ports qsfp28_clk_0_p]
# create_clock -name qsfp28_clk_1 -period 6.206 [get_ports qsfp28_clk_1_p]

# pcie_refclk_0: PCIE reference clock for lanes 0-7
set_property PACKAGE_PIN AL15 [get_ports pcie_refclk_0_p]
set_property PACKAGE_PIN AL14 [get_ports pcie_refclk_0_n]
# pcie_refclk_1: PCIE reference clock for lanes 8-15
# set_property PACKAGE_PIN AR15 [get_ports pcie_refclk_1_p]
# set_property PACKAGE_PIN AR14 [get_ports pcie_refclk_1_n]
# pcie_sysclk_0: System clock derived from pcie_refclk_0
# set_property PACKAGE_PIN AK13 [get_ports pcie_sysclk_0_p]
# set_property PACKAGE_PIN AK12 [get_ports pcie_sysclk_0_n]
# pcie_sysclk_1: System clock derived from pcie_refclk_1
# set_property PACKAGE_PIN AP13 [get_ports pcie_sysclk_1_p]
# set_property PACKAGE_PIN AP12 [get_ports pcie_sysclk_1_n]
# sysclk_0: System clock for SLR0
# set_property -dict {IOSTANDARD LVDS PACKAGE_PIN BK43} [get_ports sysclk_0_p]
# set_property -dict {IOSTANDARD LVDS PACKAGE_PIN BK44} [get_ports sysclk_0_n]
# sysclk_1: System clock for SLR1
# set_property -dict {IOSTANDARD LVDS PACKAGE_PIN BK10} [get_ports sysclk_1_p]
# set_property -dict {IOSTANDARD LVDS PACKAGE_PIN BL10} [get_ports sysclk_1_n]
# qsfp28_clk_0: QSFP28 clock for cage 0
# set_property PACKAGE_PIN AD42 [get_ports qsfp28_clk_0_p]
# set_property PACKAGE_PIN AD43 [get_ports qsfp28_clk_0_n]
# qsfp28_clk_1: QSFP28 clock for cage 1
# set_property PACKAGE_PIN AB42 [get_ports qsfp28_clk_1_p]
# set_property PACKAGE_PIN AB43 [get_ports qsfp28_clk_1_n]
# ----------------------------------------------------------------------------------------------------------------------

# -- [UART] ------------------------------------------------------------------------------------------------------------
# uart_0: UART 0 - accessible over FTDI from micro-usb port
# set_property -dict {IOSTANDARD LVCMOS18 PACKAGE_PIN BK41} [get_ports uart_0_rxd]
# set_property -dict {IOSTANDARD LVCMOS18 PACKAGE_PIN BJ41} [get_ports uart_0_txd]
# uart_1: UART 1 - accessible over FTDI from micro-usb port
# set_property -dict {IOSTANDARD LVCMOS18 PACKAGE_PIN BP47} [get_ports uart_1_rxd]
# set_property -dict {IOSTANDARD LVCMOS18 PACKAGE_PIN BN47} [get_ports uart_1_txd]
# uart_2: UART 2 - accessible only over Alveo maintenance port
# set_property -dict {IOSTANDARD LVCMOS18 PACKAGE_PIN BL46} [get_ports uart_2_rxd]
# set_property -dict {IOSTANDARD LVCMOS18 PACKAGE_PIN BL45} [get_ports uart_2_txd]
# ----------------------------------------------------------------------------------------------------------------------

# -- [SATELLITE CONTROLLER] --------------------------------------------------------------------------------------------
# sc_rstn: SC to FPGA active low reset
# set_property -dict {IOSTANDARD LVCMOS18 PACKAGE_PIN BG45} [get_ports sc_rstn]
# sc_hbm_cattrip: FPGA to SC requesting immediate power down
# set_property -dict {IOSTANDARD LVCMOS18 PACKAGE_PIN BE45} [get_ports sc_hbm_cattrip]
# sc_uart: General communication between FPGA and SC
set_property -dict {IOSTANDARD LVCMOS18 PACKAGE_PIN BJ42} [get_ports sc_uart_rxd]
set_property -dict {IOSTANDARD LVCMOS18 PACKAGE_PIN BH42} [get_ports sc_uart_txd]
# sc_gpio: sc_gpio[0] = power throttle warning, sc_gpio[1] = power throttle critical
set_property -dict {IOSTANDARD LVCMOS18 PACKAGE_PIN BE46} [get_ports { sc_gpio[0] }]
set_property -dict {IOSTANDARD LVCMOS18 PACKAGE_PIN BH46} [get_ports { sc_gpio[1] }]
set_property -dict {IOSTANDARD LVCMOS18 PACKAGE_PIN BF45} [get_ports { sc_gpio[2] }]
set_property -dict {IOSTANDARD LVCMOS18 PACKAGE_PIN BF46} [get_ports { sc_gpio[3] }]
# ----------------------------------------------------------------------------------------------------------------------

# -- [QSFP28] ----------------------------------------------------------------------------------------------------------
# qsfp_0_activity_led: Activity LED for QSFP cage 0
# set_property -dict {IOSTANDARD LVCMOS18 PACKAGE_PIN BL13} [get_ports qsfp_0_activity_led]
# qsfp_0_link_stat_ledg: Green LED for QSFP cage 0
# set_property -dict {IOSTANDARD LVCMOS18 PACKAGE_PIN BK11} [get_ports qsfp_0_link_stat_ledg]
# qsfp_0_link_stat_ledy: Yellow LED for QSFP cage 0
# set_property -dict {IOSTANDARD LVCMOS18 PACKAGE_PIN BJ11} [get_ports qsfp_0_link_stat_ledy]
# qsfp_1_activity_led: Activity LED for QSFP cage 1
# set_property -dict {IOSTANDARD LVCMOS18 PACKAGE_PIN BK14} [get_ports qsfp_1_activity_led]
# qsfp_1_link_stat_ledg: Green LED for QSFP cage 1
# set_property -dict {IOSTANDARD LVCMOS18 PACKAGE_PIN BK15} [get_ports qsfp_1_link_stat_ledg]
# qsfp_1_link_stat_ledy: Yellow LED for QSFP cage 1
# set_property -dict {IOSTANDARD LVCMOS18 PACKAGE_PIN BL12} [get_ports qsfp_1_link_stat_ledy]

# qsfp28_0: Data lines for QSFP28 cage 0
# set_property PACKAGE_PIN AD51 [get_ports { qsfp28_0_rxp[0] }]
# set_property PACKAGE_PIN AD52 [get_ports { qsfp28_0_rxn[0] }]
# set_property PACKAGE_PIN AD46 [get_ports { qsfp28_0_txp[0] }]
# set_property PACKAGE_PIN AD47 [get_ports { qsfp28_0_txn[0] }]
# set_property PACKAGE_PIN AC53 [get_ports { qsfp28_0_rxp[1] }]
# set_property PACKAGE_PIN AC54 [get_ports { qsfp28_0_rxn[1] }]
# set_property PACKAGE_PIN AC44 [get_ports { qsfp28_0_txp[1] }]
# set_property PACKAGE_PIN AC45 [get_ports { qsfp28_0_txn[1] }]
# set_property PACKAGE_PIN AC49 [get_ports { qsfp28_0_rxp[2] }]
# set_property PACKAGE_PIN AC50 [get_ports { qsfp28_0_rxn[2] }]
# set_property PACKAGE_PIN AB46 [get_ports { qsfp28_0_txp[2] }]
# set_property PACKAGE_PIN AB47 [get_ports { qsfp28_0_txn[2] }]
# set_property PACKAGE_PIN AB51 [get_ports { qsfp28_0_rxp[3] }]
# set_property PACKAGE_PIN AB52 [get_ports { qsfp28_0_rxn[3] }]
# set_property PACKAGE_PIN AA48 [get_ports { qsfp28_0_txp[3] }]
# set_property PACKAGE_PIN AA49 [get_ports { qsfp28_0_txn[3] }]

# qsfp28_1: Data lines for QSFP28 cage 1
# set_property PACKAGE_PIN AA53 [get_ports { qsfp28_1_rxp[0] }]
# set_property PACKAGE_PIN AA54 [get_ports { qsfp28_1_rxn[0] }]
# set_property PACKAGE_PIN AA44 [get_ports { qsfp28_1_txp[0] }]
# set_property PACKAGE_PIN AA45 [get_ports { qsfp28_1_txn[0] }]
# set_property PACKAGE_PIN Y51  [get_ports { qsfp28_1_rxp[1] }]
# set_property PACKAGE_PIN Y52  [get_ports { qsfp28_1_rxn[1] }]
# set_property PACKAGE_PIN Y46  [get_ports { qsfp28_1_txp[1] }]
# set_property PACKAGE_PIN Y47  [get_ports { qsfp28_1_txn[1] }]
# set_property PACKAGE_PIN W53  [get_ports { qsfp28_1_rxp[2] }]
# set_property PACKAGE_PIN W54  [get_ports { qsfp28_1_rxn[2] }]
# set_property PACKAGE_PIN W48  [get_ports { qsfp28_1_txp[2] }]
# set_property PACKAGE_PIN W49  [get_ports { qsfp28_1_txn[2] }]
# set_property PACKAGE_PIN V51  [get_ports { qsfp28_1_rxp[3] }]
# set_property PACKAGE_PIN V52  [get_ports { qsfp28_1_rxn[3] }]
# set_property PACKAGE_PIN W44  [get_ports { qsfp28_1_txp[3] }]
# set_property PACKAGE_PIN W45  [get_ports { qsfp28_1_txn[3] }]
# ----------------------------------------------------------------------------------------------------------------------

# -- [PCIE] ------------------------------------------------------------------------------------------------------------
# pcie_perst: Active low reset from PCIE edge connector
set_property -dict {IOSTANDARD LVCMOS18 PACKAGE_PIN BF41} [get_ports pcie_perst]
# pcie_pwrbrk: Emergency reduce power from PCIE edge connector
# set_property -dict {IOSTANDARD LVCMOS18 PACKAGE_PIN BG43} [get_ports pcie_pwrbrk]

# pcie: Data lines of PCIE edge connector
set_property PACKAGE_PIN AL2  [get_ports { pcie_rxp[0] }]
set_property PACKAGE_PIN AL1  [get_ports { pcie_rxn[0] }]
set_property PACKAGE_PIN AL11 [get_ports { pcie_txp[0] }]
set_property PACKAGE_PIN AL10 [get_ports { pcie_txn[0] }]
set_property PACKAGE_PIN AM4  [get_ports { pcie_rxp[1] }]
set_property PACKAGE_PIN AM3  [get_ports { pcie_rxn[1] }]
set_property PACKAGE_PIN AM9  [get_ports { pcie_txp[1] }]
set_property PACKAGE_PIN AM8  [get_ports { pcie_txn[1] }]
set_property PACKAGE_PIN AN6  [get_ports { pcie_rxp[2] }]
set_property PACKAGE_PIN AN5  [get_ports { pcie_rxn[2] }]
set_property PACKAGE_PIN AN11 [get_ports { pcie_txp[2] }]
set_property PACKAGE_PIN AN10 [get_ports { pcie_txn[2] }]
set_property PACKAGE_PIN AN2  [get_ports { pcie_rxp[3] }]
set_property PACKAGE_PIN AN1  [get_ports { pcie_rxn[3] }]
set_property PACKAGE_PIN AP9  [get_ports { pcie_txp[3] }]
set_property PACKAGE_PIN AP8  [get_ports { pcie_txn[3] }]
# set_property PACKAGE_PIN AP4  [get_ports { pcie_rxp[4] }]
# set_property PACKAGE_PIN AP3  [get_ports { pcie_rxn[4] }]
# set_property PACKAGE_PIN AR11 [get_ports { pcie_txp[4] }]
# set_property PACKAGE_PIN AR10 [get_ports { pcie_txn[4] }]
# set_property PACKAGE_PIN AR2  [get_ports { pcie_rxp[5] }]
# set_property PACKAGE_PIN AR1  [get_ports { pcie_rxn[5] }]
# set_property PACKAGE_PIN AR7  [get_ports { pcie_txp[5] }]
# set_property PACKAGE_PIN AR6  [get_ports { pcie_txn[5] }]
# set_property PACKAGE_PIN AT4  [get_ports { pcie_rxp[6] }]
# set_property PACKAGE_PIN AT3  [get_ports { pcie_rxn[6] }]
# set_property PACKAGE_PIN AT9  [get_ports { pcie_txp[6] }]
# set_property PACKAGE_PIN AT8  [get_ports { pcie_txn[6] }]
# set_property PACKAGE_PIN AU2  [get_ports { pcie_rxp[7] }]
# set_property PACKAGE_PIN AU1  [get_ports { pcie_rxn[7] }]
# set_property PACKAGE_PIN AU11 [get_ports { pcie_txp[7] }]
# set_property PACKAGE_PIN AU10 [get_ports { pcie_txn[7] }]
# set_property PACKAGE_PIN AV4  [get_ports { pcie_rxp[8] }]
# set_property PACKAGE_PIN AV3  [get_ports { pcie_rxn[8] }]
# set_property PACKAGE_PIN AU7  [get_ports { pcie_txp[8] }]
# set_property PACKAGE_PIN AU6  [get_ports { pcie_txn[8] }]
# set_property PACKAGE_PIN AW6  [get_ports { pcie_rxp[9] }]
# set_property PACKAGE_PIN AW5  [get_ports { pcie_rxn[9] }]
# set_property PACKAGE_PIN AV9  [get_ports { pcie_txp[9] }]
# set_property PACKAGE_PIN AV8  [get_ports { pcie_txn[9] }]
# set_property PACKAGE_PIN AW2  [get_ports { pcie_rxp[10] }]
# set_property PACKAGE_PIN AW1  [get_ports { pcie_rxn[10] }]
# set_property PACKAGE_PIN AW11 [get_ports { pcie_txp[10] }]
# set_property PACKAGE_PIN AW10 [get_ports { pcie_txn[10] }]
# set_property PACKAGE_PIN AY4  [get_ports { pcie_rxp[11] }]
# set_property PACKAGE_PIN AY3  [get_ports { pcie_rxn[11] }]
# set_property PACKAGE_PIN AY9  [get_ports { pcie_txp[11] }]
# set_property PACKAGE_PIN AY8  [get_ports { pcie_txn[11] }]
# set_property PACKAGE_PIN BA6  [get_ports { pcie_rxp[12] }]
# set_property PACKAGE_PIN BA5  [get_ports { pcie_rxn[12] }]
# set_property PACKAGE_PIN BA11 [get_ports { pcie_txp[12] }]
# set_property PACKAGE_PIN BA10 [get_ports { pcie_txn[12] }]
# set_property PACKAGE_PIN BA2  [get_ports { pcie_rxp[13] }]
# set_property PACKAGE_PIN BA1  [get_ports { pcie_rxn[13] }]
# set_property PACKAGE_PIN BB9  [get_ports { pcie_txp[13] }]
# set_property PACKAGE_PIN BB8  [get_ports { pcie_txn[13] }]
# set_property PACKAGE_PIN BB4  [get_ports { pcie_rxp[14] }]
# set_property PACKAGE_PIN BB3  [get_ports { pcie_rxn[14] }]
# set_property PACKAGE_PIN BC11 [get_ports { pcie_txp[14] }]
# set_property PACKAGE_PIN BC10 [get_ports { pcie_txn[14] }]
# set_property PACKAGE_PIN BC2  [get_ports { pcie_rxp[15] }]
# set_property PACKAGE_PIN BC1  [get_ports { pcie_rxn[15] }]
# set_property PACKAGE_PIN BC7  [get_ports { pcie_txp[15] }]
# set_property PACKAGE_PIN BC6  [get_ports { pcie_txn[15] }]
# ----------------------------------------------------------------------------------------------------------------------

# -- [Si5394B] ---------------------------------------------------------------------------------------------------------
# set_property -dict {IOSTANDARD LVCMOS18 PACKAGE_PIN BM8} [get_ports si_rstbb]
# set_property -dict {IOSTANDARD LVCMOS18 PACKAGE_PIN BM9} [get_ports si_intrb]
# set_property -dict {IOSTANDARD LVCMOS18 PACKAGE_PIN BN10} [get_ports si_pll_lock]
# set_property -dict {IOSTANDARD LVCMOS18 PACKAGE_PIN BM10} [get_ports si_in_los]
# set_property -dict {IOSTANDARD LVCMOS18 PACKAGE_PIN BM14} [get_ports si_i2c_scl]
# set_property -dict {IOSTANDARD LVCMOS18 PACKAGE_PIN BN14} [get_ports si_i2c_sda]
# ----------------------------------------------------------------------------------------------------------------------
