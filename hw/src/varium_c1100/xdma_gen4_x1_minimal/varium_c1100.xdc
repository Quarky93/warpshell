# -- [Clock Hints] -------------------------------------------------------------
# shell clock
create_clock -period 10.000 -name PCIEREFCLK1 [get_ports "PCIE_REFCLK1_P"]
# hbm clock
create_clock -period 10.000 -name SYSCLK2 [get_ports "SYSCLK2_P"]
# user clock
# create_clock -period 10.000 -name SYSCLK3 [get_ports "SYSCLK3_P"]
# ------------------------------------------------------------------------------

# -- [Clock Pins] --------------------------------------------------------------
set_property PACKAGE_PIN AR14 [get_ports "PCIE_REFCLK1_N"]
set_property PACKAGE_PIN AR15 [get_ports "PCIE_REFCLK1_P"]

set_property -dict {IOSTANDARD LVDS PACKAGE_PIN BL10} [get_ports "SYSCLK2_N"]
set_property -dict {IOSTANDARD LVDS PACKAGE_PIN BK10} [get_ports "SYSCLK2_P"]

# set_property -dict {IOSTANDARD LVDS PACKAGE_PIN BK44} [get_ports "SYSCLK3_N"]
# set_property -dict {IOSTANDARD LVDS PACKAGE_PIN BK43} [get_ports "SYSCLK3_P"]
# ------------------------------------------------------------------------------

# -- [PCIE Pins] ---------------------------------------------------------------
set_property -dict {IOSTANDARD LVCMOS18 PACKAGE_PIN BF41} [get_ports "PCIE_PERST_LS_65"]
set_property PACKAGE_PIN AL1  [get_ports "PEX_RX0_N"]
set_property PACKAGE_PIN AL2  [get_ports "PEX_RX0_P"]
set_property PACKAGE_PIN AL10 [get_ports "PEX_TX0_N"]
set_property PACKAGE_PIN AL11 [get_ports "PEX_TX0_P"]
# ------------------------------------------------------------------------------

# -- [Satellite Controller Pins] -----------------------------------------------
set_property PACKAGE_PIN BE46     [get_ports "MSP_GPIO0"] ;# Bank  65 VCCO - VCC1V8   - IO_L22N_T3U_N7_DBC_AD0N_D05_65
set_property IOSTANDARD  LVCMOS18 [get_ports "MSP_GPIO0"] ;# Bank  65 VCCO - VCC1V8   - IO_L22N_T3U_N7_DBC_AD0N_D05_65
set_property PACKAGE_PIN BF46     [get_ports "MSP_GPIO3"] ;# Bank  65 VCCO - VCC1V8   - IO_L20N_T3L_N3_AD1N_D09_65
set_property IOSTANDARD  LVCMOS18 [get_ports "MSP_GPIO3"] ;# Bank  65 VCCO - VCC1V8   - IO_L20N_T3L_N3_AD1N_D09_65
set_property PACKAGE_PIN BF45     [get_ports "MSP_GPIO2"] ;# Bank  65 VCCO - VCC1V8   - IO_L20P_T3L_N2_AD1P_D08_65
set_property IOSTANDARD  LVCMOS18 [get_ports "MSP_GPIO2"] ;# Bank  65 VCCO - VCC1V8   - IO_L20P_T3L_N2_AD1P_D08_65
set_property PACKAGE_PIN BH46     [get_ports "MSP_GPIO1"] ;# Bank  65 VCCO - VCC1V8   - IO_L16P_T2U_N6_QBC_AD3P_A00_D16_65
set_property IOSTANDARD  LVCMOS18 [get_ports "MSP_GPIO1"] ;# Bank  65 VCCO - VCC1V8   - IO_L16P_T2U_N6_QBC_AD3P_A00_D16_65
set_property PACKAGE_PIN BJ42     [get_ports "FPGA_RXD_MSP_65"] ;# Bank  65 VCCO - VCC1V8   - IO_L13N_T2L_N1_GC_QBC_A07_D23_65
set_property IOSTANDARD  LVCMOS18 [get_ports "FPGA_RXD_MSP_65"] ;# Bank  65 VCCO - VCC1V8   - IO_L13N_T2L_N1_GC_QBC_A07_D23_65
set_property PACKAGE_PIN BH42     [get_ports "FPGA_TXD_MSP_65"] ;# Bank  65 VCCO - VCC1V8   - IO_L13P_T2L_N0_GC_QBC_A06_D22_65
set_property IOSTANDARD  LVCMOS18 [get_ports "FPGA_TXD_MSP_65"] ;# Bank  65 VCCO - VCC1V8   - IO_L13P_T2L_N0_GC_QBC_A06_D22_65
# ------------------------------------------------------------------------------
