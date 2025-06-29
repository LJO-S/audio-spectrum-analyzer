
################################################################
# This is a generated script based on design: top_appl
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2022.2
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   catch {common::send_gid_msg -ssname BD::TCL -id 2041 -severity "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source top_appl_script.tcl

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xc7z010clg400-1
   set_property BOARD_PART digilentinc.com:zybo-z7-10:part0:1.2 [current_project]
}


# CHANGE DESIGN NAME HERE
variable design_name
set design_name top_appl

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      common::send_gid_msg -ssname BD::TCL -id 2001 -severity "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_gid_msg -ssname BD::TCL -id 2002 -severity "INFO" "Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   common::send_gid_msg -ssname BD::TCL -id 2003 -severity "INFO" "Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   common::send_gid_msg -ssname BD::TCL -id 2004 -severity "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

common::send_gid_msg -ssname BD::TCL -id 2005 -severity "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   catch {common::send_gid_msg -ssname BD::TCL -id 2006 -severity "ERROR" $errMsg}
   return $nRet
}

set bCheckIPsPassed 1
##################################################################
# CHECK IPs
##################################################################
set bCheckIPs 1
if { $bCheckIPs == 1 } {
   set list_check_ips "\ 
xilinx.com:ip:c_addsub:12.0\
xilinx.com:ip:clk_wiz:6.0\
xilinx.com:ip:mult_gen:12.0\
xilinx.com:ip:xfft:9.1\
xilinx.com:ip:xlconstant:1.1\
xilinx.com:ip:xlslice:1.0\
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

if { $bCheckIPsPassed != 1 } {
  common::send_gid_msg -ssname BD::TCL -id 2023 -severity "WARNING" "Will not continue with creation of design due to the error(s) above."
  return 3
}

##################################################################
# DESIGN PROCs
##################################################################



# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder
  variable design_name

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
  set S_AXIS_DATA_0 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 S_AXIS_DATA_0 ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {25000000} \
   CONFIG.HAS_TKEEP {0} \
   CONFIG.HAS_TLAST {1} \
   CONFIG.HAS_TREADY {1} \
   CONFIG.HAS_TSTRB {0} \
   CONFIG.LAYERED_METADATA {undef} \
   CONFIG.TDATA_NUM_BYTES {4} \
   CONFIG.TDEST_WIDTH {0} \
   CONFIG.TID_WIDTH {0} \
   CONFIG.TUSER_WIDTH {0} \
   ] $S_AXIS_DATA_0


  # Create ports
  set event_data_in_channel_halt [ create_bd_port -dir O -type intr event_data_in_channel_halt ]
  set event_data_out_channel_halt [ create_bd_port -dir O -type intr event_data_out_channel_halt ]
  set event_frame_started [ create_bd_port -dir O -type intr event_frame_started ]
  set event_status_channel_halt [ create_bd_port -dir O -type intr event_status_channel_halt ]
  set event_tlast_missing [ create_bd_port -dir O -type intr event_tlast_missing ]
  set event_tlast_unexpected [ create_bd_port -dir O -type intr event_tlast_unexpected ]
  set m_axis_data_tlast [ create_bd_port -dir O m_axis_data_tlast ]
  set m_axis_data_tvalid [ create_bd_port -dir O m_axis_data_tvalid ]
  set o_BLK_EXP [ create_bd_port -dir O -from 7 -to 0 o_BLK_EXP ]
  set o_FFT_mag [ create_bd_port -dir O -from 31 -to 0 -type data o_FFT_mag ]
  set o_XK_INDEX [ create_bd_port -dir O -from 9 -to 0 o_XK_INDEX ]
  set o_clk_25 [ create_bd_port -dir O -type clk o_clk_25 ]
  set o_clk_250 [ create_bd_port -dir O -type clk o_clk_250 ]
  set sys_clock [ create_bd_port -dir I -type clk -freq_hz 125000000 sys_clock ]
  set_property -dict [ list \
   CONFIG.PHASE {0.0} \
 ] $sys_clock

  # Create instance: c_addsub_0, and set properties
  set c_addsub_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:c_addsub:12.0 c_addsub_0 ]
  set_property -dict [list \
    CONFIG.A_Type {Signed} \
    CONFIG.A_Width {32} \
    CONFIG.B_Type {Signed} \
    CONFIG.B_Value {00000000000000000000000000000000} \
    CONFIG.B_Width {32} \
    CONFIG.CE {false} \
    CONFIG.Latency {1} \
    CONFIG.Out_Width {32} \
  ] $c_addsub_0


  # Create instance: clk_wiz_0, and set properties
  set clk_wiz_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:6.0 clk_wiz_0 ]
  set_property -dict [list \
    CONFIG.CLKIN2_JITTER_PS {100.0} \
    CONFIG.CLKOUT1_JITTER {165.419} \
    CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {25.000} \
    CONFIG.CLKOUT2_JITTER {104.759} \
    CONFIG.CLKOUT2_PHASE_ERROR {96.948} \
    CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {250.000} \
    CONFIG.CLKOUT2_USED {true} \
    CONFIG.CLK_IN1_BOARD_INTERFACE {sys_clock} \
    CONFIG.CLK_OUT1_PORT {clk_25} \
    CONFIG.CLK_OUT2_PORT {clk_250} \
    CONFIG.MMCM_CLKIN2_PERIOD {10.000} \
    CONFIG.MMCM_CLKOUT0_DIVIDE_F {40.000} \
    CONFIG.MMCM_CLKOUT1_DIVIDE {4} \
    CONFIG.NUM_OUT_CLKS {2} \
    CONFIG.SECONDARY_SOURCE {Single_ended_clock_capable_pin} \
    CONFIG.USE_BOARD_FLOW {true} \
    CONFIG.USE_INCLK_SWITCHOVER {false} \
    CONFIG.USE_LOCKED {false} \
    CONFIG.USE_RESET {false} \
  ] $clk_wiz_0


  # Create instance: mult_gen_0, and set properties
  set mult_gen_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:mult_gen:12.0 mult_gen_0 ]
  set_property -dict [list \
    CONFIG.MultType {Parallel_Multiplier} \
    CONFIG.PortAType {Signed} \
    CONFIG.PortAWidth {16} \
    CONFIG.PortBType {Signed} \
    CONFIG.PortBWidth {16} \
  ] $mult_gen_0


  # Create instance: mult_gen_1, and set properties
  set mult_gen_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:mult_gen:12.0 mult_gen_1 ]
  set_property -dict [list \
    CONFIG.MultType {Parallel_Multiplier} \
    CONFIG.PortAType {Signed} \
    CONFIG.PortAWidth {16} \
    CONFIG.PortBType {Signed} \
    CONFIG.PortBWidth {16} \
  ] $mult_gen_1


  # Create instance: xfft_0, and set properties
  set xfft_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xfft:9.1 xfft_0 ]
  set_property -dict [list \
    CONFIG.data_format {fixed_point} \
    CONFIG.implementation_options {pipelined_streaming_io} \
    CONFIG.input_width {16} \
    CONFIG.memory_options_hybrid {false} \
    CONFIG.number_of_stages_using_block_ram_for_data_and_phase_factors {3} \
    CONFIG.output_ordering {natural_order} \
    CONFIG.phase_factor_width {16} \
    CONFIG.rounding_modes {truncation} \
    CONFIG.run_time_configurable_transform_length {false} \
    CONFIG.scaling_options {block_floating_point} \
    CONFIG.target_clock_frequency {25} \
    CONFIG.xk_index {true} \
  ] $xfft_0


  # Create instance: xlconstant_0, and set properties
  set xlconstant_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_0 ]

  # Create instance: xlconstant_1, and set properties
  set xlconstant_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_1 ]
  set_property CONFIG.CONST_VAL {0} $xlconstant_1


  # Create instance: xlslice_0, and set properties
  set xlslice_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 xlslice_0 ]
  set_property -dict [list \
    CONFIG.DIN_FROM {31} \
    CONFIG.DIN_TO {16} \
  ] $xlslice_0


  # Create instance: xlslice_1, and set properties
  set xlslice_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 xlslice_1 ]
  set_property -dict [list \
    CONFIG.DIN_FROM {15} \
    CONFIG.DIN_TO {0} \
  ] $xlslice_1


  # Create instance: xlslice_2, and set properties
  set xlslice_2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 xlslice_2 ]
  set_property -dict [list \
    CONFIG.DIN_FROM {23} \
    CONFIG.DIN_TO {16} \
    CONFIG.DIN_WIDTH {24} \
  ] $xlslice_2


  # Create instance: xlslice_3, and set properties
  set xlslice_3 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 xlslice_3 ]
  set_property -dict [list \
    CONFIG.DIN_FROM {9} \
    CONFIG.DIN_TO {0} \
    CONFIG.DIN_WIDTH {24} \
  ] $xlslice_3


  # Create interface connections
  connect_bd_intf_net -intf_net S_AXIS_DATA_XFFT [get_bd_intf_ports S_AXIS_DATA_0] [get_bd_intf_pins xfft_0/S_AXIS_DATA]

  # Create port connections
  connect_bd_net -net c_addsub_0_S [get_bd_ports o_FFT_mag] [get_bd_pins c_addsub_0/S]
  connect_bd_net -net clk_wiz_0_clk_25 [get_bd_ports o_clk_25] [get_bd_pins c_addsub_0/CLK] [get_bd_pins clk_wiz_0/clk_25] [get_bd_pins mult_gen_0/CLK] [get_bd_pins mult_gen_1/CLK] [get_bd_pins xfft_0/aclk]
  connect_bd_net -net clk_wiz_0_clk_250 [get_bd_ports o_clk_250] [get_bd_pins clk_wiz_0/clk_250]
  connect_bd_net -net mult_gen_0_P [get_bd_pins c_addsub_0/A] [get_bd_pins mult_gen_0/P]
  connect_bd_net -net mult_gen_1_P [get_bd_pins c_addsub_0/B] [get_bd_pins mult_gen_1/P]
  connect_bd_net -net sys_clock_1 [get_bd_ports sys_clock] [get_bd_pins clk_wiz_0/clk_in1]
  connect_bd_net -net xfft_0_event_data_in_channel_halt [get_bd_ports event_data_in_channel_halt] [get_bd_pins xfft_0/event_data_in_channel_halt]
  connect_bd_net -net xfft_0_event_data_out_channel_halt [get_bd_ports event_data_out_channel_halt] [get_bd_pins xfft_0/event_data_out_channel_halt]
  connect_bd_net -net xfft_0_event_frame_started [get_bd_ports event_frame_started] [get_bd_pins xfft_0/event_frame_started]
  connect_bd_net -net xfft_0_event_status_channel_halt [get_bd_ports event_status_channel_halt] [get_bd_pins xfft_0/event_status_channel_halt]
  connect_bd_net -net xfft_0_event_tlast_missing [get_bd_ports event_tlast_missing] [get_bd_pins xfft_0/event_tlast_missing]
  connect_bd_net -net xfft_0_event_tlast_unexpected [get_bd_ports event_tlast_unexpected] [get_bd_pins xfft_0/event_tlast_unexpected]
  connect_bd_net -net xfft_0_m_axis_data_tdata [get_bd_pins xfft_0/m_axis_data_tdata] [get_bd_pins xlslice_0/Din] [get_bd_pins xlslice_1/Din]
  connect_bd_net -net xfft_0_m_axis_data_tlast [get_bd_ports m_axis_data_tlast] [get_bd_pins xfft_0/m_axis_data_tlast]
  connect_bd_net -net xfft_0_m_axis_data_tuser [get_bd_pins xfft_0/m_axis_data_tuser] [get_bd_pins xlslice_2/Din] [get_bd_pins xlslice_3/Din]
  connect_bd_net -net xfft_0_m_axis_data_tvalid [get_bd_ports m_axis_data_tvalid] [get_bd_pins xfft_0/m_axis_data_tvalid]
  connect_bd_net -net xlconstant_0_dout [get_bd_pins xfft_0/m_axis_data_tready] [get_bd_pins xlconstant_0/dout]
  connect_bd_net -net xlconstant_1_dout [get_bd_pins xfft_0/s_axis_config_tvalid] [get_bd_pins xlconstant_1/dout]
  connect_bd_net -net xlslice_0_Dout [get_bd_pins mult_gen_0/A] [get_bd_pins mult_gen_0/B] [get_bd_pins xlslice_0/Dout]
  connect_bd_net -net xlslice_1_Dout [get_bd_pins mult_gen_1/A] [get_bd_pins mult_gen_1/B] [get_bd_pins xlslice_1/Dout]
  connect_bd_net -net xlslice_2_Dout [get_bd_ports o_BLK_EXP] [get_bd_pins xlslice_2/Dout]
  connect_bd_net -net xlslice_3_Dout [get_bd_ports o_XK_INDEX] [get_bd_pins xlslice_3/Dout]

  # Create address segments


  # Restore current instance
  current_bd_instance $oldCurInst

  validate_bd_design
  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


