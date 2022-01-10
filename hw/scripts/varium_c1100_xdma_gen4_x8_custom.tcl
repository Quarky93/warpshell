create_project varium_c1100_xdma_gen4_x8_custom ./varium_c1100_xdma_gen4_x8_custom -part xcu55n-fsvh2892-2l-e

set script_dir [ file dirname [ file normalize [ info script ] ] ]

add_files -fileset constrs_1 [ glob $script_dir/../src/varium_c1100/xdma_gen4_x8_minimal/*.xdc ]

source $script_dir/../src/varium_c1100/xdma_gen4_x8_minimal/shell.tcl
make_wrapper -top -import -files [get_files shell.bd]
