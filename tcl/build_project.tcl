################################################################
# builds/build.tcl
#
# Creates a dated Vivado project (build_DDMMYY), runs the full
# implementation flow, and exports hardware + bitstream if timing passes.
#
# Usage (from Vivado Tcl console):
#   source builds/build.tcl
#
# Note: any existing build_DDMMYY folder is deleted and recreated.
################################################################

################################################################
# Date-stamped build directory
################################################################
set day   [clock format [clock seconds] -format "%d"]
set month [clock format [clock seconds] -format "%m"]
set year  [clock format [clock seconds] -format "%y"]
set build_name "build_${day}${month}${year}"

set script_folder [file normalize [file dirname [info script]]]
set repo_root     [file normalize [file join $script_folder ".."]]
set build_dir     [file join $repo_root "builds"]


# TODO this should only delete the specific build dir, not the entire builds/ folder (which may contain other builds)
if { [file exists [file join $build_dir $build_name]] } {
    puts "INFO: Removing existing directory: $build_dir"
    file delete -force [file normalize [file join $build_dir $build_name] ]
}
# if { [file exists $build_dir] } {
#     puts "INFO: Removing existing directory: $build_dir"
#     file delete -force $build_dir
# }
# file mkdir $build_dir

################################################################
# Set board repo path and find the part number for the board
################################################################
set_param board.repoPaths [list "/mnt/tools/projects/fpga/vivado-boards/new/board_files"]
set REPOPATH [get_param board.repoPaths]
puts "Board repo path: $REPOPATH"

################################################################
# Create project
################################################################
create_project project_1 [file join $build_dir $build_name] -part xc7z010clg400-1
set_property BOARD_PART digilentinc.com:zybo-z7-10:part0:1.2 [current_project]

################################################################
# Add constraint files from constraints/
################################################################
set constraints_dir [file normalize [file join $repo_root "constraints"]]
set xdc_files [glob -nocomplain -directory $constraints_dir "*.xdc"]
if { [llength $xdc_files] > 0 } {
    add_files -fileset constrs_1 -norecurse $xdc_files
    puts "INFO: Added [llength $xdc_files] constraint file(s): $xdc_files"
} else {
    puts "WARNING: No .xdc files found in $constraints_dir"
}

################################################################
# Build block design (sources + IPs + module reference).
# The project is already open so vivado_build.tcl skips its
# own create_project call (guarded by get_projects -quiet).
################################################################
source [file normalize [file join $script_folder "vivado_build.tcl"]]

# Explicitly set the generated BD wrapper as the synthesis top.
# make_wrapper on "top_bd_wrapper.bd" produces entity top_bd_wrapper_wrapper.
set_property top top_bd_wrapper_wrapper [current_fileset]
update_compile_order -fileset sources_1

################################################################
# Incremental compile: reuse DCPs from the most recent prior build.
# Routed DCP --> impl_1 incremental 
# Synth DCP --> synth_1 incremental 
################################################################
set prev_synth_dcp ""
set prev_impl_dcp  ""

set all_builds [glob -nocomplain -directory [file join $repo_root "builds"] -type d "build_*"]

# Remove the current build dir from candidates, then sort by mtime descending
set candidates {}
foreach d $all_builds {
    if { [file normalize $d] ne [file normalize [file join $build_dir $build_name]] } {
        lappend candidates [list [file mtime $d] $d]
    }
}
set candidates [lsort -decreasing -index 0 $candidates]

foreach entry $candidates {
    set prev  [lindex $entry 1]
    set pname [file tail $prev]
    set impl_dcp  [file join $prev "${pname}.runs/impl_1/top_bd_wrapper_wrapper_routed.dcp"]
    set synth_dcp [file join $prev "${pname}.runs/synth_1/top_bd_wrapper_wrapper.dcp"]

    if { $prev_impl_dcp  eq "" && [file exists $impl_dcp]  } { 
        set prev_impl_dcp  $impl_dcp  
        puts "INFO: Found prior impl DCP: $prev_impl_dcp"
    }
    if { $prev_synth_dcp eq "" && [file exists $synth_dcp] } { 
        set prev_synth_dcp $synth_dcp 
        puts "INFO: Found prior synth DCP: $prev_synth_dcp"
    }
    # If both DCP are found, no need to check older builds
    if { $prev_impl_dcp ne "" && $prev_synth_dcp ne "" } break
}

if { $prev_impl_dcp ne "" } {
    puts "INFO: Incremental impl  DCP: $prev_impl_dcp"
    set_property incremental_checkpoint $prev_impl_dcp  [get_runs impl_1]
}
if { $prev_synth_dcp ne "" } {
    puts "INFO: Incremental synth DCP: $prev_synth_dcp"
    set_property incremental_checkpoint $prev_synth_dcp [get_runs synth_1]
}
if { $prev_synth_dcp eq "" && $prev_impl_dcp eq "" } {
    puts "INFO: No prior DCP found — running full compile."
}

################################################################
# Synthesis
################################################################
puts "INFO: Launching synthesis (4 jobs)..."
launch_runs synth_1 -jobs 4
wait_on_run synth_1
if { [get_property PROGRESS [get_runs synth_1]] ne "100%" } {
    error "ERROR: Synthesis failed - aborting..."
}
puts "INFO: Synthesis complete!"

################################################################
# Implementation
################################################################
puts "INFO: Launching implementation (4 jobs)..."
launch_runs impl_1 -jobs 4
wait_on_run impl_1
if { [get_property PROGRESS [get_runs impl_1]] ne "100%" } {
    error "ERROR: Implementation failed - aborting..."
}
puts "INFO: Implementation complete!"

################################################################
# Timing check — only proceed if WNS >= 0 and WHS >= 0
################################################################
set wns [get_property STATS.WNS [get_runs impl_1]]
set whs [get_property STATS.WHS [get_runs impl_1]]
puts "INFO: WNS = $wns ns  |  WHS = $whs ns"

if { [string is double -strict $wns] && $wns >= 0 &&
     [string is double -strict $whs] && $whs >= 0 } {

    ################################################################
    # Bitstream generation
    ################################################################
    puts "INFO: Timing successful! Generating bitstream..."
    launch_runs impl_1 -to_step write_bitstream -jobs 4
    wait_on_run impl_1
    puts "INFO: Bitstream generated."

    ################################################################
    # Hardware export (XSA for Vitis / PetaLinux)
    ################################################################
    set xsa_path [file join $build_dir $build_name "top_bd_wrapper_wrapper.xsa"]
    write_hw_platform -fixed -include_bit -force -file $xsa_path
    puts "INFO: Hardware exported to: $xsa_path"
    puts "INFO: *** Build successful: $build_name ***"

} else {
    puts "WARNING: Timing NOT met (WNS=$wns ns, WHS=$whs ns)."
    puts "WARNING: Bitstream and hardware export skipped."
}
