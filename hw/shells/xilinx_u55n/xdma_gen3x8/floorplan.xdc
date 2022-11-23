create_pblock shell_partition
resize_pblock shell_partition -add {CLOCKREGION_X7Y1:CLOCKREGION_X7Y5}
add_cells_to_pblock shell_partition [get_cells shell_partition]

create_pblock user_partition
resize_pblock user_partition -add {CLOCKREGION_X0Y4:CLOCKREGION_X6Y7}
resize_pblock user_partition -add {CLOCKREGION_X7Y6:CLOCKREGION_X7Y7}
resize_pblock user_partition -add {CLOCKREGION_X0Y0:CLOCKREGION_X6Y3}
resize_pblock user_partition -add {CLOCKREGION_X7Y0:CLOCKREGION_X7Y0}
resize_pblock user_partition -remove {IOB_X0Y103 IOB_X0Y98 IOB_X0Y84 IOB_X0Y93 IOB_X0Y94 IOB_X0Y79 IOB_X0Y78}
add_cells_to_pblock user_partition [get_cells user_partition]
set_property HD.RECONFIGURABLE TRUE [get_cells user_partition]
