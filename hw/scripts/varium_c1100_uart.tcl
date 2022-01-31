create_project -in_memory -part xcu55n-fsvh2892-2l-e

set script_dir [ file dirname [ file normalize [ info script ] ] ]

read_xdc [ glob $script_dir/../src/varium_c1100/uart/*.xdc ]
read_verilog [ glob $script_dir/../src/varium_c1100/uart/*.v ]

puts "---- \[Running Synthesis...\] ----------------------------------------------------"
synth_design -top uart

puts "---- \[Running Pre-Placement Optimization...\] -----------------------------------"
opt_design

puts "---- \[Running Placement...\] ----------------------------------------------------"
place_design

puts "---- \[Running Post-Placement Physical Optimization...\] -------------------------"
phys_opt_design

puts "---- \[Running Routing...\] ------------------------------------------------------"
route_design

puts "---- \[Post Route Utilization\] --------------------------------------------------"
report_utilization -file uart_post_route_utilization.rpt

puts "---- \[Post Route Timing\] -------------------------------------------------------"
report_timing_summary -file uart_post_route_timing.rpt

puts "---- \[Writing Design Checkpoint...\] --------------------------------------------"
write_checkpoint -force uart_post_route.dcp

puts "---- \[Writing Bitstream...\] ----------------------------------------------------"
write_bitstream -force uart.bit
puts "--------------------------------------------------------------------------------"
