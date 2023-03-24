set script_path [file dirname [file normalize [info script]]]

create_project -in_memory -part xc7a200tfbg484-2
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

reset_property LOC [get_cells {shell_partition/xdma/inst/shell_xdma_0_pcie2_to_pcie3_wrapper_i/pcie2_ip_i/inst/inst/gt_top_i/pipe_wrapper_i/pipe_lane[0].gt_wrapper_i/gtp_channel.gtpe2_channel_i}]
reset_property LOC [get_cells {shell_partition/xdma/inst/shell_xdma_0_pcie2_to_pcie3_wrapper_i/pcie2_ip_i/inst/inst/gt_top_i/pipe_wrapper_i/pipe_lane[1].gt_wrapper_i/gtp_channel.gtpe2_channel_i}]
reset_property LOC [get_cells {shell_partition/xdma/inst/shell_xdma_0_pcie2_to_pcie3_wrapper_i/pcie2_ip_i/inst/inst/gt_top_i/pipe_wrapper_i/pipe_lane[2].gt_wrapper_i/gtp_channel.gtpe2_channel_i}]
reset_property LOC [get_cells {shell_partition/xdma/inst/shell_xdma_0_pcie2_to_pcie3_wrapper_i/pcie2_ip_i/inst/inst/gt_top_i/pipe_wrapper_i/pipe_lane[3].gt_wrapper_i/gtp_channel.gtpe2_channel_i}]

set_property LOC GTPE2_CHANNEL_X0Y6 [get_cells {shell_partition/xdma/inst/shell_xdma_0_pcie2_to_pcie3_wrapper_i/pcie2_ip_i/inst/inst/gt_top_i/pipe_wrapper_i/pipe_lane[0].gt_wrapper_i/gtp_channel.gtpe2_channel_i}]
set_property LOC GTPE2_CHANNEL_X0Y4 [get_cells {shell_partition/xdma/inst/shell_xdma_0_pcie2_to_pcie3_wrapper_i/pcie2_ip_i/inst/inst/gt_top_i/pipe_wrapper_i/pipe_lane[1].gt_wrapper_i/gtp_channel.gtpe2_channel_i}]
set_property LOC GTPE2_CHANNEL_X0Y5 [get_cells {shell_partition/xdma/inst/shell_xdma_0_pcie2_to_pcie3_wrapper_i/pcie2_ip_i/inst/inst/gt_top_i/pipe_wrapper_i/pipe_lane[2].gt_wrapper_i/gtp_channel.gtpe2_channel_i}]
set_property LOC GTPE2_CHANNEL_X0Y7 [get_cells {shell_partition/xdma/inst/shell_xdma_0_pcie2_to_pcie3_wrapper_i/pcie2_ip_i/inst/inst/gt_top_i/pipe_wrapper_i/pipe_lane[3].gt_wrapper_i/gtp_channel.gtpe2_channel_i}]

write_checkpoint -force ./post_synth_sqrl_cle215_xdma_gen2x4.dcp
opt_design -directive Explore
place_design -directive Auto_1
phys_opt_design -directive ExploreWithAggressiveHoldFix
route_design -directive AggressiveExplore
phys_opt_design -directive ExploreWithAggressiveHoldFix
write_checkpoint ./post_route_sqrl_cle215_xdma_gen2x4.dcp
update_design -cell user_partition -black_box
lock_design -level routing
write_checkpoint -force ./abstract_warpshell_sqrl_cle215_xdma_gen3x8.dcp
write_bitstream -bin_file -force ./warpshell_sqrl_cle215_gen2x4.bit
write_cfgmem -force -format mcs -interface spix4 -size 16 -loadbit "up 0x00000000 warpshell_sqrl_cle215_gen2x4.bit" -file "warpshell_sqrl_cle215_xdma_gen2x4.mcs"
# -----------------------------------------------------------------------------
