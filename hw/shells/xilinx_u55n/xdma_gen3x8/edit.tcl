set script_path [file dirname [file normalize [info script]]]

create_project -in_memory -part xcu55n-fsvh2892-2L-e
set_property source_mgmt_mode All [current_project]

source "${script_path}/user_logic.tcl"
source "${script_path}/shell.tcl"
read_verilog "${script_path}/../../../utils/hbm_channel_nc.v"

start_gui

cr_bd_user_logic {}
cr_bd_shell {}
