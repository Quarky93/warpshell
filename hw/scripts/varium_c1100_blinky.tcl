create_project -in_memory -part xcu55n-fsvh2892-2l-e

read_xdc [ glob ../hw/src/varium_c1100/blinky/*.xdc ]
read_verilog [ glob ../hw/src/varium_c1100/blinky/*.v ]

puts "---- \[Running Synthesis...\] ----------------------------------------------------"
synth_design -top blinky

puts "---- \[Post Synthesis Utilization\] ----------------------------------------------"
report_utilization

puts "---- \[Running Pre-Placement Optimization...\] -----------------------------------"
opt_design

puts "---- \[Running Placement...\] ----------------------------------------------------"
place_design

puts "---- \[Running Post-Placement Physical Optimization...\] -------------------------"
phys_opt_design

puts "---- \[Post Placement Utilization\] ----------------------------------------------"
report_utilization

puts "---- \[Running Routing...\] ------------------------------------------------------"
route_design

puts "---- \[Post Route Utilization\] --------------------------------------------------"
report_utilization

puts "---- \[Post Route Timing\] -------------------------------------------------------"
report_timing_summary

puts "---- \[Writing Design Checkpoint...\] --------------------------------------------"
write_checkpoint -force blinky_routed.dcp

puts "---- \[Writing Bitstream...\] ----------------------------------------------------"
write_bitstream -force blinky.bit
puts "--------------------------------------------------------------------------------"
