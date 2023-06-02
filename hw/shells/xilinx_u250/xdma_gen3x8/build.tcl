set script_path [file dirname [file normalize [info script]]]

create_project -part xcu250-figd2104-2L-e synth synth
set_property source_mgmt_mode All [current_project]

# -- [READ FILES] -------------------------------------------------------------
import_files ${script_path}/shell.bd
import_files ${script_path}/user.bd
import_files "${script_path}/io.xdc"
import_files "${script_path}/misc.xdc"
import_files "${script_path}/floorplan.xdc"
import_files "${script_path}/top.v"
# -----------------------------------------------------------------------------

# -- [GENERATE BDS] -----------------------------------------------------------
set_property synth_checkpoint_mode Hierarchical [get_files shell.bd]
set_property synth_checkpoint_mode Hierarchical [get_files user.bd]
generate_target all [get_files shell.bd]
generate_target all [get_files user.bd]
# -----------------------------------------------------------------------------

# -- [COMPILE] ----------------------------------------------------------------
export_ip_user_files -of_objects [get_files shell.bd] -no_script -sync -force -quiet
export_ip_user_files -of_objects [get_files user.bd] -no_script -sync -force -quiet
create_ip_run [get_files -of_objects [get_fileset sources_1] shell.bd]
create_ip_run [get_files -of_objects [get_fileset sources_1] user.bd]

launch_runs synth_1 -jobs 16
wait_on_runs synth_1

open_run synth_1
write_checkpoint -force ./post_synth_xilinx_u250_xdma_gen3x8.dcp
opt_design -directive Explore
place_design -directive Auto_1
phys_opt_design -directive ExploreWithAggressiveHoldFix
route_design -directive AggressiveExplore
phys_opt_design -directive ExploreWithAggressiveHoldFix
write_checkpoint ./post_route_xilinx_u250_xdma_gen3x8.dcp
write_bitstream -bin_file -force ./warpshell_xilinx_u250_xdma_gen3x8.bit
write_abstract_shell -cell user_partition -force ./abstract_warpshell_xilinx_u250_xdma_gen3x8.dcp
write_cfgmem -force -format mcs -interface spix4 -size 256 -loadbit "up 0x01002000 warpshell_xilinx_u250_xdma_gen3x8.bit" -file "warpshell_xilinx_u250_xdma_gen3x8.mcs"
# -----------------------------------------------------------------------------
