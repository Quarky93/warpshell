create_project varium_c1100_xdma_gen4_x1_custom ./varium_c1100_xdma_gen4_x1_custom -part xcu55n-fsvh2892-2l-e

add_files -fileset constrs_1 [ glob ../hw/src/varium_c1100/xdma_gen4_x1_minimal/*.xdc ]

source ../hw/src/varium_c1100/xdma_gen4_x1_minimal/shell.tcl
make_wrapper -top -import -files [get_files shell.bd]
