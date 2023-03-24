set script_path [file dirname [file normalize [info script]]]

create_project -in_memory -part xcu55n-fsvh2892-2L-e
set_property source_mgmt_mode All [current_project]

# -- [READ FILES] -------------------------------------------------------------
file mkdir ./shell/
file mkdir ./user/
file copy ${script_path}/shell.bd ./shell/shell.bd
file copy ${script_path}/user.bd ./user/user.bd
read_bd ./shell/shell.bd
read_bd ./user/user.bd

read_xdc "${script_path}/io.xdc"
read_xdc "${script_path}/misc.xdc"
read_xdc "${script_path}/floorplan.xdc"
read_verilog "${script_path}/top.v"
# -----------------------------------------------------------------------------

# -- [GENERATE BDS] -----------------------------------------------------------
generate_target all [get_files shell.bd]
generate_target all [get_files user.bd]
# -----------------------------------------------------------------------------

# -- [COMPILE] ----------------------------------------------------------------
synth_design -top top
write_checkpoint -force ./post_synth_xilinx_u55n_xdma_gen3x8.dcp
opt_design -directive Explore
place_design -directive Auto_1
phys_opt_design -directive ExploreWithAggressiveHoldFix
route_design -directive AggressiveExplore
phys_opt_design -directive ExploreWithAggressiveHoldFix
write_checkpoint ./post_route_xilinx_u55n_xdma_gen3x8.dcp
write_bitstream -bin_file -force ./warpshell_xilinx_u55n_xdma_gen3x8.bit
write_abstract_shell -cell user_partition -force ./abstract_warpshell_xilinx_u55n_xdma_gen3x8.dcp
write_cfgmem -force -format mcs -interface spix4 -size 128 -loadbit "up 0x01002000 warpshell_xilinx_u55n_xdma_gen3x8.bit" -file "warpshell_xilinx_u55n_xdma_gen3x8.mcs"
# -----------------------------------------------------------------------------
