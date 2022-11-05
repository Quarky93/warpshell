set part [lindex $argv 0]
set bd_name [lindex $argv 1]
set bd_script [lindex $argv 2]

create_project -in_memory -part ${part}

source ${bd_script}

cr_bd_${bd_name} {}

start_gui
