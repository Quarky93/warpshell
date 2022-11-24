set bd [lindex $argv 0]
set script_path [file dirname [file normalize [info script]]]

create_project -in_memory -part xcu55c-fsvh2892-2L-e
set_property source_mgmt_mode All [current_project]

proc commit {} {
    validate_bd_design
    puts "Writing to: $::script_path/$::bd.tcl"
    write_bd_tcl -bd_name $::bd -no_project_wrapper -make_local -force "$::script_path/$::bd.tcl"
}

source "${script_path}/${bd}.tcl"

start_gui

cr_bd_${bd} {}
