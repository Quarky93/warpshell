create_pblock user_logic
resize_pblock [get_pblocks user_logic] -add {SLICE_X206Y360:SLICE_X232Y479 SLICE_X206Y0:SLICE_X232Y59 SLICE_X0Y0:SLICE_X205Y479}
resize_pblock [get_pblocks user_logic] -add {CFGIO_SITE_X0Y1:CFGIO_SITE_X0Y1}
resize_pblock [get_pblocks user_logic] -add {CMACE4_X0Y0:CMACE4_X0Y4}
resize_pblock [get_pblocks user_logic] -add {DSP48E2_X30Y138:DSP48E2_X31Y185 DSP48E2_X30Y0:DSP48E2_X31Y17 DSP48E2_X0Y0:DSP48E2_X29Y185}
resize_pblock [get_pblocks user_logic] -add {ILKNE4_X0Y0:ILKNE4_X1Y1}
resize_pblock [get_pblocks user_logic] -add {LAGUNA_X28Y240:LAGUNA_X31Y359 LAGUNA_X0Y0:LAGUNA_X27Y359}
resize_pblock [get_pblocks user_logic] -add {PCIE4CE4_X1Y0:PCIE4CE4_X1Y0 PCIE4CE4_X0Y0:PCIE4CE4_X0Y1}
resize_pblock [get_pblocks user_logic] -add {RAMB18_X12Y144:RAMB18_X13Y191 RAMB18_X12Y0:RAMB18_X13Y23 RAMB18_X0Y0:RAMB18_X11Y191}
resize_pblock [get_pblocks user_logic] -add {RAMB36_X12Y72:RAMB36_X13Y95 RAMB36_X12Y0:RAMB36_X13Y11 RAMB36_X0Y0:RAMB36_X11Y95}
resize_pblock [get_pblocks user_logic] -add {SYSMONE4_X0Y1:SYSMONE4_X0Y1}
resize_pblock [get_pblocks user_logic] -add {URAM288_X0Y0:URAM288_X4Y127}
set_property SNAPPING_MODE ON [get_pblocks user_logic]

add_cells_to_pblock user_logic [get_cells user_logic]
set_property HD.RECONFIGURABLE TRUE [get_cells user_logic]
