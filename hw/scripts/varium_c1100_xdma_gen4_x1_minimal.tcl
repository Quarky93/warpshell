create_project -in_memory -part xcu55n-fsvh2892-2l-e

read_xdc [ glob ../hw/src/varium_c1100/xdma_gen4_x1_minimal/*.xdc ]
read_verilog [ glob ../hw/src/varium_c1100/xdma_gen4_x1_minimal/*.v ]

source ../hw/src/varium_c1100/xdma_gen4_x1_minimal/shell.tcl
generate_target all [get_files shell.bd]

puts "---- \[Running Synthesis...\] ----------------------------------------------------"
synth_design -top xdma_gen4_x1_minimal

puts "---- \[Running Pre-Placement Optimization...\] -----------------------------------"
opt_design

puts "---- \[Running Placement...\] ----------------------------------------------------"
place_design

puts "---- \[Running Post-Placement Physical Optimization...\] -------------------------"
phys_opt_design

puts "---- \[Running Routing...\] ------------------------------------------------------"
route_design

puts "---- \[Post Route Utilization\] --------------------------------------------------"
report_utilization -file xdma_gen4_x1_minimal_post_route_utilization.rpt

puts "---- \[Post Route Timing\] -------------------------------------------------------"
report_timing_summary -file xdma_gen4_x1_minimal_post_route_timing.rpt

puts "---- \[Writing Design Checkpoint...\] --------------------------------------------"
write_checkpoint -force xdma_gen4_x1_minimal_post_route.dcp

puts "---- \[Writing Bitstream...\] ----------------------------------------------------"
write_bitstream -force xdma_gen4_x1_minimal.bit
write_debug_probes -force xdma_gen4_x1_minimal.ltx
puts "--------------------------------------------------------------------------------"
