create_pblock shell_partition
resize_pblock shell_partition -add {CLOCKREGION_X0Y2:CLOCKREGION_X0Y4}
add_cells_to_pblock shell_partition [get_cells shell_partition]

create_pblock user_partition
resize_pblock [get_pblocks user_partition] -add {SLICE_X84Y100:SLICE_X163Y249 SLICE_X0Y0:SLICE_X163Y99}
resize_pblock [get_pblocks user_partition] -add {DSP48_X7Y0:DSP48_X8Y99 DSP48_X5Y20:DSP48_X6Y79 DSP48_X0Y0:DSP48_X4Y39}
resize_pblock [get_pblocks user_partition] -add {RAMB18_X7Y0:RAMB18_X8Y99 RAMB18_X5Y20:RAMB18_X6Y79 RAMB18_X0Y0:RAMB18_X4Y39}
resize_pblock [get_pblocks user_partition] -add {RAMB36_X7Y0:RAMB36_X8Y49 RAMB36_X5Y10:RAMB36_X6Y39 RAMB36_X0Y0:RAMB36_X4Y19}
add_cells_to_pblock user_partition [get_cells user_partition]
set_property HD.RECONFIGURABLE TRUE [get_cells user_partition]
set_property SNAPPING_MODE ON [get_pblocks user_partition]
set_property RESET_AFTER_RECONFIG 1 [get_pblocks user_partition]