create_project varium_c1100_xdma_gen4_x1_minimal ./varium_c1100_xdma_gen4_x1_minimal_custom -part xcu55n-fsvh2892-2l-e

add_files -fileset constrs_1 [ glob ../hw/src/varium_c1100/xdma_gen4_x1_minimal/*.xdc ]
add_files [ glob ../hw/src/varium_c1100/xdma_gen4_x1_minimal/*.v ]

source ../hw/src/varium_c1100/xdma_gen4_x1_minimal/shell.tcl
