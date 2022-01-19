# WIP DO NOT USE

set script_dir [ file dirname [ file normalize [ info script ] ] ]

set_param board.repoPaths $script_dir/../boards/Xilinx/varium_c1100/1.0/

create_project -in_memory -part xcu55n-fsvh2892-2L-e

set_property board_part xilinx.com:varium_c1100:part0:1.0

