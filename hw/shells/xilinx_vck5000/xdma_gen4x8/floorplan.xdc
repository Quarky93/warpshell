create_pblock user_partition
add_cells_to_pblock user_partition [get_cells user_partition]
resize_pblock [get_pblocks user_partition] -add {CLOCKREGION_X0Y4:CLOCKREGION_X9Y5 CLOCKREGION_X1Y3:CLOCKREGION_X9Y3 CLOCKREGION_X2Y1:CLOCKREGION_X9Y2}
set_property HD.RECONFIGURABLE TRUE [get_cells user_partition]
