create_project -in_memory -part xcu55n-fsvh2892-2l-e

read_xdc [ glob ../hw/src/varium_c1100/xdma_gen4_x8_minimal/*.xdc ]

source ../hw/src/varium_c1100/xdma_gen4_x8_minimal/shell.tcl
make_wrapper -top -import -files [get_files shell.bd]
generate_target all [get_files shell.bd]

puts "---- \[Running Synthesis...\] ----------------------------------------------------"
synth_design -top shell_wrapper

puts "---- \[Running Pre-Placement Optimization...\] -----------------------------------"
opt_design

puts "---- \[Running Placement...\] ----------------------------------------------------"
place_design

puts "---- \[Running Post-Placement Physical Optimization...\] -------------------------"
phys_opt_design

puts "---- \[Running Routing...\] ------------------------------------------------------"
route_design

puts "---- \[Post Route Utilization\] --------------------------------------------------"
report_utilization -file xdma_gen4_x8_minimal_post_route_utilization.rpt

puts "---- \[Post Route Timing\] -------------------------------------------------------"
report_timing_summary -file xdma_gen4_x8_minimal_post_route_timing.rpt

puts "---- \[Writing Design Checkpoint...\] --------------------------------------------"
write_checkpoint -force xdma_gen4_x8_minimal_post_route.dcp

puts "---- \[Writing Bitstream...\] ----------------------------------------------------"
write_bitstream -force xdma_gen4_x8_minimal.bit
write_debug_probes -force xdma_gen4_x8_minimal.ltx
puts "--------------------------------------------------------------------------------"
