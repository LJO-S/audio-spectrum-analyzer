# =====================================================================
# Extract arguments from tcl_args
set project_dir       [lindex $argv 0]
set project_name      [lindex $argv 1]
set top_entity        [lindex $argv 2]
set src_dir           [lindex $argv 3]
set open_gui_opt      [lindex $argv 4]
# =====================================================================
# Create project
create_project -force $project_name ${project_dir}/${project_name}
# =====================================================================
# Add all VHDL files from the source directory

# Define a recursive search procedure
proc find_files {dir pattern} {
    # 1. Find files in the current directory that match the pattern
    set files [glob -nocomplain -directory $dir $pattern]

    # 2. Find all subdirectories in the current directory
    set subdirs [glob -nocomplain -directory $dir -type d *]

    # 3. Loop through subdirectories and call this procedure recursively,
    #    skipping "test" directories to avoid picking up testbench syntax
    foreach subdir $subdirs {
        if {[file tail $subdir] eq "test"} {
            continue
        }
        set files [concat $files [find_files $subdir $pattern]]
    }

    return $files
}

set vhdl_files [find_files $src_dir "*.vhd"]

if {[llength $vhdl_files] > 0} {
    add_files -norecurse $vhdl_files
    set_property FILE_TYPE "VHDL 2008" [get_files $vhdl_files]
} else {
    puts "ERROR: No VHDL files found in $src_dir"
    exit 1
}
# =====================================================================
# Add constraint file (for timing summary)
set constr_path "${project_dir}/${project_name}/${project_name}.srcs/constrs_1/new"
file mkdir $constr_path
set clk_xdc "${constr_path}/clk.xdc"
set fh [open $clk_xdc w]
puts $fh "create_clock -period 4.000 -name clk -waveform {0.000 2.000} \[get_ports clk\]"
close $fh
add_files -fileset constrs_1 $clk_xdc
set_property target_constrs_file $clk_xdc [current_fileset -constrset]
# =====================================================================
# Set the top-level entity for synthesis
set_property top $top_entity [current_fileset]
# =====================================================================
# Configure general project settings
set obj [get_projects $project_name]
set_property "default_lib" "xil_defaultlib" $obj
set_property "part" "xc7z010clg400-1" $obj
set_property "simulator_language" "Mixed" $obj
set_property "source_mgmt_mode" "DisplayOnly" $obj
set_property "target_language" "VHDL" $obj
# =====================================================================
# Run Synthesis
reset_run synth_1
launch_runs synth_1 -jobs 4
wait_on_run synth_1
# =====================================================================
# Open the run to access the netlist for reporting
open_run synth_1
# =====================================================================
puts "-------------------------------------------------------"
puts " UTILIZATION SUMMARY "
puts "-------------------------------------------------------"
report_utilization -hierarchical -hierarchical_depth 2
# =====================================================================
puts "-------------------------------------------------------"
puts " TIMING SUMMARY "
puts "-------------------------------------------------------"
report_timing_summary -delay_type min_max \
                    -report_unconstrained \
                    -check_timing_verbose \
                    -max_paths 150 \
                    -input_pins -routable_nets -name timing_1 \
                    -file "${project_dir}/${project_name}/timing_report.txt"
# =====================================================================
if {$open_gui_opt == "True"} {
    puts "Opening Vivado GUI..."
    start_gui
} else {
    close_project
}
# =====================================================================
