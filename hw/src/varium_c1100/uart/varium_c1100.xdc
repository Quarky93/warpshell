# -- [Clock Hints] -------------------------------------------------------------
create_clock -period 10.000 -name SYSCLK2 [get_ports "SYSCLK2_P"]
# ------------------------------------------------------------------------------

# -- [Clock Pins] --------------------------------------------------------------
set_property -dict {IOSTANDARD LVDS PACKAGE_PIN BL10} [get_ports "SYSCLK2_N"]
set_property -dict {IOSTANDARD LVDS PACKAGE_PIN BK10} [get_ports "SYSCLK2_P"]
# ------------------------------------------------------------------------------

# -- [QSFP LED Pins] -----------------------------------------------------------
set_property -dict {IOSTANDARD LVCMOS18 PACKAGE_PIN BL13} [get_ports "QSFP28_0_ACTIVITY_LED"]
# ------------------------------------------------------------------------------

# -- [UART0 Pins] --------------------------------------------------------------
set_property -dict {IOSTANDARD LVCMOS18 PACKAGE_PIN BK41} [get_ports "FPGA_UART0_RXD"]
set_property -dict {IOSTANDARD LVCMOS18 PACKAGE_PIN BJ41} [get_ports "FPGA_UART0_TXD"]
# ------------------------------------------------------------------------------
