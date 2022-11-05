# Proc to create BD user_logic
proc cr_bd_user_logic { parentCell } {
# The design that will be created by this Tcl proc contains the following 
# module references:
# hbm_channel_nc, hbm_channel_nc, hbm_channel_nc, hbm_channel_nc, hbm_channel_nc, hbm_channel_nc, hbm_channel_nc, hbm_channel_nc, hbm_channel_nc, hbm_channel_nc, hbm_channel_nc, hbm_channel_nc, hbm_channel_nc, hbm_channel_nc, hbm_channel_nc, hbm_channel_nc, hbm_channel_nc, hbm_channel_nc, hbm_channel_nc, hbm_channel_nc, hbm_channel_nc, hbm_channel_nc, hbm_channel_nc, hbm_channel_nc, hbm_channel_nc, hbm_channel_nc, hbm_channel_nc, hbm_channel_nc, hbm_channel_nc, hbm_channel_nc, hbm_channel_nc



  # CHANGE DESIGN NAME HERE
  set design_name user_logic

  common::send_gid_msg -ssname BD::TCL -id 2010 -severity "INFO" "Currently there is no design <$design_name> in project, so creating one..."

  create_bd_design $design_name

  set bCheckIPsPassed 1
  ##################################################################
  # CHECK IPs
  ##################################################################
  set bCheckIPs 1
  if { $bCheckIPs == 1 } {
     set list_check_ips "\ 
  xilinx.com:ip:axi_register_slice:2.1\
  xilinx.com:ip:axi_bram_ctrl:4.1\
  xilinx.com:ip:blk_mem_gen:8.4\
  xilinx.com:ip:smartconnect:1.0\
  "

   set list_ips_missing ""
   common::send_gid_msg -ssname BD::TCL -id 2011 -severity "INFO" "Checking if the following IPs exist in the project's IP catalog: $list_check_ips ."

   foreach ip_vlnv $list_check_ips {
      set ip_obj [get_ipdefs -all $ip_vlnv]
      if { $ip_obj eq "" } {
         lappend list_ips_missing $ip_vlnv
      }
   }

   if { $list_ips_missing ne "" } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2012 -severity "ERROR" "The following IPs are not found in the IP Catalog:\n  $list_ips_missing\n\nResolution: Please add the repository containing the IP(s) to the project." }
      set bCheckIPsPassed 0
   }

  }

  ##################################################################
  # CHECK Modules
  ##################################################################
  set bCheckModules 1
  if { $bCheckModules == 1 } {
     set list_check_mods "\ 
  hbm_channel_nc\
  hbm_channel_nc\
  hbm_channel_nc\
  hbm_channel_nc\
  hbm_channel_nc\
  hbm_channel_nc\
  hbm_channel_nc\
  hbm_channel_nc\
  hbm_channel_nc\
  hbm_channel_nc\
  hbm_channel_nc\
  hbm_channel_nc\
  hbm_channel_nc\
  hbm_channel_nc\
  hbm_channel_nc\
  hbm_channel_nc\
  hbm_channel_nc\
  hbm_channel_nc\
  hbm_channel_nc\
  hbm_channel_nc\
  hbm_channel_nc\
  hbm_channel_nc\
  hbm_channel_nc\
  hbm_channel_nc\
  hbm_channel_nc\
  hbm_channel_nc\
  hbm_channel_nc\
  hbm_channel_nc\
  hbm_channel_nc\
  hbm_channel_nc\
  hbm_channel_nc\
  "

   set list_mods_missing ""
   common::send_gid_msg -ssname BD::TCL -id 2020 -severity "INFO" "Checking if the following modules exist in the project's sources: $list_check_mods ."

   foreach mod_vlnv $list_check_mods {
      if { [can_resolve_reference $mod_vlnv] == 0 } {
         lappend list_mods_missing $mod_vlnv
      }
   }

   if { $list_mods_missing ne "" } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2021 -severity "ERROR" "The following module(s) are not found in the project: $list_mods_missing" }
      common::send_gid_msg -ssname BD::TCL -id 2022 -severity "INFO" "Please add source files for the missing module(s) above."
      set bCheckIPsPassed 0
   }
}

  if { $bCheckIPsPassed != 1 } {
    common::send_gid_msg -ssname BD::TCL -id 2023 -severity "WARNING" "Will not continue with creation of design due to the error(s) above."
    return 3
  }

  
# Hierarchical cell: hbm_channel_nc
proc create_hier_cell_hbm_channel_nc { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_hbm_channel_nc() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 user_axi_hbm_s00

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 user_axi_hbm_s01

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 user_axi_hbm_s02

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 user_axi_hbm_s03

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 user_axi_hbm_s04

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 user_axi_hbm_s05

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 user_axi_hbm_s06

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 user_axi_hbm_s07

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 user_axi_hbm_s08

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 user_axi_hbm_s09

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 user_axi_hbm_s10

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 user_axi_hbm_s11

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 user_axi_hbm_s12

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 user_axi_hbm_s13

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 user_axi_hbm_s14

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 user_axi_hbm_s15

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 user_axi_hbm_s16

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 user_axi_hbm_s17

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 user_axi_hbm_s18

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 user_axi_hbm_s19

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 user_axi_hbm_s20

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 user_axi_hbm_s21

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 user_axi_hbm_s22

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 user_axi_hbm_s23

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 user_axi_hbm_s24

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 user_axi_hbm_s25

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 user_axi_hbm_s26

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 user_axi_hbm_s27

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 user_axi_hbm_s28

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 user_axi_hbm_s29

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 user_axi_hbm_s30


  # Create pins
  create_bd_pin -dir I -type clk user_axi_hbm_clk

  # Create instance: hbm_channel_nc_0, and set properties
  set block_name hbm_channel_nc
  set block_cell_name hbm_channel_nc_0
  if { [catch {set hbm_channel_nc_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $hbm_channel_nc_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: hbm_channel_nc_1, and set properties
  set block_name hbm_channel_nc
  set block_cell_name hbm_channel_nc_1
  if { [catch {set hbm_channel_nc_1 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $hbm_channel_nc_1 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: hbm_channel_nc_2, and set properties
  set block_name hbm_channel_nc
  set block_cell_name hbm_channel_nc_2
  if { [catch {set hbm_channel_nc_2 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $hbm_channel_nc_2 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: hbm_channel_nc_3, and set properties
  set block_name hbm_channel_nc
  set block_cell_name hbm_channel_nc_3
  if { [catch {set hbm_channel_nc_3 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $hbm_channel_nc_3 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: hbm_channel_nc_4, and set properties
  set block_name hbm_channel_nc
  set block_cell_name hbm_channel_nc_4
  if { [catch {set hbm_channel_nc_4 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $hbm_channel_nc_4 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: hbm_channel_nc_5, and set properties
  set block_name hbm_channel_nc
  set block_cell_name hbm_channel_nc_5
  if { [catch {set hbm_channel_nc_5 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $hbm_channel_nc_5 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: hbm_channel_nc_6, and set properties
  set block_name hbm_channel_nc
  set block_cell_name hbm_channel_nc_6
  if { [catch {set hbm_channel_nc_6 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $hbm_channel_nc_6 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: hbm_channel_nc_7, and set properties
  set block_name hbm_channel_nc
  set block_cell_name hbm_channel_nc_7
  if { [catch {set hbm_channel_nc_7 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $hbm_channel_nc_7 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: hbm_channel_nc_8, and set properties
  set block_name hbm_channel_nc
  set block_cell_name hbm_channel_nc_8
  if { [catch {set hbm_channel_nc_8 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $hbm_channel_nc_8 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: hbm_channel_nc_9, and set properties
  set block_name hbm_channel_nc
  set block_cell_name hbm_channel_nc_9
  if { [catch {set hbm_channel_nc_9 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $hbm_channel_nc_9 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: hbm_channel_nc_10, and set properties
  set block_name hbm_channel_nc
  set block_cell_name hbm_channel_nc_10
  if { [catch {set hbm_channel_nc_10 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $hbm_channel_nc_10 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: hbm_channel_nc_11, and set properties
  set block_name hbm_channel_nc
  set block_cell_name hbm_channel_nc_11
  if { [catch {set hbm_channel_nc_11 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $hbm_channel_nc_11 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: hbm_channel_nc_12, and set properties
  set block_name hbm_channel_nc
  set block_cell_name hbm_channel_nc_12
  if { [catch {set hbm_channel_nc_12 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $hbm_channel_nc_12 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: hbm_channel_nc_13, and set properties
  set block_name hbm_channel_nc
  set block_cell_name hbm_channel_nc_13
  if { [catch {set hbm_channel_nc_13 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $hbm_channel_nc_13 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: hbm_channel_nc_14, and set properties
  set block_name hbm_channel_nc
  set block_cell_name hbm_channel_nc_14
  if { [catch {set hbm_channel_nc_14 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $hbm_channel_nc_14 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: hbm_channel_nc_15, and set properties
  set block_name hbm_channel_nc
  set block_cell_name hbm_channel_nc_15
  if { [catch {set hbm_channel_nc_15 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $hbm_channel_nc_15 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: hbm_channel_nc_16, and set properties
  set block_name hbm_channel_nc
  set block_cell_name hbm_channel_nc_16
  if { [catch {set hbm_channel_nc_16 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $hbm_channel_nc_16 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: hbm_channel_nc_17, and set properties
  set block_name hbm_channel_nc
  set block_cell_name hbm_channel_nc_17
  if { [catch {set hbm_channel_nc_17 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $hbm_channel_nc_17 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: hbm_channel_nc_18, and set properties
  set block_name hbm_channel_nc
  set block_cell_name hbm_channel_nc_18
  if { [catch {set hbm_channel_nc_18 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $hbm_channel_nc_18 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: hbm_channel_nc_19, and set properties
  set block_name hbm_channel_nc
  set block_cell_name hbm_channel_nc_19
  if { [catch {set hbm_channel_nc_19 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $hbm_channel_nc_19 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: hbm_channel_nc_20, and set properties
  set block_name hbm_channel_nc
  set block_cell_name hbm_channel_nc_20
  if { [catch {set hbm_channel_nc_20 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $hbm_channel_nc_20 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: hbm_channel_nc_21, and set properties
  set block_name hbm_channel_nc
  set block_cell_name hbm_channel_nc_21
  if { [catch {set hbm_channel_nc_21 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $hbm_channel_nc_21 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: hbm_channel_nc_22, and set properties
  set block_name hbm_channel_nc
  set block_cell_name hbm_channel_nc_22
  if { [catch {set hbm_channel_nc_22 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $hbm_channel_nc_22 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: hbm_channel_nc_23, and set properties
  set block_name hbm_channel_nc
  set block_cell_name hbm_channel_nc_23
  if { [catch {set hbm_channel_nc_23 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $hbm_channel_nc_23 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: hbm_channel_nc_24, and set properties
  set block_name hbm_channel_nc
  set block_cell_name hbm_channel_nc_24
  if { [catch {set hbm_channel_nc_24 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $hbm_channel_nc_24 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: hbm_channel_nc_25, and set properties
  set block_name hbm_channel_nc
  set block_cell_name hbm_channel_nc_25
  if { [catch {set hbm_channel_nc_25 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $hbm_channel_nc_25 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: hbm_channel_nc_26, and set properties
  set block_name hbm_channel_nc
  set block_cell_name hbm_channel_nc_26
  if { [catch {set hbm_channel_nc_26 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $hbm_channel_nc_26 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: hbm_channel_nc_27, and set properties
  set block_name hbm_channel_nc
  set block_cell_name hbm_channel_nc_27
  if { [catch {set hbm_channel_nc_27 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $hbm_channel_nc_27 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: hbm_channel_nc_28, and set properties
  set block_name hbm_channel_nc
  set block_cell_name hbm_channel_nc_28
  if { [catch {set hbm_channel_nc_28 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $hbm_channel_nc_28 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: hbm_channel_nc_29, and set properties
  set block_name hbm_channel_nc
  set block_cell_name hbm_channel_nc_29
  if { [catch {set hbm_channel_nc_29 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $hbm_channel_nc_29 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: hbm_channel_nc_30, and set properties
  set block_name hbm_channel_nc
  set block_cell_name hbm_channel_nc_30
  if { [catch {set hbm_channel_nc_30 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $hbm_channel_nc_30 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create interface connections
  connect_bd_intf_net -intf_net Conn1 [get_bd_intf_pins user_axi_hbm_s00] [get_bd_intf_pins hbm_channel_nc_0/m_axi]
  connect_bd_intf_net -intf_net Conn2 [get_bd_intf_pins user_axi_hbm_s01] [get_bd_intf_pins hbm_channel_nc_1/m_axi]
  connect_bd_intf_net -intf_net Conn3 [get_bd_intf_pins user_axi_hbm_s02] [get_bd_intf_pins hbm_channel_nc_2/m_axi]
  connect_bd_intf_net -intf_net Conn4 [get_bd_intf_pins user_axi_hbm_s03] [get_bd_intf_pins hbm_channel_nc_3/m_axi]
  connect_bd_intf_net -intf_net Conn5 [get_bd_intf_pins user_axi_hbm_s04] [get_bd_intf_pins hbm_channel_nc_4/m_axi]
  connect_bd_intf_net -intf_net Conn6 [get_bd_intf_pins user_axi_hbm_s05] [get_bd_intf_pins hbm_channel_nc_5/m_axi]
  connect_bd_intf_net -intf_net Conn7 [get_bd_intf_pins user_axi_hbm_s06] [get_bd_intf_pins hbm_channel_nc_6/m_axi]
  connect_bd_intf_net -intf_net Conn8 [get_bd_intf_pins user_axi_hbm_s07] [get_bd_intf_pins hbm_channel_nc_7/m_axi]
  connect_bd_intf_net -intf_net Conn9 [get_bd_intf_pins user_axi_hbm_s08] [get_bd_intf_pins hbm_channel_nc_8/m_axi]
  connect_bd_intf_net -intf_net Conn10 [get_bd_intf_pins user_axi_hbm_s09] [get_bd_intf_pins hbm_channel_nc_9/m_axi]
  connect_bd_intf_net -intf_net Conn11 [get_bd_intf_pins user_axi_hbm_s10] [get_bd_intf_pins hbm_channel_nc_10/m_axi]
  connect_bd_intf_net -intf_net Conn12 [get_bd_intf_pins user_axi_hbm_s11] [get_bd_intf_pins hbm_channel_nc_11/m_axi]
  connect_bd_intf_net -intf_net Conn13 [get_bd_intf_pins user_axi_hbm_s12] [get_bd_intf_pins hbm_channel_nc_12/m_axi]
  connect_bd_intf_net -intf_net Conn14 [get_bd_intf_pins user_axi_hbm_s13] [get_bd_intf_pins hbm_channel_nc_13/m_axi]
  connect_bd_intf_net -intf_net Conn15 [get_bd_intf_pins user_axi_hbm_s14] [get_bd_intf_pins hbm_channel_nc_14/m_axi]
  connect_bd_intf_net -intf_net Conn16 [get_bd_intf_pins user_axi_hbm_s15] [get_bd_intf_pins hbm_channel_nc_15/m_axi]
  connect_bd_intf_net -intf_net Conn17 [get_bd_intf_pins user_axi_hbm_s16] [get_bd_intf_pins hbm_channel_nc_16/m_axi]
  connect_bd_intf_net -intf_net Conn18 [get_bd_intf_pins user_axi_hbm_s17] [get_bd_intf_pins hbm_channel_nc_17/m_axi]
  connect_bd_intf_net -intf_net Conn19 [get_bd_intf_pins user_axi_hbm_s18] [get_bd_intf_pins hbm_channel_nc_18/m_axi]
  connect_bd_intf_net -intf_net Conn20 [get_bd_intf_pins user_axi_hbm_s19] [get_bd_intf_pins hbm_channel_nc_19/m_axi]
  connect_bd_intf_net -intf_net Conn21 [get_bd_intf_pins user_axi_hbm_s20] [get_bd_intf_pins hbm_channel_nc_20/m_axi]
  connect_bd_intf_net -intf_net Conn22 [get_bd_intf_pins user_axi_hbm_s21] [get_bd_intf_pins hbm_channel_nc_21/m_axi]
  connect_bd_intf_net -intf_net Conn23 [get_bd_intf_pins user_axi_hbm_s22] [get_bd_intf_pins hbm_channel_nc_22/m_axi]
  connect_bd_intf_net -intf_net Conn24 [get_bd_intf_pins user_axi_hbm_s23] [get_bd_intf_pins hbm_channel_nc_23/m_axi]
  connect_bd_intf_net -intf_net Conn25 [get_bd_intf_pins user_axi_hbm_s24] [get_bd_intf_pins hbm_channel_nc_24/m_axi]
  connect_bd_intf_net -intf_net Conn26 [get_bd_intf_pins user_axi_hbm_s25] [get_bd_intf_pins hbm_channel_nc_25/m_axi]
  connect_bd_intf_net -intf_net Conn27 [get_bd_intf_pins user_axi_hbm_s26] [get_bd_intf_pins hbm_channel_nc_26/m_axi]
  connect_bd_intf_net -intf_net Conn28 [get_bd_intf_pins user_axi_hbm_s27] [get_bd_intf_pins hbm_channel_nc_27/m_axi]
  connect_bd_intf_net -intf_net Conn29 [get_bd_intf_pins user_axi_hbm_s28] [get_bd_intf_pins hbm_channel_nc_28/m_axi]
  connect_bd_intf_net -intf_net Conn30 [get_bd_intf_pins user_axi_hbm_s29] [get_bd_intf_pins hbm_channel_nc_29/m_axi]
  connect_bd_intf_net -intf_net Conn31 [get_bd_intf_pins user_axi_hbm_s30] [get_bd_intf_pins hbm_channel_nc_30/m_axi]

  # Create port connections
  connect_bd_net -net user_axi_hbm_clk_1 [get_bd_pins user_axi_hbm_clk] [get_bd_pins hbm_channel_nc_0/aclk] [get_bd_pins hbm_channel_nc_1/aclk] [get_bd_pins hbm_channel_nc_10/aclk] [get_bd_pins hbm_channel_nc_11/aclk] [get_bd_pins hbm_channel_nc_12/aclk] [get_bd_pins hbm_channel_nc_13/aclk] [get_bd_pins hbm_channel_nc_14/aclk] [get_bd_pins hbm_channel_nc_15/aclk] [get_bd_pins hbm_channel_nc_16/aclk] [get_bd_pins hbm_channel_nc_17/aclk] [get_bd_pins hbm_channel_nc_18/aclk] [get_bd_pins hbm_channel_nc_19/aclk] [get_bd_pins hbm_channel_nc_2/aclk] [get_bd_pins hbm_channel_nc_20/aclk] [get_bd_pins hbm_channel_nc_21/aclk] [get_bd_pins hbm_channel_nc_22/aclk] [get_bd_pins hbm_channel_nc_23/aclk] [get_bd_pins hbm_channel_nc_24/aclk] [get_bd_pins hbm_channel_nc_25/aclk] [get_bd_pins hbm_channel_nc_26/aclk] [get_bd_pins hbm_channel_nc_27/aclk] [get_bd_pins hbm_channel_nc_28/aclk] [get_bd_pins hbm_channel_nc_29/aclk] [get_bd_pins hbm_channel_nc_3/aclk] [get_bd_pins hbm_channel_nc_30/aclk] [get_bd_pins hbm_channel_nc_4/aclk] [get_bd_pins hbm_channel_nc_5/aclk] [get_bd_pins hbm_channel_nc_6/aclk] [get_bd_pins hbm_channel_nc_7/aclk] [get_bd_pins hbm_channel_nc_8/aclk] [get_bd_pins hbm_channel_nc_9/aclk]

  # Restore current instance
  current_bd_instance $oldCurInst
}
  variable script_folder

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set user_axi_ctrl [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 user_axi_ctrl ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {32} \
   CONFIG.ARUSER_WIDTH {0} \
   CONFIG.AWUSER_WIDTH {0} \
   CONFIG.BUSER_WIDTH {0} \
   CONFIG.DATA_WIDTH {32} \
   CONFIG.FREQ_HZ {250000000} \
   CONFIG.HAS_BRESP {1} \
   CONFIG.HAS_BURST {0} \
   CONFIG.HAS_CACHE {0} \
   CONFIG.HAS_LOCK {0} \
   CONFIG.HAS_PROT {1} \
   CONFIG.HAS_QOS {0} \
   CONFIG.HAS_REGION {0} \
   CONFIG.HAS_RRESP {1} \
   CONFIG.HAS_WSTRB {1} \
   CONFIG.ID_WIDTH {0} \
   CONFIG.MAX_BURST_LENGTH {1} \
   CONFIG.NUM_READ_OUTSTANDING {1} \
   CONFIG.NUM_READ_THREADS {1} \
   CONFIG.NUM_WRITE_OUTSTANDING {1} \
   CONFIG.NUM_WRITE_THREADS {1} \
   CONFIG.PROTOCOL {AXI4LITE} \
   CONFIG.READ_WRITE_MODE {READ_WRITE} \
   CONFIG.RUSER_BITS_PER_BYTE {0} \
   CONFIG.RUSER_WIDTH {0} \
   CONFIG.SUPPORTS_NARROW_BURST {0} \
   CONFIG.WUSER_BITS_PER_BYTE {0} \
   CONFIG.WUSER_WIDTH {0} \
   ] $user_axi_ctrl

  set user_axi_dma [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 user_axi_dma ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {64} \
   CONFIG.ARUSER_WIDTH {0} \
   CONFIG.AWUSER_WIDTH {0} \
   CONFIG.BUSER_WIDTH {0} \
   CONFIG.DATA_WIDTH {256} \
   CONFIG.FREQ_HZ {250000000} \
   CONFIG.HAS_BRESP {1} \
   CONFIG.HAS_BURST {0} \
   CONFIG.HAS_CACHE {0} \
   CONFIG.HAS_LOCK {0} \
   CONFIG.HAS_PROT {0} \
   CONFIG.HAS_QOS {0} \
   CONFIG.HAS_REGION {0} \
   CONFIG.HAS_RRESP {1} \
   CONFIG.HAS_WSTRB {1} \
   CONFIG.ID_WIDTH {0} \
   CONFIG.MAX_BURST_LENGTH {256} \
   CONFIG.NUM_READ_OUTSTANDING {32} \
   CONFIG.NUM_READ_THREADS {1} \
   CONFIG.NUM_WRITE_OUTSTANDING {16} \
   CONFIG.NUM_WRITE_THREADS {1} \
   CONFIG.PROTOCOL {AXI4} \
   CONFIG.READ_WRITE_MODE {READ_WRITE} \
   CONFIG.RUSER_BITS_PER_BYTE {0} \
   CONFIG.RUSER_WIDTH {0} \
   CONFIG.SUPPORTS_NARROW_BURST {0} \
   CONFIG.WUSER_BITS_PER_BYTE {0} \
   CONFIG.WUSER_WIDTH {0} \
   ] $user_axi_dma

  set user_axi_hbm_s00 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 user_axi_hbm_s00 ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {33} \
   CONFIG.DATA_WIDTH {256} \
   CONFIG.FREQ_HZ {450000000} \
   CONFIG.HAS_CACHE {0} \
   CONFIG.HAS_LOCK {0} \
   CONFIG.HAS_PROT {0} \
   CONFIG.HAS_QOS {0} \
   CONFIG.HAS_REGION {0} \
   CONFIG.NUM_READ_OUTSTANDING {2} \
   CONFIG.NUM_WRITE_OUTSTANDING {2} \
   CONFIG.PROTOCOL {AXI3} \
   ] $user_axi_hbm_s00

  set user_axi_hbm_s01 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 user_axi_hbm_s01 ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {33} \
   CONFIG.DATA_WIDTH {256} \
   CONFIG.FREQ_HZ {450000000} \
   CONFIG.HAS_CACHE {0} \
   CONFIG.HAS_LOCK {0} \
   CONFIG.HAS_PROT {0} \
   CONFIG.HAS_QOS {0} \
   CONFIG.HAS_REGION {0} \
   CONFIG.NUM_READ_OUTSTANDING {2} \
   CONFIG.NUM_WRITE_OUTSTANDING {2} \
   CONFIG.PROTOCOL {AXI3} \
   ] $user_axi_hbm_s01

  set user_axi_hbm_s02 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 user_axi_hbm_s02 ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {33} \
   CONFIG.DATA_WIDTH {256} \
   CONFIG.FREQ_HZ {450000000} \
   CONFIG.HAS_CACHE {0} \
   CONFIG.HAS_LOCK {0} \
   CONFIG.HAS_PROT {0} \
   CONFIG.HAS_QOS {0} \
   CONFIG.HAS_REGION {0} \
   CONFIG.NUM_READ_OUTSTANDING {2} \
   CONFIG.NUM_WRITE_OUTSTANDING {2} \
   CONFIG.PROTOCOL {AXI3} \
   ] $user_axi_hbm_s02

  set user_axi_hbm_s03 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 user_axi_hbm_s03 ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {33} \
   CONFIG.DATA_WIDTH {256} \
   CONFIG.FREQ_HZ {450000000} \
   CONFIG.HAS_CACHE {0} \
   CONFIG.HAS_LOCK {0} \
   CONFIG.HAS_PROT {0} \
   CONFIG.HAS_QOS {0} \
   CONFIG.HAS_REGION {0} \
   CONFIG.NUM_READ_OUTSTANDING {2} \
   CONFIG.NUM_WRITE_OUTSTANDING {2} \
   CONFIG.PROTOCOL {AXI3} \
   ] $user_axi_hbm_s03

  set user_axi_hbm_s04 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 user_axi_hbm_s04 ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {33} \
   CONFIG.DATA_WIDTH {256} \
   CONFIG.FREQ_HZ {450000000} \
   CONFIG.HAS_CACHE {0} \
   CONFIG.HAS_LOCK {0} \
   CONFIG.HAS_PROT {0} \
   CONFIG.HAS_QOS {0} \
   CONFIG.HAS_REGION {0} \
   CONFIG.NUM_READ_OUTSTANDING {2} \
   CONFIG.NUM_WRITE_OUTSTANDING {2} \
   CONFIG.PROTOCOL {AXI3} \
   ] $user_axi_hbm_s04

  set user_axi_hbm_s05 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 user_axi_hbm_s05 ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {33} \
   CONFIG.DATA_WIDTH {256} \
   CONFIG.FREQ_HZ {450000000} \
   CONFIG.HAS_CACHE {0} \
   CONFIG.HAS_LOCK {0} \
   CONFIG.HAS_PROT {0} \
   CONFIG.HAS_QOS {0} \
   CONFIG.HAS_REGION {0} \
   CONFIG.NUM_READ_OUTSTANDING {2} \
   CONFIG.NUM_WRITE_OUTSTANDING {2} \
   CONFIG.PROTOCOL {AXI3} \
   ] $user_axi_hbm_s05

  set user_axi_hbm_s06 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 user_axi_hbm_s06 ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {33} \
   CONFIG.DATA_WIDTH {256} \
   CONFIG.FREQ_HZ {450000000} \
   CONFIG.HAS_CACHE {0} \
   CONFIG.HAS_LOCK {0} \
   CONFIG.HAS_PROT {0} \
   CONFIG.HAS_QOS {0} \
   CONFIG.HAS_REGION {0} \
   CONFIG.NUM_READ_OUTSTANDING {2} \
   CONFIG.NUM_WRITE_OUTSTANDING {2} \
   CONFIG.PROTOCOL {AXI3} \
   ] $user_axi_hbm_s06

  set user_axi_hbm_s07 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 user_axi_hbm_s07 ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {33} \
   CONFIG.DATA_WIDTH {256} \
   CONFIG.FREQ_HZ {450000000} \
   CONFIG.HAS_CACHE {0} \
   CONFIG.HAS_LOCK {0} \
   CONFIG.HAS_PROT {0} \
   CONFIG.HAS_QOS {0} \
   CONFIG.HAS_REGION {0} \
   CONFIG.NUM_READ_OUTSTANDING {2} \
   CONFIG.NUM_WRITE_OUTSTANDING {2} \
   CONFIG.PROTOCOL {AXI3} \
   ] $user_axi_hbm_s07

  set user_axi_hbm_s08 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 user_axi_hbm_s08 ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {33} \
   CONFIG.DATA_WIDTH {256} \
   CONFIG.FREQ_HZ {450000000} \
   CONFIG.HAS_CACHE {0} \
   CONFIG.HAS_LOCK {0} \
   CONFIG.HAS_PROT {0} \
   CONFIG.HAS_QOS {0} \
   CONFIG.HAS_REGION {0} \
   CONFIG.NUM_READ_OUTSTANDING {2} \
   CONFIG.NUM_WRITE_OUTSTANDING {2} \
   CONFIG.PROTOCOL {AXI3} \
   ] $user_axi_hbm_s08

  set user_axi_hbm_s09 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 user_axi_hbm_s09 ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {33} \
   CONFIG.DATA_WIDTH {256} \
   CONFIG.FREQ_HZ {450000000} \
   CONFIG.HAS_CACHE {0} \
   CONFIG.HAS_LOCK {0} \
   CONFIG.HAS_PROT {0} \
   CONFIG.HAS_QOS {0} \
   CONFIG.HAS_REGION {0} \
   CONFIG.NUM_READ_OUTSTANDING {2} \
   CONFIG.NUM_WRITE_OUTSTANDING {2} \
   CONFIG.PROTOCOL {AXI3} \
   ] $user_axi_hbm_s09

  set user_axi_hbm_s10 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 user_axi_hbm_s10 ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {33} \
   CONFIG.DATA_WIDTH {256} \
   CONFIG.FREQ_HZ {450000000} \
   CONFIG.HAS_CACHE {0} \
   CONFIG.HAS_LOCK {0} \
   CONFIG.HAS_PROT {0} \
   CONFIG.HAS_QOS {0} \
   CONFIG.HAS_REGION {0} \
   CONFIG.NUM_READ_OUTSTANDING {2} \
   CONFIG.NUM_WRITE_OUTSTANDING {2} \
   CONFIG.PROTOCOL {AXI3} \
   ] $user_axi_hbm_s10

  set user_axi_hbm_s11 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 user_axi_hbm_s11 ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {33} \
   CONFIG.DATA_WIDTH {256} \
   CONFIG.FREQ_HZ {450000000} \
   CONFIG.HAS_CACHE {0} \
   CONFIG.HAS_LOCK {0} \
   CONFIG.HAS_PROT {0} \
   CONFIG.HAS_QOS {0} \
   CONFIG.HAS_REGION {0} \
   CONFIG.NUM_READ_OUTSTANDING {2} \
   CONFIG.NUM_WRITE_OUTSTANDING {2} \
   CONFIG.PROTOCOL {AXI3} \
   ] $user_axi_hbm_s11

  set user_axi_hbm_s12 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 user_axi_hbm_s12 ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {33} \
   CONFIG.DATA_WIDTH {256} \
   CONFIG.FREQ_HZ {450000000} \
   CONFIG.HAS_CACHE {0} \
   CONFIG.HAS_LOCK {0} \
   CONFIG.HAS_PROT {0} \
   CONFIG.HAS_QOS {0} \
   CONFIG.HAS_REGION {0} \
   CONFIG.NUM_READ_OUTSTANDING {2} \
   CONFIG.NUM_WRITE_OUTSTANDING {2} \
   CONFIG.PROTOCOL {AXI3} \
   ] $user_axi_hbm_s12

  set user_axi_hbm_s13 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 user_axi_hbm_s13 ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {33} \
   CONFIG.DATA_WIDTH {256} \
   CONFIG.FREQ_HZ {450000000} \
   CONFIG.HAS_CACHE {0} \
   CONFIG.HAS_LOCK {0} \
   CONFIG.HAS_PROT {0} \
   CONFIG.HAS_QOS {0} \
   CONFIG.HAS_REGION {0} \
   CONFIG.NUM_READ_OUTSTANDING {2} \
   CONFIG.NUM_WRITE_OUTSTANDING {2} \
   CONFIG.PROTOCOL {AXI3} \
   ] $user_axi_hbm_s13

  set user_axi_hbm_s14 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 user_axi_hbm_s14 ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {33} \
   CONFIG.DATA_WIDTH {256} \
   CONFIG.FREQ_HZ {450000000} \
   CONFIG.HAS_CACHE {0} \
   CONFIG.HAS_LOCK {0} \
   CONFIG.HAS_PROT {0} \
   CONFIG.HAS_QOS {0} \
   CONFIG.HAS_REGION {0} \
   CONFIG.NUM_READ_OUTSTANDING {2} \
   CONFIG.NUM_WRITE_OUTSTANDING {2} \
   CONFIG.PROTOCOL {AXI3} \
   ] $user_axi_hbm_s14

  set user_axi_hbm_s15 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 user_axi_hbm_s15 ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {33} \
   CONFIG.DATA_WIDTH {256} \
   CONFIG.FREQ_HZ {450000000} \
   CONFIG.HAS_CACHE {0} \
   CONFIG.HAS_LOCK {0} \
   CONFIG.HAS_PROT {0} \
   CONFIG.HAS_QOS {0} \
   CONFIG.HAS_REGION {0} \
   CONFIG.NUM_READ_OUTSTANDING {2} \
   CONFIG.NUM_WRITE_OUTSTANDING {2} \
   CONFIG.PROTOCOL {AXI3} \
   ] $user_axi_hbm_s15

  set user_axi_hbm_s16 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 user_axi_hbm_s16 ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {33} \
   CONFIG.DATA_WIDTH {256} \
   CONFIG.FREQ_HZ {450000000} \
   CONFIG.HAS_CACHE {0} \
   CONFIG.HAS_LOCK {0} \
   CONFIG.HAS_PROT {0} \
   CONFIG.HAS_QOS {0} \
   CONFIG.HAS_REGION {0} \
   CONFIG.NUM_READ_OUTSTANDING {2} \
   CONFIG.NUM_WRITE_OUTSTANDING {2} \
   CONFIG.PROTOCOL {AXI3} \
   ] $user_axi_hbm_s16

  set user_axi_hbm_s17 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 user_axi_hbm_s17 ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {33} \
   CONFIG.DATA_WIDTH {256} \
   CONFIG.FREQ_HZ {450000000} \
   CONFIG.HAS_CACHE {0} \
   CONFIG.HAS_LOCK {0} \
   CONFIG.HAS_PROT {0} \
   CONFIG.HAS_QOS {0} \
   CONFIG.HAS_REGION {0} \
   CONFIG.NUM_READ_OUTSTANDING {2} \
   CONFIG.NUM_WRITE_OUTSTANDING {2} \
   CONFIG.PROTOCOL {AXI3} \
   ] $user_axi_hbm_s17

  set user_axi_hbm_s18 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 user_axi_hbm_s18 ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {33} \
   CONFIG.DATA_WIDTH {256} \
   CONFIG.FREQ_HZ {450000000} \
   CONFIG.HAS_CACHE {0} \
   CONFIG.HAS_LOCK {0} \
   CONFIG.HAS_PROT {0} \
   CONFIG.HAS_QOS {0} \
   CONFIG.HAS_REGION {0} \
   CONFIG.NUM_READ_OUTSTANDING {2} \
   CONFIG.NUM_WRITE_OUTSTANDING {2} \
   CONFIG.PROTOCOL {AXI3} \
   ] $user_axi_hbm_s18

  set user_axi_hbm_s19 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 user_axi_hbm_s19 ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {33} \
   CONFIG.DATA_WIDTH {256} \
   CONFIG.FREQ_HZ {450000000} \
   CONFIG.HAS_CACHE {0} \
   CONFIG.HAS_LOCK {0} \
   CONFIG.HAS_PROT {0} \
   CONFIG.HAS_QOS {0} \
   CONFIG.HAS_REGION {0} \
   CONFIG.NUM_READ_OUTSTANDING {2} \
   CONFIG.NUM_WRITE_OUTSTANDING {2} \
   CONFIG.PROTOCOL {AXI3} \
   ] $user_axi_hbm_s19

  set user_axi_hbm_s20 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 user_axi_hbm_s20 ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {33} \
   CONFIG.DATA_WIDTH {256} \
   CONFIG.FREQ_HZ {450000000} \
   CONFIG.HAS_CACHE {0} \
   CONFIG.HAS_LOCK {0} \
   CONFIG.HAS_PROT {0} \
   CONFIG.HAS_QOS {0} \
   CONFIG.HAS_REGION {0} \
   CONFIG.NUM_READ_OUTSTANDING {2} \
   CONFIG.NUM_WRITE_OUTSTANDING {2} \
   CONFIG.PROTOCOL {AXI3} \
   ] $user_axi_hbm_s20

  set user_axi_hbm_s21 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 user_axi_hbm_s21 ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {33} \
   CONFIG.DATA_WIDTH {256} \
   CONFIG.FREQ_HZ {450000000} \
   CONFIG.HAS_CACHE {0} \
   CONFIG.HAS_LOCK {0} \
   CONFIG.HAS_PROT {0} \
   CONFIG.HAS_QOS {0} \
   CONFIG.HAS_REGION {0} \
   CONFIG.NUM_READ_OUTSTANDING {2} \
   CONFIG.NUM_WRITE_OUTSTANDING {2} \
   CONFIG.PROTOCOL {AXI3} \
   ] $user_axi_hbm_s21

  set user_axi_hbm_s22 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 user_axi_hbm_s22 ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {33} \
   CONFIG.DATA_WIDTH {256} \
   CONFIG.FREQ_HZ {450000000} \
   CONFIG.HAS_CACHE {0} \
   CONFIG.HAS_LOCK {0} \
   CONFIG.HAS_PROT {0} \
   CONFIG.HAS_QOS {0} \
   CONFIG.HAS_REGION {0} \
   CONFIG.NUM_READ_OUTSTANDING {2} \
   CONFIG.NUM_WRITE_OUTSTANDING {2} \
   CONFIG.PROTOCOL {AXI3} \
   ] $user_axi_hbm_s22

  set user_axi_hbm_s23 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 user_axi_hbm_s23 ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {33} \
   CONFIG.DATA_WIDTH {256} \
   CONFIG.FREQ_HZ {450000000} \
   CONFIG.HAS_CACHE {0} \
   CONFIG.HAS_LOCK {0} \
   CONFIG.HAS_PROT {0} \
   CONFIG.HAS_QOS {0} \
   CONFIG.HAS_REGION {0} \
   CONFIG.NUM_READ_OUTSTANDING {2} \
   CONFIG.NUM_WRITE_OUTSTANDING {2} \
   CONFIG.PROTOCOL {AXI3} \
   ] $user_axi_hbm_s23

  set user_axi_hbm_s24 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 user_axi_hbm_s24 ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {33} \
   CONFIG.DATA_WIDTH {256} \
   CONFIG.FREQ_HZ {450000000} \
   CONFIG.HAS_CACHE {0} \
   CONFIG.HAS_LOCK {0} \
   CONFIG.HAS_PROT {0} \
   CONFIG.HAS_QOS {0} \
   CONFIG.HAS_REGION {0} \
   CONFIG.NUM_READ_OUTSTANDING {2} \
   CONFIG.NUM_WRITE_OUTSTANDING {2} \
   CONFIG.PROTOCOL {AXI3} \
   ] $user_axi_hbm_s24

  set user_axi_hbm_s25 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 user_axi_hbm_s25 ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {33} \
   CONFIG.DATA_WIDTH {256} \
   CONFIG.FREQ_HZ {450000000} \
   CONFIG.HAS_CACHE {0} \
   CONFIG.HAS_LOCK {0} \
   CONFIG.HAS_PROT {0} \
   CONFIG.HAS_QOS {0} \
   CONFIG.HAS_REGION {0} \
   CONFIG.NUM_READ_OUTSTANDING {2} \
   CONFIG.NUM_WRITE_OUTSTANDING {2} \
   CONFIG.PROTOCOL {AXI3} \
   ] $user_axi_hbm_s25

  set user_axi_hbm_s26 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 user_axi_hbm_s26 ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {33} \
   CONFIG.DATA_WIDTH {256} \
   CONFIG.FREQ_HZ {450000000} \
   CONFIG.HAS_CACHE {0} \
   CONFIG.HAS_LOCK {0} \
   CONFIG.HAS_PROT {0} \
   CONFIG.HAS_QOS {0} \
   CONFIG.HAS_REGION {0} \
   CONFIG.NUM_READ_OUTSTANDING {2} \
   CONFIG.NUM_WRITE_OUTSTANDING {2} \
   CONFIG.PROTOCOL {AXI3} \
   ] $user_axi_hbm_s26

  set user_axi_hbm_s27 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 user_axi_hbm_s27 ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {33} \
   CONFIG.DATA_WIDTH {256} \
   CONFIG.FREQ_HZ {450000000} \
   CONFIG.HAS_CACHE {0} \
   CONFIG.HAS_LOCK {0} \
   CONFIG.HAS_PROT {0} \
   CONFIG.HAS_QOS {0} \
   CONFIG.HAS_REGION {0} \
   CONFIG.NUM_READ_OUTSTANDING {2} \
   CONFIG.NUM_WRITE_OUTSTANDING {2} \
   CONFIG.PROTOCOL {AXI3} \
   ] $user_axi_hbm_s27

  set user_axi_hbm_s28 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 user_axi_hbm_s28 ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {33} \
   CONFIG.DATA_WIDTH {256} \
   CONFIG.FREQ_HZ {450000000} \
   CONFIG.HAS_CACHE {0} \
   CONFIG.HAS_LOCK {0} \
   CONFIG.HAS_PROT {0} \
   CONFIG.HAS_QOS {0} \
   CONFIG.HAS_REGION {0} \
   CONFIG.NUM_READ_OUTSTANDING {2} \
   CONFIG.NUM_WRITE_OUTSTANDING {2} \
   CONFIG.PROTOCOL {AXI3} \
   ] $user_axi_hbm_s28

  set user_axi_hbm_s29 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 user_axi_hbm_s29 ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {33} \
   CONFIG.DATA_WIDTH {256} \
   CONFIG.FREQ_HZ {450000000} \
   CONFIG.HAS_CACHE {0} \
   CONFIG.HAS_LOCK {0} \
   CONFIG.HAS_PROT {0} \
   CONFIG.HAS_QOS {0} \
   CONFIG.HAS_REGION {0} \
   CONFIG.NUM_READ_OUTSTANDING {2} \
   CONFIG.NUM_WRITE_OUTSTANDING {2} \
   CONFIG.PROTOCOL {AXI3} \
   ] $user_axi_hbm_s29

  set user_axi_hbm_s30 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 user_axi_hbm_s30 ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {33} \
   CONFIG.DATA_WIDTH {256} \
   CONFIG.FREQ_HZ {450000000} \
   CONFIG.HAS_CACHE {0} \
   CONFIG.HAS_LOCK {0} \
   CONFIG.HAS_PROT {0} \
   CONFIG.HAS_QOS {0} \
   CONFIG.HAS_REGION {0} \
   CONFIG.NUM_READ_OUTSTANDING {2} \
   CONFIG.NUM_WRITE_OUTSTANDING {2} \
   CONFIG.PROTOCOL {AXI3} \
   ] $user_axi_hbm_s30

  set user_axi_hbm_s31 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 user_axi_hbm_s31 ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {33} \
   CONFIG.DATA_WIDTH {256} \
   CONFIG.FREQ_HZ {450000000} \
   CONFIG.HAS_CACHE {0} \
   CONFIG.HAS_LOCK {0} \
   CONFIG.HAS_PROT {0} \
   CONFIG.HAS_QOS {0} \
   CONFIG.HAS_REGION {0} \
   CONFIG.NUM_READ_OUTSTANDING {2} \
   CONFIG.NUM_WRITE_OUTSTANDING {2} \
   CONFIG.PROTOCOL {AXI3} \
   ] $user_axi_hbm_s31


  # Create ports
  set user_axi_clk [ create_bd_port -dir I -type clk -freq_hz 250000000 user_axi_clk ]
  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {user_axi_dma:user_axi_ctrl} \
   CONFIG.ASSOCIATED_RESET {user_axi_rstn} \
 ] $user_axi_clk
  set user_axi_hbm_clk [ create_bd_port -dir I -type clk -freq_hz 450000000 user_axi_hbm_clk ]
  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {user_axi_hbm_s31:user_axi_hbm_s00:user_axi_hbm_s01:user_axi_hbm_s02:user_axi_hbm_s03:user_axi_hbm_s04:user_axi_hbm_s05:user_axi_hbm_s06:user_axi_hbm_s07:user_axi_hbm_s08:user_axi_hbm_s09:user_axi_hbm_s10:user_axi_hbm_s11:user_axi_hbm_s12:user_axi_hbm_s13:user_axi_hbm_s14:user_axi_hbm_s30:user_axi_hbm_s15:user_axi_hbm_s16:user_axi_hbm_s17:user_axi_hbm_s18:user_axi_hbm_s19:user_axi_hbm_s20:user_axi_hbm_s21:user_axi_hbm_s22:user_axi_hbm_s23:user_axi_hbm_s24:user_axi_hbm_s25:user_axi_hbm_s26:user_axi_hbm_s27:user_axi_hbm_s28:user_axi_hbm_s29} \
 ] $user_axi_hbm_clk
  set user_axi_rstn [ create_bd_port -dir I -type rst user_axi_rstn ]

  # Create instance: ctrl_slice, and set properties
  set ctrl_slice [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_register_slice:2.1 ctrl_slice ]

  # Create instance: dma_pipe, and set properties
  set dma_pipe [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_register_slice:2.1 dma_pipe ]

  # Create instance: dummy_bram_controller, and set properties
  set dummy_bram_controller [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.1 dummy_bram_controller ]
  set_property CONFIG.PROTOCOL {AXI4LITE} $dummy_bram_controller


  # Create instance: dummy_bram_controller_bram, and set properties
  set dummy_bram_controller_bram [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.4 dummy_bram_controller_bram ]
  set_property CONFIG.Memory_Type {True_Dual_Port_RAM} $dummy_bram_controller_bram


  # Create instance: hbm_channel_nc
  create_hier_cell_hbm_channel_nc [current_bd_instance .] hbm_channel_nc

  # Create instance: smartconnect_dma, and set properties
  set smartconnect_dma [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 smartconnect_dma ]
  set_property -dict [list \
    CONFIG.NUM_CLKS {2} \
    CONFIG.NUM_MI {1} \
    CONFIG.NUM_SI {1} \
  ] $smartconnect_dma


  # Create interface connections
  connect_bd_intf_net -intf_net ctrl_slice_M_AXI [get_bd_intf_pins ctrl_slice/M_AXI] [get_bd_intf_pins dummy_bram_controller/S_AXI]
  connect_bd_intf_net -intf_net dma_pipe_M_AXI [get_bd_intf_pins dma_pipe/M_AXI] [get_bd_intf_pins smartconnect_dma/S00_AXI]
  connect_bd_intf_net -intf_net dummy_bram_controller_BRAM_PORTA [get_bd_intf_pins dummy_bram_controller/BRAM_PORTA] [get_bd_intf_pins dummy_bram_controller_bram/BRAM_PORTA]
  connect_bd_intf_net -intf_net dummy_bram_controller_BRAM_PORTB [get_bd_intf_pins dummy_bram_controller/BRAM_PORTB] [get_bd_intf_pins dummy_bram_controller_bram/BRAM_PORTB]
  connect_bd_intf_net -intf_net hbm_channel_nc_user_axi_hbm_s00 [get_bd_intf_ports user_axi_hbm_s00] [get_bd_intf_pins hbm_channel_nc/user_axi_hbm_s00]
  connect_bd_intf_net -intf_net hbm_channel_nc_user_axi_hbm_s01 [get_bd_intf_ports user_axi_hbm_s01] [get_bd_intf_pins hbm_channel_nc/user_axi_hbm_s01]
  connect_bd_intf_net -intf_net hbm_channel_nc_user_axi_hbm_s02 [get_bd_intf_ports user_axi_hbm_s02] [get_bd_intf_pins hbm_channel_nc/user_axi_hbm_s02]
  connect_bd_intf_net -intf_net hbm_channel_nc_user_axi_hbm_s03 [get_bd_intf_ports user_axi_hbm_s03] [get_bd_intf_pins hbm_channel_nc/user_axi_hbm_s03]
  connect_bd_intf_net -intf_net hbm_channel_nc_user_axi_hbm_s04 [get_bd_intf_ports user_axi_hbm_s04] [get_bd_intf_pins hbm_channel_nc/user_axi_hbm_s04]
  connect_bd_intf_net -intf_net hbm_channel_nc_user_axi_hbm_s05 [get_bd_intf_ports user_axi_hbm_s05] [get_bd_intf_pins hbm_channel_nc/user_axi_hbm_s05]
  connect_bd_intf_net -intf_net hbm_channel_nc_user_axi_hbm_s06 [get_bd_intf_ports user_axi_hbm_s06] [get_bd_intf_pins hbm_channel_nc/user_axi_hbm_s06]
  connect_bd_intf_net -intf_net hbm_channel_nc_user_axi_hbm_s07 [get_bd_intf_ports user_axi_hbm_s07] [get_bd_intf_pins hbm_channel_nc/user_axi_hbm_s07]
  connect_bd_intf_net -intf_net hbm_channel_nc_user_axi_hbm_s08 [get_bd_intf_ports user_axi_hbm_s08] [get_bd_intf_pins hbm_channel_nc/user_axi_hbm_s08]
  connect_bd_intf_net -intf_net hbm_channel_nc_user_axi_hbm_s09 [get_bd_intf_ports user_axi_hbm_s09] [get_bd_intf_pins hbm_channel_nc/user_axi_hbm_s09]
  connect_bd_intf_net -intf_net hbm_channel_nc_user_axi_hbm_s10 [get_bd_intf_ports user_axi_hbm_s10] [get_bd_intf_pins hbm_channel_nc/user_axi_hbm_s10]
  connect_bd_intf_net -intf_net hbm_channel_nc_user_axi_hbm_s11 [get_bd_intf_ports user_axi_hbm_s11] [get_bd_intf_pins hbm_channel_nc/user_axi_hbm_s11]
  connect_bd_intf_net -intf_net hbm_channel_nc_user_axi_hbm_s12 [get_bd_intf_ports user_axi_hbm_s12] [get_bd_intf_pins hbm_channel_nc/user_axi_hbm_s12]
  connect_bd_intf_net -intf_net hbm_channel_nc_user_axi_hbm_s13 [get_bd_intf_ports user_axi_hbm_s13] [get_bd_intf_pins hbm_channel_nc/user_axi_hbm_s13]
  connect_bd_intf_net -intf_net hbm_channel_nc_user_axi_hbm_s14 [get_bd_intf_ports user_axi_hbm_s14] [get_bd_intf_pins hbm_channel_nc/user_axi_hbm_s14]
  connect_bd_intf_net -intf_net hbm_channel_nc_user_axi_hbm_s15 [get_bd_intf_ports user_axi_hbm_s15] [get_bd_intf_pins hbm_channel_nc/user_axi_hbm_s15]
  connect_bd_intf_net -intf_net hbm_channel_nc_user_axi_hbm_s16 [get_bd_intf_ports user_axi_hbm_s16] [get_bd_intf_pins hbm_channel_nc/user_axi_hbm_s16]
  connect_bd_intf_net -intf_net hbm_channel_nc_user_axi_hbm_s17 [get_bd_intf_ports user_axi_hbm_s17] [get_bd_intf_pins hbm_channel_nc/user_axi_hbm_s17]
  connect_bd_intf_net -intf_net hbm_channel_nc_user_axi_hbm_s18 [get_bd_intf_ports user_axi_hbm_s18] [get_bd_intf_pins hbm_channel_nc/user_axi_hbm_s18]
  connect_bd_intf_net -intf_net hbm_channel_nc_user_axi_hbm_s19 [get_bd_intf_ports user_axi_hbm_s19] [get_bd_intf_pins hbm_channel_nc/user_axi_hbm_s19]
  connect_bd_intf_net -intf_net hbm_channel_nc_user_axi_hbm_s20 [get_bd_intf_ports user_axi_hbm_s20] [get_bd_intf_pins hbm_channel_nc/user_axi_hbm_s20]
  connect_bd_intf_net -intf_net hbm_channel_nc_user_axi_hbm_s21 [get_bd_intf_ports user_axi_hbm_s21] [get_bd_intf_pins hbm_channel_nc/user_axi_hbm_s21]
  connect_bd_intf_net -intf_net hbm_channel_nc_user_axi_hbm_s22 [get_bd_intf_ports user_axi_hbm_s22] [get_bd_intf_pins hbm_channel_nc/user_axi_hbm_s22]
  connect_bd_intf_net -intf_net hbm_channel_nc_user_axi_hbm_s23 [get_bd_intf_ports user_axi_hbm_s23] [get_bd_intf_pins hbm_channel_nc/user_axi_hbm_s23]
  connect_bd_intf_net -intf_net hbm_channel_nc_user_axi_hbm_s24 [get_bd_intf_ports user_axi_hbm_s24] [get_bd_intf_pins hbm_channel_nc/user_axi_hbm_s24]
  connect_bd_intf_net -intf_net hbm_channel_nc_user_axi_hbm_s25 [get_bd_intf_ports user_axi_hbm_s25] [get_bd_intf_pins hbm_channel_nc/user_axi_hbm_s25]
  connect_bd_intf_net -intf_net hbm_channel_nc_user_axi_hbm_s26 [get_bd_intf_ports user_axi_hbm_s26] [get_bd_intf_pins hbm_channel_nc/user_axi_hbm_s26]
  connect_bd_intf_net -intf_net hbm_channel_nc_user_axi_hbm_s27 [get_bd_intf_ports user_axi_hbm_s27] [get_bd_intf_pins hbm_channel_nc/user_axi_hbm_s27]
  connect_bd_intf_net -intf_net hbm_channel_nc_user_axi_hbm_s28 [get_bd_intf_ports user_axi_hbm_s28] [get_bd_intf_pins hbm_channel_nc/user_axi_hbm_s28]
  connect_bd_intf_net -intf_net hbm_channel_nc_user_axi_hbm_s29 [get_bd_intf_ports user_axi_hbm_s29] [get_bd_intf_pins hbm_channel_nc/user_axi_hbm_s29]
  connect_bd_intf_net -intf_net hbm_channel_nc_user_axi_hbm_s30 [get_bd_intf_ports user_axi_hbm_s30] [get_bd_intf_pins hbm_channel_nc/user_axi_hbm_s30]
  connect_bd_intf_net -intf_net smartconnect_dma_M00_AXI [get_bd_intf_ports user_axi_hbm_s31] [get_bd_intf_pins smartconnect_dma/M00_AXI]
  connect_bd_intf_net -intf_net user_axi_ctrl_1 [get_bd_intf_ports user_axi_ctrl] [get_bd_intf_pins ctrl_slice/S_AXI]
  connect_bd_intf_net -intf_net user_axi_dma_1 [get_bd_intf_ports user_axi_dma] [get_bd_intf_pins dma_pipe/S_AXI]

  # Create port connections
  connect_bd_net -net dma_reset_peripheral_aresetn [get_bd_ports user_axi_rstn] [get_bd_pins ctrl_slice/aresetn] [get_bd_pins dma_pipe/aresetn] [get_bd_pins dummy_bram_controller/s_axi_aresetn] [get_bd_pins smartconnect_dma/aresetn]
  connect_bd_net -net user_axi_clk_1 [get_bd_ports user_axi_clk] [get_bd_pins ctrl_slice/aclk] [get_bd_pins dma_pipe/aclk] [get_bd_pins dummy_bram_controller/s_axi_aclk] [get_bd_pins smartconnect_dma/aclk]
  connect_bd_net -net user_axi_hbm_clk_1 [get_bd_ports user_axi_hbm_clk] [get_bd_pins hbm_channel_nc/user_axi_hbm_clk] [get_bd_pins smartconnect_dma/aclk1]

  # Create address segments
  assign_bd_address -offset 0x01000000 -range 0x00008000 -target_address_space [get_bd_addr_spaces user_axi_ctrl] [get_bd_addr_segs dummy_bram_controller/S_AXI/Mem0] -force
  assign_bd_address -offset 0x00000000 -range 0x000200000000 -target_address_space [get_bd_addr_spaces user_axi_dma] [get_bd_addr_segs user_axi_hbm_s31/Reg] -force

  set_property USAGE memory [get_bd_addr_segs user_axi_hbm_s31/Reg]


  # Restore current instance
  current_bd_instance $oldCurInst

  validate_bd_design
  save_bd_design
  close_bd_design $design_name 
}
# End of cr_bd_user_logic()