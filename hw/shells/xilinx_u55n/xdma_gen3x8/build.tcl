set script_path [file dirname [file normalize [info script]]]

create_project -in_memory -part xcu55n-fsvh2892-2L-e
set_property source_mgmt_mode All [current_project]

# -- [READ FILES] -------------------------------------------------------------
source "${script_path}/user_logic.tcl"
source "${script_path}/shell.tcl"
read_xdc "${script_path}/io.xdc"
read_xdc "${script_path}/floorplan.xdc"
# -----------------------------------------------------------------------------

# -- [CONFIGURE USER_LOGIC BD] ------------------------------------------------
cr_bd_user_logic {}
generate_target all [get_files user_logic.bd]
# -----------------------------------------------------------------------------

# -- [CONFIGURE SHELL BD] -----------------------------------------------------
cr_bd_shell {}
open_bd_design [get_files shell.bd]
validate_bd_design
assign_bd_address -force -export_to_file ./addr_map.csv
close_bd_design [get_bd_design shell]
generate_target all [get_files shell.bd]
# -----------------------------------------------------------------------------

# -- [COMPILE] ----------------------------------------------------------------
synth_design -top shell
write_checkpoint -force ./post_synth_xilinx_u55n_xdma_gen3x8.dcp
opt_design -directive Explore
place_design -directive Auto_1
phys_opt_design -directive ExploreWithAggressiveHoldFix
route_design -directive AggressiveExplore
phys_opt_design -directive ExploreWithAggressiveHoldFix
write_checkpoint ./post_route_xilinx_u55n_xdma_gen3x8.dcp
write_bitstream -bin_file -force ./warpshell_xilinx_u55n_xdma_gen3x8.bit
write_abstract_shell -cell user_logic -force ./abstract_warpshell_xilinx_u55n_xdma_gen3x8.dcp
# -----------------------------------------------------------------------------
