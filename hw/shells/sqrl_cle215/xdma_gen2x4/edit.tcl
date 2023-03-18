set script_path [file dirname [file normalize [info script]]]

create_project -in_memory -part xc7a200tfbg484-2
set_property source_mgmt_mode All [current_project]

proc commit {} {
    validate_bd_design
    save_bd_design
    set bd [current_bd_design]
    puts "Writing to: $::script_path/${bd}.bd"
    file copy -force ./${bd}/${bd}.bd $::script_path/
}

file mkdir ./shell/
file mkdir ./user/
file copy ${script_path}/shell.bd ./shell/shell.bd
file copy ${script_path}/user.bd ./user/user.bd
read_bd ./shell/shell.bd
read_bd ./user/user.bd

start_gui
