create_pblock shell_partition
resize_pblock shell_partition -add {CLOCKREGION_X7Y4:CLOCKREGION_X7Y7}
add_cells_to_pblock shell_partition [get_cells shell_partition]

create_pblock user_partition
resize_pblock user_partition -add {CLOCKREGION_X0Y0:CLOCKREGION_X7Y3}
resize_pblock user_partition -add {CLOCKREGION_X0Y4:CLOCKREGION_X6Y7}
resize_pblock user_partition -add {CLOCKREGION_X0Y8:CLOCKREGION_X7Y11}
resize_pblock user_partition -add {CLOCKREGION_X0Y12:CLOCKREGION_X7Y15}
resize_pblock user_partition -remove {IOB_X0Y217 IOB_X0Y218 IOB_X0Y219 IOB_X0Y220 IOB_X0Y255 IOB_X0Y244 IOB_X0Y245}
add_cells_to_pblock user_partition [get_cells user_partition]
set_property HD.RECONFIGURABLE TRUE [get_cells user_partition]
