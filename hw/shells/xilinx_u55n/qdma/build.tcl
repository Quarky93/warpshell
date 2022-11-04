set pcie_gen [lindex $argv 0]
set pcie_lanes [lindex $argv 1]

switch "${pcie_gen}${pcie_lanes}" {
    "gen3x4" {
        set pcie_link_speed "8.0_GT/s"
        set pcie_link_width "X4"
        set dma_data_width "128"
        read_xdc "./floorplan_small.xdc"
    }
    "gen3x8" {
        set pcie_linkspeed "8.0_GT/s"
        set pcie_link_width "X8"
        set dma_data_width "256"
        read_xdc "./floorplan_medium.xdc"
    }
    "gen4x4" {
        set pcie_linkspeed "16.0_GT/s"
        set pcie_link_width "X4"
        set dma_data_width "256"
        read_xdc "./floorplan_medium.xdc"
    }
    "gen4x8" {
        set pcie_linkspeed "16.0_GT/s"
        set pcie_link_width "X8"
        set dma_data_width "512"
        read_xdc "./floorplan_large.xdc"
    }
    default {
        puts "pcie_gen: ${pcie_gen} unsupported"
        exit
    }
}

create_project -in_memory -part xcu55n-fsvh2892-2L-e

# -- [READ FILES] -------------------------------------------------------------
read_bd "./shell.bd"
read_bd "./user_logic.bd"
read_xdc "./io.xdc"
# -----------------------------------------------------------------------------

# -- [CONFIGURE SHELL BD] -----------------------------------------------------
open_bd_design [get_files shell.bd]
set_property -dict [list CONFIG.DATA_WIDTH ${dma_data_width}] [get_bd_cells dma_firewall]
set_property -dict [list CONFIG.DATA_WIDTH ${dma_data_width}] [get_bd_intf_ports user_axi_dma]
set_property CONFIG.CONST_VAL {0xDEADBEEF} [get_bd_cells const_id]
# -----------------------------------------------------------------------------

# -- [CONFIGURE USER LOGIC BD] ------------------------------------------------
open_bd_design [get_files user_logic.bd]
set_property -dict [list CONFIG.DATA_WIDTH ${dma_data_width}] [get_bd_intf_ports user_axi_dma]
# -----------------------------------------------------------------------------
